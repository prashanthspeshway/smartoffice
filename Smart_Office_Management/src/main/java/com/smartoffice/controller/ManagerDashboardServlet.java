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
import com.smartoffice.dao.LeaveRequestDAO;
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

		String username = (String) session.getAttribute("username");

		// ✅ Read tab from URL
		String tab = request.getParameter("tab");
		if (tab == null || tab.isEmpty()) {
			tab = "selfAttendance"; // default
		}
		request.setAttribute("tab", tab);

		TaskDAO.deleteOldCompletedTasks();

		try {
			AttendanceDAO attendanceDAO = new AttendanceDAO();

			// ================= SELF ATTENDANCE =================
			ResultSet rs = attendanceDAO.getTodayAttendance(username);
			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			// ================= TEAM LIST (COMMON) =================
			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

			// ================= TEAM ATTENDANCE =================
			request.setAttribute("teamAttendance", attendanceDAO.getTeamAttendanceForToday(username));

			// ================= LEAVE REQUESTS =================
			LeaveRequestDAO leaveDao = new LeaveRequestDAO();
			request.setAttribute("leaveRequests", leaveDao.getTeamLeaveRequests(username));

			// ================= ASSIGN TASK / VIEW TASK =================
			if ("assignTask".equals(tab)) {

				String viewEmployee = request.getParameter("viewEmployee");
				String assignEmployee = request.getParameter("assignEmployee");

				if (viewEmployee != null && !viewEmployee.isEmpty()) {
					request.setAttribute("viewEmployee", viewEmployee);
					request.setAttribute("viewTasks", TaskDAO.getTasksAssignedByManager(username, viewEmployee));
				}

				if (assignEmployee != null && !assignEmployee.isEmpty()) {
					request.setAttribute("assignEmployee", assignEmployee);
					request.setAttribute("assignTasks", TaskDAO.getTasksAssignedByManager(username, assignEmployee));
				}
			}

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