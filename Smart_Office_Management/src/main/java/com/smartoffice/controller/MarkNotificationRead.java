package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.NotificationReadsDAO;

@SuppressWarnings("serial")
@WebServlet("/markNotificationRead")
public class MarkNotificationRead extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		int notificationId = Integer.parseInt(req.getParameter("id"));
		String sessionValue = (String) session.getAttribute("username");

		try {
			NotificationReadsDAO nrDAO = new NotificationReadsDAO();
			nrDAO.markAsRead(notificationId, sessionValue);
			res.setStatus(HttpServletResponse.SC_OK);
		} catch (Exception e) {
			e.printStackTrace();
			res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}