package com.smartoffice.controller;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.sql.Date;

import com.smartoffice.dao.TaskDAO;

@SuppressWarnings("serial")
@WebServlet("/assignTask")
@MultipartConfig
public class AssignTaskServlet extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}
		
		String manager = (String) session.getAttribute("username");
		String employee = request.getParameter("employeeUsername");
		String title = request.getParameter("title");
		String desc = request.getParameter("taskDesc");
		String deadlineStr = request.getParameter("deadline");
		String priority = request.getParameter("priority");
		
		// Validation checks
		if (employee == null || employee.trim().isEmpty()) {
			// ✅ CHANGED: Redirect to managerTasks instead of manager servlet
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=SelectEmployee");
			return;
		}
		
		if (!TaskDAO.isEmployeeUnderManager(employee, manager)) {
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=InvalidEmployee");
			return;
		}
		
		if (title == null || title.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=EmptyTitle");
			return;
		}
		
		if (desc == null || desc.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=EmptyTask");
			return;
		}
		
		Date deadline = null;
		if (deadlineStr != null && !deadlineStr.trim().isEmpty()) {
			try {
				deadline = Date.valueOf(deadlineStr.trim());
			} catch (IllegalArgumentException ex) {
				response.sendRedirect(request.getContextPath() + "/managerTasks?error=InvalidDeadline");
				return;
			}
		}
		
		if (priority == null || priority.trim().isEmpty()) {
			priority = "MEDIUM";
		}
		
		// Handle file attachment
		String attachmentName = null;
		byte[] attachmentBytes = null;
		try {
			Part filePart = request.getPart("attachment");
			if (filePart != null && filePart.getSize() > 0) {
				String submittedFileName = filePart.getSubmittedFileName();
				if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
					attachmentName = submittedFileName.trim();
					try (InputStream is = filePart.getInputStream();
					     ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
						byte[] tmp = new byte[4096];
						int read;
						while ((read = is.read(tmp)) != -1) {
							buffer.write(tmp, 0, read);
						}
						attachmentBytes = buffer.toByteArray();
					}
				}
			}
		} catch (IllegalStateException ex) {
			// file too large or not multipart – ignore and continue without attachment
			attachmentName = null;
			attachmentBytes = null;
		}
		
		// Assign the task
		TaskDAO.assignTask(employee, manager, title.trim(), desc.trim(), deadline, priority.trim(), attachmentName, attachmentBytes);
		
		// ✅ CHANGED: Redirect to managerTasks instead of manager servlet
		response.sendRedirect(request.getContextPath() + "/managerTasks?success=true");
	}
}