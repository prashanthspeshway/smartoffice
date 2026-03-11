<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>

<%
String successMsg = (String) session.getAttribute("teamsSuccess");
String errorMsg = (String) session.getAttribute("teamsError");
session.removeAttribute("teamsSuccess");
session.removeAttribute("teamsError");

List<Team> teams = (List<Team>) request.getAttribute("teams");
List<User> managers = (List<User>) request.getAttribute("managers");
List<User> employees = (List<User>) request.getAttribute("employees");
if (teams == null) teams = new java.util.ArrayList<>();
if (managers == null) managers = new java.util.ArrayList<>();
if (employees == null) employees = new java.util.ArrayList<>();
Set<String> assignedUsernames = (Set<String>) request.getAttribute("assignedUsernames");
if (assignedUsernames == null) assignedUsernames = new java.util.HashSet<>();
int totalMembers = 0;
for (Team t : teams) { totalMembers += t.getMembers().size(); }
int availableCount = 0;
for (User e : employees) {
  if (!assignedUsernames.contains(e.getEmail())) availableCount++;
}
%>

<%
String safeSuccess = (successMsg != null) ? successMsg.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;") : "";
String safeError = (errorMsg != null) ? errorMsg.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;") : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Teams • Smart Office</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --bg: #f1f5f9;
  --card: #ffffff;
  --card-border: #e2e8f0;
  --text: #0f172a;
  --text-muted: #64748b;
  --accent: #0ea5e9;
  --accent-hover: #0284c7;
  --success: #10b981;
  --danger: #ef4444;
  --danger-hover: #dc2626;
  --radius: 12px;
  --radius-sm: 8px;
  --shadow: 0 1px 3px rgba(0,0,0,0.06);
  --shadow-lg: 0 10px 40px -10px rgba(0,0,0,0.12);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
  line-height: 1.5;
}

.page {
  max-width: 1280px;
  margin: 0 auto;
  padding: 32px 24px;
}

/* Header */
.page-header {
  margin-bottom: 32px;
}
.page-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--text);
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}
.page-title i { color: var(--accent); }
.page-subtitle { font-size: 14px; color: var(--text-muted); }

/* Stats row */
.stats-row {
  display: flex;
  gap: 16px;
  margin-bottom: 28px;
  flex-wrap: wrap;
}
.stat-card {
  background: var(--card);
  border: 1px solid var(--card-border);
  border-radius: var(--radius);
  padding: 16px 20px;
  min-width: 140px;
  box-shadow: var(--shadow);
}
.stat-card .value { font-size: 24px; font-weight: 700; color: var(--text); }
.stat-card .label { font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px; }

/* Grid layout */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
@media (max-width: 900px) { .grid-2 { grid-template-columns: 1fr; } }

/* Cards */
.card {
  background: var(--card);
  border: 1px solid var(--card-border);
  border-radius: var(--radius);
  padding: 24px;
  box-shadow: var(--shadow);
}
.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.card-title i { color: var(--accent); font-size: 18px; }

/* Forms */
.form-group { margin-bottom: 16px; }
.form-group:last-of-type { margin-bottom: 0; }
.form-group label {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: var(--text);
  margin-bottom: 6px;
}
.form-group input,
.form-group select {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--card-border);
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-family: inherit;
  background: var(--card);
  transition: border-color 0.2s, box-shadow 0.2s;
}
.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.15);
}
.form-row { display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap; }
.form-row .form-group { flex: 1; min-width: 160px; margin-bottom: 0; }

/* Buttons */
.btn {
  padding: 12px 20px;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}
