<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.TeamAttendance"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

java.sql.Timestamp punchIn = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");

java.util.Calendar cal = java.util.Calendar.getInstance();
int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
boolean isWeekend = (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY);

boolean onBreak = Boolean.TRUE.equals(request.getAttribute("onBreak"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-7xl mx-auto">
		<h2 class="text-2xl font-bold text-slate-800 mb-6">Attendance</h2>

		<!-- My Attendance Cards -->
		<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
			<!-- Status Card -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<h3 class="text-sm font-semibold text-slate-700 uppercase tracking-wider mb-4">Status</h3>
				
				<div class="space-y-3">
					<div class="flex justify-between items-center py-2 border-b border-slate-100">
						<span class="text-slate-600 font-medium">Punch In</span>
						<span class="text-slate-900 font-semibold">
							<%=punchIn != null ? new SimpleDateFormat("HH:mm:ss").format(punchIn) : "--"%>
						</span>
					</div>
					<div class="flex justify-between items-center py-2">
						<span class="text-slate-600 font-medium">Punch Out</span>
						<span class="text-slate-900 font-semibold">
							<%=punchOut != null ? new SimpleDateFormat("HH:mm:ss").format(punchOut) : "--"%>
						</span>
					</div>
				</div>

				<%if (isWeekend) {%>
				<p class="text-slate-500 text-sm mt-4">Attendance is closed on weekends.</p>
				<%} else {%>
				<div class="flex gap-3 mt-6">
					<form action="<%=request.getContextPath()%>/attendance" method="post" class="flex-1">
						<input type="hidden" name="action" value="punchin">
						<button type="submit"
							class="w-full px-4 py-2 rounded-lg font-semibold text-white transition-colors
							<%=punchIn != null ? "bg-slate-400 cursor-not-allowed" : "bg-indigo-600 hover:bg-indigo-700"%>"
							<%=punchIn != null ? "disabled" : ""%>>
							Punch In
						</button>
					</form>
					<form action="<%=request.getContextPath()%>/attendance" method="post" class="flex-1">
						<input type="hidden" name="action" value="punchout">
						<button type="submit"
							class="w-full px-4 py-2 rounded-lg font-semibold text-white transition-colors
							<%=(punchIn == null || punchOut != null) ? "bg-slate-400 cursor-not-allowed" : "bg-red-600 hover:bg-red-700"%>"
							<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
							Punch Out
						</button>
					</form>
				</div>
				<%}%>
			</div>

			<!-- Break Card -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<h3 class="text-sm font-semibold text-slate-700 uppercase tracking-wider mb-4">Total Break Today</h3>
				
				<div class="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-lg p-4 mb-4">
					<div class="flex justify-between items-center">
						<span class="text-xs font-semibold text-slate-600 uppercase tracking-wide">Total Break</span>
						<span class="text-lg font-bold text-indigo-600">
							<%
							int mgrBreakSecs = 0;
							if (request.getAttribute("breakTotalSeconds") != null) {
								mgrBreakSecs = (Integer) request.getAttribute("breakTotalSeconds");
							}
							int mbh = mgrBreakSecs / 3600;
							int mbm = (mgrBreakSecs % 3600) / 60;
							int mbs = mgrBreakSecs % 60;
							%>
							<%=String.format("%02d:%02d:%02d", mbh, mbm, mbs)%>
						</span>
					</div>
				</div>

				<div class="flex gap-3 mb-4">
					<form action="<%=request.getContextPath()%>/break" method="post" class="flex-1">
						<input type="hidden" name="action" value="start">
						<input type="hidden" name="redirect" value="manager">
						<button type="submit"
							class="w-full px-4 py-2 rounded-lg font-semibold text-white transition-colors
							<%=(punchIn == null || punchOut != null || onBreak) ? "bg-slate-400 cursor-not-allowed" : "bg-purple-600 hover:bg-purple-700"%>"
							<%=(punchIn == null || punchOut != null || onBreak) ? "disabled" : ""%>>
							Start Break
						</button>
					</form>
					<form action="<%=request.getContextPath()%>/break" method="post" class="flex-1">
						<input type="hidden" name="action" value="end">
						<input type="hidden" name="redirect" value="manager">
						<button type="submit"
							class="w-full px-4 py-2 rounded-lg font-semibold text-white transition-colors
							<%=!onBreak ? "bg-slate-400 cursor-not-allowed" : "bg-slate-600 hover:bg-slate-700"%>"
							<%=!onBreak ? "disabled" : ""%>>
							End Break
						</button>
					</form>
				</div>

				<div class="max-h-32 overflow-y-auto space-y-2">
					<%
					java.util.List<com.smartoffice.model.BreakLog> mgrBreaks = 
						(java.util.List<com.smartoffice.model.BreakLog>) request.getAttribute("breakLogs");
					SimpleDateFormat mgrTimeFmt = new SimpleDateFormat("HH:mm:ss");
					if (mgrBreaks != null && !mgrBreaks.isEmpty()) {
						for (com.smartoffice.model.BreakLog b : mgrBreaks) {
							String mStart = b.getStartTime() != null ? mgrTimeFmt.format(b.getStartTime()) : "--";
							String mEnd = b.getEndTime() != null ? mgrTimeFmt.format(b.getEndTime()) : "--";
					%>
					<div class="bg-slate-50 rounded-lg p-3 text-sm border border-slate-200">
						From <b><%=mStart%></b> to <b><%=mEnd%></b>
					</div>
					<%
						}
					} else {
					%>
					<p class="text-slate-500 text-sm">No breaks recorded today.</p>
					<%
					}
					%>
				</div>
			</div>
		</div>

		<!-- Team Attendance -->
		<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
			<div class="flex justify-between items-center mb-6">
				<h3 class="text-lg font-semibold text-slate-800">Team Attendance (Today)</h3>
				<div class="flex gap-3">
					<form action="<%=request.getContextPath()%>/exportTeamAttendance" method="get">
						<button type="submit" 
							class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-colors flex items-center gap-2">
							<i class="fa-solid fa-file-export"></i> Export Attendance
						</button>
					</form>
					<form action="<%=request.getContextPath()%>/exportTeamPerformance" method="get">
						<button type="submit"
							class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-colors flex items-center gap-2">
							<i class="fa-solid fa-file-export"></i> Export Performance
						</button>
					</form>
				</div>
			</div>

			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
				<%
				List<TeamAttendance> teamAttendance = (List<TeamAttendance>) request.getAttribute("teamAttendance");
				if (teamAttendance != null && !teamAttendance.isEmpty()) {
					for (TeamAttendance ta : teamAttendance) {
						String st = ta.getStatus() != null ? ta.getStatus().toLowerCase() : "";
						String statusColor = st.contains("present") || st.contains("punched") 
							? "bg-green-100 text-green-800" 
							: (st.contains("absent") ? "bg-red-100 text-red-800" : "bg-blue-100 text-blue-800");
				%>
				<div class="bg-slate-50 rounded-lg p-4 border border-slate-200 hover:shadow-md transition-shadow">
					<div class="flex items-center justify-between mb-3">
						<div class="flex items-center gap-2">
							<i class="fa-solid fa-user text-indigo-600"></i>
							<span class="font-semibold text-slate-800"><%=ta.getFullName()%></span>
						</div>
						<span class="px-2 py-1 rounded-full text-xs font-semibold <%=statusColor%>">
							<%=ta.getStatus()%>
						</span>
					</div>
					<div class="space-y-1 text-sm text-slate-600">
						<div><b>Punch In:</b> <%=ta.getPunchIn() != null ? ta.getPunchIn() : "--"%></div>
						<div><b>Punch Out:</b> <%=ta.getPunchOut() != null ? ta.getPunchOut() : "--"%></div>
					</div>
				</div>
				<%
					}
				} else {
				%>
				<p class="text-slate-500 col-span-full text-center py-8">No attendance data available for today.</p>
				<%
				}
				%>
			</div>
		</div>
	</div>

	<script>
	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
