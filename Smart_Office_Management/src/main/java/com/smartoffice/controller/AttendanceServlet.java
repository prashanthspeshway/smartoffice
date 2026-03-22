package com.smartoffice.controller;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;
import com.smartoffice.model.AttendanceLogEntry;

@SuppressWarnings("serial")
@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

    // ─────────────────────────────────────────────────────────────
    // GET — serves the employee attendance page with optional filter
    // ─────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String username = (String) session.getAttribute("username");
        AttendanceDAO dao = new AttendanceDAO();

        try {
            // ── Today's punch state (for the punch-in/out buttons) ──
            java.sql.ResultSet rs = dao.getTodayAttendance(username);
            if (rs != null && rs.next()) {
                request.setAttribute("punchIn",  rs.getTimestamp("punch_in"));
                request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
            }

            // ✅ Pass On Leave flag so JSP can disable punch buttons
            request.setAttribute("isOnLeave", dao.isOnLeaveToday(username));

            // ── Break state ──
            request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
            request.setAttribute("breakLogs",         BreakDAO.getTodayBreaks(username));
            request.setAttribute("onBreak",           BreakDAO.isCurrentlyOnBreak(username));

            // ── Activity log with filter ──────────────────────────────
            String period   = request.getParameter("period");
            String fromDate = request.getParameter("fromDate");
            String toDate   = request.getParameter("toDate");

            if (period == null || period.isEmpty()) period = "all";

            DateTimeFormatter iso   = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate         today = LocalDate.now();

            List<AttendanceLogEntry> attendanceLog;

            switch (period) {
                case "week":
                    String weekFrom = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).format(iso);
                    String weekTo   = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY)).format(iso);
                    attendanceLog = dao.getAttendanceLogByRange(username, weekFrom, weekTo);
                    break;

                case "month":
                    String monthFrom = today.with(TemporalAdjusters.firstDayOfMonth()).format(iso);
                    String monthTo   = today.with(TemporalAdjusters.lastDayOfMonth()).format(iso);
                    attendanceLog = dao.getAttendanceLogByRange(username, monthFrom, monthTo);
                    break;

                case "custom":
                    if (fromDate != null && !fromDate.isEmpty()
                            && toDate != null && !toDate.isEmpty()) {
                        attendanceLog = dao.getAttendanceLogByRange(username, fromDate, toDate);
                    } else {
                        attendanceLog = dao.getFullAttendanceLog(username);
                        period = "all";
                    }
                    break;

                default:
                    attendanceLog = dao.getFullAttendanceLog(username);
                    break;
            }

            request.setAttribute("attendanceLog", attendanceLog);
            request.setAttribute("filterPeriod", period);
            request.setAttribute("filterFrom",   fromDate);
            request.setAttribute("filterTo",     toDate);

        } catch (Exception e) {
            throw new ServletException("Error loading attendance page", e);
        }

        request.getRequestDispatcher("userAttendance.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────
    // POST — punch in / punch out
    // ─────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String username = (String) session.getAttribute("username");
        String role     = (String) session.getAttribute("role");
        String action   = request.getParameter("action");

        AttendanceDAO dao = new AttendanceDAO();

        try {
            // ✅ Block punch if employee is on approved leave today
            try {
                if (dao.isOnLeaveToday(username)) {
                    redirectWithError(response, request.getContextPath(), role, "OnLeave");
                    return;
                }
            } catch (Exception leaveCheckEx) {
                // If check fails, allow punch — don't block unnecessarily
                System.err.println("[AttendanceServlet] Leave check failed: " + leaveCheckEx.getMessage());
            }

            String success = "";
            if ("punchin".equalsIgnoreCase(action)) {
                dao.punchIn(username);
                success = "PunchIn";
            } else if ("punchout".equalsIgnoreCase(action)) {
                dao.punchOut(username);
                success = "PunchOut";
            }

            redirectWithSuccess(response, request.getContextPath(), role, success);

        } catch (Exception e) {
            String errorParam = (e.getMessage() != null && e.getMessage().contains("holiday"))
                    ? "HolidayAttendance" : "AttendanceError";
            redirectWithError(response, request.getContextPath(), role, errorParam);
        }
    }

    // ── Redirect helpers ──────────────────────────────────────────
    private void redirectWithSuccess(HttpServletResponse response, String ctx,
                                     String role, String success) throws IOException {
        if ("admin".equalsIgnoreCase(role)) {
            response.sendRedirect(ctx + "/adminAttendance?success=" + success);
        } else if ("manager".equalsIgnoreCase(role)) {
            response.sendRedirect(ctx + "/managerAttendance?success=" + success);
        } else {
            response.sendRedirect(ctx + "/attendance?success=" + success);
        }
    }

    private void redirectWithError(HttpServletResponse response, String ctx,
                                   String role, String error) throws IOException {
        if ("admin".equalsIgnoreCase(role)) {
            response.sendRedirect(ctx + "/adminAttendance?error=" + error);
        } else if ("manager".equalsIgnoreCase(role)) {
            response.sendRedirect(ctx + "/managerAttendance?error=" + error);
        } else {
            response.sendRedirect(ctx + "/attendance?error=" + error);
        }
    }
}