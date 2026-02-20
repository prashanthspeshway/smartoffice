package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/schedulemeeting")
public class ScheduleMeetingServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String startTime = request.getParameter("startTime");
		String endTime = request.getParameter("endTime");
		String meetingLink = request.getParameter("meetingLink");

		String manager = (String) request.getSession().getAttribute("username");

		try (Connection con = DBConnectionUtil.getConnection()) {

			PreparedStatement ps = con.prepareStatement(
					"INSERT INTO meetings (title, description, start_time, end_time, meeting_link, created_by) "
							+ "VALUES (?, ?, ?, ?, ?, ?)");

			ps.setString(1, title);
			ps.setString(2, description);
			ps.setTimestamp(3, Timestamp.valueOf(startTime.replace("T", " ") + ":00"));
			ps.setTimestamp(4, Timestamp.valueOf(endTime.replace("T", " ") + ":00"));
			ps.setString(5, meetingLink);
			ps.setString(6, manager);

			ps.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/manager?error=MeetingFailed");
			return;
		}

		// ✅ Redirect back to MANAGER CONTROLLER (NOT JSP)
		response.sendRedirect(request.getContextPath() + "/manager?tab=schedulemeeting&success=MeetingScheduled");
	}
}