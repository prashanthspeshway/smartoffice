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
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.model.TeamAttendance;

@SuppressWarnings("serial")
@WebServlet("/managerAttendance")
public class ManagerAttendanceServlet extends HttpServlet {

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
			AttendanceDAO attendanceDAO = new AttendanceDAO();

			// Self Attendance
			ResultSet rs = attendanceDAO.getTodayAttendance(username);
			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			// Break Time
			request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
			request.setAttribute("breakLogs", BreakDAO.getTodayBreaks(username));
			request.setAttribute("onBreak", BreakDAO.isCurrentlyOnBreak(username));

			// Team Attendance
			List<TeamAttendance> teamAttendance = attendanceDAO.getTeamAttendanceForToday(username);
			request.setAttribute("teamAttendance", teamAttendance);

		} catch (Exception e) {
			throw new ServletException("Error loading attendance data", e);
		}

		request.getRequestDispatcher("managerAttendance.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}