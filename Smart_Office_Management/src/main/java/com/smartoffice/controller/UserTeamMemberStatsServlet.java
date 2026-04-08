package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/userTeamMemberStats")
public class UserTeamMemberStatsServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		String requester = (String) session.getAttribute("username");
		String targetEmail = request.getParameter("email");
		if (targetEmail == null || targetEmail.trim().isEmpty()) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing email");
			return;
		}
		targetEmail = targetEmail.trim();

		try {
			if (!isMemberInSameTeam(requester, targetEmail)) {
				response.sendError(HttpServletResponse.SC_FORBIDDEN, "Member is not in your team");
				return;
			}

			IdentityKeys keys = resolveIdentityKeys(targetEmail);
			Stats stats = new Stats();
			stats.fullName = keys.fullName != null && !keys.fullName.isEmpty() ? keys.fullName : targetEmail;
			stats.email = keys.email != null ? keys.email : targetEmail;
			stats.username = keys.username != null ? keys.username : targetEmail;
			stats.role = keys.role != null ? keys.role : "Employee";
			stats.status = keys.status != null ? keys.status : "Active";

			fillTaskStats(stats, keys);
			fillAttendanceStats(stats, keys);
			fillLeaveStats(stats, keys);
			fillMeetingStats(stats, keys);
			fillLatestRating(stats, keys);

			String json = "{"
					+ "\"fullName\":\"" + esc(stats.fullName) + "\","
					+ "\"email\":\"" + esc(stats.email) + "\","
					+ "\"username\":\"" + esc(stats.username) + "\","
					+ "\"role\":\"" + esc(stats.role) + "\","
					+ "\"status\":\"" + esc(stats.status) + "\","
					+ "\"openTasks\":" + stats.openTasks + ","
					+ "\"completedTasks\":" + stats.completedTasks + ","
					+ "\"attendanceRate7d\":" + stats.attendanceRate7d + ","
					+ "\"presentDays7d\":" + stats.presentDays7d + ","
					+ "\"pendingLeaves\":" + stats.pendingLeaves + ","
					+ "\"approvedLeaves\":" + stats.approvedLeaves + ","
					+ "\"upcomingMeetings\":" + stats.upcomingMeetings + ","
					+ "\"latestRating\":\"" + esc(stats.latestRating) + "\""
					+ "}";

			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			response.getWriter().write(json);

		} catch (Exception e) {
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
		}
	}

	private boolean hasColumn(String table, String column) throws Exception {
		String sql = "SELECT 1 FROM information_schema.COLUMNS "
				+ "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, table);
			ps.setString(2, column);
			ResultSet rs = ps.executeQuery();
			return rs.next();
		}
	}

	private String getAttendanceUserColumn() throws Exception {
		if (hasColumn("attendance", "user_email"))
			return "user_email";
		if (hasColumn("attendance", "email"))
			return "email";
		return "username";
	}

	private String getLeaveUserColumn() throws Exception {
		if (hasColumn("leave_requests", "username"))
			return "username";
		return "email";
	}

	private boolean isMemberInSameTeam(String requesterEmail, String targetEmail) throws Exception {
		String sql = "SELECT 1 FROM team_members tm_req "
				+ "JOIN team_members tm_target ON tm_target.team_id = tm_req.team_id "
				+ "WHERE tm_req.username = ? AND tm_target.username = ? LIMIT 1";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, requesterEmail);
			ps.setString(2, targetEmail);
			ResultSet rs = ps.executeQuery();
			return rs.next();
		}
	}

	private IdentityKeys resolveIdentityKeys(String email) throws Exception {
		IdentityKeys k = new IdentityKeys();
		k.email = email;
		String sql = "SELECT email, username, firstname, lastname, role, status FROM users WHERE email = ? LIMIT 1";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				k.email = rs.getString("email");
				k.username = rs.getString("username");
				String first = rs.getString("firstname");
				String last = rs.getString("lastname");
				k.fullName = ((first == null ? "" : first.trim()) + " " + (last == null ? "" : last.trim())).trim();
				k.role = rs.getString("role");
				k.status = rs.getString("status");
			}
		}
		if (k.username == null || k.username.trim().isEmpty())
			k.username = k.email;
		if (k.fullName == null || k.fullName.trim().isEmpty())
			k.fullName = k.username;
		return k;
	}

	private List<String> toLowerKeys(IdentityKeys k) {
		Set<String> s = new LinkedHashSet<>();
		if (k.email != null)
			s.add(k.email.trim().toLowerCase());
		if (k.username != null)
			s.add(k.username.trim().toLowerCase());
		if (k.fullName != null)
			s.add(k.fullName.trim().toLowerCase());
		return new ArrayList<>(s);
	}

	private String inClause(int n) {
		StringBuilder sb = new StringBuilder("(");
		for (int i = 0; i < n; i++) {
			if (i > 0)
				sb.append(",");
			sb.append("?");
		}
		sb.append(")");
		return sb.toString();
	}

	private void bindKeys(PreparedStatement ps, List<String> keys, int startIdx) throws Exception {
		int idx = startIdx;
		for (String k : keys)
			ps.setString(idx++, k);
	}

	private void fillTaskStats(Stats s, IdentityKeys k) throws Exception {
		List<String> keys = toLowerKeys(k);
		String sql = "SELECT "
				+ "COALESCE(SUM(CASE WHEN UPPER(status)='COMPLETED' THEN 1 ELSE 0 END),0) completed, "
				+ "COALESCE(SUM(CASE WHEN UPPER(status)<>'COMPLETED' THEN 1 ELSE 0 END),0) openTasks "
				+ "FROM tasks WHERE LOWER(TRIM(assigned_to)) IN " + inClause(keys.size());
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			bindKeys(ps, keys, 1);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				s.completedTasks = rs.getInt("completed");
				s.openTasks = rs.getInt("openTasks");
			}
		}
	}

	private void fillAttendanceStats(Stats s, IdentityKeys k) throws Exception {
		List<String> keys = toLowerKeys(k);
		String col = getAttendanceUserColumn();
		String sql = "SELECT "
				+ "COALESCE(SUM(CASE WHEN status IN ('Present','In Progress','Half Day','On Break') THEN 1 ELSE 0 END),0) p, "
				+ "COALESCE(SUM(CASE WHEN status='Absent' THEN 1 ELSE 0 END),0) ab "
				+ "FROM attendance WHERE DATE(punch_date) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) "
				+ "AND LOWER(TRIM(" + col + ")) IN " + inClause(keys.size());
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			bindKeys(ps, keys, 1);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				int p = rs.getInt("p");
				int ab = rs.getInt("ab");
				s.presentDays7d = p;
				s.attendanceRate7d = (p + ab) > 0 ? (p * 100 / (p + ab)) : 0;
			}
		}
	}

	private void fillLeaveStats(Stats s, IdentityKeys k) throws Exception {
		List<String> keys = toLowerKeys(k);
		String col = getLeaveUserColumn();
		String sql = "SELECT "
				+ "COALESCE(SUM(CASE WHEN UPPER(status)='PENDING' THEN 1 ELSE 0 END),0) p, "
				+ "COALESCE(SUM(CASE WHEN UPPER(status)='APPROVED' THEN 1 ELSE 0 END),0) a "
				+ "FROM leave_requests WHERE LOWER(TRIM(" + col + ")) IN " + inClause(keys.size());
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			bindKeys(ps, keys, 1);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				s.pendingLeaves = rs.getInt("p");
				s.approvedLeaves = rs.getInt("a");
			}
		}
	}

	private void fillMeetingStats(Stats s, IdentityKeys k) throws Exception {
		// meeting_participants stores user_email in most flows; use canonical email.
		if (k.email == null || k.email.trim().isEmpty())
			return;
		String sql = "SELECT COUNT(DISTINCT m.id) cnt FROM meetings m "
				+ "LEFT JOIN meeting_participants mp ON mp.meeting_id = m.id "
				+ "WHERE (mp.user_email = ? OR m.created_by = ?) AND m.end_time >= NOW()";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			ps.setString(1, k.email);
			ps.setString(2, k.email);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				s.upcomingMeetings = rs.getInt("cnt");
		}
	}

	private void fillLatestRating(Stats s, IdentityKeys k) throws Exception {
		List<String> keys = toLowerKeys(k);
		String sql = "SELECT rating FROM employee_performance "
				+ "WHERE LOWER(TRIM(employee_username)) IN " + inClause(keys.size())
				+ " ORDER BY created_at DESC LIMIT 1";
		try (Connection c = DBConnectionUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
			bindKeys(ps, keys, 1);
			ResultSet rs = ps.executeQuery();
			if (rs.next() && rs.getString("rating") != null)
				s.latestRating = rs.getString("rating");
		}
	}

	private String esc(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
	}

	private static final class IdentityKeys {
		String email;
		String username;
		String fullName;
		String role;
		String status;
	}

	private static final class Stats {
		String fullName;
		String email;
		String username;
		String role;
		String status;
		int openTasks;
		int completedTasks;
		int attendanceRate7d;
		int presentDays7d;
		int pendingLeaves;
		int approvedLeaves;
		int upcomingMeetings;
		String latestRating = "N/A";
	}
}

