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
	        List<Meeting> meetings = MeetingDao.getTodayMeetings(email);

	        SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

	        if (meetings == null || meetings.isEmpty()) {
	            out.println(
	                "<div class='flex flex-col items-center justify-center py-16 text-center'>" +
	                "  <i class='fa-solid fa-calendar-xmark text-5xl text-slate-300 mb-4'></i>" +
	                "  <p class='text-slate-500 font-medium'>No meetings scheduled for today.</p>" +
	                "  <p class='text-slate-400 text-sm mt-1'>Enjoy your free day!</p>" +
	                "</div>"
	            );
	            return;
	        }

	        out.println("<div class='space-y-3'>");

	        for (Meeting m : meetings) {
	            String createdBy = m.getCreatedBy();
	            boolean isSelf   = createdBy != null && createdBy.equalsIgnoreCase(email);

	            String badgeText  = isSelf ? "BY YOU" : "BY ADMIN";
	            String badgeCls   = isSelf
	                ? "bg-indigo-100 text-indigo-700"
	                : "bg-purple-100 text-purple-700";
	            String badgeIcon  = isSelf ? "fa-user-tie" : "fa-user-shield";

	            String startTime = m.getStartTime() != null ? timeFmt.format(m.getStartTime()) : "--";
	            String endTime   = m.getEndTime()   != null ? timeFmt.format(m.getEndTime())   : "--";

	            out.println(
	                "<div class='bg-slate-50 rounded-lg p-4 border border-slate-200 hover:shadow-md transition-shadow'>" +

	                "  <div class='flex items-start justify-between gap-3 mb-2'>" +
	                "    <div class='flex items-start gap-3'>" +
	                "      <i class='fa-solid fa-video text-indigo-600 mt-1'></i>" +
	                "      <div>" +
	                "        <h4 class='font-semibold text-slate-800'>" + escapeHtml(m.getTitle()) + "</h4>" +
	                (m.getDescription() != null && !m.getDescription().isEmpty()
	                    ? "<p class='text-sm text-slate-500 mt-0.5'>" + escapeHtml(m.getDescription()) + "</p>"
	                    : "") +
	                "      </div>" +
	                "    </div>" +
	                "    <span class='inline-flex items-center gap-1.5 text-xs font-bold px-2.5 py-1 rounded-full shrink-0 " + badgeCls + "'>" +
	                "      <i class='fa-solid " + badgeIcon + " text-[10px]'></i>" + badgeText +
	                "    </span>" +
	                "  </div>" +

	                "  <div class='flex items-center gap-4 text-xs text-slate-500 ml-8'>" +
	                "    <span><i class='fa-solid fa-clock mr-1'></i>" + startTime + " – " + endTime + "</span>" +
	                "  </div>" +

	                (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()
	                    ? "<a href='" + escapeHtml(m.getMeetingLink()) + "' target='_blank' " +
	                      "class='inline-flex items-center gap-2 mt-3 ml-8 px-3 py-1 bg-blue-100 text-blue-700 " +
	                      "rounded-full text-xs font-semibold hover:bg-blue-200 transition-colors'>" +
	                      "<i class='fa-solid fa-video'></i> Join Meeting</a>"
	                    : "") +

	                "</div>"
	            );
	        }

	        out.println("</div>");

	    } catch (Exception e) {
	        e.printStackTrace();
	        out.println(
	            "<p class='text-red-500 text-center py-8'>" +
	            "<i class='fa-solid fa-triangle-exclamation mr-2'></i>Error loading meetings. Please try again.</p>"
	        );
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