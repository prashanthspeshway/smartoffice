<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%
List<Task> tasks = (List<Task>) request.getAttribute("tasks");
if (tasks == null) tasks = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }
.badge-priority { padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 600; display:inline-flex; align-items:center; gap:4px; }
.bp-high { background:#fee2e2; color:#b91c1c; }
.bp-medium { background:#fef3c7; color:#92400e; }
.bp-low { background:#dcfce7; color:#166534; }
.badge-status { padding:4px 10px; border-radius:9999px; font-size:11px; font-weight:600; display:inline-flex; align-items:center; gap:4px; }
.bs-pending { background:#fef3c7; color:#92400e; }
.bs-progress { background:#dbeafe; color:#1d4ed8; }
.bs-done { background:#dcfce7; color:#166534; }
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-6xl mx-auto">
	<div class="flex flex-wrap justify-between items-center gap-4 mb-6">
		<div>
			<h2 class="text-2xl font-semibold text-slate-800 flex items-center gap-2">
				<i class="fa-solid fa-list-check text-indigo-500"></i> Tasks
			</h2>
			<p class="text-slate-500 text-sm mt-0.5">Read-only view of all tasks assigned in the system.</p>
		</div>
	</div>

	<div class="overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
		<table class="w-full">
			<thead>
				<tr class="bg-slate-50 border-b border-slate-200 text-sm text-slate-600">
					<th class="px-4 py-3 text-left">#</th>
					<th class="px-4 py-3 text-left">Title</th>
					<th class="px-4 py-3 text-left">Description</th>
					<th class="px-4 py-3 text-left">Priority</th>
					<th class="px-4 py-3 text-left">Status</th>
					<th class="px-4 py-3 text-left">Assigned Date</th>
					<th class="px-4 py-3 text-left">Assigned To</th>
					<th class="px-4 py-3 text-left">Assigned By</th>
				</tr>
			</thead>
			<tbody>
				<%
				if (tasks.isEmpty()) {
				%>
				<tr>
					<td colspan="8" class="px-4 py-8 text-center text-slate-500 text-sm italic">
						No tasks found.
					</td>
				</tr>
				<%
				} else {
					int idx = 1;
					for (Task t : tasks) {
						String title = t.getTitle() != null ? t.getTitle() : "";
						String desc = t.getDescription() != null ? t.getDescription() : "";
						String status = t.getStatus() != null ? t.getStatus() : "";
						String assignedTo = t.getAssignedTo() != null ? t.getAssignedTo() : "";
						String assignedBy = t.getAssignedBy() != null ? t.getAssignedBy() : "";
						java.sql.Timestamp ts = t.getAssignedDate();
						String dateStr = ts != null ? ts.toLocalDateTime().toLocalDate().toString() : "";

						String priClass = "bp-medium";
						String priText = "Medium";
						if ("COMPLETED".equalsIgnoreCase(status)) { priClass = "bp-low"; priText = "Low"; }
						else if ("ASSIGNED".equalsIgnoreCase(status)) { priClass = "bp-medium"; priText = "Medium"; }
						else if ("IN_PROGRESS".equalsIgnoreCase(status)) { priClass = "bp-high"; priText = "High"; }

						String stClass = "bs-pending";
						String stText = status;
						if ("COMPLETED".equalsIgnoreCase(status)) { stClass = "bs-done"; stText = "COMPLETED"; }
						else if ("IN_PROGRESS".equalsIgnoreCase(status)) { stClass = "bs-progress"; stText = "IN_PROGRESS"; }
						else if ("ASSIGNED".equalsIgnoreCase(status)) { stClass = "bs-pending"; stText = "PENDING"; }
				%>
				<tr class="border-b border-slate-200 hover:bg-slate-50 text-sm">
					<td class="px-4 py-3 text-slate-500"><%= idx++ %></td>
					<td class="px-4 py-3 text-slate-800"><%= title %></td>
					<td class="px-4 py-3 text-slate-600"><%= desc %></td>
					<td class="px-4 py-3">
						<span class="badge-priority <%= priClass %>">
							<%= priText %>
						</span>
					</td>
					<td class="px-4 py-3">
						<span class="badge-status <%= stClass %>">
							<%= stText %>
						</span>
					</td>
					<td class="px-4 py-3 text-slate-600"><%= dateStr %></td>
					<td class="px-4 py-3 text-slate-600"><%= assignedTo %></td>
					<td class="px-4 py-3 text-slate-600"><%= assignedBy %></td>
				</tr>
				<%
					}
				}
				%>
			</tbody>
		</table>
	</div>
</div>

</body>
</html>

