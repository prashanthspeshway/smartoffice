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
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Notification;
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
			response.sendRedirect("login.jsp");
			return;
		}

		String username = (String) session.getAttribute("username");

		// ================= TAB HANDLING =================
		String tab = request.getParameter("tab");
		if (tab == null || tab.isEmpty()) {
			tab = "selfAttendance";
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

			// ================= TODAY MEETINGS =================
			List<Meeting> todayMeetings = MeetingDao.getTodayMeetings(username);
			request.setAttribute("todayMeetings", todayMeetings);

			List<User> teamList = UserDao.getUsersByManager(username);
			request.setAttribute("teamList", teamList);

			// ================= TEAM ATTENDANCE =================
			request.setAttribute("teamAttendance", attendanceDAO.getTeamAttendanceForToday(username));

			// ================= LEAVE REQUESTS =================
			LeaveRequestDAO leaveDao = new LeaveRequestDAO();
			request.setAttribute("leaveRequests", leaveDao.getTeamLeaveRequests(username));

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
			User user = UserDao.getUserByUsername(username);
			request.setAttribute("user", user);


			/* ================= NOTIFICATIONS ================= */
			List<Notification> notifications = new ArrayList<>();

			String notificationSql = """
					    SELECT n.*
					    FROM notifications n
					    WHERE NOT EXISTS (
					        SELECT 1
					        FROM notification_reads nr
					        WHERE nr.notification_id = n.id
					        AND nr.username = ?
					    )
					    ORDER BY n.created_at DESC
					""";

			try (Connection con = DBConnectionUtil.getConnection();
					PreparedStatement ps = con.prepareStatement(notificationSql)) {

				ps.setString(1, username); // ⭐ manager username
				ResultSet rsNotif = ps.executeQuery();

				while (rsNotif.next()) {
					Notification n = new Notification();
					n.setId(rsNotif.getInt("id"));
					n.setMessage(rsNotif.getString("message"));
					n.setCreatedBy(rsNotif.getString("created_by"));
					n.setCreatedAt(rsNotif.getTimestamp("created_at"));
					notifications.add(n);
				}
			}

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