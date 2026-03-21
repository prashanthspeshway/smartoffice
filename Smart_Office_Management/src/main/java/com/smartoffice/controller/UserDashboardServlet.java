package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.dao.NotificationReadsDAO;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.AttendanceLogEntry;
import com.smartoffice.model.LeaveRequest;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Notification;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet({
    "/user",
    "/userAttendance",
    "/userTasks",
    "/userTeam",
    "/userLeave",
    "/userMeetings",
    "/userSettings",
    "/userNotifications"
})
public class UserDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String username = (String) session.getAttribute("username");
        String path = request.getServletPath(); // e.g. "/userAttendance"

        try {
            // ===== USER PROFILE (always load for settings & display) =====
            User user = UserDao.getUserByEmail(username);
            request.setAttribute("user", user);
            String fn = user != null ? user.getFullname() : null;
            if (fn != null && !fn.isEmpty()) session.setAttribute("fullName", fn);

            // ===== Shell dashboard — load all & forward to user.jsp =====
            if ("/user".equals(path)) {
                loadAll(request, username);
                request.getRequestDispatcher("user.jsp").forward(request, response);
                return;
            }

            // ===== Individual section servlets (called from iframe) =====
            switch (path) {
                case "/userAttendance":
                    loadAttendance(request, username);
                    request.getRequestDispatcher("userAttendance.jsp").forward(request, response);
                    break;

                case "/userTasks":
                    TaskDAO.deleteOldCompletedTasks();
                    request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));
                    request.getRequestDispatcher("userTasks.jsp").forward(request, response);
                    break;

                case "/userTeam":
                    request.setAttribute("myTeams", TeamDAO.getTeamsForMember(username));
                    request.getRequestDispatcher("userTeam.jsp").forward(request, response);
                    break;

                case "/userLeave":
                    request.setAttribute("myLeaves", new LeaveRequestDAO().getLeavesByUsername(username));
                    request.getRequestDispatcher("userLeave.jsp").forward(request, response);
                    break;

                case "/userMeetings":
                    request.setAttribute("meetings", loadMeetings(username));
                    request.getRequestDispatcher("userMeetings.jsp").forward(request, response);
                    break;

                case "/userSettings":
                    // user already loaded above
                    request.getRequestDispatcher("userSettings.jsp").forward(request, response);
                    break;

                case "/userNotifications":
                    request.setAttribute("notifications", new NotificationReadsDAO().getUnreadNotifications(username));
                    request.getRequestDispatcher("userNotifications.jsp").forward(request, response);
                    break;

                default:
                    response.sendRedirect("user");
            }

        } catch (Exception e) {
            throw new ServletException("Error loading user dashboard", e);
        }
    }

    // ---------------------------------------------------------------
    // Load everything (for the old /user shell if needed)
    // ---------------------------------------------------------------
    private void loadAll(HttpServletRequest request, String username) throws Exception {
        loadAttendance(request, username);
        TaskDAO.deleteOldCompletedTasks();
        request.setAttribute("tasks", TaskDAO.getTasksForEmployee(username));
        request.setAttribute("myLeaves", new LeaveRequestDAO().getLeavesByUsername(username));
        request.setAttribute("meetings", loadMeetings(username));
        request.setAttribute("myTeams", TeamDAO.getTeamsForMember(username));
        request.setAttribute("notifications", new NotificationReadsDAO().getUnreadNotifications(username));
    }

    // ---------------------------------------------------------------
    // Attendance helpers
    // ---------------------------------------------------------------
    private void loadAttendance(HttpServletRequest request, String username) throws Exception {
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        ResultSet rs = attendanceDAO.getTodayAttendance(username);
        if (rs != null && rs.next()) {
            request.setAttribute("punchIn",  rs.getTimestamp("punch_in"));
            request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
        }
        request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
        request.setAttribute("breakLogs",         BreakDAO.getTodayBreaks(username));
        request.setAttribute("onBreak",           BreakDAO.isCurrentlyOnBreak(username));

        List<AttendanceLogEntry> log = attendanceDAO.getRecentAttendance(username, 30);
        for (AttendanceLogEntry e : log) {
            e.setBreakSeconds(BreakDAO.getTotalSecondsForDate(username, e.getAttendanceDate()));
        }
        request.setAttribute("attendanceLog", log);
    }

    // ---------------------------------------------------------------
    // Meetings helper
    // ---------------------------------------------------------------
    private List<Meeting> loadMeetings(String username) throws Exception {
        List<Meeting> meetings = new ArrayList<>();
        String sql = "SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time, " +
                     "m.meeting_link, m.created_by, m.created_at, " +
                     "CONCAT(u.firstname, ' ', u.lastname) AS creator_name, u.role AS creator_role " +
                     "FROM meetings m " +
                     "LEFT JOIN meeting_participants mp ON m.id = mp.meeting_id " +
                     "LEFT JOIN users u ON m.created_by = u.email " +
                     "LEFT JOIN users emp ON emp.email = ? " +
                     "WHERE (mp.user_email = ? OR m.created_by = emp.manager_email) " +
                     "AND m.end_time >= NOW() " +
                     "ORDER BY m.start_time ASC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Meeting m = new Meeting();
                m.setId(rs.getInt("id"));
                m.setTitle(rs.getString("title"));
                m.setDescription(rs.getString("description"));
                m.setStartTime(rs.getTimestamp("start_time"));
                m.setEndTime(rs.getTimestamp("end_time"));
                m.setMeetingLink(rs.getString("meeting_link"));
                m.setCreatedBy(rs.getString("created_by"));
                m.setCreatedAt(rs.getTimestamp("created_at"));
                m.setCreatorName(rs.getString("creator_name"));
                m.setCreatorRole(rs.getString("creator_role"));
                meetings.add(m);
            }
        }
        return meetings;
    }
}