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
String qError = request.getParameter("error");
if (errorMessage == null && qError != null && !qError.isEmpty()) {
	errorMessage = qError;
}
List<User> team = (List<User>) request.getAttribute("teamList");
String assignEmployee = (String) request.getAttribute("assignEmployee");
String viewEmployee   = (String) request.getAttribute("viewEmployee");
List<Task> viewTasks  = (List<Task>) request.getAttribute("viewTasks");
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
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>body { font-family: 'Geist', system-ui, sans-serif; }</style>
</head>
<body class="bg-slate-100 p-6">

	<div id="taskToast"
		class="fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg hidden text-sm font-medium max-w-[min(92vw,24rem)]">
	</div>

	<div class="max-w-7xl mx-auto">
		<h2 class="text-2xl font-bold text-slate-800 mb-6">Tasks</h2>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

			<!-- ══════════════════════════════════════════════
			     Assign Task Card
			══════════════════════════════════════════════ -->
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

				<form action="<%=request.getContextPath()%>/managerTasks" method="post"
					enctype="multipart/form-data" class="space-y-4" id="assignTaskForm">

					<input type="hidden" name="action" value="assign">

					<!-- ── Multi-select employee dropdown ───────────────────── -->
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Assign to <span class="text-red-500">*</span>
						</label>
						<div class="relative" id="empDropdownWrapper">
							<button type="button" onclick="toggleEmpDropdown()"
								class="w-full px-4 py-2 border border-slate-300 rounded-lg bg-white text-left focus:outline-none focus:ring-2 focus:ring-indigo-500 flex justify-between items-center min-h-[42px]">
								<span id="empDropdownLabel" class="text-slate-500 text-sm">Select Employees</span>
								<i class="fa-solid fa-chevron-down text-slate-400 text-xs ml-2 shrink-0 transition-transform duration-200"
									id="empChevron"></i>
							</button>

							<div id="empDropdownPanel"
								class="hidden absolute z-20 mt-1 w-full bg-white border border-slate-200 rounded-lg shadow-lg max-h-52 overflow-y-auto">
								<%
								if (team != null && !team.isEmpty()) {
									for (User u : team) {
								%>
								<label
									class="flex items-center gap-3 px-4 py-2.5 hover:bg-indigo-50 cursor-pointer transition-colors border-b border-slate-100 last:border-0">
									<input type="checkbox" name="employeeUsername"
										value="<%=u.getEmail()%>"
										class="emp-checkbox accent-indigo-600 w-4 h-4 shrink-0"
										onchange="updateEmpLabel()">
									<span class="text-sm text-slate-700 leading-tight">
										<%=u.getFullname()%>
										<span class="text-slate-400 text-xs block"><%=u.getEmail()%></span>
									</span>
								</label>
								<%
									}
								} else {
								%>
								<div class="px-4 py-3 text-sm text-slate-400">No employees available</div>
								<%}%>
							</div>
						</div>
						<!-- Hidden input so browser required-check fires when nothing is selected -->
						<input type="text" id="empValidation" class="sr-only" required
							tabindex="-1" aria-hidden="true" autocomplete="off">
						<p class="text-xs text-slate-500 mt-1">You can select multiple employees to assign the same task.</p>
					</div>

					<!-- ── Title (mandatory) ────────────────────────────────── -->
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Task Title <span class="text-red-500">*</span>
						</label>
						<input type="text" name="title"
							placeholder="E.g. Submit weekly report" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<!-- ── Description (mandatory) ──────────────────────────── -->
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Description <span class="text-red-500">*</span>
						</label>
						<%-- name="taskDesc" — ManagerTasksServlet reads getParameter("taskDesc") --%>
						<textarea name="taskDesc" rows="4"
							placeholder="Add clear instructions and details" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
					</div>

					<!-- ── Deadline + Priority ──────────────────────────────── -->
					<div class="grid grid-cols-2 gap-4">
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">
								Deadline <span class="text-red-500">*</span>
							</label>
							<input type="date" name="deadline" required
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						</div>
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">
								Priority <span class="text-red-500">*</span>
							</label>
							<select name="priority" required
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
								<option value="HIGH">High</option>
								<option value="MEDIUM" selected>Medium</option>
								<option value="LOW">Low</option>
							</select>
						</div>
					</div>

					<!-- ── Attachment (optional) ────────────────────────────── -->
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Attachment <span class="text-slate-500 font-normal">(optional)</span>
						</label>
						<input type="file" name="attachment"
							accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg"
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						<p class="text-xs text-slate-500 mt-1">Attach any reference document your employee needs.</p>
					</div>

					<button type="submit"
						class="w-full px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors">
						<i class="fa-solid fa-paper-plane mr-2"></i>Assign Task
					</button>
				</form>
			</div>

			<!-- ══════════════════════════════════════════════
			     View Tasks Card
			══════════════════════════════════════════════ -->
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
								String rs = t.getStatus() != null ? t.getStatus().trim() : "";
								String statusLabel = "COMPLETED".equalsIgnoreCase(rs) ? "Completed"
										: ("PROCESSING".equalsIgnoreCase(rs) || "SUBMITTED".equalsIgnoreCase(rs))
											? "Processing" : "Assigned";
								boolean isCompleted  = "COMPLETED".equalsIgnoreCase(rs);
								boolean isProcessing = "PROCESSING".equalsIgnoreCase(rs) || "SUBMITTED".equalsIgnoreCase(rs);
						%>
						<div class="bg-slate-50 rounded-lg p-4 border border-slate-200">
							<div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-3 mb-2">
								<h5 class="font-semibold text-slate-800">
									<%=t.getTitle() != null ? t.getTitle() : "Task"%>
								</h5>
								<%if (!isCompleted && viewEmployee != null) {%>
								<form action="<%=request.getContextPath()%>/managerTasks"
									method="post"
									class="flex flex-wrap items-center gap-2 shrink-0">
									<input type="hidden" name="action" value="updateStatus">
									<input type="hidden" name="taskId" value="<%=t.getId()%>">
									<input type="hidden" name="viewEmployee" value="<%=viewEmployee%>">
									<label class="sr-only" for="decision-<%=t.getId()%>">Manager action</label>
									<select id="decision-<%=t.getId()%>" name="decision" required
										class="text-sm px-3 py-2 rounded-lg border border-slate-300 bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 min-w-[11rem]">
										<option value="">Select action</option>
										<%if (isProcessing) {%>
										<option value="review">Review</option>
										<%}%>
										<option value="completed">Completed</option>
									</select>
									<button type="submit"
										class="text-sm px-3 py-2 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white font-semibold transition-colors">
										Apply
									</button>
								</form>
								<%}%>
							</div>

							<p class="text-sm text-slate-700 mb-2">
								<span class="text-slate-500 font-medium">Status:</span>
								<span class="font-semibold text-slate-900"><%=statusLabel%></span>
							</p>
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
	// ── Multi-select employee dropdown ─────────────────────────────
	function toggleEmpDropdown() {
		var panel   = document.getElementById('empDropdownPanel');
		var chevron = document.getElementById('empChevron');
		var isOpen  = !panel.classList.contains('hidden');
		if (isOpen) {
			panel.classList.add('hidden');
			chevron.style.transform = 'rotate(0deg)';
		} else {
			panel.classList.remove('hidden');
			chevron.style.transform = 'rotate(180deg)';
		}
	}

	document.addEventListener('click', function (e) {
		var wrapper = document.getElementById('empDropdownWrapper');
		if (wrapper && !wrapper.contains(e.target)) {
			document.getElementById('empDropdownPanel').classList.add('hidden');
			document.getElementById('empChevron').style.transform = 'rotate(0deg)';
		}
	});

	function updateEmpLabel() {
		var checked    = document.querySelectorAll('.emp-checkbox:checked');
		var label      = document.getElementById('empDropdownLabel');
		var validation = document.getElementById('empValidation');

		if (checked.length === 0) {
			label.textContent = 'Select Employees';
			label.classList.add('text-slate-500');
			label.classList.remove('text-slate-800');
			validation.value = '';
		} else if (checked.length === 1) {
			var nameSpan = checked[0].closest('label').querySelector('span');
			label.textContent = nameSpan
				? nameSpan.childNodes[0].textContent.trim()
				: checked[0].value;
			label.classList.remove('text-slate-500');
			label.classList.add('text-slate-800');
			validation.value = 'selected';
		} else {
			label.textContent = checked.length + ' employees selected';
			label.classList.remove('text-slate-500');
			label.classList.add('text-slate-800');
			validation.value = 'selected';
		}
	}

	// Prevent form submit if no employee selected
	document.getElementById('assignTaskForm').addEventListener('submit', function (e) {
		var checked = document.querySelectorAll('.emp-checkbox:checked');
		if (checked.length === 0) {
			e.preventDefault();
			document.getElementById('empDropdownPanel').classList.remove('hidden');
			document.getElementById('empChevron').style.transform = 'rotate(180deg)';
			var btn = document.querySelector('#empDropdownWrapper button');
			btn.classList.add('border-red-400', 'ring-2', 'ring-red-300');
			setTimeout(function () {
				btn.classList.remove('border-red-400', 'ring-2', 'ring-red-300');
			}, 2000);
		}
	});

	// ── Toast notifications ────────────────────────────────────────
	function showTaskFlash(msg, ok) {
		var el = document.getElementById('taskToast');
		if (!el) return;
		el.className = 'fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg text-sm font-medium max-w-[min(92vw,24rem)] '
			+ (ok ? 'bg-emerald-600 text-white' : 'bg-red-600 text-white');
		el.textContent = msg;
		el.classList.remove('hidden');
		setTimeout(function () { el.classList.add('hidden'); }, 3800);
	}

	(function () {
		var p     = new URLSearchParams(window.location.search);
		var flash = p.get('taskFlash');
		if (flash === 'review')           showTaskFlash('Task returned to employee — they can submit again.', true);
		else if (flash === 'completed')   showTaskFlash('Task is completed successfully.', true);
		else if (flash === 'alreadyCompleted') showTaskFlash('This task was already completed.', true);

		var s = p.get('success');
		if (s) showTaskFlash(decodeURIComponent(s.replace(/\+/g, ' ')), true);

		var err = p.get('error');
		if (err) showTaskFlash(decodeURIComponent(err.replace(/\+/g, ' ')), false);

		if (flash || err || s) {
			p.delete('taskFlash');
			p.delete('error');
			p.delete('success');
			var q    = p.toString();
			var path = window.location.pathname + (q ? '?' + q : '');
			window.history.replaceState({}, document.title, path);
		}
	})();
	</script>
</body>
</html>
