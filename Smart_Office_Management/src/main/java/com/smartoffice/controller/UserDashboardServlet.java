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
import com.smartoffice.dao.NotificationReadsDAO;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.AttendanceLogEntry;
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
			User user = UserDao.getUserByEmail(username);
            request.setAttribute("user", user);
            String fn = user != null ? user.getFullname() : null;
            if (fn != null && !fn.isEmpty()) request.getSession().setAttribute("fullName", fn);
			/* ================= ATTENDANCE ================= */
			AttendanceDAO attendanceDAO = new AttendanceDAO();
			ResultSet rs = attendanceDAO.getTodayAttendance(username);

			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			/* ================= BREAK TIME ================= */
			request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
			request.setAttribute("breakLogs", BreakDAO.getTodayBreaks(username));
			request.setAttribute("onBreak", BreakDAO.isCurrentlyOnBreak(username));

			/* ================= RECENT ACTIVITY LOG ================= */
			List<AttendanceLogEntry> activityLog = attendanceDAO.getRecentAttendance(username, 30);
			for (AttendanceLogEntry e : activityLog) {
				e.setBreakSeconds(BreakDAO.getTotalSecondsForDate(username, e.getAttendanceDate()));
			}
			request.setAttribute("attendanceLog", activityLog);

			/* ================= TASKS ================= */
			TaskDAO.deleteOldCompletedTasks();
			request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));

			/* ================= LEAVES ================= */
			LeaveRequestDAO leaveDAO = new LeaveRequestDAO();
			List<LeaveRequest> myLeaves = leaveDAO.getLeavesByUsername(username);
			request.setAttribute("myLeaves", myLeaves);

			/* ================= MEETINGS ================= */
			List<Meeting> meetings = new ArrayList<>();

			// Updated query to fetch meetings where user is a participant
			// Joins with meeting_participants and users tables to get creator info
			String meetingSql = "SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time,\r\n"
					+ "       m.meeting_link, m.created_by, m.created_at,\r\n"
					+ "       CONCAT(u.firstname, ' ', u.lastname) AS creator_name,\r\n"
					+ "       u.role AS creator_role\r\n"
					+ "FROM meetings m\r\n"
					+ "LEFT JOIN meeting_participants mp ON m.id = mp.meeting_id\r\n"
					+ "LEFT JOIN users u ON m.created_by = u.email\r\n"
					+ "LEFT JOIN users emp ON emp.email = ?\r\n"
					+ "WHERE \r\n"
					+ "(\r\n"
					+ "    mp.user_email = ? \r\n"
					+ "    OR m.created_by = emp.manager_email\r\n"
					+ ")\r\n"
					+ "AND m.end_time >= NOW()\r\n"
					+ "ORDER BY m.start_time ASC;";

			try (Connection con = DBConnectionUtil.getConnection();
			        PreparedStatement ps = con.prepareStatement(meetingSql)) {

				ps.setString(1, username); // for emp.email
				ps.setString(2, username); // for participant
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
			        m.setCreatedAt(rsMeetings.getTimestamp("created_at"));
			        
			        // Set creator information
			        m.setCreatorName(rsMeetings.getString("creator_name"));
			        m.setCreatorRole(rsMeetings.getString("creator_role"));
			        
			        meetings.add(m);
			    }
			}

			request.setAttribute("meetings", meetings);

			/* ================= MY TEAMS (as member) ================= */
			request.setAttribute("myTeams", TeamDAO.getTeamsForMember(username));

			/* ================= NOTIFICATIONS ================= */
			NotificationReadsDAO nrDAO = new NotificationReadsDAO();
			List<Notification> notifications = nrDAO.getUnreadNotifications(username);
			request.setAttribute("notifications", notifications);

			/* ================= FORWARD ================= */
			request.getRequestDispatcher("user.jsp").forward(request, response);

		} catch (Exception e) {
			throw new ServletException("Error loading user dashboard", e);
		}
	}
}