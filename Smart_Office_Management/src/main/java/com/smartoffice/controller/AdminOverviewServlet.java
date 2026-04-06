package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.smartoffice.dao.AdminDAO;

@SuppressWarnings("serial")
@WebServlet("/adminOverview")
public class AdminOverviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        AdminDAO dao = new AdminDAO();

        // ── Staff counts ──────────────────────────────────────────────────
        int managers  = safeInt(() -> dao.getManagerCount());
        int employees = safeInt(() -> dao.getEmployeeCount());
        request.setAttribute("managers",   managers);
        request.setAttribute("employees",  employees);
        request.setAttribute("totalStaff", managers + employees);
        request.setAttribute("presentToday", safeInt(() -> dao.getPresentTodayCount()));
        request.setAttribute("absentToday",  safeInt(() -> dao.getAbsentTodayCount()));

        // ── Insight row 1 ─────────────────────────────────────────────────
        request.setAttribute("attendanceRate", safeInt(() -> dao.getAttendanceRate()));
        request.setAttribute("tasksCompleted", safeInt(() -> dao.getTasksCompletedThisMonth()));
        request.setAttribute("leavesPending",  safeInt(() -> dao.getLeavesPending()));
        request.setAttribute("activeTeams",    safeInt(() -> dao.getActiveTeams()));

        // ── Insight row 2 ─────────────────────────────────────────────────
        request.setAttribute("avgWorkHours",      safeStr(() -> dao.getAvgWorkHoursToday(), "0.0"));
        request.setAttribute("lateArrivals",      safeInt(() -> dao.getLateArrivalsThisWeek()));
        request.setAttribute("leaveApprovalRate", safeStr(() -> dao.getLeaveApprovalRate(), "0"));

        // ── Weekly attendance ─────────────────────────────────────────────
        request.setAttribute("weekPresent", safeStr(() -> dao.getWeekPresent(), "0,0,0,0,0,0,0"));
        request.setAttribute("weekAbsent",  safeStr(() -> dao.getWeekAbsent(),  "0,0,0,0,0,0,0"));

        // ── 30-day trend ──────────────────────────────────────────────────
        request.setAttribute("attendanceTrend", safeStr(() -> dao.getAttendanceTrend(),
            "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"));

        // ── Task status pie ───────────────────────────────────────────────
        request.setAttribute("taskStatusDist", safeStr(() -> dao.getTaskStatusDistribution(), "0|0|0|0|0"));

        // ── Leave type doughnut ───────────────────────────────────────────
        request.setAttribute("leaveCasual", safeInt(() -> dao.getLeaveCountByType("Casual Leave")));
        request.setAttribute("leaveSick",   safeInt(() -> dao.getLeaveCountByType("Sick Leave")));
        request.setAttribute("leaveEarned", safeInt(() -> dao.getLeaveCountByType("Earned Leave")));

        // ── Task completion by week ───────────────────────────────────────
        request.setAttribute("taskWeekData", safeStr(() -> dao.getTaskCompletionByWeek(), "0,0,0,0"));

        // ── Break analytics ───────────────────────────────────────────────
        request.setAttribute("breakData", safeStr(() -> dao.getBreakAnalytics(), "0,0,0,0,0,0,0"));

        // ── Punch-in distribution ─────────────────────────────────────────
        request.setAttribute("punchData", safeStr(() -> dao.getPunchInDistribution(), "0,0,0,0,0"));

        // ── Holidays ──────────────────────────────────────────────────────
        try {
            request.setAttribute("holidays", dao.getUpcomingHolidays());
        } catch (Exception e) {
            request.setAttribute("holidays", java.util.Collections.emptyList());
            log("holidays failed: " + e.getMessage());
        }

        request.getRequestDispatcher("adminOverview.jsp").forward(request, response);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    @FunctionalInterface
    interface IntSupplier { int get() throws Exception; }

    @FunctionalInterface
    interface StrSupplier { String get() throws Exception; }

    private int safeInt(IntSupplier s) {
        try { return s.get(); }
        catch (Exception e) { log("DAO int error: " + e.getMessage()); return 0; }
    }

    private String safeStr(StrSupplier s, String fallback) {
        try { return s.get(); }
        catch (Exception e) { log("DAO str error: " + e.getMessage()); return fallback; }
    }
}