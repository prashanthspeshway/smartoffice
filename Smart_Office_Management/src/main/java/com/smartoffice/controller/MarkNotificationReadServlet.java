package com.smartoffice.controller;

import com.smartoffice.dao.NotificationReadsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/markNotificationRead")
public class MarkNotificationReadServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private NotificationReadsDAO dao;

	@Override
	public void init() throws ServletException {
		dao = new NotificationReadsDAO();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("text/plain;charset=UTF-8");

		HttpSession session = request.getSession(false);

		if (session == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			response.getWriter().write("Session expired");
			return;
		}

		String email = (String) session.getAttribute("username");

		if (email == null || email.trim().isEmpty()) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			response.getWriter().write("User not logged in");
			return;
		}

		String idParam = request.getParameter("id");

		if (idParam == null || idParam.trim().isEmpty()) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.getWriter().write("Notification id required");
			return;
		}

		try {

			if ("all".equalsIgnoreCase(idParam)) {

				dao.markAllAsRead(email);

			} else {

				int notificationId = Integer.parseInt(idParam);

				dao.markAsRead(notificationId, email);

			}

			response.setStatus(HttpServletResponse.SC_OK);
			response.getWriter().write("Notification marked as read");

		} catch (NumberFormatException e) {

			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.getWriter().write("Invalid notification id");

		} catch (Exception e) {

			e.printStackTrace();

			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			response.getWriter().write("Server error");

		}
	}
}