package com.smartoffice.controller;

import com.smartoffice.dao.NotificationReadsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/*
 * POST /deleteNotification?id={id}  -> delete single notification
 * POST /deleteNotification?id=all   -> delete all READ notifications
 */

@WebServlet("/deleteNotification")
public class DeleteNotificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private NotificationReadsDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new NotificationReadsDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        /* ───── Check Session ───── */
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Session expired");
            return;
        }

        String email = (String) session.getAttribute("username");

        if (email == null || email.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("User not logged in");
            return;
        }

        /* ───── Get Request Parameter ───── */
        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Notification id is required");
            return;
        }

        try {

            /* ───── Delete Logic ───── */

            if ("all".equalsIgnoreCase(idParam)) {

                // Delete all read notifications
                dao.deleteAllReadNotifications(email);

            } else {

                // Delete single notification
                int notificationId = Integer.parseInt(idParam);
                dao.deleteNotification(notificationId, email);

            }

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Notification deleted successfully");

        } catch (NumberFormatException e) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid notification id");

        } catch (Exception e) {

            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error deleting notification");

        }
    }
}