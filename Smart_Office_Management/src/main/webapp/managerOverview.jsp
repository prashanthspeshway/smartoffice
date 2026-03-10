<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.TeamAttendance"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.Meeting"%>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    String role = (String) session.getAttribute("role");

    // Team data
    List<User> teamList       = (List<User>) request.getAttribute("teamList");
    List<TeamAttendance> teamAttendance = (List<TeamAttendance>) request.getAttribute("teamAttendance");
    List<LeaveRequest>   leaveRequests  = (List<LeaveRequest>)  request.getAttribute("leaveRequests");
    List<Task>           viewTasks      = (List<Task>)           request.getAttribute("viewTasks");
    List<Meeting>        todayMeetings  = (List<Meeting>)        request.getAttribute("todayMeetings");
    List<Notification>   notifications  = (List<Notification>)   request.getAttribute("notifications");

    // Attendance stats
    int totalTeam     = (teamList      != null) ? teamList.size()      : 0;
    int presentCount  = 0, absentCount  = 0, lateCount = 0;
    if (teamAttendance != null) {
        for (TeamAttendance ta : teamAttendance) {
            String s = ta.getStatus();
            if      ("PRESENT".equalsIgnoreCase(s))  presentCount++;
            else if ("LATE".equalsIgnoreCase(s))     lateCount++;
            else                                      absentCount++;
        }
    }
    int pendingLeave = 0;
    if (leaveRequests != null) {
        for (LeaveRequest lr : leaveRequests)
            if ("PENDING".equalsIgnoreCase(lr.getStatus())) pendingLeave++;
    }
    int meetingsToday = (todayMeetings != null) ? todayMeetings.size() : 0;
    int unreadNotifs  = (notifications != null) ? notifications.size() : 0;

    // Task stats
    int totalTasks = 0, completedTasks = 0, pendingTasks = 0;
    if (viewTasks != null) {
        totalTasks = viewTasks.size();
        for (Task t : viewTasks) {
            if ("COMPLETED".equalsIgnoreCase(t.getStatus())) completedTasks++;
            else pendingTasks++;
        }
    }

    double attendanceRate = totalTeam > 0 ? Math.round(((presentCount + lateCount) * 100.0) / totalTeam) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager Overview</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=Syne:wght@700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ─── Reset & Variables ─── */
*, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

:root {
    --bg:        #c3cfe2;
    --surface:   rgba(255,255,255,0.65);
    --surface2:  rgba(255,255,255,0.45);
    --glass:     rgba(255,255,255,0.3);
    --border:    rgba(255,255,255,0.55);
    --text-main: #1a2540;
    --text-muted:#4a5578;
    --text-light:#8492b4;
    --accent1:   #6366f1;
    --accent2:   #764ba2;
    --green:     #10b981;
    --amber:     #f59e0b;
    --red:       #ef4444;
    --blue:      #3b82f6;
    --radius:    16px;
    --shadow:    0 8px 32px rgba(30,41,100,.13);
    --shadow-lg: 0 16px 48px rgba(30,41,100,.18);
}

body {
    font-family: 'DM Sans', sans-serif;
    background: var(--bg);
    color: var(--text-main);
    min-height: 100vh;
    overflow-x: hidden;
}

/* ─── Scrollbar ─── */
::-webkit-scrollbar        { width:6px; }
::-webkit-scrollbar-track  { background:transparent; }
::-webkit-scrollbar-thumb  { background:rgba(99,102,241,.35); border-radius:8px; }

/* ─── Page Wrapper ─── */
.overview-page {
    padding: 28px 32px 40px;
    max-width: 1400px;
    margin: 0 auto;
    animation: pageIn .5s ease both;
}

@keyframes pageIn { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }

/* ─── Header ─── */
.ov-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 30px;
    flex-wrap: wrap;
    gap: 12px;
}

.ov-title-block h1 {
    font-family: 'Syne', sans-serif;
    font-size: 28px;
    font-weight: 800;
    background: linear-gradient(135deg, var(--accent1), var(--accent2));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    line-height: 1.1;
}

.ov-title-block p {
    font-size: 13px;
    color: var(--text-muted);
    margin-top: 4px;
    font-weight: 400;
}

.live-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 30px;
    background: rgba(16,185,129,.12);
    border: 1px solid rgba(16,185,129,.3);
    font-size: 12px;
    font-weight: 600;
    color: var(--green);
}

.live-dot {
    width:8px; height:8px;
    border-radius:50%;
    background: var(--green);
    animation: pulse 1.6s infinite;
}

