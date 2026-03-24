<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Performance"%>

<%
    /* ── Session & Auth ── */
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    String role  = (String) session.getAttribute("role");
    String email = (String) session.getAttribute("email");

    /* ── User Profile ── */
    User userObj = (User) request.getAttribute("user");

    /* ── Attendance ── */
    java.sql.Timestamp punchIn  = (java.sql.Timestamp) request.getAttribute("punchIn");
    java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");

    java.util.Calendar cal = java.util.Calendar.getInstance();
    int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
    boolean isWeekend = (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY);

    String attendStatus = "Not Punched In";
    if (punchIn != null && punchOut == null) attendStatus = "Punched In";
    if (punchOut != null)                    attendStatus = "Punched Out";

    /* ── Attendance stats (from employeeOverview) ── */
    Integer daysPresentAttr      = (Integer) request.getAttribute("daysPresent");
    Integer daysAbsentAttr       = (Integer) request.getAttribute("daysAbsent");
    Integer totalWorkingDaysAttr = (Integer) request.getAttribute("totalWorkingDays");
    Integer daysHalfDayAttr      = (Integer) request.getAttribute("daysHalfDay");

    int daysPresent      = daysPresentAttr      != null ? daysPresentAttr      : 0;
    int daysAbsent       = daysAbsentAttr       != null ? daysAbsentAttr       : 0;
    int totalWorkingDays = totalWorkingDaysAttr  != null ? totalWorkingDaysAttr : 0;
    int daysHalfDay      = daysHalfDayAttr      != null ? daysHalfDayAttr      : 0;
    int attPct = totalWorkingDays > 0 ? (int)((daysPresent * 100.0) / totalWorkingDays) : 0;

    /* ── Computed punch fields ── */
    boolean isPunchedIn  = "Punched In".equalsIgnoreCase(attendStatus);
    boolean isPunchedOut = "Punched Out".equalsIgnoreCase(attendStatus);

    /* ── Lists ── */
    List<Task>         tasks         = (List<Task>)         request.getAttribute("tasks");
    List<Meeting>      meetings      = (List<Meeting>)      request.getAttribute("meetings");
    List<LeaveRequest> myLeaves      = (List<LeaveRequest>) request.getAttribute("myLeaves");
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    List<Performance>  feedbackList  = (List<Performance>)  request.getAttribute("Performance");

    /* ── Quick counts ── */
    int taskCount      = tasks         != null ? tasks.size()         : 0;
    int meetingCount   = meetings      != null ? meetings.size()      : 0;
    int notifCount     = notifications != null ? notifications.size() : 0;
    int pendingLeaves  = 0;
    if (myLeaves != null) {
        for (LeaveRequest lr : myLeaves)
            if ("PENDING".equalsIgnoreCase(lr.getStatus())) pendingLeaves++;
    }
    int completedTasks = 0;
    if (tasks != null) {
        for (Task t : tasks)
            if ("COMPLETED".equalsIgnoreCase(t.getStatus())) completedTasks++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Employee Overview</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>

/* ══════════════════════════════════════════════════
   ROOT & RESET
══════════════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
    --bg:        #eef1f8;
    --surface:   #ffffff;
    --surface2:  #f7f8fc;
    --border:    rgba(102,126,234,0.12);
    --border2:   rgba(102,126,234,0.2);
    --text:      #0f1729;
    --muted:     #6b7280;
    --light:     #9ca3af;

    --indigo:    #667eea;
    --violet:    #764ba2;
    --green:     #10b981;
    --red:       #ef4444;
    --amber:     #f59e0b;
    --blue:      #3b82f6;
    --teal:      #14b8a6;
    --purple:    #8b5cf6;

    --grad:      linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    --grad-g:    linear-gradient(135deg, #10b981, #059669);
    --grad-r:    linear-gradient(135deg, #ef4444, #dc2626);
    --grad-a:    linear-gradient(135deg, #f59e0b, #d97706);
    --grad-p:    linear-gradient(135deg, #8b5cf6, #7c3aed);
    --grad-t:    linear-gradient(135deg, #14b8a6, #0d9488);

    --radius:    16px;
    --radius-sm: 10px;
    --shadow:    0 4px 20px rgba(102,126,234,0.10);
    --shadow-md: 0 8px 30px rgba(102,126,234,0.16);
    --shadow-lg: 0 16px 48px rgba(102,126,234,0.22);

    /* Type scale aligned with Admin (adminOverview.jsp) */
    --fs-xs:  12px;
    --fs-sm:  13px;
    --fs-base:15px;
    --fs-md:  15px;
    --fs-lg:  16px;
    --fs-xl:  18px;
    --fs-2xl: 26px;
    --fs-3xl: 28px;
}

body {
    font-family: 'Geist', system-ui, -apple-system, sans-serif;
    font-size: var(--fs-base);
    line-height: 1.5;
    background: var(--bg);
    color: var(--text);
    overflow-x: hidden;
}

::-webkit-scrollbar        { width: 5px; }
::-webkit-scrollbar-track  { background: transparent; }
::-webkit-scrollbar-thumb  { background: rgba(102,126,234,.3); border-radius: 6px; }

/* ══════════════════════════════════════════════════
   PAGE WRAPPER
══════════════════════════════════════════════════ */
.ov-page {
    padding: 24px 28px 40px;
    max-width: 1380px;
    margin: 0 auto;
    animation: fadeUp .5s ease both;
}

@keyframes fadeUp {
    from { opacity:0; transform: translateY(16px); }
    to   { opacity:1; transform: translateY(0); }
}

/* ══════════════════════════════════════════════════
   HERO GREETING STRIP
══════════════════════════════════════════════════ */
.hero-strip {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--grad);
    border-radius: 20px;
    padding: 24px 30px;
    margin-bottom: 24px;
    box-shadow: var(--shadow-lg);
    position: relative;
    overflow: hidden;
    gap: 16px;
    flex-wrap: wrap;
}

/* geometric decorative circles */
.hero-strip::before {
    content: '';
    position: absolute;
    top: -40px; right: -40px;
    width: 200px; height: 200px;
    border-radius: 50%;
    background: rgba(255,255,255,.06);
    pointer-events: none;
}
.hero-strip::after {
    content: '';
    position: absolute;
    bottom: -60px; left: 20%;
    width: 160px; height: 160px;
    border-radius: 50%;
    background: rgba(255,255,255,.04);
    pointer-events: none;
}

.hero-left { position: relative; z-index: 1; }

.hero-left h1 {
    font-family: 'Geist', system-ui, sans-serif;
    font-size: var(--fs-2xl);
    font-weight: 600;
    color: #fff;
    line-height: 1.2;
    margin-bottom: 4px;
}

.hero-left p {
    font-size: var(--fs-sm);
    color: rgba(255,255,255,.8);
    font-weight: 400;
}

.hero-right {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    position: relative;
    z-index: 1;
}

.hero-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 18px;
    border-radius: 30px;
    background: rgba(255,255,255,.18);
    border: 1px solid rgba(255,255,255,.3);
    color: #fff;
    font-size: var(--fs-sm);
    font-weight: 600;
    backdrop-filter: blur(8px);
    white-space: nowrap;
}

.live-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: #4ade80;
    animation: pulse 1.6s infinite;
    flex-shrink: 0;
}

@keyframes pulse {
    0%,100% { opacity:1; transform:scale(1); }
    50%      { opacity:.6; transform:scale(1.35); }
}

/* ── Profile Chip ── */
.profile-chip {
    display: flex;
    align-items: center;
    gap: 10px;
    background: rgba(255,255,255,.18);
    border: 1px solid rgba(255,255,255,.3);
    border-radius: 30px;
    padding: 6px 14px 6px 6px;
    backdrop-filter: blur(8px);
}

.profile-avatar {
    width: 34px; height: 34px;
    border-radius: 50%;
    background: rgba(255,255,255,.3);
    display: flex; align-items: center; justify-content: center;
    font-weight: 800;
    font-size: var(--fs-base);
    color: #fff;
    flex-shrink: 0;
    border: 2px solid rgba(255,255,255,.5);
}

