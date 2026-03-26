package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.TokenData;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class UserDao {

	/*
	 * ========================= Get all users (Admin) =========================
	 */
	public static List<User> getAllUsers() {

		List<User> users = new ArrayList<>();

		String sql = "SELECT id, username, email, firstname, lastname, role, status, phone, designation, joinedDate FROM users";

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				User u = new User();
				u.setId(rs.getInt("id"));
				u.setUsername(rs.getString("username"));
				u.setEmail(rs.getString("email"));
				u.setFirstname(rs.getString("firstname"));
				u.setLastname(rs.getString("lastname"));
				u.setRole(rs.getString("role"));
				u.setStatus(rs.getString("status"));
				u.setPhone(rs.getString("phone"));
				u.setDesignation(rs.getString("designation"));
				u.setJoinedDate(rs.getDate("joinedDate"));
				users.add(u);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	}

	public static User getUserByUsername(String username) {
	    String sql = "SELECT id, email, firstname, lastname, role, status, phone FROM users WHERE username = ? LIMIT 1";
	    try (Connection con = DBConnectionUtil.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {
	        ps.setString(1, username);
	        ResultSet rs = ps.executeQuery();
	        if (rs.next()) {
	            User u = new User();
	            u.setId(rs.getInt("id"));
	            u.setEmail(rs.getString("email"));
	            u.setFirstname(rs.getString("firstname"));
	            u.setLastname(rs.getString("lastname"));
	            u.setRole(rs.getString("role"));
	            u.setStatus(rs.getString("status"));
	            u.setPhone(rs.getString("phone"));
	            return u;
	        }
	    } catch (Exception e) { e.printStackTrace(); }
	    return null;
	}

	/*
	 * ========================= Get users in teams managed by manager
	 * FIX: Now also fetches designation so the assign-task form can
	 *      filter employees by designation.
	 * =========================
	 */
	public static List<User> getUsersByManager(String managerUsername) {
	    List<User> users = new ArrayList<>();
	    String sql = "SELECT DISTINCT u.id, u.email, u.firstname, u.lastname, u.role, u.status, u.phone, u.designation, t.name AS team_name "
	            + "FROM users u "
	            + "JOIN team_members tm ON tm.username = u.email "
	            + "JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?";
	    try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
	        ps.setString(1, managerUsername);
	        ResultSet rs = ps.executeQuery();
	        while (rs.next()) {
	            User u = new User();
	            u.setId(rs.getInt("id"));
	            u.setEmail(rs.getString("email"));
	            u.setFirstname(rs.getString("firstname"));
	            u.setLastname(rs.getString("lastname"));
	            u.setRole(rs.getString("role"));
	            u.setStatus(rs.getString("status"));
	            u.setPhone(rs.getString("phone"));
	            u.setDesignation(rs.getString("designation"));
	            u.setTeamName(rs.getString("team_name")); // ← new
	            users.add(u);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return users;
	}

	public static List<User> getUsersByRole(String role) {

		List<User> list = new ArrayList<>();

		String sql = "SELECT * FROM users WHERE LOWER(role)=LOWER(?)";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, role);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				User u = new User();

				u.setEmail(rs.getString("email"));
				u.setFirstname(rs.getString("firstname"));
				u.setLastname(rs.getString("lastname"));

				list.add(u);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	/*
	 * ========================= Get logged-in user profile (USED FOR SELF PROFILE)
	 * =========================
	 */
	public static User getUserByEmail(String email) {
		User user = null;
		String sql = "SELECT id, email, firstname, lastname, role, status, phone FROM users WHERE email = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				user = new User();
				user.setId(rs.getInt("id"));
				user.setEmail(rs.getString("email"));
				user.setFirstname(rs.getString("firstname"));
				user.setLastname(rs.getString("lastname"));
				user.setRole(rs.getString("role"));
				user.setStatus(rs.getString("status"));
				user.setPhone(rs.getString("phone"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return user;
	}

	public static void saveResetToken(String email, String token, long expiryTime) {

	    String sql = "INSERT INTO password_reset (email, token, expiry_time) VALUES (?, ?, ?)";

	    try (Connection con = DBConnectionUtil.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setString(1, email);
	        ps.setString(2, token);
	        ps.setLong(3, expiryTime);

	        ps.executeUpdate();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}

	public static TokenData getResetToken(String token) {

	    String sql = "SELECT email, expiry_time FROM password_reset WHERE token=?";

	    try (Connection con = DBConnectionUtil.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setString(1, token);
	        ResultSet rs = ps.executeQuery();

	        if (rs.next()) {
	            return new TokenData(
	                rs.getString("email"),
	                rs.getLong("expiry_time")
	            );
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return null;
	}

	public static void updatePassword(String email, String newPassword) {

	    String sql = "UPDATE users SET password=? WHERE email=?";

	    try (Connection con = DBConnectionUtil.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setString(1, newPassword);
	        ps.setString(2, email);

	        ps.executeUpdate();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}

	public static void deleteResetToken(String token) {

	    String sql = "DELETE FROM password_reset WHERE token=?";

	    try (Connection con = DBConnectionUtil.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setString(1, token);
	        ps.executeUpdate();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}

}