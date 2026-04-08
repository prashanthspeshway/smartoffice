package com.smartoffice.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.io.InputStream;

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
		String assignerName = getDisplayName(session);
		String role = (String) session.getAttribute("role");
		boolean isAdmin = "admin".equalsIgnoreCase(role);
		String redirectUrl = isAdmin ? "/adminTasks" : "/managerTasks";

		try {
			String[] assignedToList = request.getParameterValues("employeeUsername");
			if (assignedToList == null || assignedToList.length == 0) {
				String single = request.getParameter("assignedTo");
				if (single != null && !single.isEmpty()) {
					assignedToList = new String[] { single };
				}
			}

			if (assignedToList == null || assignedToList.length == 0) {
				response.sendRedirect(request.getContextPath() + redirectUrl + "?error="
						+ URLEncoder.encode("Please select at least one employee.", StandardCharsets.UTF_8));
				return;
			}

			String title = request.getParameter("title");

			String description = request.getParameter("taskDesc");
			if (description == null || description.isEmpty())
				description = request.getParameter("description");

			String deadline = request.getParameter("deadline");
			String priority = request.getParameter("priority");
			if (priority == null || priority.isEmpty())
				priority = "MEDIUM";

			if (title == null || title.isEmpty()) {
				response.sendRedirect(request.getContextPath() + redirectUrl + "?error="
						+ URLEncoder.encode("Task title is required.", StandardCharsets.UTF_8));
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

			String roleLabel = isAdmin ? "Admin" : "Manager";

			for (String assignedTo : assignedToList) {
				if (assignedTo == null || assignedTo.trim().isEmpty())
					continue;

				TaskDAO.assignTask(assignedTo.trim(), assignerEmail, title, description, deadlineDate, priority,
						attachmentName, attachmentBytes);

				String empMsg = "📋 New task assigned by " + roleLabel + " " + assignerName + ": \"" + title + "\""
						+ (deadline != null && !deadline.isEmpty() ? ". Deadline: " + deadline : "") + " | Priority: "
						+ priority;

				NotificationService.notify(assignedTo.trim(), assignerEmail, NotificationService.TYPE_TASK, empMsg);

				if (isAdmin) {
					NotificationService.notifyManagerOf(assignedTo.trim(), assignerEmail, NotificationService.TYPE_TASK,
							"📋 Admin " + assignerName + " assigned task \"" + title + "\" to " + assignedTo.trim());
				}
			}

			if (!isAdmin) {
				NotificationService.notifyAllAdmins(assignerEmail, NotificationService.TYPE_TASK,
						"📋 Manager " + assignerName + " assigned task \"" + title + "\" to " + assignedToList.length
								+ " employee(s)");
			}

			response.sendRedirect(request.getContextPath() + redirectUrl + "?success=TaskAssigned");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + redirectUrl + "?error=" + URLEncoder
					.encode(e.getMessage() != null ? e.getMessage() : "Unexpected error", StandardCharsets.UTF_8));
		}
	}

	private String getDisplayName(HttpSession session) {
		String fn = (String) session.getAttribute("fullName");
		return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
	}
}