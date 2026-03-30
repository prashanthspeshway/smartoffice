package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import com.smartoffice.model.Task;
import com.smartoffice.model.User;
import com.smartoffice.utils.AuthRedirectUtil;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet({ "/user", "/userOverview", "/userAttendance", "/userTasks", "/userTeam", "/userLeave", "/userMeetings",
		"/userSettings", "/userNotifications" })
public class UserDashboardServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			AuthRedirectUtil.sendTopWindowRedirect(request, response, "/index.html");
			return;
		}

		String username = (String) session.getAttribute("username");
		String path = request.getServletPath(); // e.g. "/userAttendance"

		try {
			User user = UserDao.getUserByEmail(username);
			request.setAttribute("user", user);
			String fn = user != null ? user.getFullname() : null;
			if (fn != null && !fn.isEmpty())
				session.setAttribute("fullName", fn);

			if ("/user".equals(path)) {
				loadAll(request, username);
				request.getRequestDispatcher("user.jsp").forward(request, response);
				return;
			}

			switch (path) {
			case "/userOverview":
				loadAttendance(request, username);
				loadOverviewStats(request, username);
				request.getRequestDispatcher("userOverview.jsp").forward(request, response);
				break;

			case "/userAttendance":
				loadAttendance(request, username);
				request.getRequestDispatcher("userAttendance.jsp").forward(request, response);
				break;
				
			case "/userTasks":
			    request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));
			    request.getRequestDispatcher("userTasks.jsp").forward(request, response);
			    break;

			case "/userTeam":
				request.setAttribute("myTeams", TeamDAO.getTeamsForMember(username));
				request.getRequestDispatcher("userTeam.jsp").forward(request, response);
				break;

			case "/userLeave":
				request.setAttribute("myLeaves", new LeaveRequestDAO().getLeavesByUsername(username));
				request.getRequestDispatcher("userLeave.jsp").forward(request, response);
				break;

			case "/userMeetings":
				request.setAttribute("meetings", loadMeetings(username));
				request.getRequestDispatcher("userMeetings.jsp").forward(request, response);
				break;

			case "/userSettings":
				request.getRequestDispatcher("userSettings.jsp").forward(request, response);
				break;

			case "/userNotifications":
				request.setAttribute("notifications", new NotificationReadsDAO().getUnreadNotifications(username));
				request.getRequestDispatcher("userNotifications.jsp").forward(request, response);
				break;

			default:
				response.sendRedirect(request.getContextPath() + "/userOverview");
			}

		} catch (Exception e) {
			throw new ServletException("Error loading user dashboard", e);
		}
	}

	private void loadAll(HttpServletRequest request, String username) throws Exception {
		loadAttendance(request, username);
		request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));
		request.setAttribute("myLeaves", new LeaveRequestDAO().getLeavesByUsername(username));
		request.setAttribute("meetings", loadMeetings(username));
		request.setAttribute("myTeams", TeamDAO.getTeamsForMember(username));
		request.setAttribute("notifications", new NotificationReadsDAO().getUnreadNotifications(username));
	}

	private void loadAttendance(HttpServletRequest request, String username) throws Exception {
		AttendanceDAO attendanceDAO = new AttendanceDAO();
		ResultSet rs = attendanceDAO.getTodayAttendance(username);
		if (rs != null && rs.next()) {
			request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
			request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
		}
		request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
		request.setAttribute("breakLogs", BreakDAO.getTodayBreaks(username));
		request.setAttribute("onBreak", BreakDAO.isCurrentlyOnBreak(username));

		List<AttendanceLogEntry> log = attendanceDAO.getRecentAttendance(username, 30);
		for (AttendanceLogEntry e : log) {
			e.setBreakSeconds(BreakDAO.getTotalSecondsForDate(username, e.getAttendanceDate()));
		}
		request.setAttribute("attendanceLog", log);
	}

	private void loadOverviewStats(HttpServletRequest request, String username) throws Exception {
		java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

		List<Task> tasks = TaskDAO.getTasksForEmployee(username);
		int taskAssigned = 0;
		int taskCompleted = 0;
		int taskSubmitted = 0;
		int taskOverdue = 0;
		int openTasks = 0;
		for (Task t : tasks) {
			String st = t.getStatus();
			if (st != null && "COMPLETED".equalsIgnoreCase(st)) {
				taskCompleted++;
			} else {
				openTasks++;
				if (st != null && "SUBMITTED".equalsIgnoreCase(st)) {
					taskSubmitted++;
				} else {
					taskAssigned++;
				}
			}
			if (st != null && !"COMPLETED".equalsIgnoreCase(st) && t.getDeadline() != null
					&& t.getDeadline().before(today)) {
				taskOverdue++;
			}
		}
		request.setAttribute("taskAssigned", taskAssigned);
		request.setAttribute("taskSubmitted", taskSubmitted);
		request.setAttribute("taskCompleted", taskCompleted);
		request.setAttribute("taskOverdue", taskOverdue);
		request.setAttribute("openTasks", openTasks);
		request.setAttribute("overdueTasks", taskOverdue);
		request.setAttribute("completedTasks", taskCompleted);

		int totalTasks = tasks.size();
		int compRate = totalTasks > 0 ? (taskCompleted * 100 / totalTasks) : 0;
		request.setAttribute("taskCompletionRate", compRate);

		List<LeaveRequest> leaves = new LeaveRequestDAO().getLeavesByUsername(username);
		int pendingLeaves = 0;
		int leaveSick = 0;
		int leaveAnnual = 0;
		int leavePersonal = 0;
		int leaveMaternity = 0;
		int leaveOther = 0;
		for (LeaveRequest lr : leaves) {
			String s = lr.getStatus();
			if (s != null && "PENDING".equalsIgnoreCase(s.trim())) {
				pendingLeaves++;
			}
			String lt = lr.getLeaveType();
			if (lt == null || lt.isEmpty()) {
				leaveOther++;
			} else {
				String ltl = lt.toLowerCase();
				if (ltl.contains("sick")) {
					leaveSick++;
				} else if (ltl.contains("annual")) {
					leaveAnnual++;
				} else if (ltl.contains("personal")) {
					leavePersonal++;
				} else if (ltl.contains("maternity")) {
					leaveMaternity++;
				} else {
					leaveOther++;
				}
			}
		}
		request.setAttribute("pendingLeaves", pendingLeaves);
		request.setAttribute("leaveSick", leaveSick);
		request.setAttribute("leaveAnnual", leaveAnnual);
		request.setAttribute("leavePersonal", leavePersonal);
		request.setAttribute("leaveMaternity", leaveMaternity);
		request.setAttribute("leaveOther", leaveOther);

		List<Meeting> meetings = loadMeetings(username);
		request.setAttribute("upcomingMeetingsCount", meetings.size());

		User u = UserDao.getUserByEmail(username);
		String dbUser = u != null && u.getUsername() != null ? u.getUsername().trim() : username;
		String em = u != null && u.getEmail() != null ? u.getEmail().trim() : username;

		fillEmployeeWeeklyAttendance(request, em, dbUser);
		fillEmployeePunchDistribution(request, em, dbUser);

		java.sql.Timestamp pi = (java.sql.Timestamp) request.getAttribute("punchIn");
		java.sql.Timestamp po = (java.sql.Timestamp) request.getAttribute("punchOut");
		boolean onBreak = Boolean.TRUE.equals(request.getAttribute("onBreak"));
		String todayStatus;
		if (pi == null) {
			todayStatus = "Not punched in";
		} else if (po != null) {
			todayStatus = "Finished for today";
		} else if (onBreak) {
			todayStatus = "On break";
		} else {
			todayStatus = "At work";
		}
		request.setAttribute("todayStatus", todayStatus);

		request.setAttribute("recentActivities", buildEmployeeRecentActivities(tasks, leaves));
	}

	private void fillEmployeeWeeklyAttendance(HttpServletRequest request, String email, String dbUsername)
			throws Exception {
		String sql = "SELECT DATE_FORMAT(d.dy,'%a') lbl, "
				+ "  COALESCE(SUM(CASE WHEN a.status IN ('Present','On Break') THEN 1 ELSE 0 END),0) p, "
				+ "  COALESCE(SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END),0) ab " + "FROM ( "
				+ "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL " + "  SELECT CURDATE()-INTERVAL 5 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 4 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 3 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 2 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 1 DAY    UNION ALL "
				+ "  SELECT CURDATE() " + ") d " + "LEFT JOIN attendance a ON a.punch_date = d.dy "
				+ "  AND (a.user_email = ? OR a.username = ?) " + "GROUP BY d.dy ORDER BY d.dy";
		StringBuilder lbl = new StringBuilder();
		StringBuilder pre = new StringBuilder();
		StringBuilder abs = new StringBuilder();
		int sumP = 0;
		int sumA = 0;
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, email);
			ps.setString(2, dbUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				if (lbl.length() > 0) {
					lbl.append(",");
					pre.append(",");
					abs.append(",");
				}
				lbl.append("'").append(rs.getString("lbl")).append("'");
				int p = rs.getInt("p");
				int ab = rs.getInt("ab");
				pre.append(p);
				abs.append(ab);
				sumP += p;
				sumA += ab;
			}
		}
		request.setAttribute("weekLabels",
				lbl.length() > 0 ? lbl.toString() : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
		request.setAttribute("weekPresentData", pre.length() > 0 ? pre.toString() : "0,0,0,0,0,0,0");
		request.setAttribute("weekAbsentData", abs.length() > 0 ? abs.toString() : "0,0,0,0,0,0,0");
		int attRate7d = (sumP + sumA) > 0 ? (sumP * 100 / (sumP + sumA)) : 0;
		request.setAttribute("attRate7d", attRate7d);
	}

	private void fillEmployeePunchDistribution(HttpServletRequest request, String email, String dbUsername)
			throws Exception {
		Map<String, Integer> d = new HashMap<>();
		d.put("before8", 0);
		d.put("8to9", 0);
		d.put("9to10", 0);
		d.put("10to11", 0);
		d.put("after11", 0);
		String sql = "SELECT "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) < 8                            THEN 1 ELSE 0 END) b8,   "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 8  AND HOUR(a.punch_in) < 9  THEN 1 ELSE 0 END) h89,  "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 9  AND HOUR(a.punch_in) < 10 THEN 1 ELSE 0 END) h910, "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 10 AND HOUR(a.punch_in) < 11 THEN 1 ELSE 0 END) h1011,"
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 11                            THEN 1 ELSE 0 END) a11   "
				+ "FROM attendance a " + "WHERE (a.user_email = ? OR a.username = ?) " + "  AND a.punch_in IS NOT NULL "
				+ "  AND a.punch_date >= DATE(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY))";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, email);
			ps.setString(2, dbUsername);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				d.put("before8", rs.getInt("b8"));
				d.put("8to9", rs.getInt("h89"));
				d.put("9to10", rs.getInt("h910"));
				d.put("10to11", rs.getInt("h1011"));
				d.put("after11", rs.getInt("a11"));
			}
		}
		int v0 = d.get("before8");
		int v1 = d.get("8to9");
		int v2 = d.get("9to10");
		int v3 = d.get("10to11");
		int v4 = d.get("after11");
		int punchSum = v0 + v1 + v2 + v3 + v4;
		int onTimePct = punchSum > 0 ? ((v0 + v1) * 100 / punchSum) : 0;
		request.setAttribute("punchBefore8", v0);
		request.setAttribute("punch8to9", v1);
		request.setAttribute("punch9to10", v2);
		request.setAttribute("punch10to11", v3);
		request.setAttribute("punchAfter11", v4);
		request.setAttribute("onTimePunchPct", onTimePct);
	}

	private List<Map<String, String>> buildEmployeeRecentActivities(List<Task> tasks, List<LeaveRequest> leaves) {
		List<ActRow> rows = new ArrayList<>();
		if (tasks != null) {
			for (Task t : tasks) {
				if (t.getAssignedDate() == null) {
					continue;
				}
				rows.add(new ActRow(t.getAssignedDate().getTime(), "task", t.getTitle(),
						"Status: " + (t.getStatus() != null ? t.getStatus() : "—")));
			}
		}
		if (leaves != null) {
			for (LeaveRequest lr : leaves) {
				if (lr.getAppliedAt() == null) {
					continue;
				}
				String lt = lr.getLeaveType() != null ? lr.getLeaveType() : "Leave";
				rows.add(new ActRow(lr.getAppliedAt().getTime(), "leave", lt + " leave",
						"Status: " + (lr.getStatus() != null ? lr.getStatus() : "—")));
			}
		}
		rows.sort(Comparator.comparingLong((ActRow a) -> a.ts).reversed());

		java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("MMM d, yyyy HH:mm");
		List<Map<String, String>> out = new ArrayList<>();
		int n = Math.min(8, rows.size());
		for (int i = 0; i < n; i++) {
			ActRow r = rows.get(i);
			Map<String, String> m = new HashMap<>();
			m.put("kind", r.kind);
			m.put("title", r.title);
			m.put("detail", r.detail);
			m.put("when", fmt.format(new java.util.Date(r.ts)));
			out.add(m);
		}
		return out;
	}

	private static final class ActRow {
		final long ts;
		final String kind;
		final String title;
		final String detail;

		ActRow(long ts, String kind, String title, String detail) {
			this.ts = ts;
			this.kind = kind;
			this.title = title;
			this.detail = detail;
		}
	}

	private List<Meeting> loadMeetings(String username) throws Exception {
		List<Meeting> meetings = new ArrayList<>();
		String sql = "SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time, "
				+ "m.meeting_link, m.created_by, m.created_at, "
				+ "CONCAT(u.firstname, ' ', u.lastname) AS creator_name, u.role AS creator_role " + "FROM meetings m "
				+ "LEFT JOIN meeting_participants mp ON m.id = mp.meeting_id "
				+ "LEFT JOIN users u ON m.created_by = u.email " + "LEFT JOIN users emp ON emp.email = ? "
				+ "WHERE (mp.user_email = ? OR m.created_by = emp.manager_email) " + "AND m.end_time >= NOW() "
				+ "ORDER BY m.start_time ASC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, username);
			ps.setString(2, username);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				m.setCreatedAt(rs.getTimestamp("created_at"));
				m.setCreatorName(rs.getString("creator_name"));
				m.setCreatorRole(rs.getString("creator_role"));
				meetings.add(m);
			}
		}
		return meetings;
	}
}