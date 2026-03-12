package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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
		if (hasAttendanceColumn("email")) return "email";
		if (hasAttendanceColumn("username")) return "username";
		return "username";
	}

	/** Resolve session value (email) to attendance identifier. When attendance uses username, look up from users. */
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

	/** Get username from users by email (for INSERT when both username and user_email exist). */
	private String getUsernameFromEmail(String email) throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement("SELECT username FROM users WHERE email = ?")) {
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) return rs.getString("username");
		}
		return email;
	}

	// Check if user has punched in today (sessionValue = email from session)
	public boolean hasPunchedIn(String sessionValue, Date date) throws Exception {
		String id = resolveForAttendance(sessionValue);
		String col = getAttendanceUserColumn();
		String sql = "SELECT punch_in FROM attendance WHERE " + col + "=? AND punch_date=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, id);
			ps.setDate(2, new java.sql.Date(date.getTime()));

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				return rs.getTimestamp("punch_in") != null;
			}
			return false;
		}
	}

	// Check if user has punched out today
	public boolean hasPunchedOut(String sessionValue, Date date) throws Exception {
		String id = resolveForAttendance(sessionValue);
		String col = getAttendanceUserColumn();
		String sql = "SELECT punch_out FROM attendance WHERE " + col + "=? AND punch_date=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, id);
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

		// 1️⃣ Check if Saturday or Sunday
		java.util.Calendar cal = java.util.Calendar.getInstance();
		cal.setTime(date);

		int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);

		if (dayOfWeek == java.util.Calendar.SATURDAY || dayOfWeek == java.util.Calendar.SUNDAY) {
			return true; // Block punch in/out on weekends
		}

		// 2️⃣ Check admin-declared holidays from DB
		String sql = "SELECT COUNT(*) FROM holidays WHERE holiday_date=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setDate(1, new java.sql.Date(date.getTime()));
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				return rs.getInt(1) > 0;
			}
		}

		return false;
	}

	// Punch In with holiday check (sessionValue = email from session)
	public void punchIn(String sessionValue) throws Exception {
		Date today = new Date(System.currentTimeMillis());

		if (isHoliday(today)) {
			throw new Exception("Cannot punch in on a holiday");
		}

		// Build INSERT with ALL user columns that exist (table may have both username and user_email during migration)
		List<String> userCols = new ArrayList<>();
		if (hasAttendanceColumn("username")) userCols.add("username");
		if (hasAttendanceColumn("user_email")) userCols.add("user_email");
		if (hasAttendanceColumn("email")) userCols.add("email");

		if (userCols.isEmpty()) userCols.add("username");

		String cols = String.join(", ", userCols);
		String placeholders = String.join(", ", java.util.Collections.nCopies(userCols.size(), "?"));
		String sql = "INSERT INTO attendance (" + cols + ", punch_in, punch_date) VALUES (" + placeholders + ", NOW(), CURDATE()) "
				+ "ON DUPLICATE KEY UPDATE punch_in = IF(punch_in IS NULL, NOW(), punch_in)";

		String usernameVal = getUsernameFromEmail(sessionValue);

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			int i = 1;
			for (String c : userCols) {
				ps.setString(i++, "email".equals(c) || "user_email".equals(c) ? sessionValue : usernameVal);
			}
			ps.executeUpdate();
		}
	}

	// Punch Out with holiday check
	public void punchOut(String sessionValue) throws Exception {
		Date today = new Date(System.currentTimeMillis());

		if (isHoliday(today)) {
			throw new Exception("Cannot punch out on a holiday");
		}

		String id = resolveForAttendance(sessionValue);
		String col = getAttendanceUserColumn();
		String sql = "UPDATE attendance SET punch_out = NOW() "
				+ "WHERE " + col + "=? AND punch_date=CURDATE() AND punch_out IS NULL";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, id);
			ps.executeUpdate();
		}
	}

	// Get today's attendance (sessionValue = email from session)
	public ResultSet getTodayAttendance(String sessionValue) throws Exception {
		String id = resolveForAttendance(sessionValue);
		String col = getAttendanceUserColumn();
		String sql = "SELECT punch_in, punch_out FROM attendance WHERE " + col + "=? AND punch_date=CURDATE()";

		Connection con = DBConnectionUtil.getConnection();
		PreparedStatement ps = con.prepareStatement(sql);
		ps.setString(1, id);

		return ps.executeQuery();
	}

	public List<TeamAttendance> getTeamAttendanceForToday(String managerUsername) throws Exception {
		List<TeamAttendance> list = new ArrayList<>();
		String aCol = getAttendanceUserColumn();
		String joinOn = "username".equals(aCol) ? "a.username = u.username" : "a." + aCol + " = u.email";
		String sql = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, a.punch_in, a.punch_out " +
		             "FROM (SELECT DISTINCT tm.username FROM team_members tm JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?) team_users " +
		             "JOIN users u ON u.email = team_users.username " +
		             "LEFT JOIN attendance a ON " + joinOn + " AND a.punch_date = CURDATE() " +
		             "ORDER BY fullname";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				TeamAttendance ta = new TeamAttendance();
				ta.setUsername(rs.getString("email"));
				ta.setFullName(rs.getString("fullname"));
				ta.setPunchIn(rs.getTimestamp("punch_in"));
				ta.setPunchOut(rs.getTimestamp("punch_out"));
				ta.setStatus(ta.getPunchIn() == null ? "Absent" : (ta.getPunchOut() == null ? "Punched In" : "Present"));
				list.add(ta);
			}
		}
		return list;
	}

	public List<TeamAttendance> getTeamAttendanceForMonth(String managerUsername) throws Exception {
		List<TeamAttendance> list = new ArrayList<>();
		String aCol = getAttendanceUserColumn();
		String joinOn = "username".equals(aCol) ? "a.username = u.username" : "a." + aCol + " = u.email";
		String sql = "SELECT u.email, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS fullname, a.punch_date, a.punch_in, a.punch_out " +
		             "FROM (SELECT DISTINCT tm.username FROM team_members tm JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?) team_users " +
		             "JOIN users u ON u.email = team_users.username " +
		             "LEFT JOIN attendance a ON " + joinOn + " AND MONTH(a.punch_date) = MONTH(CURDATE()) AND YEAR(a.punch_date) = YEAR(CURDATE()) " +
		             "ORDER BY fullname, a.punch_date";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				TeamAttendance ta = new TeamAttendance();
				ta.setUsername(rs.getString("email"));
				ta.setFullName(rs.getString("fullname"));
				ta.setAttendanceDate(rs.getDate("punch_date"));
				ta.setPunchIn(rs.getTimestamp("punch_in"));
				ta.setPunchOut(rs.getTimestamp("punch_out"));
				list.add(ta);
			}
		}
		return list;
	}

}