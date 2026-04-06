package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.smartoffice.utils.DBConnectionUtil;

public class AdminDAO {

    // ─── Staff Counts ─────────────────────────────────────────────────────────

    public int getManagerCount() throws Exception {
        return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) = 'manager'");
    }

    public int getEmployeeCount() throws Exception {
        return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('user','employee')");
    }

    public int getPresentTodayCount() throws Exception {
        return getCount(
            "SELECT COUNT(DISTINCT user_email) FROM attendance " +
            "WHERE punch_date = CURDATE() AND punch_in IS NOT NULL"
        );
    }

    public int getAbsentTodayCount() throws Exception {
        int total   = getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('manager','user','employee')");
        int present = getPresentTodayCount();
        return Math.max(0, total - present);
    }

    // ─── Insight Metrics ──────────────────────────────────────────────────────

    public int getAttendanceRate() throws Exception {
        String sql =
            "SELECT IFNULL(ROUND(" +
            "  COUNT(*) * 100.0 / " +
            "  ((SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('manager','user','employee'))" +
            "   * GREATEST(COUNT(DISTINCT punch_date), 1)" +
            "  ), 0), 0) AS rate " +
            "FROM attendance " +
            "WHERE YEAR(punch_date)  = YEAR(CURDATE()) " +
            "  AND MONTH(punch_date) = MONTH(CURDATE()) " +
            "  AND punch_in IS NOT NULL";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? Math.min(rs.getInt("rate"), 100) : 0;
        }
    }

    public int getTasksCompletedThisMonth() throws Exception {
        // Use COALESCE because submitted_at can be NULL for some completed tasks
        return getCount(
            "SELECT COUNT(*) FROM tasks " +
            "WHERE UPPER(TRIM(status)) = 'COMPLETED' " +
            "  AND YEAR(COALESCE(submitted_at, assigned_date))  = YEAR(CURDATE()) " +
            "  AND MONTH(COALESCE(submitted_at, assigned_date)) = MONTH(CURDATE())"
        );
    }

    public int getLeavesPending() throws Exception {
        return getCount("SELECT COUNT(*) FROM leave_requests WHERE UPPER(TRIM(status)) = 'PENDING'");
    }

    public int getActiveTeams() throws Exception {
        return getCount("SELECT COUNT(*) FROM teams");
    }

    // ─── Weekly Attendance ────────────────────────────────────────────────────

    public String getWeekPresent() throws Exception {
        return buildWeekSeries("present");
    }

    public String getWeekAbsent() throws Exception {
        return buildWeekSeries("absent");
    }

    private String buildWeekSeries(String type) throws Exception {
        String sql =
            "SELECT d.day_date, " +
            "       COALESCE(a.present_count, 0) AS present_count, " +
            "       (SELECT COUNT(*) FROM users " +
            "        WHERE LOWER(TRIM(role)) IN ('manager','user','employee')) " +
            "       - COALESCE(a.present_count, 0) AS absent_count " +
            "FROM (" +
            "  SELECT CURDATE() - INTERVAL (6 - seq) DAY AS day_date " +
            "  FROM (SELECT 0 seq UNION SELECT 1 UNION SELECT 2 UNION " +
            "               SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) n" +
            ") d " +
            "LEFT JOIN (" +
            "  SELECT punch_date, COUNT(DISTINCT user_email) AS present_count " +
            "  FROM attendance " +
            "  WHERE punch_date >= CURDATE() - INTERVAL 6 DAY " +
            "    AND punch_in IS NOT NULL " +
            "  GROUP BY punch_date" +
            ") a ON d.day_date = a.punch_date " +
            "ORDER BY d.day_date";

        StringBuilder sb = new StringBuilder();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(rs.getInt(type.equals("present") ? "present_count" : "absent_count"));
                first = false;
            }
        }
        return sb.length() > 0 ? sb.toString() : "0,0,0,0,0,0,0";
    }

    // ─── 30-Day Attendance Trend ──────────────────────────────────────────────

    public String getAttendanceTrend() throws Exception {
        String sql =
            "SELECT d.day_date, " +
            "       COALESCE(ROUND(a.present_count * 100.0 / " +
            "         GREATEST((SELECT COUNT(*) FROM users " +
            "          WHERE LOWER(TRIM(role)) IN ('manager','user','employee')), 1), 0), 0) AS pct " +
            "FROM (" +
            "  SELECT CURDATE() - INTERVAL (29 - seq) DAY AS day_date " +
            "  FROM (SELECT 0 seq  UNION SELECT 1  UNION SELECT 2  UNION SELECT 3  UNION " +
            "               SELECT 4  UNION SELECT 5  UNION SELECT 6  UNION SELECT 7  UNION " +
            "               SELECT 8  UNION SELECT 9  UNION SELECT 10 UNION SELECT 11 UNION " +
            "               SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION " +
            "               SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION " +
            "               SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION " +
            "               SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION " +
            "               SELECT 28 UNION SELECT 29) n" +
            ") d " +
            "LEFT JOIN (" +
            "  SELECT punch_date, COUNT(DISTINCT user_email) AS present_count " +
            "  FROM attendance " +
            "  WHERE punch_date >= CURDATE() - INTERVAL 29 DAY " +
            "    AND punch_in IS NOT NULL " +
            "  GROUP BY punch_date" +
            ") a ON d.day_date = a.punch_date " +
            "ORDER BY d.day_date";

        StringBuilder sb = new StringBuilder();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(Math.min(rs.getInt("pct"), 100));
                first = false;
            }
        }
        return sb.length() > 0 ? sb.toString()
            : "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
    }

    // ─── Task Status Distribution ─────────────────────────────────────────────

    public String getTaskStatusDistribution() throws Exception {
        // PROCESSING is grouped with Needs Review (same concept in manager view)
        String sql =
            "SELECT " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) = 'COMPLETED' THEN 1 ELSE 0 END) AS completed, " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) = 'ASSIGNED'  THEN 1 ELSE 0 END) AS assigned, " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) IN " +
            "      ('AWAITING REVIEW','NEEDS REVIEW','REVIEW','PROCESSING') " +
            "      THEN 1 ELSE 0 END) AS review, " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) IN " +
            "      ('DOCUMENT_VERIFICATION','DOCUMENT VERIFICATION') " +
            "      THEN 1 ELSE 0 END) AS docverify, " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) IN " +
            "      ('ERRORS_RAISED','ERRORS RAISED') " +
            "      THEN 1 ELSE 0 END) AS errors " +
            "FROM tasks";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("completed") + "|" +
                       rs.getInt("assigned")  + "|" +
                       rs.getInt("review")    + "|" +
                       rs.getInt("docverify") + "|" +
                       rs.getInt("errors");
            }
        }
        return "0|0|0|0|0";
    }

    // ─── Task Completion by Week (current month) ──────────────────────────────

    public String getTaskCompletionByWeek() throws Exception {
        // COALESCE: use submitted_at if present, else fall back to assigned_date
        String sql =
            "SELECT " +
            "  SUM(CASE WHEN DAY(COALESCE(submitted_at, assigned_date)) BETWEEN 1  AND 7  THEN 1 ELSE 0 END) AS w1, " +
            "  SUM(CASE WHEN DAY(COALESCE(submitted_at, assigned_date)) BETWEEN 8  AND 14 THEN 1 ELSE 0 END) AS w2, " +
            "  SUM(CASE WHEN DAY(COALESCE(submitted_at, assigned_date)) BETWEEN 15 AND 21 THEN 1 ELSE 0 END) AS w3, " +
            "  SUM(CASE WHEN DAY(COALESCE(submitted_at, assigned_date)) BETWEEN 22 AND 31 THEN 1 ELSE 0 END) AS w4 " +
            "FROM tasks " +
            "WHERE UPPER(TRIM(status)) = 'COMPLETED' " +
            "  AND YEAR(COALESCE(submitted_at, assigned_date))  = YEAR(CURDATE()) " +
            "  AND MONTH(COALESCE(submitted_at, assigned_date)) = MONTH(CURDATE())";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("w1") + "," + rs.getInt("w2") + "," +
                       rs.getInt("w3") + "," + rs.getInt("w4");
            }
        }
        return "0,0,0,0";
    }

    // ─── Leave Types ──────────────────────────────────────────────────────────

    public int getLeaveCountByType(String type) throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT COUNT(*) FROM leave_requests WHERE LOWER(TRIM(leave_type)) = LOWER(?)")) {
            ps.setString(1, type.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─── Break Analytics (avg min per person per day, last 7 days) ───────────

    public String getBreakAnalytics() throws Exception {
        // Sum total valid break seconds per day / distinct users that day = avg per person
        // Exclude micro-breaks < 10s and runaway breaks > 2 hours
        String sql =
            "SELECT d.day_date, " +
            "       COALESCE(ROUND(" +
            "         SUM(b.duration_seconds) / 60.0 / GREATEST(COUNT(DISTINCT b.username), 1)" +
            "       , 1), 0) AS avg_min " +
            "FROM (" +
            "  SELECT CURDATE() - INTERVAL (6 - seq) DAY AS day_date " +
            "  FROM (SELECT 0 seq UNION SELECT 1 UNION SELECT 2 UNION " +
            "               SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) n" +
            ") d " +
            "LEFT JOIN break_logs b " +
            "  ON b.break_date = d.day_date " +
            "  AND b.duration_seconds IS NOT NULL " +
            "  AND b.duration_seconds >= 10 " +
            "  AND b.duration_seconds <= 7200 " +
            "GROUP BY d.day_date " +
            "ORDER BY d.day_date";

        StringBuilder sb = new StringBuilder();
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(rs.getDouble("avg_min"));
                first = false;
            }
        }
        return sb.length() > 0 ? sb.toString() : "0,0,0,0,0,0,0";
    }

    // ─── Punch-In Distribution ────────────────────────────────────────────────

    public String getPunchInDistribution() throws Exception {
        int[] buckets = new int[5]; // <8, 8-9, 9-10, 10-11, >11
        String sql =
            "SELECT HOUR(punch_in) AS hr, COUNT(*) AS cnt " +
            "FROM attendance " +
            "WHERE punch_date >= CURDATE() - INTERVAL 6 DAY " +
            "  AND punch_in IS NOT NULL " +
            "GROUP BY HOUR(punch_in)";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int hr  = rs.getInt("hr");
                int cnt = rs.getInt("cnt");
                if      (hr < 8)   buckets[0] += cnt;
                else if (hr == 8)  buckets[1] += cnt;
                else if (hr == 9)  buckets[2] += cnt;
                else if (hr == 10) buckets[3] += cnt;
                else               buckets[4] += cnt;
            }
        }
        return buckets[0]+","+buckets[1]+","+buckets[2]+","+buckets[3]+","+buckets[4];
    }

    // ─── Upcoming Holidays ────────────────────────────────────────────────────

    public List<String> getUpcomingHolidays() throws Exception {
        List<String> list = new ArrayList<>();
        String sql =
            "SELECT holiday_name, holiday_date FROM holidays " +
            "WHERE holiday_date >= CURDATE() " +
            "ORDER BY holiday_date LIMIT 5";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(rs.getString("holiday_name") + " — " + rs.getString("holiday_date"));
        }
        return list;
    }

    // ─── NEW: Avg Work Hours Today ────────────────────────────────────────────

    public String getAvgWorkHoursToday() throws Exception {
        String sql =
            "SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, punch_in, " +
            "  IFNULL(punch_out, NOW()))) / 60.0, 1) AS avg_hrs " +
            "FROM attendance " +
            "WHERE punch_date = CURDATE() AND punch_in IS NOT NULL";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                double v = rs.getDouble("avg_hrs");
                return rs.wasNull() ? "0.0" : String.valueOf(v);
            }
        }
        return "0.0";
    }

    // ─── NEW: Late Arrivals This Week ─────────────────────────────────────────

    public int getLateArrivalsThisWeek() throws Exception {
        return getCount(
            "SELECT COUNT(*) FROM attendance " +
            "WHERE punch_date >= CURDATE() - INTERVAL 6 DAY " +
            "  AND punch_in IS NOT NULL " +
            "  AND TIME(punch_in) > '09:30:00'"
        );
    }

    // ─── NEW: Leave Approval Rate ─────────────────────────────────────────────

    public String getLeaveApprovalRate() throws Exception {
        String sql =
            "SELECT COUNT(*) AS total, " +
            "  SUM(CASE WHEN UPPER(TRIM(status)) = 'APPROVED' THEN 1 ELSE 0 END) AS approved " +
            "FROM leave_requests";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int total    = rs.getInt("total");
                int approved = rs.getInt("approved");
                if (total == 0) return "0";
                return String.valueOf(Math.round(approved * 100.0 / total));
            }
        }
        return "0";
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    private int getCount(String sql) throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}