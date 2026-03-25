package com.smartoffice.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

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
 * Supports assigning the same task to MULTIPLE employees at once.
 * Notifications are fired for each assigned employee after every successful assignment.
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
        String redirectUrl   = isAdmin ? "/adminTasks" : "/managerTasks";

        try {
            // ── Read selected employees (supports MULTIPLE checkboxes) ──
            // managerTasks.jsp sends name="employeeUsername" for each checked box
            // admin forms may send name="assignedTo"
            String[] assignedToList = request.getParameterValues("employeeUsername");
            if (assignedToList == null || assignedToList.length == 0) {
                // fallback: try single-value admin param
                String single = request.getParameter("assignedTo");
                if (single != null && !single.isEmpty()) {
                    assignedToList = new String[]{ single };
                }
            }

            // Validate: must have at least one employee
            if (assignedToList == null || assignedToList.length == 0) {
                response.sendRedirect(request.getContextPath() + redirectUrl
                        + "?error=" + URLEncoder.encode("Please select at least one employee.", StandardCharsets.UTF_8));
                return;
            }

            // ── Read other form fields ──────────────────────────────────
            String title = request.getParameter("title");

            // managerTasks.jsp uses "taskDesc"; admin forms may use "description"
            String description = request.getParameter("taskDesc");
            if (description == null || description.isEmpty())
                description = request.getParameter("description");

            String deadline = request.getParameter("deadline");
            String priority = request.getParameter("priority");
            if (priority == null || priority.isEmpty()) priority = "MEDIUM";

            // Validate required fields
            if (title == null || title.isEmpty()) {
                response.sendRedirect(request.getContextPath() + redirectUrl
                        + "?error=" + URLEncoder.encode("Task title is required.", StandardCharsets.UTF_8));
                return;
            }

            // ── Read attachment ONCE — reused for every employee ────────
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

            // ── Loop: assign task to every selected employee ────────────
            String roleLabel = isAdmin ? "Admin" : "Manager";

            for (String assignedTo : assignedToList) {
                if (assignedTo == null || assignedTo.trim().isEmpty()) continue;

                // Insert one task row per employee
                TaskDAO.assignTask(
                    assignedTo.trim(),
                    assignerEmail,
                    title,
                    description,
                    deadlineDate,
                    priority,
                    attachmentName,
                    attachmentBytes
                );

                // Notify this employee individually
                String empMsg = "📋 New task assigned by " + roleLabel + " " + assignerName +
                                ": \"" + title + "\"" +
                                (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "") +
                                " | Priority: " + priority;

                NotificationService.notify(
                        assignedTo.trim(), assignerEmail,
                        NotificationService.TYPE_TASK, empMsg);

                if (isAdmin) {
                    // Admin assigned → notify the employee's manager too
                    NotificationService.notifyManagerOf(
                            assignedTo.trim(), assignerEmail,
                            NotificationService.TYPE_TASK,
                            "📋 Admin " + assignerName + " assigned task \"" + title +
                            "\" to " + assignedTo.trim());
                }
            }

            // Single admin notification summarising the bulk assign (manager only)
            if (!isAdmin) {
                NotificationService.notifyAllAdmins(
                        assignerEmail,
                        NotificationService.TYPE_TASK,
                        "📋 Manager " + assignerName + " assigned task \"" + title +
                        "\" to " + assignedToList.length + " employee(s)");
            }

            response.sendRedirect(request.getContextPath() + redirectUrl + "?success=TaskAssigned");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + redirectUrl
                    + "?error=" + URLEncoder.encode(
                            e.getMessage() != null ? e.getMessage() : "Unexpected error",
                            StandardCharsets.UTF_8));
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}