@keyframes pulse { 0%,100%{opacity:1;transform:scale(1);} 50%{opacity:.6;transform:scale(1.3);} }

/* ─── Quick-Nav Pills ─── */
.quick-nav {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 28px;
}

.qn-pill {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 8px 18px;
    border-radius: 30px;
    background: var(--surface);
    border: 1px solid var(--border);
    color: var(--text-main);
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    backdrop-filter: blur(10px);
    transition: all .2s ease;
    box-shadow: 0 2px 8px rgba(0,0,0,.06);
}

.qn-pill:hover, .qn-pill.active {
    background: linear-gradient(135deg, var(--accent1), var(--accent2));
    color: #fff;
    border-color: transparent;
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(99,102,241,.35);
}

.qn-pill i { font-size: 12px; }

/* ─── Stat Cards Row ─── */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 18px;
    margin-bottom: 28px;
}

.stat-card {
    background: var(--surface);
    backdrop-filter: blur(16px);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 22px 20px;
    box-shadow: var(--shadow);
    display: flex;
    align-items: center;
    gap: 16px;
    cursor: default;
    transition: transform .22s ease, box-shadow .22s ease;
    animation: cardIn .45s ease both;
}

.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-lg);
}

@keyframes cardIn { from{opacity:0;transform:translateY(18px);} to{opacity:1;transform:translateY(0);} }
.stat-card:nth-child(1){animation-delay:.05s}
.stat-card:nth-child(2){animation-delay:.10s}
.stat-card:nth-child(3){animation-delay:.15s}
.stat-card:nth-child(4){animation-delay:.20s}
.stat-card:nth-child(5){animation-delay:.25s}
.stat-card:nth-child(6){animation-delay:.30s}

.stat-icon {
    width: 52px; height: 52px;
    border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
}

.si-purple { background: rgba(99,102,241,.15);  color: var(--accent1); }
.si-green  { background: rgba(16,185,129,.15);  color: var(--green);   }
.si-amber  { background: rgba(245,158,11,.15);  color: var(--amber);   }
.si-red    { background: rgba(239,68,68,.15);   color: var(--red);     }
.si-blue   { background: rgba(59,130,246,.15);  color: var(--blue);    }
.si-teal   { background: rgba(20,184,166,.15);  color: #14b8a6;        }

.stat-info { flex:1; min-width:0; }

.stat-info .label {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-light);
    text-transform: uppercase;
    letter-spacing: .6px;
    margin-bottom: 4px;
}

.stat-info .value {
    font-family: 'Syne', sans-serif;
    font-size: 30px;
    font-weight: 800;
    color: var(--text-main);
    line-height: 1;
}

.stat-info .sub {
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 3px;
}

/* ─── Progress Bar ─── */
.progress-wrap { margin-top: 8px; }

.progress-bar-bg {
    height: 6px;
    background: rgba(0,0,0,.08);
    border-radius: 10px;
    overflow: hidden;
}

.progress-bar-fill {
    height: 100%;
    border-radius: 10px;
    background: linear-gradient(90deg, var(--accent1), var(--accent2));
    transition: width 1.2s cubic-bezier(.4,0,.2,1);
}

/* ─── Two-Column Layout ─── */
.dashboard-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 20px;
}

.dashboard-grid.triple {
    grid-template-columns: 1.2fr 1fr 1fr;
}

@media(max-width:1100px) {
    .dashboard-grid, .dashboard-grid.triple { grid-template-columns: 1fr 1fr; }
}
@media(max-width:700px) {
    .dashboard-grid, .dashboard-grid.triple { grid-template-columns: 1fr; }
}

/* ─── Panel Card ─── */
.panel {
    background: var(--surface);
    backdrop-filter: blur(16px);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 22px;
    box-shadow: var(--shadow);
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.panel.full { grid-column: 1 / -1; }

.panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
}

.panel-title {
    display: flex;
    align-items: center;
    gap: 10px;
    font-family: 'Syne', sans-serif;
    font-size: 15px;
    font-weight: 700;
    color: var(--text-main);
}

.panel-title .icon-dot {
    width: 32px; height: 32px;
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 14px;
}

.panel-action {
    font-size: 12px;
    font-weight: 600;
    color: var(--accent1);
    text-decoration: none;
    cursor: pointer;
    background: none;
    border: none;
    padding: 5px 10px;
    border-radius: 8px;
    transition: background .2s;
}
.panel-action:hover { background: rgba(99,102,241,.1); }

/* ─── Attendance Donut ─── */
.donut-wrap {
    display: flex;
    align-items: center;
    gap: 22px;
}

.donut-svg { flex-shrink: 0; }

