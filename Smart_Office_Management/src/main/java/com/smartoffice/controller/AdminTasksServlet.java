package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

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
@WebServlet("/adminTasks")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10 MB
public class AdminTasksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        if (!"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        try {
            List<Task> tasks = TaskDAO.getAllTasks();
            request.setAttribute("tasks", tasks);
        } catch (Exception e) {
            throw new ServletException("Unable to load tasks", e);
        }
        request.getRequestDispatcher("adminTasks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        String action     = request.getParameter("action");
        String adminEmail = (String) session.getAttribute("username");
        String adminName  = getDisplayName(session);

        try {
            if ("assign".equals(action)) {
                String assignedTo  = request.getParameter("assignedTo");
                String title       = request.getParameter("title");
                String description = request.getParameter("description");
                String deadline    = request.getParameter("deadline");
                String priority    = request.getParameter("priority");

                // Handle optional file attachment
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
                    deadlineDate = java.sql.Date.valueOf(deadline);
                }

                // Use the existing TaskDAO.assignTask signature exactly
                TaskDAO.assignTask(
                    assignedTo,
                    adminEmail,
                    title,
                    description,
                    deadlineDate,
                    priority,
                    attachmentName,
                    attachmentBytes
                );

                // ── NOTIFICATION: Notify the assigned employee ────────
                String msg = "📋 New task assigned by Admin " + adminName +
                             ": \"" + title + "\"" +
                             (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "") +
                             (priority != null && !priority.isEmpty() ? " | Priority: " + priority : "");

                NotificationService.notify(assignedTo, adminEmail,
                        NotificationService.TYPE_TASK, msg);

                // Also notify the employee's direct manager
                NotificationService.notifyManagerOf(assignedTo, adminEmail,
                        NotificationService.TYPE_TASK,
                        "📋 Admin " + adminName + " assigned task \"" + title +
                        "\" to " + assignedTo);
                // ─────────────────────────────────────────────────────

                response.sendRedirect(request.getContextPath() + "/adminTasks?success=Task assigned");
                return;
            }

            if ("delete".equals(action)) {
                int taskId = Integer.parseInt(request.getParameter("taskId"));
                TaskDAO.deleteTask(taskId);
                response.sendRedirect(request.getContextPath() + "/adminTasks?success=Task deleted");
                return;
            }

            if ("updateStatus".equals(action)) {
                int taskId    = Integer.parseInt(request.getParameter("taskId"));
                String status = request.getParameter("status");
                TaskDAO.updateStatus(taskId, status);
                response.sendRedirect(request.getContextPath() + "/adminTasks?success=Status updated");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/adminTasks?error=" + e.getMessage());
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}