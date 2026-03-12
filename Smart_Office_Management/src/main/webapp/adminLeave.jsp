<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%
if (session.getAttribute("username") == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}
String leaveSuccess = request.getParameter("success");
List<LeaveRequest> allLeaves = (List<LeaveRequest>) request.getAttribute("allLeaves");
long pendingCount = request.getAttribute("pendingCount") != null ? (Long) request.getAttribute("pendingCount") : 0;
long approvedCount = request.getAttribute("approvedCount") != null ? (Long) request.getAttribute("approvedCount") : 0;
long onLeaveTodayCount = request.getAttribute("onLeaveTodayCount") != null ? (Long) request.getAttribute("onLeaveTodayCount") : 0;
long rejectedCount = request.getAttribute("rejectedCount") != null ? (Long) request.getAttribute("rejectedCount") : 0;
if (allLeaves == null) allLeaves = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Leave Management • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }
.tab-btn { padding: 10px 16px; border-radius: 8px; font-weight: 500; transition: all 0.2s; }
.tab-btn.active { background: #4f46e5; color: white; }
.tab-btn:not(.active) { background: #f1f5f9; color: #64748b; }
.tab-btn:not(.active):hover { background: #e2e8f0; color: #334155; }
.leave-card { transition: all 0.2s; }
.leave-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-5xl mx-auto">
	<!-- Header -->
	<div class="flex flex-wrap justify-between items-center gap-4 mb-6">
		<div>
			<h2 class="text-2xl font-semibold text-slate-800">Leave Management</h2>
			<p class="text-slate-500 text-sm mt-0.5">Manage employee leave requests</p>
		</div>
	</div>

	<!-- Summary Cards -->
	<div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
		<div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
			<div class="flex items-center gap-3">
				<div class="w-10 h-10 rounded-lg bg-amber-100 flex items-center justify-center text-amber-600"><i class="fa-solid fa-clock"></i></div>
				<div>
					<div class="text-2xl font-bold text-slate-800"><%= pendingCount %></div>
					<div class="text-sm text-slate-500">Pending Requests</div>
				</div>
			</div>
		</div>
		<div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
			<div class="flex items-center gap-3">
				<div class="w-10 h-10 rounded-lg bg-emerald-100 flex items-center justify-center text-emerald-600"><i class="fa-solid fa-check"></i></div>
				<div>
					<div class="text-2xl font-bold text-slate-800"><%= approvedCount %></div>
					<div class="text-sm text-slate-500">Approved</div>
				</div>
			</div>
		</div>
		<div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
			<div class="flex items-center gap-3">
				<div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600"><i class="fa-solid fa-plane-departure"></i></div>
				<div>
					<div class="text-2xl font-bold text-slate-800"><%= onLeaveTodayCount %></div>
					<div class="text-sm text-slate-500">On Leave Today</div>
				</div>
			</div>
		</div>
		<div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
			<div class="flex items-center gap-3">
				<div class="w-10 h-10 rounded-lg bg-red-100 flex items-center justify-center text-red-600"><i class="fa-solid fa-times"></i></div>
				<div>
					<div class="text-2xl font-bold text-slate-800"><%= rejectedCount %></div>
					<div class="text-sm text-slate-500">Rejected</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Tabs -->
	<div class="flex flex-wrap gap-2 mb-4">
		<button type="button" class="tab-btn active" data-tab="pending" onclick="setTab('pending')">Pending (<%= pendingCount %>)</button>
		<button type="button" class="tab-btn" data-tab="approved" onclick="setTab('approved')">Approved</button>
		<button type="button" class="tab-btn" data-tab="rejected" onclick="setTab('rejected')">Rejected</button>
	</div>

	<!-- Leave List -->
	<div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
		<div id="pendingList" class="tab-content p-4 space-y-3">
			<% 
			long pCount = 0;
			for (LeaveRequest lr : allLeaves) {
				if (!"PENDING".equalsIgnoreCase(lr.getStatus())) continue;
				pCount++;
				String initials = "";
				if (lr.getDisplayName() != null && !lr.getDisplayName().isEmpty()) {
					String[] parts = lr.getDisplayName().trim().split("\\s+");
					if (parts.length >= 2) initials = parts[0].substring(0,1) + parts[parts.length-1].substring(0,1);
					else if (parts[0].length() >= 1) initials = parts[0].substring(0, Math.min(2, parts[0].length()));
				}
				if (initials.isEmpty() && lr.getUsername() != null) initials = lr.getUsername().substring(0, Math.min(2, lr.getUsername().length())).toUpperCase();
			%>
			<div class="leave-card flex items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
				<div class="w-12 h-12 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-semibold text-sm shrink-0"><%= initials.toUpperCase() %></div>
				<div class="flex-1 min-w-0">
					<div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
					<div class="text-sm text-slate-500"><%= lr.getLeaveType() %> • <%= lr.getFromDate() %> → <%= lr.getToDate() %></div>
					<div class="text-xs text-slate-400 mt-0.5">Applied on <%= lr.getAppliedAt() != null ? lr.getAppliedAt().toString().substring(0, 10) : "--" %></div>
				</div>
				<span class="px-3 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-700 shrink-0">Pending</span>
				<div class="flex gap-2 shrink-0">
					<form action="leave-approval" method="post" class="inline">
						<input type="hidden" name="leaveId" value="<%= lr.getId() %>">
						<input type="hidden" name="action" value="approve">
						<button type="submit" class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white rounded-lg text-sm font-medium"><i class="fa-solid fa-check mr-1"></i> Approve</button>
					</form>
					<form action="leave-approval" method="post" class="inline">
						<input type="hidden" name="leaveId" value="<%= lr.getId() %>">
						<input type="hidden" name="action" value="reject">
						<button type="submit" class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg text-sm font-medium"><i class="fa-solid fa-times mr-1"></i> Reject</button>
					</form>
				</div>
			</div>
			<% } %>
			<% if (pCount == 0) { %>
			<div class="text-center py-12 text-slate-500"><i class="fa-solid fa-check-circle text-4xl mb-2"></i><p>No pending leave requests</p></div>
			<% } %>
		</div>
		<div id="approvedList" class="tab-content p-4 space-y-3 hidden">
			<% for (LeaveRequest lr : allLeaves) {
				if (!"APPROVED".equalsIgnoreCase(lr.getStatus())) continue;
				String initials = "";
				if (lr.getDisplayName() != null && !lr.getDisplayName().isEmpty()) {
					String[] parts = lr.getDisplayName().trim().split("\\s+");
					if (parts.length >= 2) initials = parts[0].substring(0,1) + parts[parts.length-1].substring(0,1);
					else if (parts[0].length() >= 1) initials = parts[0].substring(0, Math.min(2, parts[0].length()));
				}
				if (initials.isEmpty() && lr.getUsername() != null) initials = lr.getUsername().substring(0, Math.min(2, lr.getUsername().length())).toUpperCase();
			%>
			<div class="leave-card flex items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
				<div class="w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-semibold text-sm shrink-0"><%= initials.toUpperCase() %></div>
				<div class="flex-1 min-w-0">
					<div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
					<div class="text-sm text-slate-500"><%= lr.getLeaveType() %> • <%= lr.getFromDate() %> → <%= lr.getToDate() %></div>
				</div>
				<span class="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-700 shrink-0">Approved</span>
			</div>
			<% } %>
			<% 
			boolean hasApproved = false;
			for (LeaveRequest lr : allLeaves) { if ("APPROVED".equalsIgnoreCase(lr.getStatus())) { hasApproved = true; break; } }
			if (!hasApproved) { %>
			<div class="text-center py-12 text-slate-500"><p>No approved requests</p></div>
			<% } %>
		</div>
		<div id="rejectedList" class="tab-content p-4 space-y-3 hidden">
			<% for (LeaveRequest lr : allLeaves) {
				if (!"REJECTED".equalsIgnoreCase(lr.getStatus())) continue;
				String initials = "";
				if (lr.getDisplayName() != null && !lr.getDisplayName().isEmpty()) {
					String[] parts = lr.getDisplayName().trim().split("\\s+");
					if (parts.length >= 2) initials = parts[0].substring(0,1) + parts[parts.length-1].substring(0,1);
					else if (parts[0].length() >= 1) initials = parts[0].substring(0, Math.min(2, parts[0].length()));
				}
				if (initials.isEmpty() && lr.getUsername() != null) initials = lr.getUsername().substring(0, Math.min(2, lr.getUsername().length())).toUpperCase();
			%>
			<div class="leave-card flex items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
				<div class="w-12 h-12 rounded-full bg-red-100 text-red-700 flex items-center justify-center font-semibold text-sm shrink-0"><%= initials.toUpperCase() %></div>
				<div class="flex-1 min-w-0">
					<div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
					<div class="text-sm text-slate-500"><%= lr.getLeaveType() %> • <%= lr.getFromDate() %> → <%= lr.getToDate() %></div>
				</div>
				<span class="px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700 shrink-0">Rejected</span>
			</div>
			<% } %>
			<% 
			boolean hasRejected = false;
			for (LeaveRequest lr : allLeaves) { if ("REJECTED".equalsIgnoreCase(lr.getStatus())) { hasRejected = true; break; } }
			if (!hasRejected) { %>
			<div class="text-center py-12 text-slate-500"><p>No rejected requests</p></div>
			<% } %>
		</div>
	</div>
</div>

<script>
function setTab(tab) {
	document.querySelectorAll('.tab-btn').forEach(b => {
		b.classList.toggle('active', b.dataset.tab === tab);
	});
	document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
	const el = document.getElementById(tab + 'List');
	if (el) el.classList.remove('hidden');
}
document.addEventListener('DOMContentLoaded', function() {
	var s = '<%= leaveSuccess != null ? leaveSuccess : "" %>';
	if (s && typeof window.parent.showToast === 'function') {
		window.parent.showToast('Leave ' + s.toLowerCase() + ' successfully');
		window.history.replaceState({}, document.title, window.location.pathname);
	}
});
</script>
</body>
</html>
