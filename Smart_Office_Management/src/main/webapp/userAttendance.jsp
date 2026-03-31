<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.AttendanceLogEntry"%>
<%@ page import="com.smartoffice.model.BreakLog"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Calendar"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

java.sql.Timestamp punchIn = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");
boolean onBreak = Boolean.TRUE.equals(request.getAttribute("onBreak"));

java.util.Calendar cal = java.util.Calendar.getInstance();
int dow = cal.get(Calendar.DAY_OF_WEEK);
boolean isWeekend = (dow == Calendar.SATURDAY || dow == Calendar.SUNDAY);

// ✅ On Leave / holiday (weekend checked separately below)
Boolean isOnLeaveAttr = (Boolean) request.getAttribute("isOnLeave");
boolean isOnLeave = isOnLeaveAttr != null && isOnLeaveAttr;
Boolean isHolidayAttr = (Boolean) request.getAttribute("isHoliday");
boolean isHoliday = isHolidayAttr != null && isHolidayAttr;
boolean attendanceBlockedToday = isWeekend || isOnLeave || isHoliday;

int breakSecs = request.getAttribute("breakTotalSeconds") != null
		? (Integer) request.getAttribute("breakTotalSeconds")
		: 0;
int bh = breakSecs / 3600, bm = (breakSecs % 3600) / 60, bs2 = breakSecs % 60;

SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dateFmt = new SimpleDateFormat("MMM d, yyyy");
SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
SimpleDateFormat tFmt = new SimpleDateFormat("HH:mm:ss");
SimpleDateFormat isoFmt = new SimpleDateFormat("yyyy-MM-dd");

// ── Filter state ──────────────────────────────────────────────────────────
String filterPeriod = (String) request.getAttribute("filterPeriod");
String filterFrom = (String) request.getAttribute("filterFrom");
String filterTo = (String) request.getAttribute("filterTo");
if (filterPeriod == null)
	filterPeriod = "all";
if (filterFrom == null)
	filterFrom = "";
if (filterTo == null)
	filterTo = "";

// ── Summary stats from filtered log ──────────────────────────────────────
List<AttendanceLogEntry> activityLog = (List<AttendanceLogEntry>) request.getAttribute("attendanceLog");

int totalPresent = 0, totalDays = 0;
long totalWorkSec = 0, totalBreakSec = 0;
if (activityLog != null) {
	totalDays = activityLog.size();
	for (AttendanceLogEntry entry : activityLog) {
		if ("Present".equals(entry.getStatus()))
	totalPresent++;
		java.sql.Timestamp pi2 = entry.getPunchIn(), po2 = entry.getPunchOut();
		int br2 = entry.getBreakSeconds();
		if (pi2 != null && po2 != null) {
	totalWorkSec += Math.max(0, (po2.getTime() - pi2.getTime()) / 1000 - br2);
	totalBreakSec += br2;
		}
	}
}
int swH = (int) (totalWorkSec / 3600), swM = (int) ((totalWorkSec % 3600) / 60);
int sbH = (int) (totalBreakSec / 3600), sbM = (int) ((totalBreakSec % 3600) / 60);
List<BreakLog> breakLogs = (List<BreakLog>) request.getAttribute("breakLogs");

String todayStr = isoFmt.format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Attendance</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<style>
.filter-pill {
	display: inline-flex;
	align-items: center;
	gap: 5px;
	padding: 5px 14px;
	border-radius: 999px;
	font-size: 12.5px;
	font-weight: 600;
	border: 1.5px solid #e2e8f0;
	background: #fff;
	color: #64748b;
	cursor: pointer;
	transition: all .15s;
	white-space: nowrap;
}

.filter-pill:hover {
	border-color: #6366f1;
	color: #6366f1;
	background: #eef2ff;
}

.filter-pill.active {
	border-color: #6366f1;
	background: #6366f1;
	color: #fff;
}

.stat-chip {
	display: flex;
	flex-direction: column;
	align-items: center;
	background: #f8fafc;
	border: 1.5px solid #e2e8f0;
	border-radius: 12px;
	padding: 12px 16px;
	flex: 1;
	min-width: 80px;
}

#customRange {
	display: none;
}

#customRange.open {
	display: flex;
	animation: slideDown .18s ease;
}

