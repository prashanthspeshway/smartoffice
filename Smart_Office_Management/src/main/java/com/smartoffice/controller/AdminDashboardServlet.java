package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		try {

			List<User> employees = UserDao.getUsersByRole("employee");
			List<User> managers = UserDao.getUsersByRole("manager");
			List<User> users = UserDao.getAllUsers();
			List<Team> teams = TeamDAO.getAllTeams();

			request.setAttribute("employees", employees);
			request.setAttribute("managers", managers);
			request.setAttribute("users", users);
			request.setAttribute("teams", teams);


		} catch (Exception e) {
			e.printStackTrace();
		}

		request.getRequestDispatcher("admin.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}