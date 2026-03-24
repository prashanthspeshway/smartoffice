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
import com.smartoffice.utils.AuthRedirectUtil;
import com.smartoffice.utils.DBConnectionUtil;

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
            // ── Today's punch state ───────────────────────────────────────────
            java.sql.ResultSet rs = dao.getTodayAttendance(username);
            if (rs != null && rs.next()) {
                request.setAttribute("punchIn",  rs.getTimestamp("punch_in"));
                request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
            }

            // ── Break state ───────────────────────────────────────────────────
            request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
            request.setAttribute("breakLogs",         BreakDAO.getTodayBreaks(username));
            request.setAttribute("onBreak",           BreakDAO.isCurrentlyOnBreak(username));

            // ── Block reason attributes (leave / holiday / weekend) ───────────
            setBlockAttributes(request, username, dao);

            // ── Activity log with filter ──────────────────────────────────────
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
                    attendanceLog   = dao.getAttendanceLogByRange(username, weekFrom, weekTo);
                    break;

                case "month":
                    String monthFrom = today.with(TemporalAdjusters.firstDayOfMonth()).format(iso);
                    String monthTo   = today.with(TemporalAdjusters.lastDayOfMonth()).format(iso);
                    attendanceLog    = dao.getAttendanceLogByRange(username, monthFrom, monthTo);
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
            request.setAttribute("filterPeriod",  period);
            request.setAttribute("filterFrom",    fromDate);
            request.setAttribute("filterTo",      toDate);

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
            AuthRedirectUtil.sendTopWindowRedirect(request, response, "/index.html");
            return;
        }

        String username = (String) session.getAttribute("username");
        String role     = (String) session.getAttribute("role");
        String action   = request.getParameter("action");

        AttendanceDAO dao = new AttendanceDAO();

        try {
            // ✅ Use getBlockReason — covers Leave, Holiday AND Weekend in one call
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            String blockReason  = null;
            try {
                blockReason = dao.getBlockReason(username, today);
            } catch (Exception blockCheckEx) {
                // If check fails, allow punch — don't block unnecessarily
                System.err.println("[AttendanceServlet] Block check failed: " + blockCheckEx.getMessage());
            }

            if (blockReason != null) {
                // Map the reason string to an error code for the redirect
                String errorCode = resolveErrorCode(blockReason);
                redirectWithError(response, request.getContextPath(), role, errorCode);
                return;
            }

            // ── Perform the punch action ──────────────────────────────────────
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
            // ✅ AttendanceDAO.punchIn/punchOut also throws with the block message
            //    as a safety net — map it to the right error code
            String msg       = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
            String errorCode = msg.contains("leave")   ? "OnLeave"
                             : msg.contains("holiday") ? "Holiday"
                             : msg.contains("weekend") ? "Weekend"
                             : "AttendanceError";
            redirectWithError(response, request.getContextPath(), role, errorCode);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ✅ Sets isOnLeave / isHoliday / holidayName / blockReason on the request
    //    so the JSP can render the correct block banner without extra DB calls.
    // ─────────────────────────────────────────────────────────────────────────
    private void setBlockAttributes(HttpServletRequest request,
                                    String username,
                                    AttendanceDAO dao) {
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

        // ── 1. On Leave? ──────────────────────────────────────────────────────
        boolean isOnLeave = false;
        try {
            isOnLeave = dao.isOnApprovedLeaveOn(username, today);
        } catch (Exception e) {
            System.err.println("[AttendanceServlet] Leave check error: " + e.getMessage());
        }
        request.setAttribute("isOnLeave", isOnLeave);

        // ── 2. Weekend? ───────────────────────────────────────────────────────
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
        boolean isWeekend = (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY);
        // (isWeekend is computed in JSP already from the Calendar, so no attribute needed,
        //  but we still use it below to skip the holidays DB call on weekends)

        // ── 3. Holiday? (fetch name for display) ──────────────────────────────
        boolean isHoliday   = false;
        String  holidayName = "";
        if (!isWeekend && !isOnLeave) {
            try (java.sql.Connection con = DBConnectionUtil.getConnection();
                 java.sql.PreparedStatement ps = con.prepareStatement(
                         "SELECT COALESCE(holiday_name, '') AS holiday_name " +
                         "FROM holidays WHERE holiday_date = ?")) {
                ps.setDate(1, today);
                java.sql.ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    isHoliday   = true;
                    holidayName = rs.getString("holiday_name");
                    if (holidayName == null) holidayName = "";
                }
            } catch (Exception e) {
                System.err.println("[AttendanceServlet] Holiday check error: " + e.getMessage());
            }
        }
        request.setAttribute("isHoliday",   isHoliday);
        request.setAttribute("holidayName", holidayName);

        // ── 4. Unified blockReason string (used by JSP banner + toast) ────────
        String blockReason = "";
        try {
            String reason = dao.getBlockReason(username, today);
            if (reason != null) blockReason = reason;
        } catch (Exception e) {
            System.err.println("[AttendanceServlet] BlockReason error: " + e.getMessage());
        }
        request.setAttribute("blockReason", blockReason);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Maps a blockReason message to a URL-safe error code for the redirect
    // ─────────────────────────────────────────────────────────────────────────
    private String resolveErrorCode(String blockReason) {
        if (blockReason == null) return "AttendanceError";
        String lower = blockReason.toLowerCase();
        if (lower.contains("leave"))   return "OnLeave";
        if (lower.contains("holiday")) return "Holiday";
        if (lower.contains("weekend")) return "Weekend";
        return "AttendanceError";
    }

    // ── Redirect helpers ──────────────────────────────────────────────────────
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