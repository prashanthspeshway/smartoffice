package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.Team;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/managerOverview")
public class ManagerOverviewServlet extends HttpServlet {

    // ─────────────────────────────────────────────────────────────────────
    // DATA LAYOUT (verified from DB screenshots):
    //
    //  teams.manager_username          = display name  e.g. "prasad nani"
    //  team_members.username           = EMAIL         e.g. "jayanth@gmail.com"
    //                                    (TeamDAO.getTeamMembers joins tm.username = users.email)
    //  attendance.username             = display name  (users.username)
    //  attendance.user_email           = display name  (misnamed — actually stores username/display name)
    //  break_logs.username             = display name  (users.username)
    //  leave_requests.username         = display name  (users.username)
    //  tasks.assigned_by               = display name  (users.username)
    //  tasks.assigned_to               = display name  (users.username)
    //  employee_performance.manager_username = display name
    //  employee_performance.employee_username = display name
    //  meetings.created_by             = EMAIL
    //
    //  KEY FIX: getTeamMemberUsernames() must return DISPLAY NAMES (users.username),
    //  not emails, so all the attendance/break/leave queries work correctly.
    //  We get display names by joining team_members.username (email) → users.email → users.username.
    // ─────────────────────────────────────────────────────────────────────

    /** Manager's display name (used in tasks, attendance, break_logs, performance, teams) */
    private String resolveManagerUsername(HttpSession session) {
        String sessionUsername = (String) session.getAttribute("username");
        if (sessionUsername != null && !sessionUsername.trim().isEmpty()) {
            return sessionUsername.trim();
        }
        String emailAttr = (String) session.getAttribute("email");
        if (emailAttr != null && emailAttr.contains("@")) {
            try (Connection c = DBConnectionUtil.getConnection()) {
                PreparedStatement ps = c.prepareStatement(
                    "SELECT username FROM users WHERE email = ? LIMIT 1");
                ps.setString(1, emailAttr);
                ResultSet rs = ps.executeQuery();
                if (rs.next() && rs.getString("username") != null) {
                    return rs.getString("username").trim();
                }
            } catch (Exception e) { e.printStackTrace(); }
        }
        return sessionUsername;
    }

