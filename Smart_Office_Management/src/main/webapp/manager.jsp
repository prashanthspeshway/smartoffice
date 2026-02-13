<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>

<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.dao.TaskDAO"%>

<%
String activeTab = (String) request.getAttribute("tab");
%>
<%
List<Task> assignTasks = (List<Task>) request.getAttribute("assignTasks");
List<Task> viewTasks = (List<Task>) request.getAttribute("viewTasks");
%>
<%
java.sql.Timestamp punchIn = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");

String status = "Not Punched In";
if (punchIn != null && punchOut == null)
	status = "Punched In";
if (punchOut != null)
	status = "Punched Out";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manager Dashboard</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* ===== Global ===== */
* {
	box-sizing: border-box;
}

body {
	margin: 0;
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f1f5f9;
}

body.dark {
	background: #0f172a;
	color: #e5e7eb;
}

/* ===== Top Bar ===== */
.top-bar {
	height: 75px;
	background: linear-gradient(135deg, #17223d, #2a3c66, #29448a);
	color: #fff;
	display: flex;
	align-items: center;
	padding: 0 30px;
}

.user-area {
	margin-left: auto;
	display: flex;
	align-items: center;
	gap: 15px;
}

.icon-btn {
	background: none;
	border: none;
	color: #fff;
	font-size: 18px;
	cursor: pointer;
}

.logout-btn {
	background: #ef4444;
	border: none;
	padding: 8px 18px;
	border-radius: 20px;
	color: #fff;
	cursor: pointer;
}

/* ===== Layout ===== */
.container {
	display: flex;
	height: calc(100vh - 75px);
}

/* ===== Sidebar ===== */
.left-panel {
	width: 260px;
	background: #ffffff;
	padding: 25px 20px;
	box-shadow: 3px 0 12px rgba(0, 0, 0, 0.08);
}

.nav-btn {
	width: 100%;
	padding: 14px;
	margin-bottom: 14px;
	border: none;
	border-radius: 10px;
	background: #1c42a5;
	color: #eee;
	cursor: pointer;
	font-size: 15px;
}

.nav-btn:hover {
	background: #2563eb;
}

/* ===== Content ===== */
.right-panel {
	flex: 1;
	padding: 30px;
	overflow-y: auto;
	background: #f1f5f9;
}

/* ===== Box ===== */
.box {
	background: #ffffff;
	padding: 25px 30px;
	border-radius: 16px;
	box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
	margin-bottom: 30px;
}

/* ===== Buttons ===== */
.primary-btn, .reject-btn {
	padding: 10px 22px;
	border-radius: 22px;
	cursor: pointer;
	font-weight: 500;
	transition: all 0.2s ease;
	border: none;
}

.primary-btn {
	background: #22c55e;
	color: #fff;
}

.primary-btn:hover:not(:disabled) {
	background: #16a34a;
	transform: translateY(-1px);
	box-shadow: 0 6px 14px rgba(34, 197, 94, 0.35);
}

.reject-btn {
	background: #dc2626;
	color: #fff;
}

.reject-btn:hover:not(:disabled) {
	background: #b91c1c;
	transform: translateY(-1px);
	box-shadow: 0 6px 14px rgba(239, 68, 68, 0.35);
}

.primary-btn:disabled, .reject-btn:disabled {
	background: #e5e7eb;
	color: #9ca3af;
	cursor: not-allowed;
	box-shadow: none;
	transform: none;
}

.secondary-btn {
	background: #3b82f6;
	color: #fff;
	padding: 8px 18px;
	border: none;
	border-radius: 18px;
	cursor: pointer;
}

/* ===== Employee Grid ===== */
.employee-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	gap: 16px;
	margin-top: 15px;
}

.employee-card {
	border-left: 5px solid #2563eb;
	padding: 14px 16px;
	background: linear-gradient(135deg, #f8fafc, #eef2ff);
	border-radius: 12px;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
	background: linear-gradient(135deg, #f8fafc, #eef2ff);
}

.employee-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.emp-header {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 6px;
	font-size: 14px;
}

.emp-header i {
	color: #3b82f6;
}

.emp-name {
	font-weight: 600;
	flex: 1;
}

.emp-status {
	font-size: 11px;
	padding: 3px 10px;
	border-radius: 12px;
	background: #dcfce7;
	color: #166534;
}

.emp-body {
	font-size: 13px;
	color: #475569;
}

.emp-body div {
	margin-bottom: 4px;
}

/* ===== Form Controls ===== */
.form-control {
	width: 100%;
	padding: 12px;
	border-radius: 10px;
	border: 1px solid #d1d5db;
	margin-bottom: 15px;
}

/* ===== Attendance Module Styles ===== */
.attendance-buttons {
	margin-top: 15px;
	display: flex;
	gap: 15px;
}

.attendance-buttons button {
	min-width: 100px;
}

/* ===== Settings Module Styles ===== */
#settings p {
	margin-bottom: 12px;
}

/* ===== Tasks Title ===== */
.tasks-title {
	margin-top: 25px;
	margin-bottom: 14px;
	font-size: 18px;
	font-weight: 600;
	color: #1e293b;
}

/* ===== Assigned Tasks Grid ===== */
.task-list {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	gap: 20px;
}

/* ===== Task Card ===== */
.task-card {
	background: #03368a;
	border-radius: 14px;
	padding: 18px;
	border: 1px solid #e5e7eb;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
}

/* Hover (soft & professional) */
.task-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 12px 28px rgba(0, 0, 0, 0.12);
}

