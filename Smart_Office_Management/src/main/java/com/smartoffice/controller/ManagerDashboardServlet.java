package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;

@SuppressWarnings("serial")
@WebServlet("/manager")
public class ManagerDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");

        AttendanceDAO dao = new AttendanceDAO();

        try {
            ResultSet rs = dao.getTodayAttendance(username);
            if (rs.next()) {
                request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
                request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
            }
            request.getRequestDispatcher("manager.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
