package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.LeaveRequest;
import com.smartoffice.utils.DBConnectionUtil;

public class LeaveRequestDAO {

	private String getLeaveUserColumn() throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT 1 FROM information_schema.COLUMNS "
						+ "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='leave_requests' AND COLUMN_NAME='username'");
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				return "username";
		}
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT 1 FROM information_schema.COLUMNS "
						+ "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='leave_requests' AND COLUMN_NAME='email'");
				ResultSet rs = ps.executeQuery()) {
			if (rs.next())
				return "email";
		}
		return "username";
	}

	private String resolveForLeave(String sessionValue) throws Exception {
		String col = getLeaveUserColumn();
		if ("email".equals(col))
			return sessionValue;
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT username FROM users WHERE email = ?")) {
			ps.setString(1, sessionValue);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				return rs.getString("username");
		}
		return sessionValue;
	}

	private LeaveRequest mapRow(ResultSet rs, String lrCol) throws Exception {
		LeaveRequest lr = new LeaveRequest();
		lr.setId(rs.getInt("id"));
		lr.setUsername(rs.getString(lrCol));
		lr.setLeaveType(rs.getString("leave_type"));
		lr.setFromDate(rs.getDate("from_date"));
		lr.setToDate(rs.getDate("to_date"));
		lr.setReason(rs.getString("reason"));
		lr.setStatus(rs.getString("status"));
		lr.setAppliedAt(rs.getTimestamp("applied_at"));
		try {
			lr.setRejectionReason(rs.getString("rejection_reason"));
		} catch (Exception ignored) {
		}
		return lr;
	}

	public LeaveRequest getLeaveById(int leaveId) throws Exception {
		String col = getLeaveUserColumn();
		String sql = "SELECT * FROM leave_requests WHERE id = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, leaveId);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				return mapRow(rs, col);
			}
		}
		return null;
	}

	public void applyLeave(LeaveRequest lr) throws Exception {
		applyLeave(lr.getAppliedBy(), lr.getLeaveType(), lr.getFromDate(), lr.getToDate(), lr.getReason());
	}

	public void applyLeave(String sessionValue, String leaveType, java.sql.Date fromDate, java.sql.Date toDate,
			String reason) throws Exception {
		String col = getLeaveUserColumn();
		String id = resolveForLeave(sessionValue);
		String sql = "INSERT INTO leave_requests (" + col
				+ ", leave_type, from_date, to_date, reason, status) VALUES (?, ?, ?, ?, ?, 'PENDING')";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, id);
			ps.setString(2, leaveType);
			ps.setDate(3, fromDate);
			ps.setDate(4, toDate);
			ps.setString(5, reason);
			ps.executeUpdate();
		}
	}

	public void updateLeaveStatus(int leaveId, String status) throws Exception {
		String sql = "UPDATE leave_requests SET status = ? WHERE id = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, status);
			ps.setInt(2, leaveId);
			ps.executeUpdate();
		}
	}

	public void updateLeaveStatus(int leaveId, String status, String rejectionReason) throws Exception {
		String sql = "UPDATE leave_requests SET status = ?, rejection_reason = ? WHERE id = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, status);
			ps.setString(2,
					(rejectionReason != null && !rejectionReason.trim().isEmpty()) ? rejectionReason.trim() : null);
			ps.setInt(3, leaveId);
			ps.executeUpdate();
		}
	}

	public List<LeaveRequest> getLeavesByUsername(String sessionValue) throws Exception {
		List<LeaveRequest> list = new ArrayList<>();
		String col = getLeaveUserColumn();
		String id = resolveForLeave(sessionValue);
		String sql = "SELECT * FROM leave_requests WHERE " + col + " = ? ORDER BY applied_at DESC";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, id);
			ResultSet rs = ps.executeQuery();
			while (rs.next())
				list.add(mapRow(rs, col));
		}
		return list;
	}

	public List<LeaveRequest> getTeamLeaveRequests(String managerUsername) throws Exception {
		List<LeaveRequest> list = new ArrayList<>();
		String lrCol = getLeaveUserColumn();
		String sql = "SELECT DISTINCT lr.* FROM leave_requests lr " + "JOIN team_members tm ON tm.username = lr."
				+ lrCol + " " + "JOIN teams t ON t.id = tm.team_id AND t.manager_username = ? "
				+ "ORDER BY lr.applied_at DESC";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next())
				list.add(mapRow(rs, lrCol));
		}
		return list;
	}

	public List<LeaveRequest> getAllLeaveRequests() throws Exception {
		List<LeaveRequest> list = new ArrayList<>();
		String lrCol = getLeaveUserColumn();
		String userCol = "email".equals(lrCol) ? "email" : "username";
		String sql = "SELECT lr.*, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname "
				+ "FROM leave_requests lr " + "LEFT JOIN users u ON u." + userCol + " = lr." + lrCol + " "
				+ "ORDER BY lr.applied_at DESC";
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				LeaveRequest lr = mapRow(rs, lrCol);
				String fn = rs.getString("fullname");
				lr.setDisplayName((fn != null && !fn.trim().isEmpty()) ? fn.trim() : rs.getString(lrCol));
				list.add(lr);
			}
		}
		return list;
	}
}