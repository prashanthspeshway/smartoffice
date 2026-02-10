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
            response.sendRedirect("login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        String action = request.getParameter("action");

        AttendanceDAO dao = new AttendanceDAO();

        try {
            if ("punchin".equals(action)) {
                dao.punchIn(username);
            } else if ("punchout".equals(action)) {
                dao.punchOut(username);
            }

            // ✅ ALWAYS REDIRECT AFTER POST
            if ("Admin".equalsIgnoreCase(role)) {
                response.sendRedirect("AdminAttendance.jsp");
            } else if ("Manager".equalsIgnoreCase(role)) {
                response.sendRedirect("manager");
            } else {
                response.sendRedirect("user");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
