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
import com.smartoffice.service.NotificationService;

/**
 * Handles task assignment from BOTH:
 *   - managerTasks.jsp  (form action="/assignTask")
 *   - admin forms       (if they also use /assignTask)
 *
 * This is the REAL servlet your JSP forms post to.
 * Notifications are fired here after every successful assignment.
 */
@SuppressWarnings("serial")
@WebServlet("/assignTask")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10 MB
public class AssignTaskServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String assignerEmail = (String) session.getAttribute("username");
        String assignerName  = getDisplayName(session);
        String role          = (String) session.getAttribute("role");
        boolean isAdmin      = "admin".equalsIgnoreCase(role);

        try {
            // Read form fields — support both param names used in your JSPs
            // managerTasks.jsp uses "employeeUsername", adminTasks might use "assignedTo"
            String assignedTo = request.getParameter("employeeUsername");
            if (assignedTo == null || assignedTo.isEmpty())
                assignedTo = request.getParameter("assignedTo");

            String title       = request.getParameter("title");
            // managerTasks.jsp uses "taskDesc", admin might use "description"
            String description = request.getParameter("taskDesc");
            if (description == null || description.isEmpty())
                description = request.getParameter("description");

            String deadline  = request.getParameter("deadline");
            String priority  = request.getParameter("priority");
            if (priority == null || priority.isEmpty()) priority = "MEDIUM";

            // Validate required fields
            if (assignedTo == null || assignedTo.isEmpty() ||
                title == null || title.isEmpty()) {
                String redirectUrl = isAdmin ? "/adminTasks" : "/managerTasks";
                response.sendRedirect(request.getContextPath() + redirectUrl + "?error=MissingFields");
                return;
            }

            // Handle optional attachment
            String attachmentName  = null;
            byte[] attachmentBytes = null;
            try {
                Part filePart = request.getPart("attachment");
                if (filePart != null && filePart.getSize() > 0
                        && filePart.getSubmittedFileName() != null
                        && !filePart.getSubmittedFileName().isEmpty()) {
                    attachmentName  = filePart.getSubmittedFileName();
                    attachmentBytes = filePart.getInputStream().readAllBytes();
                }
            } catch (Exception ignore) {}

            java.sql.Date deadlineDate = null;
            if (deadline != null && !deadline.isEmpty()) {
                try { deadlineDate = java.sql.Date.valueOf(deadline); }
                catch (Exception ignore) {}
            }

            // Assign the task using the existing TaskDAO signature
            TaskDAO.assignTask(
                assignedTo,
                assignerEmail,
                title,
                description,
                deadlineDate,
                priority,
                attachmentName,
                attachmentBytes
            );

            // ── NOTIFICATIONS ─────────────────────────────────────────
            String roleLabel = isAdmin ? "Admin" : "Manager";
            String empMsg = "📋 New task assigned by " + roleLabel + " " + assignerName +
                            ": \"" + title + "\"" +
                            (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "") +
                            " | Priority: " + priority;

            // 1. Notify the employee who received the task
            NotificationService.notify(
                    assignedTo, assignerEmail,
                    NotificationService.TYPE_TASK, empMsg);

            if (isAdmin) {
                // 2. Admin assigned → notify the employee's manager too
                NotificationService.notifyManagerOf(
                        assignedTo, assignerEmail,
                        NotificationService.TYPE_TASK,
                        "📋 Admin " + assignerName + " assigned task \"" + title +
                        "\" to " + assignedTo);
            } else {
                // 3. Manager assigned → notify all admins
                NotificationService.notifyAllAdmins(
                        assignerEmail,
                        NotificationService.TYPE_TASK,
                        "📋 Manager " + assignerName + " assigned task \"" + title +
                        "\" to " + assignedTo);
            }
            // ─────────────────────────────────────────────────────────

            String redirectUrl = isAdmin ? "/adminTasks" : "/managerTasks";
            response.sendRedirect(request.getContextPath() + redirectUrl + "?success=TaskAssigned");

        } catch (Exception e) {
            e.printStackTrace();
            String redirectUrl = isAdmin ? "/adminTasks" : "/managerTasks";
            response.sendRedirect(request.getContextPath() + redirectUrl + "?error=" + e.getMessage());
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}