<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.User"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

String errorMessage = (String) request.getAttribute("errorMessage");
List<User> team = (List<User>) request.getAttribute("teamList");
String assignEmployee = (String) request.getAttribute("assignEmployee");
String viewEmployee = (String) request.getAttribute("viewEmployee");
List<Task> viewTasks = (List<Task>) request.getAttribute("viewTasks");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap" rel="stylesheet">
<style>body{font-family:'DM Sans',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-7xl mx-auto">
		<h2 class="text-2xl font-bold text-slate-800 mb-6">Tasks</h2>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
			<!-- Assign Task Card -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<div class="flex items-center gap-3 mb-6">
					<i class="fa-solid fa-paper-plane text-indigo-600 text-2xl"></i>
					<h3 class="text-lg font-semibold text-slate-800">Assign New Task</h3>
				</div>

				<%if (errorMessage != null) {%>
				<div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
					<i class="fa-solid fa-exclamation-circle mr-2"></i><%=errorMessage%>
				</div>
				<%}%>

				<form action="<%=request.getContextPath()%>/assignTask" method="post" 
					enctype="multipart/form-data" class="space-y-4">
					
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Assign to</label>
						<select name="employeeUsername" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
							<option value="">Select Employee</option>
							<%
							if (team != null && !team.isEmpty()) {
								for (User u : team) {
							%>
							<option value="<%=u.getEmail()%>" 
								<%=u.getEmail().equals(assignEmployee) ? "selected" : ""%>>
								<%=u.getFullname()%> (<%=u.getEmail()%>)
							</option>
							<%
								}
							} else {
							%>
							<option disabled>No employees available</option>
							<%}%>
						</select>
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Task Title</label>
						<input type="text" name="title" placeholder="E.g. Submit weekly report" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Description</label>
						<textarea name="taskDesc" rows="4" placeholder="Add clear instructions and details" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
					</div>

					<div class="grid grid-cols-2 gap-4">
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">Deadline</label>
							<input type="date" name="deadline"
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						</div>
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">Priority</label>
							<select name="priority"
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
								<option value="HIGH">High</option>
								<option value="MEDIUM" selected>Medium</option>
								<option value="LOW">Low</option>
							</select>
						</div>
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Attachment <span class="text-slate-500 font-normal">(optional)</span>
						</label>
						<input type="file" name="attachment"
							accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg"
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						<p class="text-xs text-slate-500 mt-1">Attach any reference document or file your employee needs.</p>
					</div>

					<button type="submit"
						class="w-full px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors">
						<i class="fa-solid fa-paper-plane mr-2"></i>Assign Task
					</button>
				</form>
			</div>

			<!-- View Tasks Card -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<div class="flex items-center gap-3 mb-6">
					<i class="fa-solid fa-list-check text-indigo-600 text-2xl"></i>
					<h3 class="text-lg font-semibold text-slate-800">View Assigned Tasks</h3>
				</div>

				<form action="<%=request.getContextPath()%>/viewAssignedTasks" method="post" 
					class="space-y-4 mb-6">
					
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Employee</label>
						<select name="employeeUsername" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
							<option value="">Select Employee</option>
							<%
							if (team != null && !team.isEmpty()) {
								for (User u : team) {
							%>
							<option value="<%=u.getEmail()%>" 
								<%=u.getEmail().equals(viewEmployee) ? "selected" : ""%>>
								<%=u.getFullname()%> (<%=u.getEmail()%>)
							</option>
							<%
								}
							} else {
							%>
							<option disabled>No employees available</option>
							<%}%>
						</select>
					</div>

					<button type="submit"
						class="w-full px-6 py-3 bg-slate-700 hover:bg-slate-800 text-white font-semibold rounded-lg transition-colors">
						<i class="fa-solid fa-eye mr-2"></i>View Tasks
					</button>
				</form>

				<%if (viewTasks != null) {%>
				<div class="border-t border-slate-200 pt-6">
					<h4 class="font-semibold text-slate-800 mb-4">
						Tasks for <span class="text-indigo-600"><%=viewEmployee%></span>
					</h4>

					<div class="space-y-3 max-h-96 overflow-y-auto">
						<%
						if (viewTasks.isEmpty()) {
						%>
						<p class="text-slate-500 text-center py-8">No tasks found for this employee.</p>
						<%
						} else {
							for (Task t : viewTasks) {
								String statusColor = t.getStatus().equals("COMPLETED") 
									? "bg-green-100 text-green-800" 
									: "bg-yellow-100 text-yellow-800";
						%>
						<div class="bg-slate-50 rounded-lg p-4 border border-slate-200">
							<div class="flex justify-between items-start mb-2">
								<h5 class="font-semibold text-slate-800"><%=t.getTitle() != null ? t.getTitle() : "Task"%></h5>
								<span class="px-2 py-1 rounded-full text-xs font-semibold <%=statusColor%>">
									<%=t.getStatus()%>
								</span>
							</div>
							<p class="text-sm text-slate-600 mb-2"><%=t.getDescription()%></p>
							<div class="flex items-center gap-4 text-xs text-slate-500">
								<span>
									<i class="fa-solid fa-calendar mr-1"></i>
									Deadline: <%=t.getDeadline() != null ? t.getDeadline().toString() : "--"%>
								</span>
								<span>
									<i class="fa-solid fa-flag mr-1"></i>
									Priority: <%=t.getPriority() != null ? t.getPriority() : "MEDIUM"%>
								</span>
							</div>
							<%
							String attName = t.getAttachmentName();
							if (attName != null && !attName.isEmpty()) {
							%>
							<a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>" 
								target="_blank"
								class="inline-flex items-center gap-1 mt-2 text-xs text-blue-600 hover:text-blue-700">
								<i class="fa-solid fa-paperclip"></i> Download: <%=attName%>
							</a>
							<%}%>
							<%
							String empFile = t.getEmployeeAttachmentName();
							if (empFile != null && !empFile.isEmpty()) {
							%>
							<a href="<%=request.getContextPath()%>/employeeTaskAttachment?id=<%=t.getId()%>" 
								target="_blank"
								class="inline-flex items-center gap-1 mt-2 ml-4 text-xs text-green-600 hover:text-green-700">
								<i class="fa-solid fa-file-arrow-up"></i> Employee Submission: <%=empFile%>
							</a>
							<%}%>
						</div>
						<%
							}
						}
						%>
					</div>
				</div>
				<%}%>
			</div>
		</div>
	</div>

	<script>
	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