@
keyframes slideDown {from { opacity:0;
	transform: translateY(-5px);
}

to {
	opacity: 1;
	transform: translateY(0);
}
}
</style>
</head>
<body class="user-iframe-page p-6">
	<div class="max-w-5xl mx-auto space-y-6">

		<!-- Header -->
		<div>
			<h2 class="text-2xl font-bold text-slate-800">
				<i class="fa-solid fa-clock mr-2 text-indigo-500"></i>Attendance
			</h2>
			<p class="text-slate-500 text-sm mt-1">Track your work sessions
				and breaks.</p>
		</div>

		<!-- Punch + Break cards -->
		<div class="grid grid-cols-1 md:grid-cols-2 gap-6">

			<!-- Status Card -->
			<div
				class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
				<p
					class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Today's
					Status</p>
				<div class="divide-y divide-slate-100">
					<div class="flex justify-between py-3 text-sm">
						<span class="font-semibold text-slate-500">Punch In</span> <span
							class="font-semibold text-slate-800"><%=punchIn != null ? dtFmt.format(punchIn) : "--"%></span>
					</div>
					<div class="flex justify-between py-3 text-sm">
						<span class="font-semibold text-slate-500">Punch Out</span> <span
							class="font-semibold text-slate-800"><%=punchOut != null ? dtFmt.format(punchOut) : "--"%></span>
					</div>
				</div>

				<%-- Weekend / leave / holiday: no punch (toast on click instead of inline banners) --%>
				<%
				if (attendanceBlockedToday) {
				%>
				<div class="flex gap-3 mt-5 flex-wrap">
					<button type="button" onclick="showAttendanceDisabledToast()"
						class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 transition-colors">
						<i class="fa-solid fa-right-to-bracket mr-1"></i> Punch In
					</button>
					<button type="button" onclick="showAttendanceDisabledToast()"
						class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-red-500 hover:bg-red-600 transition-colors">
						<i class="fa-solid fa-right-from-bracket mr-1"></i> Punch Out
					</button>
				</div>
				<%
				} else {
				%>
				<div class="flex gap-3 mt-5 flex-wrap">
					<form action="<%=request.getContextPath()%>/attendance"
						method="post">
						<input type="hidden" name="action" value="punchin">
						<button type="submit"
							class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
							<%=punchIn != null ? "disabled" : ""%>>
							<i class="fa-solid fa-right-to-bracket mr-1"></i> Punch In
						</button>
					</form>
					<form action="<%=request.getContextPath()%>/attendance"
						method="post">
						<input type="hidden" name="action" value="punchout">
						<button type="submit"
							class="px-5 py-2.5 rounded-lg text-sm font-semibold text-white bg-red-500 hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
							<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
							<i class="fa-solid fa-right-from-bracket mr-1"></i> Punch Out
						</button>
					</form>
				</div>
				<%
				}
				%>
			</div>

			<!-- Break Card -->
			<div
				class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
				<p
					class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">Break</p>
				<div
					class="bg-indigo-50 rounded-lg px-4 py-3 flex justify-between items-center mb-4">
					<span
						class="text-xs font-bold text-slate-400 uppercase tracking-wider">Total
						Break Today</span> <span class="text-lg font-bold text-indigo-600"><%=String.format("%02d:%02d:%02d", bh, bm, bs2)%></span>
				</div>
				<%-- ✅ Disable break buttons on leave days too --%>
				<div class="flex gap-3 mb-4 flex-wrap">
					<form action="<%=request.getContextPath()%>/break" method="post">
						<input type="hidden" name="action" value="start"> <input
							type="hidden" name="redirect" value="user">
						<button type="submit"
							class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-violet-600 hover:bg-violet-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
							<%=(attendanceBlockedToday || punchIn == null || punchOut != null || onBreak) ? "disabled" : ""%>>
							<i class="fa-solid fa-mug-hot mr-1"></i> Start Break
						</button>
					</form>
					<form action="<%=request.getContextPath()%>/break" method="post">
						<input type="hidden" name="action" value="end"> <input
							type="hidden" name="redirect" value="user">
						<button type="submit"
							class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-slate-500 hover:bg-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
							<%=!onBreak ? "disabled" : ""%>>
							<i class="fa-solid fa-play mr-1"></i> End Break
						</button>
					</form>
				</div>
				<div class="space-y-2 max-h-32 overflow-y-auto">
					<%
					if (breakLogs != null && !breakLogs.isEmpty()) {
						for (BreakLog b : breakLogs) {
							String s = b.getStartTime() != null ? tFmt.format(b.getStartTime()) : "--";
							String e = b.getEndTime() != null ? tFmt.format(b.getEndTime()) : "--";
					%>
					<div
						class="text-xs bg-slate-50 border border-slate-100 rounded-lg px-3 py-2 text-slate-600">
						From <strong><%=s%></strong> to <strong><%=e%></strong>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-sm text-slate-400">No breaks recorded today.</p>
					<%
					}
					%>
				</div>
			</div>
		</div>

		<!-- Activity Log with Filter -->
		<div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">

			<div class="flex flex-col gap-3 mb-5">
				<div class="flex items-center justify-between">
					<h3
						class="text-base font-bold text-slate-800 flex items-center gap-2">
						<i class="fa-solid fa-table-list text-indigo-400 text-sm"></i>
						Activity Log
					</h3>
				</div>

				<form id="filterForm" method="get"
					action="<%=request.getContextPath()%>/attendance">
					<div class="flex flex-wrap items-center gap-2">
						<button type="submit" name="period" value="all"
							class="filter-pill <%="all".equals(filterPeriod) ? "active" : ""%>">
							<i class="fa-solid fa-clock-rotate-left text-xs"></i> All
						</button>
						<button type="submit" name="period" value="week"
							class="filter-pill <%="week".equals(filterPeriod) ? "active" : ""%>">
							<i class="fa-solid fa-calendar-week text-xs"></i> This Week
						</button>
						<button type="submit" name="period" value="month"
							class="filter-pill <%="month".equals(filterPeriod) ? "active" : ""%>">
							<i class="fa-solid fa-calendar-days text-xs"></i> This Month
						</button>
						<button type="button" id="customToggle" onclick="toggleCustom()"
							class="filter-pill <%="custom".equals(filterPeriod) ? "active" : ""%>">
							<i class="fa-solid fa-sliders text-xs"></i> Custom Range
						</button>
					</div>

					<div id="customRange"
						class="<%="custom".equals(filterPeriod) ? "open" : ""%> flex-wrap items-center gap-2 mt-3">
						<input type="hidden" name="period" id="customPeriodInput"
							value="custom">
						<div class="flex flex-wrap items-center gap-2">
							<label class="text-xs font-semibold text-slate-500">From</label>
							<input type="date" name="fromDate" id="fromDate"
								value="<%=filterFrom%>" max="<%=todayStr%>"
								class="text-sm border border-slate-200 rounded-lg px-3 py-1.5 text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-300">
							<label class="text-xs font-semibold text-slate-500">To</label> <input
								type="date" name="toDate" id="toDate" value="<%=filterTo%>"
								max="<%=todayStr%>"
								class="text-sm border border-slate-200 rounded-lg px-3 py-1.5 text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-300">
							<button type="submit"
								class="px-4 py-1.5 rounded-lg text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 transition-colors">
								<i class="fa-solid fa-magnifying-glass mr-1"></i> Apply
							</button>
						</div>
					</div>
				</form>
			</div>

			<!-- Summary chips -->
			<%
			if (!"all".equals(filterPeriod) && totalDays > 0) {
			%>
			<div
				class="flex flex-wrap gap-3 mb-5 p-4 bg-slate-50 rounded-xl border border-slate-100">
				<div class="stat-chip">
					<span class="text-xl font-bold text-indigo-600"><%=totalPresent%></span>
					<span class="text-xs text-slate-500 mt-1 font-semibold text-center">Days
						Present</span>
				</div>
				<div class="stat-chip">
					<span class="text-xl font-bold text-slate-700"><%=totalDays%></span>
					<span class="text-xs text-slate-500 mt-1 font-semibold text-center">Total
						Records</span>
				</div>
				<div class="stat-chip">
					<span class="text-xl font-bold text-emerald-600"><%=swH%>h <%=String.format("%02d", swM)%>m</span>
					<span class="text-xs text-slate-500 mt-1 font-semibold text-center">Work
						Time</span>
				</div>
				<div class="stat-chip">
					<span class="text-xl font-bold text-violet-600"><%=sbH%>h <%=String.format("%02d", sbM)%>m</span>
					<span class="text-xs text-slate-500 mt-1 font-semibold text-center">Break
						Time</span>
				</div>
				<%
				if (totalPresent > 0 && totalWorkSec > 0) {
					long avgSec = totalWorkSec / totalPresent;
					int aH = (int) (avgSec / 3600), aM = (int) ((avgSec % 3600) / 60);
				%>
				<div class="stat-chip">
					<span class="text-xl font-bold text-amber-600"><%=aH%>h <%=String.format("%02d", aM)%>m</span>
					<span class="text-xs text-slate-500 mt-1 font-semibold text-center">Avg
						/ Day</span>
				</div>
				<%
				}
				%>
			</div>
			<%
			}
			%>

			<!-- Table -->
			<div class="overflow-x-auto">
				<table class="w-full text-sm">
					<thead>
						<tr class="border-b-2 border-slate-100">
							<th
								class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Date</th>
							<th
								class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Punch
								In → Out</th>
							<th
								class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Break</th>
							<th
								class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Net
								Work</th>
							<th
								class="text-left pb-3 text-xs font-bold text-slate-400 uppercase tracking-wider">Status</th>
						</tr>
					</thead>
					<tbody id="activityLogBody">
						<%
						if (activityLog != null && !activityLog.isEmpty()) {
							for (AttendanceLogEntry entry : activityLog) {
								java.sql.Timestamp pi = entry.getPunchIn();
								java.sql.Timestamp po = entry.getPunchOut();
								int br = entry.getBreakSeconds();
								long workSec = (pi != null && po != null) ? Math.max(0, (po.getTime() - pi.getTime()) / 1000 - br) : 0;
								int th = (int) (workSec / 3600), tm2 = (int) ((workSec % 3600) / 60);
								int brH = br / 3600, brM = (br % 3600) / 60;
								String piStr = pi != null ? timeFmt.format(pi) : "--";
								String poStr = po != null ? timeFmt.format(po) : "--";
								String inOut = piStr + " → " + poStr;
								String entryStatus = entry.getStatus() != null ? entry.getStatus() : "";
								String statusCls, statusDot;
								if ("Present".equals(entryStatus)) {
							statusCls = "text-emerald-700 bg-emerald-50 border border-emerald-200";
							statusDot = "bg-emerald-400";
								} else if ("Punched In".equals(entryStatus)) {
							statusCls = "text-amber-700 bg-amber-50 border border-amber-200";
							statusDot = "bg-amber-400";
								} else if ("On Leave".equals(entryStatus)) {
							statusCls = "text-blue-700 bg-blue-50 border border-blue-200";
							statusDot = "bg-blue-400";
								} // ADD this alongside the existing On Leave / Half Day / Present cases:
								else if ("Weekend".equals(entryStatus)) {
							statusCls = "text-purple-700 bg-purple-50 border border-purple-200";
							statusDot = "bg-purple-400";
								} else if ("Half Day".equals(entryStatus)) {
							statusCls = "text-orange-700 bg-orange-50 border border-orange-200";
							statusDot = "bg-orange-400";
								} else {
							statusCls = "text-slate-500 bg-slate-50 border border-slate-200";
							statusDot = "bg-slate-300";
								}
						%>
						<tr
							class="border-b border-slate-50 hover:bg-slate-50 transition-colors"
							data-log-row>
							<td class="py-3 text-slate-700 font-medium"><%=entry.getAttendanceDate() != null ? dateFmt.format(entry.getAttendanceDate()) : "--"%>
							</td>
							<td class="py-3 text-slate-600 font-mono text-xs"><%=inOut%></td>
							<td class="py-3 text-slate-500"><%=brH%>h <%=String.format("%02d", brM)%>m</td>
							<td class="py-3 text-slate-700 font-semibold"><%=workSec > 0 ? th + "h " + String.format("%02d", tm2) + "m" : "--"%>
							</td>
							<td class="py-3"><span
								class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold <%=statusCls%>">
									<span class="w-1.5 h-1.5 rounded-full <%=statusDot%>"></span> <%=entryStatus.isEmpty() ? "--" : entryStatus%>
							</span></td>
						</tr>
						<%
						}
						} else {
						%>
						<tr>
							<td colspan="5" class="py-12 text-center text-slate-400"><i
								class="fa-solid fa-calendar-xmark text-3xl mb-3 block text-slate-300"></i>
								No attendance records for this period.</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>

			<!-- Pagination footer -->
			<div
				class="flex items-center justify-between mt-4 pt-3 border-t border-slate-100">
				<span id="pageInfo" class="text-xs text-slate-400 font-medium"></span>
				<div class="flex gap-1">
					<button id="logPrev" aria-label="Previous"
						class="w-8 h-8 rounded-lg border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-50 disabled:opacity-40 text-xs transition-colors">
						<i class="fa-solid fa-chevron-left"></i>
					</button>
					<button id="logNext" aria-label="Next"
						class="w-8 h-8 rounded-lg border border-slate-200 flex items-center justify-center text-slate-500 hover:bg-slate-50 disabled:opacity-40 text-xs transition-colors">
						<i class="fa-solid fa-chevron-right"></i>
					</button>
				</div>
			</div>

		</div>
	</div>

	<script>
		var ATTENDANCE_DISABLED_MSG = 'Attendance is disabled today, please contact Admin';
		function showAttendanceDisabledToast() {
			if (window.parent && window.parent !== window && typeof window.parent.showToast === 'function') {
				window.parent.showToast(ATTENDANCE_DISABLED_MSG, 'error', 'left');
			} else {
				alert(ATTENDANCE_DISABLED_MSG);
			}
		}
		document.addEventListener('DOMContentLoaded', function() {
		    var params = new URLSearchParams(window.location.search);
		    var err = params.get('error');
		    var success = params.get('success');

		    function toast(msg, type) {
		        if (window.parent && window.parent !== window && typeof window.parent.showToast === 'function') {
		            window.parent.showToast(msg, type, 'left');
		        } else {
		            alert(msg);
		        }
		    }

		    if (success === 'PunchIn') {
		        toast('Punched in successfully!', 'success');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (success === 'PunchOut') {
		        toast('Punched out successfully!', 'success');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (success === 'breakstart') {
		        toast('Break started. Enjoy your break!', 'info');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (success === 'breakend') {
		        toast('Break ended. Welcome back!', 'success');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'OnLeave' || err === 'Weekend' || err === 'Holiday' || err === 'HolidayBreak') {
		        showAttendanceDisabledToast();
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'NotPunchedIn') {
		        toast('Please punch in before starting a break.', 'error');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'AlreadyPunchedOut') {
		        toast('You have already punched out for today.', 'error');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'AlreadyOnBreak') {
		        toast('You are already on a break.', 'error');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'NotOnBreak') {
		        toast('No active break found to end.', 'error');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    } else if (err === 'AttendanceError') {
		        toast('Something went wrong. Please try again.', 'error');
		        window.history.replaceState({}, document.title, window.location.pathname);
		    }
		});

		// ── Pagination ──────────────────────────────────────────────────────────────
		(function() {
			var rows = document
					.querySelectorAll('#activityLogBody tr[data-log-row]');
			var perPage = 7, cur = 0;
			var total = Math.max(1, Math.ceil(rows.length / perPage));
			var info = document.getElementById('pageInfo');

			function render() {
				rows.forEach(function(r, i) {
					r.style.display = (i >= cur * perPage && i < (cur + 1)
							* perPage) ? '' : 'none';
				});
				document.getElementById('logPrev').disabled = cur <= 0;
				document.getElementById('logNext').disabled = cur >= total - 1;
				if (info)
					info.textContent = rows.length ? 'Page ' + (cur + 1)
							+ ' of ' + total + ' \u2022 ' + rows.length
							+ ' records' : '';
			}

			if (rows.length) {
				render();
				document.getElementById('logPrev').onclick = function() {
					if (cur > 0) {
						cur--;
						render();
					}
				};
				document.getElementById('logNext').onclick = function() {
					if (cur < total - 1) {
						cur++;
						render();
					}
				};
			} else {
				document.getElementById('logPrev').disabled = true;
				document.getElementById('logNext').disabled = true;
			}
		})();

		// ── Custom range toggle ─────────────────────────────────────────────────────
		function toggleCustom() {
			var panel = document.getElementById('customRange');
			var toggle = document.getElementById('customToggle');
			var isOpen = panel.classList.contains('open');
			panel.classList.toggle('open', !isOpen);
			toggle.classList.toggle('active', !isOpen);
			document.getElementById('customPeriodInput').disabled = isOpen;
		}

		(function() {
	<%if ("custom".equals(filterPeriod)) {%>
		document.getElementById('customRange').classList.add('open');
			document.getElementById('customToggle').classList.add('active');
			document.getElementById('customPeriodInput').disabled = false;
	<%} else {%>
		document.getElementById('customPeriodInput').disabled = true;
	<%}%>
		})();

		document.getElementById('filterForm').addEventListener(
				'submit',
				function(e) {
					var from = document.getElementById('fromDate').value;
					var to = document.getElementById('toDate').value;
					var panel = document.getElementById('customRange');
					if (panel.classList.contains('open') && from && to
							&& from > to) {
						e.preventDefault();
						alert('"From" date cannot be after "To" date.');
					}
				});
	</script>
</body>
</html>
