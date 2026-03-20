package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Task;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/managerTasks")
public class ManagerTasksServlet extends HttpServlet {

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
			// Delete old completed tasks
			TaskDAO.deleteOldCompletedTasks();

			// Get team members
			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

			// Handle view tasks request
			String viewEmployee = request.getParameter("viewEmployee");
			if (viewEmployee != null && !viewEmployee.isEmpty()) {
				request.setAttribute("viewEmployee", viewEmployee);
				List<Task> viewTasks = TaskDAO.getTasksAssignedByManager(username, viewEmployee);
				request.setAttribute("viewTasks", viewTasks);
			}

			// Handle assign employee selection
			String assignEmployee = request.getParameter("assignEmployee");
			if (assignEmployee != null && !assignEmployee.isEmpty()) {
				request.setAttribute("assignEmployee", assignEmployee);
			}

		} catch (Exception e) {
			throw new ServletException("Error loading tasks data", e);
		}

		request.getRequestDispatcher("managerTasks.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}