    /** Manager's email (used only for meetings.created_by) */
    private String resolveManagerEmail(HttpSession session) {
        String emailAttr = (String) session.getAttribute("email");
        if (emailAttr != null && emailAttr.contains("@")) return emailAttr;

        String sessionUsername = (String) session.getAttribute("username");
        if (sessionUsername == null) return null;
        if (sessionUsername.contains("@")) return sessionUsername;

        try (Connection c = DBConnectionUtil.getConnection()) {
            PreparedStatement ps = c.prepareStatement(
                "SELECT email FROM users WHERE username = ? LIMIT 1");
            ps.setString(1, sessionUsername);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getString("email") != null) {
                return rs.getString("email");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return sessionUsername;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (!"Manager".equalsIgnoreCase(role)) {
            response.sendRedirect("index.html?error=accessDenied");
            return;
        }

        String mgr      = resolveManagerUsername(session); // display name
        String mgrEmail = resolveManagerEmail(session);    // email (for meetings only)

        try {
            // 1. Teams
            List<Team> teams = TeamDAO.getTeamsByManager(mgr);
            int totalTeams = teams.size(), totalMembers = 0;
            for (Team t : teams) totalMembers += t.getMembers().size();
            request.setAttribute("totalTeams",   totalTeams);
            request.setAttribute("totalMembers", totalMembers);
            request.setAttribute("teams",        teams);


            // 2. Attendance + On Break
            Map<String, Integer> att = getAttendanceStats(mgr);
            request.setAttribute("presentCount", att.get("present"));
            request.setAttribute("absentCount",  att.get("absent"));
            request.setAttribute("onBreakCount", att.get("onBreak"));

            // 3. Tasks — all status values, correct pending/overdue counts
            Map<String, Integer> task = getTaskStats(mgr);
            request.setAttribute("totalTasks",      task.get("total"));
            request.setAttribute("pendingTasks",    task.get("pending"));
            request.setAttribute("completedTasks",  task.get("completed"));
            request.setAttribute("overdueTasks",    task.get("overdue"));
            request.setAttribute("processingTasks", task.get("processing"));

            // 4. Leave pending count
            int pendingLeaves = getPendingLeaveCount(mgr);
            request.setAttribute("pendingLeaves", pendingLeaves);

            // 5. Meetings (uses email)
            List<Meeting> todayMeetings = MeetingDao.getTodayMeetings(mgrEmail);
            request.setAttribute("todayMeetings", todayMeetings);
            request.setAttribute("meetingCount",  todayMeetings.size());

            // 6. Recent Activities
            request.setAttribute("recentActivities", getRecentActivities(mgr));

            // 7. Performance stats
            Map<String, Integer> perf = getPerformanceStats(mgr, totalMembers);
            request.setAttribute("ratedEmployees", perf.get("rated"));
            request.setAttribute("pendingRatings", perf.get("pending"));

            // 8. Weekly attendance chart
            Map<String, String> weekly = getWeeklyAttendance(mgr);
            request.setAttribute("weekLabels",      weekly.get("labels"));
            request.setAttribute("weekPresentData", weekly.get("present"));
            request.setAttribute("weekAbsentData",  weekly.get("absent"));

            // 9. Task status breakdown (for pie chart)
            Map<String, Integer> ts = getTaskStatusBreakdown(mgr);
            request.setAttribute("taskAssigned",   ts.get("ASSIGNED"));
            request.setAttribute("taskCompleted",  ts.get("COMPLETED"));
            request.setAttribute("taskSubmitted",  ts.get("SUBMITTED"));
            request.setAttribute("taskOverdue",    ts.get("OVERDUE"));
            request.setAttribute("taskProcessing", ts.get("PROCESSING"));

            // 10. Leave type breakdown
            Map<String, Integer> lt = getLeaveTypeBreakdown(mgr);
            request.setAttribute("leaveSick",      lt.getOrDefault("Sick",      0));
            request.setAttribute("leaveAnnual",    lt.getOrDefault("Annual",    0));
            request.setAttribute("leavePersonal",  lt.getOrDefault("Personal",  0));
            request.setAttribute("leaveMaternity", lt.getOrDefault("Maternity", 0));
            request.setAttribute("leaveOther",     lt.getOrDefault("Other",     0));

            // 11. Punch-in distribution
            Map<String, Integer> pi = getPunchInDistribution(mgr);
            request.setAttribute("punchBefore8", pi.get("before8"));
            request.setAttribute("punch8to9",    pi.get("8to9"));
            request.setAttribute("punch9to10",   pi.get("9to10"));
            request.setAttribute("punch10to11",  pi.get("10to11"));
            request.setAttribute("punchAfter11", pi.get("after11"));

            // 12. Avg work hours this week
            Map<String, String> workHours = getAvgWorkHoursThisWeek(mgr);
            request.setAttribute("workHourLabels",    workHours.get("labels"));
            request.setAttribute("workHourData",      workHours.get("data"));
            request.setAttribute("avgWorkHoursToday", workHours.get("avgToday"));

            // 13. Task priority breakdown
            Map<String, Integer> tp = getTaskPriorityBreakdown(mgr);
            request.setAttribute("taskHighPriority",   tp.get("HIGH"));
            request.setAttribute("taskMediumPriority", tp.get("MEDIUM"));
            request.setAttribute("taskLowPriority",    tp.get("LOW"));

            // 14. Leave approval stats
            Map<String, Integer> las = getLeaveApprovalStats(mgr);
            request.setAttribute("leaveApproved",     las.get("APPROVED"));
            request.setAttribute("leaveRejected",     las.get("REJECTED"));
            request.setAttribute("leavePendingCount", las.get("PENDING"));

            // 15. Performance rating distribution
            Map<String, Integer> prd = getPerformanceRatingDistribution(mgr);
            request.setAttribute("perfExcellent", prd.getOrDefault("EXCELLENCE", 0));
            request.setAttribute("perfGood",      prd.getOrDefault("GOOD",      0));
            request.setAttribute("perfAverage",   prd.getOrDefault("AVERAGE",   0));
            request.setAttribute("perfPoor",      prd.getOrDefault("POOR",      0));

            // 16. Top performers
            request.setAttribute("topPerformers", getTopPerformers(mgr));

            // 17. Overdue task employees
            request.setAttribute("overdueEmployees", getOverdueTaskEmployees(mgr));

            // 18. Monthly leave trend
            Map<String, String> leaveTrend = getMonthlyLeaveTrend(mgr);
            request.setAttribute("leaveTrendLabels", leaveTrend.get("labels"));
            request.setAttribute("leaveTrendData",   leaveTrend.get("data"));

            // 19. Avg attendance last 4 weeks
            request.setAttribute("avgAttendanceLast4Weeks", getAvgAttendanceLast4Weeks(mgr));

            // 20. Task completion trend
            Map<String, String> taskTrend = getTaskCompletionTrend(mgr);
            request.setAttribute("taskTrendLabels", taskTrend.get("labels"));
            request.setAttribute("taskTrendData",   taskTrend.get("data"));

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading dashboard data", e);
        }

        request.getRequestDispatcher("managerOverview.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────
    // HELPER: Get team member DISPLAY NAMES (users.username) for a manager.
    //
    // FIX: team_members.username stores EMAIL (confirmed by TeamDAO.getTeamMembers
    //      which does: JOIN users u ON tm.username = u.email).
    //      All other tables (attendance.user_email, break_logs.username,
    //      leave_requests.username) store DISPLAY NAMES (users.username).
    //      So we must resolve: team_members.username (email) → users.username (display name).
    // ─────────────────────────────────────────────────────────────────────
    private List<String> getTeamMemberUsernames(String mgr) {
        List<String> displayNames = new ArrayList<>();
        // Join path: teams → team_members (email) → users (display name)
        String sql =
            "SELECT DISTINCT u.username " +
            "FROM team_members tm " +
            "INNER JOIN teams t ON tm.team_id = t.id " +
            "INNER JOIN users u ON tm.username = u.email " +
            "WHERE t.manager_username = ? " +
            "  AND u.username IS NOT NULL AND u.username != ''";
        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) displayNames.add(rs.getString("username"));
        } catch (Exception e) { e.printStackTrace(); }
        return displayNames;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 2. ATTENDANCE STATS
    //
    // attendance.user_email stores display name (users.username).
    // break_logs.username   stores display name (users.username).
    //
    // On Break = has a break_logs row today where end_time IS NULL.
    // Present  = attendance status IN ('Present','In Progress','Half Day') minus on-break.
    // Absent   = attendance status = 'Absent'.
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getAttendanceStats(String mgr) {
        Map<String, Integer> s = new HashMap<>();
        s.put("present", 0); s.put("absent", 0); s.put("onBreak", 0);

        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return s;

        String inClause = buildInClause(members.size());

        // Count employees currently on break (break_logs today, end_time IS NULL)
        String breakSql =
            "SELECT COUNT(DISTINCT bl.username) cnt " +
            "FROM break_logs bl " +
            "WHERE DATE(bl.break_date) = CURDATE() " +
            "  AND bl.end_time IS NULL " +
            "  AND bl.username IN " + inClause;

        int onBreak = 0;
        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(breakSql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) onBreak = rs.getInt("cnt");
        } catch (Exception e) { e.printStackTrace(); }

        // Count present / absent from attendance table
        // attendance.user_email stores the display name (users.username)
        String attSql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN status IN ('Present','In Progress','Half Day') THEN 1 ELSE 0 END),0) p, " +
            "  COALESCE(SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END),0) ab " +
            "FROM attendance " +
            "WHERE DATE(punch_date) = CURDATE() " +
            "  AND user_email IN " + inClause;

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(attSql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int rawPresent = rs.getInt("p");
                // Subtract on-break employees from "present" count
                s.put("present", Math.max(0, rawPresent - onBreak));
                s.put("absent",  rs.getInt("ab"));
                s.put("onBreak", onBreak);
            }
        } catch (Exception e) { e.printStackTrace(); }

        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 3. TASK STATS
    //
    // tasks.assigned_by stores display name.
    // DB status values: ASSIGNED, PROCESSING, COMPLETED, SUBMITTED
    //
    // FIX 1: pending = ASSIGNED + PROCESSING (both are "pending work")
    // FIX 2: overdue = ASSIGNED or PROCESSING tasks past their deadline
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getTaskStats(String mgr) {
        Map<String, Integer> s = new HashMap<>();
        s.put("total", 0); s.put("pending", 0); s.put("completed", 0);
        s.put("overdue", 0); s.put("processing", 0);

        String sql =
            "SELECT " +
            "  COUNT(*) total, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) IN ('ASSIGNED','PROCESSING') THEN 1 ELSE 0 END),0) pending, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) = 'COMPLETED' THEN 1 ELSE 0 END),0) completed, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) = 'PROCESSING' THEN 1 ELSE 0 END),0) processing, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) = 'SUBMITTED'  THEN 1 ELSE 0 END),0) submitted, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) IN ('ASSIGNED','PROCESSING') " +
            "                     AND deadline IS NOT NULL AND deadline < CURDATE() THEN 1 ELSE 0 END),0) overdue " +
            "FROM tasks WHERE assigned_by = ?";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                s.put("total",      rs.getInt("total"));
                s.put("pending",    rs.getInt("pending"));   // ASSIGNED + PROCESSING
                s.put("completed",  rs.getInt("completed"));
                s.put("processing", rs.getInt("processing"));
                s.put("overdue",    rs.getInt("overdue"));
            }
        } catch (Exception e) { e.printStackTrace(); }

        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 4. PENDING LEAVE COUNT
    //
    // leave_requests.username stores display name.
    // FIX: was returning 0 because member list was emails; now uses display names.
    // ─────────────────────────────────────────────────────────────────────
    private int getPendingLeaveCount(String mgr) {
        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return 0;

        String sql =
            "SELECT COUNT(*) cnt FROM leave_requests " +
            "WHERE username IN " + buildInClause(members.size()) +
            "  AND UPPER(status) = 'PENDING'";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("cnt");
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 6. RECENT ACTIVITIES
    // ─────────────────────────────────────────────────────────────────────
    private List<Map<String, String>> getRecentActivities(String mgr) {
        List<Map<String, String>> list = new ArrayList<>();

        List<String> members = getTeamMemberUsernames(mgr);
        String memberIn = members.isEmpty() ? "('__none__')" : buildInClause(members.size());

        String sql =
            "SELECT type, description, user, ts FROM (" +
            "  SELECT 'Task Assigned' type, title description, assigned_to user, " +
            "         CAST(assigned_date AS CHAR) ts " +
            "  FROM tasks WHERE assigned_by = ? " +
            "  UNION ALL " +
            "  SELECT 'Leave Request', " +
            "         CONCAT(leave_type,' - ',from_date,' to ',to_date), " +
            "         username, CAST(applied_at AS CHAR) " +
            "  FROM leave_requests WHERE username IN " + memberIn +
            "  UNION ALL " +
            "  SELECT 'Meeting Scheduled', title, created_by, CAST(created_at AS CHAR) " +
            "  FROM meetings WHERE created_by = ? " +
            ") sub ORDER BY ts DESC LIMIT 8";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, mgr);
            for (String m : members) ps.setString(idx++, m);
            ps.setString(idx, resolveEmailFromUsername(mgr));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> a = new HashMap<>();
                a.put("type",        rs.getString("type"));
                a.put("description", rs.getString("description"));
                a.put("user",        rs.getString("user"));
                a.put("time",        rs.getString("ts"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 7. PERFORMANCE STATS
    //
    // FIX: filter by current month using performance_month column.
    // rated   = DISTINCT employees who have any rating this month.
    // pending = totalMembers - rated.
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getPerformanceStats(String mgr, int totalMembers) {
        Map<String, Integer> s = new HashMap<>();
        s.put("rated", 0); s.put("pending", 0);

        String sql =
            "SELECT COUNT(DISTINCT employee_username) rated " +
            "FROM employee_performance " +
            "WHERE manager_username = ? " +
            "  AND MONTH(performance_month) = MONTH(CURDATE()) " +
            "  AND YEAR(performance_month)  = YEAR(CURDATE())";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int rated = rs.getInt("rated");
                s.put("rated",   rated);
                s.put("pending", Math.max(0, totalMembers - rated));
            }
        } catch (Exception e) { e.printStackTrace(); }

        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 8. WEEKLY ATTENDANCE CHART
    // attendance.user_email = display name
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, String> getWeeklyAttendance(String mgr) {
        Map<String, String> result = new HashMap<>();
        List<String> members = getTeamMemberUsernames(mgr);

        if (members.isEmpty()) {
            result.put("labels",  "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
            result.put("present", "0,0,0,0,0,0,0");
            result.put("absent",  "0,0,0,0,0,0,0");
            return result;
        }

        String memberIn = buildInClause(members.size());
        String sql =
            "SELECT DATE_FORMAT(d.dy,'%a') lbl, " +
            "  COALESCE(SUM(CASE WHEN a.status IN ('Present','In Progress','Half Day') THEN 1 ELSE 0 END),0) p, " +
            "  COALESCE(SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END),0) ab " +
            "FROM ( " +
            "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL SELECT CURDATE()-INTERVAL 5 DAY " +
            "  UNION ALL SELECT CURDATE()-INTERVAL 4 DAY UNION ALL SELECT CURDATE()-INTERVAL 3 DAY " +
            "  UNION ALL SELECT CURDATE()-INTERVAL 2 DAY UNION ALL SELECT CURDATE()-INTERVAL 1 DAY " +
            "  UNION ALL SELECT CURDATE() " +
            ") d " +
            "LEFT JOIN attendance a ON DATE(a.punch_date) = d.dy " +
            "  AND a.user_email IN " + memberIn +
            "GROUP BY d.dy ORDER BY d.dy";

        StringBuilder lbl = new StringBuilder(), pre = new StringBuilder(), abs = new StringBuilder();
        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (lbl.length() > 0) { lbl.append(","); pre.append(","); abs.append(","); }
                lbl.append("'").append(rs.getString("lbl")).append("'");
                pre.append(rs.getInt("p"));
                abs.append(rs.getInt("ab"));
            }
        } catch (Exception e) { e.printStackTrace(); }

        result.put("labels",  lbl.length() > 0 ? lbl.toString() : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
        result.put("present", pre.length() > 0 ? pre.toString() : "0,0,0,0,0,0,0");
        result.put("absent",  abs.length() > 0 ? abs.toString() : "0,0,0,0,0,0,0");
        return result;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 9. TASK STATUS BREAKDOWN (for pie chart)
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getTaskStatusBreakdown(String mgr) {
        Map<String, Integer> s = new HashMap<>();
        s.put("ASSIGNED", 0); s.put("COMPLETED", 0);
        s.put("SUBMITTED", 0); s.put("OVERDUE", 0); s.put("PROCESSING", 0);

        String sql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN UPPER(status)='ASSIGNED'   THEN 1 ELSE 0 END),0) assigned, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status)='COMPLETED'  THEN 1 ELSE 0 END),0) completed, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status)='SUBMITTED'  THEN 1 ELSE 0 END),0) submitted, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status)='PROCESSING' THEN 1 ELSE 0 END),0) processing, " +
            "  COALESCE(SUM(CASE WHEN UPPER(status) IN ('ASSIGNED','PROCESSING') " +
            "                     AND deadline IS NOT NULL AND deadline < CURDATE() THEN 1 ELSE 0 END),0) overdue " +
            "FROM tasks WHERE assigned_by = ?";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                s.put("ASSIGNED",   rs.getInt("assigned"));
                s.put("COMPLETED",  rs.getInt("completed"));
                s.put("SUBMITTED",  rs.getInt("submitted"));
                s.put("PROCESSING", rs.getInt("processing"));
                s.put("OVERDUE",    rs.getInt("overdue"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 10. LEAVE TYPE BREAKDOWN
    // leave_requests.username = display name
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getLeaveTypeBreakdown(String mgr) {
        Map<String, Integer> types = new HashMap<>();
        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return types;

        String sql =
            "SELECT leave_type, COUNT(*) cnt FROM leave_requests " +
            "WHERE username IN " + buildInClause(members.size()) +
            " GROUP BY leave_type";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String lType = rs.getString("leave_type");
                int cnt = rs.getInt("cnt");
                if (lType == null)                                   types.merge("Other",     cnt, Integer::sum);
                else if (lType.toLowerCase().contains("sick"))       types.merge("Sick",      cnt, Integer::sum);
                else if (lType.toLowerCase().contains("annual"))     types.merge("Annual",    cnt, Integer::sum);
                else if (lType.toLowerCase().contains("earned"))     types.merge("Annual",    cnt, Integer::sum);
                else if (lType.toLowerCase().contains("casual"))     types.merge("Personal",  cnt, Integer::sum);
                else if (lType.toLowerCase().contains("personal"))   types.merge("Personal",  cnt, Integer::sum);
                else if (lType.toLowerCase().contains("maternity"))  types.merge("Maternity", cnt, Integer::sum);
                else                                                 types.merge("Other",     cnt, Integer::sum);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return types;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 11. PUNCH-IN DISTRIBUTION
    // attendance.user_email = display name
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getPunchInDistribution(String mgr) {
        Map<String, Integer> d = new HashMap<>();
        d.put("before8", 0); d.put("8to9", 0); d.put("9to10", 0);
        d.put("10to11", 0); d.put("after11", 0);

        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return d;

        String sql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN HOUR(punch_in) < 8  THEN 1 ELSE 0 END),0) b8, " +
            "  COALESCE(SUM(CASE WHEN HOUR(punch_in) >= 8  AND HOUR(punch_in) < 9  THEN 1 ELSE 0 END),0) h89, " +
            "  COALESCE(SUM(CASE WHEN HOUR(punch_in) >= 9  AND HOUR(punch_in) < 10 THEN 1 ELSE 0 END),0) h910, " +
            "  COALESCE(SUM(CASE WHEN HOUR(punch_in) >= 10 AND HOUR(punch_in) < 11 THEN 1 ELSE 0 END),0) h1011, " +
            "  COALESCE(SUM(CASE WHEN HOUR(punch_in) >= 11 THEN 1 ELSE 0 END),0) a11 " +
            "FROM attendance " +
            "WHERE user_email IN " + buildInClause(members.size()) +
            "  AND punch_in IS NOT NULL " +
            "  AND DATE(punch_date) >= DATE(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY))";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                d.put("before8", rs.getInt("b8"));
                d.put("8to9",    rs.getInt("h89"));
                d.put("9to10",   rs.getInt("h910"));
                d.put("10to11",  rs.getInt("h1011"));
                d.put("after11", rs.getInt("a11"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return d;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 12. AVG WORK HOURS THIS WEEK
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, String> getAvgWorkHoursThisWeek(String mgr) {
        Map<String, String> result = new HashMap<>();
        List<String> members = getTeamMemberUsernames(mgr);

        if (members.isEmpty()) {
            result.put("labels",   "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
            result.put("data",     "0,0,0,0,0,0,0");
            result.put("avgToday", "0");
            return result;
        }

        String memberIn = buildInClause(members.size());
        String sql =
            "SELECT DATE_FORMAT(d.dy,'%a') lbl, " +
            "  COALESCE(ROUND(AVG(" +
            "    CASE WHEN a.punch_in IS NOT NULL THEN " +
            "      TIMESTAMPDIFF(MINUTE, a.punch_in, " +
            "        COALESCE(a.punch_out, " +
            "          CASE WHEN DATE(a.punch_date) = CURDATE() THEN NOW() ELSE NULL END)" +
            "      ) / 60.0 " +
            "    END" +
            "  ),1), 0) hrs " +
            "FROM ( " +
            "  SELECT CURDATE()-INTERVAL 6 DAY dy UNION ALL SELECT CURDATE()-INTERVAL 5 DAY " +
            "  UNION ALL SELECT CURDATE()-INTERVAL 4 DAY UNION ALL SELECT CURDATE()-INTERVAL 3 DAY " +
            "  UNION ALL SELECT CURDATE()-INTERVAL 2 DAY UNION ALL SELECT CURDATE()-INTERVAL 1 DAY " +
            "  UNION ALL SELECT CURDATE() " +
            ") d " +
            "LEFT JOIN attendance a ON DATE(a.punch_date) = d.dy " +
            "  AND a.user_email IN " + memberIn +
            "GROUP BY d.dy ORDER BY d.dy";

        StringBuilder lbl = new StringBuilder(), data = new StringBuilder();
        String avgToday = "0";
        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            String lastVal = "0";
            while (rs.next()) {
                if (lbl.length() > 0) { lbl.append(","); data.append(","); }
                lbl.append("'").append(rs.getString("lbl")).append("'");
                lastVal = rs.getString("hrs"); if (lastVal == null) lastVal = "0";
                data.append(lastVal);
            }
            avgToday = lastVal;
        } catch (Exception e) { e.printStackTrace(); }

        result.put("labels",   lbl.length()  > 0 ? lbl.toString()  : "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'");
        result.put("data",     data.length() > 0 ? data.toString() : "0,0,0,0,0,0,0");
        result.put("avgToday", avgToday);
        return result;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 13. TASK PRIORITY BREAKDOWN
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getTaskPriorityBreakdown(String mgr) {
        Map<String, Integer> s = new HashMap<>();
        s.put("HIGH", 0); s.put("MEDIUM", 0); s.put("LOW", 0);

        String sql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN UPPER(priority)='HIGH'   THEN 1 ELSE 0 END),0) h, " +
            "  COALESCE(SUM(CASE WHEN UPPER(priority)='MEDIUM' THEN 1 ELSE 0 END),0) m, " +
            "  COALESCE(SUM(CASE WHEN UPPER(priority)='LOW'    THEN 1 ELSE 0 END),0) l " +
            "FROM tasks WHERE assigned_by = ?";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                s.put("HIGH",   rs.getInt("h"));
                s.put("MEDIUM", rs.getInt("m"));
                s.put("LOW",    rs.getInt("l"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 14. LEAVE APPROVAL STATS
    //
    // FIX: was returning 0 because member list was emails; now uses display names.
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getLeaveApprovalStats(String mgr) {
        Map<String, Integer> s = new HashMap<>();
        s.put("APPROVED", 0); s.put("REJECTED", 0); s.put("PENDING", 0);

        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return s;

        String sql =
            "SELECT UPPER(status) st, COUNT(*) cnt FROM leave_requests " +
            "WHERE username IN " + buildInClause(members.size()) +
            " GROUP BY UPPER(status)";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String st = rs.getString("st");
                int cnt = rs.getInt("cnt");
                if (s.containsKey(st)) s.put(st, cnt);
            }
        } catch (Exception e) { e.printStackTrace(); }

        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 15. PERFORMANCE RATING DISTRIBUTION
    //
    // DB stores: EXCELLENCE, GOOD, AVERAGE, POOR (uppercase)
    // FIX: filter to current month only.
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, Integer> getPerformanceRatingDistribution(String mgr) {
        Map<String, Integer> s = new HashMap<>();

        String sql =
            "SELECT UPPER(rating) rating, COUNT(*) cnt " +
            "FROM employee_performance " +
            "WHERE manager_username = ? " +
            "  AND MONTH(performance_month) = MONTH(CURDATE()) " +
            "  AND YEAR(performance_month)  = YEAR(CURDATE()) " +
            "GROUP BY UPPER(rating)";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) s.put(rs.getString("rating"), rs.getInt("cnt"));
        } catch (Exception e) { e.printStackTrace(); }

        return s;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 16. TOP PERFORMERS
    // ─────────────────────────────────────────────────────────────────────
    private List<Map<String, String>> getTopPerformers(String mgr) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql =
            "SELECT ep.employee_username, UPPER(ep.rating) rating, " +
            "  TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) fullname " +
            "FROM employee_performance ep " +
            "LEFT JOIN users u ON ep.employee_username = u.username " +
            "WHERE ep.manager_username = ? " +
            "  AND MONTH(ep.performance_month) = MONTH(CURDATE()) " +
            "  AND YEAR(ep.performance_month)  = YEAR(CURDATE()) " +
            "ORDER BY FIELD(UPPER(ep.rating),'EXCELLENCE','GOOD','AVERAGE','POOR') ASC " +
            "LIMIT 5";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                String fullname = rs.getString("fullname");
                if (fullname == null || fullname.trim().isEmpty())
                    fullname = rs.getString("employee_username");
                row.put("name",   fullname);
                row.put("rating", rs.getString("rating"));
                row.put("email",  rs.getString("employee_username"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 17. OVERDUE TASK EMPLOYEES
    // ─────────────────────────────────────────────────────────────────────
    private List<Map<String, String>> getOverdueTaskEmployees(String mgr) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql =
            "SELECT t.assigned_to, COUNT(*) cnt, " +
            "  TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) fullname " +
            "FROM tasks t " +
            "LEFT JOIN users u ON t.assigned_to = u.username " +
            "WHERE t.assigned_by = ? " +
            "  AND UPPER(t.status) IN ('ASSIGNED','PROCESSING') " +
            "  AND t.deadline IS NOT NULL AND t.deadline < CURDATE() " +
            "GROUP BY t.assigned_to, u.firstname, u.lastname " +
            "ORDER BY cnt DESC LIMIT 5";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, mgr);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                String fullname = rs.getString("fullname");
                if (fullname == null || fullname.trim().isEmpty())
                    fullname = rs.getString("assigned_to");
                row.put("name",  fullname);
                row.put("count", String.valueOf(rs.getInt("cnt")));
                row.put("email", rs.getString("assigned_to"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 18. MONTHLY LEAVE TREND
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, String> getMonthlyLeaveTrend(String mgr) {
        Map<String, String> result = new HashMap<>();
        List<String> members = getTeamMemberUsernames(mgr);

        if (members.isEmpty()) {
            result.put("labels", "''"); result.put("data", "0"); return result;
        }

        String sql =
            "SELECT DATE_FORMAT(CAST(applied_at AS DATE),'%b %Y') mon, COUNT(*) cnt, " +
            "  DATE_FORMAT(CAST(applied_at AS DATE),'%Y-%m') sort_key " +
            "FROM leave_requests " +
            "WHERE username IN " + buildInClause(members.size()) +
            "  AND CAST(applied_at AS DATE) >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
            "GROUP BY DATE_FORMAT(CAST(applied_at AS DATE),'%b %Y'), " +
            "         DATE_FORMAT(CAST(applied_at AS DATE),'%Y-%m') " +
            "ORDER BY sort_key ASC";

        StringBuilder lbl = new StringBuilder(), data = new StringBuilder();
        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (lbl.length() > 0) { lbl.append(","); data.append(","); }
                lbl.append("'").append(rs.getString("mon")).append("'");
                data.append(rs.getInt("cnt"));
            }
        } catch (Exception e) { e.printStackTrace(); }

        result.put("labels", lbl.length() > 0 ? lbl.toString() : "''");
        result.put("data",   data.length() > 0 ? data.toString() : "0");
        return result;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 19. AVG ATTENDANCE LAST 4 WEEKS
    // ─────────────────────────────────────────────────────────────────────
    private int getAvgAttendanceLast4Weeks(String mgr) {
        List<String> members = getTeamMemberUsernames(mgr);
        if (members.isEmpty()) return 0;

        String sql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN status IN ('Present','In Progress','Half Day') THEN 1 ELSE 0 END),0) p, " +
            "  COUNT(*) tot " +
            "FROM attendance " +
            "WHERE user_email IN " + buildInClause(members.size()) +
            "  AND DATE(punch_date) >= DATE_SUB(CURDATE(), INTERVAL 28 DAY)";

        try (Connection c = DBConnectionUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            setParams(ps, members);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int tot = rs.getInt("tot");
                return tot > 0 ? (rs.getInt("p") * 100 / tot) : 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────
    // 20. TASK COMPLETION TREND
    // ─────────────────────────────────────────────────────────────────────
    private Map<String, String> getTaskCompletionTrend(String mgr) {
        Map<String, String> result = new HashMap<>();
        StringBuilder lbl = new StringBuilder(), data = new StringBuilder();

        String[] dateColumns = {"assigned_date", "created_at"};
        for (String dateCol : dateColumns) {
            lbl.setLength(0); data.setLength(0);
            String sql =
                "SELECT " +
                "  CONCAT('Wk ', WEEK(MIN(" + dateCol + "))) lbl, " +
                "  COALESCE(SUM(CASE WHEN UPPER(status)='COMPLETED' THEN 1 ELSE 0 END),0) done " +
                "FROM tasks " +
                "WHERE assigned_by = ? " +
                "  AND " + dateCol + " >= DATE_SUB(CURDATE(), INTERVAL 4 WEEK) " +
                "GROUP BY YEARWEEK(" + dateCol + ", 1) " +
                "ORDER BY YEARWEEK(" + dateCol + ", 1) ASC";

            try (Connection c = DBConnectionUtil.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, mgr);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    if (lbl.length() > 0) { lbl.append(","); data.append(","); }
                    lbl.append("'").append(rs.getString("lbl")).append("'");
                    data.append(rs.getInt("done"));
                }
                break;
            } catch (Exception e) { /* try next column */ }
        }

        result.put("labels", lbl.length() > 0 ? lbl.toString() : "'Wk 1','Wk 2','Wk 3','Wk 4'");
        result.put("data",   data.length() > 0 ? data.toString() : "0,0,0,0");
        return result;
    }

    // ─────────────────────────────────────────────────────────────────────
    // HELPER: Resolve email from display name (for meetings queries)
    // ─────────────────────────────────────────────────────────────────────
    private String resolveEmailFromUsername(String username) {
        try (Connection c = DBConnectionUtil.getConnection()) {
            PreparedStatement ps = c.prepareStatement(
                "SELECT email FROM users WHERE username = ? LIMIT 1");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getString("email") != null) {
                return rs.getString("email");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return username;
    }

    // ─────────────────────────────────────────────────────────────────────
    // HELPER: Build SQL IN clause — e.g. (?,?,?)
    // ─────────────────────────────────────────────────────────────────────
    private String buildInClause(int size) {
        StringBuilder sb = new StringBuilder("(");
        for (int i = 0; i < size; i++) {
            if (i > 0) sb.append(",");
            sb.append("?");
        }
        sb.append(")");
        return sb.toString();
    }

    // ─────────────────────────────────────────────────────────────────────
    // HELPER: Bind list of strings to PreparedStatement from index 1
    // ─────────────────────────────────────────────────────────────────────
    private void setParams(PreparedStatement ps, List<String> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            ps.setString(i + 1, params.get(i));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}