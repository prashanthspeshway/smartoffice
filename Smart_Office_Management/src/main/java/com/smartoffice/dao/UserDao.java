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

		String sql = "SELECT id, username, fullname, role, status, email, phone FROM users";

		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				User u = new User();
				u.setId(rs.getInt("id"));
				u.setUsername(rs.getString("username"));
				u.setFullname(rs.getString("fullname"));
				u.setRole(rs.getString("role"));
				u.setStatus(rs.getString("status"));
				u.setEmail(rs.getString("email"));
				u.setPhone(rs.getString("phone"));
				users.add(u);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return users;
	}

	/* =========================
	   Get users under a manager
	   ========================= */
	public static List<User> getUsersByManager(String managerUsername) {

		List<User> users = new ArrayList<>();

		String sql = "SELECT id, username, fullname, role, status, email, phone " +
		             "FROM users WHERE manager = ?";

		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				User u = new User();
				u.setId(rs.getInt("id"));
				u.setUsername(rs.getString("username"));
				u.setFullname(rs.getString("fullname"));
				u.setRole(rs.getString("role"));
				u.setStatus(rs.getString("status"));
				u.setEmail(rs.getString("email"));
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
	public static User getUserByUsername(String username) {

		User user = null;

		String sql = "SELECT id, username, fullname, role, status, email, phone, manager " +
		             "FROM users WHERE username = ?";

		try (Connection con = DBConnectionUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				user = new User();
				user.setId(rs.getInt("id"));
				user.setUsername(rs.getString("username"));
				user.setFullname(rs.getString("fullname"));
				user.setRole(rs.getString("role"));
				user.setStatus(rs.getString("status"));
				user.setEmail(rs.getString("email"));
				user.setPhone(rs.getString("phone"));
				user.setManager(rs.getString("manager"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return user;
	}
}