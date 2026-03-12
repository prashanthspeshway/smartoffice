package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLSyntaxErrorException;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.BreakLog;
import com.smartoffice.utils.DBConnectionUtil;

public class BreakDAO {

	private static String resolveDbUsername(Connection con, String emailOrUsername) {
		if (emailOrUsername == null || emailOrUsername.trim().isEmpty()) {
			return emailOrUsername;
		}
		String trimmed = emailOrUsername.trim();
		String sql = "SELECT username FROM users WHERE email = ? LIMIT 1";
		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, trimmed);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String dbUsername = rs.getString("username");
					if (dbUsername != null && !dbUsername.trim().isEmpty()) {
						return dbUsername.trim();
					}
				}
			}
		} catch (Exception e) {
			// fall back to original if lookup fails
			e.printStackTrace();
		}
		return trimmed;
	}

	public static int startBreak(String emailOrUsername) throws Exception {
		// First try using email column
		try (Connection con = DBConnectionUtil.getConnection()) {
			String sql = "INSERT INTO break_logs (email, break_date, start_time) VALUES (?, CURDATE(), NOW())";
			try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
				ps.setString(1, emailOrUsername);
				ps.executeUpdate();
				try (ResultSet rs = ps.getGeneratedKeys()) {
					return rs.next() ? rs.getInt(1) : 0;
				}
			}
		} catch (SQLSyntaxErrorException ex) {
			// Fallback to username column variant
			try (Connection con = DBConnectionUtil.getConnection()) {
				String username = resolveDbUsername(con, emailOrUsername);
				String sql = "INSERT INTO break_logs (username, break_date, start_time) VALUES (?, CURDATE(), NOW())";
				try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
					ps.setString(1, username);
					ps.executeUpdate();
					try (ResultSet rs = ps.getGeneratedKeys()) {
						return rs.next() ? rs.getInt(1) : 0;
					}
				}
			}
		}
	}

	public static void endBreak(String emailOrUsername) throws Exception {
		// Try email column first
		try (Connection con = DBConnectionUtil.getConnection()) {
			String sql = "UPDATE break_logs " +
					"SET end_time = NOW(), duration_seconds = TIMESTAMPDIFF(SECOND, start_time, NOW()) " +
					"WHERE email = ? AND break_date = CURDATE() AND end_time IS NULL " +
					"ORDER BY id DESC LIMIT 1";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				ps.setString(1, emailOrUsername);
				ps.executeUpdate();
				return;
			}
		} catch (SQLSyntaxErrorException ex) {
			// Fallback to username column
			try (Connection con = DBConnectionUtil.getConnection()) {
				String username = resolveDbUsername(con, emailOrUsername);
				String sql = "UPDATE break_logs " +
						"SET end_time = NOW(), duration_seconds = TIMESTAMPDIFF(SECOND, start_time, NOW()) " +
						"WHERE username = ? AND break_date = CURDATE() AND end_time IS NULL " +
						"ORDER BY id DESC LIMIT 1";
				try (PreparedStatement ps = con.prepareStatement(sql)) {
					ps.setString(1, username);
					ps.executeUpdate();
				}
			}
		}
	}

	public static List<BreakLog> getTodayBreaks(String emailOrUsername) throws Exception {
		List<BreakLog> list = new ArrayList<>();
		// Try email column first
		try (Connection con = DBConnectionUtil.getConnection()) {
			String sql = "SELECT id, start_time, end_time, duration_seconds " +
					"FROM break_logs WHERE email = ? AND break_date = CURDATE() ORDER BY start_time";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				ps.setString(1, emailOrUsername);
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
		} catch (SQLSyntaxErrorException ex) {
			// Fallback to username column
			try (Connection con = DBConnectionUtil.getConnection()) {
				String username = resolveDbUsername(con, emailOrUsername);
				String sql = "SELECT id, start_time, end_time, duration_seconds " +
						"FROM break_logs WHERE username = ? AND break_date = CURDATE() ORDER BY start_time";
				try (PreparedStatement ps = con.prepareStatement(sql)) {
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
			}
			return list;
		}
	}

	public static int getTodayTotalSeconds(String emailOrUsername) throws Exception {
		// Try email column first
		try (Connection con = DBConnectionUtil.getConnection()) {
			String sql = "SELECT COALESCE(SUM(duration_seconds),0) " +
					"FROM break_logs WHERE email = ? AND break_date = CURDATE()";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				ps.setString(1, emailOrUsername);
				try (ResultSet rs = ps.executeQuery()) {
					return rs.next() ? rs.getInt(1) : 0;
				}
			}
		} catch (SQLSyntaxErrorException ex) {
			// Fallback to username column
			try (Connection con = DBConnectionUtil.getConnection()) {
				String username = resolveDbUsername(con, emailOrUsername);
				String sql = "SELECT COALESCE(SUM(duration_seconds),0) " +
						"FROM break_logs WHERE username = ? AND break_date = CURDATE()";
				try (PreparedStatement ps = con.prepareStatement(sql)) {
					ps.setString(1, username);
					try (ResultSet rs = ps.executeQuery()) {
						return rs.next() ? rs.getInt(1) : 0;
					}
				}
			}
		}
	}
}

