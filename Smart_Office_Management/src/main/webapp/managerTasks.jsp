<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.TreeSet"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.User"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}

String errorMessage = (String) request.getAttribute("errorMessage");
String qError = request.getParameter("error");
if (errorMessage == null && qError != null && !qError.isEmpty()) errorMessage = qError;

List<User> team     = (List<User>) request.getAttribute("teamList");
List<Task> allTasks = (List<Task>) request.getAttribute("allManagerTasks");
if (allTasks == null) allTasks = java.util.Collections.emptyList();

Calendar cal = Calendar.getInstance();
cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0);
cal.set(Calendar.SECOND, 0);      cal.set(Calendar.MILLISECOND, 0);
int dow = cal.get(Calendar.DAY_OF_WEEK);
int daysToMon = (dow == Calendar.SUNDAY) ? 6 : dow - Calendar.MONDAY;
cal.add(Calendar.DAY_OF_MONTH, -daysToMon);
Date weekStart = cal.getTime();

java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
String todayStr = sdf.format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks • Manager</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>
/* ══════════════════════════════════
   TOKENS
══════════════════════════════════ */
:root {
  --brand:       #4F6EF7;
  --brand-dark:  #3B57E3;
  --brand-light: #EEF2FF;
  --brand-glow:  rgba(79,110,247,.12);

  --green:       #10B981;
  --green-bg:    #D1FAE5;
  --amber:       #F59E0B;
  --amber-bg:    #FEF3C7;
  --red:         #EF4444;
  --red-bg:      #FEE2E2;
  --violet:      #8B5CF6;
  --violet-bg:   #EDE9FE;
  --sky:         #0EA5E9;
  --sky-bg:      #E0F2FE;

  --surface:     #FFFFFF;
  --surface-2:   #F8FAFC;
  --surface-3:   #F1F5F9;
  --border:      #E2E8F0;
  --border-mid:  #CBD5E1;
  --text-1:      #0F172A;
  --text-2:      #334155;
  --text-3:      #64748B;
  --text-4:      #94A3B8;
  --text-5:      #CBD5E1;

  --r-sm:  6px;
  --r-md:  10px;
  --r-lg:  14px;
  --r-xl:  18px;
  --r-2xl: 24px;

  --shadow-xs: 0 1px 2px rgba(0,0,0,.05);
  --shadow-sm: 0 2px 8px rgba(0,0,0,.06);
  --shadow-md: 0 4px 16px rgba(0,0,0,.08);
  --shadow-lg: 0 12px 40px rgba(0,0,0,.12);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 14px; }
body {
  font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
  background: var(--surface-2);
  color: var(--text-2);
  -webkit-font-smoothing: antialiased;
}
button { font-family: inherit; cursor: pointer; border: none; background: none; }

::-webkit-scrollbar { width: 4px; height: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border-mid); border-radius: 99px; }

/* ══════════════════════════════════
   PAGE
══════════════════════════════════ */
.page { max-width: 1100px; margin: 0 auto; padding: 28px 28px 60px; }

/* Header */
.page-header {
  display: flex; align-items: center; justify-content: space-between;
  gap: 16px; flex-wrap: wrap; margin-bottom: 24px;
}
.page-header-left { display: flex; align-items: center; gap: 14px; }
.page-icon {
  width: 44px; height: 44px; background: var(--brand);
  border-radius: var(--r-lg); display: flex; align-items: center; justify-content: center;
  color: white; font-size: 18px; box-shadow: 0 4px 16px rgba(79,110,247,.3); flex-shrink: 0;
}
.page-title { font-size: 1.4rem; font-weight: 800; color: var(--text-1); letter-spacing: -.02em; }
.page-subtitle { font-size: .78rem; color: var(--text-4); margin-top: 2px; }

/* Refresh btn */
.btn-refresh {
  display: inline-flex; align-items: center; gap: 6px;
  font-size: .75rem; font-weight: 600; color: var(--text-3);
  border: 1.5px solid var(--border); border-radius: 99px;
  padding: 7px 14px; background: var(--surface); transition: all .15s;
}
.btn-refresh:hover { border-color: var(--brand); color: var(--brand); }

/* ══════════════════════════════════
   SUMMARY STATS ROW
══════════════════════════════════ */
.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
  gap: 12px; margin-bottom: 24px;
}
.stat-card {
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--r-xl); padding: 16px 18px;
  display: flex; align-items: center; gap: 12px;
  box-shadow: var(--shadow-xs); transition: box-shadow .15s, transform .15s;
}
.stat-card:hover { box-shadow: var(--shadow-sm); transform: translateY(-1px); }
.stat-icon {
  width: 38px; height: 38px; border-radius: var(--r-md);
  display: flex; align-items: center; justify-content: center;
  font-size: 15px; flex-shrink: 0;
}
.stat-val { font-size: 1.35rem; font-weight: 800; color: var(--text-1); line-height: 1; }
.stat-lbl { font-size: .65rem; font-weight: 700; text-transform: uppercase; letter-spacing: .07em; color: var(--text-4); margin-top: 3px; }

