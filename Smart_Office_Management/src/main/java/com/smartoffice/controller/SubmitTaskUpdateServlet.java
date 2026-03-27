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

		String employeeEmail = (String) session.getAttribute("username");
		String employeeName = getDisplayName(session);

		try {
			int taskId = Integer.parseInt(request.getParameter("taskId"));
			String comment = request.getParameter("comment");

			Task task = TaskDAO.getTaskById(taskId);
			if (task == null) {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
				return;
			}
			if (!TaskDAO.taskBelongsToAssignee(task, employeeEmail)) {
				response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not your task");
				return;
			}

			Part filePart = null;
			try {
				filePart = request.getPart("employeeFile");
			} catch (Exception ignore) {
			}

			TaskDAO.submitEmployeeTaskRequest(taskId, comment, filePart);

			if (task != null) {

				String assignedByRaw = task.getAssignedBy();
				String assignedByEmail = resolveToEmail(assignedByRaw);

				String taskTitle = task.getTitle() != null ? task.getTitle() : task.getDescription();

				String msg = "📨 " + employeeName + " submitted a request for task \"" + taskTitle + "\""
						+ (comment != null && !comment.isEmpty() ? ". Comment: " + comment : "");

				if (assignedByEmail != null && !assignedByEmail.isEmpty()
						&& !assignedByEmail.equalsIgnoreCase(employeeEmail)) {
					NotificationService.notify(assignedByEmail, employeeEmail, NotificationService.TYPE_TASK, msg);
				}

				String assignerRole = getRoleOf(assignedByEmail);
				if ("admin".equalsIgnoreCase(assignerRole)) {
					NotificationService.notifyManagerOf(employeeEmail, employeeEmail, NotificationService.TYPE_TASK,
							msg);
				}

				NotificationService.notifyAllAdmins(employeeEmail, NotificationService.TYPE_TASK, msg);
			}
			// ─────────────────────────────────────────────────────────

			response.setStatus(HttpServletResponse.SC_OK);

		} catch (IllegalStateException | IllegalArgumentException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Task update failed: " + e.getMessage());
		}
	}

	private String resolveToEmail(String usernameOrEmail) {
		if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty())
			return null;
		String val = usernameOrEmail.trim();
		if (val.contains("@"))
			return val;

		try {
			User user = UserDao.getUserByUsername(val);
			if (user != null && user.getEmail() != null)
				return user.getEmail();
		} catch (Exception e) {
			System.err.println("[SubmitTaskUpdateServlet] resolveToEmail error for '" + val + "': " + e.getMessage());
		}
		return val;
	}

	private String getRoleOf(String email) {
		if (email == null || email.isEmpty())
			return null;
		try {
			User user = UserDao.getUserByEmail(email);
			return user != null ? user.getRole() : null;
		} catch (Exception e) {
			System.err.println("[SubmitTaskUpdateServlet] getRoleOf error for '" + email + "': " + e.getMessage());
		}
		return null;
	}

	private String getDisplayName(HttpSession session) {
		String fn = (String) session.getAttribute("fullName");
		return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
	}
}