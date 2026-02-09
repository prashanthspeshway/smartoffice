package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.smartoffice.utils.DBConnectionUtil;

public class AttendanceDAO {

	public boolean hasPunchedIn(String username, Date date) throws Exception {
		String sql = "SELECT punch_in FROM attendance WHERE username=? AND punch_date=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ps.setDate(2, new java.sql.Date(date.getTime()));

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				return rs.getTimestamp("punch_in") != null;
			}
			return false;
		}
	}

	public boolean hasPunchedOut(String username, Date date) throws Exception {
		String sql = "SELECT punch_out FROM attendance WHERE username=? AND punch_date=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ps.setDate(2, new java.sql.Date(date.getTime()));

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				return rs.getTimestamp("punch_out") != null;
			}
			return false;
		}
	}

	public void punchIn(String username) throws Exception {
		String sql = "INSERT INTO attendance (username, punch_in, punch_date) " + "VALUES (?, NOW(), CURDATE()) "
				+ "ON DUPLICATE KEY UPDATE punch_in = IF(punch_in IS NULL, NOW(), punch_in)";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ps.executeUpdate();
		}
	}

	public void punchOut(String username) throws Exception {
		String sql = "UPDATE attendance SET punch_out = NOW() "
				+ "WHERE username=? AND punch_date=CURDATE() AND punch_out IS NULL";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ps.executeUpdate();
		}
	}

	public ResultSet getTodayAttendance(String username) throws Exception {
		String sql = "SELECT punch_in, punch_out FROM attendance " + "WHERE username=? AND punch_date=CURDATE()";

		Connection con = DBConnectionUtil.getConnection();
		PreparedStatement ps = con.prepareStatement(sql);
		ps.setString(1, username);

		return ps.executeQuery();
	}

}