.profile-name {
    font-size: var(--fs-sm);
    font-weight: 700;
    color: #fff;
}
.profile-role {
    font-size: var(--fs-xs);
    color: rgba(255,255,255,.7);
    line-height: 1.2;
}

/* ══════════════════════════════════════════════════
   QUICK-NAV PILLS
══════════════════════════════════════════════════ */
.quick-nav {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 22px;
    align-items: center;
}

.qnav-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 7px 16px;
    border-radius: 30px;
    background: var(--surface);
    border: 1px solid var(--border2);
    color: var(--text);
    font-size: var(--fs-sm);
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    transition: all .2s ease;
    box-shadow: var(--shadow);
    white-space: nowrap;
    line-height: 1;
}

.qnav-pill:hover {
    background: var(--grad);
    color: #fff;
    border-color: transparent;
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(102,126,234,.3);
}

.qnav-pill i { font-size: var(--fs-xs); }

/* ══════════════════════════════════════════════════
   STAT CARDS ROW
══════════════════════════════════════════════════ */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 14px;
    margin-bottom: 22px;
}

.stat-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 18px 16px;
    box-shadow: var(--shadow);
    display: flex;
    align-items: center;
    gap: 13px;
    transition: transform .2s, box-shadow .2s;
    animation: cardIn .4s ease both;
    cursor: default;
}

.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-md);
}

@keyframes cardIn {
    from { opacity:0; transform:translateY(16px); }
    to   { opacity:1; transform:translateY(0); }
}
.stat-card:nth-child(1){animation-delay:.04s}
.stat-card:nth-child(2){animation-delay:.08s}
.stat-card:nth-child(3){animation-delay:.12s}
.stat-card:nth-child(4){animation-delay:.16s}
.stat-card:nth-child(5){animation-delay:.20s}
.stat-card:nth-child(6){animation-delay:.24s}

.sc-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 17px;
    flex-shrink: 0;
}

.ic-green  { background: rgba(16,185,129,.12);  color: var(--green);  }
.ic-red    { background: rgba(239,68,68,.10);   color: var(--red);    }
.ic-blue   { background: rgba(59,130,246,.12);  color: var(--blue);   }
.ic-amber  { background: rgba(245,158,11,.12);  color: var(--amber);  }
.ic-purple { background: rgba(139,92,246,.12);  color: var(--purple); }
.ic-teal   { background: rgba(20,184,166,.12);  color: var(--teal);   }
.ic-indigo { background: rgba(102,126,234,.12); color: var(--indigo); }

.sc-info { flex: 1; min-width: 0; }

.sc-label {
    font-size: var(--fs-xs);
    font-weight: 700;
    color: var(--light);
    text-transform: uppercase;
    letter-spacing: .6px;
    line-height: 1;
    margin-bottom: 4px;
}

.sc-value {
    font-size: 26px;
    font-weight: 900;
    line-height: 1.1;
    font-variant-numeric: tabular-nums;
}

.sc-sub {
    font-size: var(--fs-xs);
    color: var(--muted);
    margin-top: 2px;
    line-height: 1.3;
}

.cv-green  { color: var(--green);  }
.cv-red    { color: var(--red);    }
.cv-blue   { color: var(--blue);   }
.cv-amber  { color: var(--amber);  }
.cv-purple { color: var(--purple); }
.cv-teal   { color: var(--teal);   }
.cv-indigo { color: var(--indigo); }

/* ══════════════════════════════════════════════════
   SECTION LAYOUT GRIDS
══════════════════════════════════════════════════ */
.grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
    margin-bottom: 18px;
}

.grid-3 {
    display: grid;
    grid-template-columns: 1.2fr 1fr 1fr;
    gap: 18px;
    margin-bottom: 18px;
}

.grid-full { grid-column: 1 / -1; }

@media(max-width:1100px) {
    .grid-3 { grid-template-columns: 1fr 1fr; }
}
@media(max-width:700px) {
    .grid-2, .grid-3 { grid-template-columns: 1fr; }
    .stat-grid { grid-template-columns: 1fr 1fr; }
    .ov-page { padding: 14px 12px 32px; }
}

/* ══════════════════════════════════════════════════
   PANEL CARD
══════════════════════════════════════════════════ */
.panel {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 20px;
    box-shadow: var(--shadow);
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    min-height: 32px;
}

.panel-title {
    display: flex;
    align-items: center;
    gap: 9px;
    font-size: 14px;
    font-weight: 700;
    color: var(--text);
    line-height: 1.2;
}

.pt-icon {
    width: 32px; height: 32px;
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: var(--fs-base);
    flex-shrink: 0;
}

.panel-action {
    font-size: var(--fs-xs);
    font-weight: 700;
    color: var(--indigo);
    background: none;
    border: none;
    padding: 5px 10px;
    border-radius: 8px;
    cursor: pointer;
    transition: background .2s;
    white-space: nowrap;
    text-decoration: none;
    line-height: 1;
}
.panel-action:hover { background: rgba(102,126,234,.1); }

.panel-scroll {
    max-height: 280px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding-right: 3px;
}

/* ══════════════════════════════════════════════════
   PUNCH STATUS CARD — with inline forms
══════════════════════════════════════════════════ */
.ps-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 11px 14px;
    border-radius: 11px;
    background: var(--surface2);
    border: 1px solid var(--border);
    font-size: var(--fs-sm);
    margin-bottom: 0;
}

.ps-key {
    font-size: var(--fs-xs);
    font-weight: 700;
    color: var(--light);
    text-transform: uppercase;
    letter-spacing: .4px;
}

.ps-val {
    font-weight: 800;
    color: var(--text);
    font-family: 'Geist Mono', monospace;
    font-size: var(--fs-sm);
}

