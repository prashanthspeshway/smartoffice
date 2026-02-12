package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.TaskDAO;

@SuppressWarnings("serial")
@WebServlet("/user")
public class UserDashboardServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("login.jsp");
			return;
		}
		
		TaskDAO.deleteOldCompletedTasks();

		String username = (String) session.getAttribute("username");

		try {
			// Attendance
			AttendanceDAO dao = new AttendanceDAO();
			ResultSet rs = dao.getTodayAttendance(username);
			if (rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			// Tasks
			request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));

			request.getRequestDispatcher("user.jsp").forward(request, response);

		} catch (Exception e) {
			throw new ServletException(e);
		}
	}
}
