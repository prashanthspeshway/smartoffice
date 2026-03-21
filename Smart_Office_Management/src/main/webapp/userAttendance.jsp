<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.AttendanceLogEntry"%>
<%@ page import="com.smartoffice.model.BreakLog"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Calendar"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }

java.sql.Timestamp punchIn  = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");
boolean onBreak = Boolean.TRUE.equals(request.getAttribute("onBreak"));

java.util.Calendar cal = java.util.Calendar.getInstance();
int dow = cal.get(Calendar.DAY_OF_WEEK);
boolean isWeekend = (dow == Calendar.SATURDAY || dow == Calendar.SUNDAY);

int breakSecs = request.getAttribute("breakTotalSeconds") != null ? (Integer) request.getAttribute("breakTotalSeconds") : 0;
int bh = breakSecs / 3600, bm = (breakSecs % 3600) / 60, bs2 = breakSecs % 60;

SimpleDateFormat dtFmt   = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dateFmt = new SimpleDateFormat("MMM d, yyyy");
SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
SimpleDateFormat tFmt    = new SimpleDateFormat("HH:mm:ss");

List<AttendanceLogEntry> activityLog = (List<AttendanceLogEntry>) request.getAttribute("attendanceLog");
List<BreakLog> breakLogs = (List<BreakLog>) request.getAttribute("breakLogs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Attendance</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body{font-family:'Inter',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <!-- Header -->
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-clock mr-2 text-indigo-500"></i>Attendance</h2>
        <p class="text-slate-500 text-sm mt-1">Track your work sessions and breaks.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Status Card -->
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
            <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Status</p>
            <div class="divide-y divide-slate-100">
                <div class="flex justify-between py-3 text-sm">
                    <span class="font-semibold text-slate-500">Punch In</span>
                    <span class="font-semibold text-slate-800"><%=punchIn != null ? dtFmt.format(punchIn) : "--"%></span>
                </div>
                <div class="flex justify-between py-3 text-sm">
                    <span class="font-semibold text-slate-500">Punch Out</span>
                    <span class="font-semibold text-slate-800"><%=punchOut != null ? dtFmt.format(punchOut) : "--"%></span>
                </div>
            </div>
            <%if (isWeekend) {%>
            <p class="text-sm text-slate-400 mt-4 flex items-center gap-2"><i class="fa-solid fa-circle-info text-indigo-400"></i>Attendance is closed on weekends.</p>
            <%} else {%>
            <div class="flex gap-3 mt-5 flex-wrap">
                <form action="<%=request.getContextPath()%>/attendance" method="post">
                    <input type="hidden" name="action" value="punchin">
                    <button type="submit" class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors" <%=punchIn != null ? "disabled" : ""%>>
                        <i class="fa-solid fa-right-to-bracket mr-1"></i> Punch In
                    </button>
                </form>
                <form action="<%=request.getContextPath()%>/attendance" method="post">
                    <input type="hidden" name="action" value="punchout">
                    <button type="submit" class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-red-500 hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors" <%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
                        <i class="fa-solid fa-right-from-bracket mr-1"></i> Punch Out
                    </button>
                </form>
            </div>
            <%}%>
        </div>

        <!-- Break Card -->
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
            <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Break</p>
            <div class="bg-indigo-50 rounded-lg px-4 py-3 flex justify-between items-center mb-4">
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Total Break Today</span>
                <span class="text-lg font-bold text-indigo-600"><%=String.format("%02d:%02d:%02d", bh, bm, bs2)%></span>
            </div>
            <div class="flex gap-3 mb-4 flex-wrap">
                <form action="<%=request.getContextPath()%>/break" method="post">
                    <input type="hidden" name="action" value="start">
                    <input type="hidden" name="redirect" value="user">
                    <button type="submit" class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-violet-600 hover:bg-violet-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors" <%=(punchIn == null || punchOut != null || onBreak) ? "disabled" : ""%>>
                        <i class="fa-solid fa-mug-hot mr-1"></i> Start Break
                    </button>
                </form>
                <form action="<%=request.getContextPath()%>/break" method="post">
                    <input type="hidden" name="action" value="end">
                    <input type="hidden" name="redirect" value="user">
                    <button type="submit" class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-slate-500 hover:bg-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors" <%=!onBreak ? "disabled" : ""%>>
                        <i class="fa-solid fa-play mr-1"></i> End Break
                    </button>
                </form>
            </div>
            <div class="space-y-2 max-h-32 overflow-y-auto">
                <%if (breakLogs != null && !breakLogs.isEmpty()) {
                    for (BreakLog b : breakLogs) {
                        String s = b.getStartTime() != null ? tFmt.format(b.getStartTime()) : "--";
                        String e = b.getEndTime()   != null ? tFmt.format(b.getEndTime())   : "--";
                %>
                <div class="text-xs bg-slate-50 border border-slate-100 rounded-lg px-3 py-2 text-slate-600">
                    From <strong><%=s%></strong> to <strong><%=e%></strong>
                </div>
                <%}} else {%>
                <p class="text-sm text-slate-400">No breaks recorded today.</p>
                <%}%>
            </div>
        </div>
    </div>

    <!-- Activity Log -->
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-base font-bold text-slate-800">Recent Activity Log</h3>
            <div class="flex gap-1">
                <button id="logPrev" class="w-8 h-8 rounded-lg border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-50 disabled:opacity-40 text-xs" aria-label="Previous"><i class="fa-solid fa-chevron-left"></i></button>
                <button id="logNext" class="w-8 h-8 rounded-lg border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-50 disabled:opacity-40 text-xs" aria-label="Next"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="border-b-2 border-slate-100">
                        <th class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Date</th>
                        <th class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Punch In / Out</th>
                        <th class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Break</th>
                        <th class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Total</th>
                        <th class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Status</th>
                    </tr>
                </thead>
                <tbody id="activityLogBody">
                <%
                if (activityLog != null && !activityLog.isEmpty()) {
                    for (AttendanceLogEntry entry : activityLog) {
                        java.sql.Timestamp pi = entry.getPunchIn();
                        java.sql.Timestamp po = entry.getPunchOut();
                        int br = entry.getBreakSeconds();
                        long totalSec = (pi != null && po != null) ? Math.max(0, (po.getTime() - pi.getTime()) / 1000 - br) : 0;
                        int th = (int)(totalSec/3600), tm2 = (int)((totalSec%3600)/60);
                        int brH = br/3600, brM = (br%3600)/60;
                        String inOut = pi != null ? timeFmt.format(pi) : "--";
                        if (po != null) inOut += " (" + timeFmt.format(po) + ")";
                        String statusCls = "Present".equals(entry.getStatus()) ? "text-emerald-600 font-bold" : "text-slate-400 font-semibold";
                %>
                <tr class="border-b border-slate-50 hover:bg-slate-50 transition-colors" data-log-row>
                    <td class="py-3 text-slate-700"><%=entry.getAttendanceDate() != null ? dateFmt.format(entry.getAttendanceDate()) : "--"%></td>
                    <td class="py-3 text-slate-600"><%=inOut%></td>
                    <td class="py-3 text-slate-600"><%=brH%>h <%=String.format("%02d",brM)%>m</td>
                    <td class="py-3 text-slate-600"><%=th%>h <%=tm2%>m</td>
                    <td class="py-3 <%=statusCls%>"><%=entry.getStatus() != null ? entry.getStatus() : "--"%></td>
                </tr>
                <%}} else {%>
                <tr><td colspan="5" class="py-8 text-center text-slate-400">No attendance records yet.</td></tr>
                <%}%>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
(function() {
    var rows = document.querySelectorAll('#activityLogBody tr[data-log-row]');
    var perPage = 5, cur = 0;
    var totalPages = Math.max(1, Math.ceil(rows.length / perPage));
    function showPage() {
        rows.forEach(function(r, i) { r.style.display = (i >= cur*perPage && i < (cur+1)*perPage) ? '' : 'none'; });
        document.getElementById('logPrev').disabled = cur <= 0;
        document.getElementById('logNext').disabled = cur >= totalPages - 1;
    }
    if (rows.length > 0) {
        showPage();
        document.getElementById('logPrev').onclick = function() { if(cur>0){cur--;showPage();} };
        document.getElementById('logNext').onclick = function() { if(cur<totalPages-1){cur++;showPage();} };
    } else {
        document.getElementById('logPrev').disabled = true;
        document.getElementById('logNext').disabled = true;
    }
})();
</script>
</body>
</html>
