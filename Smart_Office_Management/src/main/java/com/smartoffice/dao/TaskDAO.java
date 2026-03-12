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

	public static List<Task> getAllTasks() throws Exception {
		List<Task> list = new ArrayList<>();
		String sql = "SELECT id, title, description, assigned_to, assigned_by, status, assigned_date "
				+ "FROM tasks ORDER BY id DESC";
		try (Connection con = DBConnectionUtil.getConnection();
		     PreparedStatement ps = con.prepareStatement(sql);
		     ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Task t = new Task();
				t.setId(rs.getInt("id"));
				t.setTitle(rs.getString("title"));
				t.setDescription(rs.getString("description"));
				t.setAssignedTo(rs.getString("assigned_to"));
				t.setAssignedBy(rs.getString("assigned_by"));
				t.setStatus(rs.getString("status"));
				t.setAssignedDate(rs.getTimestamp("assigned_date"));
				list.add(t);
			}
		}
		return list;
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
		String sql = "SELECT DISTINCT u.email, u.firstname, u.lastname, u.phone, u.status " +
		             "FROM users u JOIN team_members tm ON tm.username = u.email " +
		             "JOIN teams t ON t.id = tm.team_id AND t.manager_username = ? " +
		             "ORDER BY u.firstname, u.lastname";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				User u = new User();
				u.setEmail(rs.getString("email"));
				u.setFirstname(rs.getString("firstname"));
				u.setLastname(rs.getString("lastname"));
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

	public static boolean isEmployeeUnderManager(String employeeUsername, String managerUsername) {
		String sql = "SELECT COUNT(*) FROM team_members tm JOIN teams t ON t.id = tm.team_id " +
		             "WHERE tm.username = ? AND t.manager_username = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, employeeUsername);
			ps.setString(2, managerUsername);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) return rs.getInt(1) > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

}
