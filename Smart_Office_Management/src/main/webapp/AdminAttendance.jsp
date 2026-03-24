<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="com.smartoffice.model.AdminAttendanceRow"%>
<%
List<AdminAttendanceRow> attendanceList = (List<AdminAttendanceRow>) request.getAttribute("attendanceList");
Integer tpAttr = (Integer) request.getAttribute("totalPresent");
Integer obAttr = (Integer) request.getAttribute("onBreakCount");
Integer laAttr = (Integer) request.getAttribute("lateArrivals");
Integer abAttr = (Integer) request.getAttribute("absentCount");
List<String> designations = (List<String>) request.getAttribute("designations");

int totalPresent = tpAttr != null ? tpAttr : 0;
int onBreakCount = obAttr != null ? obAttr : 0;
int lateArrivals = laAttr != null ? laAttr : 0;
int absentCount = abAttr != null ? abAttr : 0;

String search = request.getParameter("search") != null ? request.getParameter("search") : "";
String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "";
String deptFilter = request.getParameter("department") != null ? request.getParameter("department") : "";
String escapedSearch = "";
if (search != null) {
	escapedSearch = search.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");
}
SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
SimpleDateFormat headerTimeFmt = new SimpleDateFormat("hh:mm:ss a");
if (attendanceList == null)
	attendanceList = java.util.Collections.emptyList();

java.time.LocalDate exportEnd = java.time.LocalDate.now();
java.time.LocalDate exportStart = exportEnd.withDayOfMonth(1);
String exportDefaultStart = exportStart.toString();
String exportDefaultEnd = exportEnd.toString();
if (designations == null)
	designations = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance Dashboard • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<style>
body {
	font-family: 'Geist', system-ui, sans-serif;
}

.attendance-card {
	background: #fff;
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 20px 24px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	transition: box-shadow 0.2s;
}