.btn-primary {
  background: linear-gradient(135deg, var(--accent), #0284c7);
  color: white;
}
.btn-primary:hover { opacity: 0.95; transform: translateY(-1px); }
.btn-danger {
  background: var(--danger);
  color: white;
  padding: 8px 14px;
  font-size: 13px;
}
.btn-danger:hover { background: var(--danger-hover); }
.btn-ghost {
  background: transparent;
  color: var(--text-muted);
  padding: 6px 10px;
}
.btn-ghost:hover { background: #f1f5f9; color: var(--text); }

/* Add members section - stacked to prevent overlap */
.add-members-layout {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.add-members-row {
  display: flex;
  gap: 16px;
  align-items: flex-end;
  flex-wrap: wrap;
}
.add-members-row .team-select-wrap { flex: 0 0 200px; min-width: 160px; }
.add-members-row .add-btn-wrap { flex-shrink: 0; }

.employee-panel {
  border: 1px solid var(--card-border);
  border-radius: var(--radius-sm);
  background: #fafafa;
  overflow: hidden;
  min-height: 0;
}
.employee-panel-label {
  padding: 12px 14px 0;
  font-size: 13px;
  font-weight: 500;
  color: var(--text);
}
.employee-panel-label .muted { color: var(--text-muted); font-weight: 400; }
.employee-search {
  padding: 10px 14px;
  border-bottom: 1px solid var(--card-border);
  position: relative;
}
.employee-search input {
  width: 100%;
  padding: 10px 12px 10px 36px;
  border: none;
  background: var(--card);
  border-radius: var(--radius-sm);
  font-size: 13px;
}
.employee-search .fa-search {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
  font-size: 13px;
}
.employee-list {
  height: 200px;
  min-height: 120px;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 8px;
  box-sizing: border-box;
}
.employee-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  margin-bottom: 4px;
  cursor: pointer;
  transition: background 0.15s;
}
.employee-item:hover:not(.assigned) { background: #e2e8f0; }
.employee-item.assigned {
  opacity: 0.5;
  color: var(--text-muted);
  cursor: not-allowed;
}
.employee-item input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: var(--accent);
}
.employee-item.assigned input { cursor: not-allowed; }
.employee-item .name { font-size: 14px; font-weight: 500; }
.employee-item .badge { font-size: 11px; color: var(--text-muted); margin-left: 4px; }
.no-results { padding: 20px; text-align: center; color: var(--text-muted); font-size: 13px; }

/* Team select in add form */
.team-select-wrap select {
  height: 44px;
  padding: 10px 14px;
}

/* Teams grid */
.teams-section { margin-top: 32px; }
.teams-section .card { padding: 28px; }
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.section-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--text);
  display: flex;
  align-items: center;
  gap: 10px;
}
.section-title i { color: var(--accent); }

.teams-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 20px;
}
.team-card {
  background: var(--card);
  border: 1px solid var(--card-border);
  border-radius: var(--radius);
  padding: 20px;
  box-shadow: var(--shadow);
  transition: box-shadow 0.2s, border-color 0.2s;
}
.team-card:hover {
  box-shadow: var(--shadow-lg);
  border-color: #cbd5e1;
}
.team-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}
.team-name {
  font-size: 17px;
  font-weight: 600;
  color: var(--text);
  display: flex;
  align-items: center;
  gap: 8px;
}
.team-name i { color: var(--accent); font-size: 16px; }
.team-manager-select {
  padding: 6px 10px;
  font-size: 12px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--card-border);
  background: var(--card);
  min-width: 100px;
}
.team-meta {
  font-size: 13px;
  color: var(--text-muted);
  margin-bottom: 16px;
}
.team-members-wrap {
  margin-bottom: 16px;
}
.team-members-label { font-size: 12px; font-weight: 500; color: var(--text-muted); margin-bottom: 8px; }
.member-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.member-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #f1f5f9;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  color: var(--text);
}
.member-pill .remove {
  background: none;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  font-size: 12px;
}
.member-pill .remove:hover { color: var(--danger); }
.team-actions { margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--card-border); }
.empty-state {
  text-align: center;
  padding: 48px 24px;
  color: var(--text-muted);
}
.empty-state i { font-size: 48px; margin-bottom: 16px; opacity: 0.4; }
.empty-state p { font-size: 15px; margin-bottom: 8px; }

/* Toast */
.toast {
  position: fixed;
  top: 24px;
  right: 24px;
  padding: 14px 20px;
  border-radius: var(--radius-sm);
  z-index: 9999;
  display: none;
  font-size: 14px;
  font-weight: 500;
  box-shadow: var(--shadow-lg);
  animation: slideIn 0.3s ease;
}
@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}
.toast.success { background: var(--success); color: white; }
.toast.error { background: var(--danger); color: white; }
</style>
</head>
<body>

