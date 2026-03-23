package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.BreakLog;
import com.smartoffice.utils.DBConnectionUtil;

public class BreakDAO {

    // ─────────────────────────────────────────────────────────────────────────
    // Resolve the correct identifier to use in break_logs queries.
    // break_logs uses 'username' column — so if we receive an email,
    // we look up the corresponding username from the users table.
    // ─────────────────────────────────────────────────────────────────────────
    private static String resolveUsername(String emailOrUsername) {
        if (emailOrUsername == null || emailOrUsername.trim().isEmpty())
            return emailOrUsername;
        String trimmed = emailOrUsername.trim();
        // If it looks like an email, resolve to username
        if (trimmed.contains("@")) {
            try (Connection con = DBConnectionUtil.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                         "SELECT username FROM users WHERE email = ? LIMIT 1")) {
                ps.setString(1, trimmed);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String u = rs.getString("username");
                        if (u != null && !u.trim().isEmpty()) {
                            return u.trim();
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("[BreakDAO] resolveUsername failed: " + e.getMessage());
            }
        }
        // Already a username — return as-is
        return trimmed;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Start a break for today
    // ─────────────────────────────────────────────────────────────────────────
    public static int startBreak(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "INSERT INTO break_logs (username, break_date, start_time) "
                + "VALUES (?, CURDATE(), NOW())";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // End the most recent open break for today (manual end by user)
    // ─────────────────────────────────────────────────────────────────────────
    public static void endBreak(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "UPDATE break_logs "
                + "SET end_time = NOW(), "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, NOW()) "
                + "WHERE username = ? AND break_date = CURDATE() AND end_time IS NULL "
                + "ORDER BY id DESC LIMIT 1";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            int rows = ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ✅ Auto-end ALL open breaks at the EXACT punch-out timestamp.
    // Called from AttendanceDAO.punchOut() so break end_time == punch_out time.
    // ─────────────────────────────────────────────────────────────────────────
    public static void autoEndBreakAtTime(String emailOrUsername, Timestamp endTime) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "UPDATE break_logs "
                + "SET end_time = ?, "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, ?) "
                + "WHERE username = ? AND break_date = CURDATE() AND end_time IS NULL";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, endTime);
            ps.setTimestamp(2, endTime);
            ps.setString(3, username);
            int rows = ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ✅ Auto-end ALL open breaks using NOW() — used by AppStartupListener
    // ─────────────────────────────────────────────────────────────────────────
    public static void autoEndBreakIfOpen(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "UPDATE break_logs "
                + "SET end_time = NOW(), "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, NOW()) "
                + "WHERE username = ? AND break_date = CURDATE() AND end_time IS NULL";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            int rows = ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Get all breaks for today
    // ─────────────────────────────────────────────────────────────────────────
    public static List<BreakLog> getTodayBreaks(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        List<BreakLog> list = new ArrayList<>();
        String sql = "SELECT id, start_time, end_time, duration_seconds "
                + "FROM break_logs WHERE username = ? AND break_date = CURDATE() "
                + "ORDER BY start_time";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BreakLog b = new BreakLog();
                    b.setId(rs.getInt("id"));
                    b.setStartTime(rs.getTimestamp("start_time"));
                    b.setEndTime(rs.getTimestamp("end_time"));
                    b.setDurationSeconds(rs.getInt("duration_seconds"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Total break seconds for today
    // ─────────────────────────────────────────────────────────────────────────
    public static int getTodayTotalSeconds(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "SELECT COALESCE(SUM(duration_seconds), 0) "
                + "FROM break_logs WHERE username = ? AND break_date = CURDATE()";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // True if user has an open break today (started but not ended)
    // ─────────────────────────────────────────────────────────────────────────
    public static boolean isCurrentlyOnBreak(String emailOrUsername) throws Exception {
        String username = resolveUsername(emailOrUsername);
        String sql = "SELECT 1 FROM break_logs "
                + "WHERE username = ? AND break_date = CURDATE() AND end_time IS NULL LIMIT 1";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                boolean onBreak = rs.next();
                return onBreak;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Total break seconds for a specific date (used in activity log)
    // ─────────────────────────────────────────────────────────────────────────
    public static int getTotalSecondsForDate(String emailOrUsername, Date date) throws Exception {
        if (date == null) return 0;
        String username = resolveUsername(emailOrUsername);
        String sql = "SELECT COALESCE(SUM(duration_seconds), 0) "
                + "FROM break_logs WHERE username = ? AND break_date = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}