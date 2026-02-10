package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.AttendanceDAO;
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

		String username = (String) session.getAttribute("username");

		AttendanceDAO attendanceDAO = new AttendanceDAO();
		ResultSet rs = null;

		try {
			// ===== Attendance =====
			rs = attendanceDAO.getTodayAttendance(username);
			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			// ===== Team =====
			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

		} catch (Exception e) {
			throw new ServletException("Error loading manager dashboard", e);

		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException ignored) {
				}
			}
		}

		request.getRequestDispatcher("manager.jsp").forward(request, response);
	}

	// ✅ Prevent 405 errors
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
