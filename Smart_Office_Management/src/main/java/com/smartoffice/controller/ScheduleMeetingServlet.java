package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/schedulemeeting")
public class ScheduleMeetingServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

		response.setContentType("text/plain");
		response.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.getWriter().write("INVALID");
			return;
		}

		String manager = (String) session.getAttribute("username");

		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String startTimeStr = request.getParameter("startTime");
		String endTimeStr = request.getParameter("endTime");
		String meetingLink = request.getParameter("meetingLink");

		if (title == null || title.trim().isEmpty() || description == null || description.trim().isEmpty()
				|| startTimeStr == null || endTimeStr == null) {

			response.getWriter().write("INVALID");
			return;
		}

		try {
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

			LocalDateTime start = LocalDateTime.parse(startTimeStr, formatter);
			LocalDateTime end = LocalDateTime.parse(endTimeStr, formatter);

			if (!end.isAfter(start)) {
				response.getWriter().write("INVALID_TIME");
				return;
			}

			String sql = """
					    INSERT INTO meetings
					    (title, description, start_time, end_time, meeting_link, created_by)
					    VALUES (?, ?, ?, ?, ?, ?)
					""";

			try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

				ps.setString(1, title);
				ps.setString(2, description);
				ps.setTimestamp(3, Timestamp.valueOf(start));
				ps.setTimestamp(4, Timestamp.valueOf(end));

				if (meetingLink == null || meetingLink.trim().isEmpty()) {
					ps.setNull(5, java.sql.Types.VARCHAR);
				} else {
					ps.setString(5, meetingLink.trim());
				}

				ps.setString(6, manager);

				int rows = ps.executeUpdate();
			}

		} catch (Exception e) {
			response.getWriter().write("ERROR");
		}
		// ✅ Redirect back to MANAGER CONTROLLER (NOT JSP)
		response.sendRedirect(request.getContextPath() + "/manager?tab=schedulemeeting&success=MeetingScheduled");
	}
}