.donut-legend {
    display: flex;
    flex-direction: column;
    gap: 10px;
    flex: 1;
}

.legend-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    font-size: 13px;
}

.legend-dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
}

.legend-label { color: var(--text-muted); flex: 1; }
.legend-count  { font-weight: 700; color: var(--text-main); }

/* ─── Attendance Rate Arc ─── */
.arc-label {
    text-anchor: middle;
    font-family: 'Syne', sans-serif;
    font-weight: 800;
    fill: var(--text-main);
}

.arc-sub {
    text-anchor: middle;
    font-family: 'DM Sans', sans-serif;
    font-size: 10px;
    fill: var(--text-muted);
}

/* ─── Mini List Items ─── */
.mini-list { display: flex; flex-direction: column; gap: 10px; }

.mini-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--glass);
    border: 1px solid var(--border);
    transition: background .2s;
}

.mini-item:hover { background: rgba(255,255,255,.55); }

.mini-avatar {
    width: 36px; height: 36px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--accent1), var(--accent2));
    color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-size: 13px;
    font-weight: 700;
    flex-shrink: 0;
}

.mini-info { flex: 1; min-width: 0; }
.mini-name { font-size: 13px; font-weight: 600; color: var(--text-main); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.mini-sub  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

/* ─── Status Chips ─── */
.chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    white-space: nowrap;
    flex-shrink: 0;
}

