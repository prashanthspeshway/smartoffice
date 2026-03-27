<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Performance"%>
<%
List<Task>        tasks = (List<Task>)        request.getAttribute("tasks");
List<Team>        teams = (List<Team>)        request.getAttribute("teams");
List<Performance> perfs = (List<Performance>) request.getAttribute("perfs");
if (tasks == null) tasks = java.util.Collections.emptyList();
if (teams == null) teams = java.util.Collections.emptyList();
if (perfs == null) perfs = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">

<style>
  * { box-sizing: border-box; }
  body { font-family: 'DM Sans', system-ui, sans-serif; background: #f1f5f9; min-height: 100vh; }

  /* ── Breadcrumb ── */
  .crumb-sep { color: #cbd5e1; font-size: 18px; line-height: 1; }

  /* ── Team cards ── */
  .team-card {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 18px 20px; cursor: pointer; transition: all .18s ease;
    display: flex; flex-direction: column; gap: 6px;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .team-card:hover  { border-color: #6366f1; box-shadow: 0 4px 14px rgba(99,102,241,.15); transform: translateY(-1px); }
  .team-card.selected { border-color: #6366f1; background: #fafafe; box-shadow: 0 4px 18px rgba(99,102,241,.18); }
  .team-icon { width: 38px; height: 38px; border-radius: 10px; background: #eef2ff; display: flex; align-items: center; justify-content: center; color: #6366f1; font-size: 16px; }

  /* ── Tab bar ── */
  .tab-bar {
    display: flex; gap: 0; border-bottom: 2px solid #e2e8f0;
    margin-bottom: 24px; background: white;
    border-radius: 14px 14px 0 0; overflow: hidden;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .tab-btn {
    flex: 1; padding: 14px 20px; font-size: 13.5px; font-weight: 500;
    cursor: pointer; border: none; background: transparent; color: #94a3b8;
    display: flex; align-items: center; justify-content: center; gap: 8px;
    border-bottom: 2.5px solid transparent; margin-bottom: -2px;
    transition: all .18s ease; position: relative;
  }
  .tab-btn:hover { color: #6366f1; background: #f8f7ff; }
  .tab-btn.active { color: #6366f1; border-bottom-color: #6366f1; background: #fafafe; font-weight: 600; }
  .tab-btn .tab-num {
    background: #eef2ff; color: #6366f1; border-radius: 9999px;
    padding: 1px 8px; font-size: 11px; font-weight: 700;
  }
  .tab-btn.active .tab-num { background: #6366f1; color: white; }
  .tab-btn .step-circle {
    width: 22px; height: 22px; border-radius: 50%;
    background: #e2e8f0; color: #94a3b8;
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 700; flex-shrink: 0;
    transition: all .18s;
  }
  .tab-btn.active .step-circle { background: #6366f1; color: white; }
  .tab-btn.done   .step-circle { background: #22c55e; color: white; }
  .tab-btn.done   { color: #16a34a; }
  .tab-btn.locked { opacity: .45; cursor: not-allowed; pointer-events: none; }

  /* ── Member chips ── */
  .member-chip {
    display: flex; align-items: center; gap: 10px;
    background: white; border: 1.5px solid #e2e8f0; border-radius: 50px;
    padding: 8px 16px 8px 8px; cursor: pointer; transition: all .15s ease;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .member-chip:hover   { border-color: #6366f1; background: #f5f3ff; }
  .member-chip.selected { border-color: #6366f1; background: #eef2ff; color: #4338ca; }
  .avatar {
    width: 32px; height: 32px; border-radius: 50%;
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    display: flex; align-items: center; justify-content: center;
    color: white; font-size: 12px; font-weight: 600; flex-shrink: 0;
  }

  /* ── Status badges ── */
  .badge-status { padding: 3px 10px; border-radius: 9999px; font-size: 11px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
  .bs-completed  { background: #dcfce7; color: #166534; }
  .bs-incomplete { background: #fef3c7; color: #92400e; }
  .bs-docverify  { background: #ede9fe; color: #6d28d9; }
  .bs-error      { background: #fee2e2; color: #b91c1c; }
  .bs-assigned   { background: #e0f2fe; color: #0369a1; }

  /* ── Filter tabs ── */
  .filter-tab {
    padding: 5px 14px; border-radius: 9999px; font-size: 12.5px; font-weight: 500;
    cursor: pointer; border: 1.5px solid #e2e8f0; transition: all .15s ease;
    display: inline-flex; align-items: center; gap: 5px;
    background: white; color: #64748b;
  }
  .filter-tab:hover             { border-color: #6366f1; color: #6366f1; }
  .filter-tab.ft-all            { background: #6366f1; color: white; border-color: #6366f1; }
  .filter-tab.ft-completed      { background: #dcfce7; color: #166534; border-color: #86efac; }
  .filter-tab.ft-incomplete     { background: #fef3c7; color: #92400e; border-color: #fcd34d; }
  .filter-tab.ft-docverify      { background: #ede9fe; color: #6d28d9; border-color: #c4b5fd; }
  .filter-tab.ft-error          { background: #fee2e2; color: #b91c1c; border-color: #fca5a5; }
  .cpill { background: rgba(0,0,0,.1); border-radius: 9999px; padding: 0 7px; font-size: 11px; font-weight: 600; }

  /* ── Panels ── */
  .panel { animation: fadeSlide .22s ease; }
  @keyframes fadeSlide { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

  /* ── Priority dot ── */
  .prio-high   { color: #ef4444; }
  .prio-medium { color: #f59e0b; }
  .prio-low    { color: #22c55e; }

  /* ── Section header ── */
  .section-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .07em; color: #94a3b8; margin-bottom: 10px; }

  /* ── Empty state ── */
  .empty-state {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 56px 24px; display: flex; flex-direction: column;
    align-items: center; justify-content: center; gap: 10px;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .empty-icon { font-size: 44px; color: #cbd5e1; margin-bottom: 4px; }
  .empty-title { font-size: 15px; font-weight: 600; color: #94a3b8; }
  .empty-sub   { font-size: 13px; color: #b0bec5; }

  /* ── Performance cards (task perf section) ── */
  .perf-stat {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 18px 20px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .perf-bar-track {
    background: #f1f5f9; border-radius: 9999px; height: 8px; overflow: hidden; margin-top: 8px;
  }
  .perf-bar-fill { height: 100%; border-radius: 9999px; transition: width .6s cubic-bezier(.4,0,.2,1); }

  /* ── Tab content wrapper ── */
  .tab-content { display: none; }
  .tab-content.active { display: block; }

  /* ── Team context banner ── */
  .team-banner {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 12px 18px; display: flex; align-items: center; gap: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 16px;
  }

  /* ── Utility: hidden ── */
  .hidden { display: none !important; }

  /* ════════════════════════════════════════
     PERFORMANCE TAB — Monthly Reviews
  ════════════════════════════════════════ */

  /* Summary stat row */
  .pm-summary-grid {
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 16px;
  }
  .pm-s-card {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 12px;
    padding: 14px 16px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .pm-s-val { font-size: 22px; font-weight: 700; color: #1e293b; line-height: 1.2; min-height: 32px; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
  .pm-s-lbl { font-size: 11px; color: #94a3b8; margin-top: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: .05em; }

  /* Charts row */
  .pm-charts-row {
    display: grid; grid-template-columns: 1fr 190px; gap: 16px; align-items: start; margin-bottom: 16px;
  }
  @media (max-width: 600px) { .pm-charts-row { grid-template-columns: 1fr; } .pm-summary-grid { grid-template-columns: 1fr 1fr; } }

  .pm-chart-card {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 16px 18px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .pm-donut-card {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
    display: flex; flex-direction: column; align-items: center;
  }

  /* Month history list */
  .pm-history-card {
    background: white; border: 1.5px solid #e2e8f0; border-radius: 14px;
    padding: 16px 18px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .pm-month-row {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 14px; border-radius: 10px; margin-bottom: 6px;
    background: #f8fafc; border: 1px solid #e2e8f0; transition: background .15s;
  }
  .pm-month-row:last-child { margin-bottom: 0; }
  .pm-month-row:hover { background: #f0f4ff; border-color: #a5b4fc; }
  .pm-month-lbl  { font-size: 13px; color: #475569; font-weight: 500; min-width: 110px; }
  .pm-bar-wrap   { flex: 1; }
  .pm-bar-track  { background: #f1f5f9; border-radius: 9999px; height: 7px; overflow: hidden; }
  .pm-bar-fill   { height: 100%; border-radius: 9999px; transition: width .5s ease; }
  .pm-badge      { font-size: 11px; font-weight: 700; padding: 2px 10px; border-radius: 9999px; white-space: nowrap; }
  .pm-mgr-chip   { font-size: 11px; color: #94a3b8; display: flex; align-items: center; gap: 4px; min-width: 90px; justify-content: flex-end; white-space: nowrap; }

  /* Ring legend */
  .pm-ring-legend { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; margin-top: 8px; }
  .pm-ring-item   { display: flex; align-items: center; gap: 4px; font-size: 10.5px; color: #64748b; }
  .pm-ring-dot    { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }

  /* Trend arrows */
  .pm-trend-up   { color: #16a34a; font-weight: 700; }
  .pm-trend-down { color: #dc2626; font-weight: 700; }
  .pm-trend-flat { color: #f59e0b; font-weight: 700; }

  /* No-perf empty */
  .pm-empty {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 8px; padding: 52px 24px;
    background: white; border: 1.5px dashed #e2e8f0; border-radius: 14px;
  }
  .pm-empty-icon { font-size: 40px; color: #cbd5e1; }
  .pm-empty-title { font-size: 15px; font-weight: 600; color: #94a3b8; }
  .pm-empty-sub   { font-size: 13px; color: #b0bec5; text-align: center; }
</style>
</head>
<body class="p-6">

<!-- ════════ JSON DATA ISLANDS ════════ -->
<script id="teams-data" type="application/json">
[
<%
boolean firstTeam = true;
for (Team team : teams) {
  if (!firstTeam) out.print(",");
  firstTeam = false;
%>
{
  "id": <%=team.getId()%>,
  "name": "<%=escapeJson(team.getName())%>",
  "manager": "<%=escapeJson(team.getManagerFullname() != null ? team.getManagerFullname() : team.getManagerUsername())%>",
  "members": [
    <%
    boolean firstMember = true;
    for (User m : team.getMembers()) {
      if (!firstMember) out.print(",");
      firstMember = false;
      String fn = (m.getFirstname() != null ? m.getFirstname() : "") + " " + (m.getLastname() != null ? m.getLastname() : "");
      fn = fn.trim();
      if (fn.isEmpty()) fn = m.getEmail();
    %>
    {"email":"<%=escapeJson(m.getEmail())%>","name":"<%=escapeJson(fn)%>","role":"<%=escapeJson(m.getRole() != null ? m.getRole() : "")%>","username":"<%=escapeJson(m.getUsername() != null ? m.getUsername() : "")%>"}
    <%
    }
    %>
  ]
}
<%
}
%>
]
</script>

<script id="tasks-data" type="application/json">
[
<%
boolean firstTask = true;
for (Task t : tasks) {
  if (!firstTask) out.print(",");
  firstTask = false;

  String title      = t.getTitle()      != null ? t.getTitle()      : "";
  String status     = t.getStatus()     != null ? t.getStatus()     : "INCOMPLETE";
  String assignedTo = t.getAssignedTo() != null ? t.getAssignedTo() : "";
  String assignedBy = t.getAssignedBy() != null ? t.getAssignedBy() : "";
  String priority   = t.getPriority()   != null ? t.getPriority()   : "";
  String attName    = t.getAttachmentName() != null ? t.getAttachmentName() : "";

  java.sql.Timestamp ts = t.getAssignedDate();
  String dateStr        = ts != null ? ts.toLocalDateTime().toLocalDate().toString() : "";
  java.sql.Date dl      = t.getDeadline();
  String deadlineStr    = dl != null ? dl.toString() : dateStr;
%>
{
  "id":         <%=t.getId()%>,
  "title":      "<%=escapeJson(title)%>",
  "status":     "<%=escapeJson(status)%>",
  "assignedTo": "<%=escapeJson(assignedTo)%>",
  "assignedBy": "<%=escapeJson(assignedBy)%>",
  "date":       "<%=dateStr%>",
  "deadline":   "<%=deadlineStr%>",
  "priority":   "<%=escapeJson(priority)%>",
  "attachment": "<%=escapeJson(attName)%>",
  "taskUrl":    "<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>"
}
<%
}
%>
]
</script>

<script id="perfs-data" type="application/json">
[
<%
boolean firstPerf = true;
for (Performance p : perfs) {
  if (!firstPerf) out.print(",");
  firstPerf = false;
  String empUsr  = p.getEmployeeUsername() != null ? p.getEmployeeUsername() : "";
  String mgrUsr  = p.getManagerUsername()  != null ? p.getManagerUsername()  : "";
  String rating  = p.getRating()           != null ? p.getRating()           : "";
  // Use createdAt to derive the month string (YYYY-MM-01) for monthly grouping
  String monthStr = "";
  if (p.getCreatedAt() != null) {
    java.time.LocalDate ld = p.getCreatedAt().toLocalDateTime().toLocalDate();
    monthStr = ld.getYear() + "-"
             + String.format("%02d", ld.getMonthValue()) + "-01";
  }
%>
{
  "id":                  <%=p.getId()%>,
  "employee_username":   "<%=escapeJson(empUsr)%>",
  "manager_username":    "<%=escapeJson(mgrUsr)%>",
  "rating":              "<%=escapeJson(rating)%>",
  "performance_month":   "<%=monthStr%>"
}
<%
}
%>
]
</script>

<!-- ════════════ PAGE SHELL ════════════ -->
<div class="max-w-7xl mx-auto">

  <!-- Breadcrumb -->
  <div id="breadcrumb" class="flex items-center gap-2 text-sm mb-5 flex-wrap">
    <button onclick="gotoTeams()" class="text-indigo-600 font-medium hover:underline">All Teams</button>
    <span class="crumb-sep hidden" id="bc-sep1">›</span>
    <span id="bc-team"   class="text-slate-500 font-medium hidden" style="cursor:pointer;" onclick="gotoTeamView()"></span>
    <span class="crumb-sep hidden" id="bc-sep2">›</span>
    <span id="bc-member" class="text-slate-700 font-semibold hidden"></span>
  </div>

  <!-- ─── PANEL 1 : Teams Grid ─── -->
  <div id="panel-teams" class="panel">
    <p class="section-label">Select a team</p>
    <div id="teams-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4"></div>
    <div id="no-teams" class="hidden empty-state mt-4">
      <div class="empty-icon"><i class="fa-solid fa-people-group"></i></div>
      <div class="empty-title">No teams found</div>
      <div class="empty-sub">Teams will appear here once created.</div>
    </div>
  </div>

  <!-- ─── PANEL 2 : Team View with Tabs ─── -->
  <div id="panel-team-view" class="panel hidden">

    <!-- Team context banner -->
    <div class="team-banner" id="team-banner">
      <div class="team-icon"><i class="fa-solid fa-people-group"></i></div>
      <div class="flex-1 min-w-0">
        <div id="banner-team-name" class="font-semibold text-slate-800 text-sm"></div>
        <div id="banner-team-mgr"  class="text-xs text-slate-400 mt-0.5"></div>
      </div>
      <div id="banner-member-info" class="hidden items-center gap-2">
        <div class="w-px h-8 bg-slate-200"></div>
        <div id="banner-member-avatar" class="avatar text-xs w-8 h-8">?</div>
        <div>
          <div id="banner-member-name"  class="text-sm font-semibold text-slate-700"></div>
          <div id="banner-member-email" class="text-xs text-slate-400 font-mono"></div>
        </div>
      </div>
    </div>

    <!-- ── Tab Bar ── -->
    <div class="tab-bar" id="tab-bar">
      <button class="tab-btn active" id="tab-btn-1" onclick="switchTab(1)">
        <span class="step-circle">1</span>
        <span>Select Employee</span>
      </button>
      <button class="tab-btn locked" id="tab-btn-2" onclick="switchTab(2)">
        <span class="step-circle">2</span>
        <span>Task Status</span>
        <span class="tab-num hidden" id="tab2-count">0</span>
      </button>
      <button class="tab-btn locked" id="tab-btn-3" onclick="switchTab(3)">
        <span class="step-circle">3</span>
        <span>Performance</span>
        <span class="tab-num hidden" id="tab3-count">0</span>
      </button>
    </div>

    <!-- ── Tab 1 Content: Select Employee ── -->
    <div class="tab-content active" id="tab-content-1">
      <p class="section-label">Choose an employee from this team</p>
      <div id="members-wrap" class="flex flex-wrap gap-3"></div>
      <div id="no-members" class="hidden empty-state mt-4">
        <div class="empty-icon"><i class="fa-solid fa-user-slash"></i></div>
        <div class="empty-title">No members</div>
        <div class="empty-sub">This team has no members yet.</div>
      </div>
    </div>

    <!-- ── Tab 2 Content: Task Status ── -->
    <div class="tab-content" id="tab-content-2">

      <!-- Status filter pills -->
      <div class="flex flex-wrap gap-2 mb-4">
        <button class="filter-tab ft-all"  onclick="filterTasks('all', this)"><i class="fa-solid fa-border-all text-xs"></i> All <span class="cpill" id="cnt-all">0</span></button>
        <button class="filter-tab"         onclick="filterTasks('COMPLETED', this)"><i class="fa-solid fa-circle-check text-xs"></i> Completed <span class="cpill" id="cnt-completed">0</span></button>
        <button class="filter-tab"         onclick="filterTasks('INCOMPLETE', this)"><i class="fa-solid fa-clock text-xs"></i> Incomplete <span class="cpill" id="cnt-incomplete">0</span></button>
        <button class="filter-tab"         onclick="filterTasks('DOCUMENT_VERIFICATION', this)"><i class="fa-solid fa-file-circle-check text-xs"></i> Doc Verification <span class="cpill" id="cnt-docverify">0</span></button>
        <button class="filter-tab"         onclick="filterTasks('ERRORS_RAISED', this)"><i class="fa-solid fa-triangle-exclamation text-xs"></i> Errors Raised <span class="cpill" id="cnt-error">0</span></button>
      </div>

      <!-- Empty: no tasks at all -->
      <div id="empty-member-tasks" class="hidden empty-state mb-4">
        <div class="empty-icon"><i class="fa-solid fa-inbox"></i></div>
        <div class="empty-title">No tasks assigned</div>
        <div class="empty-sub">This employee has no tasks yet.</div>
      </div>

      <!-- Empty: filter returns nothing -->
      <div id="empty-filter-msg" class="hidden empty-state mb-4">
        <div class="empty-icon"><i class="fa-solid fa-filter-circle-xmark"></i></div>
        <div class="empty-title">No tasks match this filter</div>
        <div class="empty-sub">Try selecting a different status.</div>
      </div>

      <!-- Task table -->
      <div id="table-wrap" class="hidden overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
        <table class="w-full">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-200 text-xs text-slate-500 uppercase tracking-wide">
              <th class="px-4 py-3 text-left">#</th>
              <th class="px-4 py-3 text-left">Title</th>
              <th class="px-4 py-3 text-left">Status</th>
              <th class="px-4 py-3 text-left">Priority</th>
              <th class="px-4 py-3 text-left">Assigned</th>
              <th class="px-4 py-3 text-left">Deadline</th>
              <th class="px-4 py-3 text-left">Attachment</th>
              <th class="px-4 py-3 text-left">Assigned By</th>
            </tr>
          </thead>
          <tbody id="task-table-body"></tbody>
        </table>
      </div>
    </div>

    <!-- ── Tab 3 Content: Performance ── -->
    <div class="tab-content" id="tab-content-3">

      <!-- ════ SECTION A: Task-based performance (original) ════ -->
      <div id="task-perf-section">

        <!-- Summary stat cards -->
        <div id="perf-grid" class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6"></div>

        <!-- Progress breakdown -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

          <!-- Completion rate -->
          <div class="perf-stat">
            <div class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">Task Completion Rate</div>
            <div class="flex items-end gap-2 mb-1">
              <span id="perf-rate-pct" class="text-3xl font-bold text-indigo-600">0%</span>
              <span class="text-xs text-slate-400 mb-1">tasks completed</span>
            </div>
            <div class="perf-bar-track">
              <div id="perf-rate-bar" class="perf-bar-fill bg-indigo-500" style="width:0%"></div>
            </div>
            <div id="perf-rate-label" class="text-xs text-slate-400 mt-2"></div>
          </div>

          <!-- On-time delivery -->
          <div class="perf-stat">
            <div class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">On-Time Delivery</div>
            <div class="flex items-end gap-2 mb-1">
              <span id="perf-ontime-pct" class="text-3xl font-bold text-emerald-600">—</span>
              <span class="text-xs text-slate-400 mb-1">on time</span>
            </div>
            <div class="perf-bar-track">
              <div id="perf-ontime-bar" class="perf-bar-fill bg-emerald-500" style="width:0%"></div>
            </div>
            <div id="perf-ontime-label" class="text-xs text-slate-400 mt-2">Based on tasks with deadlines</div>
          </div>

          <!-- Status breakdown -->
          <div class="perf-stat md:col-span-2">
            <div class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-4">Status Breakdown</div>
            <div id="perf-breakdown" class="flex flex-col gap-3"></div>
          </div>

        </div>

        <!-- Priority breakdown -->
        <div class="perf-stat mt-4">
          <div class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-4">Priority Distribution</div>
          <div id="perf-priority" class="flex flex-wrap gap-3"></div>
        </div>

      </div><!-- /task-perf-section -->

      <!-- ════ DIVIDER ════ -->
      <div style="display:flex;align-items:center;gap:12px;margin:28px 0 20px;">
        <div style="flex:1;height:1px;background:#e2e8f0;"></div>
        <span style="font-size:11px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#94a3b8;white-space:nowrap;">
          <i class="fa-solid fa-star text-amber-400 mr-1"></i> Manager Reviews
        </span>
        <div style="flex:1;height:1px;background:#e2e8f0;"></div>
      </div>

      <!-- ════ SECTION B: Monthly manager performance ════ -->
      <div id="pm-section">

        <!-- No reviews empty state -->
        <div id="pm-empty" class="pm-empty" style="display:none;">
          <div class="pm-empty-icon"><i class="fa-regular fa-star"></i></div>
          <div class="pm-empty-title">No performance reviews yet</div>
          <div class="pm-empty-sub">Reviews given by the manager will appear here once added.</div>
        </div>

        <!-- Content (shown when reviews exist) -->
        <div id="pm-content">

          <!-- Summary cards -->
          <div class="pm-summary-grid">
            <div class="pm-s-card">
              <div class="pm-s-val" id="pm-avg-val">—</div>
              <div class="pm-s-lbl">Average Rating</div>
            </div>
            <div class="pm-s-card">
              <div class="pm-s-val" id="pm-total-val">—</div>
              <div class="pm-s-lbl">Total Reviews</div>
            </div>
            <div class="pm-s-card">
              <div class="pm-s-val" id="pm-latest-val">—</div>
              <div class="pm-s-lbl">Latest Rating</div>
            </div>
          </div>

          <!-- Charts row -->
          <div class="pm-charts-row">

            <!-- Bar chart (trend) -->
            <div class="pm-chart-card">
              <div class="section-label" style="margin-bottom:12px;">Rating trend by month</div>
              <div style="position:relative;width:100%;height:190px;">
                <canvas id="pm-bar-canvas"></canvas>
              </div>
            </div>

            <!-- Donut (distribution) -->
            <div class="pm-donut-card">
              <div class="section-label" style="margin-bottom:10px;text-align:center;">Distribution</div>
              <canvas id="pm-donut-canvas" width="140" height="140" style="display:block;"></canvas>
              <div class="pm-ring-legend" id="pm-ring-legend"></div>
            </div>

          </div>

          <!-- Monthly history list -->
          <div class="pm-history-card">
            <div class="section-label" style="margin-bottom:10px;">Monthly history</div>
            <div id="pm-history-list"></div>
          </div>

        </div><!-- /pm-content -->

      </div><!-- /pm-section -->

    </div><!-- /tab3 -->

  </div><!-- /panel-team-view -->

</div><!-- /max-w -->

<!-- ════════ Chart.js ════════ -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>

<script>
// ══════════════════════════════════════════════════
// DATA
// ══════════════════════════════════════════════════
const TEAMS = JSON.parse(document.getElementById('teams-data').textContent);
const TASKS = JSON.parse(document.getElementById('tasks-data').textContent);
const PERFS = JSON.parse(document.getElementById('perfs-data').textContent);

// Index tasks by assignee (email or name, lowercased)
const tasksByKey = {};
TASKS.forEach(function(t) {
  var k = (t.assignedTo || '').trim().toLowerCase();
  if (!k) return;
  if (!tasksByKey[k]) tasksByKey[k] = [];
  tasksByKey[k].push(t);
});

function getTasksForMember(m) {
  var byEmail    = tasksByKey[(m.email    || '').trim().toLowerCase()] || [];
  var byName     = tasksByKey[(m.name     || '').trim().toLowerCase()] || [];
  var byUsername = tasksByKey[(m.username || '').trim().toLowerCase()] || [];
  var seen = {}, merged = [];
  byEmail.concat(byName).concat(byUsername).forEach(function(t) {
    if (!seen[t.id]) { seen[t.id] = true; merged.push(t); }
  });
  return merged;
}

// ── FIX: Match perfs by email, display name, OR username ──
function getPerfsForMember(m) {
  var email    = (m.email    || '').trim().toLowerCase();
  var name     = (m.name     || '').trim().toLowerCase();
  var username = (m.username || '').trim().toLowerCase();
  return PERFS.filter(function(p) {
    var eu = (p.employee_username || '').trim().toLowerCase();
    return eu === email || eu === name || eu === username;
  });
}

// ══════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════
let selectedTeam   = null;
let selectedMember = null;
let currentTab     = 1;
let activeFilter   = 'all';

// Chart instances (keep references to destroy on re-render)
let _pmBarChart   = null;
let _pmDonutChart = null;

// ══════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════
function show(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.remove('hidden');
  el.style.display = '';
}
function hide(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.add('hidden');
  el.style.display = 'none';
}

function esc(str) {
  if (!str) return '';
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function getInitials(name) {
  if (!name) return '?';
  const p = name.trim().split(/\s+/);
  return (p[0][0] + (p[1] ? p[1][0] : '')).toUpperCase();
}
function statusMeta(s) {
  switch ((s||'').toUpperCase()) {
    case 'COMPLETED':             return { stClass:'bs-completed',  stText:'Completed' };
    case 'DOCUMENT_VERIFICATION': return { stClass:'bs-docverify',  stText:'Doc Verification' };
    case 'ERRORS_RAISED':         return { stClass:'bs-error',      stText:'Errors Raised' };
    case 'ASSIGNED':              return { stClass:'bs-assigned',   stText:'Assigned' };
    default:                      return { stClass:'bs-incomplete', stText:'Incomplete' };
  }
}
function prioDot(p) {
  if (!p) return { icon:'', cls:'text-slate-400' };
  switch (p.toUpperCase()) {
    case 'HIGH':   return { icon:'<i class="fa-solid fa-circle-up"></i>',    cls:'prio-high' };
    case 'MEDIUM': return { icon:'<i class="fa-solid fa-circle-minus"></i>', cls:'prio-medium' };
    case 'LOW':    return { icon:'<i class="fa-solid fa-circle-down"></i>',  cls:'prio-low' };
    default:       return { icon:'', cls:'text-slate-400' };
  }
}

// ── FIX: Rating keys now match exact DB values (EXCELLENCE, GOOD, AVERAGE, BELOW_AVERAGE) ──
const RATING_META = {
  'EXCELLENCE':        { bg:'#dcfce7', text:'#166534', bar:'#22c55e', score:5 },
  'GOOD':              { bg:'#dbeafe', text:'#1e40af', bar:'#3b82f6', score:4 },
  'AVERAGE':           { bg:'#fef9c3', text:'#854d0e', bar:'#eab308', score:3 },
  'BELOW_AVERAGE':     { bg:'#ffedd5', text:'#9a3412', bar:'#f97316', score:2 },
  // Kept as fallbacks in case other values appear
  'Excellent':         { bg:'#dcfce7', text:'#166534', bar:'#22c55e', score:5 },
  'Good':              { bg:'#dbeafe', text:'#1e40af', bar:'#3b82f6', score:4 },
  'Average':           { bg:'#fef9c3', text:'#854d0e', bar:'#eab308', score:3 },
  'Below Average':     { bg:'#ffedd5', text:'#9a3412', bar:'#f97316', score:2 },
  'Poor':              { bg:'#fee2e2', text:'#991b1b', bar:'#ef4444', score:1 },
  'Needs Improvement': { bg:'#ede9fe', text:'#5b21b6', bar:'#8b5cf6', score:2 }
};

function ratingMeta(r) {
  return RATING_META[r] || { bg:'#f1f5f9', text:'#64748b', bar:'#94a3b8', score:3 };
}

// ── Friendly display labels for DB rating values ──
function ratingLabel(r) {
  const labels = {
    'EXCELLENCE':    'Excellence',
    'GOOD':          'Good',
    'AVERAGE':       'Average',
    'BELOW_AVERAGE': 'Below Average'
  };
  return labels[r] || r;
}

function formatMonth(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-US', { month:'short', year:'numeric' });
}

// ══════════════════════════════════════════════════
// INIT
// ══════════════════════════════════════════════════
renderTeams();

// ══════════════════════════════════════════════════
// PANEL 1 — Teams grid
// ══════════════════════════════════════════════════
function renderTeams() {
  const grid = document.getElementById('teams-grid');
  grid.innerHTML = '';
  if (!TEAMS.length) { show('no-teams'); return; }
  hide('no-teams');
  TEAMS.forEach(team => {
    const memberCount = team.members.length;
    const card = document.createElement('div');
    card.className = 'team-card';
    card.innerHTML =
      '<div class="flex items-start gap-3">' +
        '<div class="team-icon"><i class="fa-solid fa-people-group"></i></div>' +
        '<div class="flex-1 min-w-0">' +
          '<div class="font-semibold text-slate-800 text-sm truncate">' + esc(team.name) + '</div>' +
          '<div class="text-xs text-slate-400 mt-0.5 truncate"><i class="fa-solid fa-user-tie mr-1"></i>' + esc(team.manager) + '</div>' +
        '</div>' +
      '</div>' +
      '<div class="flex items-center gap-3 mt-1 pt-2 border-t border-slate-100">' +
        '<span class="text-xs text-slate-500"><i class="fa-solid fa-users mr-1 text-indigo-400"></i>' + memberCount + ' member' + (memberCount != 1 ? 's' : '') + '</span>' +
        '<span class="text-xs text-indigo-500 ml-auto font-medium">View →</span>' +
      '</div>';
    card.onclick = () => selectTeam(team, card);
    grid.appendChild(card);
  });
}

function selectTeam(team, cardEl) {
  selectedTeam   = team;
  selectedMember = null;
  document.getElementById('bc-team').textContent = team.name;
  show('bc-sep1'); show('bc-team');
  hide('bc-sep2'); hide('bc-member');
  document.getElementById('banner-team-name').textContent = team.name;
  document.getElementById('banner-team-mgr').innerHTML = '<i class="fa-solid fa-user-tie mr-1"></i>' + esc(team.manager);
  hide('banner-member-info');
  hide('panel-teams');
  show('panel-team-view');
  gotoTab1(team);
}

// ══════════════════════════════════════════════════
// TAB 1 — Select employee
// ══════════════════════════════════════════════════
function gotoTab1(team) {
  currentTab     = 1;
  selectedMember = null;
  setTabState(1, 'active');
  setTabState(2, 'locked');
  setTabState(3, 'locked');
  showTabContent(1);
  hide('banner-member-info');
  hide('bc-sep2'); hide('bc-member');
  renderMembers(team || selectedTeam);
}

function renderMembers(team) {
  const wrap = document.getElementById('members-wrap');
  wrap.innerHTML = '';
  if (!team.members.length) { show('no-members'); return; }
  hide('no-members');
  team.members.forEach(m => {
    const initials  = getInitials(m.name);
    const taskCount = getTasksForMember(m).length;
    const chip = document.createElement('div');
    chip.className = 'member-chip';
    chip.innerHTML =
      '<div class="avatar text-xs">' + initials + '</div>' +
      '<div>' +
        '<div class="font-medium text-slate-700 text-sm leading-tight">' + esc(m.name) + '</div>' +
        '<div class="text-xs text-slate-400">' + taskCount + ' task' + (taskCount != 1 ? 's' : '') + '</div>' +
      '</div>';
    chip.onclick = () => {
      document.querySelectorAll('.member-chip').forEach(c => c.classList.remove('selected'));
      chip.classList.add('selected');
      selectMember(m);
    };
    wrap.appendChild(chip);
  });
}

function selectMember(member) {
  selectedMember = member;
  document.getElementById('bc-member').textContent = member.name;
  show('bc-sep2'); show('bc-member');
  document.getElementById('banner-member-avatar').textContent = getInitials(member.name);
  document.getElementById('banner-member-name').textContent   = member.name;
  document.getElementById('banner-member-email').textContent  = member.email;
  const bmi = document.getElementById('banner-member-info');
  bmi.classList.remove('hidden');
  bmi.style.display = 'flex';
  setTabState(1, 'done');
  setTabState(2, 'available');
  setTabState(3, 'available');
  switchTab(2);
}

// ══════════════════════════════════════════════════
// TAB SWITCHING
// ══════════════════════════════════════════════════
function switchTab(n) {
  if ((n === 2 || n === 3) && !selectedMember) return;
  currentTab = n;
  [1,2,3].forEach(i => {
    const btn = document.getElementById('tab-btn-' + i);
    if (i === n) btn.classList.add('active');
    else         btn.classList.remove('active');
  });
  showTabContent(n);
  if (n === 2) renderTaskStatus(selectedMember);
  if (n === 3) renderPerformance(selectedMember);
}

function showTabContent(n) {
  [1,2,3].forEach(i => {
    const el = document.getElementById('tab-content-' + i);
    el.classList.toggle('active', i === n);
  });
}

function setTabState(n, state) {
  const btn = document.getElementById('tab-btn-' + n);
  btn.classList.remove('active','done','locked');
  if (state === 'locked')  btn.classList.add('locked');
  if (state === 'done')    btn.classList.add('done');
  if (state === 'active')  btn.classList.add('active');
}

// ══════════════════════════════════════════════════
// TAB 2 — Task Status
// ══════════════════════════════════════════════════
function renderTaskStatus(member) {
  const memberTasks = getTasksForMember(member);
  hide('empty-member-tasks');
  hide('empty-filter-msg');
  hide('table-wrap');

  const counts = { all:0, COMPLETED:0, INCOMPLETE:0, DOCUMENT_VERIFICATION:0, ERRORS_RAISED:0 };
  memberTasks.forEach(t => {
    counts.all++;
    if (counts[t.status] !== undefined) counts[t.status]++;
  });
  document.getElementById('cnt-all').textContent        = counts.all;
  document.getElementById('cnt-completed').textContent  = counts.COMPLETED;
  document.getElementById('cnt-incomplete').textContent = counts.INCOMPLETE;
  document.getElementById('cnt-docverify').textContent  = counts.DOCUMENT_VERIFICATION;
  document.getElementById('cnt-error').textContent      = counts.ERRORS_RAISED;

  const t2c = document.getElementById('tab2-count');
  t2c.textContent = counts.all;
  show('tab2-count');

  activeFilter = 'all';
  document.querySelectorAll('.filter-tab').forEach(t => t.className = 'filter-tab');
  document.querySelector('.filter-tab').className = 'filter-tab ft-all';

  const tbody = document.getElementById('task-table-body');
  tbody.innerHTML = '';

  if (!memberTasks.length) { show('empty-member-tasks'); return; }

  show('table-wrap');
  memberTasks.forEach((t, i) => {
    const { stClass, stText } = statusMeta(t.status);
    const prioIcon = prioDot(t.priority);
    const attCell  = t.attachment
      ? '<a href="' + t.taskUrl + '" class="text-indigo-600 hover:underline text-xs" target="_blank">' + esc(t.attachment) + '</a>'
      : '<span class="text-slate-300 text-xs italic">—</span>';
    const tr = document.createElement('tr');
    tr.className  = 'task-row border-b border-slate-100 hover:bg-slate-50 text-sm';
    tr.dataset.status = t.status;
    tr.innerHTML =
      '<td class="px-4 py-3 text-slate-400 text-xs row-num">' + (i+1) + '</td>' +
      '<td class="px-4 py-3 text-slate-800 font-medium max-w-xs truncate">' + esc(t.title) + '</td>' +
      '<td class="px-4 py-3"><span class="badge-status ' + stClass + '">' + stText + '</span></td>' +
      '<td class="px-4 py-3 text-xs ' + prioIcon.cls + '">' + prioIcon.icon + ' ' + esc(t.priority) + '</td>' +
      '<td class="px-4 py-3 text-slate-500 text-xs">' + t.date + '</td>' +
      '<td class="px-4 py-3 text-slate-500 text-xs">' + t.deadline + '</td>' +
      '<td class="px-4 py-3">' + attCell + '</td>' +
      '<td class="px-4 py-3 text-slate-500 text-xs">' + esc(t.assignedBy) + '</td>';
    tbody.appendChild(tr);
  });
}

// ── Task filter pills ──
const TAB_CLS = {
  'all':'ft-all','COMPLETED':'ft-completed','INCOMPLETE':'ft-incomplete',
  'DOCUMENT_VERIFICATION':'ft-docverify','ERRORS_RAISED':'ft-error'
};
function filterTasks(status, btn) {
  activeFilter = status;
  document.querySelectorAll('.filter-tab').forEach(t => t.className = 'filter-tab');
  btn.classList.add(TAB_CLS[status]);
  let visible = 0;
  document.querySelectorAll('.task-row').forEach((row, i) => {
    const match = status === 'all' || row.dataset.status === status;
    row.style.display = match ? '' : 'none';
    if (match) { visible++; row.querySelector('.row-num').textContent = visible; }
  });
  if (visible === 0) {
    hide('table-wrap'); hide('empty-member-tasks'); show('empty-filter-msg');
  } else {
    show('table-wrap'); hide('empty-member-tasks'); hide('empty-filter-msg');
  }
}

// ══════════════════════════════════════════════════
// TAB 3 — Performance
// ══════════════════════════════════════════════════
function renderPerformance(member) {
  renderTaskPerf(member);
  renderMonthlyPerf(member);
}

// ── Part A: Task-based performance (original logic) ──
function renderTaskPerf(member) {
  const memberTasks = getTasksForMember(member);
  const total = memberTasks.length;

  const counts = { COMPLETED:0, INCOMPLETE:0, DOCUMENT_VERIFICATION:0, ERRORS_RAISED:0, ASSIGNED:0 };
  const prioC  = { HIGH:0, MEDIUM:0, LOW:0, OTHER:0 };
  let onTimeCount = 0, withDeadline = 0;
  const today = new Date(); today.setHours(0,0,0,0);

  memberTasks.forEach(t => {
    const s = (t.status || 'INCOMPLETE').toUpperCase();
    if (counts[s] !== undefined) counts[s]++; else counts.INCOMPLETE++;
    const p = (t.priority || '').toUpperCase();
    if (prioC[p] !== undefined) prioC[p]++; else prioC.OTHER++;
    if (t.deadline) {
      withDeadline++;
      const dl = new Date(t.deadline); dl.setHours(0,0,0,0);
      if (s === 'COMPLETED' && dl >= today) onTimeCount++;
    }
  });

  const completionPct = total > 0 ? Math.round((counts.COMPLETED / total) * 100) : 0;
  const onTimePct     = withDeadline > 0 ? Math.round((onTimeCount / withDeadline) * 100) : null;

  // Stat cards
  const perfGrid = document.getElementById('perf-grid');
  perfGrid.innerHTML = '';
  const stats = [
    { icon:'fa-list-check',           label:'Total Tasks', val: total,               color:'indigo' },
    { icon:'fa-circle-check',         label:'Completed',   val: counts.COMPLETED,    color:'green'  },
    { icon:'fa-clock',                label:'Incomplete',  val: counts.INCOMPLETE,   color:'amber'  },
    { icon:'fa-triangle-exclamation', label:'Errors',      val: counts.ERRORS_RAISED,color:'red'    },
  ];
  const colorMap = {
    indigo:'text-indigo-600 bg-indigo-50',
    green:'text-green-600 bg-green-50',
    amber:'text-amber-600 bg-amber-50',
    red:'text-red-600 bg-red-50'
  };
  stats.forEach(s => {
    const div = document.createElement('div');
    div.className = 'perf-stat flex items-center gap-3';
    div.innerHTML =
      '<div class="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ' + colorMap[s.color] + '">' +
        '<i class="fa-solid ' + s.icon + '"></i>' +
      '</div>' +
      '<div>' +
        '<div class="text-2xl font-bold text-slate-800">' + s.val + '</div>' +
        '<div class="text-xs text-slate-400">' + s.label + '</div>' +
      '</div>';
    perfGrid.appendChild(div);
  });

  // Completion rate bar
  document.getElementById('perf-rate-pct').textContent  = completionPct + '%';
  document.getElementById('perf-rate-bar').style.width  = completionPct + '%';
  document.getElementById('perf-rate-label').textContent = counts.COMPLETED + ' of ' + total + ' tasks completed';

  // On-time bar
  const otEl  = document.getElementById('perf-ontime-pct');
  const otBar = document.getElementById('perf-ontime-bar');
  if (onTimePct !== null) {
    otEl.textContent  = onTimePct + '%';
    otBar.style.width = onTimePct + '%';
    document.getElementById('perf-ontime-label').textContent = 'Based on tasks with deadlines';
  } else {
    otEl.textContent  = '—';
    otBar.style.width = '0%';
    document.getElementById('perf-ontime-label').textContent = 'No deadline data available';
  }

  // Status breakdown bars
  const breakdown = document.getElementById('perf-breakdown');
  breakdown.innerHTML = '';
  const statusDefs = [
    { key:'COMPLETED',             label:'Completed',        color:'bg-green-500',  text:'text-green-700'  },
    { key:'INCOMPLETE',            label:'Incomplete',       color:'bg-amber-400',  text:'text-amber-700'  },
    { key:'DOCUMENT_VERIFICATION', label:'Doc Verification', color:'bg-violet-500', text:'text-violet-700' },
    { key:'ERRORS_RAISED',         label:'Errors Raised',    color:'bg-red-500',    text:'text-red-700'    },
    { key:'ASSIGNED',              label:'Assigned',         color:'bg-sky-500',    text:'text-sky-700'    },
  ];
  statusDefs.forEach(sd => {
    const cnt = counts[sd.key] || 0;
    const pct = total > 0 ? Math.round((cnt / total) * 100) : 0;
    const row = document.createElement('div');
    row.className = 'flex items-center gap-3';
    row.innerHTML =
      '<div class="w-36 text-xs font-medium ' + sd.text + ' flex-shrink-0">' + sd.label + '</div>' +
      '<div class="flex-1 perf-bar-track">' +
        '<div class="perf-bar-fill ' + sd.color + '" style="width:' + pct + '%"></div>' +
      '</div>' +
      '<div class="w-16 text-right text-xs text-slate-500">' + cnt + ' <span class="text-slate-300">(' + pct + '%)</span></div>';
    breakdown.appendChild(row);
  });

  // Priority distribution pills
  const prioEl = document.getElementById('perf-priority');
  prioEl.innerHTML = '';
  const prioDefs = [
    { key:'HIGH',   label:'High',   bg:'bg-red-100',   text:'text-red-700',   dot:'bg-red-500'   },
    { key:'MEDIUM', label:'Medium', bg:'bg-amber-100', text:'text-amber-700', dot:'bg-amber-500' },
    { key:'LOW',    label:'Low',    bg:'bg-green-100', text:'text-green-700', dot:'bg-green-500' },
    { key:'OTHER',  label:'Other',  bg:'bg-slate-100', text:'text-slate-600', dot:'bg-slate-400' },
  ];
  prioDefs.forEach(pd => {
    const cnt = prioC[pd.key] || 0;
    if (!cnt) return;
    const pill = document.createElement('div');
    pill.className = 'flex items-center gap-2 px-4 py-2 rounded-xl ' + pd.bg;
    pill.innerHTML =
      '<div class="w-2.5 h-2.5 rounded-full ' + pd.dot + '"></div>' +
      '<span class="text-sm font-semibold ' + pd.text + '">' + cnt + '</span>' +
      '<span class="text-xs ' + pd.text + ' opacity-70">' + pd.label + '</span>';
    prioEl.appendChild(pill);
  });
  if (!prioEl.children.length) {
    prioEl.innerHTML = '<span class="text-sm text-slate-400 italic">No priority data available.</span>';
  }
}

// ── Part B: Monthly manager performance reviews ──
function renderMonthlyPerf(member) {
  const records = getPerfsForMember(member);
  const sorted  = [...records].sort((a,b) => new Date(a.performance_month) - new Date(b.performance_month));
  const total   = sorted.length;

  // Update tab-3 badge
  const t3c = document.getElementById('tab3-count');
  if (total > 0) { t3c.textContent = total; show('tab3-count'); }
  else           { hide('tab3-count'); }

  // No reviews
  if (!total) {
    document.getElementById('pm-empty').style.display   = '';
    document.getElementById('pm-content').style.display = 'none';
    if (_pmBarChart)   { _pmBarChart.destroy();   _pmBarChart   = null; }
    if (_pmDonutChart) { _pmDonutChart.destroy();  _pmDonutChart = null; }
    return;
  }

  document.getElementById('pm-empty').style.display   = 'none';
  document.getElementById('pm-content').style.display = '';

  // ── Summary cards ──
  const avgScore  = sorted.reduce((s,r) => s + ratingMeta(r.rating).score, 0) / total;
  const latest    = sorted[sorted.length - 1];
  const prev      = sorted.length > 1 ? sorted[sorted.length - 2] : null;
  const trendDiff = prev ? (ratingMeta(latest.rating).score - ratingMeta(prev.rating).score) : 0;
  const trendIcon = trendDiff > 0 ? '↑' : trendDiff < 0 ? '↓' : '—';
  const trendCls  = trendDiff > 0 ? 'pm-trend-up' : trendDiff < 0 ? 'pm-trend-down' : 'pm-trend-flat';

  // Map avgScore to nearest rating label
  const avgLabel = Object.entries(RATING_META).reduce((best, [k, v]) =>
    Math.abs(v.score - avgScore) < Math.abs(ratingMeta(best).score - avgScore) ? k : best,
    Object.keys(RATING_META)[0]
  );
  const am = ratingMeta(avgLabel);
  const lm = ratingMeta(latest.rating);

  document.getElementById('pm-avg-val').innerHTML =
    '<span style="background:' + am.bg + ';color:' + am.text + ';padding:3px 12px;border-radius:9999px;font-size:13px;font-weight:700;">' + esc(ratingLabel(avgLabel)) + '</span>';

  document.getElementById('pm-total-val').textContent = total;

  document.getElementById('pm-latest-val').innerHTML =
    '<span style="background:' + lm.bg + ';color:' + lm.text + ';padding:3px 12px;border-radius:9999px;font-size:13px;font-weight:700;">' + esc(ratingLabel(latest.rating)) + '</span>' +
    '<span class="' + trendCls + '" style="font-size:16px;">' + trendIcon + '</span>';

  // ── Bar chart (rating trend) ──
  const barLabels = sorted.map(r => formatMonth(r.performance_month));
  const barScores = sorted.map(r => ratingMeta(r.rating).score);
  const barColors = sorted.map(r => ratingMeta(r.rating).bar);

  const barCanvas = document.getElementById('pm-bar-canvas');
  if (_pmBarChart) { _pmBarChart.destroy(); _pmBarChart = null; }
  _pmBarChart = new Chart(barCanvas, {
    type: 'bar',
    data: {
      labels: barLabels,
      datasets: [{
        data: barScores,
        backgroundColor: barColors,
        borderRadius: 7,
        borderSkipped: false,
        barThickness: 28,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: function(ctx) {
              var rec = sorted[ctx.dataIndex];
              return ' ' + ratingLabel(rec.rating) + '  (' + ctx.raw + '/5)';
            }
          }
        }
      },
      scales: {
        y: {
          min: 0, max: 5.5,
          ticks: {
            stepSize: 1,
            callback: function(v) {
              var m = { 1:'Poor', 2:'Below Avg', 3:'Average', 4:'Good', 5:'Excellence' };
              return m[v] || '';
            },
            font: { size: 10 }
          },
          grid: { color: '#f1f5f9' }
        },
        x: {
          grid: { display: false },
          ticks: { font: { size: 10 }, maxRotation: 45, autoSkip: false }
        }
      }
    }
  });

  // ── Donut chart (distribution) ──
  var dist = {};
  sorted.forEach(function(r) { dist[r.rating] = (dist[r.rating] || 0) + 1; });
  var distKeys   = Object.keys(dist);
  var distValues = distKeys.map(function(k) { return dist[k]; });
  var distColors = distKeys.map(function(k) { return ratingMeta(k).bar; });

  const donutCanvas = document.getElementById('pm-donut-canvas');
  if (_pmDonutChart) { _pmDonutChart.destroy(); _pmDonutChart = null; }
  _pmDonutChart = new Chart(donutCanvas, {
    type: 'doughnut',
    data: {
      labels: distKeys.map(ratingLabel),
      datasets: [{
        data: distValues,
        backgroundColor: distColors,
        borderWidth: 2,
        borderColor: '#ffffff'
      }]
    },
    options: {
      responsive: false,
      cutout: '60%',
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: function(ctx) { return ctx.label + ': ' + ctx.raw; }
          }
        }
      }
    }
  });

  // Ring legend
  const leg = document.getElementById('pm-ring-legend');
  leg.innerHTML = '';
  distKeys.forEach(function(k) {
    const m = ratingMeta(k);
    leg.innerHTML +=
      '<div class="pm-ring-item">' +
        '<div class="pm-ring-dot" style="background:' + m.bar + ';"></div>' +
        esc(ratingLabel(k)) + ' (' + dist[k] + ')' +
      '</div>';
  });

  // ── Monthly history list ──
  const list = document.getElementById('pm-history-list');
  list.innerHTML = '';
  [...sorted].reverse().forEach(function(rec) {
    var m   = ratingMeta(rec.rating);
    var pct = Math.round(m.score / 5 * 100);
    list.innerHTML +=
      '<div class="pm-month-row">' +
        '<span class="pm-month-lbl">' + formatMonth(rec.performance_month) + '</span>' +
        '<div class="pm-bar-wrap">' +
          '<div class="pm-bar-track">' +
            '<div class="pm-bar-fill" style="width:' + pct + '%;background:' + m.bar + ';"></div>' +
          '</div>' +
        '</div>' +
        '<span class="pm-badge" style="background:' + m.bg + ';color:' + m.text + ';">' + esc(ratingLabel(rec.rating)) + '</span>' +
        '<span class="pm-mgr-chip">' +
          '<svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M12 12a5 5 0 100-10 5 5 0 000 10zm0 2c-5.33 0-8 2.67-8 4v2h16v-2c0-1.33-2.67-4-8-4z" fill="#94a3b8"/></svg>' +
          esc(rec.manager_username) +
        '</span>' +
      '</div>';
  });
}

// ══════════════════════════════════════════════════
// NAVIGATION
// ══════════════════════════════════════════════════
function gotoTeams() {
  hide('panel-team-view');
  show('panel-teams');
  hide('bc-sep1'); hide('bc-team'); hide('bc-sep2'); hide('bc-member');
  selectedTeam = null; selectedMember = null;
  document.querySelectorAll('.team-card').forEach(c => c.classList.remove('selected'));
}

function gotoTeamView() {
  gotoTab1(null);
}
</script>

<%!
  private static String escapeJson(String s) {
    if (s == null) return "";
    return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t");
  }
%>
</body>
</html>
