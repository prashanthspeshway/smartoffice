package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
    // Fetch all APPROVED leave dates for a user.
    // ─────────────────────────────────────────────────────────────────────────
    private List<LocalDate> getApprovedLeaveDates(String sessionValue) throws Exception {
        String usernameVal = getUsernameFromEmail(sessionValue);
        String sql = "SELECT from_date, to_date FROM leave_requests "
                + "WHERE username IN (?, ?) AND UPPER(status) = 'APPROVED'";
        List<LocalDate> leaveDates = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sessionValue);
            ps.setString(2, usernameVal);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LocalDate from = rs.getDate("from_date").toLocalDate();
                LocalDate to   = rs.getDate("to_date").toLocalDate();
                for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                    leaveDates.add(d);
                }
            }
        }
        return leaveDates;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Check if a given date is a holiday in the DB.
    // ─────────────────────────────────────────────────────────────────────────
    private boolean isHolidayDate(LocalDate d) throws Exception {
        String sql = "SELECT COUNT(*) FROM holidays WHERE holiday_date = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(d));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Fill missing "On Leave" entries into an attendance log list.
    // ─────────────────────────────────────────────────────────────────────────
    private void fillMissingLeaveDates(List<AttendanceLogEntry> list,
                                        String sessionValue) throws Exception {
        Set<LocalDate> existing = new HashSet<>();
        for (AttendanceLogEntry e : list) {
            if (e.getAttendanceDate() != null)
                existing.add(e.getAttendanceDate().toLocalDate());
        }
        for (LocalDate leaveDate : getApprovedLeaveDates(sessionValue)) {
            if (!existing.contains(leaveDate)) {
                AttendanceLogEntry e = new AttendanceLogEntry();
                e.setAttendanceDate(java.sql.Date.valueOf(leaveDate));
                e.setPunchIn(null);
                e.setPunchOut(null);
                e.setStatus("On Leave");
                list.add(e);
                existing.add(leaveDate);
            }
        }
        sortDescending(list);
    }

    // Same as above but restricted to [rangeStart, rangeEnd].
    private void fillMissingLeaveDatesInRange(List<AttendanceLogEntry> list,
                                               String sessionValue,
                                               LocalDate rangeStart,
                                               LocalDate rangeEnd) throws Exception {
        Set<LocalDate> existing = new HashSet<>();
        for (AttendanceLogEntry e : list) {
            if (e.getAttendanceDate() != null)
                existing.add(e.getAttendanceDate().toLocalDate());
        }
        for (LocalDate leaveDate : getApprovedLeaveDates(sessionValue)) {
            if (!leaveDate.isBefore(rangeStart) && !leaveDate.isAfter(rangeEnd)
                    && !existing.contains(leaveDate)) {
                AttendanceLogEntry e = new AttendanceLogEntry();
                e.setAttendanceDate(java.sql.Date.valueOf(leaveDate));
                e.setPunchIn(null);
                e.setPunchOut(null);
                e.setStatus("On Leave");
                list.add(e);
                existing.add(leaveDate);
            }
        }
        sortDescending(list);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Fill missing "Absent" entries for working days that have no DB row.
    // Skips: weekends, holidays, approved leave dates, and today/future.
    // Looks back 60 days by default.
    // ─────────────────────────────────────────────────────────────────────────
    private void fillMissingAbsentDays(List<AttendanceLogEntry> list,
                                        String sessionValue) throws Exception {
        Set<LocalDate> existing = new HashSet<>();
        for (AttendanceLogEntry e : list) {
            if (e.getAttendanceDate() != null)
                existing.add(e.getAttendanceDate().toLocalDate());
        }

        Set<LocalDate> leaveSet = new HashSet<>(getApprovedLeaveDates(sessionValue));

        LocalDate today  = LocalDate.now();
        LocalDate cutoff = today.minusDays(60);

        for (LocalDate d = today.minusDays(1); !d.isBefore(cutoff); d = d.minusDays(1)) {
            if (existing.contains(d)) continue;
            if (leaveSet.contains(d)) continue;

            // Skip weekends
            java.time.DayOfWeek dow = d.getDayOfWeek();
            if (dow == java.time.DayOfWeek.SATURDAY || dow == java.time.DayOfWeek.SUNDAY) continue;

            // Skip holidays
            if (isHolidayDate(d)) continue;

            // It's a working day with no record — mark Absent
            AttendanceLogEntry e = new AttendanceLogEntry();
            e.setAttendanceDate(java.sql.Date.valueOf(d));
            e.setPunchIn(null);
            e.setPunchOut(null);
            e.setStatus("Absent");
            list.add(e);
            existing.add(d);
        }
        sortDescending(list);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Same as fillMissingAbsentDays but restricted to [rangeStart, rangeEnd].
    // ─────────────────────────────────────────────────────────────────────────
    private void fillMissingAbsentDaysInRange(List<AttendanceLogEntry> list,
                                               String sessionValue,
                                               LocalDate rangeStart,
                                               LocalDate rangeEnd) throws Exception {
        Set<LocalDate> existing = new HashSet<>();
        for (AttendanceLogEntry e : list) {
            if (e.getAttendanceDate() != null)
                existing.add(e.getAttendanceDate().toLocalDate());
        }

        Set<LocalDate> leaveSet = new HashSet<>(getApprovedLeaveDates(sessionValue));
        LocalDate today = LocalDate.now();

        for (LocalDate d = rangeStart; !d.isAfter(rangeEnd); d = d.plusDays(1)) {
            // Don't mark today or future as absent
            if (!d.isBefore(today)) continue;
            if (existing.contains(d)) continue;
            if (leaveSet.contains(d)) continue;

            java.time.DayOfWeek dow = d.getDayOfWeek();
            if (dow == java.time.DayOfWeek.SATURDAY || dow == java.time.DayOfWeek.SUNDAY) continue;

            if (isHolidayDate(d)) continue;

            AttendanceLogEntry e = new AttendanceLogEntry();
            e.setAttendanceDate(java.sql.Date.valueOf(d));
            e.setPunchIn(null);
            e.setPunchOut(null);
            e.setStatus("Absent");
            list.add(e);
            existing.add(d);
        }
        sortDescending(list);
    }

    private void sortDescending(List<AttendanceLogEntry> list) {
        list.sort((a, b) -> {
            if (a.getAttendanceDate() == null && b.getAttendanceDate() == null) return 0;
            if (a.getAttendanceDate() == null) return 1;
            if (b.getAttendanceDate() == null) return -1;
            return b.getAttendanceDate().compareTo(a.getAttendanceDate());
        });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Check if the user has an APPROVED leave covering a specific date.
    // ─────────────────────────────────────────────────────────────────────────
    public boolean isOnApprovedLeaveOn(String sessionValue, Date date) throws Exception {
        String usernameVal = getUsernameFromEmail(sessionValue);
        String sql = "SELECT COUNT(*) FROM leave_requests "
                + "WHERE username IN (?, ?) "
                + "  AND UPPER(status) = 'APPROVED' "
                + "  AND ? BETWEEN from_date AND to_date";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sessionValue);
            ps.setString(2, usernameVal);
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
                return "Today is a Holiday"
                        + (name != null && !name.isEmpty() ? " (" + name + ")" : "")
                        + ". Attendance is not available.";
            }
        }
        if (isOnApprovedLeaveOn(sessionValue, date)) {
            return "You are on Approved Leave today. Attendance is not available.";
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Punch In
    // ─────────────────────────────────────────────────────────────────────────
    public void punchIn(String sessionValue) throws Exception {
        Date today = new Date(System.currentTimeMillis());
        String blockReason = getBlockReason(sessionValue, today);
        if (blockReason != null) throw new Exception(blockReason);

        List<String> userCols = new ArrayList<>();
        if (hasAttendanceColumn("username"))   userCols.add("username");
        if (hasAttendanceColumn("user_email")) userCols.add("user_email");
        if (hasAttendanceColumn("email"))      userCols.add("email");
        if (userCols.isEmpty())                userCols.add("username");

        String cols         = String.join(", ", userCols);
        String placeholders = String.join(", ", java.util.Collections.nCopies(userCols.size(), "?"));
        String sql = "INSERT INTO attendance (" + cols + ", punch_in, punch_date, status) VALUES ("
                + placeholders + ", NOW(), CURDATE(), 'In Progress') "
                + "ON DUPLICATE KEY UPDATE "
                + "punch_in = IF(punch_in IS NULL, NOW(), punch_in), "
                + "status   = IF(punch_in IS NULL, 'In Progress', status)";

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

    // ─────────────────────────────────────────────────────────────────────────
    // Punch Out
    // ─────────────────────────────────────────────────────────────────────────
    public void punchOut(String sessionValue) throws Exception {
        Date today = new Date(System.currentTimeMillis());
        String blockReason = getBlockReason(sessionValue, today);
        if (blockReason != null) throw new Exception(blockReason);

        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        java.sql.Timestamp punchOutTime = new java.sql.Timestamp(System.currentTimeMillis());

        try {
            boolean wasOnBreak = BreakDAO.isCurrentlyOnBreak(sessionValue);
            if (wasOnBreak) BreakDAO.autoEndBreakAtTime(sessionValue, punchOutTime);
        } catch (Exception e) {
            System.err.println("[AttendanceDAO] Warning: Could not auto-end break: " + e.getMessage());
        }

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

    // ─────────────────────────────────────────────────────────────────────────
    // END-OF-DAY SCHEDULED JOB
    // ─────────────────────────────────────────────────────────────────────────
    public void runEndOfDayJob() throws Exception {
        autoCloseMissedPunchOuts();
        markYesterdayApprovedLeaves();
        markDailyAbsentees();
        recalculatePreviousDayStatuses();
    }

    public void markYesterdayApprovedLeaves() throws Exception {
        String aCol    = getAttendanceUserColumn();
        String userCol = "username".equals(aCol) ? "username" : "email";

        String sql = "INSERT INTO attendance (" + aCol + ", punch_date, status) "
                + "SELECT u." + userCol + ", CURDATE() - INTERVAL 1 DAY, 'On Leave' "
                + "FROM users u "
                + "JOIN leave_requests lr "
                + "  ON lr.username IN (u.username, u.email) "
                + " AND UPPER(lr.status) = 'APPROVED' "
                + " AND (CURDATE() - INTERVAL 1 DAY) BETWEEN lr.from_date AND lr.to_date "
                + "LEFT JOIN attendance a "
                + "  ON a." + aCol + " = u." + userCol
                + " AND a.punch_date = CURDATE() - INTERVAL 1 DAY "
                + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                + "  AND a.id IS NULL "
                + "ON DUPLICATE KEY UPDATE status = 'On Leave', punch_in = NULL, punch_out = NULL";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            System.out.println("[AttendanceDAO] markYesterdayApprovedLeaves: " + rows + " row(s) written.");
        }
    }

    public void markDailyAbsentees() throws Exception {
        java.time.LocalDate yesterday = java.time.LocalDate.now().minusDays(1);
        java.time.DayOfWeek dow = yesterday.getDayOfWeek();
        if (dow == java.time.DayOfWeek.SATURDAY || dow == java.time.DayOfWeek.SUNDAY) {
            System.out.println("[AttendanceDAO] markDailyAbsentees: skipped (weekend).");
            return;
        }
        String holidayCheck = "SELECT COUNT(*) FROM holidays WHERE holiday_date = CURDATE() - INTERVAL 1 DAY";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(holidayCheck)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("[AttendanceDAO] markDailyAbsentees: skipped (holiday).");
                return;
            }
        }

        String aCol    = getAttendanceUserColumn();
        String userCol = "username".equals(aCol) ? "username" : "email";

        String sql = "INSERT INTO attendance (" + aCol + ", punch_date, status) "
                + "SELECT u." + userCol + ", CURDATE() - INTERVAL 1 DAY, 'Absent' "
                + "FROM users u "
                + "LEFT JOIN attendance a "
                + "  ON a." + aCol + " = u." + userCol
                + " AND a.punch_date = CURDATE() - INTERVAL 1 DAY "
                + "LEFT JOIN leave_requests lr "
                + "  ON lr.username IN (u.username, u.email) "
                + " AND UPPER(lr.status) = 'APPROVED' "
                + " AND (CURDATE() - INTERVAL 1 DAY) BETWEEN lr.from_date AND lr.to_date "
                + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                + "  AND a.id IS NULL "
                + "  AND lr.id IS NULL "
                + "ON DUPLICATE KEY UPDATE "
                + "  status = IF(status IS NULL OR status = '', 'Absent', status)";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            System.out.println("[AttendanceDAO] markDailyAbsentees: " + rows + " absent row(s) inserted.");
        }
    }

    public void recalculatePreviousDayStatuses() throws Exception {
        String sql = "UPDATE attendance SET status = CASE "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NOT NULL "
                + "     AND TIMESTAMPDIFF(HOUR, punch_in, punch_out) >= 4 THEN 'Present' "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NOT NULL "
                + "     AND TIMESTAMPDIFF(HOUR, punch_in, punch_out) < 4  THEN 'Half Day' "
                + "WHEN punch_in IS NOT NULL AND punch_out IS NULL          THEN 'In Progress' "
                + "ELSE status END "
                + "WHERE punch_date = CURDATE() - INTERVAL 1 DAY "
                + "  AND status NOT IN ('On Leave', 'Absent')";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
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
                if ("On Leave".equalsIgnoreCase(dbSt))      ta.setStatus("On Leave");
                else if (ta.getPunchIn() == null)           ta.setStatus("Absent");
                else if (ta.getPunchOut() == null)          ta.setStatus("In Progress");
                else if ("Half Day".equalsIgnoreCase(dbSt)) ta.setStatus("Half Day");
                else                                        ta.setStatus("Present");
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

    public List<TeamAttendance> getTeamAttendanceForDateRange(
            String managerUsername, LocalDate start, LocalDate end) throws Exception {
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

    // ─────────────────────────────────────────────────────────────────────────
    // Admin today's dashboard
    // ─────────────────────────────────────────────────────────────────────────
    public List<AdminAttendanceRow> getAllAttendanceForToday() throws Exception {
        List<AdminAttendanceRow> list = new ArrayList<>();
        String aCol    = getAttendanceUserColumn();
        String userCol = "username".equals(aCol) ? "username" : "email";

        String sql = "SELECT u.id, u.email, "
                + "TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "COALESCE(u.designation,'') AS designation, "
                + "a.punch_in, a.punch_out, a.status "
                + "FROM users u "
                + "LEFT JOIN attendance a "
                + "       ON a.punch_date = CURDATE() AND a." + aCol + " = u." + userCol + " "
                + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                + "ORDER BY fullname";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(buildAdminRow(rs, true));
            }
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("designation")) {
                list.clear();
                String sqlNoDesig = "SELECT u.id, u.email, "
                        + "TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                        + "a.punch_in, a.punch_out, a.status "
                        + "FROM users u "
                        + "LEFT JOIN attendance a "
                        + "       ON a.punch_date = CURDATE() AND a." + aCol + " = u." + userCol + " "
                        + "WHERE LOWER(TRIM(COALESCE(u.role,''))) != 'admin' "
                        + "ORDER BY fullname";
                try (Connection con = DBConnectionUtil.getConnection();
                     PreparedStatement ps = con.prepareStatement(sqlNoDesig)) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        list.add(buildAdminRow(rs, false));
                    }
                }
            } else {
                throw e;
            }
        }
        return list;
    }

    private AdminAttendanceRow buildAdminRow(ResultSet rs, boolean hasDesignation) throws Exception {
        AdminAttendanceRow row = new AdminAttendanceRow();
        row.setEmployeeId(rs.getInt("id"));
        row.setEmail(rs.getString("email"));
        row.setFullName(rs.getString("fullname"));
        row.setDesignation(hasDesignation ? rs.getString("designation") : "");
        row.setPunchIn(rs.getTimestamp("punch_in"));
        row.setPunchOut(rs.getTimestamp("punch_out"));
        row.setBreakDurationFormatted("--");
        String dbSt = rs.getString("status");
        row.setAttendanceStatus(dbSt);
        if ("On Leave".equalsIgnoreCase(dbSt)) {
            row.setLiveStatus("ON LEAVE");
        } else if (row.getPunchIn() == null) {
            row.setLiveStatus("ABSENT");
        } else if (row.getPunchOut() == null) {
            row.setLiveStatus("IN PROGRESS");
        } else {
            row.setLiveStatus("PUNCHED OUT");
        }
        return row;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Activity log — fills in missing "On Leave" AND "Absent" dates.
    // ─────────────────────────────────────────────────────────────────────────
    public List<AttendanceLogEntry> getRecentAttendance(String sessionValue, int limit) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance WHERE "
                + col + "=? ORDER BY punch_date DESC";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(buildLogEntry(rs));
        }
        fillMissingLeaveDates(list, sessionValue);
        fillMissingAbsentDays(list, sessionValue);   // ← fills missing Absent days
        int maxRows = limit <= 0 ? 14 : limit;
        return list.size() > maxRows ? list.subList(0, maxRows) : list;
    }

    public List<AttendanceLogEntry> getAttendanceLogByRange(
            String sessionValue, String fromDate, String toDate) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance "
                + "WHERE " + col + " = ? AND punch_date BETWEEN ? AND ? "
                + "ORDER BY punch_date DESC";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(buildLogEntry(rs));
        }
        fillMissingLeaveDatesInRange(list, sessionValue,
                LocalDate.parse(fromDate), LocalDate.parse(toDate));
        fillMissingAbsentDaysInRange(list, sessionValue,   // ← fills missing Absent days in range
                LocalDate.parse(fromDate), LocalDate.parse(toDate));
        return list;
    }

    public List<AttendanceLogEntry> getFullAttendanceLog(String sessionValue) throws Exception {
        String id  = resolveForAttendance(sessionValue);
        String col = getAttendanceUserColumn();
        String sql = "SELECT punch_date, punch_in, punch_out, status FROM attendance "
                + "WHERE " + col + " = ? ORDER BY punch_date DESC";
        List<AttendanceLogEntry> list = new ArrayList<>();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(buildLogEntry(rs));
        }
        fillMissingLeaveDates(list, sessionValue);
        fillMissingAbsentDays(list, sessionValue);   // ← fills missing Absent days
        return list;
    }

    private AttendanceLogEntry buildLogEntry(ResultSet rs) throws Exception {
        AttendanceLogEntry e = new AttendanceLogEntry();
        e.setAttendanceDate(rs.getDate("punch_date"));
        e.setPunchIn(rs.getTimestamp("punch_in"));
        e.setPunchOut(rs.getTimestamp("punch_out"));
        e.setStatus(mapStatus(e.getPunchIn(), e.getPunchOut(),
                rs.getString("status"), rs.getDate("punch_date")));
        return e;
    }

    private String mapStatus(java.sql.Timestamp punchIn, java.sql.Timestamp punchOut,
            String dbStatus, java.sql.Date attendanceDate) {
        if ("On Leave".equalsIgnoreCase(dbStatus))  return "On Leave";
        if ("Half Day".equalsIgnoreCase(dbStatus))  return "Half Day";
        if (punchIn != null && punchOut != null)    return "Present";
        if (punchIn != null)                        return "In Progress";
        if (attendanceDate != null) {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(attendanceDate);
            int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
            if (dow == java.util.Calendar.SATURDAY
                    || dow == java.util.Calendar.SUNDAY) return "Weekend";
        }
        return "Absent";
    }

    public void autoCloseMissedPunchOuts() throws Exception {
        String closeSql = "UPDATE attendance "
                + "SET punch_out = TIMESTAMP(punch_date, '19:30:00'), "
                + "    status    = CASE "
                + "        WHEN TIMESTAMPDIFF(HOUR, punch_in, TIMESTAMP(punch_date, '19:30:00')) >= 4 THEN 'Present' "
                + "        ELSE 'Half Day' END "
                + "WHERE punch_in  IS NOT NULL "
                + "  AND punch_out IS NULL "
                + "  AND punch_date < CURDATE() "
                + "  AND status NOT IN ('On Leave', 'Absent')";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(closeSql)) {
            ps.executeUpdate();
        }
    }

    public void markLeaveInAttendance(String sessionValue,
            java.sql.Date fromDate, java.sql.Date toDate) throws Exception {
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
                    ps.setString(i++, ("email".equals(c) || "user_email".equals(c))
                            ? sessionValue : usernameVal);
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
        return isOnApprovedLeaveOn(sessionValue, new java.sql.Date(System.currentTimeMillis()));
    }

    public List<TeamAttendance> getAllAttendanceForMonth() throws Exception {
        LocalDate now = LocalDate.now();
        return getAllAttendanceForDateRange(
                now.withDayOfMonth(1), now.withDayOfMonth(now.lengthOfMonth()));
    }

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

    public List<TeamAttendance> getAttendanceForEmployeeAndDateRange(
            int employeeId, LocalDate start, LocalDate end) throws Exception {
        List<TeamAttendance> list = new ArrayList<>();
        String aCol   = getAttendanceUserColumn();
        String joinOn = "username".equals(aCol)
                ? "a.username = u.username"
                : "a." + aCol + " = u.email";
        String sql = "SELECT u.email, "
                + "TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, "
                + "a.punch_date, a.punch_in, a.punch_out, a.status "
                + "FROM users u "
                + "LEFT JOIN attendance a ON " + joinOn
                + " AND a.punch_date BETWEEN ? AND ? "
                + "WHERE u.id = ? "
                + "ORDER BY a.punch_date";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            ps.setDate(2, Date.valueOf(end));
            ps.setInt(3, employeeId);
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