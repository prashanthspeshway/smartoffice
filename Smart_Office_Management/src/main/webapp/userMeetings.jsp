<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");
SimpleDateFormat dtFmt = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Scheduled Meetings</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap" rel="stylesheet">
<style>body{font-family:'DM Sans',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-handshake mr-2 text-indigo-500"></i>Scheduled Meetings</h2>
        <p class="text-slate-500 text-sm mt-1">Upcoming meetings you are invited to.</p>
    </div>

    <%if (meetings == null || meetings.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
        <i class="fa-solid fa-video-slash text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">No upcoming meetings scheduled.</p>
    </div>
    <%} else { for (Meeting m : meetings) {
        String creatorLabel = m.getCreatorRole() != null
            ? ("ADMIN".equalsIgnoreCase(m.getCreatorRole()) ? "Admin"
               : "MANAGER".equalsIgnoreCase(m.getCreatorRole()) ? "Manager"
               : m.getCreatorRole()) : "";
        String badgeCls = "ADMIN".equalsIgnoreCase(m.getCreatorRole())
            ? "bg-red-100 text-red-700 border border-red-200"
            : "MANAGER".equalsIgnoreCase(m.getCreatorRole())
            ? "bg-blue-100 text-blue-700 border border-blue-200"
            : "bg-indigo-100 text-indigo-700 border border-indigo-200";
        String creatorName = m.getCreatorName() != null ? m.getCreatorName() : m.getCreatedBy();
    %>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 flex flex-col md:flex-row md:items-center gap-5">
        <div class="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center flex-shrink-0">
            <i class="fa-solid fa-video text-indigo-500 text-xl"></i>
        </div>
        <div class="flex-1 min-w-0">
            <div class="flex flex-wrap items-center gap-2 mb-1">
                <h3 class="font-bold text-slate-800 text-base"><%=m.getTitle()%></h3>
                <%if (!creatorLabel.isEmpty()) {%>
                <span class="text-xs font-bold px-2 py-0.5 rounded-full <%=badgeCls%>">
                    <i class="fa-solid fa-user-tie mr-1"></i><%=creatorLabel%>
                </span>
                <%}%>
            </div>
            <%if (m.getDescription() != null && !m.getDescription().isEmpty()) {%>
            <p class="text-sm text-slate-500 mb-2"><%=m.getDescription()%></p>
            <%}%>
            <div class="flex flex-wrap gap-4 text-xs text-slate-500">
                <%if (m.getStartTime() != null) {%>
                <span><i class="fa-solid fa-calendar mr-1 text-indigo-400"></i><%=dtFmt.format(m.getStartTime())%></span>
                <%}%>
                <%if (m.getStartTime() != null && m.getEndTime() != null) {
                    long mins = (m.getEndTime().getTime() - m.getStartTime().getTime()) / 60000;
                    String dur = mins >= 60 ? (mins/60) + "h " + (mins%60) + "m" : mins + " minutes";
                %>
                <span><i class="fa-solid fa-clock mr-1 text-indigo-400"></i><%=dur%></span>
                <%}%>
                <span><i class="fa-solid fa-user mr-1 text-indigo-400"></i><%=creatorName%></span>
            </div>
        </div>
        <%if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {%>
        <div class="flex-shrink-0">
            <a href="<%=m.getMeetingLink()%>" target="_blank">
                <button class="px-5 py-2.5 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold transition-colors flex items-center gap-2">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Join Meeting
                </button>
            </a>
        </div>
        <%}%>
    </div>
    <%}}%>
</div>
</body>
</html>
