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
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.LeaveRequest;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Notification;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/user")
public class UserDashboardServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		String username = (String) session.getAttribute("username");

		try {
             //USER PROFILe
			User user = UserDao.getUserByUsername(username);
            request.setAttribute("user", user);
			/* ================= ATTENDANCE ================= */
			AttendanceDAO attendanceDAO = new AttendanceDAO();
			ResultSet rs = attendanceDAO.getTodayAttendance(username);

			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			/* ================= TASKS ================= */
			TaskDAO.deleteOldCompletedTasks();
			request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));

			/* ================= LEAVES ================= */
			LeaveRequestDAO leaveDAO = new LeaveRequestDAO();
			List<LeaveRequest> myLeaves = leaveDAO.getLeavesByUsername(username);
			request.setAttribute("myLeaves", myLeaves);

			/* ================= MEETINGS ================= */
			List<Meeting> meetings = new ArrayList<>();

			String meetingSql = """
					    SELECT *
					    FROM meetings
					    WHERE created_by = (
					        SELECT manager FROM users WHERE username = ?
					    )
					    AND start_time >= NOW()
					    ORDER BY start_time
					""";

			try (Connection con = DBConnectionUtil.getConnection();
					PreparedStatement ps = con.prepareStatement(meetingSql)) {

				ps.setString(1, username);
				ResultSet rsMeetings = ps.executeQuery();

				while (rsMeetings.next()) {
					Meeting m = new Meeting();
					m.setId(rsMeetings.getInt("id"));
					m.setTitle(rsMeetings.getString("title"));
					m.setDescription(rsMeetings.getString("description"));
					m.setStartTime(rsMeetings.getTimestamp("start_time"));
					m.setEndTime(rsMeetings.getTimestamp("end_time"));
					m.setMeetingLink(rsMeetings.getString("meeting_link"));
					m.setCreatedBy(rsMeetings.getString("created_by"));
					meetings.add(m);
				}
			}

			request.setAttribute("meetings", meetings);

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

				ps.setString(1, username); // ⭐ IMPORTANT
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

			/* ================= FORWARD ================= */
			request.getRequestDispatcher("user.jsp").forward(request, response);

		} catch (Exception e) {
			throw new ServletException("Error loading user dashboard", e);
		}
	}
}