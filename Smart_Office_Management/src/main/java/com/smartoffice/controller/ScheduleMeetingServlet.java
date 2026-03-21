package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
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
import com.smartoffice.service.NotificationService;

/**
 * Handles /schedulemeeting — the URL that managerMeetings.jsp form posts to.
 * Saves the meeting and fires notifications to all participants + admins.
 */
@SuppressWarnings("serial")
@WebServlet("/schedulemeeting")
public class ScheduleMeetingServlet extends HttpServlet {

    private static final SimpleDateFormat DISPLAY_FMT =
            new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String managerEmail = (String) session.getAttribute("username");
        String managerName  = getDisplayName(session);
        String role         = (String) session.getAttribute("role");

        try {
            String title       = request.getParameter("title");
            String description = request.getParameter("description");
            String startStr    = request.getParameter("startTime");
            String endStr      = request.getParameter("endTime");
            String meetingLink = request.getParameter("meetingLink");

            // Validate
            if (title == null || title.isEmpty() ||
                startStr == null || startStr.isEmpty() ||
                endStr == null || endStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/managerMeetings?error=InvalidInput");
                return;
            }

            Timestamp startTime = Timestamp.valueOf(startStr.replace("T", " ") + ":00");
            Timestamp endTime   = Timestamp.valueOf(endStr.replace("T", " ") + ":00");

            if (endTime.before(startTime)) {
                response.sendRedirect(request.getContextPath() + "/managerMeetings?error=InvalidTime");
                return;
            }

            // Build meeting object
            com.smartoffice.model.Meeting meeting = new com.smartoffice.model.Meeting();
            meeting.setTitle(title);
            meeting.setDescription(description);
            meeting.setStartTime(startTime);
            meeting.setEndTime(endTime);
            meeting.setMeetingLink(meetingLink);
            meeting.setCreatedBy(managerEmail);

            MeetingDao meetingDao = new MeetingDao();
            int meetingId = meetingDao.createMeeting(meeting);

            // Collect participants — supports both "participants" checkboxes
            // and the participantType radio pattern
            List<String> participantEmails = new ArrayList<>();
            String participantType = request.getParameter("participantType");

            if (participantType != null && !participantType.isEmpty()) {
                switch (participantType) {
                    case "specific":
                        String[] sel = request.getParameterValues("participants");
                        if (sel != null) participantEmails.addAll(Arrays.asList(sel));
                        break;
                    case "team":
                        String teamIdStr = request.getParameter("teamId");
                        if (teamIdStr != null && !teamIdStr.isEmpty())
                            participantEmails.addAll(
                                    meetingDao.getTeamMemberEmails(Integer.parseInt(teamIdStr)));
                        break;
                    case "allEmployees":
                        participantEmails.addAll(meetingDao.getAllEmployeeEmails()); break;
                    case "everyone":
                        participantEmails.addAll(meetingDao.getAllManagerEmails());
                        participantEmails.addAll(meetingDao.getAllEmployeeEmails()); break;
                }
            } else {
                // managerMeetings.jsp uses plain "participants" checkboxes
                String[] sel = request.getParameterValues("participants");
                if (sel != null) participantEmails.addAll(Arrays.asList(sel));
            }

            // Deduplicate
            List<String> unique = new ArrayList<>();
            for (String e : participantEmails)
                if (!unique.contains(e)) unique.add(e);

            if (!unique.isEmpty()) meetingDao.addParticipants(meetingId, unique);

            // ── NOTIFICATIONS ───────────────────────────────────────
            String startFmt = formatDateTime(startStr);
            String roleLabel = "Manager".equalsIgnoreCase(role) ? "Manager" : "User";

            // Notify all participants
            if (!unique.isEmpty()) {
                String participantMsg = "📅 Meeting scheduled by " + roleLabel + " " + managerName +
                                       ": \"" + title + "\" on " + startFmt;
                NotificationService.notifyMany(
                        unique, managerEmail,
                        NotificationService.TYPE_MEETING, participantMsg);
            }

            // Notify all admins about the new meeting
            NotificationService.notifyAllAdmins(
                    managerEmail,
                    NotificationService.TYPE_MEETING,
                    "📅 " + roleLabel + " " + managerName +
                    " scheduled meeting: \"" + title + "\" on " + startFmt);
            // ────────────────────────────────────────────────────────

            response.sendRedirect(request.getContextPath() + "/managerMeetings?success=MeetingScheduled");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/managerMeetings?error=ServerError");
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }

    private String formatDateTime(String dt) {
        try {
            return DISPLAY_FMT.format(
                    new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(dt));
        } catch (Exception e) { return dt != null ? dt : ""; }
    }
}