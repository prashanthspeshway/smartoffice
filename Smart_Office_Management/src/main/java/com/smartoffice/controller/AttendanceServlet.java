package com.smartoffice.controller;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.model.AttendanceLogEntry;
import com.smartoffice.utils.AuthRedirectUtil;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}

		String username = (String) session.getAttribute("username");
		AttendanceDAO dao = new AttendanceDAO();

		try {
			java.sql.ResultSet rs = dao.getTodayAttendance(username);
			if (rs != null && rs.next()) {
				request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
				request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
			}

			request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
			request.setAttribute("breakLogs", BreakDAO.getTodayBreaks(username));
			request.setAttribute("onBreak", BreakDAO.isCurrentlyOnBreak(username));

			setBlockAttributes(request, username, dao);

			String period = request.getParameter("period");
			String fromDate = request.getParameter("fromDate");
			String toDate = request.getParameter("toDate");

			if (period == null || period.isEmpty())
				period = "all";

			DateTimeFormatter iso = DateTimeFormatter.ofPattern("yyyy-MM-dd");
			LocalDate today = LocalDate.now();

			List<AttendanceLogEntry> attendanceLog;

			switch (period) {
			case "week":
				String weekFrom = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).format(iso);
				String weekTo = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY)).format(iso);
				attendanceLog = dao.getAttendanceLogByRange(username, weekFrom, weekTo);
				break;

			case "month":
				String monthFrom = today.with(TemporalAdjusters.firstDayOfMonth()).format(iso);
				String monthTo = today.with(TemporalAdjusters.lastDayOfMonth()).format(iso);
				attendanceLog = dao.getAttendanceLogByRange(username, monthFrom, monthTo);
				break;

			case "custom":
				if (fromDate != null && !fromDate.isEmpty() && toDate != null && !toDate.isEmpty()) {
					attendanceLog = dao.getAttendanceLogByRange(username, fromDate, toDate);
				} else {
					attendanceLog = dao.getFullAttendanceLog(username);
					period = "all";
				}
				break;

			default:
				attendanceLog = dao.getFullAttendanceLog(username);
				break;
			}

			request.setAttribute("attendanceLog", attendanceLog);
			request.setAttribute("filterPeriod", period);
			request.setAttribute("filterFrom", fromDate);
			request.setAttribute("filterTo", toDate);

		} catch (Exception e) {
			throw new ServletException("Error loading attendance page", e);
		}

		request.getRequestDispatcher("userAttendance.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			AuthRedirectUtil.sendTopWindowRedirect(request, response, "/index.html");
			return;
		}

		String username = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");
		String action = request.getParameter("action");

		AttendanceDAO dao = new AttendanceDAO();

		try {
			java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
			String blockReason = null;
			try {
				blockReason = dao.getBlockReason(username, today);
			} catch (Exception blockCheckEx) {
				System.err.println("[AttendanceServlet] Block check failed: " + blockCheckEx.getMessage());
			}

			if (blockReason != null) {

				String errorCode = resolveErrorCode(blockReason);
				redirectWithError(response, request.getContextPath(), role, errorCode);
				return;
			}

			String success = "";
			if ("punchin".equalsIgnoreCase(action)) {
				dao.punchIn(username);
				success = "PunchIn";
			} else if ("punchout".equalsIgnoreCase(action)) {
				dao.punchOut(username);
				success = "PunchOut";
			}

			redirectWithSuccess(response, request.getContextPath(), role, success);

		} catch (Exception e) {
			String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
			String errorCode = msg.contains("leave") ? "OnLeave"
					: msg.contains("holiday") ? "Holiday" : msg.contains("weekend") ? "Weekend" : "AttendanceError";
			redirectWithError(response, request.getContextPath(), role, errorCode);
		}
	}

	private void setBlockAttributes(HttpServletRequest request, String username, AttendanceDAO dao) {
		java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

		// On Leave
		boolean isOnLeave = false;
		try {
			isOnLeave = dao.isOnApprovedLeaveOn(username, today);
		} catch (Exception e) {
			System.err.println("[AttendanceServlet] Leave check error: " + e.getMessage());
		}
		request.setAttribute("isOnLeave", isOnLeave);
		// weekend
		java.util.Calendar cal = java.util.Calendar.getInstance();
		int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
		boolean isWeekend = (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY);

		boolean isHoliday = false;
		String holidayName = "";
		if (!isWeekend && !isOnLeave) {
			try (java.sql.Connection con = DBConnectionUtil.getConnection();
					java.sql.PreparedStatement ps = con
							.prepareStatement("SELECT COALESCE(holiday_name, '') AS holiday_name "
									+ "FROM holidays WHERE holiday_date = ?")) {
				ps.setDate(1, today);
				java.sql.ResultSet rs = ps.executeQuery();
				if (rs.next()) {
					isHoliday = true;
					holidayName = rs.getString("holiday_name");
					if (holidayName == null)
						holidayName = "";
				}
			} catch (Exception e) {
				System.err.println("[AttendanceServlet] Holiday check error: " + e.getMessage());
			}
		}
		request.setAttribute("isHoliday", isHoliday);
		request.setAttribute("holidayName", holidayName);

		String blockReason = "";
		try {
			String reason = dao.getBlockReason(username, today);
			if (reason != null)
				blockReason = reason;
		} catch (Exception e) {
			System.err.println("[AttendanceServlet] BlockReason error: " + e.getMessage());
		}
		request.setAttribute("blockReason", blockReason);
	}

	private String resolveErrorCode(String blockReason) {
		if (blockReason == null)
			return "AttendanceError";
		String lower = blockReason.toLowerCase();
		if (lower.contains("leave"))
			return "OnLeave";
		if (lower.contains("holiday"))
			return "Holiday";
		if (lower.contains("weekend"))
			return "Weekend";
		return "AttendanceError";
	}

	private void redirectWithSuccess(HttpServletResponse response, String ctx, String role, String success)
			throws IOException {
		if ("admin".equalsIgnoreCase(role)) {
			response.sendRedirect(ctx + "/adminAttendance?success=" + success);
		} else if ("manager".equalsIgnoreCase(role)) {
			response.sendRedirect(ctx + "/managerAttendance?success=" + success);
		} else {
			response.sendRedirect(ctx + "/attendance?success=" + success);
		}
	}

	private void redirectWithError(HttpServletResponse response, String ctx, String role, String error)
			throws IOException {
		if ("admin".equalsIgnoreCase(role)) {
			response.sendRedirect(ctx + "/adminAttendance?error=" + error);
		} else if ("manager".equalsIgnoreCase(role)) {
			response.sendRedirect(ctx + "/managerAttendance?error=" + error);
		} else {
			response.sendRedirect(ctx + "/attendance?error=" + error);
		}
	}
}