package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.Team;

@SuppressWarnings("serial")
@WebServlet("/managerPerformance")
public class ManagerPerformanceServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		String role = (String) session.getAttribute("role");
		if (!"Manager".equalsIgnoreCase(role)) {
			response.sendRedirect("index.html?error=accessDenied");
			return;
		}

		String username = (String) session.getAttribute("username");

		try {
			// Get teams for performance matrix (3-step: Team → Member → Rate)
			List<Team> myTeams = TeamDAO.getTeamsByManager(username);
			request.setAttribute("myTeams", myTeams);

		} catch (Exception e) {
			throw new ServletException("Error loading performance data", e);
		}

		request.getRequestDispatcher("managerPerformance.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}