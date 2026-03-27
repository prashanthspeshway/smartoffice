package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/managerMeetings")
public class ManagerMeetingsServlet extends HttpServlet {

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
			MeetingDao meetingDao = new MeetingDao();

			List<Meeting> todayMeetings = MeetingDao.getTodayMeetings(username);
			request.setAttribute("todayMeetings", todayMeetings);

			List<Meeting> allMeetings = meetingDao.getAllMeetingsForManager(username);
			request.setAttribute("allMeetings", allMeetings);

			List<User> employees = UserDao.getUsersByRole("employee");
			List<User> managers = UserDao.getUsersByRole("manager");
			List<User> users = UserDao.getAllUsers();
			List<Team> teams = TeamDAO.getAllTeams();

			request.setAttribute("employees", employees);
			request.setAttribute("managers", managers);
			request.setAttribute("users", users);
			request.setAttribute("teams", teams);

		} catch (Exception e) {
			throw new ServletException("Error loading meetings data", e);
		}

		request.getRequestDispatcher("managerMeetings.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}