.badge {
    padding: 3px 11px;
    border-radius: 20px;
    font-size: var(--fs-xs);
    font-weight: 800;
    letter-spacing: .3px;
    white-space: nowrap;
}
.badge-in    { background:rgba(16,185,129,.12);  color:#059669;  border:1px solid rgba(16,185,129,.25); }
.badge-out   { background:rgba(239,68,68,.10);   color:#dc2626;  border:1px solid rgba(239,68,68,.25);  }
.badge-none  { background:rgba(156,163,175,.12); color:#6b7280;  border:1px solid rgba(156,163,175,.25);}
.badge-pend  { background:rgba(245,158,11,.12);  color:#d97706;  border:1px solid rgba(245,158,11,.25); }
.badge-appr  { background:rgba(16,185,129,.12);  color:#059669;  border:1px solid rgba(16,185,129,.25); }
.badge-rej   { background:rgba(239,68,68,.10);   color:#dc2626;  border:1px solid rgba(239,68,68,.25);  }
.badge-done  { background:rgba(16,185,129,.12);  color:#059669;  border:1px solid rgba(16,185,129,.25); }
.badge-incomp{ background:rgba(239,68,68,.10);   color:#dc2626;  border:1px solid rgba(239,68,68,.25);  }
.badge-err   { background:rgba(245,158,11,.12);  color:#d97706;  border:1px solid rgba(245,158,11,.25); }
.badge-doc   { background:rgba(59,130,246,.12);  color:#2563eb;  border:1px solid rgba(59,130,246,.25); }

/* Punch buttons */
.punch-btn-row {
    display: flex;
    gap: 10px;
    margin-top: 4px;
}

.punch-btn {
    flex: 1;
    padding: 11px 0;
    border: none;
    border-radius: 11px;
    font-size: var(--fs-sm);
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    transition: transform .15s, box-shadow .15s, opacity .15s;
    font-family: 'Geist', system-ui, sans-serif;
}

.punch-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 6px 18px rgba(0,0,0,.14);
}
.punch-btn:disabled { opacity: .45; cursor: not-allowed; }

.btn-in  { background: var(--grad-g); color: #fff; box-shadow: 0 4px 12px rgba(16,185,129,.3); }
.btn-out { background: var(--grad-r); color: #fff; box-shadow: 0 4px 12px rgba(239,68,68,.3);  }

/* ══════════════════════════════════════════════════
   ATTENDANCE PIE CHART CARD
══════════════════════════════════════════════════ */
.chart-wrap {
    display: flex;
    align-items: center;
    gap: 20px;
}

.chart-wrap canvas {
    max-width: 150px;
    max-height: 150px;
    flex-shrink: 0;
}

.chart-legend {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.cl-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: var(--fs-sm);
    gap: 8px;
}

.cl-left { display: flex; align-items: center; gap: 7px; }

.cl-dot {
    width: 9px; height: 9px;
    border-radius: 50%;
    flex-shrink: 0;
}

.cl-label { color: var(--muted); font-size: var(--fs-sm); }
.cl-val   { font-weight: 800; font-size: var(--fs-sm); }

.cl-bar-wrap { height: 3px; background: #f3f4f6; border-radius: 2px; margin-top: 3px; overflow: hidden; }
.cl-bar { height: 100%; border-radius: 2px; transition: width 1.3s ease; }

/* ══════════════════════════════════════════════════
   BREAK TIME
══════════════════════════════════════════════════ */
.break-clock-box {
    background: linear-gradient(135deg, #f5f3ff, #ede9fe);
    border: 1px solid rgba(139,92,246,.2);
    border-radius: 14px;
    padding: 20px 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    position: relative;
    overflow: hidden;
}

.break-clock-box::before {
    content:'';
    position:absolute; top:-30px; right:-30px;
    width:100px; height:100px;
    border-radius:50%;
    background:rgba(139,92,246,.07);
    pointer-events:none;
}

.bsb {
    font-size: var(--fs-xs);
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: .5px;
    padding: 3px 12px;
    border-radius: 20px;
    margin-bottom: 10px;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}
.bsb-idle   { background:rgba(156,163,175,.12); color:#6b7280;  border:1px solid rgba(156,163,175,.25); }
.bsb-active { background:rgba(139,92,246,.12);  color:#7c3aed;  border:1px solid rgba(139,92,246,.3);
              animation: bpulse 1.8s ease-in-out infinite; }
.bsb-done   { background:rgba(16,185,129,.12);  color:#059669;  border:1px solid rgba(16,185,129,.25); }

@keyframes bpulse {
    0%,100%{ box-shadow:0 0 0 0 rgba(139,92,246,.25); }
    50%    { box-shadow:0 0 0 6px rgba(139,92,246,.0); }
}

.break-timer-big {
    font-size: 38px;
    font-weight: 900;
    color: #4c1d95;
    letter-spacing: 2px;
    line-height: 1;
    font-family: 'Geist Mono', monospace;
    font-variant-numeric: tabular-nums;
    position: relative; z-index: 1;
}
.break-timer-big.running { color: #7c3aed; }

.break-timer-sub {
    font-size: var(--fs-xs);
    color: #a78bfa;
    font-weight: 600;
    margin-top: 5px;
    position: relative; z-index: 1;
}

.break-btn-row {
    display: flex;
    gap: 10px;
}

.break-btn {
    flex: 1;
    padding: 11px 0;
    border: none;
    border-radius: 11px;
    font-size: var(--fs-sm);
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    transition: transform .15s, box-shadow .15s, opacity .15s;
    font-family: 'Geist', system-ui, sans-serif;
}
.break-btn:hover:not(:disabled) { transform:translateY(-2px); box-shadow:0 6px 18px rgba(0,0,0,.14); }
.break-btn:disabled { opacity:.4; cursor:not-allowed; }

.btn-break-start { background: var(--grad-p); color:#fff; box-shadow:0 4px 12px rgba(139,92,246,.35); }
.btn-break-end   { background: var(--grad-t); color:#fff; box-shadow:0 4px 12px rgba(20,184,166,.3);  }

/* Break mini stats */
.break-mini-stats {
    display: flex;
    gap: 10px;
}

.bms-item {
    flex: 1;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 11px;
    padding: 10px 12px;
    text-align: center;
}
.bms-lbl { font-size: 10px; font-weight: 700; color: var(--light); text-transform: uppercase; letter-spacing: .4px; }
.bms-val { font-size: var(--fs-lg); font-weight: 900; margin-top: 2px; }

/* Break limit bar */
.blimit-wrap { }
.blimit-head {
    display: flex;
    justify-content: space-between;
    font-size: var(--fs-xs);
    color: var(--muted);
    font-weight: 600;
    margin-bottom: 5px;
}
.blimit-track { height: 6px; background: #f3f4f6; border-radius: 4px; overflow: hidden; }
.blimit-fill  { height:100%; border-radius:4px; background:var(--purple); transition: width .8s ease, background .4s; }
.blimit-fill.warn { background: var(--amber); }
.blimit-fill.over { background: var(--red);   }

/* Break log */
.break-log-list {
    max-height: 200px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 7px;
    padding-right: 2px;
}
.break-log-list::-webkit-scrollbar { width: 4px; }
.break-log-list::-webkit-scrollbar-thumb { background: rgba(139,92,246,.25); border-radius: 4px; }

.bli {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 9px 12px;
    background: linear-gradient(135deg,rgba(139,92,246,.04),rgba(20,184,166,.04));
    border: 1px solid rgba(139,92,246,.1);
    border-radius: 10px;
    font-size: var(--fs-xs);
    animation: logIn .3s ease;
}
@keyframes logIn { from{opacity:0;transform:translateX(-8px);} to{opacity:1;transform:translateX(0);} }

.bli-idx {
    width: 20px; height: 20px;
    background: var(--grad-p);
    color: #fff;
    border-radius: 50%;
    display:flex; align-items:center; justify-content:center;
    font-size: 9px; font-weight:800; flex-shrink:0;
}

.bli-times { flex:1; }
.bli-start { font-weight:700; color:var(--text); }
.bli-end   { color:var(--light); font-size:10px; margin-top:1px; }

.bli-dur {
    font-weight:800; font-size:11px;
    padding:2px 9px; border-radius:20px;
    background:rgba(139,92,246,.1); color:#7c3aed;
    border:1px solid rgba(139,92,246,.2);
    white-space:nowrap;
}
.bli-dur.ongoing {
    background:rgba(20,184,166,.1); color:#0d9488;
    border-color:rgba(20,184,166,.25);
    animation: bpulse 1.8s ease-in-out infinite;
}

.break-empty {
    display:flex; flex-direction:column; align-items:center;
    padding:24px 0; color:var(--light); font-size:var(--fs-sm); gap:7px;
}
.break-empty i { font-size:1.8rem; }

/* ══════════════════════════════════════════════════
   TASKS
══════════════════════════════════════════════════ */
.task-item {
    display: flex;
    align-items: center;
    gap: 11px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--surface2);
    border: 1px solid var(--border);
    transition: background .2s, transform .15s;
}
.task-item:hover { background: rgba(102,126,234,.05); transform: translateX(3px); }

.task-icon {
    width: 34px; height: 34px;
    border-radius: 10px;
    background: rgba(102,126,234,.1);
    color: var(--indigo);
    display:flex; align-items:center; justify-content:center;
    font-size: var(--fs-base); flex-shrink:0;
}

.task-info { flex:1; min-width:0; }
.task-desc {
    font-size: var(--fs-base); font-weight:600; color:var(--text);
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    line-height:1.3;
}
.task-by   { font-size:var(--fs-xs); color:var(--muted); margin-top:2px; }

.task-dropdown {
    padding: 5px 10px;
    border-radius: 14px;
    border: 1px solid var(--border2);
    font-size: var(--fs-xs);
    font-weight: 600;
    cursor: pointer;
    background: var(--surface);
    color: var(--text);
    transition: border-color .2s;
    font-family: 'Geist', system-ui, sans-serif;
    flex-shrink: 0;
}
.task-dropdown:hover { border-color: var(--indigo); }

/* Task progress bar (total tasks) */
.task-progress-wrap { margin-top: 4px; }
.task-progress-label {
    display:flex; justify-content:space-between;
    font-size:var(--fs-xs); font-weight:600; color:var(--muted); margin-bottom:4px;
}
.tpbar-track { height:7px; background:#f3f4f6; border-radius:6px; overflow:hidden; }
.tpbar-fill  { height:100%; border-radius:6px; background:var(--grad-g); transition:width 1.2s ease; }

/* ══════════════════════════════════════════════════
   MEETINGS
══════════════════════════════════════════════════ */
.meeting-item {
    display: flex;
    align-items: flex-start;
    gap: 11px;
    padding: 12px 14px;
    border-radius: 12px;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-left: 4px solid var(--indigo);
    transition: transform .15s;
}
.meeting-item:hover { transform: translateX(3px); }

.meet-time {
    min-width: 50px;
    font-size: var(--fs-xs);
    font-weight: 800;
    color: var(--indigo);
    line-height: 1.4;
    padding-top: 2px;
    text-align: center;
}

.meet-body { flex:1; min-width:0; }
.meet-title {
    font-size: var(--fs-base); font-weight:700; color:var(--text);
    line-height:1.3; margin-bottom:2px;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
}
.meet-desc { font-size:var(--fs-xs); color:var(--muted); line-height:1.4; }

.join-btn {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 11px;
    border-radius: 14px;
    font-size: var(--fs-xs);
    font-weight: 800;
    color: var(--blue);
    background: rgba(59,130,246,.1);
    text-decoration: none;
    margin-top: 6px;
    border: 1px solid rgba(59,130,246,.2);
    transition: background .2s;
}
.join-btn:hover { background: rgba(59,130,246,.2); }

/* ══════════════════════════════════════════════════
   LEAVE REQUESTS
══════════════════════════════════════════════════ */
.leave-item {
    display: flex;
    align-items: center;
    gap: 11px;
    padding: 11px 13px;
    border-radius: 12px;
    background: var(--surface2);
    border: 1px solid var(--border);
}

.leave-avatar {
    width: 34px; height: 34px;
    border-radius: 50%;
    background: var(--grad);
    color: #fff;
    display:flex; align-items:center; justify-content:center;
    font-size: var(--fs-sm); font-weight:800; flex-shrink:0;
}

.leave-info { flex:1; min-width:0; }
.leave-type {
    font-size:var(--fs-base); font-weight:700; color:var(--text);
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
}
.leave-dates { font-size:var(--fs-xs); color:var(--muted); margin-top:2px; }

/* ══════════════════════════════════════════════════
   PERFORMANCE FEEDBACK
══════════════════════════════════════════════════ */
.perf-item {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    background: linear-gradient(135deg,rgba(102,126,234,.04),rgba(118,75,162,.04));
    border: 1px solid rgba(102,126,234,.1);
    padding: 14px 16px;
    border-radius: 12px;
    gap: 12px;
    transition: transform .2s, box-shadow .2s;
}
.perf-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(102,126,234,.12);
}

.perf-left { flex:1; }
.perf-manager { font-size:var(--fs-xs); color:var(--light); font-weight:700; text-transform:uppercase; letter-spacing:.3px; margin-bottom:3px; }
.perf-rating  { font-size:var(--fs-md); font-weight:800; color:var(--text); margin-bottom:3px; }
.perf-date    { font-size:var(--fs-xs); color:var(--light); }

.rb {
    padding: 4px 12px;
    border-radius: 20px;
    font-size:var(--fs-xs); font-weight:800;
    white-space:nowrap; flex-shrink:0; align-self:center;
}
.rb-excellent { background:rgba(16,185,129,.12);  color:#059669; border:1px solid rgba(16,185,129,.25); }
.rb-good      { background:rgba(59,130,246,.12);  color:#2563eb; border:1px solid rgba(59,130,246,.25); }
.rb-average   { background:rgba(245,158,11,.12);  color:#d97706; border:1px solid rgba(245,158,11,.25); }
.rb-poor      { background:rgba(239,68,68,.10);   color:#dc2626; border:1px solid rgba(239,68,68,.25);  }

/* ══════════════════════════════════════════════════
   NOTIFICATIONS
══════════════════════════════════════════════════ */
.notif-item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 11px 13px;
    border-radius: 12px;
    background: var(--surface2);
    border: 1px solid var(--border);
}
.notif-icon { font-size:var(--fs-xl); flex-shrink:0; line-height:1.3; margin-top:1px; }
.notif-body { flex:1; min-width:0; }
.notif-msg  { font-size:var(--fs-base); font-weight:500; color:var(--text); line-height:1.4; }
.notif-by   { font-size:var(--fs-xs); color:var(--muted); margin-top:3px; }

.mark-read-btn {
    padding: 4px 10px;
    border-radius: 12px;
    border: none;
    background: rgba(102,126,234,.12);
    color: var(--indigo);
    font-size:var(--fs-xs); font-weight:700;
    cursor:pointer; flex-shrink:0; align-self:center;
    transition: background .2s;
    font-family:'Geist',system-ui,sans-serif;
}
.mark-read-btn:hover { background: rgba(102,126,234,.22); }

/* ══════════════════════════════════════════════════
   QUICK ACTIONS
══════════════════════════════════════════════════ */
.qa-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 9px;
}

.qa-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    padding: 12px 8px;
    border-radius: 12px;
    background: var(--surface2);
    border: 1px solid var(--border2);
    color: var(--text);
    font-size: var(--fs-sm);
    font-weight: 700;
    cursor: pointer;
    transition: all .2s ease;
    box-shadow: 0 2px 6px rgba(0,0,0,.04);
    white-space: nowrap;
    font-family:'Geist',system-ui,sans-serif;
    line-height: 1;
    text-decoration: none;
}
.qa-btn:hover {
    background: var(--grad);
    color: #fff;
    border-color: transparent;
    transform: translateY(-2px);
    box-shadow: 0 8px 18px rgba(102,126,234,.3);
}
.qa-btn i { font-size:var(--fs-xs); }

/* ══════════════════════════════════════════════════
   RIBBON / SUMMARY STRIP
══════════════════════════════════════════════════ */
.ribbon {
    display: flex;
    gap: 18px;
    flex-wrap: wrap;
    align-items: center;
    padding-top: 4px;
    border-top: 1px solid var(--border);
    margin-top: 4px;
}

.rib-item {
    display:flex; align-items:center; gap:8px;
}
.rib-emoji { font-size:var(--fs-lg); line-height:1; }
.rib-val   { font-size:var(--fs-3xl); font-weight:700; font-family:'Geist',system-ui,sans-serif; line-height:1.1; }
.rib-lbl   { font-size:var(--fs-xs); color:var(--muted); font-weight:500; line-height:1.2; }

/* ══════════════════════════════════════════════════
   DIVIDER
══════════════════════════════════════════════════ */
.divider { width:100%; height:1px; background:var(--border); border:none; margin:4px 0; }

/* ══════════════════════════════════════════════════
   EMPTY STATE
══════════════════════════════════════════════════ */
.empty-state {
    text-align:center; padding:22px 14px;
    color:var(--light); font-size:var(--fs-sm);
}
.empty-state i { font-size:1.8rem; display:block; margin-bottom:8px; opacity:.4; }

/* ══════════════════════════════════════════════════
   SECTION ANCHOR LABELS (section IDs for scrolling)
══════════════════════════════════════════════════ */
.sec-anchor { scroll-margin-top: 20px; }

</style>
</head>
<body>
<div class="ov-page">

    <%-- ══ HERO STRIP ══ --%>
    <div class="hero-strip">
        <div class="hero-left">
            <h1 id="greetText">Hello, <%= username %> 👋</h1>
            <p>Here's your workplace snapshot for today &nbsp;•&nbsp; <span id="liveDateStr"></span></p>
        </div>
        <div class="hero-right">
            <div class="hero-badge"><span class="live-dot"></span> Live Overview</div>
            <%
                String initials = "?";
                if (userObj != null && userObj.getFullname() != null && !userObj.getFullname().isEmpty()) {
                    String[] parts = userObj.getFullname().trim().split("\\s+");
                    initials = parts[0].substring(0,1).toUpperCase();
                    if (parts.length > 1) initials += parts[parts.length-1].substring(0,1).toUpperCase();
                } else if (username != null && !username.isEmpty()) {
                    initials = username.substring(0,1).toUpperCase();
                }
            %>
            <div class="profile-chip">
                <div class="profile-avatar"><%= initials %></div>
                <div>
                    <div class="profile-name"><%= userObj != null && userObj.getFullname() != null ? userObj.getFullname() : username %></div>
                    <div class="profile-role"><%= role != null ? role : "Employee" %></div>
                </div>
            </div>
        </div>
    </div>

    <%-- ══ QUICK NAV ══ --%>
    <div class="quick-nav">
        <a class="qnav-pill" onclick="scrollToSec('sec-stats')">   <i class="fa-solid fa-gauge-high"></i>    Stats</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-punch')">   <i class="fa-solid fa-fingerprint"></i>   Attendance</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-break')">   <i class="fa-solid fa-mug-hot"></i>       Break Time</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-tasks')">   <i class="fa-solid fa-list-check"></i>    Tasks</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-meetings')"><i class="fa-solid fa-handshake"></i>     Meetings</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-leave')">   <i class="fa-solid fa-calendar-xmark"></i>Leave</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-perf')">    <i class="fa-solid fa-star"></i>          Performance</a>
        <a class="qnav-pill" onclick="scrollToSec('sec-notif')">   <i class="fa-solid fa-bell"></i>          Notifications</a>
    </div>

    <%-- ══ STAT CARDS ══ --%>
    <div class="stat-grid sec-anchor" id="sec-stats">

        <div class="stat-card">
            <div class="sc-icon ic-green"><i class="fa-solid fa-circle-check"></i></div>
            <div class="sc-info">
                <div class="sc-label">Days Present</div>
                <div class="sc-value cv-green"><%= daysPresent %></div>
                <div class="sc-sub">This month</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="sc-icon ic-red"><i class="fa-solid fa-circle-xmark"></i></div>
            <div class="sc-info">
                <div class="sc-label">Days Absent</div>
                <div class="sc-value cv-red"><%= daysAbsent %></div>
                <div class="sc-sub">This month</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="sc-icon ic-blue"><i class="fa-solid fa-chart-pie"></i></div>
            <div class="sc-info">
                <div class="sc-label">Attendance %</div>
                <div class="sc-value cv-blue"><%= attPct %>%</div>
                <div class="sc-sub">Out of <%= totalWorkingDays %> days</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="sc-icon ic-indigo"><i class="fa-solid fa-list-check"></i></div>
            <div class="sc-info">
                <div class="sc-label">Tasks</div>
                <div class="sc-value cv-indigo"><%= taskCount %></div>
                <div class="sc-sub"><%= completedTasks %> completed</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="sc-icon ic-amber"><i class="fa-solid fa-calendar-xmark"></i></div>
            <div class="sc-info">
                <div class="sc-label">Pending Leaves</div>
                <div class="sc-value cv-amber"><%= pendingLeaves %></div>
                <div class="sc-sub">Awaiting approval</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="sc-icon ic-purple"><i class="fa-solid fa-bell"></i></div>
            <div class="sc-info">
                <div class="sc-label">Notifications</div>
                <div class="sc-value cv-purple"><%= notifCount %></div>
                <div class="sc-sub">Unread</div>
            </div>
        </div>

    </div>

    <%-- ══ ROW 1: PUNCH STATUS (left) + ATTENDANCE PIE (right) ══ --%>
    <div class="grid-2 sec-anchor" id="sec-punch">

        <%-- Today's Punch Status --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-indigo"><i class="fa-solid fa-fingerprint"></i></div>
                    Today's Punch Status
                </div>
            </div>

            <%
                String badgeCls = "badge-none";
                if (isPunchedIn)  badgeCls = "badge-in";
                if (isPunchedOut) badgeCls = "badge-out";
            %>

            <div class="panel-scroll" style="gap:9px;">
                <div class="ps-row">
                    <span class="ps-key">Status</span>
                    <span class="badge <%= badgeCls %>"><%= attendStatus %></span>
                </div>
                <div class="ps-row">
                    <span class="ps-key">Punch In</span>
                    <span class="ps-val"><%= punchIn  != null ? punchIn.toString().substring(11,19)  : "—" %></span>
                </div>
                <div class="ps-row">
                    <span class="ps-key">Punch Out</span>
                    <span class="ps-val"><%= punchOut != null ? punchOut.toString().substring(11,19) : "—" %></span>
                </div>
                <div class="ps-row">
                    <span class="ps-key">Hours Worked</span>
                    <span class="ps-val">
                    <%
                    if (punchIn != null && punchOut != null) {
                        long diff = punchOut.getTime() - punchIn.getTime();
                        long hrs  = diff / 3600000;
                        long mins = (diff % 3600000) / 60000;
                        out.print(hrs + "h " + mins + "m");
                    } else if (punchIn != null) {
                        out.print("In Progress…");
                    } else {
                        out.print("—");
                    }
                    %>
                    </span>
                </div>
            </div>

            <% if (isWeekend) { %>
            <div class="punch-btn-row" style="opacity:0.7;">
                <p style="color:#64748b;font-size:13px;margin:0;">Attendance is closed on weekends.</p>
            </div>
            <% } else { %>
            <div class="punch-btn-row">
                <form action="attendance" method="post" style="flex:1;display:flex;">
                    <input type="hidden" name="action" value="punchin">
                    <button type="submit" class="punch-btn btn-in" <%= punchIn != null ? "disabled" : "" %>>
                        <i class="fa-solid fa-right-to-bracket"></i> Punch In
                    </button>
                </form>
                <form action="attendance" method="post" style="flex:1;display:flex;">
                    <input type="hidden" name="action" value="punchout">
                    <button type="submit" class="punch-btn btn-out"
                            <%= (punchIn == null || punchOut != null) ? "disabled" : "" %>>
                        <i class="fa-solid fa-right-from-bracket"></i> Punch Out
                    </button>
                </form>
            </div>
            <% } %>
        </div>

        <%-- Attendance Breakdown Pie --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-blue"><i class="fa-solid fa-chart-pie"></i></div>
                    Attendance Breakdown
                </div>
            </div>

            <div class="chart-wrap">
                <canvas id="attChart"></canvas>
                <div class="chart-legend">
                    <div>
                        <div class="cl-row">
                            <span class="cl-left"><span class="cl-dot" style="background:#10b981;"></span><span class="cl-label">Present</span></span>
                            <span class="cl-val cv-green"><%= daysPresent %> days</span>
                        </div>
                        <div class="cl-bar-wrap">
                            <div class="cl-bar" style="background:#10b981;width:0" data-w="<%= totalWorkingDays>0?(daysPresent*100/totalWorkingDays):0 %>%"></div>
                        </div>
                    </div>
                    <div>
                        <div class="cl-row">
                            <span class="cl-left"><span class="cl-dot" style="background:#ef4444;"></span><span class="cl-label">Absent</span></span>
                            <span class="cl-val cv-red"><%= daysAbsent %> days</span>
                        </div>
                        <div class="cl-bar-wrap">
                            <div class="cl-bar" style="background:#ef4444;width:0" data-w="<%= totalWorkingDays>0?(daysAbsent*100/totalWorkingDays):0 %>%"></div>
                        </div>
                    </div>
                    <div>
                        <div class="cl-row">
                            <span class="cl-left"><span class="cl-dot" style="background:#f59e0b;"></span><span class="cl-label">Half-Day</span></span>
                            <span class="cl-val cv-amber"><%= daysHalfDay %> days</span>
                        </div>
                        <div class="cl-bar-wrap">
                            <div class="cl-bar" style="background:#f59e0b;width:0" data-w="<%= totalWorkingDays>0?(daysHalfDay*100/totalWorkingDays):0 %>%"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <%-- ══ ROW 2: BREAK TIME (full width 2-col internal) ══ --%>
    <div class="panel sec-anchor" id="sec-break" style="margin-bottom:18px;">
        <div class="panel-header">
            <div class="panel-title">
                <div class="pt-icon" style="background:rgba(139,92,246,.12);color:#8b5cf6;">
                    <i class="fa-solid fa-mug-hot"></i>
                </div>
                Break Time
            </div>
            <span style="font-size:var(--fs-xs);font-weight:600;color:var(--muted);">
                Limit: <b style="color:var(--purple);">60 min/day</b>
            </span>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">

            <%-- Left: clock + controls --%>
            <div style="display:flex;flex-direction:column;gap:11px;">

                <div class="break-clock-box">
                    <div class="bsb bsb-idle" id="bStatusBadge">
                        <i class="fa-solid fa-circle" style="font-size:7px;"></i> Idle
                    </div>
                    <div class="break-timer-big" id="bTimerDisplay">00:00:00</div>
                    <div class="break-timer-sub" id="bTimerSub">Start a break when ready</div>
                </div>

                <div class="break-btn-row">
                    <button class="break-btn btn-break-start" id="btnBreakStart"
                            onclick="startBreak()"
                            <%= (punchIn == null || punchOut != null) ? "disabled" : "" %>>
                        <i class="fa-solid fa-mug-hot"></i> Start Break
                    </button>
                    <button class="break-btn btn-break-end" id="btnBreakEnd"
                            onclick="endBreak()" disabled>
                        <i class="fa-solid fa-arrow-rotate-left"></i> End Break
                    </button>
                </div>

                <div class="break-mini-stats">
                    <div class="bms-item">
                        <div class="bms-lbl">Breaks</div>
                        <div class="bms-val cv-purple" id="bCount">0</div>
                    </div>
                    <div class="bms-item">
                        <div class="bms-lbl">Total</div>
                        <div class="bms-val cv-teal" id="bTotal">0m 0s</div>
                    </div>
                    <div class="bms-item">
                        <div class="bms-lbl">Remaining</div>
                        <div class="bms-val cv-amber" id="bRemaining">60m</div>
                    </div>
                </div>

                <div class="blimit-wrap">
                    <div class="blimit-head">
                        <span>Break Usage</span>
                        <span id="bBarPct">0%</span>
                    </div>
                    <div class="blimit-track">
                        <div class="blimit-fill" id="bBarFill" style="width:0%"></div>
                    </div>
                </div>

            </div>

            <%-- Right: break log --%>
            <div style="display:flex;flex-direction:column;gap:9px;">
                <div style="font-size:var(--fs-xs);font-weight:700;color:var(--muted);
                            text-transform:uppercase;letter-spacing:.4px;">
                    <i class="fa-regular fa-clock" style="margin-right:5px;color:#8b5cf6;"></i>
                    Today's Break Log
                </div>
                <div class="break-log-list" id="bLogList">
                    <div class="break-empty" id="bLogEmpty">
                        <i class="fa-solid fa-mug-hot"></i>
                        No breaks taken yet
                    </div>
                </div>
            </div>

        </div>
    </div>

    <%-- ══ ROW 3: TASKS + MEETINGS + LEAVE ══ --%>
    <div class="grid-3 sec-anchor" id="sec-tasks">

        <%-- Tasks --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-indigo"><i class="fa-solid fa-list-check"></i></div>
                    Assigned Tasks
                </div>
                <span style="font-size:var(--fs-xs);font-weight:700;color:var(--muted);">
                    <%= completedTasks %>/<%= taskCount %> done
                </span>
            </div>

            <%-- task progress bar --%>
            <div class="task-progress-wrap">
                <div class="task-progress-label">
                    <span>Completion</span>
                    <span><%= taskCount > 0 ? (completedTasks * 100 / taskCount) : 0 %>%</span>
                </div>
                <div class="tpbar-track">
                    <div class="tpbar-fill" style="width:<%= taskCount > 0 ? (completedTasks * 100 / taskCount) : 0 %>%"></div>
                </div>
            </div>

            <div class="panel-scroll">
                <%
                if (tasks == null || tasks.isEmpty()) {
                %>
                <div class="empty-state"><i class="fa-solid fa-check-circle"></i>No tasks assigned yet.</div>
                <%
                } else {
                    for (Task t : tasks) {
                        String tBadge = "badge-incomp";
                        if      ("COMPLETED".equalsIgnoreCase(t.getStatus()))             tBadge = "badge-done";
                        else if ("ERRORS_RAISED".equalsIgnoreCase(t.getStatus()))         tBadge = "badge-err";
                        else if ("DOCUMENT_VERIFICATION".equalsIgnoreCase(t.getStatus())) tBadge = "badge-doc";
                %>
                <div class="task-item">
                    <div class="task-icon"><i class="fa-solid fa-file-lines"></i></div>
                    <div class="task-info">
                        <div class="task-desc"><%= t.getDescription() %></div>
                        <div class="task-by">By <%= t.getAssignedBy() %></div>
                    </div>
                    <form action="updateTaskStatus" method="post" style="flex-shrink:0;">
                        <input type="hidden" name="taskId" value="<%= t.getId() %>">
                        <select name="status" class="task-dropdown" onchange="this.form.submit()">
                            <option value="">Status</option>
                            <option value="COMPLETED"             <%= "COMPLETED".equals(t.getStatus())             ? "selected" : "" %>>Complete</option>
                            <option value="INCOMPLETE"            <%= "INCOMPLETE".equals(t.getStatus())            ? "selected" : "" %>>Incomplete</option>
                            <option value="ERRORS_RAISED"         <%= "ERRORS_RAISED".equals(t.getStatus())         ? "selected" : "" %>>Errors Raised</option>
                            <option value="DOCUMENT_VERIFICATION" <%= "DOCUMENT_VERIFICATION".equals(t.getStatus()) ? "selected" : "" %>>Doc Verify</option>
                        </select>
                    </form>
                </div>
                <%
                    }
                }
                %>
            </div>
        </div>

        <%-- Meetings --%>
        <div class="panel sec-anchor" id="sec-meetings">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-blue"><i class="fa-solid fa-video"></i></div>
                    Meetings
                </div>
                <span style="font-size:var(--fs-xs);font-weight:700;color:var(--muted);"><%= meetingCount %> today</span>
            </div>

            <div class="panel-scroll">
                <%
                if (meetings == null || meetings.isEmpty()) {
                %>
                <div class="empty-state"><i class="fa-solid fa-calendar-check"></i>No meetings today!</div>
                <%
                } else {
                    for (Meeting m : meetings) {
                        String timeStr = m.getStartTime() != null ? m.getStartTime().toString() : "--";
                        if (timeStr.length() > 16) timeStr = timeStr.substring(11, 16);
                %>
                <div class="meeting-item">
                    <div class="meet-time">
                        <i class="fa-regular fa-clock"></i><br><%= timeStr %>
                    </div>
                    <div class="meet-body">
                        <div class="meet-title"><%= m.getTitle() %></div>
                        <div class="meet-desc"><%= m.getDescription() != null ? m.getDescription() : "" %></div>
                        <div class="meet-desc" style="margin-top:2px;">
                            End: <%= m.getEndTime() != null ? m.getEndTime().toString().substring(0, Math.min(16, m.getEndTime().toString().length())) : "--" %>
                        </div>
                        <% if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) { %>
                        <a href="<%= m.getMeetingLink() %>" target="_blank" class="join-btn">
                            <i class="fa-solid fa-video"></i> Join
                        </a>
                        <% } %>
                    </div>
                </div>
                <%
                    }
                }
                %>
            </div>
        </div>

        <%-- Leave Requests --%>
        <div class="panel sec-anchor" id="sec-leave">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-amber"><i class="fa-solid fa-calendar-xmark"></i></div>
                    My Leaves
                </div>
                <% if (pendingLeaves > 0) { %>
                <span style="background:var(--red);color:#fff;font-size:var(--fs-xs);
                             font-weight:800;padding:2px 8px;border-radius:20px;"><%= pendingLeaves %></span>
                <% } %>
            </div>

            <div class="panel-scroll">
                <%
                if (myLeaves == null || myLeaves.isEmpty()) {
                %>
                <div class="empty-state"><i class="fa-solid fa-plane-departure"></i>No leave requests found.</div>
                <%
                } else {
                    for (LeaveRequest lr : myLeaves) {
                        String st = lr.getStatus();
                        String lBadge = "badge-pend";
                        if ("APPROVED".equalsIgnoreCase(st))  lBadge = "badge-appr";
                        if ("REJECTED".equalsIgnoreCase(st))  lBadge = "badge-rej";
                        String av = lr.getEmail() != null && !lr.getEmail().isEmpty()
                            ? lr.getEmail().substring(0,1).toUpperCase() : "?";
                %>
                <div class="leave-item">
                    <div class="leave-avatar"><%= av %></div>
                    <div class="leave-info">
                        <div class="leave-type"><%= lr.getLeaveType() %></div>
                        <div class="leave-dates"><%= lr.getFromDate() %> → <%= lr.getToDate() %></div>
                    </div>
                    <span class="badge <%= lBadge %>"><%= st %></span>
                </div>
                <%
                    }
                }
                %>
            </div>
        </div>

    </div>

    <%-- ══ ROW 4: PERFORMANCE + NOTIFICATIONS + QUICK ACTIONS ══ --%>
    <div class="grid-3 sec-anchor" id="sec-perf">

        <%-- Performance Feedback --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-amber"><i class="fa-solid fa-star"></i></div>
                    Performance Feedback
                </div>
            </div>
            <div class="panel-scroll">
                <%
                if (feedbackList == null || feedbackList.isEmpty()) {
                %>
                <div class="empty-state">
                    <i class="fa-regular fa-face-smile"></i>
                    No feedback yet from your manager.
                </div>
                <%
                } else {
                    for (Performance p : feedbackList) {
                        String rating = p.getRating() != null ? p.getRating() : "N/A";
                        String rbCls = "rb-good";
                        String stars = "⭐⭐⭐⭐";
                        String ru = rating.toUpperCase();
                        if      (ru.contains("EXCELLENT")) { rbCls = "rb-excellent"; stars = "⭐⭐⭐⭐⭐"; }
                        else if (ru.contains("GOOD"))      { rbCls = "rb-good";      stars = "⭐⭐⭐⭐";   }
                        else if (ru.contains("AVERAGE"))   { rbCls = "rb-average";   stars = "⭐⭐⭐";     }
                        else if (ru.contains("POOR"))      { rbCls = "rb-poor";      stars = "⭐⭐";       }
                %>
                <div class="perf-item">
                    <div class="perf-left">
                        <div class="perf-manager">
                            <i class="fa-solid fa-user-tie" style="margin-right:3px;"></i>
                            <%= p.getManagerUsername() %>
                        </div>
                        <div class="perf-rating"><%= stars %> &nbsp;<%= rating %></div>
                        <div class="perf-date">
                            <i class="fa-regular fa-calendar" style="margin-right:3px;"></i>
                            <%= p.getCreatedAt() != null ? p.getCreatedAt().toString().substring(0,16) : "—" %>
                        </div>
                    </div>
                    <div class="rb <%= rbCls %>"><%= rating %></div>
                </div>
                <%
                    }
                }
                %>
            </div>
        </div>

        <%-- Notifications --%>
        <div class="panel sec-anchor" id="sec-notif">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-purple"><i class="fa-solid fa-bell"></i></div>
                    Notifications
                    <% if (notifCount > 0) { %>
                    <span style="background:var(--red);color:#fff;font-size:var(--fs-xs);
                                 font-weight:800;padding:2px 8px;border-radius:20px;flex-shrink:0;"><%= notifCount %></span>
                    <% } %>
                </div>
            </div>
            <div class="panel-scroll">
                <%
                if (notifications == null || notifications.isEmpty()) {
                %>
                <div class="empty-state"><i class="fa-solid fa-bell-slash"></i>All caught up!</div>
                <%
                } else {
                    for (Notification n : notifications) {
                %>
                <div class="notif-item" id="notif-ov-<%= n.getId() %>">
                    <div class="notif-icon">🔔</div>
                    <div class="notif-body">
                        <div class="notif-msg"><%= n.getMessage() %></div>
                        <div class="notif-by">By <%= n.getCreatedBy() %></div>
                    </div>
                    <button class="mark-read-btn" onclick="markRead(<%= n.getId() %>)">Done</button>
                </div>
                <%
                    }
                }
                %>
            </div>
        </div>

        <%-- Quick Actions --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">
                    <div class="pt-icon ic-teal"><i class="fa-solid fa-bolt"></i></div>
                    Quick Actions
                </div>
            </div>

            <div class="qa-grid">
                <button class="qa-btn" onclick="navParent('selfAttendance')">
                    <i class="fa-solid fa-user-check"></i> Attendance
                </button>
                <button class="qa-btn" onclick="navParent('tasks')">
                    <i class="fa-solid fa-list-check"></i> My Tasks
                </button>
                <button class="qa-btn" onclick="navParent('leave')">
                    <i class="fa-solid fa-calendar-xmark"></i> Apply Leave
                </button>
                <button class="qa-btn" onclick="navParent('meetings')">
                    <i class="fa-solid fa-handshake"></i> Meetings
                </button>
                <button class="qa-btn" onclick="navParent('calendar')">
                    <i class="fa-solid fa-calendar-days"></i> Calendar
                </button>
                <button class="qa-btn" style="background:var(--grad);color:#fff;border-color:transparent;"
                        onclick="navParent('profile')">
                    <i class="fa-solid fa-user-gear"></i> Profile
                </button>
            </div>

            <hr class="divider">

            <div class="ribbon">
                <div class="rib-item">
                    <span class="rib-emoji">✅</span>
                    <div>
                        <div class="rib-val cv-green"><%= daysPresent %></div>
                        <div class="rib-lbl">Present</div>
                    </div>
                </div>
                <div class="rib-item">
                    <span class="rib-emoji">📋</span>
                    <div>
                        <div class="rib-val cv-indigo"><%= completedTasks %></div>
                        <div class="rib-lbl">Tasks Done</div>
                    </div>
                </div>
                <div class="rib-item">
                    <span class="rib-emoji">📅</span>
                    <div>
                        <div class="rib-val cv-amber"><%= pendingLeaves %></div>
                        <div class="rib-lbl">Leave Pending</div>
                    </div>
                </div>
            </div>
        </div>

    </div>

</div><%-- /.ov-page --%>

<%-- ══ SCRIPTS ══ --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>

/* ── Greeting + Date ── */
(function () {
    const h = new Date().getHours();
    const greet = h < 12 ? "Good Morning" : h < 17 ? "Good Afternoon" : "Good Evening";
    document.getElementById("greetText").textContent = greet + ", <%= username %> \uD83D\uDC4B";
    const opts = { weekday:'long', day:'numeric', month:'long', year:'numeric' };
    document.getElementById("liveDateStr").textContent =
        new Date().toLocaleDateString('en-IN', opts);
})();

/* ── Attendance Pie Chart ── */
(function () {
    const ctx = document.getElementById("attChart");
    if (!ctx) return;
    new Chart(ctx, {
        type: "pie",
        data: {
            labels: ["Present", "Absent", "Half-Day"],
            datasets: [{
                data: [<%= daysPresent %>, <%= daysAbsent %>, <%= daysHalfDay %>],
                backgroundColor: ["#10b981", "#ef4444", "#f59e0b"],
                borderColor:     ["#fff",    "#fff",    "#fff"],
                borderWidth: 2,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: ctx => " " + ctx.label + ": " + ctx.parsed + " days"
                    }
                }
            }
        }
    });
})();

/* ── Animate legend bars ── */
setTimeout(() => {
    document.querySelectorAll(".cl-bar[data-w]").forEach(b => {
        b.style.width = b.dataset.w;
    });
}, 450);

/* ── Scroll helper ── */
function scrollToSec(id) {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

/* ── Navigate to parent dashboard section ── */
function navParent(section) {
    try {
        if (window.parent && window.parent.showSection) {
            window.parent.showSection(section);
        }
        if (window.parent && window.parent.document) {
            const btns = window.parent.document.querySelectorAll(".nav-btn");
            const map = { selfAttendance:0, tasks:1, leave:2, meetings:3, calendar:4 };
            const idx = map[section];
            if (idx !== undefined) {
                btns.forEach(b => b.classList.remove("active"));
                if (btns[idx]) btns[idx].classList.add("active");
            }
        }
    } catch(e) { console.warn("navParent:", e); }
}

/* ── Mark notification read ── */
function markRead(id) {
    fetch("<%=request.getContextPath()%>/markNotificationRead?id=" + id, { method: "POST" })
        .then(r => {
            if (r.ok) {
                const el = document.getElementById("notif-ov-" + id);
                if (el) {
                    el.style.transition = "opacity .3s, transform .3s";
                    el.style.opacity = "0";
                    el.style.transform = "translateX(20px)";
                    setTimeout(() => el.remove(), 300);
                }
            }
        })
        .catch(e => console.error(e));
}

/* ══════════════════════════════════════════════════
   BREAK TIME ENGINE  (identical logic to user.jsp)
══════════════════════════════════════════════════ */
const BREAK_LIMIT = 60 * 60; // 60 min in seconds

const bs = {
    isOnBreak: false,
    startTime: null,
    log: [],
    totalSecs: 0,
    interval: null
};

const $ = id => document.getElementById(id);

function padZ(n) { return String(n).padStart(2, "0"); }

function fmtHMS(s) {
    return padZ(Math.floor(s/3600)) + ":" + padZ(Math.floor((s%3600)/60)) + ":" + padZ(s%60);
}

function fmtShort(s) {
    return Math.floor(s/60) + "m " + (s%60) + "s";
}

function fmtClock(date) {
    return date.toLocaleTimeString("en-IN",
        { hour:"2-digit", minute:"2-digit", second:"2-digit", hour12:true });
}

function updateBreakStats() {
    const done = bs.log.filter(b => b.end !== null);
    const total = done.reduce((a, b) => a + b.durSec, 0);
    bs.totalSecs = total;
    const rem = Math.max(0, BREAK_LIMIT - total);
    const pct = Math.min(100, Math.round((total / BREAK_LIMIT) * 100));

    $("bCount").textContent     = done.length;
    $("bTotal").textContent     = fmtShort(total);
    $("bRemaining").textContent = fmtShort(rem);
    $("bBarFill").style.width   = pct + "%";
    $("bBarPct").textContent    = pct + "%";

    $("bBarFill").classList.remove("warn", "over");
    if      (pct >= 100) $("bBarFill").classList.add("over");
    else if (pct >= 75)  $("bBarFill").classList.add("warn");
}

function renderBreakLog() {
    const list = $("bLogList");
    Array.from(list.querySelectorAll(".bli")).forEach(el => el.remove());

    if (bs.log.length === 0) {
        $("bLogEmpty").style.display = "flex";
        return;
    }
    $("bLogEmpty").style.display = "none";

    bs.log.forEach((b, i) => {
        const ongoing = b.end === null;
        const div = document.createElement("div");
        div.className = "bli";
        div.id = "bli-" + i;
        div.innerHTML = `
            <div class="bli-idx">${i+1}</div>
            <div class="bli-times">
                <div class="bli-start"><i class="fa-solid fa-play" style="font-size:8px;margin-right:3px;color:#8b5cf6;"></i>${fmtClock(b.start)}</div>
                <div class="bli-end">${b.end
                    ? '<i class="fa-solid fa-stop" style="font-size:8px;margin-right:3px;color:#14b8a6;"></i>' + fmtClock(b.end)
                    : '<i class="fa-solid fa-ellipsis" style="font-size:8px;margin-right:3px;color:#a78bfa;"></i>In Progress…'
                }</div>
            </div>
            <span class="bli-dur ${ongoing ? 'ongoing' : ''}">${ongoing ? 'Live' : fmtShort(b.durSec)}</span>
        `;
        list.appendChild(div);
    });
    list.scrollTop = list.scrollHeight;
}

function startBreak() {
    if (bs.isOnBreak) return;
    if (bs.totalSecs >= BREAK_LIMIT) { alert("⚠️ Daily break limit reached (60 min)."); return; }

    bs.isOnBreak = true;
    bs.startTime = new Date();
    bs.log.push({ start: bs.startTime, end: null, durSec: 0 });

    $("btnBreakStart").disabled = true;
    $("btnBreakEnd").disabled   = false;

    $("bStatusBadge").className = "bsb bsb-active";
    $("bStatusBadge").innerHTML = '<i class="fa-solid fa-circle" style="font-size:7px;"></i> On Break';
    $("bTimerDisplay").classList.add("running");
    $("bTimerSub").textContent = "Started at " + fmtClock(bs.startTime);

    renderBreakLog();

    bs.interval = setInterval(() => {
        const elapsed = Math.floor((Date.now() - bs.startTime.getTime()) / 1000);
        $("bTimerDisplay").textContent = fmtHMS(elapsed);

        const last = bs.log[bs.log.length - 1];
        if (last && last.end === null) {
            last.durSec = elapsed;
            const el = document.getElementById("bli-" + (bs.log.length-1));
            if (el) {
                const d = el.querySelector(".bli-dur");
                if (d) d.textContent = fmtShort(elapsed);
            }
        }

        const used = bs.totalSecs + elapsed;
        const pct  = Math.min(100, Math.round((used / BREAK_LIMIT) * 100));
        $("bBarFill").style.width = pct + "%";
        $("bBarPct").textContent  = pct + "%";
        $("bBarFill").classList.remove("warn","over");
        if      (pct >= 100) $("bBarFill").classList.add("over");
        else if (pct >= 75)  $("bBarFill").classList.add("warn");

        if (used >= BREAK_LIMIT) endBreak(true);
    }, 1000);
}

function endBreak(auto) {
    if (!bs.isOnBreak) return;
    clearInterval(bs.interval);
    bs.isOnBreak = false;

    const now = new Date();
    const last = bs.log[bs.log.length - 1];
    if (last) { last.end = now; last.durSec = Math.floor((now - last.start) / 1000); }

    $("btnBreakStart").disabled = false;
    $("btnBreakEnd").disabled   = true;

    $("bStatusBadge").className = "bsb bsb-done";
    $("bStatusBadge").innerHTML = '<i class="fa-solid fa-circle-check" style="font-size:8px;"></i> Break Ended';
    $("bTimerDisplay").classList.remove("running");
    $("bTimerDisplay").textContent = fmtHMS(last ? last.durSec : 0);
    $("bTimerSub").textContent = auto ? "⚠️ Limit reached!" : "Ended at " + fmtClock(now);

    if (auto) alert("⏰ Your 60-min daily break limit has been reached. Break ended automatically.");

    updateBreakStats();
    renderBreakLog();

    setTimeout(() => {
        if (!bs.isOnBreak) {
            $("bTimerDisplay").textContent = "00:00:00";
            $("bTimerSub").textContent     = "Start a break when ready";
            $("bStatusBadge").className    = "bsb bsb-idle";
            $("bStatusBadge").innerHTML    = '<i class="fa-solid fa-circle" style="font-size:7px;"></i> Idle';
        }
    }, 4000);
}

/* Initial stats */
updateBreakStats();

</script>
</body>
</html>
