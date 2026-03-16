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
        try {
            AdminDAO dao = new AdminDAO();

            // ── Stat cards (your existing code) ──────────────────────────────
            int managers     = dao.getManagerCount();
            int employees    = dao.getEmployeeCount();
            int totalStaff   = managers + employees;
            int presentToday = dao.getPresentTodayCount();
            int absentToday  = dao.getAbsentTodayCount();

            request.setAttribute("managers",     managers);
            request.setAttribute("employees",    employees);
            request.setAttribute("totalStaff",   totalStaff);
            request.setAttribute("presentToday", presentToday);
            request.setAttribute("absentToday",  absentToday);

            // ── Insight row ───────────────────────────────────────────────────
            request.setAttribute("attendanceRate", dao.getAttendanceRate());
            request.setAttribute("tasksCompleted", dao.getTasksCompletedThisMonth());
            request.setAttribute("leavesPending",  dao.getLeavesPending());
            request.setAttribute("activeTeams",    dao.getActiveTeams());

            // ── Weekly attendance bar chart ───────────────────────────────────
            request.setAttribute("weekPresent", dao.getWeekPresent());
            request.setAttribute("weekAbsent",  dao.getWeekAbsent());

            // ── 30-day trend line chart ───────────────────────────────────────
            request.setAttribute("attendanceTrend", dao.getAttendanceTrend());

            // ── Punch-in distribution chart ───────────────────────────────────
            request.setAttribute("punchData", dao.getPunchInDistribution());

            // ── Task pie chart ────────────────────────────────────────────────
            // Status values match your tasks.status column (default = 'ASSIGNED')
            request.setAttribute("taskCompleted",    dao.getTaskCountByStatus("COMPLETED"));
            request.setAttribute("taskInProgress",   dao.getTaskCountByStatus("SUBMITTED"));  // submitted = in review
            request.setAttribute("taskPending",      dao.getTaskCountByStatus("ASSIGNED"));   // assigned but not started
            request.setAttribute("taskErrorsRaised", dao.getTaskCountByStatus("REOPENED"));   // reopened = error/rework
            request.setAttribute("taskDocVerify",    dao.getTaskCountByStatus("ERROR"));      // error state

            // ── Leave doughnut chart ──────────────────────────────────────────
            // leave_type is free text — these match common values users enter.
            // Run dao.getDistinctLeaveTypes() once to see exactly what's in your DB.
            request.setAttribute("leaveSick",      dao.getLeaveCountByType("SICK"));
            request.setAttribute("leaveAnnual",    dao.getLeaveCountByType("ANNUAL"));
            request.setAttribute("leavePersonal",  dao.getLeaveCountByType("PERSONAL"));
            request.setAttribute("leaveMaternity", dao.getLeaveCountByType("MATERNITY"));
            request.setAttribute("leaveUnpaid",    dao.getLeaveCountByType("UNPAID"));

            // ── Holidays (your existing code) ─────────────────────────────────
            request.setAttribute("holidays", dao.getUpcomingHolidays());

            request.getRequestDispatcher("adminOverview.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading admin overview", e);
        }
    }
}