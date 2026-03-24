package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.AdminAttendanceRow;
import com.smartoffice.model.AttendanceLogEntry;
import com.smartoffice.model.TeamAttendance;
import com.smartoffice.utils.DBConnectionUtil;

public class AttendanceDAO {

    private boolean hasAttendanceColumn(String colName) throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND COLUMN_NAME=?")) {
            ps.setString(1, colName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String getAttendanceUserColumn() throws Exception {
        if (hasAttendanceColumn("user_email")) return "user_email";
        if (hasAttendanceColumn("email"))      return "email";
        if (hasAttendanceColumn("username"))   return "username";
        return "username";
    }

    private String resolveForAttendance(String sessionValue) throws Exception {
        String col = getAttendanceUserColumn();
        if ("email".equals(col) || "user_email".equals(col)) return sessionValue;
        try (Connection con = DBConnectionUtil.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, sessionValue);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("username");
        }
        return sessionValue;
    }

    private String getUsernameFromEmail(String email) throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("username");
        }
        return email;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ✅ NEW: Check if the user has an APPROVED leave covering a specific date.
    //    Matches by both username AND email columns in leave_requests to be safe.
    // ─────────────────────────────────────────────────────────────────────────
    public boolean isOnApprovedLeaveOn(String sessionValue, Date date) throws Exception {
        // leave_requests.username stores the plain username (e.g. "prasad nani")
        // We check both the raw sessionValue (email) and resolved username
        String usernameVal = getUsernameFromEmail(sessionValue);

        String sql = "SELECT COUNT(*) FROM leave_requests "
                + "WHERE username IN (?, ?) "
                + "  AND status = 'APPROVED' "
                + "  AND ? BETWEEN from_date AND to_date";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sessionValue);   // try email match
            ps.setString(2, usernameVal);    // try username match
            ps.setDate(3, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }

    public boolean hasPunchedIn(String sessionValue, Date date) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_in FROM attendance WHERE " + col + "=? AND punch_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setDate(2, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getTimestamp("punch_in") != null;
            return false;
        }
    }

    public boolean hasPunchedOut(String sessionValue, Date date) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_out FROM attendance WHERE " + col + "=? AND punch_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setDate(2, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getTimestamp("punch_out") != null;
            return false;
        }
    }

    public boolean isHoliday(Date date) throws Exception {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(date);
        int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);
        if (dayOfWeek == java.util.Calendar.SATURDAY || dayOfWeek == java.util.Calendar.SUNDAY) return true;
        String sql = "SELECT COUNT(*) FROM holidays WHERE holiday_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ✅ NEW: Returns a user-friendly reason why today is blocked, or null if
    //    the user is free to punch in/out.
    // ─────────────────────────────────────────────────────────────────────────
    public String getBlockReason(String sessionValue, Date date) throws Exception {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(date);
        int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);
        if (dayOfWeek == java.util.Calendar.SATURDAY || dayOfWeek == java.util.Calendar.SUNDAY) {
            return "Today is a Weekend. Attendance is not available.";
        }
        String holidaySql = "SELECT holiday_name FROM holidays WHERE holiday_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(holidaySql)) {
            ps.setDate(1, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String name = rs.getString("holiday_name");
                return "Today is a Holiday" + (name != null && !name.isEmpty() ? " (" + name + ")" : "") + ". Attendance is not available.";
            }
        }
        if (isOnApprovedLeaveOn(sessionValue, date)) {
            return "You are on Approved Leave today. Attendance is not available.";
        }
        return null; // no block — punch in/out is allowed
    }

    public void punchIn(String sessionValue) throws Exception {
        Date today = new Date(System.currentTimeMillis());

        // ✅ FIXED: Check weekend/holiday/approved-leave — all with clear messages
        String blockReason = getBlockReason(sessionValue, today);
        if (blockReason != null) {
            throw new Exception(blockReason);
        }

        List<String> userCols = new ArrayList<>();
        if (hasAttendanceColumn("username"))   userCols.add("username");
        if (hasAttendanceColumn("user_email")) userCols.add("user_email");
        if (hasAttendanceColumn("email"))      userCols.add("email");
        if (userCols.isEmpty())                userCols.add("username");

        String cols         = String.join(", ", userCols);
        String placeholders = String.join(", ", java.util.Collections.nCopies(userCols.size(), "?"));
        String sql = "INSERT INTO attendance (" + cols + ", punch_in, punch_date, status) VALUES ("
                + placeholders + ", NOW(), CURDATE(), 'Present') "
                + "ON DUPLICATE KEY UPDATE "
                + "punch_in = IF(punch_in IS NULL, NOW(), punch_in), "
                + "status = 'Present'";

        String usernameVal = getUsernameFromEmail(sessionValue);
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            for (String c : userCols) {
                ps.setString(i++, "email".equals(c) || "user_email".equals(c) ? sessionValue : usernameVal);
            }
            ps.executeUpdate();
        }
    }

    public void punchOut(String sessionValue) throws Exception {
        Date today = new Date(System.currentTimeMillis());

        // ✅ FIXED: Check weekend/holiday/approved-leave — all with clear messages
        String blockReason = getBlockReason(sessionValue, today);
        if (blockReason != null) {
            throw new Exception(blockReason);
        }

        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();

        // ✅ Single shared timestamp — break end_time and punch_out are IDENTICAL
        java.sql.Timestamp punchOutTime = new java.sql.Timestamp(System.currentTimeMillis());

        // ✅ Auto-close any open break at the EXACT punch-out timestamp
        try {
            boolean wasOnBreak = BreakDAO.isCurrentlyOnBreak(sessionValue);
            if (wasOnBreak) {
                BreakDAO.autoEndBreakAtTime(sessionValue, punchOutTime);
            }
        } catch (Exception e) {
            System.err.println("[AttendanceDAO] Warning: Could not auto-end break: " + e.getMessage());
        }

        // ✅ Record punch-out using same captured timestamp
        String sql = "UPDATE attendance "
                + "SET punch_out = ?, "
                + "    status = CASE "
                + "        WHEN TIMESTAMPDIFF(HOUR, punch_in, ?) < 4 THEN 'Half Day' "
                + "        ELSE 'Present' "
                + "    END "
                + "WHERE " + col + " = ? AND punch_date = CURDATE() AND punch_out IS NULL";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, punchOutTime);
            ps.setTimestamp(2, punchOutTime);
            ps.setString(3, id);
            ps.executeUpdate();
        }
    }

    public void updateDailyStatus() throws Exception {
        String sql = "UPDATE attendance SET status = CASE "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NOT NULL AND TIMESTAMPDIFF(HOUR, punch_in, punch_out) >= 4 THEN 'Present' "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NOT NULL AND TIMESTAMPDIFF(HOUR, punch_in, punch_out) < 4  THEN 'Half Day' "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NULL THEN 'In Progress' "
                + "ELSE 'Absent' END "
                + "WHERE punch_date = CURDATE() AND status NOT IN ('On Leave')";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    public void fixAttendanceStatus() throws Exception {
        String sql = "UPDATE attendance SET status = CASE "
                + "WHEN punch_in IS NOT NULL THEN 'Present' "
                + "ELSE 'Absent' END "
                + "WHERE punch_date = CURDATE() AND status NOT IN ('On Leave')";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    public ResultSet getTodayAttendance(String sessionValue) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_in, punch_out FROM attendance WHERE " + col + "=? AND punch_date=CURDATE()";
        Connection con = DBConnectionUtil.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, id);
        return ps.executeQuery();
    }

    public List<TeamAttendance> getTeamAttendanceForToday(String managerUsername) throws Exception {
        List<TeamAttendance> list = new ArrayList<>();
        String aCol   = getAttendanceUserColumn();
        String joinOn = "username".equals(aCol) ? "a.username = u.username" : "a." + aCol + " = u.email";
        String sql = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "a.punch_in, a.punch_out, a.status "
                + "FROM (SELECT DISTINCT tm.username FROM team_members tm "
                + "      JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?) team_users "
                + "JOIN users u ON u.email = team_users.username "
                + "LEFT JOIN attendance a ON " + joinOn + " AND a.punch_date = CURDATE() "
                + "ORDER BY fullname";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, managerUsername);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TeamAttendance ta = new TeamAttendance();
                ta.setUsername(rs.getString("email"));
                ta.setFullName(rs.getString("fullname"));
                ta.setPunchIn(rs.getTimestamp("punch_in"));
                ta.setPunchOut(rs.getTimestamp("punch_out"));
                String dbSt = rs.getString("status");
                if ("On Leave".equalsIgnoreCase(dbSt)) {
                    ta.setStatus("On Leave");
                } else if (ta.getPunchIn() == null) {
                    ta.setStatus("Absent");
                } else if (ta.getPunchOut() == null) {
                    ta.setStatus("Punched In");
                } else if ("Half Day".equalsIgnoreCase(dbSt)) {
                    ta.setStatus("Half Day");
                } else {
                    ta.setStatus("Present");
                }
                list.add(ta);
            }
        }
        return list;
    }

    public List<TeamAttendance> getTeamAttendanceForMonth(String managerUsername) throws Exception {
        LocalDate now = LocalDate.now();
        return getTeamAttendanceForDateRange(managerUsername,
                now.withDayOfMonth(1), now.withDayOfMonth(now.lengthOfMonth()));
    }

    /** Attendance rows for a manager's team between {@code start} and {@code end} (inclusive). */
    public List<TeamAttendance> getTeamAttendanceForDateRange(String managerUsername, LocalDate start, LocalDate end)
            throws Exception {
        List<TeamAttendance> list = new ArrayList<>();
        String aCol   = getAttendanceUserColumn();
        String joinOn = "username".equals(aCol) ? "a.username = u.username" : "a." + aCol + " = u.email";
        String sql = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "a.punch_date, a.punch_in, a.punch_out, a.status "
                + "FROM (SELECT DISTINCT tm.username FROM team_members tm "
                + "      JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?) team_users "
                + "JOIN users u ON u.email = team_users.username "
                + "LEFT JOIN attendance a ON " + joinOn
                + " AND a.punch_date BETWEEN ? AND ? "
                + "ORDER BY fullname, a.punch_date";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, managerUsername);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TeamAttendance ta = new TeamAttendance();
                ta.setUsername(rs.getString("email"));
                ta.setFullName(rs.getString("fullname"));
                ta.setAttendanceDate(rs.getDate("punch_date"));
                ta.setPunchIn(rs.getTimestamp("punch_in"));
                ta.setPunchOut(rs.getTimestamp("punch_out"));
                try { ta.setStatus(rs.getString("status")); } catch (Exception ignored) {}
                list.add(ta);
            }
        }
        return list;
    }

    public List<AdminAttendanceRow> getAllAttendanceForToday() throws Exception {
        List<AdminAttendanceRow> list = new ArrayList<>();
        String aCol    = getAttendanceUserColumn();
        String userCol = "username".equals(aCol) ? "username" : "email";
        String sql = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "COALESCE(u.designation,'') AS designation, a.punch_in, a.punch_out, a.status "
                + "FROM users u "
                + "LEFT JOIN attendance a ON a.punch_date = CURDATE() AND a." + aCol + " = u." + userCol + " "
                + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                + "ORDER BY fullname";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AdminAttendanceRow row = new AdminAttendanceRow();
                row.setEmail(rs.getString("email"));
                row.setFullName(rs.getString("fullname"));
                try { row.setDesignation(rs.getString("designation")); } catch (Exception e) { /* ignore */ }
                row.setPunchIn(rs.getTimestamp("punch_in"));
                row.setPunchOut(rs.getTimestamp("punch_out"));
                row.setBreakDurationFormatted("--");
                String dbSt = rs.getString("status");
                row.setAttendanceStatus(dbSt);
                if ("On Leave".equalsIgnoreCase(dbSt)) {
                    row.setLiveStatus("ON LEAVE");
                } else {
                    row.setLiveStatus(row.getPunchIn() == null ? "ABSENT"
                            : (row.getPunchOut() == null ? "PUNCHED IN" : "PUNCHED OUT"));
                }
                list.add(row);
            }
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("designation")) {
                list.clear();
                String sqlNoDesig = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                        + "a.punch_in, a.punch_out, a.status "
                        + "FROM users u "
                        + "LEFT JOIN attendance a ON a.punch_date = CURDATE() AND a." + aCol + " = u." + userCol + " "
                        + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                        + "ORDER BY fullname";
                try (Connection con = DBConnectionUtil.getConnection();
                     PreparedStatement ps = con.prepareStatement(sqlNoDesig)) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        AdminAttendanceRow row = new AdminAttendanceRow();
                        row.setEmail(rs.getString("email"));
                        row.setFullName(rs.getString("fullname"));
                        row.setDesignation("");
                        row.setPunchIn(rs.getTimestamp("punch_in"));
                        row.setPunchOut(rs.getTimestamp("punch_out"));
                        row.setBreakDurationFormatted("--");
                        String dbSt = rs.getString("status");
                        row.setAttendanceStatus(dbSt);
                        if ("On Leave".equalsIgnoreCase(dbSt)) {
                            row.setLiveStatus("ON LEAVE");
                        } else {
                            row.setLiveStatus(row.getPunchIn() == null ? "ABSENT"
                                    : (row.getPunchOut() == null ? "PUNCHED IN" : "PUNCHED OUT"));
                        }
                        list.add(row);
                    }
                }
            } else {
                throw e;
            }
        }
        return list;
    }

    public List<AttendanceLogEntry> getRecentAttendance(String sessionValue, int limit) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance WHERE "
                + col + "=? ORDER BY punch_date DESC LIMIT ?";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setInt(2, limit <= 0 ? 14 : limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AttendanceLogEntry e = new AttendanceLogEntry();
                e.setAttendanceDate(rs.getDate("punch_date"));
                e.setPunchIn(rs.getTimestamp("punch_in"));
                e.setPunchOut(rs.getTimestamp("punch_out"));
                e.setStatus(mapStatus(e.getPunchIn(), e.getPunchOut(), rs.getString("status"), rs.getDate("punch_date")));
                list.add(e);
            }
        }
        return list;
    }

    public List<AttendanceLogEntry> getAttendanceLogByRange(String sessionValue, String fromDate, String toDate)
            throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance "
                + "WHERE " + col + " = ? "
                + "  AND punch_date BETWEEN ? AND ? "
                + "ORDER BY punch_date DESC";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AttendanceLogEntry e = new AttendanceLogEntry();
                e.setAttendanceDate(rs.getDate("punch_date"));
                e.setPunchIn(rs.getTimestamp("punch_in"));
                e.setPunchOut(rs.getTimestamp("punch_out"));
                e.setStatus(mapStatus(e.getPunchIn(), e.getPunchOut(), rs.getString("status"), rs.getDate("punch_date")));
                list.add(e);
            }
        }
        return list;
    }

    public List<AttendanceLogEntry> getFullAttendanceLog(String sessionValue) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance "
                + "WHERE " + col + " = ? "
                + "ORDER BY punch_date DESC";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AttendanceLogEntry e = new AttendanceLogEntry();
                e.setAttendanceDate(rs.getDate("punch_date"));
                e.setPunchIn(rs.getTimestamp("punch_in"));
                e.setPunchOut(rs.getTimestamp("punch_out"));
                e.setStatus(mapStatus(e.getPunchIn(), e.getPunchOut(), rs.getString("status"), rs.getDate("punch_date")));
                list.add(e);
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // ✅ FIXED mapStatus — DB status takes priority over punch logic
    // ─────────────────────────────────────────────────────────────
    private String mapStatus(java.sql.Timestamp punchIn, java.sql.Timestamp punchOut,
            String dbStatus, java.sql.Date attendanceDate) {
        if ("On Leave".equalsIgnoreCase(dbStatus)) return "On Leave";
        if ("Half Day".equalsIgnoreCase(dbStatus)) return "Half Day";
        if (punchIn != null && punchOut != null)   return "Present";
        if (punchIn != null)                       return "Punched In";
        if (attendanceDate != null) {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(attendanceDate);
            int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
            if (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY) return "Weekend";
        }
        return "Absent";
    }

    public void autoCloseMissedPunchOuts() throws Exception {
        // Step 1: Close missed punch-outs for PAST days only — never today
        String closeSql = "UPDATE attendance "
                + "SET punch_out = TIMESTAMP(punch_date, '19:30:00'), status = 'Present' "
                + "WHERE punch_in  IS NOT NULL "
                + "  AND punch_out IS NULL "
                + "  AND punch_date < CURDATE() "
                + "  AND status NOT IN ('On Leave')";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(closeSql)) {
            ps.executeUpdate();
        }

        // Step 2: Mark Half Day if worked < 4 hours — PAST days only
        String halfDaySql = "UPDATE attendance "
                + "SET status = 'Half Day' "
                + "WHERE punch_in  IS NOT NULL "
                + "  AND punch_out IS NOT NULL "
                + "  AND punch_date < CURDATE() "
                + "  AND status NOT IN ('On Leave') "
                + "  AND TIMESTAMPDIFF(HOUR, punch_in, punch_out) < 4";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(halfDaySql)) {
            ps.executeUpdate();
        }
    }

    public void markLeaveInAttendance(String sessionValue, java.sql.Date fromDate, java.sql.Date toDate)
            throws Exception {
        List<String> userCols = new ArrayList<>();
        if (hasAttendanceColumn("username"))   userCols.add("username");
        if (hasAttendanceColumn("user_email")) userCols.add("user_email");
        if (hasAttendanceColumn("email"))      userCols.add("email");
        if (userCols.isEmpty())                userCols.add("username");

        String cols         = String.join(", ", userCols);
        String placeholders = String.join(", ", java.util.Collections.nCopies(userCols.size(), "?"));
        String sql = "INSERT INTO attendance (" + cols + ", punch_date, status) "
                + "VALUES (" + placeholders + ", ?, 'On Leave') "
                + "ON DUPLICATE KEY UPDATE status = 'On Leave', punch_in = NULL, punch_out = NULL";

        String usernameVal = getUsernameFromEmail(sessionValue);
        java.time.LocalDate start = fromDate.toLocalDate();
        java.time.LocalDate end   = toDate.toLocalDate();

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (java.time.LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
                java.sql.Date sqlDate = java.sql.Date.valueOf(date);
                int i = 1;
                for (String c : userCols) {
                    ps.setString(i++, ("email".equals(c) || "user_email".equals(c)) ? sessionValue : usernameVal);
                }
                ps.setDate(i, sqlDate);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public boolean isOnLeaveToday(String sessionValue) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT status FROM attendance WHERE " + col + " = ? AND punch_date = CURDATE()";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return "On Leave".equalsIgnoreCase(rs.getString("status"));
        }
        return false;
    }

    public List<TeamAttendance> getAllAttendanceForMonth() throws Exception {
        LocalDate now = LocalDate.now();
        return getAllAttendanceForDateRange(now.withDayOfMonth(1), now.withDayOfMonth(now.lengthOfMonth()));
    }

    /** All non-admin employees' attendance between {@code start} and {@code end} (inclusive). */
    public List<TeamAttendance> getAllAttendanceForDateRange(LocalDate start, LocalDate end) throws Exception {
        List<TeamAttendance> list = new ArrayList<>();
        String aCol   = getAttendanceUserColumn();
        String joinOn = "username".equals(aCol) ? "a.username = u.username" : "a." + aCol + " = u.email";
        String sql = "SELECT u.email, "
                + "TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "a.punch_date, a.punch_in, a.punch_out, a.status "
                + "FROM users u "
                + "LEFT JOIN attendance a ON " + joinOn
                + " AND a.punch_date BETWEEN ? AND ? "
                + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                + "ORDER BY fullname, a.punch_date";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TeamAttendance ta = new TeamAttendance();
                ta.setUsername(rs.getString("email"));
                ta.setFullName(rs.getString("fullname"));
                ta.setAttendanceDate(rs.getDate("punch_date"));
                ta.setPunchIn(rs.getTimestamp("punch_in"));
                ta.setPunchOut(rs.getTimestamp("punch_out"));
                try { ta.setStatus(rs.getString("status")); } catch (Exception ignored) {}
                list.add(ta);
            }
        }
        return list;
    }
}