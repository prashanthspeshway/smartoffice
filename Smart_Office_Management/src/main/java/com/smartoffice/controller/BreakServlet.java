package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.BreakDAO;

@WebServlet("/break")
@SuppressWarnings("serial")
public class BreakServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String email    = (String) session.getAttribute("username");
        String action   = request.getParameter("action");   // start | end
        String redirect = request.getParameter("redirect"); // user | manager

        try {
            AttendanceDAO attendanceDAO = new AttendanceDAO();

            // ✅ GUARD 1: Block ALL break actions on holidays
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            if (attendanceDAO.isHoliday(today)) {
                redirectTo(response, request.getContextPath(), redirect, "error=HolidayBreak");
                return;
            }

            // ✅ GUARD 2: Block ALL break actions if employee is on leave
            if (attendanceDAO.isOnLeaveToday(email)) {
                redirectTo(response, request.getContextPath(), redirect, "error=OnLeave");
                return;
            }

            if ("start".equalsIgnoreCase(action)) {

                // ✅ GUARD 3: Cannot start a break if not punched in
                java.sql.Date todayDate = new java.sql.Date(System.currentTimeMillis());
                if (!attendanceDAO.hasPunchedIn(email, todayDate)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=NotPunchedIn");
                    return;
                }

                // ✅ GUARD 4: Cannot start a break if already punched out
                if (attendanceDAO.hasPunchedOut(email, todayDate)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=AlreadyPunchedOut");
                    return;
                }

                // ✅ GUARD 5: Cannot start a break if already on break
                if (BreakDAO.isCurrentlyOnBreak(email)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=AlreadyOnBreak");
                    return;
                }

                BreakDAO.startBreak(email);

            } else if ("end".equalsIgnoreCase(action)) {

                // ✅ GUARD 6: Cannot end a break if not currently on break
                if (!BreakDAO.isCurrentlyOnBreak(email)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=NotOnBreak");
                    return;
                }

                BreakDAO.endBreak(email);
            }

        } catch (Exception e) {
            throw new ServletException("Error updating break status", e);
        }

        // ✅ Redirect to attendance fragment only — never to full dashboard shell
        redirectTo(response, request.getContextPath(), redirect, "success=break" + action);
    }

    private void redirectTo(HttpServletResponse response, String ctx,
                             String redirect, String param) throws IOException {
        if ("manager".equalsIgnoreCase(redirect)) {
            response.sendRedirect(ctx + "/managerAttendance?" + param);
        } else {
            response.sendRedirect(ctx + "/attendance?" + param);
        }
    }
}