<div id="toast" class="toast" data-success="<%= safeSuccess %>" data-error="<%= safeError %>"></div>

<div class="page">
  <header class="page-header">
    <h1 class="page-title"><i class="fa-solid fa-people-group"></i> Team Management</h1>
    <p class="page-subtitle">Create teams, assign managers, and add employees</p>
  </header>

  <div class="stats-row">
    <div class="stat-card">
      <div class="value"><%= teams.size() %></div>
      <div class="label">Teams</div>
    </div>
    <div class="stat-card">
      <div class="value"><%= totalMembers %></div>
      <div class="label">Total Members</div>
    </div>
    <div class="stat-card">
      <div class="value"><%= availableCount %></div>
      <div class="label">Available</div>
    </div>
  </div>

  <div class="grid-2">
    <!-- Create Team -->
    <div class="card">
      <h2 class="card-title"><i class="fa-solid fa-plus-circle"></i> Create Team</h2>
      <form action="<%= request.getContextPath() %>/teams" method="post">
        <input type="hidden" name="action" value="create">
        <div class="form-group">
          <label>Team Name</label>
          <input type="text" name="teamName" required placeholder="e.g. Development Team">
        </div>
        <div class="form-group">
          <label>Assign Manager</label>
          <select name="managerUsername" required>
            <option value="">Select Manager</option>
            <% for (User m : managers) { %>
            <option value="<%= m.getEmail() %>"><%= m.getFullname() != null ? m.getFullname() : m.getEmail() %></option>
            <% } %>
          </select>
        </div>
        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-plus"></i> Create Team</button>
      </form>
    </div>

    <!-- Add Members -->
    <div class="card">
      <h2 class="card-title"><i class="fa-solid fa-user-plus"></i> Add Employees</h2>
      <form id="addMemberForm" action="<%= request.getContextPath() %>/teams" method="post">
        <input type="hidden" name="action" value="addMember">
        <div class="add-members-layout">
          <div class="add-members-row">
            <div class="form-group team-select-wrap">
              <label>Team</label>
              <select name="teamId" id="teamSelect" required>
                <option value="">Select Team</option>
                <% for (Team t : teams) { %>
                <option value="<%= t.getId() %>"><%= t.getName() %></option>
                <% } %>
              </select>
            </div>
            <div class="add-btn-wrap">
              <button type="submit" class="btn btn-primary"><i class="fa-solid fa-arrow-right"></i> Add</button>
            </div>
          </div>
          <div class="employee-panel">
            <div class="employee-panel-label">Employees <span class="muted">(assigned are faded)</span></div>
            <div class="employee-search">
              <i class="fa-solid fa-search"></i>
              <input type="text" id="employeeSearch" placeholder="Search name or username..." autocomplete="off">
            </div>
            <div class="employee-list" id="employeeCheckboxList">
              <% for (User e : employees) {
                boolean assigned = assignedUsernames.contains(e.getEmail());
                String displayName = e.getFullname() != null ? e.getFullname() : e.getEmail();
                String searchText = (displayName + " " + e.getEmail()).toLowerCase();
              %>
              <label class="employee-item <%= assigned ? "assigned" : "" %>" data-search="<%= searchText.replace("\"", "&quot;") %>">
                <input type="checkbox" name="username" value="<%= e.getEmail() %>" <%= assigned ? "disabled" : "" %>>
                <span class="name"><%= displayName %><% if (assigned) { %><span class="badge">(assigned)</span><% } %></span>
              </label>
              <% } %>
              <p class="no-results" id="employeeNoResults" style="display:none;">No matches</p>
              <% if (employees.isEmpty()) { %>
              <p class="no-results" id="employeeEmpty">No employees</p>
              <% } %>
            </div>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- All Teams -->
  <section class="teams-section">
    <div class="card">
      <div class="section-header">
        <h2 class="section-title"><i class="fa-solid fa-layer-group"></i> All Teams</h2>
      </div>

      <% if (teams.isEmpty()) { %>
      <div class="empty-state">
        <i class="fa-solid fa-people-group"></i>
        <p>No teams yet</p>
        <p style="font-size: 13px;">Create your first team above</p>
      </div>
      <% } else { %>
      <div class="teams-grid">
        <% for (Team t : teams) { %>
        <div class="team-card">
          <div class="team-card-header">
            <h3 class="team-name"><i class="fa-solid fa-users"></i> <%= t.getName() %></h3>
            <form action="<%= request.getContextPath() %>/teams" method="post" style="display:inline;">
              <input type="hidden" name="action" value="updateManager">
              <input type="hidden" name="teamId" value="<%= t.getId() %>">
              <select name="managerUsername" class="team-manager-select" onchange="this.form.submit()">
                <% for (User m : managers) { %>
                <option value="<%= m.getEmail() %>" <%= m.getEmail().equals(t.getManagerUsername()) ? "selected" : "" %>><%= m.getFullname() != null ? m.getFullname() : m.getEmail() %></option>
                <% } %>
              </select>
            </form>
          </div>
          <div class="team-meta">
            <%= t.getMembers().size() %> member<%= t.getMembers().size() != 1 ? "s" : "" %>
          </div>
          <div class="team-members-wrap">
            <div class="team-members-label">Members</div>
            <div class="member-pills">
              <% for (User mem : t.getMembers()) { %>
              <span class="member-pill">
                <%= mem.getFullname() != null ? mem.getFullname() : mem.getEmail() %>
                <form action="<%= request.getContextPath() %>/teams" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="removeMember">
                  <input type="hidden" name="teamId" value="<%= t.getId() %>">
                  <input type="hidden" name="username" value="<%= mem.getEmail() %>">
                  <button type="submit" class="remove" title="Remove"><i class="fa-solid fa-xmark"></i></button>
                </form>
              </span>
              <% } %>
              <% if (t.getMembers().isEmpty()) { %>
              <span style="font-size: 13px; color: var(--text-muted);">No members yet</span>
              <% } %>
            </div>
          </div>
          <div class="team-actions">
            <form action="<%= request.getContextPath() %>/teams" method="post" style="display:inline;">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="teamId" value="<%= t.getId() %>">
              <button type="submit" class="btn btn-danger" onclick="return confirm('Delete this team?');"><i class="fa-solid fa-trash"></i> Delete</button>
            </form>
          </div>
        </div>
        <% } %>
      </div>
      <% } %>
    </div>
  </section>