/* ══════════════════════════════════
   TOOLBAR  (filters + date)
══════════════════════════════════ */
.toolbar {
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--r-xl); padding: 14px 18px;
  display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
  box-shadow: var(--shadow-xs); margin-bottom: 20px;
}
.toolbar-label {
  font-size: .65rem; font-weight: 800; text-transform: uppercase;
  letter-spacing: .08em; color: var(--text-4); white-space: nowrap;
  padding-right: 6px; border-right: 1.5px solid var(--border);
}
.ftab {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 6px 14px; border-radius: 99px; font-size: .75rem; font-weight: 600;
  border: 1.5px solid var(--border); background: var(--surface); color: var(--text-3);
  transition: all .13s; white-space: nowrap; cursor: pointer;
}
.ftab:hover { border-color: var(--brand); color: var(--brand); }
.ftab.active-all        { background: var(--brand);      color: white; border-color: var(--brand);      box-shadow: 0 2px 10px rgba(79,110,247,.3); }
.ftab.active-today      { background: var(--sky);        color: white; border-color: var(--sky);        box-shadow: 0 2px 10px rgba(14,165,233,.3); }
.ftab.active-week       { background: var(--green);      color: white; border-color: var(--green);      box-shadow: 0 2px 10px rgba(16,185,129,.3); }
.ftab.active-assigned   { background: var(--sky-bg);     color: #0369A1; border-color: #7DD3FC; }
.ftab.active-review     { background: var(--amber-bg);   color: #92400E; border-color: #FCD34D; }
.ftab.active-completed  { background: var(--green-bg);   color: #065F46; border-color: #6EE7B7; }
.cpill {
  background: rgba(0,0,0,.12); border-radius: 99px;
  padding: 0 6px; font-size: .65rem; font-weight: 800; line-height: 1.6;
}
.ftab.active-all .cpill, .ftab.active-today .cpill, .ftab.active-week .cpill { background: rgba(255,255,255,.25); }

/* date pill */
.date-pill {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 6px 14px; border-radius: 99px; font-size: .75rem; font-weight: 600;
  border: 1.5px solid var(--border); background: var(--surface); color: var(--text-3);
  transition: all .13s; cursor: pointer; white-space: nowrap;
}
.date-pill:hover { border-color: var(--brand); color: var(--brand); }
.date-pill.active { background: var(--violet-bg); color: #5B21B6; border-color: #DDD6FE; }

.btn-clear-date {
  display: none; align-items: center; gap: 5px;
  font-size: .72rem; font-weight: 600; color: var(--text-3);
  border: 1.5px solid var(--border); border-radius: 99px;
  padding: 6px 12px; background: var(--surface); transition: all .13s;
}
.btn-clear-date:hover { border-color: var(--red); color: var(--red); }
.btn-clear-date.visible { display: inline-flex; }

/* ══════════════════════════════════
   CALENDAR DROPDOWN
══════════════════════════════════ */
.cal-anchor { position: relative; display: inline-flex; align-items: center; }
#customCalendar {
  position: absolute; z-index: 9999; top: calc(100% + 8px); right: 0; /* ← was: left: 0 */
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--r-xl); box-shadow: var(--shadow-lg);
  padding: 14px 16px 12px; width: 268px; display: none;
}
#customCalendar.open { display: block; }
.cal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; }
.cal-header span { font-size: .82rem; font-weight: 700; color: var(--text-1); }
.cal-nav {
  background: none; border: none; cursor: pointer; color: var(--text-3);
  padding: 4px 8px; border-radius: var(--r-sm); font-size: .85rem; line-height: 1; transition: all .12s;
}
.cal-nav:hover { background: var(--surface-3); color: var(--brand); }
.cal-grid { display: grid; grid-template-columns: repeat(7,1fr); gap: 2px; }
.cal-dow { text-align: center; font-size: .62rem; font-weight: 700; color: var(--text-5); padding: 4px 0 6px; text-transform: uppercase; }
.cal-day {
  text-align: center; font-size: .75rem; padding: 6px 0; border-radius: var(--r-sm);
  cursor: pointer; color: var(--text-2); transition: all .1s; line-height: 1.2;
}
.cal-day:hover:not(.cal-empty):not(.cal-disabled) { background: var(--brand-light); color: var(--brand); }
.cal-day.cal-today { font-weight: 800; color: var(--brand); }
.cal-day.cal-selected { background: var(--brand) !important; color: white !important; font-weight: 700; }
.cal-day.cal-disabled { color: var(--text-5); cursor: default; }
.cal-day.cal-empty    { cursor: default; }
.cal-footer {
  display: flex; justify-content: space-between; margin-top: 10px;
  padding-top: 10px; border-top: 1px solid var(--surface-3);
}
.cal-footer button {
  font-size: .72rem; font-weight: 700; padding: 5px 14px; border-radius: var(--r-sm); border: none; cursor: pointer; transition: background .12s;
}
.cal-clear      { background: var(--surface-3); color: var(--text-3); }
.cal-clear:hover { background: var(--border); }
.cal-jump       { background: var(--brand-light); color: var(--brand); }
.cal-jump:hover { background: #E0E7FF; }

/* ══════════════════════════════════
   TASK FEED
══════════════════════════════════ */
.feed-header {
  display: flex; align-items: center; gap: 10px; margin-bottom: 16px; flex-wrap: wrap;
}
.feed-title { font-size: .9rem; font-weight: 800; color: var(--text-1); }
.review-badge {
  display: inline-flex; align-items: center; gap: 6px;
  font-size: .72rem; font-weight: 700; color: #92400E;
  background: var(--amber-bg); border: 1.5px solid #FCD34D;
  padding: 4px 12px; border-radius: 99px;
}

/* Task grid */
.task-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 14px;
}

/* Task Card */
.task-card {
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: var(--r-xl);
  padding: 18px 20px;
  display: flex; flex-direction: column; gap: 0;
  box-shadow: var(--shadow-xs);
  transition: box-shadow .18s, border-color .18s, transform .18s;
  position: relative; overflow: hidden;
  animation: cardIn .25s ease both;
}
.task-card:hover { box-shadow: var(--shadow-md); border-color: #C7D2FE; transform: translateY(-2px); }

/* left accent stripe */
.task-card::before {
  content: ''; position: absolute; top: 0; left: 0; bottom: 0; width: 3.5px;
  background: var(--border); border-radius: var(--r-xl) 0 0 var(--r-xl);
  transition: background .15s;
}
.task-card.stripe-review::before  { background: var(--amber); }
.task-card.stripe-completed::before { background: var(--green); }
.task-card.stripe-assigned::before  { background: var(--brand); }
.task-card.stripe-overdue::before   { background: var(--red); }

/* Card sections */
.card-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; margin-bottom: 10px; }
.card-title { font-size: .88rem; font-weight: 800; color: var(--text-1); line-height: 1.35; }
.card-assignee { font-size: .7rem; color: var(--text-4); font-family: 'JetBrains Mono', monospace; margin-top: 3px; }
.card-badges { display: flex; flex-wrap: wrap; gap: 5px; flex-shrink: 0; align-items: flex-start; }

.card-desc {
  font-size: .76rem; color: var(--text-3); line-height: 1.5;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
  margin-bottom: 12px;
}

.card-meta {
  display: flex; flex-wrap: wrap; align-items: center; gap: 10px;
  font-size: .72rem; color: var(--text-4); margin-bottom: 12px;
}
.meta-item { display: inline-flex; align-items: center; gap: 4px; }
.meta-item i { font-size: .65rem; }
.meta-item strong { color: var(--text-2); font-weight: 600; }
.prio-HIGH   { color: var(--red);   font-weight: 700; }
.prio-MEDIUM { color: var(--amber); font-weight: 700; }
.prio-LOW    { color: var(--green); font-weight: 700; }

/* Comment box */
.card-comment {
  background: #FFFBEB; border: 1.5px solid #FDE68A;
  border-radius: var(--r-md); padding: 9px 12px;
  font-size: .72rem; color: #92400E; margin-bottom: 10px; line-height: 1.5;
}
.card-comment strong { font-weight: 800; }

/* Attachment links */
.card-attachments { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 10px; }
.attach-link {
  display: inline-flex; align-items: center; gap: 5px;
  font-size: .7rem; font-weight: 600;
  padding: 4px 11px; border-radius: 99px; text-decoration: none;
  transition: all .12s;
}
.attach-emp  { background: var(--green-bg); color: #065F46; border: 1.5px solid #6EE7B7; }
.attach-emp:hover  { background: #A7F3D0; }
.attach-mgr  { background: var(--brand-light); color: var(--brand-dark); border: 1.5px solid #C7D2FE; }
.attach-mgr:hover  { background: #E0E7FF; }

/* Card action row */
.card-action {
  display: flex; align-items: center; gap: 8px;
  padding-top: 12px; border-top: 1.5px solid var(--surface-3);
  margin-top: auto;
}
.action-select {
  flex: 1; font-size: .75rem; font-family: 'Plus Jakarta Sans', sans-serif;
  padding: 7px 10px; border: 1.5px solid var(--border); border-radius: var(--r-md);
  background: var(--surface-2); color: var(--text-2); outline: none; transition: all .13s;
}
.action-select:focus { border-color: var(--brand); background: white; box-shadow: 0 0 0 3px var(--brand-glow); }
.btn-apply {
  padding: 7px 16px; background: var(--brand); color: white;
  font-size: .75rem; font-weight: 700; border-radius: var(--r-md);
  box-shadow: 0 2px 8px rgba(79,110,247,.25);
  transition: all .13s; white-space: nowrap;
}
.btn-apply:hover { background: var(--brand-dark); transform: translateY(-1px); box-shadow: 0 4px 14px rgba(79,110,247,.35); }

/* Badges */
.badge {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 3px 9px; border-radius: 99px; font-size: .68rem; font-weight: 700; white-space: nowrap;
}
.b-assigned   { background: var(--sky-bg);   color: #0369A1;  border: 1.5px solid #7DD3FC; }
.b-review     { background: var(--amber-bg); color: #92400E;  border: 1.5px solid #FCD34D; }
.b-completed  { background: var(--green-bg); color: #065F46;  border: 1.5px solid #6EE7B7; }
.b-docverify  { background: var(--violet-bg);color: #5B21B6;  border: 1.5px solid #DDD6FE; }
.b-today      { background: var(--sky-bg);   color: #0369A1;  border: 1.5px solid #7DD3FC; }
.b-week       { background: var(--green-bg); color: #065F46;  border: 1.5px solid #6EE7B7; }

/* Pulse dot */
.pulse-dot {
  display: inline-block; width: 7px; height: 7px; border-radius: 50%;
  background: var(--amber); flex-shrink: 0;
  box-shadow: 0 0 0 0 rgba(245,158,11,.5);
  animation: pulse 1.4s ease-out infinite;
}
@keyframes pulse {
  0%   { box-shadow: 0 0 0 0 rgba(245,158,11,.5); }
  70%  { box-shadow: 0 0 0 7px rgba(245,158,11,0); }
  100% { box-shadow: 0 0 0 0 rgba(245,158,11,0); }
}
@keyframes cardIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

/* Empty state */
.empty-state {
  grid-column: 1 / -1;
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--r-xl); padding: 56px 24px; text-align: center;
}
.empty-state i { font-size: 36px; color: var(--text-5); display: block; margin-bottom: 10px; }
.empty-state p { font-size: .82rem; color: var(--text-4); }
</style>
</head>
<body>

<div id="toast" aria-live="polite"></div>

<div class="page">

  <!-- ── Page Header ── -->
  <div class="page-header">
    <div class="page-header-left">
      <div class="page-icon"><i class="fa-solid fa-list-check"></i></div>
      <div>
        <div class="page-title">Team Task Feed</div>
        <div class="page-subtitle">Monitor and manage all tasks assigned to your team</div>
      </div>
    </div>
    <button class="btn-refresh" onclick="location.reload()">
      <i class="fa-solid fa-rotate-right" style="font-size:.7rem;"></i> Refresh
    </button>
  </div>

  <!-- ── Summary Stats ── -->
  <%
  long cAll       = allTasks.size();
  long cAssigned  = allTasks.stream().filter(t -> { String s=t.getStatus()!=null?t.getStatus().trim().toUpperCase():""; return !s.equals("COMPLETED")&&!s.equals("PROCESSING")&&!s.equals("SUBMITTED"); }).count();
  long cReview    = allTasks.stream().filter(t -> { String s=t.getStatus()!=null?t.getStatus().trim().toUpperCase():""; return s.equals("PROCESSING")||s.equals("SUBMITTED"); }).count();
  long cCompleted = allTasks.stream().filter(t -> { String s=t.getStatus()!=null?t.getStatus().trim().toUpperCase():""; return s.equals("COMPLETED"); }).count();
  long cToday     = 0;
  for (Task t : allTasks) { if (t.getAssignedDate()!=null && sdf.format(t.getAssignedDate()).equals(todayStr)) cToday++; }
  %>
  <div class="stats-row">
    <div class="stat-card">
      <div class="stat-icon" style="background:var(--brand-light);color:var(--brand);"><i class="fa-solid fa-border-all"></i></div>
      <div><div class="stat-val"><%=cAll%></div><div class="stat-lbl">Total</div></div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:var(--sky-bg);color:var(--sky);"><i class="fa-solid fa-sun"></i></div>
      <div><div class="stat-val" style="color:var(--sky);"><%=cToday%></div><div class="stat-lbl">Today</div></div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:var(--sky-bg);color:#0369A1;"><i class="fa-solid fa-clock"></i></div>
      <div><div class="stat-val" style="color:#0369A1;"><%=cAssigned%></div><div class="stat-lbl">Assigned</div></div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:var(--amber-bg);color:var(--amber);"><i class="fa-solid fa-hourglass-half"></i></div>
      <div><div class="stat-val" style="color:var(--amber);"><%=cReview%></div><div class="stat-lbl">Review</div></div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:var(--green-bg);color:var(--green);"><i class="fa-solid fa-circle-check"></i></div>
      <div><div class="stat-val" style="color:var(--green);"><%=cCompleted%></div><div class="stat-lbl">Completed</div></div>
    </div>
  </div>

  <!-- ── Toolbar ── -->
  <div class="toolbar">
    <span class="toolbar-label">Filter</span>

    <button class="ftab" id="tabAll"       onclick="filterFeed('all',this)">
      <i class="fa-solid fa-border-all" style="font-size:.65rem;"></i> All
      <span class="cpill" id="fc-all">0</span>
    </button>
    <button class="ftab" id="tabToday"     onclick="filterFeed('TODAY',this)">
      <i class="fa-solid fa-sun" style="font-size:.65rem;"></i> Today
      <span class="cpill" id="fc-today">0</span>
    </button>
    <button class="ftab" id="tabWeek"      onclick="filterFeed('WEEK',this)">
      <i class="fa-solid fa-calendar-week" style="font-size:.65rem;"></i> This Week
      <span class="cpill" id="fc-week">0</span>
    </button>
    <button class="ftab"                   onclick="filterFeed('ASSIGNED',this)">
      <i class="fa-solid fa-clock" style="font-size:.65rem;"></i> Assigned
      <span class="cpill" id="fc-assigned">0</span>
    </button>
    <button class="ftab"                   onclick="filterFeed('REVIEW',this)">
      <span class="pulse-dot"></span> Needs Review
      <span class="cpill" id="fc-review">0</span>
    </button>
    <button class="ftab"                   onclick="filterFeed('COMPLETED',this)">
      <i class="fa-solid fa-circle-check" style="font-size:.65rem;"></i> Completed
      <span class="cpill" id="fc-completed">0</span>
    </button>

    <div class="cal-anchor" id="calWrapper" style="margin-left:auto;">
      <button class="date-pill" id="datePillBtn" onclick="toggleCalendar(event)">
        <i class="fa-solid fa-calendar-days" style="font-size:.65rem;"></i>
        <span id="datePillLabel">Pick a Date</span>
      </button>
      <div id="customCalendar">
        <div class="cal-header">
          <button class="cal-nav" onclick="calNav(-1)" type="button">&#8249;</button>
          <span id="calMonthYear"></span>
          <button class="cal-nav" onclick="calNav(1)"  type="button">&#8250;</button>
        </div>
        <div class="cal-grid" id="calGrid"></div>
        <div class="cal-footer">
          <button class="cal-clear" onclick="clearDateFilter()" type="button">Clear</button>
          <button class="cal-jump"  onclick="calJumpToday()"    type="button">Today</button>
        </div>
      </div>
    </div>

    <button id="clearDateBtn" class="btn-clear-date" onclick="clearDateFilter()" type="button">
      <i class="fa-solid fa-xmark" style="font-size:.65rem;"></i> Clear date
    </button>
  </div>

  <!-- ── Feed Header ── -->
  <div class="feed-header">
    <span class="feed-title">Tasks</span>
    <%if (cReview > 0) {%>
    <span class="review-badge"><span class="pulse-dot"></span> <%=cReview%> awaiting review</span>
    <%}%>
    <span id="visibleCount" style="font-size:.72rem;color:var(--text-4);margin-left:auto;"></span>
  </div>

  <!-- ── Task Grid ── -->
  <div class="task-grid" id="taskFeed">

    <%if (allTasks.isEmpty()) {%>
    <div class="empty-state">
      <i class="fa-solid fa-inbox"></i>
      <p>No tasks assigned yet.</p>
    </div>
    <%} else {
      for (Task t : allTasks) {
        String rawStatus     = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "ASSIGNED";
        boolean isProcessing = rawStatus.equals("PROCESSING") || rawStatus.equals("SUBMITTED");
        boolean isCompleted  = rawStatus.equals("COMPLETED");
        boolean needsReview  = isProcessing;
        boolean isThisWeek   = t.getAssignedDate() != null && !t.getAssignedDate().before(weekStart);

        String assignedDateStr = "";
        boolean isToday = false;
        if (t.getAssignedDate() != null) {
            assignedDateStr = sdf.format(t.getAssignedDate());
            isToday = assignedDateStr.equals(todayStr);
        }

        String badgeCls, badgeLabel, filterKey, stripeCls;
        switch (rawStatus) {
          case "COMPLETED":
            badgeCls="b-completed"; badgeLabel="Completed"; filterKey="COMPLETED"; stripeCls="stripe-completed"; break;
          case "PROCESSING": case "SUBMITTED":
            badgeCls="b-review"; badgeLabel="Awaiting Review"; filterKey="REVIEW"; stripeCls="stripe-review"; break;
          case "DOCUMENT_VERIFICATION":
            badgeCls="b-docverify"; badgeLabel="Doc Verification"; filterKey="ASSIGNED"; stripeCls="stripe-assigned"; break;
          default:
            badgeCls="b-assigned"; badgeLabel="Assigned"; filterKey="ASSIGNED"; stripeCls="stripe-assigned"; break;
        }

        String prioCls   = "prio-" + (t.getPriority() != null ? t.getPriority().trim().toUpperCase() : "MEDIUM");
        String prioLabel = t.getPriority() != null ? t.getPriority() : "MEDIUM";
        String prioIcon  = "MEDIUM".equals(prioLabel.toUpperCase()) ? "fa-flag" : "HIGH".equals(prioLabel.toUpperCase()) ? "fa-flag" : "fa-flag";
        String deadlineStr = t.getDeadline()  != null ? t.getDeadline().toString() : "—";
        String assignedTo  = t.getAssignedTo()!= null ? t.getAssignedTo()         : "";
        String title       = t.getTitle()     != null ? t.getTitle()              : "Untitled";
        String desc        = t.getDescription()!= null? t.getDescription()        : "";
    %>
    <div class="task-card <%=stripeCls%>"
         data-filter="<%=filterKey%>"
         data-week="<%=isThisWeek?"1":"0"%>"
         data-today="<%=isToday?"1":"0"%>"
         data-assigned-date="<%=assignedDateStr%>">

      <!-- Top row: title + badges -->
      <div class="card-top">
        <div style="flex:1;min-width:0;">
          <div style="display:flex;align-items:center;gap:7px;">
            <%if (needsReview) {%><span class="pulse-dot" style="margin-top:2px;flex-shrink:0;"></span><%}%>
            <div class="card-title"><%=title%></div>
          </div>
          <div class="card-assignee"><%=assignedTo%></div>
        </div>
        <div class="card-badges">
          <%if (isToday) {%><span class="badge b-today"><i class="fa-solid fa-sun" style="font-size:.6rem;"></i> Today</span><%}
          else if (isThisWeek) {%><span class="badge b-week"><i class="fa-solid fa-calendar-week" style="font-size:.6rem;"></i> This Week</span><%}%>
          <span class="badge <%=badgeCls%>"><%=badgeLabel%></span>
        </div>
      </div>

      <%if (!desc.isEmpty()) {%>
      <p class="card-desc"><%=desc%></p>
      <%}%>

      <!-- Meta row -->
      <div class="card-meta">
        <span class="meta-item"><i class="fa-regular fa-calendar"></i> Due: <strong><%=deadlineStr%></strong></span>
        <span class="meta-item <%=prioCls%>"><i class="fa-solid fa-flag"></i> <%=prioLabel%></span>
        <%if (t.getAssignedDate() != null) {%>
        <span class="meta-item"><i class="fa-regular fa-clock"></i> Assigned: <strong><%=t.getAssignedDate().toLocalDateTime().toLocalDate()%></strong></span>
        <%}%>
        <%if (t.getSubmittedAt() != null) {%>
        <span class="meta-item" style="color:var(--amber);"><i class="fa-regular fa-clock"></i> Submitted: <strong><%=t.getSubmittedAt().toLocalDateTime().toLocalDate()%></strong></span>
        <%}%>
      </div>

      <%if (t.getEmployeeComment() != null && !t.getEmployeeComment().isEmpty()) {%>
      <div class="card-comment">
        <strong><i class="fa-solid fa-message" style="margin-right:4px;"></i>Employee note:</strong> <%=t.getEmployeeComment()%>
      </div>
      <%}%>

      <%boolean hasAttach = (t.getEmployeeAttachmentName()!=null&&!t.getEmployeeAttachmentName().isEmpty()) || (t.getAttachmentName()!=null&&!t.getAttachmentName().isEmpty());
      if (hasAttach) {%>
      <div class="card-attachments">
        <%if (t.getEmployeeAttachmentName() != null && !t.getEmployeeAttachmentName().isEmpty()) {%>
        <a href="<%=request.getContextPath()%>/employeeTaskAttachment?id=<%=t.getId()%>" target="_blank" class="attach-link attach-emp">
          <i class="fa-solid fa-file-arrow-up"></i> <%=t.getEmployeeAttachmentName()%>
        </a>
        <%}%>
        <%if (t.getAttachmentName() != null && !t.getAttachmentName().isEmpty()) {%>
        <a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>" target="_blank" class="attach-link attach-mgr">
          <i class="fa-solid fa-paperclip"></i> <%=t.getAttachmentName()%>
        </a>
        <%}%>
      </div>
      <%}%>

      <%if (!isCompleted) {%>
      <form action="<%=request.getContextPath()%>/managerTasks" method="post" class="card-action">
        <input type="hidden" name="action" value="updateStatus">
        <input type="hidden" name="taskId" value="<%=t.getId()%>">
        <select name="decision" required class="action-select">
          <option value="">Select action…</option>
          <%if (needsReview) {%><option value="review">↩ Return to Employee</option><%}%>
          <option value="completed">✓ Mark as Completed</option>
        </select>
        <button type="submit" class="btn-apply">Apply</button>
      </form>
      <%}%>
    </div>
    <%}}%>
  </div>

</div>

<script>
var TODAY_STR = '<%=todayStr%>';
var calViewYear, calViewMonth, calSelectedDate = null;

(function() {
  var d = new Date();
  calViewYear  = d.getFullYear();
  calViewMonth = d.getMonth();
})();

// ── Calendar ──────────────────────────────
function toggleCalendar(e) {
  e.stopPropagation();
  var cal = document.getElementById('customCalendar');
  if (!cal.classList.contains('open')) { renderCalendar(); cal.classList.add('open'); }
  else cal.classList.remove('open');
}
function closeCalendar() { document.getElementById('customCalendar').classList.remove('open'); }
function calNav(dir) {
  calViewMonth += dir;
  if (calViewMonth < 0)  { calViewMonth=11; calViewYear--; }
  if (calViewMonth > 11) { calViewMonth=0;  calViewYear++; }
  renderCalendar();
}
function calJumpToday() {
  var d=new Date(); calViewYear=d.getFullYear(); calViewMonth=d.getMonth();
  renderCalendar();
}
function renderCalendar() {
  var months=['January','February','March','April','May','June','July','August','September','October','November','December'];
  document.getElementById('calMonthYear').textContent = months[calViewMonth] + ' ' + calViewYear;
  var grid = document.getElementById('calGrid');
  grid.innerHTML = '';
  ['Mo','Tu','We','Th','Fr','Sa','Su'].forEach(function(d) {
    var el=document.createElement('div'); el.className='cal-dow'; el.textContent=d; grid.appendChild(el);
  });
  var firstDay = new Date(calViewYear, calViewMonth, 1).getDay();
  var offset   = (firstDay===0)?6:firstDay-1;
  var daysInMonth = new Date(calViewYear, calViewMonth+1, 0).getDate();
  var tp=TODAY_STR.split('-'), ty=parseInt(tp[0]), tm=parseInt(tp[1])-1, td=parseInt(tp[2]);
  for (var i=0;i<offset;i++) { var e=document.createElement('div'); e.className='cal-day cal-empty'; grid.appendChild(e); }
  for (var day=1;day<=daysInMonth;day++) {
    var el=document.createElement('div'); el.className='cal-day'; el.textContent=day;
    var isToday=(calViewYear===ty&&calViewMonth===tm&&day===td);
    var isFuture=new Date(calViewYear,calViewMonth,day)>new Date(ty,tm,td);
    var dateVal=calViewYear+'-'+String(calViewMonth+1).padStart(2,'0')+'-'+String(day).padStart(2,'0');
    if (isFuture) el.classList.add('cal-disabled');
    if (isToday)  el.classList.add('cal-today');
    if (calSelectedDate===dateVal) el.classList.add('cal-selected');
    if (!isFuture) {
      (function(dv){ el.addEventListener('click',function(){ calSelectedDate=dv; closeCalendar(); onDateSelected(dv); }); })(dateVal);
    }
    grid.appendChild(el);
  }
}
function onDateSelected(dateVal) {
  var parts=dateVal.split('-'), months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var label=months[parseInt(parts[1])-1]+' '+parseInt(parts[2])+', '+parts[0];
  if (dateVal===TODAY_STR) label='Today ('+label+')';
  document.getElementById('datePillLabel').textContent=label;
  document.getElementById('datePillBtn').classList.add('active');
  document.getElementById('clearDateBtn').classList.add('visible');
  document.querySelectorAll('.ftab').forEach(function(t){t.className='ftab';});
  applyFilter('DATE',dateVal);
}

// ── Tab style map ─────────────────────────
var TAB_MAP = { all:'active-all', TODAY:'active-today', WEEK:'active-week', ASSIGNED:'active-assigned', REVIEW:'active-review', COMPLETED:'active-completed' };

function filterFeed(key, btn) {
  calSelectedDate=null;
  document.getElementById('datePillLabel').textContent='Pick a Date';
  document.getElementById('datePillBtn').classList.remove('active');
  document.getElementById('clearDateBtn').classList.remove('visible');
  closeCalendar();
  document.querySelectorAll('.ftab').forEach(function(t){t.className='ftab';});
  if (btn) btn.classList.add(TAB_MAP[key]||'active-all');
  applyFilter(key,null);
}

function clearDateFilter() {
  calSelectedDate=null;
  document.getElementById('datePillLabel').textContent='Pick a Date';
  document.getElementById('datePillBtn').classList.remove('active');
  document.getElementById('clearDateBtn').classList.remove('visible');
  closeCalendar();
  document.querySelectorAll('.ftab').forEach(function(t){t.className='ftab';});
  document.getElementById('tabToday').classList.add('active-today');
  applyFilter('TODAY',null);
}

function applyFilter(key, dateVal) {
  var cards=document.querySelectorAll('.task-card'), visible=0;
  cards.forEach(function(c){
    var show;
    switch(key){
      case 'all':    show=true; break;
      case 'TODAY':  show=c.dataset.today==='1'; break;
      case 'WEEK':   show=c.dataset.week==='1'; break;
      case 'DATE':   show=c.dataset.assignedDate===dateVal; break;
      default:       show=c.dataset.filter===key; break;
    }
    c.style.display=show?'':'none';
    if(show) visible++;
  });
  var feed=document.getElementById('taskFeed');
  var empty=document.getElementById('feedEmpty');
  if(visible===0&&!empty){
    var el=document.createElement('div'); el.id='feedEmpty'; el.className='empty-state';
    el.style.gridColumn='1/-1';
    var msg=key==='TODAY'?'No tasks assigned today.':key==='DATE'?'No tasks on this date.':'No tasks match this filter.';
    el.innerHTML='<i class="fa-solid fa-filter-circle-xmark"></i><p>'+msg+'</p>';
    feed.appendChild(el);
  } else if(visible>0&&empty) empty.remove();
  var vc=document.getElementById('visibleCount');
  if(vc) vc.textContent=visible+' task'+(visible!==1?'s':'');
}

// ── Init ─────────────────────────────────
(function initCounts(){
  var counts={all:0,TODAY:0,WEEK:0,ASSIGNED:0,REVIEW:0,COMPLETED:0};
  document.querySelectorAll('.task-card').forEach(function(c){
    counts.all++;
    if(c.dataset.today==='1') counts.TODAY++;
    if(c.dataset.week==='1')  counts.WEEK++;
    var k=c.dataset.filter;
    if(counts[k]!=null) counts[k]++;
  });
  document.getElementById('fc-all').textContent       = counts.all;
  document.getElementById('fc-today').textContent     = counts.TODAY;
  document.getElementById('fc-week').textContent      = counts.WEEK;
  document.getElementById('fc-assigned').textContent  = counts.ASSIGNED;
  document.getElementById('fc-review').textContent    = counts.REVIEW;
  document.getElementById('fc-completed').textContent = counts.COMPLETED;
  document.getElementById('tabToday').classList.add('active-today');
  applyFilter('TODAY',null);
})();

// close calendar on outside click
document.addEventListener('click',function(e){
  var w=document.getElementById('calWrapper');
  if(w&&!w.contains(e.target)) closeCalendar();
});

// toast flash messages
(function(){
  var p=new URLSearchParams(window.location.search);
  var flash=p.get('taskFlash');
  if(flash==='review')              showToast('Task returned — employee can resubmit.','success');
  else if(flash==='completed')      showToast('Task marked as completed!','success');
  else if(flash==='alreadyCompleted') showToast('Task was already completed.','success');
  var s=p.get('success'); if(s) showToast(decodeURIComponent(s.replace(/\+/g,' ')),'success');
  var err=p.get('error'); if(err) showToast(decodeURIComponent(err.replace(/\+/g,' ')),'error');
  if(flash||s||err){
    p.delete('taskFlash'); p.delete('success'); p.delete('error');
    var q=p.toString();
    window.history.replaceState({},'',window.location.pathname+(q?'?'+q:''));
  }
})();
</script>
</body>
</html>