/* ===== Task Description ===== */
.task-desc {
	font-size: 14px;
	font-weight: 500;
	color: white;
	margin-bottom: 14px;
	line-height: 1.5;
}

/* ===== Status Badge ===== */
.task-status {
	display: inline-block;
	font-size: 11px;
	font-weight: 600;
	padding: 6px 14px;
	border-radius: 999px;
}

/* ASSIGNED */
.task-status.assigned {
	background: #fde68a;
	color: #92400e;
}

/* COMPLETED */
.task-status.completed {
	background: #bbf7d0;
	color: #166534;
}

/* COMPLETED card subtle fade */
.task-card.completed {
	opacity: 0.75;
}

.task-card.completed {
	opacity: 1;
}
</style>
</head>
<body>

	<!-- ===== Top Bar ===== -->
	<div class="top-bar">
		<h2>Smart Office • Manager Dashboard</h2>
		<div class="user-area">
			<span>Welcome, <b>${sessionScope.username}</b></span>
			<button class="icon-btn" onclick="showSection('settings')">
				<i class="fa-solid fa-gear"></i>
			</button>
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">Logout</button>
			</a>
		</div>
	</div>

	<div class="container">

		<!-- ===== Sidebar ===== -->
		<div class="left-panel">
			<button class="nav-btn" onclick="showSection('selfAttendance')">My
				Attendance</button>
			<button class="nav-btn" onclick="showSection('teamSection')">My
				Team</button>
			<button class="nav-btn" onclick="showSection('assignTask')">Assign
				Tasks</button>
			<button class="nav-btn" onclick="showSection('attendance')">Team
				Attendance</button>
			<button class="nav-btn" onclick="showSection('leave')">Leave
				Requests</button>
				<button class="nav-btn" onclick="openCalendar()">Calendar</button>
		</div>

		<!-- ===== Right Panel ===== -->
		<div class="right-panel">

			<div class="box" id="blank" style="display: none;">
				<h3>Welcome 👋</h3>
				<p>Select an option from the left menu to continue.</p>
			</div>

			<!-- ===== My Attendance ===== -->
			<div class="box" id="selfAttendance" style="display: none;">
				<h3>My Attendance</h3>
				<p>
					<b>Status:</b>
					<%=status%></p>
				<p>
					<b>Punch In:</b>
					<%=punchIn != null ? punchIn : "--"%></p>
				<p>
					<b>Punch Out:</b>
					<%=punchOut != null ? punchOut : "--"%></p>

				<div class="attendance-buttons">
					<form action="attendance" method="post" style="display: inline;">
						<input type="hidden" name="action" value="punchin">
						<button class="primary-btn" <%=punchIn != null ? "disabled" : ""%>>Punch
							In</button>
					</form>

					<form action="attendance" method="post" style="display: inline;">
						<input type="hidden" name="action" value="punchout">
						<button class="reject-btn"
							<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>Punch
							Out</button>
					</form>
				</div>
			</div>

			<!-- ===== My Team ===== -->
			<div class="box" id="teamSection" style="display: none;">
				<h3>My Team</h3>
				<div class="employee-grid">
					<%
					List<User> team = (List<User>) request.getAttribute("teamList");
					if (team != null && !team.isEmpty()) {
						for (User u : team) {
					%>
					<div class="employee-card">
						<div class="emp-header">
							<i class="fa-solid fa-user"></i> <span class="emp-name"><%=u.getFullname()%></span>
							<span class="emp-status"><%=u.getStatus()%></span>
						</div>
						<div class="emp-body">
							<div>
								<b>Username:</b>
								<%=u.getUsername()%></div>
							<div>
								<b>Email:</b>
								<%=u.getEmail()%></div>
							<div>
								<b>Phone:</b>
								<%=u.getPhone()%></div>
						</div>
					</div>
					<%
					}
					} else {
					%>
					<p>No employees found</p>
					<%
					}
					%>
				</div>
			</div>

			<!-- ===== Assign Tasks ===== -->
			<div class="box" id="assignTask" style="display: none;">

				<h3>Assign Task</h3>

				<!-- Display error message if any -->
				<%
				String errorMessage = (String) request.getAttribute("errorMessage");
				if (errorMessage != null) {
				%>
				<div style="color: red; font-weight: bold; margin-bottom: 15px;">
					<%=errorMessage%>
				</div>
				<%
				}
				%>

				<!-- Assign form with dropdown for employee -->
				<form action="<%=request.getContextPath()%>/assignTask"
					method="post">
					<select name="employeeUsername">
						<option value="">Select Employee</option>
						<%
						String assignEmployee = (String) request.getAttribute("assignEmployee");
						for (User u : team) {
						%>
						<option value="<%=u.getUsername()%>"
							<%=u.getUsername().equals(assignEmployee) ? "selected" : ""%>>
							<%=u.getUsername()%>
						</option>
						<%
						}
						%>
					</select>

					<textarea class="form-control" name="taskDesc" rows="4"
						placeholder="Task Description" required><%=request.getParameter("taskDesc") != null ? request.getParameter("taskDesc") : ""%></textarea>
					<button class="primary-btn">Assign Task</button>
				</form>


				<hr style="margin: 25px 0;">


				<!-- View tasks form -->
				<form action="<%=request.getContextPath()%>/viewAssignedTasks"
					method="post">
					<select class="form-control" name="employeeUsername" required>
						<option value="">Select Employee</option>
						<%
						String viewEmployee = (String) request.getAttribute("viewEmployee");
						if (team != null) {
							for (User u : team) {
						%>
						<option value="<%=u.getUsername()%>"
							<%=u.getUsername().equals(viewEmployee) ? "selected" : ""%>>
							<%=u.getFullname()%> (<%=u.getUsername()%>)
						</option>
						<%
						}
						}
						%>
					</select>
					<button class="secondary-btn">View Assigned Tasks</button>
				</form>

				<!-- Task list -->
				<%
				// 				List<Task> viewTasks = (List<Task>) request.getAttribute("viewTasks");
				// 				String viewEmployee = (String) request.getAttribute("viewEmployee");
				if (viewTasks != null) {
				%>

				<h4 class="tasks-title">
					Tasks for
					<%=viewEmployee%>
				</h4>


				<div id="taskList" class="task-list">

					<%
					if (viewTasks.isEmpty()) {
					%>
					<p>No tasks found.</p>
					<%
					} else {
					for (Task t : viewTasks) {
					%>
					<div
						class="task-card <%=t.getStatus().equals("COMPLETED") ? "completed" : ""%>">
						<div class="task-desc"><%=t.getDescription()%></div>
						<span
							class="task-status <%=t.getStatus().equals("COMPLETED") ? "completed" : "assigned"%>">
							<%=t.getStatus()%>
						</span>
					</div>

					<%
					}
					}
					}
					%>
				</div>
			</div>


			<!-- ===== Team Attendance ===== -->
			<div class="box" id="attendance" style="display: none;">
				<h3>Team Attendance</h3>
				<p>Coming soon…</p>
			</div>

			<!-- ===== Leave Requests ===== -->
			<div class="box" id="leave" style="display: none;">
				<h3>Leave Requests</h3>
				<p>Coming soon…</p>
			</div>
