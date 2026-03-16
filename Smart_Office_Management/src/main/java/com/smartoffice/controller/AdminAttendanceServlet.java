package com.smartoffice.controller;

import java.io.IOException;
import java.util.Calendar;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.dao.DesignationDAO;
import com.smartoffice.model.AdminAttendanceRow;

@SuppressWarnings("serial")
@WebServlet({"/adminAttendance", "/AdminAttendance"})
public class AdminAttendanceServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}
		
		String search = request.getParameter("search");
		String department = request.getParameter("department");

		if (search == null) search = "";
		if (department == null) department = "";

		search = search.toLowerCase().trim();
		department = department.trim();

		try {
			AttendanceDAO attendanceDAO = new AttendanceDAO();
			List<AdminAttendanceRow> rows = attendanceDAO.getAllAttendanceForToday();
			List<AdminAttendanceRow> filteredRows = new java.util.ArrayList<>();

			int totalPresent = 0;
			int onBreakCount = 0;
			int lateArrivals = 0;
			int absentCount = 0;

			// Late threshold: 9:30 AM
			Calendar lateCal = Calendar.getInstance();
			lateCal.set(Calendar.HOUR_OF_DAY, 9);
			lateCal.set(Calendar.MINUTE, 30);
			lateCal.set(Calendar.SECOND, 0);
			long lateThresholdMs = lateCal.getTimeInMillis();

			for (AdminAttendanceRow row : rows) {

				String name = row.getFullName() != null ? row.getFullName().toLowerCase() : "";
				String designation = row.getDesignation() != null ? row.getDesignation() : "";

				// SEARCH FILTER
				if (!search.isEmpty() && !name.contains(search)) {
					continue;
				}

				// DESIGNATION FILTER
				if (!department.isEmpty() && !department.equalsIgnoreCase(designation)) {
					continue;
				}

				String email = row.getEmail();

				// Break duration
				int secs = 0;
				try {
					secs = BreakDAO.getTodayTotalSeconds(email);
				} catch (Exception e) { }

				row.setBreakDurationFormatted(formatBreakDuration(secs));

				// Live status
				try {
					if (BreakDAO.isCurrentlyOnBreak(email)) {
						row.setLiveStatus("ON BREAK");
						onBreakCount++;
					}
				} catch (Exception e) { }

				// Attendance counts
				if (row.getPunchIn() == null) {
					absentCount++;
				} else {
					totalPresent++;

					if ("ON BREAK".equals(row.getLiveStatus())) {
						// already counted
					} else if (row.getPunchIn().getTime() > lateThresholdMs) {
						lateArrivals++;
					}
				}

				filteredRows.add(row);
			}

			request.setAttribute("attendanceList", filteredRows);
			request.setAttribute("totalPresent", totalPresent);
			request.setAttribute("onBreakCount", onBreakCount);
			request.setAttribute("lateArrivals", lateArrivals);
			request.setAttribute("absentCount", absentCount);
			request.setAttribute("designations", new DesignationDAO().getActiveDesignations());
			request.getRequestDispatcher("AdminAttendance.jsp").forward(request, response);

		} catch (Exception e) {
			throw new ServletException("Error loading admin attendance", e);
		}
	}

	private static String formatBreakDuration(int totalSeconds) {
		if (totalSeconds <= 0) return "--";
		int h = totalSeconds / 3600;
		int m = (totalSeconds % 3600) / 60;
		if (h > 0) return h + "h " + m + "m";
		return m + "m";
	}
}
