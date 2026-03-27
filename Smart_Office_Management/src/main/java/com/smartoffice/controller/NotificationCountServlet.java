package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.NotificationReadsDAO;

@WebServlet("/notificationCount")
@SuppressWarnings("serial")
public class NotificationCountServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		response.setContentType("application/json;charset=UTF-8");
		response.setHeader("Cache-Control", "no-store");

		if (session == null || session.getAttribute("username") == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			try (PrintWriter w = response.getWriter()) {
				w.write("{\"count\":0}");
			}
			return;
		}

		String email = (String) session.getAttribute("username");
		int count = 0;
		try {
			count = new NotificationReadsDAO().getUnreadCount(email);
		} catch (Exception e) {

		}

		try (PrintWriter w = response.getWriter()) {
			w.write("{\"count\":" + count + "}");
		}
	}
}
