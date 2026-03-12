package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.NotificationReadsDAO;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Notification;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/manager")
public class ManagerDashboardServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		String username = (String) session.getAttribute("username");

		// ================= TAB HANDLING =================
		String tab = request.getParameter("tab");
		if (tab == null || tab.isEmpty()) {
			tab = "attendance";
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

			// ================= BREAK TIME =================
			request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
			request.setAttribute("breakLogs", BreakDAO.getTodayBreaks(username));

			// ================= TODAY MEETINGS =================
			List<Meeting> todayMeetings = MeetingDao.getTodayMeetings(username);
			request.setAttribute("todayMeetings", todayMeetings);

			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

			// ================= TEAM ATTENDANCE =================
			request.setAttribute("teamAttendance", attendanceDAO.getTeamAttendanceForToday(username));

			// ================= LEAVE (manager's own leaves - apply to admin) =================
			LeaveRequestDAO leaveDao = new LeaveRequestDAO();
			request.setAttribute("myLeaves", leaveDao.getLeavesByUsername(username));

			// ================= TEAMS (assigned to this manager) =================
			List<Team> myTeams = TeamDAO.getTeamsByManager(username);
			request.setAttribute("myTeams", myTeams);

			// ================= ASSIGN / VIEW TASK =================
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
			// ================= SELF PROFILE =================
			User user = UserDao.getUserByEmail(username);
			request.setAttribute("user", user);
			String fn = user != null ? user.getFullname() : null;
			if (fn != null && !fn.isEmpty()) request.getSession().setAttribute("fullName", fn);


			/* ================= NOTIFICATIONS ================= */
			NotificationReadsDAO nrDAO = new NotificationReadsDAO();
			List<Notification> notifications = nrDAO.getUnreadNotifications(username);
			request.setAttribute("notifications", notifications);

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