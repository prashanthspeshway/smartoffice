package com.smartoffice.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/managerTasks")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class ManagerTasksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }
        if (!"Manager".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("index.html?error=accessDenied");
            return;
        }

        String username = (String) session.getAttribute("username");
        try {
            TaskDAO.deleteOldCompletedTasks();
            List<User> teamList = UserDao.getUsersByManager(username);
            request.setAttribute("teamList", teamList);

            String viewEmployee = request.getParameter("viewEmployee");
            if (viewEmployee != null && !viewEmployee.isEmpty()) {
                request.setAttribute("viewEmployee", viewEmployee);
                request.setAttribute("viewTasks",
                        TaskDAO.getTasksAssignedByManager(username, viewEmployee));
            }

            String assignEmployee = request.getParameter("assignEmployee");
            if (assignEmployee != null && !assignEmployee.isEmpty()) {
                request.setAttribute("assignEmployee", assignEmployee);
            }
        } catch (Exception e) {
            throw new ServletException("Error loading tasks data", e);
        }
        request.getRequestDispatcher("managerTasks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }
        if (!"Manager".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("index.html?error=accessDenied");
            return;
        }

        String action        = request.getParameter("action");
        String managerEmail  = (String) session.getAttribute("username");
        String managerName   = getDisplayName(session);

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
                    managerEmail,
                    title,
                    description,
                    deadlineDate,
                    priority,
                    attachmentName,
                    attachmentBytes
                );

                // ── NOTIFICATION: Notify the assigned employee ────────
                String empMsg = "📋 New task from Manager " + managerName +
                                ": \"" + title + "\"" +
                                (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "") +
                                (priority != null && !priority.isEmpty() ? " | Priority: " + priority : "");

                NotificationService.notify(assignedTo, managerEmail,
                        NotificationService.TYPE_TASK, empMsg);

                // Notify all admins about the assignment
                NotificationService.notifyAllAdmins(managerEmail,
                        NotificationService.TYPE_TASK,
                        "📋 Manager " + managerName + " assigned task \"" + title +
                        "\" to " + assignedTo);
                // ─────────────────────────────────────────────────────

                response.sendRedirect(request.getContextPath() + "/managerTasks?success=Task assigned");
                return;
            }

            if ("delete".equals(action)) {
                int taskId = Integer.parseInt(request.getParameter("taskId"));
                TaskDAO.deleteTask(taskId);
                response.sendRedirect(request.getContextPath() + "/managerTasks?success=Task deleted");
                return;
            }

            if ("updateStatus".equals(action)) {
                int taskId = Integer.parseInt(request.getParameter("taskId"));
                String decision = request.getParameter("decision");
                String viewEmployee = request.getParameter("viewEmployee");
                String ctx = request.getContextPath();
                String veParam = (viewEmployee != null && !viewEmployee.isEmpty())
                        ? "&viewEmployee=" + URLEncoder.encode(viewEmployee, StandardCharsets.UTF_8)
                        : "";

                Task task = TaskDAO.getTaskById(taskId);
                if (task == null || !TaskDAO.taskAssignedByManager(task, managerEmail)) {
                    response.sendRedirect(ctx + "/managerTasks?error=" + URLEncoder.encode("Invalid task", StandardCharsets.UTF_8) + veParam);
                    return;
                }

                String st = task.getStatus() != null ? task.getStatus().trim() : "";
                boolean processing = "PROCESSING".equalsIgnoreCase(st) || "SUBMITTED".equalsIgnoreCase(st);

                if ("review".equalsIgnoreCase(decision)) {
                    if (!processing) {
                        response.sendRedirect(ctx + "/managerTasks?error=" + URLEncoder.encode("Review is only for tasks awaiting your review", StandardCharsets.UTF_8) + veParam);
                        return;
                    }
                    TaskDAO.returnTaskForReview(taskId);
                    String assigneeEmail = resolveAssigneeEmail(task);
                    if (assigneeEmail != null) {
                        String title = task.getTitle() != null ? task.getTitle() : task.getDescription();
                        NotificationService.notify(assigneeEmail, managerEmail, NotificationService.TYPE_TASK,
                                "↩️ Manager " + managerName + " returned task \"" + title + "\" for you to update and resubmit.");
                    }
                    response.sendRedirect(ctx + "/managerTasks?taskFlash=review" + veParam);
                    return;
                }

                if ("completed".equalsIgnoreCase(decision)) {
                    if ("COMPLETED".equalsIgnoreCase(st)) {
                        response.sendRedirect(ctx + "/managerTasks?taskFlash=alreadyCompleted" + veParam);
                        return;
                    }
                    TaskDAO.markCompleted(taskId);
                    String assigneeEmail = resolveAssigneeEmail(task);
                    if (assigneeEmail != null) {
                        String title = task.getTitle() != null ? task.getTitle() : task.getDescription();
                        NotificationService.notify(assigneeEmail, managerEmail, NotificationService.TYPE_TASK,
                                "✅ Manager " + managerName + " marked task \"" + title + "\" as completed.");
                    }
                    response.sendRedirect(ctx + "/managerTasks?taskFlash=completed" + veParam);
                    return;
                }

                response.sendRedirect(ctx + "/managerTasks?error=" + URLEncoder.encode("Choose Review or Completed", StandardCharsets.UTF_8) + veParam);
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/managerTasks?error=" + e.getMessage());
        }

        doGet(request, response);
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }

    private static String resolveAssigneeEmail(Task task) {
        if (task == null) {
            return null;
        }
        String u = task.getAssignedTo();
        if (u == null || u.trim().isEmpty()) {
            return null;
        }
        u = u.trim();
        if (u.contains("@")) {
            return u;
        }
        try {
            User user = UserDao.getUserByUsername(u);
            if (user != null && user.getEmail() != null) {
                return user.getEmail();
            }
        } catch (Exception e) {
            System.err.println("[ManagerTasksServlet] resolveAssigneeEmail: " + e.getMessage());
        }
        return u;
    }
}