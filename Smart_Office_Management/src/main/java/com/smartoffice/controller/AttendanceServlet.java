package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.smartoffice.dao.AttendanceDAO;

@SuppressWarnings("serial")
@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

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
            String success = "";

            if ("punchin".equalsIgnoreCase(action)) {
                dao.punchIn(username);
                success = "PunchIn";
            } else if ("punchout".equalsIgnoreCase(action)) {
                dao.punchOut(username);
                success = "PunchOut";
            }

            // Role-based redirect — tab value must match the section div ID in the JSP exactly
            if ("admin".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin?success=" + success);
            } else if ("manager".equalsIgnoreCase(role)) {
                // "attendance" matches id="attendance" in manager_dashboard.jsp
                response.sendRedirect(request.getContextPath() + "/manager?success=" + success + "&tab=attendance");
            } else {
                response.sendRedirect(request.getContextPath() + "/user?success=" + success);
            }

        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("holiday")) {
                if ("manager".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/manager?error=HolidayAttendance&tab=attendance");
                } else if ("admin".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/admin?error=HolidayAttendance");
                } else {
                    response.sendRedirect(request.getContextPath() + "/user?error=HolidayAttendance");
                }
            } else {
                throw new ServletException(e);
            }
        }
    }
}