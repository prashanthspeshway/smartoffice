package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.model.Meeting;

@SuppressWarnings("serial")
@WebServlet("/allMeetings")
public class AllMeetingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String email = (String) session.getAttribute("username");

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            MeetingDao dao = new MeetingDao();
            List<Meeting> meetings = dao.getAllMeetingsForManager(email);

            SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy");
            SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

            if (meetings == null || meetings.isEmpty()) {
                out.println("<p style='text-align:center; color:#64748b; padding:20px;'>No meetings found.</p>");
                return;
            }

            for (Meeting m : meetings) {
                String createdBy    = m.getCreatedBy();
                boolean isSelf      = createdBy != null && createdBy.equalsIgnoreCase(email);
                String badgeLabel   = isSelf ? "BY YOU" : "BY ADMIN";
                String badgeColor   = isSelf ? "#4f46e5" : "#7c3aed";
                String badgeIcon    = isSelf ? "fa-user-tie" : "fa-user-shield";

                String startDate = m.getStartTime() != null ? dateFmt.format(m.getStartTime()) : "--";
                String startTime = m.getStartTime() != null ? timeFmt.format(m.getStartTime()) : "--";
                String endTime   = m.getEndTime()   != null ? timeFmt.format(m.getEndTime())   : "--";

                out.println("<div class='meeting-item'>");

                // Header row: title + badge
                out.println("  <div class='meeting-title' style='justify-content: space-between;'>");
                out.println("    <div style='display:flex; align-items:center; gap:8px;'>");
                out.println("      <i class='fa-solid fa-video'></i>");
                out.println("      <span>" + escapeHtml(m.getTitle()) + "</span>");
                out.println("    </div>");
                out.println("    <span style='" +
                        "display:inline-flex; align-items:center; gap:5px;" +
                        "background:" + badgeColor + "; color:#fff;" +
                        "font-size:11px; font-weight:700; padding:3px 10px;" +
                        "border-radius:20px; letter-spacing:0.4px;'>" +
                        "<i class='fa-solid " + badgeIcon + "' style='font-size:10px;'></i>" +
                        badgeLabel + "</span>");
                out.println("  </div>");

                // Description
                if (m.getDescription() != null && !m.getDescription().isEmpty()) {
                    out.println("  <div class='meeting-info'>" + escapeHtml(m.getDescription()) + "</div>");
                }

                // Date / Time
                out.println("  <div class='meeting-info'><b>Date:</b> " + startDate + "</div>");
                out.println("  <div class='meeting-info'><b>Start:</b> " + startTime + "</div>");
                out.println("  <div class='meeting-info'><b>End:</b> "   + endTime   + "</div>");

                // Scheduled-by line for admin meetings
                if (!isSelf) {
                    out.println("  <div style='font-size:12px; color:#7c3aed; margin-top:4px;'>" +
                            "<i class='fa-solid fa-user-shield' style='margin-right:4px;'></i>" +
                            "Scheduled by Admin</div>");
                }

                // Join button
                if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {
                    out.println("  <a href='" + escapeHtml(m.getMeetingLink()) + "' target='_blank' class='join-btn'>" +
                            "<i class='fa-solid fa-video'></i> Join Meeting</a>");
                }

                out.println("</div>"); // .meeting-item
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:#dc2626; padding:16px;'>Error loading meetings. Please try again.</p>");
        }
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}