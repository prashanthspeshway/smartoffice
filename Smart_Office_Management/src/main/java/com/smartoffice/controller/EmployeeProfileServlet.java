package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.AttendanceLogEntry;
import com.smartoffice.model.LeaveRequest;
import com.smartoffice.model.Team;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/employeeProfile")
public class EmployeeProfileServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		String email = req.getParameter("email");
		if (email == null || email.trim().isEmpty()) {
			resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			return;
		}

		resp.setContentType("application/json; charset=UTF-8");

		try {
			StringBuilder json = new StringBuilder("{");

			// 1. Personal Info
			json.append("\"info\":");
			appendPersonalInfo(json, email);
			json.append(",");

			// 2. Attendance Stats
			json.append("\"attendance\":");
			appendAttendanceStats(json, email);
			json.append(",");

			// 3. Leave Summary
			json.append("\"leaves\":");
			appendLeaveData(json, email);
			json.append(",");

			// 4. Team & Manager Info
			json.append("\"team\":");
			appendTeamInfo(json, email);

			json.append("}");
			resp.getWriter().write(json.toString());

		} catch (Exception e) {
			e.printStackTrace();
			resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			resp.getWriter().write("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
		}
	}

	// personal info
	private void appendPersonalInfo(StringBuilder json, String email) throws Exception {
		String sql = "SELECT firstname, lastname, email, phone, role, status, designation, joinedDate FROM users WHERE email = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				String first = nullToEmpty(rs.getString("firstname"));
				String last = nullToEmpty(rs.getString("lastname"));
				String fullName = (first + " " + last).trim();
				if (fullName.isEmpty())
					fullName = email;

				String role = nullToEmpty(rs.getString("role"));
				if ("user".equalsIgnoreCase(role.trim()))
					role = "employee";

				String joined = "";
				java.sql.Date jd = rs.getDate("joinedDate");
				if (jd != null)
					joined = new SimpleDateFormat("dd MMM yyyy").format(jd);

				// initials for avatar
				String[] parts = fullName.trim().split("\\s+");
				String initials = parts.length >= 2
						? ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
						: fullName.length() >= 2 ? fullName.substring(0, 2).toUpperCase() : fullName.toUpperCase();

				json.append("{").append("\"fullName\":\"").append(escapeJson(fullName)).append("\",")
						.append("\"initials\":\"").append(escapeJson(initials)).append("\",").append("\"email\":\"")
						.append(escapeJson(nullToEmpty(rs.getString("email")))).append("\",").append("\"phone\":\"")
						.append(escapeJson(nullToEmpty(rs.getString("phone")))).append("\",").append("\"role\":\"")
						.append(escapeJson(role)).append("\",").append("\"status\":\"")
						.append(escapeJson(nullToEmpty(rs.getString("status")))).append("\",")
						.append("\"designation\":\"").append(escapeJson(nullToEmpty(rs.getString("designation"))))
						.append("\",").append("\"joinedDate\":\"").append(escapeJson(joined)).append("\"").append("}");
			} else {
				json.append("null");
			}
		}
	}

	// Attendence status
	private void appendAttendanceStats(StringBuilder json, String email) throws Exception {
		String sql = "SELECT "
				+ "SUM(CASE WHEN punch_in IS NOT NULL AND punch_out IS NOT NULL THEN 1 ELSE 0 END) AS present_count, "
				+ "SUM(CASE WHEN punch_in IS NOT NULL AND punch_out IS NULL THEN 1 ELSE 0 END) AS halfday_count, "
				+ "SUM(CASE WHEN punch_in IS NULL THEN 1 ELSE 0 END) AS absent_count, " + "COUNT(*) AS total_days "
				+ "FROM attendance "
				+ "WHERE (user_email = ? OR username = (SELECT username FROM users WHERE email = ? LIMIT 1)) "
				+ "AND MONTH(punch_date) = MONTH(CURDATE()) AND YEAR(punch_date) = YEAR(CURDATE())";

		AttendanceDAO dao = new AttendanceDAO();
		List<AttendanceLogEntry> recent = dao.getRecentAttendance(email, 5);

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);
			ps.setString(2, email);
			ResultSet rs = ps.executeQuery();

			int present = 0, halfday = 0, absent = 0, total = 0;
			if (rs.next()) {
				present = rs.getInt("present_count");
				halfday = rs.getInt("halfday_count");
				absent = rs.getInt("absent_count");
				total = rs.getInt("total_days");
			}

			json.append("{").append("\"presentCount\":").append(present).append(",").append("\"halfdayCount\":")
					.append(halfday).append(",").append("\"absentCount\":").append(absent).append(",")
					.append("\"totalDays\":").append(total).append(",").append("\"recentLog\":[");

			SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM");
			SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

			for (int i = 0; i < recent.size(); i++) {
				AttendanceLogEntry e = recent.get(i);
				String dateStr = e.getAttendanceDate() != null ? dateFmt.format(e.getAttendanceDate()) : "--";
				String inStr = e.getPunchIn() != null ? timeFmt.format(e.getPunchIn()) : "--";
				String outStr = e.getPunchOut() != null ? timeFmt.format(e.getPunchOut()) : "--";
				json.append("{").append("\"date\":\"").append(escapeJson(dateStr)).append("\",")
						.append("\"punchIn\":\"").append(escapeJson(inStr)).append("\",").append("\"punchOut\":\"")
						.append(escapeJson(outStr)).append("\",").append("\"status\":\"")
						.append(escapeJson(nullToEmpty(e.getStatus()))).append("\"").append("}");
				if (i < recent.size() - 1)
					json.append(",");
			}
			json.append("]}");
		}
	}

	// Leave Data
	private void appendLeaveData(StringBuilder json, String email) throws Exception {
		LeaveRequestDAO dao = new LeaveRequestDAO();
		List<LeaveRequest> leaves = dao.getLeavesByUsername(email);

		// Count by status
		int pending = 0, approved = 0, rejected = 0;
		for (LeaveRequest lr : leaves) {
			String s = lr.getStatus() != null ? lr.getStatus().toUpperCase() : "";
			if ("PENDING".equals(s))
				pending++;
			else if ("APPROVED".equals(s))
				approved++;
			else if ("REJECTED".equals(s))
				rejected++;
		}

		SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy");

		json.append("{").append("\"total\":").append(leaves.size()).append(",").append("\"pending\":").append(pending)
				.append(",").append("\"approved\":").append(approved).append(",").append("\"rejected\":")
				.append(rejected).append(",").append("\"recent\":[");

		// Show last 5 leave requests
		int limit = Math.min(5, leaves.size());
		for (int i = 0; i < limit; i++) {
			LeaveRequest lr = leaves.get(i);
			String from = lr.getFromDate() != null ? fmt.format(lr.getFromDate()) : "--";
			String to = lr.getToDate() != null ? fmt.format(lr.getToDate()) : "--";

			// Calculate days
			long days = 1;
			if (lr.getFromDate() != null && lr.getToDate() != null) {
				days = ((lr.getToDate().getTime() - lr.getFromDate().getTime()) / (1000 * 60 * 60 * 24)) + 1;
			}

			json.append("{").append("\"type\":\"").append(escapeJson(nullToEmpty(lr.getLeaveType()))).append("\",")
					.append("\"from\":\"").append(escapeJson(from)).append("\",").append("\"to\":\"")
					.append(escapeJson(to)).append("\",").append("\"days\":").append(days).append(",")
					.append("\"status\":\"").append(escapeJson(nullToEmpty(lr.getStatus()))).append("\"").append("}");
			if (i < limit - 1)
				json.append(",");
		}
		json.append("]}");
	}

	private void appendTeamInfo(StringBuilder json, String email) throws Exception {
		List<Team> teams = TeamDAO.getTeamsForMember(email);

		json.append("{\"teams\":[");
		for (int i = 0; i < teams.size(); i++) {
			Team t = teams.get(i);
			int memberCount = t.getMembers() != null ? t.getMembers().size() : 0;
			json.append("{").append("\"name\":\"").append(escapeJson(nullToEmpty(t.getName()))).append("\",")
					.append("\"manager\":\"").append(escapeJson(nullToEmpty(t.getManagerFullname()))).append("\",")
					.append("\"managerEmail\":\"").append(escapeJson(nullToEmpty(t.getManagerUsername()))).append("\",")
					.append("\"memberCount\":").append(memberCount).append("}");
			if (i < teams.size() - 1)
				json.append(",");
		}
		json.append("]}");
	}

	private String nullToEmpty(String s) {
		return s != null ? s : "";
	}

	private String escapeJson(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t",
				"\\t");
	}
}