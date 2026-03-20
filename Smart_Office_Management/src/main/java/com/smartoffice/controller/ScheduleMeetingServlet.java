package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.User;
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
		
		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String startTimeStr = request.getParameter("startTime");
		String endTimeStr = request.getParameter("endTime");
		String meetingLink = request.getParameter("meetingLink");
		String[] users = request.getParameterValues("participants");
		String[] teams = request.getParameterValues("teamParticipants");
		String email = (String) session.getAttribute("email");
		String role = (String) session.getAttribute("role");
		
		Set<String> finalParticipants = new HashSet<>();
		
		try {
			// Validation
			if (title == null || title.trim().isEmpty() || 
			    description == null || description.trim().isEmpty() ||
			    startTimeStr == null || endTimeStr == null) {
				
				String redirectUrl = "manager".equalsIgnoreCase(role) 
					? "/managerMeetings?error=InvalidInput" 
					: "/user?tab=meetings&error=InvalidInput";
				response.sendRedirect(request.getContextPath() + redirectUrl);
				return;
			}
			
			/* ADD INDIVIDUAL USERS */
			if (users != null) {
				for (String u : users) {
					finalParticipants.add(u);
				}
			}
			
			/* ADD TEAM MEMBERS */
			if (teams != null) {
				for (String teamId : teams) {
					List<User> members = TeamDAO.getTeamById(Integer.parseInt(teamId)).getMembers();
					for (User member : members) {
						finalParticipants.add(member.getEmail());
					}
				}
			}
			
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
			LocalDateTime start = LocalDateTime.parse(startTimeStr, formatter);
			LocalDateTime end = LocalDateTime.parse(endTimeStr, formatter);
			
			// Validate end time is after start time
			if (end.isBefore(start) || end.isEqual(start)) {
				String redirectUrl = "manager".equalsIgnoreCase(role) 
					? "/managerMeetings?error=InvalidTime" 
					: "/user?tab=meetings&error=InvalidTime";
				response.sendRedirect(request.getContextPath() + redirectUrl);
				return;
			}
			
			String sql = "INSERT INTO meetings(title, description, start_time, end_time, meeting_link, created_by) VALUES (?, ?, ?, ?, ?, ?)";
			try (Connection con = DBConnectionUtil.getConnection();
					PreparedStatement ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
				
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
				ResultSet rs = ps.getGeneratedKeys();
				
				if (rs.next()) {
					int meetingId = rs.getInt(1);
					
					/* INSERT PARTICIPANTS */
					String insert = "INSERT INTO meeting_participants(meeting_id,user_email) VALUES (?,?)";
					PreparedStatement ps2 = con.prepareStatement(insert);
					for (String participant : finalParticipants) {
					    ps2.setInt(1, meetingId);
					    ps2.setString(2, participant);
					    ps2.addBatch();
					}
					ps2.executeBatch();
				}
			}
			
			// ✅ CHANGED: Redirect to modular dashboard pages
			if ("manager".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/managerMeetings?success=MeetingScheduled");
			} else {
				response.sendRedirect(request.getContextPath() + "/user?tab=meetings&success=MeetingScheduled");
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			String redirectUrl = "manager".equalsIgnoreCase(role) 
				? "/managerMeetings?error=ServerError" 
				: "/user?tab=meetings&error=ServerError";
			response.sendRedirect(request.getContextPath() + redirectUrl);
		}
	}
}