package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class UserDao {

	/* =========================
	   Get all users (Admin)
	   ========================= */
	public static List<User> getAllUsers() {

		List<User> users = new ArrayList<>();

		String sql = "SELECT id, email, firstname, lastname, role, status, phone FROM users";

		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				User u = new User();
				u.setId(rs.getInt("id"));
				u.setEmail(rs.getString("email"));
				u.setFirstname(rs.getString("firstname"));
				u.setLastname(rs.getString("lastname"));
				u.setRole(rs.getString("role"));
				u.setStatus(rs.getString("status"));
				u.setPhone(rs.getString("phone"));
				users.add(u);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	}

	/* =========================
	   Get users in teams managed by manager (from team_members)
	   ========================= */
	public static List<User> getUsersByManager(String managerUsername) {
		List<User> users = new ArrayList<>();
		String sql = "SELECT DISTINCT u.id, u.email, u.firstname, u.lastname, u.role, u.status, u.phone " +
		             "FROM users u JOIN team_members tm ON tm.username = u.email " +
		             "JOIN teams t ON t.id = tm.team_id AND t.manager_username = ?";
		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql)) {
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
				users.add(u);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	}

	/* =========================
	   Get logged-in user profile
	   (USED FOR SELF PROFILE)
	   ========================= */
	public static User getUserByEmail(String email) {
		User user = null;
		String sql = "SELECT id, email, firstname, lastname, role, status, phone FROM users WHERE email = ?";
		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql)) {
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
}