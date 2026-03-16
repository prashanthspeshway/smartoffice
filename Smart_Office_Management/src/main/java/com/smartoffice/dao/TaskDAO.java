package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class TaskDAO {

    private static String resolveDbUsername(Connection con, String emailOrUsername) {
        if (emailOrUsername == null || emailOrUsername.trim().isEmpty()) {
            return emailOrUsername;
        }

        String trimmed = emailOrUsername.trim();

        String sql = "SELECT username FROM users WHERE email=? LIMIT 1";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, trimmed);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dbUsername = rs.getString("username");

                if (dbUsername != null && !dbUsername.trim().isEmpty()) {
                    return dbUsername.trim();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return trimmed;
    }

    // ASSIGN TASK
    public static void assignTask(String emp, String manager, String title, String desc,
                                  Date deadline, String priority,
                                  String attachmentName, byte[] attachmentBytes) {

        try (Connection con = DBConnectionUtil.getConnection()) {

            String assignedToDb = resolveDbUsername(con, emp);
            String assignedByDb = resolveDbUsername(con, manager);

            String sql = "INSERT INTO tasks (title, description, attachment_name, attachment, assigned_to, assigned_by, status, deadline, priority) "
                    + "VALUES (?, ?, ?, ?, ?, ?, 'ASSIGNED', ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, title);
            ps.setString(2, desc);
            ps.setString(3, attachmentName);

            if (attachmentBytes != null)
                ps.setBytes(4, attachmentBytes);
            else
                ps.setNull(4, java.sql.Types.BLOB);

            ps.setString(5, assignedToDb);
            ps.setString(6, assignedByDb);

            if (deadline != null)
                ps.setDate(7, deadline);
            else
                ps.setNull(7, java.sql.Types.DATE);

            ps.setString(8, priority);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // EMPLOYEE UPLOAD DOCUMENT
    public static void submitEmployeeWork(int taskId, String attachmentName, byte[] attachmentBytes, String comment) {

        String sql = "UPDATE tasks SET employee_attachment_name=?, employee_attachment=?, employee_comment=?, status='SUBMITTED' WHERE id=?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, attachmentName);

            if (attachmentBytes != null)
                ps.setBytes(2, attachmentBytes);
            else
                ps.setNull(2, java.sql.Types.BLOB);

            ps.setString(3, comment);
            ps.setInt(4, taskId);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
 // ADMIN VIEW ALL TASKS
    public static List<Task> getAllTasks() {

        List<Task> list = new ArrayList<>();

        String sql = "SELECT * FROM tasks ORDER BY id DESC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Task task = new Task();

                task.setId(rs.getInt("id"));
                task.setTitle(rs.getString("title"));
                task.setDescription(rs.getString("description"));
                task.setAssignedTo(rs.getString("assigned_to"));
                task.setAssignedBy(rs.getString("assigned_by"));
                task.setStatus(rs.getString("status"));
                task.setAssignedDate(rs.getTimestamp("assigned_date"));

                try { task.setDeadline(rs.getDate("deadline")); } catch (Exception ignore) {}
                try { task.setPriority(rs.getString("priority")); } catch (Exception ignore) {}

                list.add(task);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // USER VIEW TASKS
    public static List<Task> getTasksForEmployee(String username) {

        List<Task> list = new ArrayList<>();

        String sql = "SELECT * FROM tasks WHERE assigned_to=? ORDER BY id DESC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String assignedToDb = resolveDbUsername(con, username);

            ps.setString(1, assignedToDb);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Task task = new Task();

                task.setId(rs.getInt("id"));
                task.setTitle(rs.getString("title"));
                task.setDescription(rs.getString("description"));
                task.setAttachmentName(rs.getString("attachment_name"));
                task.setAssignedTo(rs.getString("assigned_to"));
                task.setAssignedBy(rs.getString("assigned_by"));
                task.setStatus(rs.getString("status"));
                task.setAssignedDate(rs.getTimestamp("assigned_date"));

                try { task.setDeadline(rs.getDate("deadline")); } catch (Exception ignore) {}
                try { task.setPriority(rs.getString("priority")); } catch (Exception ignore) {}

                try { task.setEmployeeAttachmentName(rs.getString("employee_attachment_name")); } catch (Exception ignore) {}
                try { task.setEmployeeComment(rs.getString("employee_comment")); } catch (Exception ignore) {}

                list.add(task);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // MANAGER VIEW TASKS
    public static List<Task> getTasksAssignedByManager(String manager, String employee) {

        List<Task> list = new ArrayList<>();

        String sql = "SELECT * FROM tasks WHERE assigned_by=? AND assigned_to=? ORDER BY id DESC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String managerDb = resolveDbUsername(con, manager);
            String employeeDb = resolveDbUsername(con, employee);

            ps.setString(1, managerDb);
            ps.setString(2, employeeDb);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Task t = new Task();

                t.setId(rs.getInt("id"));
                t.setTitle(rs.getString("title"));
                t.setDescription(rs.getString("description"));
                t.setAttachmentName(rs.getString("attachment_name"));

                t.setEmployeeAttachmentName(rs.getString("employee_attachment_name"));
                t.setEmployeeComment(rs.getString("employee_comment"));

                t.setStatus(rs.getString("status"));
                t.setAssignedDate(rs.getTimestamp("assigned_date"));

                try { t.setDeadline(rs.getDate("deadline")); } catch (Exception ignore) {}
                try { t.setPriority(rs.getString("priority")); } catch (Exception ignore) {}

                list.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
 // UPDATE TASK STATUS
    public static void updateStatus(int taskId, String status) {

        String sql = "UPDATE tasks SET status=? WHERE id=?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, taskId);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // MARK COMPLETED
    public static void markCompleted(int taskId) {

        String sql = "UPDATE tasks SET status='COMPLETED' WHERE id=?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, taskId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // DELETE OLD TASKS
    public static void deleteOldCompletedTasks() {

        String sql = "DELETE FROM tasks WHERE status='COMPLETED' AND assigned_date < CURDATE()";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
 // CHECK IF EMPLOYEE BELONGS TO MANAGER
    public static boolean isEmployeeUnderManager(String employee, String manager) {

        boolean exists = false;

        String sql = "SELECT 1 FROM teams t " +
                     "JOIN team_members tm ON tm.team_id = t.id " +
                     "WHERE t.manager_username=? AND tm.username=? LIMIT 1";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, manager);
            ps.setString(2, employee);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                exists = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return exists;
    }

    // GET EMPLOYEES UNDER MANAGER
    public static List<User> getEmployeesUnderManager(String managerUsername) {

        List<User> list = new ArrayList<>();

        String sql = "SELECT DISTINCT u.email,u.firstname,u.lastname,u.phone,u.status "
                + "FROM users u "
                + "JOIN team_members tm ON tm.username = u.email "
                + "JOIN teams t ON t.id = tm.team_id AND t.manager_username=?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, managerUsername);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                User u = new User();

                u.setEmail(rs.getString("email"));
                u.setFirstname(rs.getString("firstname"));
                u.setLastname(rs.getString("lastname"));
                u.setPhone(rs.getString("phone"));
                u.setStatus(rs.getString("status"));

                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

}