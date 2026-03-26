<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%
List<Task> tasks   = (List<Task>) request.getAttribute("tasks");
List<Team> teams   = (List<Team>) request.getAttribute("teams");
if (tasks  == null) tasks  = java.util.Collections.emptyList();
if (teams  == null) teams  = java.util.Collections.emptyList();
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
  .team-card:hover { border-color: #6366f1; box-shadow: 0 4px 14px rgba(99,102,241,.15); transform: translateY(-1px); }
  .team-card.selected { border-color: #6366f1; background: #fafafe; box-shadow: 0 4px 18px rgba(99,102,241,.18); }
  .team-icon { width: 38px; height: 38px; border-radius: 10px; background: #eef2ff; display: flex; align-items: center; justify-content: center; color: #6366f1; font-size: 16px; }

  /* ── Member chips ── */
  .member-chip {
    display: flex; align-items: center; gap: 10px;
    background: white; border: 1.5px solid #e2e8f0; border-radius: 50px;
    padding: 8px 16px 8px 8px; cursor: pointer; transition: all .15s ease;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
  }
  .member-chip:hover { border-color: #6366f1; background: #f5f3ff; }
  .member-chip.selected { border-color: #6366f1; background: #eef2ff; color: #4338ca; }
  .avatar {
    width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #6366f1, #8b5cf6);
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
  .filter-tab:hover            { border-color: #6366f1; color: #6366f1; }
  .filter-tab.ft-all           { background: #6366f1; color: white; border-color: #6366f1; }
  .filter-tab.ft-completed     { background: #dcfce7; color: #166534; border-color: #86efac; }
  .filter-tab.ft-incomplete    { background: #fef3c7; color: #92400e; border-color: #fcd34d; }
  .filter-tab.ft-docverify     { background: #ede9fe; color: #6d28d9; border-color: #c4b5fd; }
  .filter-tab.ft-error         { background: #fee2e2; color: #b91c1c; border-color: #fca5a5; }
  .cpill { background: rgba(0,0,0,.1); border-radius: 9999px; padding: 0 7px; font-size: 11px; font-weight: 600; }

  /* ── Panels ── */
  .panel { animation: fadeSlide .2s ease; }
  @keyframes fadeSlide { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

  /* ── Priority dot ── */
  .prio-high   { color: #ef4444; }
  .prio-medium { color: #f59e0b; }
  .prio-low    { color: #22c55e; }

  /* ── Section header ── */
  .section-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .07em; color: #94a3b8; margin-bottom: 10px; }
</style>
</head>
<body class="p-6">

<!-- ════════════════════════════════════════════════
     JSON DATA ISLAND  –  rendered once server-side
     ════════════════════════════════════════════════ -->
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
    {"email":"<%=escapeJson(m.getEmail())%>","name":"<%=escapeJson(fn)%>","role":"<%=escapeJson(m.getRole() != null ? m.getRole() : "")%>"}
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

<!-- ════════════ PAGE SHELL ════════════ -->
<div class="max-w-7xl mx-auto">

  <!-- Header -->
  <div class="flex flex-wrap justify-between items-start gap-4 mb-6">
    <div>
      <h2 class="text-2xl font-semibold text-slate-800 flex items-center gap-2">
        <i class="fa-solid fa-list-check text-indigo-500"></i> Tasks
      </h2>
      <p class="text-slate-500 text-sm mt-0.5">Browse by team, then select a member to view their tasks.</p>
    </div>
  </div>

  <!-- Breadcrumb -->
  <div id="breadcrumb" class="flex items-center gap-2 text-sm mb-5 flex-wrap">
    <button onclick="gotoTeams()" class="text-indigo-600 font-medium hover:underline">All Teams</button>
    <span class="crumb-sep" id="bc-sep1" style="display:none">›</span>
    <span id="bc-team"  class="text-slate-500 font-medium" style="display:none"></span>
    <span class="crumb-sep" id="bc-sep2" style="display:none">›</span>
    <span id="bc-member" class="text-slate-700 font-semibold" style="display:none"></span>
  </div>

  <!-- ─── PANEL 1 : Teams ─── -->
  <div id="panel-teams" class="panel">
    <p class="section-label">Select a team</p>
    <div id="teams-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4"></div>
    <div id="no-teams" class="hidden px-4 py-10 text-center text-slate-400 text-sm italic bg-white rounded-xl border border-slate-200">
      No teams found.
    </div>
  </div>

  <!-- ─── PANEL 2 : Members ─── -->
  <div id="panel-members" class="panel hidden">
    <p class="section-label">Select a member</p>
    <div id="members-wrap" class="flex flex-wrap gap-3"></div>
  </div>

  <!-- ─── PANEL 3 : Tasks ─── -->
  <div id="panel-tasks" class="panel hidden">

    <!-- member summary bar -->
    <div id="member-bar" class="flex items-center gap-3 mb-5 bg-white border border-slate-200 rounded-xl px-4 py-3 shadow-sm">
      <div id="member-bar-avatar" class="avatar text-base w-10 h-10">?</div>
      <div>
        <div id="member-bar-name" class="font-semibold text-slate-800 text-sm"></div>
        <div id="member-bar-email" class="text-slate-400 text-xs font-mono"></div>
      </div>
      <div class="ml-auto flex items-center gap-2">
        <span id="member-bar-total" class="text-xs text-slate-500 font-medium"></span>
      </div>
    </div>

    <!-- status filter tabs -->
    <div class="flex flex-wrap gap-2 mb-4">
      <button class="filter-tab ft-all"      onclick="filterTasks('all',  this)"><i class="fa-solid fa-border-all text-xs"></i> All <span class="cpill" id="cnt-all">0</span></button>
      <button class="filter-tab"             onclick="filterTasks('COMPLETED', this)"><i class="fa-solid fa-circle-check text-xs"></i> Completed <span class="cpill" id="cnt-completed">0</span></button>
      <button class="filter-tab"             onclick="filterTasks('INCOMPLETE', this)"><i class="fa-solid fa-clock text-xs"></i> Incomplete <span class="cpill" id="cnt-incomplete">0</span></button>
      <button class="filter-tab"             onclick="filterTasks('DOCUMENT_VERIFICATION', this)"><i class="fa-solid fa-file-circle-check text-xs"></i> Doc Verification <span class="cpill" id="cnt-docverify">0</span></button>
      <button class="filter-tab"             onclick="filterTasks('ERRORS_RAISED', this)"><i class="fa-solid fa-triangle-exclamation text-xs"></i> Errors Raised <span class="cpill" id="cnt-error">0</span></button>
    </div>

    <!-- empty filter message -->
    <div id="empty-filter-msg" class="hidden px-4 py-8 text-center text-slate-400 text-sm italic bg-white rounded-xl border border-slate-200 shadow-sm mb-4">
      No tasks match this filter.
    </div>

    <!-- table -->
    <div id="table-wrap" class="overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
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

    <!-- empty member tasks -->
    <div id="empty-member-tasks" class="hidden px-4 py-10 text-center text-slate-400 text-sm italic bg-white rounded-xl border border-slate-200 shadow-sm">
      This member has no tasks assigned.
    </div>
  </div>

</div><!-- /max-w -->

<script>
// ── Data from server ──────────────────────────────────
const TEAMS = JSON.parse(document.getElementById('teams-data').textContent);
const TASKS = JSON.parse(document.getElementById('tasks-data').textContent);

// Build a dual-key lookup: index by BOTH email and full-name (lower-cased)
// because the DB assignedTo column may store either a full name or an email.
const tasksByKey = {};
TASKS.forEach(function(t) {
  var k = (t.assignedTo || '').trim().toLowerCase();
  if (!k) return;
  if (!tasksByKey[k]) tasksByKey[k] = [];
  tasksByKey[k].push(t);
});
function getTasksForMember(m) {
  var byEmail = tasksByKey[(m.email || '').trim().toLowerCase()] || [];
  var byName  = tasksByKey[(m.name  || '').trim().toLowerCase()] || [];
  var seen = {}, merged = [];
  byEmail.concat(byName).forEach(function(t) {
    if (!seen[t.id]) { seen[t.id] = true; merged.push(t); }
  });
  return merged;
}

// ── State ─────────────────────────────────────────────
let selectedTeam   = null;
let selectedMember = null;
let activeFilter   = 'all';

// ── Init ──────────────────────────────────────────────
renderTeams();

function renderTeams() {
  const grid = document.getElementById('teams-grid');
  grid.innerHTML = '';

  if (!TEAMS.length) {
    document.getElementById('no-teams').classList.remove('hidden');
    return;
  }

  TEAMS.forEach(team => {
    const memberCount = team.members.length;
    const card = document.createElement('div');
    card.className = 'team-card';
    card.innerHTML =
      '<div class="flex items-start gap-3">' +
        '<div class="team-icon"><i class="fa-solid fa-people-group"></i></div>' +
        '<div class="flex-1 min-w-0">' +
          '<div class="font-semibold text-slate-800 text-sm truncate">' + esc(team.name) + '</div>' +
          '<div class="text-xs text-slate-400 mt-0.5 truncate">' +
            '<i class="fa-solid fa-user-tie mr-1"></i>' + esc(team.manager) +
          '</div>' +
        '</div>' +
      '</div>' +
      '<div class="flex items-center gap-3 mt-1 pt-2 border-t border-slate-100">' +
        '<span class="text-xs text-slate-500"><i class="fa-solid fa-users mr-1 text-indigo-400"></i>' + memberCount + ' member' + (memberCount != 1 ? 's' : '') + '</span>' +
        '<span class="text-xs text-indigo-500 ml-auto font-medium">View \u2192</span>' +
      '</div>';
    card.onclick = () => selectTeam(team, card);
    grid.appendChild(card);
  });
}

function selectTeam(team, cardEl) {
  selectedTeam = team;
  selectedMember = null;

  // Update breadcrumb
  document.getElementById('bc-team').textContent = team.name;
  show('bc-sep1'); show('bc-team');
  hide('bc-sep2'); hide('bc-member');

  // Switch panels
  hide('panel-teams');
  show('panel-members');
  hide('panel-tasks');

  renderMembers(team);
}

function renderMembers(team) {
  const wrap = document.getElementById('members-wrap');
  wrap.innerHTML = '';

  if (!team.members.length) {
    wrap.innerHTML = '<p class="text-slate-400 text-sm italic">No members in this team.</p>';
    return;
  }

  team.members.forEach(m => {
    const initials = getInitials(m.name);
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

  // Breadcrumb
  document.getElementById('bc-member').textContent = member.name;
  show('bc-sep2'); show('bc-member');

  // Show panel
  show('panel-tasks');
  hide('panel-members');

  renderMemberTasks(member);
}

function renderMemberTasks(member) {
  const memberTasks = getTasksForMember(member);

  // Member bar
  document.getElementById('member-bar-avatar').textContent = getInitials(member.name);
  document.getElementById('member-bar-name').textContent   = member.name;
  document.getElementById('member-bar-email').textContent  = member.email;
  document.getElementById('member-bar-total').textContent  = memberTasks.length + ' task' + (memberTasks.length != 1 ? 's' : '');

  // Counts
  const counts = { all: 0, COMPLETED: 0, INCOMPLETE: 0, DOCUMENT_VERIFICATION: 0, ERRORS_RAISED: 0 };
  memberTasks.forEach(t => { counts.all++; if (counts[t.status] !== undefined) counts[t.status]++; });
  document.getElementById('cnt-all').textContent       = counts.all;
  document.getElementById('cnt-completed').textContent = counts.COMPLETED;
  document.getElementById('cnt-incomplete').textContent= counts.INCOMPLETE;
  document.getElementById('cnt-docverify').textContent = counts.DOCUMENT_VERIFICATION;
  document.getElementById('cnt-error').textContent     = counts.ERRORS_RAISED;

  // Reset filter tabs
  activeFilter = 'all';
  document.querySelectorAll('.filter-tab').forEach(t => t.className = 'filter-tab');
  document.querySelector('.filter-tab').className = 'filter-tab ft-all';

  // Build table rows
  const tbody = document.getElementById('task-table-body');
  tbody.innerHTML = '';

  if (!memberTasks.length) {
    hide('table-wrap');
    show('empty-member-tasks');
    hide('empty-filter-msg');
    return;
  }

  show('table-wrap');
  hide('empty-member-tasks');
  hide('empty-filter-msg');

  memberTasks.forEach((t, i) => {
    const { stClass, stText } = statusMeta(t.status);
    const prioIcon = prioDot(t.priority);
    const attCell  = t.attachment
      ? '<a href="' + t.taskUrl + '" class="text-indigo-600 hover:underline text-xs" target="_blank">' + esc(t.attachment) + '</a>'
      : '<span class="text-slate-300 text-xs italic">\u2014</span>';

    const tr = document.createElement('tr');
    tr.className = 'task-row border-b border-slate-100 hover:bg-slate-50 text-sm';
    tr.dataset.status = t.status;
    tr.innerHTML =
      '<td class="px-4 py-3 text-slate-400 text-xs row-num">' + (i + 1) + '</td>' +
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

// ── Filter ────────────────────────────────────────────
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
    const show = status === 'all' || row.dataset.status === status;
    row.style.display = show ? '' : 'none';
    if (show) { visible++; row.querySelector('.row-num').textContent = visible; }
  });

  document.getElementById('empty-filter-msg').classList.toggle('hidden', visible > 0);
  document.getElementById('table-wrap').style.display = visible === 0 ? 'none' : '';
}

// ── Navigation helpers ────────────────────────────────
function gotoTeams() {
  hide('panel-members'); hide('panel-tasks');
  show('panel-teams');
  hide('bc-sep1'); hide('bc-team'); hide('bc-sep2'); hide('bc-member');
  selectedTeam = null; selectedMember = null;
  document.querySelectorAll('.team-card').forEach(c => c.classList.remove('selected'));
}

function gotoMembers() {
  if (!selectedTeam) return;
  hide('panel-tasks');
  show('panel-members');
  hide('bc-sep2'); hide('bc-member');
  selectedMember = null;
}

// Click team name in breadcrumb also goes to members
document.getElementById('bc-team').addEventListener('click', gotoMembers);
document.getElementById('bc-team').style.cursor = 'pointer';

// ── Helpers ───────────────────────────────────────────
function show(id) { document.getElementById(id).classList.remove('hidden'); document.getElementById(id).style.display = ''; }
function hide(id) { document.getElementById(id).classList.add('hidden'); }

function esc(str) {
  if (!str) return '';
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function getInitials(name) {
  if (!name) return '?';
  const parts = name.trim().split(/\s+/);
  return (parts[0][0] + (parts[1] ? parts[1][0] : '')).toUpperCase();
}

function statusMeta(s) {
  switch ((s || '').toUpperCase()) {
    case 'COMPLETED':             return { stClass: 'bs-completed',  stText: 'Completed' };
    case 'DOCUMENT_VERIFICATION': return { stClass: 'bs-docverify',  stText: 'Doc Verification' };
    case 'ERRORS_RAISED':         return { stClass: 'bs-error',      stText: 'Errors Raised' };
    case 'ASSIGNED':              return { stClass: 'bs-assigned',   stText: 'Assigned' };
    default:                      return { stClass: 'bs-incomplete', stText: 'Incomplete' };
  }
}

function prioDot(p) {
  if (!p) return { icon: '', cls: 'text-slate-400' };
  switch (p.toUpperCase()) {
    case 'HIGH':   return { icon: '<i class="fa-solid fa-circle-up"></i>',    cls: 'prio-high' };
    case 'MEDIUM': return { icon: '<i class="fa-solid fa-circle-minus"></i>',  cls: 'prio-medium' };
    case 'LOW':    return { icon: '<i class="fa-solid fa-circle-down"></i>',   cls: 'prio-low' };
    default:       return { icon: '', cls: 'text-slate-400' };
  }
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
