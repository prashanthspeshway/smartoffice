package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/manager")
public class ManagerDashboardServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("login.jsp");
			return;
		}
		
		TaskDAO.deleteOldCompletedTasks();

		String tab = request.getParameter("tab");
		if (tab == null || tab.isEmpty()) {
			tab = "none"; // blank right panel
		}
		request.setAttribute("tab", tab);

		String username = (String) session.getAttribute("username");

		try {
			AttendanceDAO attendanceDAO = new AttendanceDAO();

			ResultSet rs = attendanceDAO.getTodayAttendance(username);
			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

		} catch (Exception e) {
			throw new ServletException("Error loading manager dashboard", e);
		}

		request.getRequestDispatcher("manager.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
