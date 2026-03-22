package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/submitTaskUpdate")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class SubmitTaskUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // "username" attribute holds the email
        String employeeEmail = (String) session.getAttribute("username");
        String employeeName  = getDisplayName(session);

        try {
            int    taskId    = Integer.parseInt(request.getParameter("taskId"));
            String newStatus = request.getParameter("status");
            String comment   = request.getParameter("comment");

            if (newStatus == null || newStatus.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Status is required");
                return;
            }

            // Get task BEFORE updating — needed to find who assigned it
            Task task = TaskDAO.getTaskById(taskId);

            // Handle optional file
            Part filePart = null;
            try { filePart = request.getPart("employeeFile"); } catch (Exception ignore) {}

            boolean hasFile = filePart != null
                    && filePart.getSize() > 0
                    && filePart.getSubmittedFileName() != null
                    && !filePart.getSubmittedFileName().isEmpty();

            if (hasFile) {
                // Update with file
                TaskDAO.submitEmployeeWork(
                        taskId,
                        filePart.getSubmittedFileName(),
                        filePart.getInputStream().readAllBytes(),
                        comment);
                // Also update status to the employee's chosen value
                TaskDAO.updateStatus(taskId, newStatus);
            } else {
                // Status + comment only
                TaskDAO.updateTaskStatus(taskId, newStatus, comment, null);
            }

            // ── NOTIFICATIONS ─────────────────────────────────────────
            if (task != null) {
                /*
                 * BUG FIX: task.getAssignedBy() stores the DB username which may NOT
                 * be the email. NotificationService inserts into recipient_email, so
                 * we must resolve the username → email first.
                 */
                String assignedByRaw   = task.getAssignedBy();
                String assignedByEmail = resolveToEmail(assignedByRaw);

                String taskTitle = task.getTitle() != null
                        ? task.getTitle() : task.getDescription();

                String msg = getStatusEmoji(newStatus) + " " + employeeName
                        + " updated task \"" + taskTitle
                        + "\" → " + formatStatus(newStatus)
                        + (comment != null && !comment.isEmpty()
                                ? ". Comment: " + comment : "");

                // Notify whoever assigned the task (manager OR admin)
                if (assignedByEmail != null && !assignedByEmail.isEmpty()
                        && !assignedByEmail.equalsIgnoreCase(employeeEmail)) {
                    NotificationService.notify(
                            assignedByEmail, employeeEmail,
                            NotificationService.TYPE_TASK, msg);
                }

                /*
                 * BUG FIX: If the task was assigned by an admin (not the manager),
                 * the manager was never notified. We check the assigner's role and
                 * additionally ping the employee's direct manager in that case.
                 */
                String assignerRole = getRoleOf(assignedByEmail);
                if ("admin".equalsIgnoreCase(assignerRole)) {
                    NotificationService.notifyManagerOf(
                            employeeEmail, employeeEmail,
                            NotificationService.TYPE_TASK, msg);
                }

                // Always also notify all admins
                NotificationService.notifyAllAdmins(
                        employeeEmail, NotificationService.TYPE_TASK, msg);
            }
            // ─────────────────────────────────────────────────────────

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Task update failed: " + e.getMessage());
        }
    }

    /**
     * Resolves a DB username or email to an email address.
     * If the value already contains '@' it is returned as-is.
     * Otherwise UserDao.getUserByUsername() is called to look up the email.
     *
     * NOTE: If UserDao does not yet have getUserByUsername(), add:
     *   public static User getUserByUsername(String username) {
     *       String sql = "SELECT * FROM users WHERE username = ? LIMIT 1";
     *       // ... standard query ...
     *   }
     */
    private String resolveToEmail(String usernameOrEmail) {
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty()) return null;
        String val = usernameOrEmail.trim();
        if (val.contains("@")) return val; // already an email

        try {
            User user = UserDao.getUserByUsername(val);
            if (user != null && user.getEmail() != null) return user.getEmail();
        } catch (Exception e) {
            System.err.println("[SubmitTaskUpdateServlet] resolveToEmail error for '"
                    + val + "': " + e.getMessage());
        }
        return val; // fall back to raw value
    }

    /** Returns the role stored in the users table for the given email. */
    private String getRoleOf(String email) {
        if (email == null || email.isEmpty()) return null;
        try {
            User user = UserDao.getUserByEmail(email);
            return user != null ? user.getRole() : null;
        } catch (Exception e) {
            System.err.println("[SubmitTaskUpdateServlet] getRoleOf error for '"
                    + email + "': " + e.getMessage());
        }
        return null;
    }

    private String getStatusEmoji(String status) {
        if (status == null) return "📋";
        switch (status.toUpperCase()) {
            case "COMPLETED":             return "✅";
            case "INCOMPLETE":            return "⏳";
            case "ERRORS_RAISED":         return "⚠️";
            case "DOCUMENT_VERIFICATION": return "📄";
            case "SUBMITTED":             return "📨";
            default:                      return "📋";
        }
    }

    private String formatStatus(String status) {
        if (status == null) return "";
        switch (status.toUpperCase()) {
            case "COMPLETED":             return "Completed";
            case "INCOMPLETE":            return "Incomplete";
            case "ERRORS_RAISED":         return "Errors Raised";
            case "DOCUMENT_VERIFICATION": return "Document Verification";
            case "SUBMITTED":             return "Submitted";
            default:                      return status;
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}