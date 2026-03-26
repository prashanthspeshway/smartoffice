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

// Collect unique team names AND designations from team list
TreeSet<String> teams        = new TreeSet<>();
TreeSet<String> designations = new TreeSet<>();
if (team != null) {
    for (User u : team) {
        if (u.getTeamName() != null && !u.getTeamName().trim().isEmpty())
            teams.add(u.getTeamName().trim());
        if (u.getDesignation() != null && !u.getDesignation().trim().isEmpty())
            designations.add(u.getDesignation().trim());
    }
}

// Compute start-of-current-week (Monday)
Calendar cal = Calendar.getInstance();
cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0);
cal.set(Calendar.SECOND, 0);      cal.set(Calendar.MILLISECOND, 0);
int dow = cal.get(Calendar.DAY_OF_WEEK);
int daysToMon = (dow == Calendar.SUNDAY) ? 6 : dow - Calendar.MONDAY;
cal.add(Calendar.DAY_OF_MONTH, -daysToMon);
Date weekStart = cal.getTime();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks • Manager</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
  body { font-family: 'DM Sans', system-ui, sans-serif; }

  .badge { display:inline-flex; align-items:center; gap:4px; padding:3px 10px; border-radius:9999px; font-size:11px; font-weight:600; }
  .badge-assigned    { background:#e0f2fe; color:#0369a1; }
  .badge-processing  { background:#fef3c7; color:#92400e; }
  .badge-submitted   { background:#fef3c7; color:#92400e; }
  .badge-completed   { background:#dcfce7; color:#166534; }
  .badge-incomplete  { background:#fee2e2; color:#b91c1c; }
  .badge-docverify   { background:#ede9fe; color:#6d28d9; }

  .ftab { padding:5px 14px; border-radius:9999px; font-size:12px; font-weight:500; cursor:pointer;
          border:1.5px solid #e2e8f0; background:white; color:#64748b; transition:all .15s;
          display:inline-flex; align-items:center; gap:5px; }
  .ftab:hover         { border-color:#6366f1; color:#6366f1; }
  .ftab.f-all         { background:#6366f1; color:white; border-color:#6366f1; }
  .ftab.f-week        { background:#f0fdf4; color:#15803d; border-color:#86efac; }
  .ftab.f-assigned    { background:#e0f2fe; color:#0369a1; border-color:#7dd3fc; }
  .ftab.f-processing  { background:#fef3c7; color:#92400e; border-color:#fcd34d; }
  .ftab.f-completed   { background:#dcfce7; color:#166534; border-color:#86efac; }
  .cpill { background:rgba(0,0,0,.12); border-radius:9999px; padding:0 7px; font-size:10px; font-weight:700; }

  .task-card { background:white; border:1.5px solid #e2e8f0; border-radius:14px; padding:16px 18px;
               transition:box-shadow .15s, border-color .15s; }
  .task-card:hover { box-shadow:0 4px 14px rgba(0,0,0,.08); border-color:#c7d2fe; }
  .task-card.needs-review { border-left:4px solid #f59e0b; }
  .task-card.completed    { border-left:4px solid #22c55e; opacity:.85; }
  .task-card.this-week-card { box-shadow: 0 0 0 1.5px #bbf7d0; }

  .week-pill { display:inline-flex; align-items:center; gap:4px;
               background:#f0fdf4; color:#15803d; border:1px solid #86efac;
               border-radius:9999px; font-size:10px; font-weight:600; padding:2px 8px; }

  /* Team tag shown inside each employee row */
  .team-tag  { display:inline-flex; align-items:center; gap:3px;
               background:#eef2ff; color:#4338ca; border:1px solid #c7d2fe;
               border-radius:9999px; font-size:10px; font-weight:500; padding:1px 7px; margin-top:2px; }

  /* Designation tag shown inside each employee row */
  .desig-tag { display:inline-flex; align-items:center; gap:3px;
               background:#f1f5f9; color:#475569; border:1px solid #e2e8f0;
               border-radius:9999px; font-size:10px; font-weight:500; padding:1px 7px; margin-top:2px; }

  /* Team filter pills */
  .team-btn { font-size:12px; padding:4px 14px; border-radius:9999px; cursor:pointer;
              border:1.5px solid #e2e8f0; background:white; color:#64748b;
              transition:all .15s; display:inline-flex; align-items:center; gap:4px; }
  .team-btn:hover  { border-color:#6366f1; color:#6366f1; background:#eef2ff; }
  .team-btn.active { background:#6366f1; color:white; border-color:#6366f1; }

  .emp-row.hidden-by-team { display:none !important; }

  .prio-HIGH   { color:#ef4444; font-weight:600; }
  .prio-MEDIUM { color:#f59e0b; font-weight:600; }
  .prio-LOW    { color:#22c55e; font-weight:600; }

  .feed-scroll { max-height: calc(100vh - 220px); overflow-y:auto; padding-right:4px; }
  .feed-scroll::-webkit-scrollbar { width:5px; }
  .feed-scroll::-webkit-scrollbar-track { background:#f1f5f9; border-radius:9999px; }
  .feed-scroll::-webkit-scrollbar-thumb { background:#cbd5e1; border-radius:9999px; }

  .pulse-dot { width:8px; height:8px; border-radius:50%; background:#f59e0b;
               box-shadow:0 0 0 0 rgba(245,158,11,.5);
               animation:pulse-ring 1.4s ease-out infinite; display:inline-block; }
  @keyframes pulse-ring {
    0%   { box-shadow:0 0 0 0 rgba(245,158,11,.5); }
    70%  { box-shadow:0 0 0 7px rgba(245,158,11,0); }
    100% { box-shadow:0 0 0 0 rgba(245,158,11,0); }
  }
</style>
</head>
<body class="bg-slate-100 p-6">

<div id="toast" class="fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg hidden text-sm font-medium max-w-xs"></div>

<div class="max-w-7xl mx-auto">
  <h2 class="text-2xl font-bold text-slate-800 mb-6 flex items-center gap-2">
    <i class="fa-solid fa-list-check text-indigo-500"></i> Tasks
  </h2>

  <div class="grid grid-cols-1 lg:grid-cols-[420px_1fr] gap-6 items-start">

    <!-- ══════════════ LEFT: Assign Task ══════════════ -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 sticky top-6">
      <div class="flex items-center gap-3 mb-5">
        <div class="w-9 h-9 rounded-lg bg-indigo-50 flex items-center justify-center">
          <i class="fa-solid fa-paper-plane text-indigo-600"></i>
        </div>
        <h3 class="text-base font-semibold text-slate-800">Assign New Task</h3>
      </div>

      <%if (errorMessage != null) {%>
      <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-2.5 rounded-lg mb-4 text-sm">
        <i class="fa-solid fa-exclamation-circle mr-2"></i><%=errorMessage%>
      </div>
      <%}%>

      <form action="<%=request.getContextPath()%>/managerTasks" method="post"
            enctype="multipart/form-data" class="space-y-4" id="assignTaskForm">
        <input type="hidden" name="action" value="assign">

        <!-- ── Filter by Team ── -->
        <%if (!teams.isEmpty()) {%>
        <div>
          <label class="block text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">
            <i class="fa-solid fa-people-group mr-1"></i>Filter by Team
          </label>
          <div class="flex flex-wrap gap-1.5" id="teamFilterRow">
            <button type="button" class="team-btn active" data-team="all"
                    onclick="filterByTeam('all', this)">
              <i class="fa-solid fa-users text-xs"></i> All Teams
            </button>
            <%for (String tm : teams) {%>
            <button type="button" class="team-btn" data-team="<%=tm%>"
                    onclick="filterByTeam('<%=tm%>', this)">
              <i class="fa-solid fa-people-group text-xs"></i> <%=tm%>
            </button>
            <%}%>
          </div>
        </div>
        <%}%>

        <!-- ── Assign to ── -->
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">
            Assign to <span class="text-red-500">*</span>
            <span id="empCountLabel" class="text-slate-400 font-normal text-xs ml-1"></span>
          </label>
          <div class="relative" id="empDropdownWrapper">
            <button type="button" onclick="toggleEmpDropdown()"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-lg bg-white text-left focus:outline-none focus:ring-2 focus:ring-indigo-500 flex justify-between items-center min-h-[42px]">
              <span id="empDropdownLabel" class="text-slate-400 text-sm">Select employees…</span>
              <i class="fa-solid fa-chevron-down text-slate-400 text-xs ml-2 shrink-0 transition-transform" id="empChevron"></i>
            </button>
            <div id="empDropdownPanel" class="hidden absolute z-20 mt-1 w-full bg-white border border-slate-200 rounded-xl shadow-lg max-h-52 overflow-y-auto">
              <%if (team != null && !team.isEmpty()) {
                  for (User u : team) {
                      String desig   = u.getDesignation() != null ? u.getDesignation().trim() : "";
                      String empTeam = u.getTeamName()    != null ? u.getTeamName().trim()    : "";
              %>
              <label class="emp-row flex items-center gap-3 px-4 py-2.5 hover:bg-indigo-50 cursor-pointer border-b border-slate-100 last:border-0"
                     data-team="<%=empTeam%>">
                <input type="checkbox" name="employeeUsername" value="<%=u.getEmail()%>"
                       class="emp-checkbox accent-indigo-600 w-4 h-4 shrink-0" onchange="updateEmpLabel()">
                <span class="text-sm text-slate-700 flex-1 min-w-0">
                  <span class="block font-medium truncate emp-name"><%=u.getFullname()%></span>
                  <span class="text-slate-400 text-xs font-mono block"><%=u.getEmail()%></span>
                  <span class="flex flex-wrap gap-1 mt-0.5">
                    <%if (!empTeam.isEmpty()) {%>
                    <span class="team-tag"><i class="fa-solid fa-people-group text-xs"></i> <%=empTeam%></span>
                    <%}%>
                    <%if (!desig.isEmpty()) {%>
                    <span class="desig-tag"><i class="fa-solid fa-id-badge text-xs"></i> <%=desig%></span>
                    <%}%>
                  </span>
                </span>
              </label>
              <%} } else { %>
              <div class="px-4 py-3 text-sm text-slate-400">No employees available</div>
              <%}%>
            </div>
          </div>
          <input type="text" id="empValidation" class="sr-only" required tabindex="-1" aria-hidden="true" autocomplete="off">
        </div>

        <!-- Title -->
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Title <span class="text-red-500">*</span></label>
          <input type="text" name="title" placeholder="E.g. Submit weekly report" required
            class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Description <span class="text-red-500">*</span></label>
          <textarea name="taskDesc" rows="3" placeholder="Add clear instructions and details" required
            class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
        </div>

        <!-- Deadline + Priority -->
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Deadline <span class="text-red-500">*</span></label>
            <input type="date" name="deadline" required
              class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
          </div>
          <div>
            <label class="block text-sm font-semibold text-slate-700 mb-1.5">Priority <span class="text-red-500">*</span></label>
            <select name="priority" required
              class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
              <option value="HIGH">High</option>
              <option value="MEDIUM" selected>Medium</option>
              <option value="LOW">Low</option>
            </select>
          </div>
        </div>

        <!-- Attachment -->
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1.5">Attachment <span class="text-slate-400 font-normal">(optional)</span></label>
          <input type="file" name="attachment" accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg"
            class="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
        </div>

        <button type="submit"
          class="w-full py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg transition-colors flex items-center justify-center gap-2">
          <i class="fa-solid fa-paper-plane"></i> Assign Task
        </button>
      </form>
    </div>

    <!-- ══════════════ RIGHT: Task Feed ══════════════ -->
    <div>
      <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
        <div class="flex items-center gap-2">
          <h3 class="text-base font-semibold text-slate-800">Team Task Feed</h3>
          <%
          long pendingCount = allTasks.stream().filter(t -> {
              String s = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "";
              return s.equals("PROCESSING") || s.equals("SUBMITTED");
          }).count();
          %>
          <%if (pendingCount > 0) {%>
          <span class="flex items-center gap-1.5 bg-amber-50 border border-amber-200 text-amber-700 text-xs font-semibold px-2.5 py-1 rounded-full">
            <span class="pulse-dot"></span> <%=pendingCount%> awaiting review
          </span>
          <%}%>
        </div>
        <button onclick="location.reload()"
          class="text-xs text-slate-500 hover:text-indigo-600 flex items-center gap-1.5 border border-slate-200 rounded-full px-3 py-1.5 bg-white transition-colors">
          <i class="fa-solid fa-rotate-right text-xs"></i> Refresh
        </button>
      </div>

      <div class="flex flex-wrap gap-2 mb-4">
        <button class="ftab"                     onclick="filterFeed('all',this)">       <i class="fa-solid fa-border-all text-xs"></i>    All          <span class="cpill" id="fc-all">0</span></button>
        <button class="ftab f-week" id="tabWeek" onclick="filterFeed('WEEK',this)">      <i class="fa-solid fa-calendar-week text-xs"></i> This Week    <span class="cpill" id="fc-week">0</span></button>
        <button class="ftab"                     onclick="filterFeed('ASSIGNED',this)">  <i class="fa-solid fa-clock text-xs"></i>         Assigned     <span class="cpill" id="fc-assigned">0</span></button>
        <button class="ftab"                     onclick="filterFeed('REVIEW',this)">    <span class="pulse-dot"></span>                  Needs Review <span class="cpill" id="fc-review">0</span></button>
        <button class="ftab"                     onclick="filterFeed('COMPLETED',this)"> <i class="fa-solid fa-circle-check text-xs"></i>  Completed    <span class="cpill" id="fc-completed">0</span></button>
      </div>

      <div class="feed-scroll space-y-3" id="taskFeed">
        <%if (allTasks.isEmpty()) {%>
        <div class="bg-white rounded-xl border border-slate-200 px-6 py-12 text-center">
          <i class="fa-solid fa-inbox text-slate-300 text-4xl mb-3"></i>
          <p class="text-slate-400 text-sm">No tasks assigned yet. Use the form to assign your first task.</p>
        </div>
        <%} else {
          for (Task t : allTasks) {
            String rawStatus     = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "ASSIGNED";
            boolean isProcessing = rawStatus.equals("PROCESSING") || rawStatus.equals("SUBMITTED");
            boolean isCompleted  = rawStatus.equals("COMPLETED");
            boolean needsReview  = isProcessing;
            boolean isThisWeek   = t.getAssignedDate() != null && !t.getAssignedDate().before(weekStart);

            String badgeCls, badgeLabel, filterKey;
            switch (rawStatus) {
              case "COMPLETED":
                badgeCls="badge-completed"; badgeLabel="Completed"; filterKey="COMPLETED"; break;
              case "PROCESSING": case "SUBMITTED":
                badgeCls="badge-processing"; badgeLabel="Awaiting Review"; filterKey="REVIEW"; break;
              case "DOCUMENT_VERIFICATION":
                badgeCls="badge-docverify"; badgeLabel="Doc Verification"; filterKey="ASSIGNED"; break;
              default:
                badgeCls="badge-assigned"; badgeLabel="Assigned"; filterKey="ASSIGNED"; break;
            }

            String cardExtra = (isCompleted ? "completed" : (needsReview ? "needs-review" : ""))
                             + (isThisWeek ? " this-week-card" : "");
            String prioCls   = "prio-" + (t.getPriority() != null ? t.getPriority().trim().toUpperCase() : "MEDIUM");
            String prioLabel = t.getPriority() != null ? t.getPriority() : "MEDIUM";
            String deadlineStr = t.getDeadline() != null ? t.getDeadline().toString() : "—";
            String assignedTo  = t.getAssignedTo() != null ? t.getAssignedTo() : "";
            String title       = t.getTitle()  != null ? t.getTitle() : "Untitled";
            String desc        = t.getDescription() != null ? t.getDescription() : "";
        %>
        <div class="task-card <%=cardExtra.trim()%>" data-filter="<%=filterKey%>" data-week="<%=isThisWeek?"1":"0"%>">
          <div class="flex flex-wrap justify-between items-start gap-2 mb-2">
            <div class="flex items-start gap-2 flex-1 min-w-0">
              <%if (needsReview) {%><span class="pulse-dot mt-1.5 shrink-0"></span><%}%>
              <div class="min-w-0">
                <p class="font-semibold text-slate-800 text-sm leading-snug truncate"><%=title%></p>
                <p class="text-xs text-slate-400 font-mono mt-0.5"><%=assignedTo%></p>
              </div>
            </div>
            <div class="flex items-center gap-1.5 shrink-0 flex-wrap justify-end">
              <%if (isThisWeek) {%>
              <span class="week-pill"><i class="fa-solid fa-calendar-week text-xs"></i> This Week</span>
              <%}%>
              <span class="badge <%=badgeCls%>"><%=badgeLabel%></span>
            </div>
          </div>

          <%if (!desc.isEmpty()) {%>
          <p class="text-xs text-slate-500 mb-2 line-clamp-2"><%=desc%></p>
          <%}%>

          <div class="flex flex-wrap items-center gap-3 text-xs text-slate-500 mb-3">
            <span><i class="fa-regular fa-calendar mr-1"></i>Due: <span class="font-medium text-slate-700"><%=deadlineStr%></span></span>
            <span class="<%=prioCls%>"><i class="fa-solid fa-flag mr-1"></i><%=prioLabel%></span>
            <%if (t.getSubmittedAt() != null) {%>
            <span class="text-amber-600"><i class="fa-regular fa-clock mr-1"></i>Submitted: <%=t.getSubmittedAt().toLocalDateTime().toLocalDate()%></span>
            <%}%>
            <%if (t.getAssignedDate() != null) {%>
            <span><i class="fa-regular fa-clock mr-1"></i>Assigned: <%=t.getAssignedDate().toLocalDateTime().toLocalDate()%></span>
            <%}%>
          </div>

          <%if (t.getEmployeeComment() != null && !t.getEmployeeComment().isEmpty()) {%>
          <div class="bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 mb-3 text-xs text-amber-800">
            <i class="fa-solid fa-message mr-1"></i><span class="font-semibold">Employee note:</span> <%=t.getEmployeeComment()%>
          </div>
          <%}%>
          <%if (t.getEmployeeAttachmentName() != null && !t.getEmployeeAttachmentName().isEmpty()) {%>
          <a href="<%=request.getContextPath()%>/employeeTaskAttachment?id=<%=t.getId()%>" target="_blank"
             class="inline-flex items-center gap-1.5 text-xs text-green-700 bg-green-50 border border-green-200 rounded-full px-3 py-1 mb-3 hover:bg-green-100 transition-colors">
            <i class="fa-solid fa-file-arrow-up"></i> <%=t.getEmployeeAttachmentName()%>
          </a>
          <%}%>
          <%if (t.getAttachmentName() != null && !t.getAttachmentName().isEmpty()) {%>
          <a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>" target="_blank"
             class="inline-flex items-center gap-1.5 text-xs text-indigo-700 bg-indigo-50 border border-indigo-200 rounded-full px-3 py-1 mb-3 hover:bg-indigo-100 transition-colors ml-1">
            <i class="fa-solid fa-paperclip"></i> <%=t.getAttachmentName()%>
          </a>
          <%}%>

          <%if (!isCompleted) {%>
          <form action="<%=request.getContextPath()%>/managerTasks" method="post"
                class="flex items-center gap-2 pt-2 border-t border-slate-100">
            <input type="hidden" name="action" value="updateStatus">
            <input type="hidden" name="taskId" value="<%=t.getId()%>">
            <select name="decision" required
              class="flex-1 text-xs px-3 py-2 rounded-lg border border-slate-200 bg-slate-50 focus:outline-none focus:ring-2 focus:ring-indigo-400">
              <option value="">Select action…</option>
              <%if (needsReview) {%><option value="review">↩ Return to Employee</option><%}%>
              <option value="completed">✓ Mark as Completed</option>
            </select>
            <button type="submit"
              class="px-4 py-2 text-xs bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-semibold transition-colors">
              Apply
            </button>
          </form>
          <%}%>
        </div>
        <%}}%>
      </div>
    </div>

  </div>
</div>

<script>
// ── Team filter ─────────────────────────────────────────────────
function filterByTeam(team, btn) {
  document.querySelectorAll('.team-btn').forEach(function(b) {
    b.classList.remove('active');
  });
  btn.classList.add('active');

  var rows = document.querySelectorAll('.emp-row');
  var visible = 0;
  rows.forEach(function(row) {
    var match = team === 'all' || row.dataset.team === team;
    row.classList.toggle('hidden-by-team', !match);
    if (match) visible++;
  });

  // Update count label
  var label = document.getElementById('empCountLabel');
  if (label) {
    label.textContent = team === 'all'
      ? '(' + visible + ' employees)'
      : '(' + visible + ' in ' + team + ' team)';
  }

  // Uncheck hidden employees so they are not accidentally submitted
  document.querySelectorAll('.emp-row.hidden-by-team .emp-checkbox:checked').forEach(function(cb) {
    cb.checked = false;
  });
  updateEmpLabel();
}

// ── Feed filter ─────────────────────────────────────────────────
var TAB_CLS = { all:'f-all', WEEK:'f-week', ASSIGNED:'f-assigned', REVIEW:'f-processing', COMPLETED:'f-completed' };

function filterFeed(key, btn) {
  document.querySelectorAll('.ftab').forEach(function(t){ t.className = 'ftab'; });
  btn.classList.add(TAB_CLS[key] || 'f-all');
  var cards = document.querySelectorAll('.task-card');
  var visible = 0;
  cards.forEach(function(c) {
    var show = key === 'all' ? true : key === 'WEEK' ? c.dataset.week === '1' : c.dataset.filter === key;
    c.style.display = show ? '' : 'none';
    if (show) visible++;
  });
  var feed = document.getElementById('taskFeed');
  var empty = document.getElementById('feedEmpty');
  if (visible === 0 && !empty) {
    var el = document.createElement('div');
    el.id = 'feedEmpty';
    el.className = 'bg-white rounded-xl border border-slate-200 px-6 py-10 text-center text-slate-400 text-sm';
    el.innerHTML = '<i class="fa-solid fa-filter-circle-xmark text-3xl mb-2 block"></i>No tasks match this filter.';
    feed.appendChild(el);
  } else if (visible > 0 && empty) { empty.remove(); }
}

// ── Count pills ─────────────────────────────────────────────────
(function initCounts() {
  var counts = { all:0, WEEK:0, ASSIGNED:0, REVIEW:0, COMPLETED:0 };
  document.querySelectorAll('.task-card').forEach(function(c) {
    counts.all++;
    if (c.dataset.week === '1') counts.WEEK++;
    var k = c.dataset.filter;
    if (counts[k] != null) counts[k]++;
  });
  document.getElementById('fc-all').textContent       = counts.all;
  document.getElementById('fc-week').textContent      = counts.WEEK;
  document.getElementById('fc-assigned').textContent  = counts.ASSIGNED;
  document.getElementById('fc-review').textContent    = counts.REVIEW;
  document.getElementById('fc-completed').textContent = counts.COMPLETED;

  // Set initial employee count label
  var label = document.getElementById('empCountLabel');
  if (label) {
    var total = document.querySelectorAll('.emp-row').length;
    if (total > 0) label.textContent = '(' + total + ' employees)';
  }

  // Default: This Week tab
  filterFeed('WEEK', document.getElementById('tabWeek'));
})();

// ── Employee dropdown ───────────────────────────────────────────
function toggleEmpDropdown() {
  var panel   = document.getElementById('empDropdownPanel');
  var chevron = document.getElementById('empChevron');
  var open    = !panel.classList.contains('hidden');
  panel.classList.toggle('hidden', open);
  chevron.style.transform = open ? 'rotate(0deg)' : 'rotate(180deg)';
}
document.addEventListener('click', function(e) {
  var w = document.getElementById('empDropdownWrapper');
  if (w && !w.contains(e.target)) {
    document.getElementById('empDropdownPanel').classList.add('hidden');
    document.getElementById('empChevron').style.transform = 'rotate(0deg)';
  }
});
function updateEmpLabel() {
  var checked = document.querySelectorAll('.emp-checkbox:checked');
  var label   = document.getElementById('empDropdownLabel');
  var val     = document.getElementById('empValidation');
  if (checked.length === 0) {
    label.textContent = 'Select employees…'; label.className = 'text-slate-400 text-sm'; val.value = '';
  } else if (checked.length === 1) {
    var nameEl = checked[0].closest('label').querySelector('.emp-name');
    label.textContent = nameEl ? nameEl.textContent.trim() : checked[0].value;
    label.className = 'text-slate-800 text-sm'; val.value = 'ok';
  } else {
    label.textContent = checked.length + ' employees selected';
    label.className = 'text-slate-800 text-sm'; val.value = 'ok';
  }
}
document.getElementById('assignTaskForm').addEventListener('submit', function(e) {
  if (!document.querySelectorAll('.emp-checkbox:checked').length) {
    e.preventDefault();
    document.getElementById('empDropdownPanel').classList.remove('hidden');
    document.getElementById('empChevron').style.transform = 'rotate(180deg)';
    var btn = document.querySelector('#empDropdownWrapper button');
    btn.classList.add('border-red-400','ring-2','ring-red-300');
    setTimeout(function(){ btn.classList.remove('border-red-400','ring-2','ring-red-300'); }, 2000);
  }
});

// ── Toast ───────────────────────────────────────────────────────
function showToast(msg, ok) {
  var el = document.getElementById('toast');
  el.className = 'fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg text-sm font-medium max-w-xs '
    + (ok ? 'bg-emerald-600 text-white' : 'bg-red-600 text-white');
  el.textContent = msg; el.classList.remove('hidden');
  setTimeout(function(){ el.classList.add('hidden'); }, 3800);
}
(function() {
  var p = new URLSearchParams(window.location.search);
  var flash = p.get('taskFlash');
  if (flash === 'review')                showToast('Task returned — employee can resubmit.', true);
  else if (flash === 'completed')        showToast('Task marked as completed!', true);
  else if (flash === 'alreadyCompleted') showToast('Task was already completed.', true);
  var s = p.get('success'); if (s) showToast(decodeURIComponent(s.replace(/\+/g,' ')), true);
  var err = p.get('error'); if (err) showToast(decodeURIComponent(err.replace(/\+/g,' ')), false);
  if (flash||s||err) {
    p.delete('taskFlash'); p.delete('success'); p.delete('error');
    var q = p.toString();
    window.history.replaceState({}, '', window.location.pathname + (q ? '?'+q : ''));
  }
})();
</script>
</body>
</html>
