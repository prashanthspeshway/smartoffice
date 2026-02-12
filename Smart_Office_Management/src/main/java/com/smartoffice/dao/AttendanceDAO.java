package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.smartoffice.utils.DBConnectionUtil;

public class AttendanceDAO {

    // Check if user has punched in today
    public boolean hasPunchedIn(String username, Date date) throws Exception {
        String sql = "SELECT punch_in FROM attendance WHERE username=? AND punch_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setDate(2, new java.sql.Date(date.getTime()));

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getTimestamp("punch_in") != null;
            }
            return false;
        }
    }

    // Check if user has punched out today
    public boolean hasPunchedOut(String username, Date date) throws Exception {
        String sql = "SELECT punch_out FROM attendance WHERE username=? AND punch_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setDate(2, new java.sql.Date(date.getTime()));

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getTimestamp("punch_out") != null;
            }
            return false;
        }
    }

    // ✅ Check if today is a holiday
    public boolean isHoliday(Date date) throws Exception {
        String sql = "SELECT COUNT(*) FROM holidays WHERE holiday_date=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, new java.sql.Date(date.getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // Punch In with holiday check
    public void punchIn(String username) throws Exception {
        Date today = new Date(System.currentTimeMillis());

        if (isHoliday(today)) {
            throw new Exception("Cannot punch in on a holiday");
        }

        String sql = "INSERT INTO attendance (username, punch_in, punch_date) "
                   + "VALUES (?, NOW(), CURDATE()) "
                   + "ON DUPLICATE KEY UPDATE punch_in = IF(punch_in IS NULL, NOW(), punch_in)";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.executeUpdate();
        }
    }

    // Punch Out with holiday check
    public void punchOut(String username) throws Exception {
        Date today = new Date(System.currentTimeMillis());

        if (isHoliday(today)) {
            throw new Exception("Cannot punch out on a holiday");
        }

        String sql = "UPDATE attendance SET punch_out = NOW() "
                   + "WHERE username=? AND punch_date=CURDATE() AND punch_out IS NULL";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.executeUpdate();
        }
    }

    // Get today's attendance
    public ResultSet getTodayAttendance(String username) throws Exception {
        String sql = "SELECT punch_in, punch_out FROM attendance WHERE username=? AND punch_date=CURDATE()";

        Connection con = DBConnectionUtil.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, username);

        return ps.executeQuery();
    }
}
