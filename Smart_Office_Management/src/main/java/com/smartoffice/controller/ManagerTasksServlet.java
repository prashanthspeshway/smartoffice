package com.smartoffice.controller;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
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

		String managerEmail = (String) session.getAttribute("username");

		try {
			List<User> teamList = UserDao.getUsersByManager(managerEmail);
			request.setAttribute("teamList", teamList);

			List<Task> allManagerTasks = TaskDAO.getAllTasksAssignedByManager(managerEmail);

			if (allManagerTasks == null || allManagerTasks.isEmpty()) {
				String fullName = (String) session.getAttribute("fullName");
				if (fullName != null && !fullName.trim().isEmpty()) {
					List<Task> byName = TaskDAO.getAllTasksAssignedByManager(fullName.trim());
					if (byName != null && !byName.isEmpty()) {
						allManagerTasks = byName;
					}
				}
			}

			if (allManagerTasks == null)
				allManagerTasks = new ArrayList<>();
			request.setAttribute("allManagerTasks", allManagerTasks);

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

		String action = request.getParameter("action");
		String managerEmail = (String) session.getAttribute("username");
		String managerName = getDisplayName(session);

		try {

			// ── ASSIGN TASK ────────────────────────────────────────────
			if ("assign".equals(action)) {
				String[] assignedToList = request.getParameterValues("employeeUsername");
				String title = request.getParameter("title");
				String description = request.getParameter("taskDesc");
				String deadline = request.getParameter("deadline");
				String priority = request.getParameter("priority");
				if (priority == null || priority.isEmpty())
					priority = "MEDIUM";

				if (assignedToList == null || assignedToList.length == 0) {
					response.sendRedirect(request.getContextPath() + "/managerTasks?error="
							+ URLEncoder.encode("Please select at least one employee.", StandardCharsets.UTF_8));
					return;
				}
				if (title == null || title.trim().isEmpty()) {
					response.sendRedirect(request.getContextPath() + "/managerTasks?error="
							+ URLEncoder.encode("Task title is required.", StandardCharsets.UTF_8));
					return;
				}
				if (description == null || description.trim().isEmpty()) {
					response.sendRedirect(request.getContextPath() + "/managerTasks?error="
							+ URLEncoder.encode("Task description is required.", StandardCharsets.UTF_8));
					return;
				}

				String attachmentName = null;
				byte[] attachmentBytes = null;
				Part filePart = null;
				try {
					filePart = request.getPart("attachment");
					if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null
							&& !filePart.getSubmittedFileName().isEmpty()) {
						attachmentName = filePart.getSubmittedFileName();
						try (InputStream in = filePart.getInputStream()) {
							attachmentBytes = in.readAllBytes();
						}
					}
				} catch (Exception ignore) {
				} finally {
					// Important on Windows: release the temp upload file immediately.
					if (filePart != null) {
						try {
							filePart.delete();
						} catch (Exception ignored) {
						}
					}
				}

				java.sql.Date deadlineDate = null;
				if (deadline != null && !deadline.isEmpty()) {
					try {
						deadlineDate = java.sql.Date.valueOf(deadline);
					} catch (Exception ignore) {
					}
				}
				if (deadlineDate != null && deadlineDate.toLocalDate().isBefore(LocalDate.now())) {
					response.sendRedirect(request.getContextPath() + "/managerTasks?error="
							+ URLEncoder.encode("Deadline cannot be in the past.", StandardCharsets.UTF_8));
					return;
				}

				for (String assignedTo : assignedToList) {
					if (assignedTo == null || assignedTo.trim().isEmpty())
						continue;
					TaskDAO.assignTask(assignedTo.trim(), managerEmail, title.trim(), description.trim(), deadlineDate,
							priority, attachmentName, attachmentBytes);

					String empMsg = "New task from Manager " + managerName + ": \"" + title + "\""
							+ (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "")
							+ " | Priority: " + priority;
					NotificationService.notify(assignedTo.trim(), managerEmail, NotificationService.TYPE_TASK, empMsg);
				}

				NotificationService.notifyAllAdmins(managerEmail, NotificationService.TYPE_TASK,
						"Manager " + managerName + " assigned task \"" + title + "\" to " + assignedToList.length
								+ " employee(s)");

				response.sendRedirect(request.getContextPath() + "/managerTasks?success=Task+assigned+to+"
						+ assignedToList.length + "+employee(s)");
				return;
			}

			// ── DELETE TASK ────────────────────────────────────────────
			if ("delete".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("taskId"));
				TaskDAO.deleteTask(taskId);
				response.sendRedirect(request.getContextPath() + "/managerTasks?success=Task+deleted");
				return;
			}

			// ── UPDATE STATUS ──────────────────────────────────────────
			if ("updateStatus".equals(action)) {
				int taskId = Integer.parseInt(request.getParameter("taskId"));
				String decision = request.getParameter("decision");
				String ctx = request.getContextPath();

				Task task = TaskDAO.getTaskById(taskId);
				if (task == null || !TaskDAO.taskAssignedByManager(task, managerEmail)) {
					response.sendRedirect(
							ctx + "/managerTasks?error=" + URLEncoder.encode("Invalid task", StandardCharsets.UTF_8));
					return;
				}

				String st = task.getStatus() != null ? task.getStatus().trim() : "";
				boolean processing = "PROCESSING".equalsIgnoreCase(st) || "SUBMITTED".equalsIgnoreCase(st);

				if ("review".equalsIgnoreCase(decision)) {
					if (!processing) {
						response.sendRedirect(ctx + "/managerTasks?error=" + URLEncoder
								.encode("Review is only for tasks awaiting your review.", StandardCharsets.UTF_8));
						return;
					}
					TaskDAO.returnTaskForReview(taskId);
					String assigneeEmail = resolveAssigneeEmail(task);
					if (assigneeEmail != null) {
						String t2 = task.getTitle() != null ? task.getTitle() : task.getDescription();
						NotificationService.notify(assigneeEmail, managerEmail, NotificationService.TYPE_TASK,
								"Manager " + managerName + " returned task \"" + t2
										+ "\" — please update and resubmit.");
					}
					response.sendRedirect(ctx + "/managerTasks?taskFlash=review");
					return;
				}

				if ("completed".equalsIgnoreCase(decision)) {
					if ("COMPLETED".equalsIgnoreCase(st)) {
						response.sendRedirect(ctx + "/managerTasks?taskFlash=alreadyCompleted");
						return;
					}
					TaskDAO.markCompleted(taskId);
					String assigneeEmail = resolveAssigneeEmail(task);
					if (assigneeEmail != null) {
						String t2 = task.getTitle() != null ? task.getTitle() : task.getDescription();
						NotificationService.notify(assigneeEmail, managerEmail, NotificationService.TYPE_TASK,
								"Manager " + managerName + " marked task \"" + t2 + "\" as completed.");
					}
					response.sendRedirect(ctx + "/managerTasks?taskFlash=completed");
					return;
				}

				response.sendRedirect(ctx + "/managerTasks?error="
						+ URLEncoder.encode("Choose an action (Return / Completed).", StandardCharsets.UTF_8));
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=" + URLEncoder
					.encode(e.getMessage() != null ? e.getMessage() : "Unexpected error", StandardCharsets.UTF_8));
			return;
		}

		doGet(request, response);
	}

	// Helpers
	private String getDisplayName(HttpSession session) {
		String fn = (String) session.getAttribute("fullName");
		return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
	}

	private static String resolveAssigneeEmail(Task task) {
		if (task == null)
			return null;
		String u = task.getAssignedTo();
		if (u == null || u.trim().isEmpty())
			return null;
		u = u.trim();
		if (u.contains("@"))
			return u;
		try {
			User user = UserDao.getUserByUsername(u);
			if (user != null && user.getEmail() != null)
				return user.getEmail();
		} catch (Exception e) {
			System.err.println("[ManagerTasksServlet] resolveAssigneeEmail: " + e.getMessage());
		}
		return u;
	}
}