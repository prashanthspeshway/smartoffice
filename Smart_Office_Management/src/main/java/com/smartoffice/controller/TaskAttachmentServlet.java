package com.smartoffice.controller;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@WebServlet("/taskAttachment")
@SuppressWarnings("serial")
public class TaskAttachmentServlet extends HttpServlet {

	private String resolveDbUsername(String emailOrUsername) {
		if (emailOrUsername == null || emailOrUsername.trim().isEmpty()) {
			return emailOrUsername;
		}
		String trimmed = emailOrUsername.trim();

		String sql = "SELECT username FROM users WHERE email = ? LIMIT 1";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, trimmed);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String dbUsername = rs.getString("username");
					if (dbUsername != null && !dbUsername.trim().isEmpty()) {
						return dbUsername.trim();
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return trimmed;
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		String username = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");

		String idParam = request.getParameter("id");
		if (idParam == null) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing task id");
			return;
		}

		int taskId;
		try {
			taskId = Integer.parseInt(idParam);
		} catch (NumberFormatException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task id");
			return;
		}

		String sql = "SELECT attachment, attachment_name, assigned_to, assigned_by FROM tasks WHERE id = ?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, taskId);
			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) {
					response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
					return;
				}

				byte[] data = rs.getBytes("attachment");
				String fileName = rs.getString("attachment_name");
				String assignedTo = rs.getString("assigned_to");
				String assignedBy = rs.getString("assigned_by");

				if (data == null || fileName == null || fileName.isEmpty()) {
					response.sendError(HttpServletResponse.SC_NOT_FOUND, "No attachment for this task");
					return;
				}

				boolean isAdmin = "admin".equalsIgnoreCase(role);
				String dbUsername = resolveDbUsername(username);

				boolean isOwner = username != null
						&& (username.equalsIgnoreCase(assignedTo) || username.equalsIgnoreCase(assignedBy)
								|| (dbUsername != null && (dbUsername.equalsIgnoreCase(assignedTo)
										|| dbUsername.equalsIgnoreCase(assignedBy))));

				if (!isAdmin && !isOwner) {
					response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not allowed to view this attachment");
					return;
				}

				response.setContentType("application/octet-stream");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
				response.setContentLength(data.length);

				try (OutputStream os = response.getOutputStream()) {
					os.write(data);
					os.flush();
				}
			}
		} catch (Exception e) {
			throw new ServletException("Unable to load attachment", e);
		}
	}
}
