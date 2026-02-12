package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class TaskDAO {

	public static void assignTask(String emp, String manager, String desc) {
		String sql = "INSERT INTO tasks (description, assigned_to, assigned_by, status) "
				+ "VALUES (?, ?, ?, 'ASSIGNED')";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, desc);
			ps.setString(2, emp);
			ps.setString(3, manager);

			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace(); // use logger in production
		}
	}

	public static List<Task> getTasksForEmployee(String username) {
		List<Task> list = new ArrayList<>();

		String sql = "SELECT * FROM tasks WHERE assigned_to=? ORDER BY id DESC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Task task = new Task();
				task.setId(rs.getInt("id"));
				task.setTitle(rs.getString("title")); // ✅ if exists
				task.setDescription(rs.getString("description"));
				task.setAssignedTo(rs.getString("assigned_to"));
				task.setAssignedBy(rs.getString("assigned_by"));
				task.setStatus(rs.getString("status"));
				task.setAssignedDate(rs.getTimestamp("assigned_date")); // ✅ FIXED

				list.add(task);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	public static void updateStatus(int taskId, String status) {
		String sql = "UPDATE tasks SET status=? WHERE id=?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, status);
			ps.setInt(2, taskId);
			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// USER ONLY – safe
	public static void markCompleted(int taskId) {

		String sql = "UPDATE tasks SET status='COMPLETED' WHERE id=?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, taskId);
			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void deleteOldCompletedTasks() {
		String sql = "DELETE FROM tasks " + "WHERE status='COMPLETED' " + "AND assigned_date < CURDATE()";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// MANAGER – view tasks assigned to a specific employee
	public static List<Task> getTasksAssignedByManager(String manager, String employee) {

		List<Task> list = new ArrayList<>();

		String sql = "SELECT * FROM tasks WHERE assigned_by=? AND assigned_to=? ORDER BY id DESC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, manager);
			ps.setString(2, employee);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Task t = new Task();
				t.setId(rs.getInt("id"));
				t.setDescription(rs.getString("description"));
				t.setStatus(rs.getString("status"));
				t.setAssignedDate(rs.getTimestamp("assigned_date"));
				list.add(t);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	public static List<User> getEmployeesUnderManager(String managerUsername) {
		List<User> list = new ArrayList<>();
		String sql = "SELECT * FROM users WHERE manager=? ORDER BY fullname";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				User u = new User();
				u.setUsername(rs.getString("username"));
				u.setFullname(rs.getString("fullname"));
				u.setEmail(rs.getString("email"));
				u.setPhone(rs.getString("phone"));
				u.setStatus(rs.getString("status"));
				list.add(u);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	// TaskDAO.java
	public static boolean isEmployeeUnderManager(String employeeUsername, String managerUsername) {
		String sql = "SELECT COUNT(*) FROM users WHERE username=? AND manager=?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, employeeUsername);
			ps.setString(2, managerUsername);

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				int count = rs.getInt(1);
				return count > 0; // true if employee exists under this manager
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return false; // fallback
	}

}
