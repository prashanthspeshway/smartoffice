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
<title>Teams • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body { font-family: 'Inter', system-ui, sans-serif; }</style>
<style>
/* Toast */
.toast {
  position: fixed;
  top: 24px;
  right: 24px;
  padding: 14px 20px;
  border-radius: 8px;
  z-index: 9999;
  display: none;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 10px 40px -10px rgba(0,0,0,0.2);
  animation: slideIn 0.3s ease;
}
@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}
.toast.success { background: #10b981; color: white; }
.toast.error { background: #ef4444; color: white; }
</style>
</head>
<body class="bg-slate-100 min-h-screen">

<div id="toast" class="toast" data-success="<%= safeSuccess %>" data-error="<%= safeError %>"></div>

<div class="max-w-6xl mx-auto p-6">
  <header class="mb-8">
    <h1 class="text-2xl font-semibold text-slate-800 flex items-center gap-2 mb-2"><i class="fa-solid fa-people-group text-indigo-500"></i> Team Management</h1>
    <p class="text-slate-500 text-sm">Create teams, assign managers, and add employees</p>
  </header>

  <!-- Stats cards -->
  <div class="flex gap-4 mb-8 flex-wrap">
    <div class="bg-white rounded-xl border border-slate-200 px-6 py-4 shadow-sm min-w-[140px]">
      <div class="text-2xl font-bold text-slate-800"><%= teams.size() %></div>
      <div class="text-xs text-slate-500 uppercase tracking-wider font-medium mt-1">Teams</div>
    </div>
    <div class="bg-white rounded-xl border border-slate-200 px-6 py-4 shadow-sm min-w-[140px]">
      <div class="text-2xl font-bold text-slate-800"><%= totalMembers %></div>
      <div class="text-xs text-slate-500 uppercase tracking-wider font-medium mt-1">Total Members</div>
    </div>
    <div class="bg-white rounded-xl border border-slate-200 px-6 py-4 shadow-sm min-w-[140px]">
      <div class="text-2xl font-bold text-slate-800"><%= availableCount %></div>
      <div class="text-xs text-slate-500 uppercase tracking-wider font-medium mt-1">Available</div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Create Team -->
    <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
      <h2 class="text-lg font-semibold text-slate-800 flex items-center gap-2 mb-5"><i class="fa-solid fa-plus text-indigo-500"></i> Create Team</h2>
      <form action="<%= request.getContextPath() %>/teams" method="post">
        <input type="hidden" name="action" value="create">
        <div class="mb-4">
          <label class="block text-sm font-medium text-slate-700 mb-2">Team Name</label>
          <input type="text" name="teamName" required placeholder="e.g. Development Team" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium text-slate-700 mb-2">Assign Manager</label>
          <select name="managerUsername" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
            <option value="">Select Manager</option>
            <% for (User m : managers) { %>
            <option value="<%= m.getEmail() %>"><%= m.getFullname() != null ? m.getFullname() : m.getEmail() %></option>
            <% } %>
          </select>
        </div>
        <button type="submit" class="inline-flex items-center gap-2 px-5 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors"><i class="fa-solid fa-plus"></i> Create Team</button>
      </form>
    </div>

    <!-- Add Members -->
    <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
      <h2 class="text-lg font-semibold text-slate-800 flex items-center gap-2 mb-5"><i class="fa-solid fa-user-plus text-indigo-500"></i> Add Employees</h2>
      <form id="addMemberForm" action="<%= request.getContextPath() %>/teams" method="post">
        <input type="hidden" name="action" value="addMember">
        <div class="space-y-4">
          <div class="flex gap-3 items-end flex-wrap">
            <div class="flex-1 min-w-[180px]">
              <label class="block text-sm font-medium text-slate-700 mb-1.5">Team</label>
              <select name="teamId" id="teamSelect" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                <option value="">Select Team</option>
                <% for (Team t : teams) { %>
                <option value="<%= t.getId() %>"><%= t.getName() %></option>
                <% } %>
              </select>
            </div>
            <button type="submit" class="inline-flex items-center gap-2 px-5 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors shrink-0"><i class="fa-solid fa-arrow-right"></i> Add</button>
          </div>
          <div class="border border-slate-200 rounded-lg overflow-hidden bg-slate-50">
            <div class="px-4 py-2 text-sm font-medium text-slate-700 bg-white border-b border-slate-200">Employees <span class="font-normal text-slate-500">(assigned are faded)</span></div>
            <div class="p-3 border-b border-slate-200 bg-white">
              <div class="relative">
                <i class="fa-solid fa-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                <input type="text" id="employeeSearch" placeholder="Search name or username..." autocomplete="off" class="w-full pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
              </div>
            </div>
            <div class="employee-list max-h-[220px] overflow-y-auto p-3" id="employeeCheckboxList">
              <% for (User e : employees) {
                boolean assigned = assignedUsernames.contains(e.getEmail());
                String displayName = e.getFullname() != null ? e.getFullname() : e.getEmail();
                String searchText = (displayName + " " + e.getEmail()).toLowerCase();
              %>
              <label class="employee-item flex items-center gap-3 py-2.5 px-3 rounded-lg cursor-pointer transition-colors <%= assigned ? "opacity-50 text-slate-500 cursor-not-allowed" : "hover:bg-slate-100" %>" data-search="<%= searchText.replace("\"", "&quot;") %>">
                <input type="checkbox" name="username" value="<%= e.getEmail() %>" class="w-4 h-4 rounded border-slate-300 text-indigo-500 focus:ring-indigo-500" <%= assigned ? "disabled" : "" %>>
                <span class="text-sm font-medium text-slate-700"><%= displayName %><% if (assigned) { %><span class="text-slate-400 font-normal ml-1">(assigned)</span><% } %></span>
              </label>
              <% } %>
              <p class="no-results py-4 text-center text-slate-500 text-sm" id="employeeNoResults" style="display:none;">No matches</p>
              <% if (employees.isEmpty()) { %>
              <p class="no-results py-4 text-center text-slate-500 text-sm" id="employeeEmpty">No employees</p>
              <% } %>
            </div>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- All Teams -->
  <section class="mt-8">
    <div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-slate-800 flex items-center gap-2"><i class="fa-solid fa-layer-group text-indigo-500"></i> All Teams</h2>
      </div>

      <% if (teams.isEmpty()) { %>
      <div class="text-center py-16 text-slate-500">
        <i class="fa-solid fa-people-group text-5xl mb-4 block opacity-40"></i>
        <p class="font-medium text-slate-600">No teams yet</p>
        <p class="text-sm mt-1">Create your first team above</p>
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
          <div class="text-sm text-slate-500 mb-4">
            <%= t.getMembers().size() %> member<%= t.getMembers().size() != 1 ? "s" : "" %>
          </div>
          <div class="mb-4">
            <div class="text-xs font-medium text-slate-500 mb-2">Members</div>
            <div class="flex flex-wrap gap-2">
              <% for (User mem : t.getMembers()) { %>
              <span class="inline-flex items-center gap-1.5 bg-slate-100 px-3 py-1.5 rounded-full text-sm text-slate-700">
                <%= mem.getFullname() != null ? mem.getFullname() : mem.getEmail() %>
                <form action="<%= request.getContextPath() %>/teams" method="post" class="inline">
                  <input type="hidden" name="action" value="removeMember">
                  <input type="hidden" name="teamId" value="<%= t.getId() %>">
                  <input type="hidden" name="username" value="<%= mem.getEmail() %>">
                  <button type="submit" class="text-slate-400 hover:text-red-500 transition-colors" title="Remove"><i class="fa-solid fa-xmark text-xs"></i></button>
                </form>
              </span>
              <% } %>
              <% if (t.getMembers().isEmpty()) { %>
              <span class="text-sm text-slate-500">No members yet</span>
              <% } %>
            </div>
          </div>
          <div class="pt-4 border-t border-slate-200">
            <form action="<%= request.getContextPath() %>/teams" method="post" class="inline">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="teamId" value="<%= t.getId() %>">
              <button type="submit" class="inline-flex items-center gap-2 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg text-sm font-medium transition-colors" onclick="return confirm('Delete this team?');"><i class="fa-solid fa-trash"></i> Delete</button>
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
