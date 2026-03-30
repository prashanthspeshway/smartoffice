package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
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
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/adminMeetings")
public class AdminMeetingsServlet extends HttpServlet {

    private static final SimpleDateFormat DISPLAY_FMT =
            new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action     = req.getParameter("action");
        String adminEmail = (String) session.getAttribute("username");
        MeetingDao meetingDao = new MeetingDao();

        try {
            if ("participants".equals(action)) {
                resp.setContentType("application/json; charset=UTF-8");
                int meetingId = Integer.parseInt(req.getParameter("id"));
                List<MeetingParticipant> parts = meetingDao.getMeetingParticipants(meetingId);

                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < parts.size(); i++) {
                    MeetingParticipant p = parts.get(i);
                    json.append("{")
                        .append("\"name\":\"").append(escapeJson(p.getFullName())).append("\",")
                        .append("\"role\":\"").append(escapeJson(p.getRole())).append("\"")
                        .append("}");
                    if (i < parts.size() - 1) json.append(",");
                }
                json.append("]");

                resp.getWriter().write(json.toString());
                return;
            }

            List<Meeting> meetings = MeetingDao.getTodayMeetings(adminEmail);
            List<User>    users    = UserDao.getAllUsers();
            List<Team>    teams    = TeamDAO.getAllTeams();

            for (Meeting m : meetings) {
                List<MeetingParticipant> mp = meetingDao.getMeetingParticipants(m.getId());
                m.setParticipantCount(mp.size());
            }

            req.setAttribute("meetings", meetings);
            req.setAttribute("users",    users);
            req.setAttribute("teams",    teams);

            req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading meetings: " + e.getMessage());
            req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        MeetingDao meetingDao = new MeetingDao();

        try {
            if ("create".equals(action)) {
                String adminEmail = (String) session.getAttribute("username");
                String adminName  = getDisplayName(session);
                String title      = req.getParameter("title");
                String startTime  = req.getParameter("startTime");

                List<String> participantEmails = createMeeting(req, meetingDao, session);

                String msg = "📅 Meeting scheduled by Admin " + adminName +
                             ": \"" + title + "\" on " + formatDateTime(startTime);

                NotificationService.notifyMany(
                        participantEmails, adminEmail,
                        NotificationService.TYPE_MEETING, msg);

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

    private List<String> createMeeting(HttpServletRequest req,
            MeetingDao meetingDao, HttpSession session) throws Exception {

        String title           = req.getParameter("title");
        String description     = req.getParameter("description");
        String startTimeStr    = req.getParameter("startTime");
        String endTimeStr      = req.getParameter("endTime");
        String meetingLink     = req.getParameter("meetingLink");
        String participantType = req.getParameter("participantType");

        Timestamp startTs = Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00");
        Timestamp endTs = Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00");
        // Match datetime-local (minute precision): reject only if start minute is before current minute
        LocalDateTime startMinute = startTs.toLocalDateTime().withSecond(0).withNano(0);
        LocalDateTime nowMinute = LocalDateTime.now().withSecond(0).withNano(0);
        if (startMinute.isBefore(nowMinute)) {
            throw new Exception("Start time cannot be in the past");
        }
        if (!endTs.after(startTs)) {
            throw new Exception("End time must be after start time");
        }

        Meeting meeting = new Meeting();
        meeting.setTitle(title);
        meeting.setDescription(description);
        meeting.setStartTime(startTs);
        meeting.setEndTime(endTs);
        meeting.setMeetingLink(meetingLink);
        meeting.setCreatedBy((String) session.getAttribute("username"));

        int meetingId = meetingDao.createMeeting(meeting);

        List<String> participantEmails = new ArrayList<>();
        if (participantType != null) {
            switch (participantType) {
                case "specific":
                    String[] sel = req.getParameterValues("participants");
                    if (sel != null) participantEmails.addAll(Arrays.asList(sel));
                    break;
                case "team":
                    String teamIdStr = req.getParameter("teamId");
                    if (teamIdStr != null && !teamIdStr.isEmpty())
                        participantEmails.addAll(
                                meetingDao.getTeamMemberEmails(Integer.parseInt(teamIdStr)));
                    break;
                case "allManagers":
                    participantEmails.addAll(meetingDao.getAllManagerEmails()); break;
                case "allEmployees":
                    participantEmails.addAll(meetingDao.getAllEmployeeEmails()); break;
                case "everyone":
                    participantEmails.addAll(meetingDao.getAllManagerEmails());
                    participantEmails.addAll(meetingDao.getAllEmployeeEmails()); break;
            }
        }

        List<String> unique = new ArrayList<>();
        for (String e : participantEmails)
            if (!unique.contains(e)) unique.add(e);

        if (!unique.isEmpty()) meetingDao.addParticipants(meetingId, unique);
        return unique;
    }

    private void updateMeeting(HttpServletRequest req, MeetingDao meetingDao) throws Exception {
        Meeting meeting = new Meeting();
        meeting.setId(Integer.parseInt(req.getParameter("id")));
        meeting.setTitle(req.getParameter("title"));
        meeting.setDescription(req.getParameter("description"));
        meeting.setStartTime(Timestamp.valueOf(req.getParameter("startTime").replace("T", " ") + ":00"));
        meeting.setEndTime(Timestamp.valueOf(req.getParameter("endTime").replace("T", " ") + ":00"));
        meeting.setMeetingLink(req.getParameter("meetingLink"));
        meetingDao.updateMeeting(meeting);
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

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}