.chip-green  { background: rgba(16,185,129,.15);  color: #059669; }
.chip-amber  { background: rgba(245,158,11,.15);  color: #d97706; }
.chip-red    { background: rgba(239,68,68,.15);   color: #dc2626; }
.chip-blue   { background: rgba(59,130,246,.15);  color: #2563eb; }
.chip-purple { background: rgba(99,102,241,.15);  color: #6366f1; }
.chip-gray   { background: rgba(100,116,139,.12); color: #64748b; }

/* ─── Meeting Timeline ─── */
.meeting-timeline { display: flex; flex-direction: column; gap: 10px; }

.mt-item {
    display: flex;
    gap: 12px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--glass);
    border: 1px solid var(--border);
    border-left: 4px solid var(--accent1);
    transition: transform .15s;
}

.mt-item:hover { transform: translateX(3px); }

.mt-time {
    min-width: 60px;
    font-size: 11px;
    font-weight: 700;
    color: var(--accent1);
    padding-top: 2px;
    line-height: 1.3;
}

.mt-body { flex: 1; }
.mt-title { font-size: 13px; font-weight: 600; color: var(--text-main); margin-bottom: 3px; }
.mt-desc  { font-size: 11px; color: var(--text-muted); }

.join-link {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    border-radius: 14px;
    font-size: 11px;
    font-weight: 700;
    color: var(--blue);
    background: rgba(59,130,246,.1);
    text-decoration: none;
    margin-top: 6px;
    transition: background .2s;
}
.join-link:hover { background: rgba(59,130,246,.2); }

/* ─── Leave Pending Items ─── */
.leave-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--glass);
    border: 1px solid var(--border);
}

.leave-meta { flex: 1; min-width: 0; }
.leave-name { font-size: 13px; font-weight: 600; }
.leave-detail { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

.leave-btns { display: flex; gap: 6px; }

.btn-xs {
    padding: 5px 12px;
    border-radius: 10px;
    border: none;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    transition: transform .15s, box-shadow .15s;
}
.btn-xs:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,.15); }

.btn-approve { background: var(--green); color: #fff; }
.btn-reject  { background: var(--red);   color: #fff; }

/* ─── Stacked Bar Chart ─── */
.bar-chart { display: flex; flex-direction: column; gap: 10px; }

.bar-row {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
}

.bar-label { width: 90px; color: var(--text-muted); font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.bar-track { flex: 1; height: 10px; background: rgba(0,0,0,.07); border-radius: 8px; overflow: hidden; }
.bar-fill  { height: 100%; border-radius: 8px; }
.bar-val   { width: 32px; text-align: right; color: var(--text-main); font-weight: 700; }

/* ─── Empty State ─── */
.empty-state {
    text-align: center;
    padding: 24px;
    color: var(--text-light);
    font-size: 13px;
}
.empty-state i { font-size: 28px; margin-bottom: 8px; display: block; opacity: .4; }

/* ─── Notification Badge in panel ─── */
.notif-count {
    background: var(--red);
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    padding: 2px 7px;
    border-radius: 20px;
}

/* ─── Team Member Row ─── */
.team-row {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    border-radius: 12px;
    background: var(--glass);
    border: 1px solid var(--border);
    cursor: pointer;
    transition: background .2s;
}
.team-row:hover { background: rgba(255,255,255,.55); }
.team-row .tr-info { flex:1; min-width: 0; }
.team-row .tr-name  { font-size:13px; font-weight:600; }
.team-row .tr-email { font-size:11px; color:var(--text-muted); margin-top:1px; }

/* ─── Notification items ─── */
.notif-item {
    display: flex;
    gap: 10px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--glass);
    border: 1px solid var(--border);
}
.notif-icon { font-size: 18px; flex-shrink: 0; padding-top: 1px; }
.notif-body { flex: 1; min-width: 0; }
.notif-msg  { font-size: 13px; font-weight: 500; color: var(--text-main); }
.notif-by   { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

/* ─── Scroll area ─── */
.panel-scroll {
    max-height: 300px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding-right: 4px;
}

/* ─── Summary row at bottom ─── */
.summary-ribbon {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 14px;
    padding: 18px 22px;
    background: var(--surface);
    backdrop-filter: blur(16px);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    margin-top: 4px;
}

.ribbon-item {
    display: flex;
    align-items: center;
    gap: 10px;
}
.ribbon-icon { font-size: 18px; }
.ribbon-info .r-val  { font-size: 18px; font-weight: 800; font-family: 'Syne', sans-serif; }
.ribbon-info .r-lbl  { font-size: 11px; color: var(--text-muted); font-weight: 500; }

/* ─── Divider ─── */
.divider { width:100%; height:1px; background:rgba(0,0,0,.07); border:none; margin: 4px 0; }

/* ─── Responsive ─── */
@media(max-width:600px) {
    .overview-page  { padding: 16px 14px 32px; }
    .ov-header      { flex-direction: column; align-items: flex-start; }
    .stat-grid      { grid-template-columns: 1fr 1fr; }
    .donut-wrap     { flex-direction: column; }
}
</style>
</head>
<body>
<div class="overview-page">

    <!-- ─── Header ─── -->
    <div class="ov-header">
        <div class="ov-title-block">
            <h1>Manager Overview</h1>
            <p>
                Hello, <strong><%= username %></strong> &nbsp;•&nbsp;
                <i class="fa-regular fa-calendar"></i>&nbsp;
                <span id="liveDate"></span>
            </p>
        </div>
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <div class="live-badge"><span class="live-dot"></span> Live Dashboard</div>
            <button class="qn-pill" style="background:linear-gradient(135deg,#6366f1,#764ba2);color:#fff;border-color:transparent;"
                    onclick="window.parent.showSection('selfAttendance'); window.parent.setActive(document.querySelectorAll('.sidebar-btn')[0])">
                <i class="fa-solid fa-arrow-up-right-from-square"></i> Full Dashboard
            </button>
        </div>
    </div>

    <!-- ─── Quick Nav ─── -->
    <div class="quick-nav">
        <a class="qn-pill" onclick="scrollTo('sec-stats')"><i class="fa-solid fa-gauge-high"></i> Stats</a>
        <a class="qn-pill" onclick="scrollTo('sec-attendance')"><i class="fa-solid fa-clipboard-user"></i> Attendance</a>
        <a class="qn-pill" onclick="scrollTo('sec-team')"><i class="fa-solid fa-users"></i> My Team</a>
        <a class="qn-pill" onclick="scrollTo('sec-meetings')"><i class="fa-solid fa-handshake"></i> Meetings</a>
        <a class="qn-pill" onclick="scrollTo('sec-leave')"><i class="fa-solid fa-calendar-xmark"></i> Leave</a>
        <a class="qn-pill" onclick="scrollTo('sec-notif')"><i class="fa-solid fa-bell"></i> Notifications</a>
    </div>

    <!-- ─── Stat Cards ─── -->
    <div class="stat-grid" id="sec-stats">

        <div class="stat-card">
            <div class="stat-icon si-purple"><i class="fa-solid fa-users"></i></div>
            <div class="stat-info">
                <div class="label">Team Size</div>
                <div class="value"><%= totalTeam %></div>
                <div class="sub">Direct reports</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon si-green"><i class="fa-solid fa-user-check"></i></div>
            <div class="stat-info">
                <div class="label">Present Today</div>
                <div class="value"><%= presentCount %></div>
                <div class="progress-wrap">
                    <div class="progress-bar-bg">
                        <div class="progress-bar-fill" id="presentBar"
                             style="width:0%;background:linear-gradient(90deg,#10b981,#34d399);"
                             data-target="<%= totalTeam > 0 ? (presentCount * 100 / totalTeam) : 0 %>">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon si-amber"><i class="fa-solid fa-clock-rotate-left"></i></div>
            <div class="stat-info">
                <div class="label">Late Arrivals</div>
                <div class="value"><%= lateCount %></div>
                <div class="sub">Checked in late</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon si-red"><i class="fa-solid fa-calendar-xmark"></i></div>
            <div class="stat-info">
                <div class="label">Pending Leave</div>
                <div class="value"><%= pendingLeave %></div>
                <div class="sub">Awaiting approval</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon si-blue"><i class="fa-solid fa-video"></i></div>
            <div class="stat-info">
                <div class="label">Meetings Today</div>
                <div class="value"><%= meetingsToday %></div>
                <div class="sub">Scheduled sessions</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon si-teal"><i class="fa-solid fa-bell"></i></div>
            <div class="stat-info">
                <div class="label">Notifications</div>
                <div class="value"><%= unreadNotifs %></div>
                <div class="sub">Unread messages</div>
            </div>
        </div>

    </div>

    <!-- ─── Row 1: Attendance Donut + Team Attendance Bar ─── -->
    <div class="dashboard-grid" id="sec-attendance">

        <!-- Attendance Overview Donut -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-green" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-chart-pie"></i>
                    </div>
                    Attendance Overview
                </div>
                <button class="panel-action" onclick="navigateTo('attendance')">
                    <i class="fa-solid fa-arrow-right"></i> View All
                </button>
            </div>

            <div class="donut-wrap">
                <!-- SVG Donut -->
                <svg class="donut-svg" width="130" height="130" viewBox="0 0 130 130">
                    <circle cx="65" cy="65" r="52" fill="none" stroke="#e2e8f0" stroke-width="14"/>
                    <%
                        double total = Math.max(totalTeam, 1);
                        double pAngle = (presentCount / total) * 314.159;
                        double lAngle = (lateCount / total) * 314.159;
                        double aAngle = (absentCount / total) * 314.159;
                        double p1 = presentCount > 0 ? pAngle : 0;
                        double p2 = lateCount > 0 ? lAngle : 0;
                        double p3 = absentCount > 0 ? aAngle : 0;
                        double off1 = 0;
                        double off2 = 314.159 - p1;
                        double off3 = 314.159 - p1 - p2;
                    %>
                    <% if (presentCount > 0) { %>
                    <circle cx="65" cy="65" r="50" fill="none"
                            stroke="#10b981" stroke-width="14"
                            stroke-dasharray="<%= String.format("%.1f", p1) %> 314.159"
                            stroke-dashoffset="<%= String.format("%.1f", 314.159 * 0.25) %>"
                            stroke-linecap="round"
                            style="transform:rotate(-90deg);transform-origin:65px 65px;"/>
                    <% } %>
                    <% if (lateCount > 0) { %>
                    <circle cx="65" cy="65" r="50" fill="none"
                            stroke="#f59e0b" stroke-width="14"
                            stroke-dasharray="<%= String.format("%.1f", p2) %> 314.159"
                            stroke-dashoffset="<%= String.format("%.1f", 314.159 * 0.25 - p1) %>"
                            stroke-linecap="round"
                            style="transform:rotate(-90deg);transform-origin:65px 65px;"/>
                    <% } %>
                    <% if (absentCount > 0) { %>
                    <circle cx="65" cy="65" r="50" fill="none"
                            stroke="#ef4444" stroke-width="14"
                            stroke-dasharray="<%= String.format("%.1f", p3) %> 314.159"
                            stroke-dashoffset="<%= String.format("%.1f", 314.159 * 0.25 - p1 - p2) %>"
                            stroke-linecap="round"
                            style="transform:rotate(-90deg);transform-origin:65px 65px;"/>
                    <% } %>
                    <text x="65" y="62" class="arc-label" font-size="20"><%= (int)attendanceRate %>%</text>
                    <text x="65" y="77" class="arc-sub">Present Rate</text>
                </svg>

                <div class="donut-legend">
                    <div class="legend-row">
                        <span class="legend-dot" style="background:#10b981;"></span>
                        <span class="legend-label">Present</span>
                        <span class="legend-count"><%= presentCount %></span>
                    </div>
                    <div class="legend-row">
                        <span class="legend-dot" style="background:#f59e0b;"></span>
                        <span class="legend-label">Late</span>
                        <span class="legend-count"><%= lateCount %></span>
                    </div>
                    <div class="legend-row">
                        <span class="legend-dot" style="background:#ef4444;"></span>
                        <span class="legend-label">Absent</span>
                        <span class="legend-count"><%= absentCount %></span>
                    </div>
                    <hr class="divider">
                    <div class="legend-row">
                        <span class="legend-dot" style="background:#6366f1;"></span>
                        <span class="legend-label">Total</span>
                        <span class="legend-count"><%= totalTeam %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Team Punch-In Bar Chart -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-blue" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-bars-progress"></i>
                    </div>
                    Today's Team Status
                </div>
                <button class="panel-action" onclick="navigateTo('attendance')">Details</button>
            </div>

            <div class="bar-chart panel-scroll">
                <%
                if (teamAttendance != null && !teamAttendance.isEmpty()) {
                    for (TeamAttendance ta : teamAttendance) {
                        String barColor = "#10b981";
                        if ("LATE".equalsIgnoreCase(ta.getStatus())) barColor = "#f59e0b";
                        else if ("ABSENT".equalsIgnoreCase(ta.getStatus())) barColor = "#ef4444";
                        int barPct = "ABSENT".equalsIgnoreCase(ta.getStatus()) ? 15 : ("LATE".equalsIgnoreCase(ta.getStatus()) ? 55 : 90);
                %>
                <div class="bar-row">
                    <div class="bar-label" title="<%= ta.getFullName() %>"><%= ta.getFullName() %></div>
                    <div class="bar-track">
                        <div class="bar-fill" style="width:<%= barPct %>%;background:<%= barColor %>;"></div>
                    </div>
                    <div class="bar-val">
                        <span class="chip <%= "PRESENT".equalsIgnoreCase(ta.getStatus()) ? "chip-green" : "LATE".equalsIgnoreCase(ta.getStatus()) ? "chip-amber" : "chip-red" %>"
                              style="font-size:10px;padding:2px 7px;">
                            <%= ta.getStatus() %>
                        </span>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div class="empty-state"><i class="fa-solid fa-circle-info"></i>No attendance data for today</div>
                <%
                }
                %>
            </div>
        </div>

    </div>

    <!-- ─── Row 2: Team Members + Meetings + Leave ─── -->
    <div class="dashboard-grid triple" id="sec-team">

        <!-- My Team -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-purple" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    My Team
                </div>
                <button class="panel-action" onclick="navigateTo('teamSection')">View All</button>
            </div>

            <div class="panel-scroll">
                <%
                if (teamList != null && !teamList.isEmpty()) {
                    for (User u : teamList) {
                        String initials = u.getFullname() != null && u.getFullname().length() > 0
                            ? (u.getFullname().substring(0,1).toUpperCase())
                            : "?";
                        if (u.getFullname() != null && u.getFullname().contains(" ")) {
                            String[] parts = u.getFullname().split(" ");
                            initials = parts[0].substring(0,1).toUpperCase() + parts[parts.length-1].substring(0,1).toUpperCase();
                        }
                        String chipClass = "ACTIVE".equalsIgnoreCase(u.getStatus()) ? "chip-green" : "chip-gray";
                %>
                <div class="team-row" onclick="navigateTo('teamSection')">
                    <div class="mini-avatar"><%= initials %></div>
                    <div class="tr-info">
                        <div class="tr-name"><%= u.getFullname() %></div>
                        <div class="tr-email"><%= u.getEmail() != null ? u.getEmail() : u.getUsername() %></div>
                    </div>
                    <span class="chip <%= chipClass %>"><%= u.getStatus() != null ? u.getStatus() : "—" %></span>
                </div>
                <%
                    }
                } else {
                %>
                <div class="empty-state"><i class="fa-solid fa-users-slash"></i>No team members found</div>
                <%
                }
                %>
            </div>
        </div>

        <!-- Today's Meetings -->
        <div class="panel" id="sec-meetings">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-blue" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-video"></i>
                    </div>
                    Today's Meetings
                </div>
                <button class="panel-action" onclick="navigateTo('schedulemeeting')">Schedule</button>
            </div>

            <div class="panel-scroll meeting-timeline">
                <%
                if (todayMeetings != null && !todayMeetings.isEmpty()) {
                    for (Meeting m : todayMeetings) {
                        String timeStr = m.getStartTime() != null ? m.getStartTime().toString() : "--";
                        if (timeStr.length() > 16) timeStr = timeStr.substring(11, 16);
                %>
                <div class="mt-item">
                    <div class="mt-time"><i class="fa-regular fa-clock"></i><br><%= timeStr %></div>
                    <div class="mt-body">
                        <div class="mt-title"><%= m.getTitle() %></div>
                        <div class="mt-desc">
                            <b>End:</b> <%= m.getEndTime() != null ? m.getEndTime().toString().substring(0, Math.min(16, m.getEndTime().toString().length())) : "--" %>
                        </div>
                        <%
                        if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {
                        %>
                        <a href="<%= m.getMeetingLink() %>" target="_blank" class="join-link">
                            <i class="fa-solid fa-video"></i> Join
                        </a>
                        <%
                        }
                        %>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div class="empty-state"><i class="fa-solid fa-calendar-check"></i>No meetings today — enjoy the focus time!</div>
                <%
                }
                %>
            </div>
        </div>

        <!-- Pending Leave Requests -->
        <div class="panel" id="sec-leave">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-amber" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-calendar-xmark"></i>
                    </div>
                    Leave Requests
                    <% if (pendingLeave > 0) { %>
                    <span class="notif-count"><%= pendingLeave %></span>
                    <% } %>
                </div>
                <button class="panel-action" onclick="navigateTo('leave')">All</button>
            </div>

            <div class="panel-scroll">
                <%
                if (leaveRequests != null && !leaveRequests.isEmpty()) {
                    int shown = 0;
                    for (LeaveRequest lr : leaveRequests) {
                        if (shown >= 5) break;
                        shown++;
                        String chipCls = "PENDING".equalsIgnoreCase(lr.getStatus()) ? "chip-amber"
                            : "APPROVED".equalsIgnoreCase(lr.getStatus()) ? "chip-green" : "chip-red";
                %>
                <div class="leave-item">
                    <div class="mini-avatar" style="font-size:11px;">
                        <%= lr.getUsername() != null && lr.getUsername().length() > 0 ? lr.getUsername().substring(0,1).toUpperCase() : "?" %>
                    </div>
                    <div class="leave-meta">
                        <div class="leave-name"><%= lr.getUsername() %></div>
                        <div class="leave-detail">
                            <%= lr.getLeaveType() %> &bull; <%= lr.getFromDate() %> → <%= lr.getToDate() %>
                        </div>
                    </div>
                    <% if ("PENDING".equalsIgnoreCase(lr.getStatus())) { %>
                    <div class="leave-btns">
                        <form action="leave-approval" method="post" style="display:inline;">
                            <input type="hidden" name="leaveId" value="<%= lr.getId() %>">
                            <button class="btn-xs btn-approve" name="action" value="approve">✓</button>
                        </form>
                        <form action="leave-approval" method="post" style="display:inline;">
                            <input type="hidden" name="leaveId" value="<%= lr.getId() %>">
                            <button class="btn-xs btn-reject" name="action" value="reject">✕</button>
                        </form>
                    </div>
                    <% } else { %>
                    <span class="chip <%= chipCls %>"><%= lr.getStatus() %></span>
                    <% } %>
                </div>
                <%
                    }
                } else {
                %>
                <div class="empty-state"><i class="fa-solid fa-check-circle"></i>No leave requests pending</div>
                <%
                }
                %>
            </div>
        </div>

    </div>

    <!-- ─── Row 3: Notifications + Quick Actions ─── -->
    <div class="dashboard-grid" id="sec-notif">

        <!-- Notifications -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-teal" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-bell"></i>
                    </div>
                    Notifications
                    <% if (unreadNotifs > 0) { %>
                    <span class="notif-count"><%= unreadNotifs %></span>
                    <% } %>
                </div>
            </div>

            <div class="panel-scroll">
                <%
                if (notifications != null && !notifications.isEmpty()) {
                    for (Notification n : notifications) {
                %>
                <div class="notif-item" id="notif-ov-<%= n.getId() %>">
                    <div class="notif-icon">🔔</div>
                    <div class="notif-body">
                        <div class="notif-msg"><%= n.getMessage() %></div>
                        <div class="notif-by">By <%= n.getCreatedBy() %></div>
                    </div>
                    <button class="btn-xs" style="background:rgba(99,102,241,.12);color:#6366f1;font-size:10px;"
                            onclick="markRead(<%= n.getId() %>)">Done</button>
                </div>
                <%
                    }
                } else {
                %>
                <div class="empty-state"><i class="fa-solid fa-bell-slash"></i>You're all caught up!</div>
                <%
                }
                %>
            </div>
        </div>

        <!-- Quick Actions Panel -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="stat-icon si-purple" style="width:32px;height:32px;border-radius:9px;font-size:13px;">
                        <i class="fa-solid fa-bolt"></i>
                    </div>
                    Quick Actions
                </div>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:2px;">

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;"
                        onclick="navigateTo('selfAttendance')">
                    <i class="fa-solid fa-user-check"></i> My Attendance
                </button>

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;"
                        onclick="navigateTo('assignTask')">
                    <i class="fa-solid fa-list-check"></i> Assign Task
                </button>

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;"
                        onclick="navigateTo('schedulemeeting')">
                    <i class="fa-solid fa-handshake"></i> Schedule Meet
                </button>

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;"
                        onclick="navigateTo('performance')">
                    <i class="fa-solid fa-chart-line"></i> Performance
                </button>

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;"
                        onclick="window.parent.openCalendar()">
                    <i class="fa-solid fa-calendar-days"></i> Calendar
                </button>

                <button class="qn-pill" style="justify-content:center;padding:14px 10px;border-radius:12px;font-size:13px;background:linear-gradient(135deg,#6366f1,#764ba2);color:#fff;border-color:transparent;"
                        onclick="exportAttendance()">
                    <i class="fa-solid fa-file-export"></i> Export
                </button>

            </div>

            <!-- Team Summary Ribbon -->
            <hr class="divider" style="margin-top:8px;">
            <div style="display:flex;gap:18px;flex-wrap:wrap;padding-top:4px;">
                <div class="ribbon-item">
                    <span class="ribbon-icon" style="color:#10b981;">✅</span>
                    <div class="ribbon-info">
                        <div class="r-val"><%= presentCount %></div>
                        <div class="r-lbl">Present</div>
                    </div>
                </div>
                <div class="ribbon-item">
                    <span class="ribbon-icon" style="color:#f59e0b;">⏰</span>
                    <div class="ribbon-info">
                        <div class="r-val"><%= lateCount %></div>
                        <div class="r-lbl">Late</div>
                    </div>
                </div>
                <div class="ribbon-item">
                    <span class="ribbon-icon" style="color:#ef4444;">❌</span>
                    <div class="ribbon-info">
                        <div class="r-val"><%= absentCount %></div>
                        <div class="r-lbl">Absent</div>
                    </div>
                </div>
                <div class="ribbon-item">
                    <span class="ribbon-icon" style="color:#6366f1;">📋</span>
                    <div class="ribbon-info">
                        <div class="r-val"><%= pendingLeave %></div>
                        <div class="r-lbl">Leave Pending</div>
                    </div>
                </div>
            </div>
        </div>

    </div>

</div><!-- end overview-page -->

<script>
/* ─── Live Date ─── */
(function() {
    const el = document.getElementById('liveDate');
    const opts = { weekday:'long', year:'numeric', month:'long', day:'numeric' };
    el.textContent = new Date().toLocaleDateString('en-IN', opts);
})();

/* ─── Animate progress bars on load ─── */
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.progress-bar-fill[data-target]').forEach(function(bar) {
        const target = parseInt(bar.getAttribute('data-target')) || 0;
        setTimeout(function() { bar.style.width = target + '%'; }, 200);
    });
});

/* ─── Navigate to a section in parent dashboard ─── */
function navigateTo(section) {
    try {
        if (window.parent && window.parent.showSection) {
            window.parent.showSection(section);
            // also mark the sidebar button active
            const btns = window.parent.document.querySelectorAll('.sidebar-btn');
            const sectionMap = {
                'selfAttendance': 0,
                'teamSection':    1,
                'assignTask':     2,
                'schedulemeeting':3,
                'attendance':     4,
                'leave':          5,
                'performance':    6
            };
            const idx = sectionMap[section];
            if (idx !== undefined) {
                btns.forEach(function(b) { b.classList.remove('active'); });
                if (btns[idx]) btns[idx].classList.add('active');
            }
            // For leave, do a full redirect
            if (section === 'leave') {
                window.parent.location.href = window.parent.location.pathname + '?tab=leave';
            }
        }
    } catch(e) {
        console.warn('Navigation error:', e);
    }
}

/* ─── Smooth scroll to anchor ─── */
function scrollTo(id) {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

/* ─── Mark notification as read ─── */
function markRead(id) {
    fetch('<%=request.getContextPath()%>/markNotificationRead?id=' + id, { method: 'POST' })
        .then(function(r) {
            if (r.ok) {
                const el = document.getElementById('notif-ov-' + id);
                if (el) {
                    el.style.transition = 'opacity .3s ease, transform .3s ease';
                    el.style.opacity = '0';
                    el.style.transform = 'translateX(20px)';
                    setTimeout(function() { el.remove(); }, 300);
                }
            }
        })
        .catch(function(e) { console.error(e); });
}

/* ─── Export ─── */
function exportAttendance() {
    window.parent.location.href = '<%=request.getContextPath()%>/exportTeamAttendance';
}
</script>
</body>
</html>
    