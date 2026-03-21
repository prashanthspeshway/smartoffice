package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.Part;

import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class TaskDAO {

    // ─────────────────────────────────────────────────────────────
    // Internal helper — resolve email → db username
    // ─────────────────────────────────────────────────────────────
    private static String resolveDbUsername(Connection con, String emailOrUsername) {
        if (emailOrUsername == null || emailOrUsername.trim().isEmpty()) return emailOrUsername;
        String trimmed = emailOrUsername.trim();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT username FROM users WHERE email=? LIMIT 1")) {
            ps.setString(1, trimmed);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String db = rs.getString("username");
                if (db != null && !db.trim().isEmpty()) return db.trim();
            }
        } catch (Exception e) { e.printStackTrace(); }
        return trimmed;
    }

    // ─────────────────────────────────────────────────────────────
    // Map a ResultSet row → Task (full mapping)
    // ─────────────────────────────────────────────────────────────
    private static Task mapFullRow(ResultSet rs) throws Exception {
        Task task = new Task();
        task.setId(rs.getInt("id"));
        task.setTitle(rs.getString("title"));
        task.setDescription(rs.getString("description"));
        task.setAssignedTo(rs.getString("assigned_to"));
        task.setAssignedBy(rs.getString("assigned_by"));
        task.setStatus(rs.getString("status"));
        task.setAssignedDate(rs.getTimestamp("assigned_date"));
        try { task.setDeadline(rs.getDate("deadline")); }           catch (Exception ignore) {}
        try { task.setPriority(rs.getString("priority")); }         catch (Exception ignore) {}
        try { task.setAttachmentName(rs.getString("attachment_name")); } catch (Exception ignore) {}
        try { task.setEmployeeAttachmentName(rs.getString("employee_attachment_name")); } catch (Exception ignore) {}
        try { task.setEmployeeComment(rs.getString("employee_comment")); } catch (Exception ignore) {}
        try { task.setSubmittedAt(rs.getTimestamp("submitted_at")); } catch (Exception ignore) {}
        return task;
    }

    // ─────────────────────────────────────────────────────────────
    // NEW — Get a single task by ID (used by SubmitTaskUpdateServlet
    //        to find assignedBy for notification routing)
    // ─────────────────────────────────────────────────────────────
    public static Task getTaskById(int taskId) {
        String sql = "SELECT * FROM tasks WHERE id = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapFullRow(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ─────────────────────────────────────────────────────────────
    // NEW — Update task status + optional comment + optional file
    //        (replaces submitEmployeeWork for the new servlet)
    // ─────────────────────────────────────────────────────────────
    public static void updateTaskStatus(int taskId, String status, String comment, Part filePart)
            throws Exception {

        boolean hasFile = filePart != null && filePart.getSize() > 0
                && filePart.getSubmittedFileName() != null
                && !filePart.getSubmittedFileName().isEmpty();

        if (hasFile) {
            // Update status + comment + employee file
            String sql = "UPDATE tasks SET status=?, employee_comment=?, " +
                         "employee_attachment_name=?, employee_attachment=?, submitted_at=NOW() " +
                         "WHERE id=?";
            try (Connection con = DBConnectionUtil.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setString(2, comment);
                ps.setString(3, filePart.getSubmittedFileName());
                ps.setBytes(4, filePart.getInputStream().readAllBytes());
                ps.setInt(5, taskId);
                ps.executeUpdate();
            }
        } else {
            // Update status + comment only
            String sql = "UPDATE tasks SET status=?, employee_comment=? WHERE id=?";
            try (Connection con = DBConnectionUtil.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setString(2, comment);
                ps.setInt(3, taskId);
                ps.executeUpdate();
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // ASSIGN TASK — updated to also accept Task object
    // ─────────────────────────────────────────────────────────────

    /** Convenience overload — accepts a Task model object */
    public static void assignTask(Task task) {
        assignTask(
            task.getAssignedTo(),
            task.getAssignedBy(),
            task.getTitle(),
            task.getDescription(),
            task.getDeadline(),
            task.getPriority(),
            null,   // no attachment name
            null    // no attachment bytes
        );
    }

    /** Original full signature (used by existing JSP forms) */
    public static void assignTask(String emp, String manager, String title, String desc,
                                  Date deadline, String priority,
                                  String attachmentName, byte[] attachmentBytes) {
        try (Connection con = DBConnectionUtil.getConnection()) {
            String assignedToDb = resolveDbUsername(con, emp);
            String assignedByDb = resolveDbUsername(con, manager);
            String sql = "INSERT INTO tasks (title, description, attachment_name, attachment, " +
                         "assigned_to, assigned_by, status, deadline, priority) " +
                         "VALUES (?, ?, ?, ?, ?, ?, 'ASSIGNED', ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, desc);
            ps.setString(3, attachmentName);
            if (attachmentBytes != null) ps.setBytes(4, attachmentBytes);
            else ps.setNull(4, java.sql.Types.BLOB);
            ps.setString(5, assignedToDb);
            ps.setString(6, assignedByDb);
            if (deadline != null) ps.setDate(7, deadline);
            else ps.setNull(7, java.sql.Types.DATE);
            ps.setString(8, priority);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // DELETE TASK
    // ─────────────────────────────────────────────────────────────
    public static void deleteTask(int taskId) {
        String sql = "DELETE FROM tasks WHERE id = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // EMPLOYEE UPLOAD DOCUMENT (original method — kept intact)
    // ─────────────────────────────────────────────────────────────
    public static void submitEmployeeWork(int taskId, String attachmentName,
                                          byte[] attachmentBytes, String comment) {
        String sql = "UPDATE tasks SET employee_attachment_name=?, employee_attachment=?, " +
                     "employee_comment=?, status='SUBMITTED' WHERE id=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, attachmentName);
            if (attachmentBytes != null) ps.setBytes(2, attachmentBytes);
            else ps.setNull(2, java.sql.Types.BLOB);
            ps.setString(3, comment);
            ps.setInt(4, taskId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // ADMIN — get all tasks
    // ─────────────────────────────────────────────────────────────
    public static List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM tasks ORDER BY id DESC";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapFullRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // EMPLOYEE — get own tasks
    // ─────────────────────────────────────────────────────────────
    public static List<Task> getTasksForEmployee(String username) {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_to=? ORDER BY id DESC";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, resolveDbUsername(con, username));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapFullRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // MANAGER — get tasks they assigned to a specific employee
    // ─────────────────────────────────────────────────────────────
    public static List<Task> getTasksAssignedByManager(String manager, String employee) {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_by=? AND assigned_to=? ORDER BY id DESC";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, resolveDbUsername(con, manager));
            ps.setString(2, resolveDbUsername(con, employee));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapFullRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // UPDATE STATUS only
    // ─────────────────────────────────────────────────────────────
    public static void updateStatus(int taskId, String status) {
        String sql = "UPDATE tasks SET status=? WHERE id=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, taskId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK COMPLETED
    // ─────────────────────────────────────────────────────────────
    public static void markCompleted(int taskId) {
        String sql = "UPDATE tasks SET status='COMPLETED' WHERE id=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // DELETE OLD COMPLETED TASKS
    // ─────────────────────────────────────────────────────────────
    public static void deleteOldCompletedTasks() {
        String sql = "DELETE FROM tasks WHERE status='COMPLETED' AND assigned_date < CURDATE()";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ─────────────────────────────────────────────────────────────
    // GET TASKS BY STATUS
    // ─────────────────────────────────────────────────────────────
    public List<Task> getTasksByStatus(String status) throws Exception {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE status=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapFullRow(rs));
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // CHECK IF EMPLOYEE BELONGS TO MANAGER
    // ─────────────────────────────────────────────────────────────
    public static boolean isEmployeeUnderManager(String employee, String manager) {
        String sql = "SELECT 1 FROM teams t " +
                     "JOIN team_members tm ON tm.team_id = t.id " +
                     "WHERE t.manager_username=? AND tm.username=? LIMIT 1";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, manager);
            ps.setString(2, employee);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ─────────────────────────────────────────────────────────────
    // GET EMPLOYEES UNDER MANAGER
    // ─────────────────────────────────────────────────────────────
    public static List<User> getEmployeesUnderManager(String managerUsername) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT DISTINCT u.email, u.firstname, u.lastname, u.phone, u.status " +
                     "FROM users u " +
                     "JOIN team_members tm ON tm.username = u.email " +
                     "JOIN teams t ON t.id = tm.team_id AND t.manager_username=?";
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
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}