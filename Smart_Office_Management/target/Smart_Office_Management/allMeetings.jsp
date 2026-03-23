<%@ page import="java.util.List" %>
<%@ page import="com.smartoffice.model.Meeting" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    List<Meeting> meetings = (List<Meeting>) request.getAttribute("todayMeetings"); // ← changed from allMeetings
    SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
%>

<div class="space-y-3">
<% if (meetings != null && !meetings.isEmpty()) {
    for (Meeting m : meetings) {
        boolean isSelf = m.getCreatedBy() != null && m.getCreatedBy().equalsIgnoreCase(username);
        String badgeCls  = isSelf ? "bg-indigo-100 text-indigo-700" : "bg-purple-100 text-purple-700";
        String badgeIcon = isSelf ? "fa-user-tie" : "fa-user-shield";
        String badgeText = isSelf ? "BY YOU" : "BY ADMIN";
%>
    <div class="bg-slate-50 rounded-lg p-4 border border-slate-200 hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between gap-3 mb-2">
            <div class="flex items-start gap-3">
                <i class="fa-solid fa-video text-indigo-600 mt-1"></i>
                <div>
                    <h4 class="font-semibold text-slate-800"><%=m.getTitle()%></h4>
                    <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                        <p class="text-sm text-slate-500 mt-0.5"><%=m.getDescription()%></p>
                    <% } %>
                </div>
            </div>
            <span class="inline-flex items-center gap-1.5 text-xs font-bold px-2.5 py-1 rounded-full shrink-0 <%=badgeCls%>">
                <i class="fa-solid <%=badgeIcon%> text-[10px]"></i> <%=badgeText%>
            </span>
        </div>

        <div class="flex items-center gap-4 text-xs text-slate-500 ml-8">
            <span>
                <i class="fa-solid fa-clock mr-1"></i>
                <%=timeFmt.format(m.getStartTime())%> – <%=timeFmt.format(m.getEndTime())%>
            </span>
        </div>

        <% if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) { %>
            <a href="<%=m.getMeetingLink()%>" target="_blank"
               class="inline-flex items-center gap-2 mt-3 ml-8 px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold hover:bg-blue-200 transition-colors">
                <i class="fa-solid fa-video"></i> Join Meeting
            </a>
        <% } %>
    </div>
<% } } else { %>
    <div class="flex flex-col items-center justify-center py-16 text-center">
        <i class="fa-solid fa-calendar-xmark text-5xl text-slate-300 mb-4"></i>
        <p class="text-slate-500 font-medium">No meetings scheduled for today.</p>
        <p class="text-slate-400 text-sm mt-1">Enjoy your free day!</p>
    </div>
<% } %>
</div>

<script>
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
    e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
        ? false : true;
</script>