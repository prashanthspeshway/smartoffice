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
int absentCount  = abAttr != null ? abAttr : 0;

String search       = request.getParameter("search")     != null ? request.getParameter("search")     : "";
String statusFilter = request.getParameter("status")     != null ? request.getParameter("status")     : "";
String deptFilter   = request.getParameter("department") != null ? request.getParameter("department") : "";

String escapedSearch = "";
if (search != null) {
    escapedSearch = search.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;");
}

SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
if (attendanceList == null) attendanceList = java.util.Collections.emptyList();
if (designations   == null) designations   = java.util.Collections.emptyList();

java.time.LocalDate exportEnd   = java.time.LocalDate.now();
java.time.LocalDate exportStart = exportEnd.withDayOfMonth(1);
String exportDefaultStart = exportStart.toString();
String exportDefaultEnd   = exportEnd.toString();

String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance Dashboard • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
body { font-family: 'Geist', system-ui, sans-serif; }

.attendance-card {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 20px 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,.05);
    transition: box-shadow .2s;
}
.attendance-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,.08); }

.table-wrap {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    box-shadow: 0 1px 3px rgba(0,0,0,.05);
}

.attendance-table { width:100%; border-collapse:collapse; font-size:14px; }
.attendance-table th {
    text-align:left; padding:14px 16px;
    background:#f1f5f9; color:#334155;
    font-weight:600; font-size:12px;
    text-transform:uppercase; letter-spacing:.5px;
}
.attendance-table td { padding:14px 16px; border-top:1px solid #e2e8f0; color:#475569; }

/* ── Clickable rows ── */
.attendance-table tbody tr.row-clickable {
    cursor: pointer;
    transition: background .15s;
}
.attendance-table tbody tr.row-clickable:hover { background: #eef2ff; }
.attendance-table tbody tr.row-clickable:hover .employee-name { color: #4f46e5; }

.row-hint {
    display:inline-flex; align-items:center; gap:5px;
    font-size:11px; color:#94a3b8; margin-left:6px;
    opacity:0; transition:opacity .15s;
    white-space:nowrap;
}
tr.row-clickable:hover .row-hint { opacity:1; color:#6366f1; }

/* ── Badges ── */
.badge-break        { background:#dbeafe; color:#1e40af; }
.badge-punched-out  { background:#f1f5f9; color:#475569; }
.badge-absent       { background:#fee2e2; color:#991b1b; }
.badge-punched-in   { background:#dcfce7; color:#166534; }
.badge-half-day     { background:#fef3c7; color:#92400e; }
.badge-present      { background:#bbf7d0; color:#14532d; }
.badge-on-leave     { background:#e9d5ff; color:#5b21b6; }

/* ── Search & filters ── */
.search-input {
    padding:10px 14px 10px 40px;
    border:1px solid #e2e8f0; border-radius:8px;
    font-size:14px; width:100%; max-width:280px;
}
.search-wrap { position:relative; }
.search-wrap i { position:absolute; left:14px; top:50%; transform:translateY(-50%); color:#94a3b8; }

.filter-select {
    padding:10px 36px 10px 14px;
    border:1px solid #e2e8f0; border-radius:8px;
    font-size:14px; background:#fff; color:#334155;
}

.export-btn {
    padding:10px 18px; background:#4f46e5; color:#fff;
    border:none; border-radius:8px; font-weight:600;
    font-size:14px; cursor:pointer;
    display:inline-flex; align-items:center; gap:8px;
    transition: background .15s;
}
.export-btn:hover { background:#4338ca; }

.avatar-circle {
    width:40px; height:40px; border-radius:50%;
    background:linear-gradient(135deg,#6366f1,#8b5cf6);
    color:#fff; display:flex; align-items:center;
    justify-content:center; font-weight:700;
    font-size:14px; flex-shrink:0;
}

/* ══ Modal ══ */
.modal-overlay {
    position:fixed; inset:0;
    background:rgba(15,23,42,.45);
    backdrop-filter:blur(4px);
    display:none; align-items:center; justify-content:center;
    z-index:10000;
}
.modal-overlay.show { display:flex; }

.modal-box {
    background:#fff; border-radius:16px; padding:28px;
    width:100%; max-width:460px;
    box-shadow:0 25px 50px rgba(0,0,0,.18);
    animation:modalPop .2s ease;
}
@keyframes modalPop {
    from { opacity:0; transform:scale(.95) translateY(8px); }
    to   { opacity:1; transform:scale(1)   translateY(0);   }
}

.modal-header {
    display:flex; align-items:flex-start; gap:14px; margin-bottom:16px;
}
.modal-icon {
    width:44px; height:44px; border-radius:10px;
    background:#eef2ff; color:#4f46e5;
    display:flex; align-items:center; justify-content:center;
    font-size:18px; flex-shrink:0;
}
.modal-icon.single { background:#f0fdf4; color:#16a34a; }

.modal-box h3  { margin:0 0 4px; font-size:1.1rem; color:#0f172a; font-weight:700; }
.modal-sub     { font-size:.8125rem; color:#64748b; margin:0; line-height:1.4; }

.emp-badge {
    display:none;
    align-items:center; gap:6px;
    background:#f0fdf4; border:1px solid #bbf7d0;
    color:#166534; border-radius:20px;
    padding:4px 12px; font-size:.8125rem;
    font-weight:600; margin-bottom:16px;
}

.modal-box label {
    display:block; font-size:.75rem; font-weight:600;
    color:#475569; margin-bottom:6px;
    text-transform:uppercase; letter-spacing:.4px;
}
.date-row { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.date-row > div { display:flex; flex-direction:column; }

.modal-box input[type="date"] {
    width:100%; padding:10px 12px;
    border:1px solid #e2e8f0; border-radius:8px;
    font-size:.875rem; color:#334155;
    box-sizing:border-box;
}
.modal-box input[type="date"]:focus {
    outline:none; border-color:#6366f1;
    box-shadow:0 0 0 3px rgba(99,102,241,.1);
}

/* ── Action buttons row ── */
.modal-actions {
    display:flex; gap:10px; justify-content:flex-end;
    margin-top:20px; flex-wrap:wrap;
}
.modal-actions button, .modal-actions a {
    padding:10px 18px; border-radius:8px;
    font-weight:600; font-size:.875rem;
    cursor:pointer; border:none; text-decoration:none;
    display:inline-flex; align-items:center; gap:7px;
    transition:background .15s, transform .1s;
}
.modal-actions button:active,
.modal-actions a:active   { transform:scale(.97); }

.btn-cancel   { background:#f1f5f9; color:#334155; }
.btn-cancel:hover { background:#e2e8f0; }

/* View — teal/emerald */
.btn-view     { background:#0d9488; color:#fff; }
.btn-view:hover { background:#0f766e; }

/* Download — indigo */
.btn-download { background:#4f46e5; color:#fff; }
.btn-download:hover { background:#4338ca; }

/* ══ Mobile table cleanup ══ */
@media (max-width: 768px) {
    body {
        padding: 12px;
    }

    .attendance-card {
        padding: 14px 12px;
    }

    .search-input {
        max-width: 100%;
    }

    .attendance-table {
        min-width: 760px;
        font-size: 13px;
    }

    .attendance-table th,
    .attendance-table td {
        padding: 10px 10px;
        white-space: nowrap;
        vertical-align: middle;
    }

    .attendance-table th:first-child,
    .attendance-table td:first-child {
        position: sticky;
        left: 0;
        z-index: 2;
        background: #fff;
    }

    .attendance-table th:first-child {
        z-index: 3;
        background: #f1f5f9;
    }

    .attendance-table td:first-child {
        min-width: 170px;
    }

    .avatar-circle {
        width: 34px;
        height: 34px;
        font-size: 12px;
    }

    .employee-name {
        font-size: 13px;
        line-height: 1.2;
    }

    .row-hint {
        display: none;
    }

    .attendance-table td span.px-3.py-1 {
        padding: 4px 8px;
        font-size: 10px;
    }
}
</style>
</head>
<body class="bg-slate-100 min-h-screen p-3 md:p-6">

<div class="max-w-7xl mx-auto">

    <!-- ── Header ── -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
        <div>
            <h1 class="text-2xl font-bold text-slate-800">Attendance Dashboard</h1>
            <p class="text-slate-600 mt-1">Real-time monitoring of all staff attendance and breaks.</p>
        </div>
        <div class="flex items-center gap-4">
            <span class="text-sm text-slate-500" id="liveClock"></span>
            <button type="button" class="export-btn" onclick="openModal(null, null)">
                <i class="fa-solid fa-file-export"></i> Report
            </button>
        </div>
    </div>

    <!-- ── Summary cards ── -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="attendance-card flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-indigo-100 flex items-center justify-center text-indigo-600">
                <i class="fa-solid fa-users text-xl"></i>
            </div>
            <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Total Present</p>
                <p class="text-2xl font-bold text-slate-800"><%=totalPresent%></p>
            </div>
        </div>
        <div class="attendance-card flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-sky-100 flex items-center justify-center text-sky-600">
                <i class="fa-solid fa-mug-hot text-xl"></i>
            </div>
            <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide">On Break</p>
                <p class="text-2xl font-bold text-slate-800"><%=onBreakCount%></p>
            </div>
        </div>
        <div class="attendance-card flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center text-amber-600">
                <i class="fa-solid fa-circle-exclamation text-xl"></i>
            </div>
            <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Late Arrivals</p>
                <p class="text-2xl font-bold text-slate-800"><%=lateArrivals%></p>
            </div>
        </div>
        <div class="attendance-card flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-red-100 flex items-center justify-center text-red-600">
                <i class="fa-solid fa-user-minus text-xl"></i>
            </div>
            <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Absent</p>
                <p class="text-2xl font-bold text-slate-800"><%=absentCount%></p>
            </div>
        </div>
    </div>

    <!-- ── Filters ── -->
    <form method="get" action="adminAttendance"
          class="flex flex-wrap items-center gap-3 mb-2">
        <div class="search-wrap">
            <i class="fa-solid fa-search"></i>
            <input type="text" name="search" class="search-input"
                   placeholder="Search employee by name..."
                   value="<%=escapedSearch%>" />
        </div>
        <select name="department" class="filter-select">
            <option value="">All Departments</option>
            <%
            for (String d : designations) {
            %>
            <option value="<%=d%>"
                <%=(deptFilter != null && deptFilter.equals(d)) ? "selected" : ""%>><%=d%></option>
            <%
            }
            %>
        </select>
        <select name="status" class="filter-select">
            <option value="">All Status</option>
            <option value="Present" <%="Present".equals(statusFilter) ? "selected" : ""%>>Present</option>
            <option value="Absent"  <%="Absent".equals(statusFilter)  ? "selected" : ""%>>Absent</option>
        </select>
        <button type="submit"
                class="p-2.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50"
                title="Apply filters">
            <i class="fa-solid fa-filter"></i>
        </button>
    </form>

    <!-- Hint -->
    <p class="text-xs text-slate-400 mb-3 flex items-center gap-1">
        <i class="fa-solid fa-circle-info"></i>
        Click any employee row to view or download their individual attendance report.
    </p>

    <!-- ── Table ── -->
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
            String searchLower = search.toLowerCase().trim();
            String dept        = deptFilter.trim();
            boolean hasVisible = false;

            for (AdminAttendanceRow row : attendanceList) {
                String name    = row.getFullName()    != null ? row.getFullName()    : "";
                String desig   = row.getDesignation() != null ? row.getDesignation() : "";
                String rowSt   = (row.getPunchIn() != null) ? "Present" : "Absent";

                if (!searchLower.isEmpty() && !name.toLowerCase().contains(searchLower)) continue;
                if (!dept.isEmpty()        && !dept.equalsIgnoreCase(desig))             continue;
                if (!statusFilter.isEmpty()&& !statusFilter.equalsIgnoreCase(rowSt))     continue;

                hasVisible = true;

                // Initials
                String initials = "";
                if (!name.isEmpty()) {
                    String[] parts = name.trim().split("\\s+");
                    if (parts.length >= 2)
                        initials = ("" + parts[0].charAt(0) + parts[parts.length-1].charAt(0)).toUpperCase();
                    else
                        initials = name.length() >= 2 ? name.substring(0,2).toUpperCase() : name.toUpperCase();
                }
                if (initials.isEmpty()) initials = "?";

                // Live status badge
                String liveStatus = row.getLiveStatus() != null ? row.getLiveStatus() : "ABSENT";
                String liveBadge  = "badge-absent";
                if      ("ON BREAK".equals(liveStatus))    liveBadge = "badge-break";
                else if ("PUNCHED IN".equals(liveStatus))  liveBadge = "badge-punched-in";
                else if ("PUNCHED OUT".equals(liveStatus)) liveBadge = "badge-punched-out";
                else if ("ON LEAVE".equals(liveStatus))    liveBadge = "badge-on-leave";

                String punchInStr  = row.getPunchIn()  != null ? timeFmt.format(row.getPunchIn())  : "--";
                String punchOutStr = row.getPunchOut() != null ? timeFmt.format(row.getPunchOut()) : "--";

                // Attendance status badge
                String dbSt = row.getAttendanceStatus();
                if (dbSt != null) dbSt = dbSt.trim();
                String statusLabel = "Absent";
                String statusClass = "badge-absent";
                if      (dbSt != null && "On Leave".equalsIgnoreCase(dbSt))    { statusLabel="On Leave"; statusClass="badge-on-leave";  }
                else if (row.getPunchIn() == null)                              { /* absent – defaults */                                 }
                else if (dbSt != null && "Half Day".equalsIgnoreCase(dbSt))    { statusLabel="Half Day"; statusClass="badge-half-day";   }
                else if (dbSt != null && "Present".equalsIgnoreCase(dbSt))     { statusLabel="Present";  statusClass="badge-present";    }
                else if (dbSt != null && "In Progress".equalsIgnoreCase(dbSt)) { statusLabel="Progress"; statusClass="badge-punched-in"; }
                else if (row.getPunchOut() == null)                             { statusLabel="Progress"; statusClass="badge-punched-in"; }
                else if (dbSt != null && "Absent".equalsIgnoreCase(dbSt))      { /* defaults */                                          }
                else                                                            { statusLabel="Present";  statusClass="badge-present";    }

                String empId  = row.getEmployeeId() > 0 ? String.valueOf(row.getEmployeeId()) : "";
                String jsName = name.replace("\\","\\\\").replace("'","\\'");
            %>
                <tr class="row-clickable"
                    onclick="openModal('<%=empId%>', '<%=jsName%>')"
                    title="View / Export report for <%=jsName%>">
                    <td>
                        <div class="flex items-center gap-3">
                            <div class="avatar-circle"><%=initials%></div>
                            <div>
                                <p class="font-semibold text-slate-800 employee-name">
                                    <%=name%>
                                    <span class="row-hint">
                                        <i class="fa-solid fa-eye"></i> View / Export
                                    </span>
                                </p>
                                <p class="text-xs text-slate-500"><%=desig.isEmpty() ? "—" : desig%></p>
                            </div>
                        </div>
                    </td>
                    <td><%=punchInStr%></td>
                    <td><%=punchOutStr%></td>
                    <td><%=row.getBreakDurationFormatted() != null ? row.getBreakDurationFormatted() : "--"%></td>
                    <td><span class="px-3 py-1 rounded-full text-xs font-semibold <%=liveBadge%>"><%=liveStatus%></span></td>
                    <td><span class="px-3 py-1 rounded-full text-xs font-semibold <%=statusClass%>"><%=statusLabel%></span></td>
                </tr>
            <%
            }
            if (!hasVisible) {
            %>
                <tr>
                    <td colspan="6" class="text-center py-8 text-slate-500">No attendance data for today.</td>
                </tr>
            <%
            }
            %>
            </tbody>
        </table>
    </div>
</div><!-- /max-w-7xl -->

<!-- ══════════════════════════════════════════════════════════
     Report Modal  (View + Download)
═══════════════════════════════════════════════════════════ -->
<div id="modalOverlay" class="modal-overlay"
     onclick="if(event.target===this) closeModal()">
    <div class="modal-box" onclick="event.stopPropagation()">

        <div class="modal-header">
            <div class="modal-icon" id="modalIcon">
                <i class="fa-solid fa-calendar-check"></i>
            </div>
            <div>
                <h3 id="modalTitle">Attendance Report</h3>
                <p class="modal-sub" id="modalSub">
                    Choose a date range, then View online or Download as Excel.
                </p>
            </div>
        </div>

        <!-- Employee badge — single-employee mode only -->
        <div class="emp-badge" id="empBadge">
            <i class="fa-solid fa-user"></i>
            <span id="empBadgeName"></span>
        </div>

        <!-- Shared date inputs — used by BOTH buttons -->
        <div class="date-row" style="margin-bottom:0;">
            <div>
                <label for="expStart">From</label>
                <input type="date" id="expStart"
                       value="<%=exportDefaultStart%>" />
            </div>
            <div>
                <label for="expEnd">To</label>
                <input type="date" id="expEnd"
                       value="<%=exportDefaultEnd%>" />
            </div>
        </div>

        <div class="modal-actions">
            <button type="button" class="btn-cancel" onclick="closeModal()">
                Cancel
            </button>
            <!-- View — opens in new tab -->
            <button type="button" class="btn-view" id="btnView" onclick="doView()">
                <i class="fa-solid fa-eye"></i> View
            </button>
            <!-- Download — triggers Excel -->
            <button type="button" class="btn-download" id="btnDownload" onclick="doDownload()">
                <i class="fa-solid fa-download"></i> Download
            </button>
        </div>

    </div>
</div>

<!-- ══════════════════════════════════════════════════════════
     Scripts
═══════════════════════════════════════════════════════════ -->
<script>
/* ── Context path for servlet URLs ─────────────────────── */
var CTX = '<%=ctxPath%>';

/* ── State set when modal opens ─────────────────────────── */
var _empId   = '';
var _empName = '';

/* ── Modal open / close ─────────────────────────────────── */
function openModal(employeeId, employeeName) {
    _empId   = (employeeId   && employeeId   !== '') ? employeeId   : '';
    _empName = (employeeName && employeeName !== '') ? employeeName : '';

    var badge    = document.getElementById('empBadge');
    var badgeName= document.getElementById('empBadgeName');
    var icon     = document.getElementById('modalIcon');
    var title    = document.getElementById('modalTitle');
    var sub      = document.getElementById('modalSub');

    if (_empId) {
        // ── Single employee ──
        badgeName.textContent = _empName;
        badge.style.display   = 'inline-flex';
        icon.className        = 'modal-icon single';
        title.textContent     = 'Employee Report — ' + _empName;
        sub.textContent       = 'Pick a date range, then view online or download as Excel.';
    } else {
        // ── All employees ──
        badge.style.display   = 'none';
        icon.className        = 'modal-icon';
        title.textContent     = 'Team Attendance Report';
        sub.textContent       = 'Pick a date range, then view online or download as Excel.';
    }

    document.getElementById('modalOverlay').classList.add('show');
}

function closeModal() {
    document.getElementById('modalOverlay').classList.remove('show');
}

/* ── Build query-string shared by both actions ─────────── */
function buildParams() {
    var s = document.getElementById('expStart').value;
    var e = document.getElementById('expEnd').value;
    if (!validateRange(s, e)) return null;
    var p = 'start=' + encodeURIComponent(s) + '&end=' + encodeURIComponent(e);
    if (_empId) p += '&employeeId=' + encodeURIComponent(_empId);
    return p;
}

/* ── View — opens styled HTML page in new tab ───────────── */
function doView() {
    var p = buildParams();
    if (!p) return;
    window.open(CTX + '/viewAttendance?' + p, '_blank');
}

/* ── Download — triggers Excel file download ────────────── */
function doDownload() {
    var p = buildParams();
    if (!p) return;
    window.location.href = CTX + '/exportTeamAttendance?' + p;
}

/* ── Date-range validation ──────────────────────────────── */
function parseLocalDate(s) {
    if (!s) return null;
    var p = s.split('-');
    return new Date(+p[0], +p[1] - 1, +p[2]);
}
function daysInclusive(s, t) {
    return Math.round((t - s) / 86400000) + 1;
}
function showMsg(msg) {
    if (typeof showToast === 'function') showToast(msg, 'error', 'bottom');
    else alert(msg);
}
function validateRange(s, e) {
    if (!s || !e) { showMsg('Please select both From and To dates.'); return false; }
    var sd = parseLocalDate(s), ed = parseLocalDate(e);
    if (ed < sd)               { showMsg('From date must be on or before To date.');  return false; }
    if (daysInclusive(sd,ed) > 400) { showMsg('Date range cannot exceed 400 days.'); return false; }
    return true;
}

/* ── Live clock ─────────────────────────────────────────── */
(function () {
    var el = document.getElementById('liveClock');
    if (!el) return;
    function tick() {
        var n = new Date();
        var h = n.getHours(), m = n.getMinutes(), s = n.getSeconds();
        var ap = h >= 12 ? 'PM' : 'AM';
        h = h % 12 || 12;
        el.textContent =
            (h < 10 ? '0'+h : h) + ':' +
            (m < 10 ? '0'+m : m) + ':' +
            (s < 10 ? '0'+s : s) + ' ' + ap;
    }
    tick();
    setInterval(tick, 1000);
})();

document.addEventListener('contextmenu', e => e.preventDefault());
</script>
</body>
</html>
