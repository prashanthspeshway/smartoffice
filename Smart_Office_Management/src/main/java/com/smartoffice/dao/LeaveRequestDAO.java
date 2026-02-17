package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.LeaveRequest;
import com.smartoffice.utils.DBConnectionUtil;

public class LeaveRequestDAO {

    public List<LeaveRequest> getTeamLeaveRequests(String managerUsername) throws Exception {

        List<LeaveRequest> list = new ArrayList<>();

        String sql = """
            SELECT lr.*
            FROM leave_requests lr
            JOIN users u ON lr.username = u.username
            WHERE u.manager = ?
            ORDER BY lr.applied_at DESC
        """;

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, managerUsername);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                LeaveRequest lr = new LeaveRequest();
                lr.setId(rs.getInt("id"));
                lr.setUsername(rs.getString("username"));
                lr.setLeaveType(rs.getString("leave_type"));
                lr.setFromDate(rs.getDate("from_date"));
                lr.setToDate(rs.getDate("to_date"));
                lr.setReason(rs.getString("reason"));
                lr.setStatus(rs.getString("status"));
                lr.setAppliedAt(rs.getTimestamp("applied_at"));
                list.add(lr);
            }
        }
        return list;
    }

    public void updateLeaveStatus(int leaveId, String status) throws Exception {

        String sql = "UPDATE leave_requests SET status = ? WHERE id = ?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, leaveId);
            ps.executeUpdate();
        }
    }
    
    public List<LeaveRequest> getLeavesByUsername(String username) throws Exception {

        List<LeaveRequest> list = new ArrayList<>();

        String sql = """
            SELECT *
            FROM leave_requests
            WHERE username = ?
            ORDER BY applied_at DESC
        """;

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                LeaveRequest lr = new LeaveRequest();
                lr.setId(rs.getInt("id"));
                lr.setLeaveType(rs.getString("leave_type"));
                lr.setFromDate(rs.getDate("from_date"));
                lr.setToDate(rs.getDate("to_date"));
                lr.setReason(rs.getString("reason"));
                lr.setStatus(rs.getString("status"));
                lr.setAppliedAt(rs.getTimestamp("applied_at"));
                list.add(lr);
            }
        }
        return list;
    }

}
