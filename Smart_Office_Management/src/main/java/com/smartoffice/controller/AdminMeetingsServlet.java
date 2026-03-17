package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.MeetingParticipant;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/adminMeetings")
public class AdminMeetingsServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
			throws ServletException, IOException {
		
		// Check admin authorization
		HttpSession session = req.getSession(false);
		if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp");
			return;
		}

		String action = req.getParameter("action");
		MeetingDao meetingDao = new MeetingDao();

		try {
			if ("view".equals(action)) {
				// View meeting details with participants
				int meetingId = Integer.parseInt(req.getParameter("id"));
				List<MeetingParticipant> participants = meetingDao.getMeetingParticipants(meetingId);
				req.setAttribute("participants", participants);
				req.setAttribute("meetingId", meetingId);
				req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);
				return;
			}

			// Default: Load all data for the meetings page
			String adminEmail = (String) session.getAttribute("email");
			List<Meeting> meetings = meetingDao.getMeetingsByAdmin(adminEmail);
			List<User> users = UserDao.getAllUsers();
			List<Team> teams = TeamDAO.getAllTeams();

			req.setAttribute("meetings", meetings);
			req.setAttribute("users", users);
			req.setAttribute("teams", teams);
			req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);

		} catch (Exception e) {
			e.printStackTrace();
			req.setAttribute("error", "Error loading meetings: " + e.getMessage());
			req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);
		}
	}

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
			throws ServletException, IOException {
		
		// Check admin authorization
		HttpSession session = req.getSession(false);
		if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp");
			return;
		}

		String action = req.getParameter("action");
		MeetingDao meetingDao = new MeetingDao();

		try {
			if ("create".equals(action)) {
				createMeeting(req, meetingDao, session);
				resp.sendRedirect(req.getContextPath() + "/adminMeetings?success=Meeting created successfully");
				return;
			}

			if ("delete".equals(action)) {
				int meetingId = Integer.parseInt(req.getParameter("id"));
				meetingDao.deleteMeeting(meetingId);
				resp.sendRedirect(req.getContextPath() + "/adminMeetings?success=Meeting deleted successfully");
				return;
			}

			if ("update".equals(action)) {
				updateMeeting(req, meetingDao);
				resp.sendRedirect(req.getContextPath() + "/adminMeetings?success=Meeting updated successfully");
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/adminMeetings?error=" + e.getMessage());
		}
	}

	private void createMeeting(HttpServletRequest req, MeetingDao meetingDao, HttpSession session) 
			throws Exception {
		
		// Parse meeting details
		String title = req.getParameter("title");
		String description = req.getParameter("description");
		String startTimeStr = req.getParameter("startTime");
		String endTimeStr = req.getParameter("endTime");
		String meetingLink = req.getParameter("meetingLink");
		String participantType = req.getParameter("participantType");

		// Create meeting object
		Meeting meeting = new Meeting();
		meeting.setTitle(title);
		meeting.setDescription(description);
		meeting.setStartTime(Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00"));
		meeting.setEndTime(Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00"));
		meeting.setMeetingLink(meetingLink);
		meeting.setCreatedBy((String) session.getAttribute("email"));

		// Insert meeting and get generated ID
		int meetingId = meetingDao.createMeeting(meeting);

		// Collect participant emails based on type
		List<String> participantEmails = new ArrayList<>();

		switch (participantType) {
			case "specific":
				// Specific users selected
				String[] selectedUsers = req.getParameterValues("participants");
				if (selectedUsers != null) {
					participantEmails.addAll(Arrays.asList(selectedUsers));
				}
				break;

			case "team":
				// Entire team selected
				String teamIdStr = req.getParameter("teamId");
				if (teamIdStr != null && !teamIdStr.isEmpty()) {
					int teamId = Integer.parseInt(teamIdStr);
					participantEmails.addAll(meetingDao.getTeamMemberEmails(teamId));
				}
				break;

			case "allManagers":
				// All managers
				participantEmails.addAll(meetingDao.getAllManagerEmails());
				break;

			case "allEmployees":
				// All employees
				participantEmails.addAll(meetingDao.getAllEmployeeEmails());
				break;

			case "everyone":
				// All users (managers + employees)
				participantEmails.addAll(meetingDao.getAllManagerEmails());
				participantEmails.addAll(meetingDao.getAllEmployeeEmails());
				break;
		}

		// Remove duplicates
		List<String> uniqueEmails = new ArrayList<>();
		for (String email : participantEmails) {
			if (!uniqueEmails.contains(email)) {
				uniqueEmails.add(email);
			}
		}

		// Add participants to the meeting
		if (!uniqueEmails.isEmpty()) {
			meetingDao.addParticipants(meetingId, uniqueEmails);
		}
	}

	private void updateMeeting(HttpServletRequest req, MeetingDao meetingDao) 
			throws Exception {
		
		int meetingId = Integer.parseInt(req.getParameter("id"));
		String title = req.getParameter("title");
		String description = req.getParameter("description");
		String startTimeStr = req.getParameter("startTime");
		String endTimeStr = req.getParameter("endTime");
		String meetingLink = req.getParameter("meetingLink");

		Meeting meeting = new Meeting();
		meeting.setId(meetingId);
		meeting.setTitle(title);
		meeting.setDescription(description);
		meeting.setStartTime(Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00"));
		meeting.setEndTime(Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00"));
		meeting.setMeetingLink(meetingLink);

		meetingDao.updateMeeting(meeting);
	}
}