<!-- Calendar -->
			<div class="box" id="calendarSection" style="display: none;">
				<h3>
					<i class="fa-solid fa-calendar-days"></i> Company Calendar
				</h3>

				<iframe id="calendarFrame" src="" style="width:100%; height:600px; border:none;"></iframe>

			</div>
			<!-- ===== Settings ===== -->
			<div class="box" id="settings" style="display: none;">
				<h3>Settings</h3>
				<p>
					<b>Name:</b> ${sessionScope.username}
				</p>
				<p>
					<b>Role:</b> Manager
				</p>
				<button class="secondary-btn" onclick="toggleTheme()">Toggle
					Theme</button>
			</div>

		</div>
	</div>

	<script>
function showSection(id) {
	document.querySelectorAll('.box').forEach(b => b.style.display = 'none');
	document.getElementById(id).style.display = 'block';
}
function toggleTheme() {
	document.body.classList.toggle("dark");
}
function openCalendar() {
    // hide all sections (same logic as showSection)
    document.querySelectorAll('.box').forEach(b => b.style.display = 'none');

    // show calendar section
    document.getElementById("calendarSection").style.display = "block";

    // load calendar jsp in iframe
    document.getElementById("calendarFrame").src = "<%=request.getContextPath()%>/calendar.jsp";
}
</script>

	<%
	if (activeTab != null) {
	%>
	<script>
showSection("<%=activeTab%>");
</script>
	<%
	} else {
	%>
	<script>
showSection("blank");

</script>
	<%
	}
	%>

</body>
</html>
