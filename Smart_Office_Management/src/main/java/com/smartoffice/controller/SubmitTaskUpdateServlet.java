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
import com.smartoffice.model.Task;
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
                String assignedBy = task.getAssignedBy(); // who assigned the task
                String taskTitle  = task.getTitle() != null
                        ? task.getTitle() : task.getDescription();

                String msg = getStatusEmoji(newStatus) + " " + employeeName +
                             " updated task \"" + taskTitle +
                             "\" → " + formatStatus(newStatus) +
                             (comment != null && !comment.isEmpty()
                                     ? ". Comment: " + comment : "");

                // Notify whoever assigned the task (manager or admin)
                if (assignedBy != null && !assignedBy.isEmpty()) {
                    NotificationService.notify(
                            assignedBy, employeeEmail,
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