</div>

<script>
function showToast(msg, type) {
  var t = document.getElementById('toast');
  if (!t) return;
  t.className = 'toast ' + type;
  t.textContent = msg;
  t.style.display = 'block';
  setTimeout(function() { t.style.display = 'none'; }, 2500);
}
document.addEventListener('DOMContentLoaded', function() {
  var toast = document.getElementById('toast');
  if (toast) {
    var s = toast.getAttribute('data-success'), e = toast.getAttribute('data-error');
    if (s) showToast(s, 'success');
    if (e) showToast(e, 'error');
  }
  var form = document.getElementById('addMemberForm');
  if (form) {
    form.addEventListener('submit', function(ev) {
      var checked = form.querySelectorAll('input[name="username"]:checked');
      if (checked.length === 0) { ev.preventDefault(); showToast('Select at least one employee.', 'error'); }
    });
  }
  var search = document.getElementById('employeeSearch');
  var list = document.getElementById('employeeCheckboxList');
  var noRes = document.getElementById('employeeNoResults');
  var empty = document.getElementById('employeeEmpty');
  if (search && list) {
    search.addEventListener('input', function() {
      var q = this.value.trim().toLowerCase();
      var items = list.querySelectorAll('.employee-item');
      var n = 0;
      items.forEach(function(el) {
        var match = !q || (el.getAttribute('data-search') || '').indexOf(q) >= 0;
        el.style.display = match ? '' : 'none';
        if (match) n++;
      });
      if (noRes) noRes.style.display = (items.length > 0 && q && n === 0) ? '' : 'none';
      if (empty) empty.style.display = (items.length === 0) ? '' : 'none';
    });
  }
});
</script>
</body>
</html>
