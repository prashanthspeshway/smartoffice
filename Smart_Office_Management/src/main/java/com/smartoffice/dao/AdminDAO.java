package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.utils.DBConnectionUtil;

public class AdminDAO {

    public int getManagerCount() throws Exception {
        return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) = 'manager'");
    }

    public int getEmployeeCount() throws Exception {
        return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('user', 'employee')");
    }

    public int getPresentTodayCount() throws Exception {
        String userCol = hasAttendanceUserColumn();
        String sql = "SELECT COUNT(DISTINCT " + userCol + ") FROM attendance " +
            "WHERE punch_date = CURDATE() AND punch_in IS NOT NULL";
        return getCount(sql);
    }

    /** Returns 'email' or 'username' depending on attendance table schema. */
    private String hasAttendanceUserColumn() throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT 1 FROM information_schema.COLUMNS " +
                 "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'attendance' AND COLUMN_NAME = 'email'");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? "email" : "username";
        }
    }

    public int getAbsentTodayCount() throws Exception {
        int total = getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('manager', 'user', 'employee')");
        int present = getPresentTodayCount();
        return total - present;
    }

    private int getCount(String sql) throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    public List<String> getUpcomingHolidays() throws Exception {
        List<String> list = new ArrayList<>();

        String sql = """
            SELECT holiday_name
            FROM holidays
            WHERE holiday_date >= CURDATE()
            ORDER BY holiday_date
            LIMIT 1
        """;

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(rs.getString("holiday_name"));
            }
        }
        return list;
    }
}