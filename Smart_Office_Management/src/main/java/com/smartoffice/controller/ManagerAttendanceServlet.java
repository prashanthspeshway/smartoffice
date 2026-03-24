package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;
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
import com.smartoffice.model.TeamAttendance;

@SuppressWarnings("serial")
@WebServlet("/managerAttendance")
public class ManagerAttendanceServlet extends HttpServlet {

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

        String username = (String) session.getAttribute("username");

        try {
            AttendanceDAO attendanceDAO = new AttendanceDAO();

            // ── Self Attendance (today's punch state) ──────────────────────
            ResultSet rs = attendanceDAO.getTodayAttendance(username);
            if (rs != null && rs.next()) {
                request.setAttribute("punchIn",  rs.getTimestamp("punch_in"));
                request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
            }

            // ✅ FIX: Pass On Leave flag — was missing, caused leave banner to never show
            request.setAttribute("isOnLeave", attendanceDAO.isOnLeaveToday(username));

            // ── Break state ────────────────────────────────────────────────
            // ✅ FIX: Re-query break state AFTER any punch-out auto-close
            // so onBreak=false correctly disables End Break button post punch-out
            boolean currentlyOnBreak = BreakDAO.isCurrentlyOnBreak(username);
            request.setAttribute("onBreak",           currentlyOnBreak);
            request.setAttribute("breakTotalSeconds", BreakDAO.getTodayTotalSeconds(username));
            request.setAttribute("breakLogs",         BreakDAO.getTodayBreaks(username));

            // ── Team Attendance (today) ────────────────────────────────────
            List<TeamAttendance> teamAttendance = attendanceDAO.getTeamAttendanceForToday(username);
            request.setAttribute("teamAttendance", teamAttendance);

            // ── Activity Log with filter ───────────────────────────────────
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
                    attendanceLog = attendanceDAO.getAttendanceLogByRange(username, weekFrom, weekTo);
                    break;

                case "month":
                    String monthFrom = today.with(TemporalAdjusters.firstDayOfMonth()).format(iso);
                    String monthTo   = today.with(TemporalAdjusters.lastDayOfMonth()).format(iso);
                    attendanceLog = attendanceDAO.getAttendanceLogByRange(username, monthFrom, monthTo);
                    break;

                case "custom":
                    if (fromDate != null && !fromDate.isEmpty()
                            && toDate != null && !toDate.isEmpty()) {
                        attendanceLog = attendanceDAO.getAttendanceLogByRange(username, fromDate, toDate);
                    } else {
                        attendanceLog = attendanceDAO.getFullAttendanceLog(username);
                        period = "all";
                    }
                    break;

                default: // "all"
                    attendanceLog = attendanceDAO.getFullAttendanceLog(username);
                    break;
            }

            request.setAttribute("attendanceLog", attendanceLog);
            request.setAttribute("filterPeriod", period);
            request.setAttribute("filterFrom",   fromDate != null ? fromDate : "");
            request.setAttribute("filterTo",     toDate   != null ? toDate   : "");

        } catch (Exception e) {
            throw new ServletException("Error loading attendance data", e);
        }

        request.getRequestDispatcher("managerAttendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}