.attendance-card:hover {
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.table-wrap {
	background: #fff;
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	overflow: hidden;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.attendance-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 14px;
}

.attendance-table th {
	text-align: left;
	padding: 14px 16px;
	background: #f1f5f9;
	color: #334155;
	font-weight: 600;
	font-size: 12px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.attendance-table td {
	padding: 14px 16px;
	border-top: 1px solid #e2e8f0;
	color: #475569;
}

.attendance-table tbody tr:hover {
	background: #f8fafc;
}

.badge-break {
	background: #dbeafe;
	color: #1e40af;
}

.badge-punched-out {
	background: #f1f5f9;
	color: #475569;
}

.badge-absent {
	background: #fee2e2;
	color: #991b1b;
}

.badge-punched-in {
	background: #dcfce7;
	color: #166534;
}

.badge-half-day {
	background: #fef3c7;
	color: #92400e;
}

.badge-present {
	background: #bbf7d0;
	color: #14532d;
}

.badge-on-leave {
	background: #e9d5ff;
	color: #5b21b6;
}

.search-input {
	padding: 10px 14px 10px 40px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	font-size: 14px;
	width: 100%;
	max-width: 280px;
}

.search-wrap {
	position: relative;
}

.search-wrap i {
	position: absolute;
	left: 14px;
	top: 50%;
	transform: translateY(-50%);
	color: #94a3b8;
}

.filter-select {
	padding: 10px 36px 10px 14px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	font-size: 14px;
	background: #fff;
	color: #334155;
}

.export-btn {
	padding: 10px 18px;
	background: #4f46e5;
	color: #fff;
	border: none;
	border-radius: 8px;
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
}

.export-btn:hover {
	background: #4338ca;
}

.avatar-circle {
	width: 40px;
	height: 40px;
	border-radius: 50%;
	background: linear-gradient(135deg, #6366f1, #8b5cf6);
	color: #fff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 700;
	font-size: 14px;
}

.action-dots {
	padding: 8px;
	color: #64748b;
	cursor: pointer;
	border-radius: 6px;
}

.action-dots:hover {
	background: #f1f5f9;
	color: #334155;
}

.export-modal-overlay {
	position: fixed;
	inset: 0;
	background: rgba(15, 23, 42, 0.45);
	backdrop-filter: blur(4px);
	display: none;
	align-items: center;
	justify-content: center;
	z-index: 10000;
}
.export-modal-overlay.show { display: flex; }
.export-modal {
	background: #fff;
	border-radius: 12px;
	padding: 24px;
	width: 100%;
	max-width: 420px;
	box-shadow: 0 25px 50px rgba(0,0,0,0.15);
}
.export-modal h3 { margin: 0 0 8px; font-size: 1.125rem; color: #0f172a; }
.export-modal p { margin: 0 0 16px; font-size: 0.875rem; color: #64748b; }
.export-modal label { display: block; font-size: 0.75rem; font-weight: 600; color: #475569; margin-bottom: 6px; }
.export-modal input[type="date"] {
	width: 100%;
	padding: 10px 12px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	margin-bottom: 14px;
}
.export-modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }
.export-modal-actions button {
	padding: 10px 18px;
	border-radius: 8px;
	font-weight: 600;
	font-size: 0.875rem;
	cursor: pointer;
	border: none;
}
.btn-modal-cancel { background: #f1f5f9; color: #334155; }
.btn-modal-submit { background: #4f46e5; color: #fff; }
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

	<div class="max-w-7xl mx-auto">
		<!-- Header -->
		<div class="flex flex-wrap items-center justify-between gap-4 mb-6">
			<div>
				<h1 class="text-2xl font-bold text-slate-800">Attendance
					Dashboard</h1>
				<p class="text-slate-600 mt-1">Real-time monitoring of all staff
					attendance and breaks.</p>
			</div>
			<div class="flex items-center gap-4">
				<span class="text-sm text-slate-500" id="liveClock"></span>
				<button type="button" class="export-btn" id="openExportModal" onclick="document.getElementById('exportModalOverlay').classList.add('show')">
					<i class="fa-solid fa-download"></i> Export Report
				</button>
			</div>
		</div>

		<!-- Summary cards -->
		<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
			<div class="attendance-card flex items-center gap-4">
				<div
					class="w-12 h-12 rounded-xl bg-indigo-100 flex items-center justify-center text-indigo-600">
					<i class="fa-solid fa-users text-xl"></i>
				</div>
				<div>
					<p
						class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Total
						Present</p>
					<p class="text-2xl font-bold text-slate-800"><%=totalPresent%></p>
				</div>
			</div>
			<div class="attendance-card flex items-center gap-4">
				<div
					class="w-12 h-12 rounded-xl bg-sky-100 flex items-center justify-center text-sky-600">
					<i class="fa-solid fa-mug-hot text-xl"></i>
				</div>
				<div>
					<p
						class="text-xs font-semibold text-slate-500 uppercase tracking-wide">On
						Break</p>
					<p class="text-2xl font-bold text-slate-800"><%=onBreakCount%></p>
				</div>
			</div>
			<div class="attendance-card flex items-center gap-4">
				<div
					class="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center text-amber-600">
					<i class="fa-solid fa-circle-exclamation text-xl"></i>
				</div>
				<div>
					<p
						class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Late
						Arrivals</p>
					<p class="text-2xl font-bold text-slate-800"><%=lateArrivals%></p>
				</div>
			</div>
			<div class="attendance-card flex items-center gap-4">
				<div
					class="w-12 h-12 rounded-xl bg-red-100 flex items-center justify-center text-red-600">
					<i class="fa-solid fa-user-minus text-xl"></i>
				</div>
				<div>
					<p
						class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Absent</p>
					<p class="text-2xl font-bold text-slate-800"><%=absentCount%></p>
				</div>
			</div>
		</div>

		<!-- Search and filters -->
		<form method="get" action="adminAttendance"
			class="flex flex-wrap items-center gap-3 mb-4">
			<div class="search-wrap">
				<i class="fa-solid fa-search"></i> <input type="text" name="search"
					class="search-input" placeholder="Search employee by name..."
					value="<%=escapedSearch%>" />
			</div>
			<select name="department" class="filter-select">
				<option value="">All Departments</option>
				<%
				if (designations != null) {
					for (String d : designations) {
				%>
				<option value="<%=d%>"
					<%=(deptFilter != null && deptFilter.equals(d)) ? "selected" : ""%>><%=d%></option>
				<%
				}
				}
				%>
			</select> <select name="status" class="filter-select">
				<option value="">All Status</option>
				<option value="Present"
					<%="Present".equals(request.getParameter("status")) ? "selected" : ""%>>Present</option>
				<option value="Absent"
					<%="Absent".equals(request.getParameter("status")) ? "selected" : ""%>>Absent</option>
			</select>
			<button type="submit"
				class="p-2.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50"
				title="Apply filters">
				<i class="fa-solid fa-filter"></i>
			</button>
		</form>

		<!-- Table -->
		<div class="table-wrap">
			<table class="attendance-table" id="attendanceTable">
				<thead>
					<tr>
						<th>Employee</th>
						<th>Punch In</th>
						<th>Punch Out</th>
						<th>Break Duration</th>
						<th>Live Status</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<%
					String searchLower = (search != null ? search : "").toLowerCase().trim();
					String dept = (deptFilter != null ? deptFilter : "").trim();
					for (AdminAttendanceRow row : attendanceList) {
						String name = row.getFullName() != null ? row.getFullName() : "";
						String desig = row.getDesignation() != null ? row.getDesignation() : "";
						String rowStatus = (row.getPunchIn() != null) ? "Present" : "Absent";

						if (!searchLower.isEmpty() && !name.toLowerCase().contains(searchLower))
						    continue;

						if (!dept.isEmpty() && !dept.equalsIgnoreCase(desig))
						    continue;

						if (!statusFilter.isEmpty() && !statusFilter.equalsIgnoreCase(rowStatus))
						    continue;
						String initials = "";
						if (name != null && !name.isEmpty()) {
							String[] parts = name.trim().split("\\s+");
							if (parts.length >= 2)
						initials = (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
							else if (parts.length == 1)
						initials = parts[0].length() >= 2 ? parts[0].substring(0, 2).toUpperCase() : parts[0].toUpperCase();
						}
						if (initials.isEmpty())
							initials = "?";
						String liveStatus = row.getLiveStatus() != null ? row.getLiveStatus() : "ABSENT";
						String badgeClass = "badge-absent";
						if ("ON BREAK".equals(liveStatus))
							badgeClass = "badge-break";
						else if ("PUNCHED IN".equals(liveStatus))
							badgeClass = "badge-punched-in";
						else if ("PUNCHED OUT".equals(liveStatus) || "Present".equals(liveStatus))
							badgeClass = "badge-punched-out";
						else if ("ABSENT".equals(liveStatus))
							badgeClass = "badge-absent";
						String punchInStr = row.getPunchIn() != null ? timeFmt.format(row.getPunchIn()) : "--";
						String punchOutStr = row.getPunchOut() != null ? timeFmt.format(row.getPunchOut()) : "--";
					%>
					<tr>
						<td>
							<div class="flex items-center gap-3">
								<div class="avatar-circle"><%=initials%></div>
								<div>
									<p class="font-semibold text-slate-800"><%=name%></p>
									<p class="text-xs text-slate-500"><%=desig.isEmpty() ? "—" : desig%></p>
								</div>
							</div>
						</td>
						<td><%=punchInStr%></td>
						<td><%=punchOutStr%></td>
						<td><%=row.getBreakDurationFormatted() != null ? row.getBreakDurationFormatted() : "--"%></td>
						<td><span
							class="px-3 py-1 rounded-full text-xs font-semibold <%=badgeClass%>"><%=liveStatus%></span></td>
						<td>
							<%
							String dbSt = row.getAttendanceStatus();
							if (dbSt != null) dbSt = dbSt.trim();
							String statusLabel = "Absent";
							String statusClass = "badge-absent";
							if (dbSt != null && !dbSt.isEmpty() && "On Leave".equalsIgnoreCase(dbSt)) {
								statusLabel = "On Leave";
								statusClass = "badge-on-leave";
							} else if (row.getPunchIn() == null) {
								/* absent */
							} else if (dbSt != null && "Half Day".equalsIgnoreCase(dbSt)) {
								statusLabel = "Half Day";
								statusClass = "badge-half-day";
							} else if (dbSt != null && "Present".equalsIgnoreCase(dbSt)) {
								statusLabel = "Present";
								statusClass = "badge-present";
							} else if (dbSt != null && "In Progress".equalsIgnoreCase(dbSt)) {
								statusLabel = "Progress";
								statusClass = "badge-punched-in";
							} else if (row.getPunchOut() == null) {
								statusLabel = "Progress";
								statusClass = "badge-punched-in";
							} else if (dbSt != null && "Absent".equalsIgnoreCase(dbSt)) {
								statusLabel = "Absent";
								statusClass = "badge-absent";
							} else {
								statusLabel = "Present";
								statusClass = "badge-present";
							}
							%> <span
							class="px-3 py-1 rounded-full text-xs font-semibold <%=statusClass%>">
								<%=statusLabel%>
						</span>
						</td>
					</tr>
					<%
					}
					%>
					<%
					boolean hasVisibleRows = false;
					for (AdminAttendanceRow r2 : attendanceList) {
						String n2 = r2.getFullName() != null ? r2.getFullName().toLowerCase() : "";
						String d2 = r2.getDesignation() != null ? r2.getDesignation() : "";
						if (!searchLower.isEmpty() && !n2.contains(searchLower))
							continue;
						if (!dept.isEmpty() && !dept.equalsIgnoreCase(d2))
							continue;
						hasVisibleRows = true;
						break;
					}
					if (!hasVisibleRows) {
					%>
					<tr>
						<td colspan="6" class="text-center py-8 text-slate-500">No
							attendance data for today.</td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
	</div>

	<div id="exportModalOverlay" class="export-modal-overlay" onclick="if(event.target===this)this.classList.remove('show')">
		<div class="export-modal" onclick="event.stopPropagation()">
			<h3>Export attendance</h3>
			<p>Choose the date range for the Excel report. Dates after today stay blank (not marked absent).</p>
			<form method="get" action="<%=request.getContextPath()%>/exportTeamAttendance"
				onsubmit="return validateExportAttendanceRange(event)">
				<label for="expStart">From</label>
				<input type="date" id="expStart" name="start" value="<%=exportDefaultStart%>" required />
				<label for="expEnd">To</label>
				<input type="date" id="expEnd" name="end" value="<%=exportDefaultEnd%>" required />
				<div class="export-modal-actions">
					<button type="button" class="btn-modal-cancel" onclick="document.getElementById('exportModalOverlay').classList.remove('show')">Cancel</button>
					<button type="submit" class="btn-modal-submit">Download</button>
				</div>
			</form>
		</div>
	</div>

	<script>
	function parseISODateLocal(s) {
		if (!s) return null;
		var p = s.split('-');
		return new Date(parseInt(p[0], 10), parseInt(p[1], 10) - 1, parseInt(p[2], 10));
	}
	function exportDaysInclusive(s, t) {
		return Math.round((t - s) / 86400000) + 1;
	}
	function notifyExportRangeToast(msg) {
		if (window.parent && typeof window.parent.showToast === 'function') {
			window.parent.showToast(msg, 'error', 'bottom');
		} else if (typeof showToast === 'function') {
			showToast(msg, 'error', 'bottom');
		} else {
			alert(msg);
		}
	}
	function validateExportAttendanceRange(ev) {
		var start = document.getElementById('expStart').value;
		var end = document.getElementById('expEnd').value;
		if (!start || !end) return true;
		var s = parseISODateLocal(start), t = parseISODateLocal(end);
		if (t < s) {
			ev.preventDefault();
			notifyExportRangeToast('From date must be on or before To date.');
			return false;
		}
		if (exportDaysInclusive(s, t) > 400) {
			ev.preventDefault();
			notifyExportRangeToast('Date range cannot exceed 400 days.');
			return false;
		}
		return true;
	}

document.addEventListener('contextmenu', e => e.preventDefault());
</script>
	<script>
document.addEventListener('contextmenu', e => e.preventDefault());

// Live clock
(function() {
    var el = document.getElementById('liveClock');
    if (!el) return;
    function update() {
        var now = new Date();
        var h = now.getHours(), m = now.getMinutes(), s = now.getSeconds();
        var ampm = h >= 12 ? 'PM' : 'AM';
        h = h % 12 || 12;
        el.textContent = (h < 10 ? '0'+h : h) + ':' + (m < 10 ? '0'+m : m) + ':' + (s < 10 ? '0'+s : s) + ' ' + ampm;
    }
    update();
    setInterval(update, 1000);
})();
</script>
</body>
</html>
