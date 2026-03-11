package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/selfProfile")
public class SelfProfileServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// Get existing session (do NOT create new one)
		HttpSession session = request.getSession(false);

		if (session == null) {
			response.sendRedirect("index.html");
			return;
		}

		String username = (String) session.getAttribute("username");

		if (username == null) {
			response.sendRedirect("index.html");
			return;
		}

		// Fetch logged-in user details
		User user = UserDao.getUserByEmail(username);

		if (user == null) {
			request.setAttribute("error", "User details not found");
		}

		request.setAttribute("user", user);
		request.getRequestDispatcher("selfProfile.jsp").forward(request, response);
	}
}