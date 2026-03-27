package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Team;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/managerOverview")
public class ManagerOverviewServlet extends HttpServlet {

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
		String managerEmail = (String) session.getAttribute("username");

		try {
			// 1. Teams
			List<Team> teams = TeamDAO.getTeamsByManager(managerEmail);
			int totalTeams = teams.size(), totalMembers = 0;
			for (Team t : teams)
				totalMembers += t.getMembers().size();
			request.setAttribute("totalTeams", totalTeams);
			request.setAttribute("totalMembers", totalMembers);
			request.setAttribute("teams", teams);

			// 2. Today's Attendance
			Map<String, Integer> att = getAttendanceStats(managerEmail);
			request.setAttribute("presentCount", att.get("present"));
			request.setAttribute("absentCount", att.get("absent"));
			request.setAttribute("onBreakCount", att.get("onBreak"));

			// 3. Tasks
			Map<String, Integer> task = getTaskStats(managerEmail);
			request.setAttribute("totalTasks", task.get("total"));
			request.setAttribute("pendingTasks", task.get("pending"));
			request.setAttribute("completedTasks", task.get("completed"));
			request.setAttribute("overdueTasks", task.get("overdue"));

			// 4. Leave pending count
			request.setAttribute("pendingLeaves", getPendingLeaveCount(managerEmail));

			// 5. Meetings
			List<Meeting> todayMeetings = MeetingDao.getTodayMeetings(managerEmail);
			request.setAttribute("todayMeetings", todayMeetings);
			request.setAttribute("meetingCount", todayMeetings.size());

			// 6. Recent Activities
			request.setAttribute("recentActivities", getRecentActivities(managerEmail));

			// 7. Performance
			Map<String, Integer> perf = getPerformanceStats(managerEmail);
			request.setAttribute("ratedEmployees", perf.get("rated"));
			request.setAttribute("pendingRatings", perf.get("pending"));

			// 8. Weekly attendance (last 7 days)
			Map<String, String> weekly = getWeeklyAttendance(managerEmail);
			request.setAttribute("weekLabels", weekly.get("labels"));
			request.setAttribute("weekPresentData", weekly.get("present"));
			request.setAttribute("weekAbsentData", weekly.get("absent"));

			// 9. Task status breakdown — counts each exact status value
			Map<String, Integer> ts = getTaskStatusBreakdown(managerEmail);
			request.setAttribute("taskAssigned", ts.get("ASSIGNED"));
			request.setAttribute("taskCompleted", ts.get("COMPLETED"));
			request.setAttribute("taskSubmitted", ts.get("SUBMITTED"));
			request.setAttribute("taskOverdue", ts.get("OVERDUE"));
			// 10. Leave type breakdown
			Map<String, Integer> lt = getLeaveTypeBreakdown(managerEmail);
			request.setAttribute("leaveSick", lt.getOrDefault("Sick", 0));
			request.setAttribute("leaveAnnual", lt.getOrDefault("Annual", 0));
			request.setAttribute("leavePersonal", lt.getOrDefault("Personal", 0));
			request.setAttribute("leaveMaternity", lt.getOrDefault("Maternity", 0));
			request.setAttribute("leaveOther", lt.getOrDefault("Other", 0));

			// 11. Punch-in time
			Map<String, Integer> pi = getPunchInDistribution(managerEmail);
			request.setAttribute("punchBefore8", pi.get("before8"));
			request.setAttribute("punch8to9", pi.get("8to9"));
			request.setAttribute("punch9to10", pi.get("9to10"));
			request.setAttribute("punch10to11", pi.get("10to11"));
			request.setAttribute("punchAfter11", pi.get("after11"));

		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException("Error loading dashboard data", e);
		}

