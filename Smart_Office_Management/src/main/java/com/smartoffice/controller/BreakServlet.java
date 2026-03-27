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
import com.smartoffice.utils.AuthRedirectUtil;

@WebServlet("/break")
@SuppressWarnings("serial")
public class BreakServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            AuthRedirectUtil.sendTopWindowRedirect(request, response, "/index.html");
            return;
        }

        String email    = (String) session.getAttribute("username");
        String action   = request.getParameter("action");   // start | end
        String redirect = request.getParameter("redirect"); // user | manager

        try {
            AttendanceDAO attendanceDAO = new AttendanceDAO();

            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            if (attendanceDAO.isHoliday(today)) {
                redirectTo(response, request.getContextPath(), redirect, "error=HolidayBreak");
                return;
            }

            if (attendanceDAO.isOnLeaveToday(email)) {
                redirectTo(response, request.getContextPath(), redirect, "error=OnLeave");
                return;
            }

            if ("start".equalsIgnoreCase(action)) {

                java.sql.Date todayDate = new java.sql.Date(System.currentTimeMillis());
                if (!attendanceDAO.hasPunchedIn(email, todayDate)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=NotPunchedIn");
                    return;
                }

                if (attendanceDAO.hasPunchedOut(email, todayDate)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=AlreadyPunchedOut");
                    return;
                }

                if (BreakDAO.isCurrentlyOnBreak(email)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=AlreadyOnBreak");
                    return;
                }

                BreakDAO.startBreak(email);

            } else if ("end".equalsIgnoreCase(action)) {

                if (!BreakDAO.isCurrentlyOnBreak(email)) {
                    redirectTo(response, request.getContextPath(), redirect, "error=NotOnBreak");
                    return;
                }

                BreakDAO.endBreak(email);
            }

        } catch (Exception e) {
            throw new ServletException("Error updating break status", e);
        }

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