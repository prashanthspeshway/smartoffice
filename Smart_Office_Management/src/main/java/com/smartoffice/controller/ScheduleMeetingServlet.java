package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.model.Meeting;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/schedulemeeting")
public class ScheduleMeetingServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}

		String manager = (String) session.getAttribute("username");

		MeetingDao meetingDao = new MeetingDao();

		List<Meeting> todayMeetings = meetingDao.getTodayMeetingsForManager(manager);

		request.setAttribute("todayMeetings", todayMeetings);

		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String startTimeStr = request.getParameter("startTime");
		String endTimeStr = request.getParameter("endTime");
		String meetingLink = request.getParameter("meetingLink");
		String username = (String) session.getAttribute("username");
		String email = (String) session.getAttribute("email");


		String createdBy = (String) session.getAttribute("username");

		try {

			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

			LocalDateTime start = LocalDateTime.parse(startTimeStr, formatter);
			LocalDateTime end = LocalDateTime.parse(endTimeStr, formatter);
			
			String sql = "INSERT INTO meetings(title, description, start_time, end_time, meeting_link, created_by) VALUES (?, ?, ?, ?, ?, ?)";

			try (Connection con = DBConnectionUtil.getConnection();
			     PreparedStatement ps = con.prepareStatement(sql)) {

				ps.setString(1, title);
				ps.setString(2, description);

				ps.setTimestamp(3, Timestamp.valueOf(start));
				ps.setTimestamp(4, Timestamp.valueOf(end));

				if (meetingLink == null || meetingLink.trim().isEmpty()) {
					ps.setNull(5, java.sql.Types.VARCHAR);
				} else {
					ps.setString(5, meetingLink.trim());
				}

				ps.setString(6, email);

				ps.executeUpdate();
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		response.sendRedirect(request.getContextPath() + "/manager?tab=schedulemeeting");
	}
}