		request.getRequestDispatcher("managerOverview.jsp").forward(request, response);
	}

	// ─────────────────────────────────────────────────────────────────────
	// CORE helpers
	// ─────────────────────────────────────────────────────────────────────

	/**
	 * Today's attendance for all team members under this manager.
	 * attendance.status: 'Present' / 'Absent' / 'On Break' Join:
	 * attendance.user_email = team_members.username
	 */
	private Map<String, Integer> getAttendanceStats(String mgr) {
		Map<String, Integer> s = new HashMap<>();
		s.put("present", 0);
		s.put("absent", 0);
		s.put("onBreak", 0);
		String sql = "SELECT " + "  SUM(CASE WHEN a.status='Present'  THEN 1 ELSE 0 END) p, "
				+ "  SUM(CASE WHEN a.status='Absent'   THEN 1 ELSE 0 END) ab, "
				+ "  SUM(CASE WHEN a.status='On Break' THEN 1 ELSE 0 END) ob " + "FROM attendance a "
				+ "INNER JOIN team_members tm ON a.user_email = tm.username "
				+ "INNER JOIN teams t ON tm.team_id = t.id "
				+ "WHERE t.manager_username = ? AND a.punch_date = CURDATE()";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				s.put("present", rs.getInt("p"));
				s.put("absent", rs.getInt("ab"));
				s.put("onBreak", rs.getInt("ob"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	/**
	 * Summary task counts for the manager. tasks.status: 'ASSIGNED' / 'COMPLETED' /
	 * 'SUBMITTED' Overdue = not COMPLETED and past deadline date.
	 */
	private Map<String, Integer> getTaskStats(String mgr) {
		Map<String, Integer> s = new HashMap<>();
		s.put("total", 0);
		s.put("pending", 0);
		s.put("completed", 0);
		s.put("overdue", 0);
		String sql = "SELECT COUNT(*) total, " + "  SUM(CASE WHEN status != 'COMPLETED' THEN 1 ELSE 0 END) pending, "
				+ "  SUM(CASE WHEN status  = 'COMPLETED' THEN 1 ELSE 0 END) completed, "
				+ "  SUM(CASE WHEN status != 'COMPLETED' AND deadline < CURDATE() THEN 1 ELSE 0 END) overdue "
				+ "FROM tasks WHERE assigned_by = ?";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				s.put("total", rs.getInt("total"));
				s.put("pending", rs.getInt("pending"));
				s.put("completed", rs.getInt("completed"));
				s.put("overdue", rs.getInt("overdue"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	/**
	 * Pending leave count for all team members. leave_requests.status default =
	 * 'PENDING' (uppercase).
	 */
	private int getPendingLeaveCount(String mgr) {
		String sql = "SELECT COUNT(*) cnt FROM leave_requests lr "
				+ "INNER JOIN team_members tm ON lr.username = tm.username "
				+ "INNER JOIN teams t ON tm.team_id = t.id "
				+ "WHERE t.manager_username = ? AND UPPER(lr.status) = 'PENDING'";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				return rs.getInt("cnt");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	private List<Map<String, String>> getRecentActivities(String mgr) {
		List<Map<String, String>> list = new ArrayList<>();
		String sql = "SELECT 'Task Assigned' type, title description, assigned_to user, assigned_date time "
				+ "FROM tasks WHERE assigned_by = ? " + "UNION ALL "
				+ "SELECT 'Leave Request', CONCAT(leave_type,' - ',from_date,' to ',to_date), username, applied_at "
				+ "FROM leave_requests "
				+ "WHERE username IN (SELECT tm.username FROM team_members tm INNER JOIN teams t ON tm.team_id=t.id WHERE t.manager_username=?) "
				+ "UNION ALL "
				+ "SELECT 'Meeting Scheduled', title, created_by, created_at FROM meetings WHERE created_by = ? "
				+ "ORDER BY time DESC LIMIT 5";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ps.setString(2, mgr);
			ps.setString(3, mgr);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Map<String, String> a = new HashMap<>();
				a.put("type", rs.getString("type"));
				a.put("description", rs.getString("description"));
				a.put("user", rs.getString("user"));
				a.put("time", rs.getString("time"));
				list.add(a);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	private Map<String, Integer> getPerformanceStats(String mgr) {
		Map<String, Integer> s = new HashMap<>();
		s.put("rated", 0);
		s.put("pending", 0);
		try (Connection c = DBConnectionUtil.getConnection()) {
			PreparedStatement ps = c
					.prepareStatement("SELECT COUNT(DISTINCT employee_username) rated FROM employee_performance "
							+ "WHERE manager_username=? AND MONTH(performance_month)=MONTH(CURDATE()) AND YEAR(performance_month)=YEAR(CURDATE())");
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				s.put("rated", rs.getInt("rated"));
		} catch (Exception e) {
			e.printStackTrace();
		}
		try (Connection c = DBConnectionUtil.getConnection()) {
			PreparedStatement ps = c.prepareStatement("SELECT COUNT(DISTINCT tm.username) total FROM team_members tm "
					+ "INNER JOIN teams t ON tm.team_id=t.id WHERE t.manager_username=?");
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				s.put("pending", Math.max(0, rs.getInt("total") - s.get("rated")));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	// ─────────────────────────────────────────────────────────────────────
	// ANALYTICS helpers
	// ─────────────────────────────────────────────────────────────────────

	/**
	 * Last 7 calendar days: Present vs Absent per day. Uses a derived 7-row date
	 * table so days with zero records still appear.
	 */
	private Map<String, String> getWeeklyAttendance(String mgr) {
		Map<String, String> result = new HashMap<>();
		String sql = "SELECT DATE_FORMAT(d.dy,'%a') lbl, "
				+ "  COALESCE(SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END),0) p, "
				+ "  COALESCE(SUM(CASE WHEN a.status='Absent'  THEN 1 ELSE 0 END),0) ab " + "FROM ( "
				+ "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL " + "  SELECT CURDATE()-INTERVAL 5 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 4 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 3 DAY    UNION ALL "
				+ "  SELECT CURDATE()-INTERVAL 2 DAY    UNION ALL " + "  SELECT CURDATE()-INTERVAL 1 DAY    UNION ALL "
				+ "  SELECT CURDATE() " + ") d " + "LEFT JOIN attendance a " + "  ON a.punch_date = d.dy "
				+ "  AND a.user_email IN ( " + "    SELECT tm.username FROM team_members tm "
				+ "    INNER JOIN teams t ON tm.team_id = t.id " + "    WHERE t.manager_username = ? " + "  ) "
				+ "GROUP BY d.dy ORDER BY d.dy";
		StringBuilder lbl = new StringBuilder(), pre = new StringBuilder(), abs = new StringBuilder();
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				if (lbl.length() > 0) {
					lbl.append(",");
					pre.append(",");
					abs.append(",");
				}
				lbl.append("'").append(rs.getString("lbl")).append("'");
				pre.append(rs.getInt("p"));
				abs.append(rs.getInt("ab"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		result.put("labels", lbl.length() > 0 ? lbl.toString() : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
		result.put("present", pre.length() > 0 ? pre.toString() : "0,0,0,0,0,0,0");
		result.put("absent", abs.length() > 0 ? abs.toString() : "0,0,0,0,0,0,0");
		return result;
	}

	/**
	 * Exact task status counts + computed overdue bucket. DB values: 'ASSIGNED',
	 * 'COMPLETED', 'SUBMITTED'.
	 */
	private Map<String, Integer> getTaskStatusBreakdown(String mgr) {
		Map<String, Integer> s = new HashMap<>();
		s.put("ASSIGNED", 0);
		s.put("COMPLETED", 0);
		s.put("SUBMITTED", 0);
		s.put("OVERDUE", 0);
		// Direct counts per status
		String sql = "SELECT " + "  SUM(CASE WHEN status='ASSIGNED'   THEN 1 ELSE 0 END) assigned, "
				+ "  SUM(CASE WHEN status='COMPLETED'  THEN 1 ELSE 0 END) completed, "
				+ "  SUM(CASE WHEN status='SUBMITTED'  THEN 1 ELSE 0 END) submitted, "
				+ "  SUM(CASE WHEN status != 'COMPLETED' AND deadline < CURDATE() THEN 1 ELSE 0 END) overdue "
				+ "FROM tasks WHERE assigned_by = ?";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				s.put("ASSIGNED", rs.getInt("assigned"));
				s.put("COMPLETED", rs.getInt("completed"));
				s.put("SUBMITTED", rs.getInt("submitted"));
				s.put("OVERDUE", rs.getInt("overdue"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	/**
	 * Leave type breakdown — keyword-matched against leave_type column value.
	 * Covers any spelling (e.g. "Sick Leave", "sick", "SICK LEAVE").
	 */
	private Map<String, Integer> getLeaveTypeBreakdown(String mgr) {
		Map<String, Integer> types = new HashMap<>();
		String sql = "SELECT lr.leave_type, COUNT(*) cnt " + "FROM leave_requests lr "
				+ "INNER JOIN team_members tm ON lr.username = tm.username "
				+ "INNER JOIN teams t ON tm.team_id = t.id " + "WHERE t.manager_username = ? "
				+ "GROUP BY lr.leave_type";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				String lt = rs.getString("leave_type");
				int cnt = rs.getInt("cnt");
				if (lt == null)
					types.merge("Other", cnt, Integer::sum);
				else if (lt.toLowerCase().contains("sick"))
					types.merge("Sick", cnt, Integer::sum);
				else if (lt.toLowerCase().contains("annual"))
					types.merge("Annual", cnt, Integer::sum);
				else if (lt.toLowerCase().contains("personal"))
					types.merge("Personal", cnt, Integer::sum);
				else if (lt.toLowerCase().contains("maternity"))
					types.merge("Maternity", cnt, Integer::sum);
				else
					types.merge("Other", cnt, Integer::sum);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return types;
	}

	/**
	 * Punch-in time buckets for the current ISO week (Mon 00:00 → today).
	 * attendance.punch_in is a TIMESTAMP column.
	 */
	private Map<String, Integer> getPunchInDistribution(String mgr) {
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
				+ "FROM attendance a " + "INNER JOIN team_members tm ON a.user_email = tm.username "
				+ "INNER JOIN teams t ON tm.team_id = t.id " + "WHERE t.manager_username = ? "
				+ "  AND a.punch_in IS NOT NULL "
				+ "  AND a.punch_date >= DATE(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY))";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, mgr);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				d.put("before8", rs.getInt("b8"));
				d.put("8to9", rs.getInt("h89"));
				d.put("9to10", rs.getInt("h910"));
				d.put("10to11", rs.getInt("h1011"));
				d.put("after11", rs.getInt("a11"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return d;
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}