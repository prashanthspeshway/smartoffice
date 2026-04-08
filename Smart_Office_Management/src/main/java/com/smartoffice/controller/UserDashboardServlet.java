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
				} else if (ltl.contains("earned") || ltl.contains("annual")) {
					// project uses Earned leave naming
					leaveAnnual++;
				} else if (ltl.contains("casual") || ltl.contains("personal")) {
					// project uses Casual leave naming
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
		String dbUser = u != null && u.getUsername() != null ? u.getUsername().trim() : null;
		String em = u != null && u.getEmail() != null ? u.getEmail().trim() : null;
		String fullName = null;
		if (u != null) {
			String first = u.getFirstname();
			String last = u.getLastname();
			String fn = ((first == null ? "" : first.trim()) + " " + (last == null ? "" : last.trim())).trim();
			if (!fn.isEmpty())
				fullName = fn;
		}
		List<String> userKeys = buildUserIdentityKeys(username, em, dbUser, fullName);

		fillEmployeeWeeklyAttendance(request, userKeys);
		fillEmployeePunchDistribution(request, userKeys);
		fillEmployeeWorkHoursLast7Days(request, userKeys);
		fillEmployeeBreakMinutesLast7Days(request, userKeys);
		fillEmployeeTaskTrendLast4Weeks(request, username);
		fillEmployeeLeaveTrendLast6Months(request, username);

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

	private boolean hasColumn(String table, String column) {
		String sql = "SELECT 1 FROM information_schema.COLUMNS "
				+ "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, table);
			ps.setString(2, column);
			ResultSet rs = ps.executeQuery();
			return rs.next();
		} catch (Exception e) {
			return false;
		}
	}

	private String getAttendanceUserColumn() {
		if (hasColumn("attendance", "user_email"))
			return "user_email";
		if (hasColumn("attendance", "email"))
			return "email";
		return "username";
	}

	private String getLeaveUserColumn() {
		if (hasColumn("leave_requests", "email"))
			return "email";
		return "username";
	}

	private String getTaskDateColumn() {
		if (hasColumn("tasks", "assigned_date"))
			return "assigned_date";
		if (hasColumn("tasks", "created_at"))
			return "created_at";
		if (hasColumn("tasks", "submitted_at"))
			return "submitted_at";
		return "assigned_date";
	}

	private List<String> buildUserIdentityKeys(String sessionUsername, String email, String dbUsername, String fullName) {
		java.util.LinkedHashSet<String> keys = new java.util.LinkedHashSet<>();
		if (email != null && !email.trim().isEmpty())
			keys.add(email.trim());
		if (dbUsername != null && !dbUsername.trim().isEmpty())
			keys.add(dbUsername.trim());
		if (sessionUsername != null && !sessionUsername.trim().isEmpty())
			keys.add(sessionUsername.trim());
		if (fullName != null && !fullName.trim().isEmpty())
			keys.add(fullName.trim());
		return new java.util.ArrayList<>(keys);
	}

	private String buildInClause(int size) {
		StringBuilder sb = new StringBuilder("(");
		for (int i = 0; i < size; i++) {
			if (i > 0)
				sb.append(",");
			sb.append("?");
		}
		sb.append(")");
		return sb.toString();
	}

	private void setParams(PreparedStatement ps, List<String> params) throws Exception {
		for (int i = 0; i < params.size(); i++) {
			ps.setString(i + 1, params.get(i));
		}
	}

	private List<String> normalizeKeys(List<String> keys) {
		java.util.ArrayList<String> out = new java.util.ArrayList<>();
		if (keys == null)
			return out;
		for (String k : keys) {
			if (k == null)
				continue;
			String v = k.trim().toLowerCase();
			if (!v.isEmpty())
				out.add(v);
		}
		return out;
	}

	private void fillEmployeeWeeklyAttendance(HttpServletRequest request, List<String> userKeys) throws Exception {
		if (userKeys == null || userKeys.isEmpty()) {
			request.setAttribute("weekLabels", "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
			request.setAttribute("weekPresentData", "0,0,0,0,0,0,0");
			request.setAttribute("weekAbsentData", "0,0,0,0,0,0,0");
			request.setAttribute("attRate7d", 0);
			return;
		}

		String aUserCol = getAttendanceUserColumn();
		String in = buildInClause(userKeys.size());

		String sql = "SELECT DATE_FORMAT(d.dy,'%a') lbl, "
				+ "  COALESCE(SUM(CASE WHEN a.status IN ('Present','In Progress','Half Day','On Break') THEN 1 ELSE 0 END),0) p, "
				+ "  COALESCE(SUM(CASE WHEN a.status IN ('Absent') THEN 1 ELSE 0 END),0) ab " + "FROM ( "
				+ "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL " + "  SELECT CURDATE()-INTERVAL 5 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 4 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 3 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 2 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 1 DAY    UNION ALL "
				+ "  SELECT CURDATE() " + ") d " + "LEFT JOIN attendance a ON DATE(a.punch_date) = d.dy "
				+ "  AND a." + aUserCol + " IN " + in + " GROUP BY d.dy ORDER BY d.dy";
		StringBuilder lbl = new StringBuilder();
		StringBuilder pre = new StringBuilder();
		StringBuilder abs = new StringBuilder();
		int sumP = 0;
		int sumA = 0;
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			setParams(ps, userKeys);
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

	private void fillEmployeePunchDistribution(HttpServletRequest request, List<String> userKeys) throws Exception {
		Map<String, Integer> d = new HashMap<>();
		d.put("before8", 0);
		d.put("8to9", 0);
		d.put("9to10", 0);
		d.put("10to11", 0);
		d.put("after11", 0);
		if (userKeys == null || userKeys.isEmpty()) {
			request.setAttribute("punchBefore8", 0);
			request.setAttribute("punch8to9", 0);
			request.setAttribute("punch9to10", 0);
			request.setAttribute("punch10to11", 0);
			request.setAttribute("punchAfter11", 0);
			request.setAttribute("onTimePunchPct", 0);
			return;
		}

		String aUserCol = getAttendanceUserColumn();
		String in = buildInClause(userKeys.size());
		// Office start = 10am buckets:
		// <10, 10–11, 11–12, 12–1, >=1pm
		String sql = "SELECT "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) < 10                            THEN 1 ELSE 0 END) b10,  "
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 10 AND HOUR(a.punch_in) < 11 THEN 1 ELSE 0 END) h1011,"
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 11 AND HOUR(a.punch_in) < 12 THEN 1 ELSE 0 END) h1112,"
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 12 AND HOUR(a.punch_in) < 13 THEN 1 ELSE 0 END) h1213,"
				+ "  SUM(CASE WHEN HOUR(a.punch_in) >= 13                            THEN 1 ELSE 0 END) a13,  "
				+ "  SUM(CASE WHEN TIME(a.punch_in) >= '10:00:00' AND TIME(a.punch_in) < '10:30:00' THEN 1 ELSE 0 END) ontime1030 "
				+ "FROM attendance a " + "WHERE a." + aUserCol + " IN " + in + "  AND a.punch_in IS NOT NULL "
				+ "  AND DATE(a.punch_date) >= DATE(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY))";
		int onTimeCount = 0;
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			setParams(ps, userKeys);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				d.put("before8", rs.getInt("b10"));     // reused attr name: now means "before 10am"
				d.put("8to9", rs.getInt("h1011"));      // now "10–11"
				d.put("9to10", rs.getInt("h1112"));     // now "11–12"
				d.put("10to11", rs.getInt("h1213"));    // now "12–1"
				d.put("after11", rs.getInt("a13"));     // now "after 1pm"
				onTimeCount = rs.getInt("ontime1030");
			}
		}
		int v0 = d.get("before8");
		int v1 = d.get("8to9");
		int v2 = d.get("9to10");
		int v3 = d.get("10to11");
		int v4 = d.get("after11");
		int punchSum = v0 + v1 + v2 + v3 + v4;
		// On-time = between 10:00am and 10:30am
		int onTimePct = punchSum > 0 ? (onTimeCount * 100 / punchSum) : 0;
		request.setAttribute("punchBefore8", v0);
		request.setAttribute("punch8to9", v1);
		request.setAttribute("punch9to10", v2);
		request.setAttribute("punch10to11", v3);
		request.setAttribute("punchAfter11", v4);
		request.setAttribute("onTimePunchPct", onTimePct);
	}

	private void fillEmployeeWorkHoursLast7Days(HttpServletRequest request, List<String> userKeys) throws Exception {
		if (userKeys == null || userKeys.isEmpty()) {
			request.setAttribute("workHourLabels", "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
			request.setAttribute("workHourData", "0,0,0,0,0,0,0");
			request.setAttribute("avgWorkHoursToday", "0");
			return;
		}

		String aUserCol = getAttendanceUserColumn();
		String in = buildInClause(userKeys.size());

		String sql = "SELECT DATE_FORMAT(d.dy,'%a') lbl, "
				+ "  COALESCE(ROUND(AVG(CASE WHEN a.punch_in IS NOT NULL THEN "
				+ "    TIMESTAMPDIFF(MINUTE, a.punch_in, "
				+ "      COALESCE(a.punch_out, CASE WHEN DATE(a.punch_date)=CURDATE() THEN NOW() ELSE NULL END)"
				+ "    ) / 60.0 END"
				+ "  ), 1), 0) hrs "
				+ "FROM ( "
				+ "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL SELECT CURDATE()-INTERVAL 5 DAY "
				+ "  UNION ALL SELECT CURDATE()-INTERVAL 4 DAY UNION ALL SELECT CURDATE()-INTERVAL 3 DAY "
				+ "  UNION ALL SELECT CURDATE()-INTERVAL 2 DAY UNION ALL SELECT CURDATE()-INTERVAL 1 DAY "
				+ "  UNION ALL SELECT CURDATE() "
				+ ") d "
				+ "LEFT JOIN attendance a ON DATE(a.punch_date)=d.dy AND a." + aUserCol + " IN " + in + " "
				+ "GROUP BY d.dy ORDER BY d.dy";

		StringBuilder lbl = new StringBuilder();
		StringBuilder data = new StringBuilder();
		String avgToday = "0";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			setParams(ps, userKeys);
			ResultSet rs = ps.executeQuery();
			String last = "0";
			while (rs.next()) {
				if (lbl.length() > 0) {
					lbl.append(",");
					data.append(",");
				}
				lbl.append("'").append(rs.getString("lbl")).append("'");
				last = rs.getString("hrs");
				if (last == null)
					last = "0";
				data.append(last);
			}
			avgToday = last;
		}
		request.setAttribute("workHourLabels", lbl.length() > 0 ? lbl.toString() : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
		request.setAttribute("workHourData", data.length() > 0 ? data.toString() : "0,0,0,0,0,0,0");
		request.setAttribute("avgWorkHoursToday", avgToday);
	}

	private void fillEmployeeBreakMinutesLast7Days(HttpServletRequest request, List<String> userKeys) throws Exception {
		// break_logs.username stores display name; BreakDAO resolves email->username, but for charts we accept multiple keys.
		if (userKeys == null || userKeys.isEmpty()) {
			request.setAttribute("breakLabels", "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
			request.setAttribute("breakData", "0,0,0,0,0,0,0");
			request.setAttribute("breakTotalMinutes7d", 0);
			return;
		}

		String in = buildInClause(userKeys.size());
		String sql = "SELECT DATE_FORMAT(d.dy,'%a') lbl, "
				+ "  COALESCE(ROUND(SUM(COALESCE(bl.duration_seconds,0))/60.0, 0), 0) mins "
				+ "FROM ( "
				+ "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL SELECT CURDATE()-INTERVAL 5 DAY "
				+ "  UNION ALL SELECT CURDATE()-INTERVAL 4 DAY UNION ALL SELECT CURDATE()-INTERVAL 3 DAY "
				+ "  UNION ALL SELECT CURDATE()-INTERVAL 2 DAY UNION ALL SELECT CURDATE()-INTERVAL 1 DAY "
				+ "  UNION ALL SELECT CURDATE() "
				+ ") d "
				+ "LEFT JOIN break_logs bl ON DATE(bl.break_date)=d.dy AND bl.username IN " + in + " "
				+ "GROUP BY d.dy ORDER BY d.dy";

		StringBuilder lbl = new StringBuilder();
		StringBuilder data = new StringBuilder();
		int sum = 0;
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			setParams(ps, userKeys);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				if (lbl.length() > 0) {
					lbl.append(",");
					data.append(",");
				}
				lbl.append("'").append(rs.getString("lbl")).append("'");
				int mins = rs.getInt("mins");
				data.append(mins);
				sum += mins;
			}
		}
		request.setAttribute("breakLabels", lbl.length() > 0 ? lbl.toString() : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
		request.setAttribute("breakData", data.length() > 0 ? data.toString() : "0,0,0,0,0,0,0");
		request.setAttribute("breakTotalMinutes7d", sum);
	}

	private void fillEmployeeTaskTrendLast4Weeks(HttpServletRequest request, String username) throws Exception {
		// tasks.assigned_to can be either email (fresh schema) or username/display name (legacy).
		// Use identity keys to ensure we match existing rows.
		String email = username;
		String dbUsername = null;
		String fullName = null;
		try (Connection c = DBConnectionUtil.getConnection();
				PreparedStatement ps = c.prepareStatement(
						"SELECT username, TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(lastname,''))) fullname FROM users WHERE email=? LIMIT 1")) {
			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				dbUsername = rs.getString("username");
				fullName = rs.getString("fullname");
				if (fullName != null)
					fullName = fullName.trim();
				if (dbUsername != null)
					dbUsername = dbUsername.trim();
			}
		} catch (Exception ignored) {
		}
		List<String> assigneeKeys = buildUserIdentityKeys(username, email, dbUsername, fullName);
		List<String> normKeys = normalizeKeys(assigneeKeys);
		if (normKeys.isEmpty()) {
			request.setAttribute("taskTrendLabels", "'Wk 1','Wk 2','Wk 3','Wk 4'");
			request.setAttribute("taskTrendAssignedData", "0,0,0,0");
			request.setAttribute("taskTrendCompletedData", "0,0,0,0");
			return;
		}

		String dateCol = getTaskDateColumn();
		String sql = "SELECT YEARWEEK(" + dateCol + ", 1) yw, "
				+ "  COALESCE(SUM(1),0) assigned, "
				+ "  COALESCE(SUM(CASE WHEN UPPER(status)='COMPLETED' THEN 1 ELSE 0 END),0) completed "
				+ "FROM tasks "
				+ "WHERE LOWER(TRIM(assigned_to)) IN " + buildInClause(normKeys.size()) + " "
				+ "  AND " + dateCol + " >= DATE_SUB(CURDATE(), INTERVAL 4 WEEK) "
				+ "GROUP BY YEARWEEK(" + dateCol + ", 1) "
				+ "ORDER BY yw ASC";

		java.util.Map<Integer, Integer> assignedByWeek = new java.util.HashMap<>();
		java.util.Map<Integer, Integer> completedByWeek = new java.util.HashMap<>();
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			setParams(ps, normKeys);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				int yw = rs.getInt("yw");
				assignedByWeek.put(yw, rs.getInt("assigned"));
				completedByWeek.put(yw, rs.getInt("completed"));
			}
		} catch (Exception e) {
			// keep defaults below
		}

		// Always render last 4 weeks (including zeros) so the chart draws a curve.
		java.util.Calendar cal = java.util.Calendar.getInstance();
		StringBuilder lbl = new StringBuilder();
		StringBuilder assigned = new StringBuilder();
		StringBuilder completed = new StringBuilder();
		for (int i = 3; i >= 0; i--) {
			java.util.Calendar wk = (java.util.Calendar) cal.clone();
			wk.add(java.util.Calendar.WEEK_OF_YEAR, -i);
			int yw = Integer.parseInt(new java.text.SimpleDateFormat("YYYYww").format(wk.getTime()));
			int a = assignedByWeek.getOrDefault(yw, 0);
			int c = completedByWeek.getOrDefault(yw, 0);
			if (lbl.length() > 0) {
				lbl.append(",");
				assigned.append(",");
				completed.append(",");
			}
			lbl.append("'Wk ").append(4 - i).append("'");
			assigned.append(a);
			completed.append(c);
		}
		request.setAttribute("taskTrendLabels", lbl.toString());
		request.setAttribute("taskTrendAssignedData", assigned.toString());
		request.setAttribute("taskTrendCompletedData", completed.toString());
	}

	private void fillEmployeeLeaveTrendLast6Months(HttpServletRequest request, String username) throws Exception {
		String leaveUserCol = getLeaveUserColumn();
		String sql = "SELECT DATE_FORMAT(CAST(applied_at AS DATE),'%Y-%m') ym, COUNT(*) cnt "
				+ "FROM leave_requests "
				+ "WHERE LOWER(TRIM(" + leaveUserCol + ")) IN " + buildInClause(2) + " "
				+ "  AND CAST(applied_at AS DATE) >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) "
				+ "GROUP BY DATE_FORMAT(CAST(applied_at AS DATE),'%Y-%m') "
				+ "ORDER BY ym ASC";

		java.util.Map<String, Integer> cntByMonth = new java.util.HashMap<>();
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			// Support both email + db username (if the schema uses username)
			String dbUsername = username;
			try (PreparedStatement psu = c.prepareStatement("SELECT username FROM users WHERE email=? LIMIT 1")) {
				psu.setString(1, username);
				ResultSet rsu = psu.executeQuery();
				if (rsu.next() && rsu.getString("username") != null && !rsu.getString("username").trim().isEmpty()) {
					dbUsername = rsu.getString("username").trim();
				}
			} catch (Exception ignored) {
			}

			ps.setString(1, username != null ? username.trim().toLowerCase() : "");
			ps.setString(2, dbUsername != null ? dbUsername.trim().toLowerCase() : "");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				cntByMonth.put(rs.getString("ym"), rs.getInt("cnt"));
			}
		} catch (Exception e) {
			// keep defaults below
		}

		// Always render last 6 months (including zeros) so the chart draws a curve.
		java.util.Calendar cal = java.util.Calendar.getInstance();
		java.text.SimpleDateFormat ymFmt = new java.text.SimpleDateFormat("yyyy-MM");
		java.text.SimpleDateFormat labelFmt = new java.text.SimpleDateFormat("MMM yyyy");
		StringBuilder lbl = new StringBuilder();
		StringBuilder data = new StringBuilder();
		for (int i = 5; i >= 0; i--) {
			java.util.Calendar m = (java.util.Calendar) cal.clone();
			m.add(java.util.Calendar.MONTH, -i);
			String ym = ymFmt.format(m.getTime());
			int cnt = cntByMonth.getOrDefault(ym, 0);
			if (lbl.length() > 0) {
				lbl.append(",");
				data.append(",");
			}
			lbl.append("'").append(labelFmt.format(m.getTime())).append("'");
			data.append(cnt);
		}
		request.setAttribute("leaveTrendLabels", lbl.toString());
		request.setAttribute("leaveTrendData", data.toString());
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