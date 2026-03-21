package com.smartoffice.controller;

import com.smartoffice.dao.NotificationReadsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Lightweight endpoint polled every 30s by all dashboards.
 * Returns JSON: {"count": 5}
 * Used to show/update the red badge on the bell icon.
 */
@SuppressWarnings("serial")
@WebServlet("/notificationCount")
public class NotificationCountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"count\":0}");
            return;
        }

        String email = (String) session.getAttribute("username"); // username = email in your app
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        // No caching — always fresh
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try {
            int count = new NotificationReadsDAO().getUnreadCount(email);
            response.getWriter().write("{\"count\":" + count + "}");
        } catch (Exception e) {
            response.getWriter().write("{\"count\":0}");
        }
    }
}