<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>

<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.TeamAttendance"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>


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
	margin-bottom: 12px;
	background: linear-gradient(135deg, #f8fafc, #eef2ff);
	border-radius: 12px;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.00);
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

.centered-box {
	max-width: 900px;
	margin: 0 auto;
}

/* ===== Team Attendance Header ===== */
.team-attendance-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
}

/* Button container */
.export-actions {
	display: flex;
	gap: 12px;
}

/* Unified export button style */
.export-btn {
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 10px 18px;
	border-radius: 20px;
	border: none;
	background: #2563eb;
	color: #fff;
	font-size: 14px;
	cursor: pointer;
	min-width: 190px;
	justify-content: center;
	transition: all 0.2s ease;
}

.export-btn:hover {
	background: #1d4ed8;
	transform: translateY(-1px);
	box-shadow: 0 6px 14px rgba(37, 99, 235, 0.35);
}

.export-btn i {
	font-size: 14px;
}

.team-attendance-header {
	display: flex;
	align-items: center; /* vertically aligns h3 + buttons */
	justify-content: space-between;
	margin-bottom: 20px;
}

/* Prevent h3 from forcing a new line */
.team-title {
	margin: 0;
	white-space: nowrap;
}

/* Button container */
.export-actions {
	display: flex;
	gap: 12px;
}

/* Buttons */
.export-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 8px;
	padding: 10px 18px;
	min-width: 190px;
	border-radius: 20px;
	border: none;
	background: #2563eb;
	color: white;
	font-weight: 600;
	cursor: pointer;
}

.export-btn:hover {
	background: #1d4ed8;
}

/* ===== Performance Matrix Styling ===== */
#performance {
	max-width: 520px;
}

#performance h3 {
	margin-bottom: 20px;
	color: #1e293b;
}

/* Radio group container */
.radio-group {
	display: flex;
	flex-direction: column; /* 👈 one by one */
	gap: 10px;
	margin: 15px 0 20px;
}

/* Individual radio option */
.radio-group label {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 10px 14px;
	border-radius: 10px;
	border: 1px solid #e5e7eb;
	background: #f8fafc;
	cursor: pointer;
	font-size: 14px;
	transition: background 0.2s ease, border 0.2s ease;
}

/* Hover effect */
.radio-group label:hover {
	background: #eef2ff;
	border-color: #3b82f6;
}

/* Radio input */
.radio-group input[type="radio"] {
	accent-color: #2563eb;
	transform: scale(1.1);
}

/* ===== Toast Notification ===== */
.toast-success {
	position: fixed;
	top: 80px;
	right: 500px;
	background: #16a34a;
	color: white;
	padding: 14px 22px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 14px;
	font-weight: 500;
	box-shadow: 0 10px 25px rgba(34, 197, 94, 0.35);
	animation: slideIn 0.4s ease, fadeOut 0.4s ease 3.6s forwards;
	z-index: 9999;
}

.toast-success i {
	font-size: 18px;
}

/* Slide from right */
@
keyframes slideIn {from { opacity:0;
	transform: translateX(60px);
}

to {
	opacity: 1;
	transform: translateX(0);
}

}

/* Fade out */
@
keyframes fadeOut {to { opacity:0;
	transform: translateX(60px);
}

}

/* ================= SETTINGS ICON ================= */
.settings-icon {
	position: absolute;
	top: 20px;
	left: 20px;
	font-size: 26px;
	cursor: pointer;
	background: #ffffff;
	padding: 10px;
	border-radius: 50%;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
	z-index: 101;
}

/* ================= SETTINGS PANEL ================= */
.settings-panel {
	position: fixed;
	top: 0;
	right: -320px;
	width: 300px;
	height: 100%;
	background: #f9f9f9;
	box-shadow: -4px 0 10px rgba(0, 0, 0, 0.3);
	transition: right 0.3s ease;
	z-index: 100;
}

.settings-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 15px;
	background: #2c3e50;
	color: white;
}

.close-btn {
	cursor: pointer;
	font-size: 18px;
}

.settings-list {
	list-style: none;
	padding: 0;
	margin: 0;
}

.settings-list li {
	padding: 15px;
	cursor: pointer;
	border-bottom: 1px solid #ddd;
}

.settings-list li:hover {
	background: #eaeaea;
}

/* ================= CHANGE PASSWORD MODAL ================= */
.password-modal {
	display: none;
	position: fixed;
	inset: 0;
	z-index: 200;
}

.password-box {
	width: 350px;
	background: #fff;
	margin: 10% auto;
	border-radius: 6px;
	overflow: hidden;
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
}

.password-header {
	background: #34495e;
	color: white;
	padding: 12px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.password-body {
	padding: 20px;
}

.password-body input {
	width: 100%;
	padding: 10px;
	margin-bottom: 12px;
	border: 1px solid #ccc;
	border-radius: 4px;
}

.password-body button {
	width: 100%;
	padding: 10px;
	background: #2ecc71;
	border: none;
	color: white;
	font-size: 15px;
	cursor: pointer;
	border-radius: 4px;
}

.password-body button:hover {
	background: #27ae60;
}

/* ================= DARK THEME ================= */
.dark-theme {
	background: #121212;
	color: white;
}

.dark-theme .settings-panel {
	background: #1e1e1e;
}

.dark-theme .password-box {
	background: #1e1e1e;
	color: white;
}

.dark-theme input {
	background: #2c2c2c;
	color: white;
	border: 1px solid #555;
}
</style>
</head>

<%
String error = request.getParameter("error");
if ("HolidayAttendance".equals(error)) {
%>
<div id="toast" class="toast-success">
	<i class="fa-solid fa-circle-check"></i> <span>Today is a
		holiday. Attendance is disabled.</span>
</div>
<%
}
%>

<body>


	<!-- SETTINGS PANEL -->
	<div id="settingsPanel" class="settings-panel">
		<div class="settings-header">
			<h3>Settings</h3>
			<span class="close-btn" onclick="closeSettings()">✖</span>
		</div>

		<ul class="settings-list">
			<li onclick="openProfile()">👤 Self Profile</li>
			<li onclick="openChangePassword()">🔐 Change Password</li>
			<li onclick="toggleTheme()">🌗 Theme</li>
		</ul>
	</div>

	<!-- CHANGE PASSWORD MODAL -->
	<div id="passwordModal" class="password-modal">
		<div class="password-box">
			<div class="password-header">
				<h4>Change Password</h4>
				<span class="close-btn" onclick="closeChangePassword()">✖</span>
			</div>

			<div class="password-body">
				<input type="password" id="oldPassword" placeholder="Old Password">
				<input type="password" id="newPassword" placeholder="New Password">
				<input type="password" id="confirmPassword"
					placeholder="Confirm Password">
				<button onclick="submitPassword()">Update Password</button>
			</div>
		</div>
	</div>








	<!-- ===== Top Bar ===== -->
	<div class="top-bar">
		<h2>Smart Office • Manager Dashboard</h2>
		<div class="user-area">
			<span>Welcome, <b>${sessionScope.username}</b></span>
			<button class="icon-btn" onclick="openSettings()">
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
			<button class="nav-btn" onclick="showSection('schedulemeeting')">
				Schedule Meetings</button>
			<button class="nav-btn" onclick="showSection('attendance')">Team
				Attendance</button>
			<button class="nav-btn"
				onclick="location.href='<%=request.getContextPath()%>/manager?tab=leave'">
				Leave Requests</button>
			<button class="nav-btn" onclick="showSection('performance')">
				Performance matrix</button>
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

			<!-- ===== Performance Matrix ===== -->
			<div class="box centered-box" id="performance" style="display: none;">
				<h3>
					<i class="fa-solid fa-chart-line"></i> Performance Matrix
				</h3>

				<form id="performanceForm"
					action="<%=request.getContextPath()%>/submitPerformance"
					method="post">

					<!-- Employee Dropdown -->
					<select class="form-control" name="employee" required>
						<option value="">Select Employee</option>
						<%
						List<User> teamPerf = (List<User>) request.getAttribute("teamList");
						if (teamPerf != null) {
							for (User u : teamPerf) {
						%>
						<option value="<%=u.getUsername()%>">
							<%=u.getFullname()%> (<%=u.getUsername()%>)
						</option>
						<%
						}
						}
						%>
					</select>

					<!-- Rating -->
					<div class="radio-group">
						<label><input type="radio" name="rating"
							value="EXCELLENCE" required> Excellence</label> <label><input
							type="radio" name="rating" value="GOOD"> Good</label> <label><input
							type="radio" name="rating" value="AVERAGE"> Average</label> <label><input
							type="radio" name="rating" value="BELOW_AVERAGE"> Below
							Average</label>
					</div>

					<button class="primary-btn" type="submit">Submit
						Performance</button>
				</form>
			</div>

			<!-- ===== Schedule Meeting ===== -->
			<div class="box" id="schedulemeeting" style="display: none;">
				<h3>Schedule Meeting</h3>

				<!-- ===== Schedule Form ===== -->
				<form id="scheduleMeetingForm"
					action="<%=request.getContextPath()%>/schedulemeeting"
					method="post">

					<input class="form-control" type="text" name="title"
						placeholder="Meeting Title" required>

					<textarea class="form-control" name="description"
						placeholder="Meeting Description" rows="3" required></textarea>

					<label>Start Time</label> <input class="form-control"
						type="datetime-local" name="startTime" required> <label>End
						Time</label> <input class="form-control" type="datetime-local"
						name="endTime" required> <label>Meeting Link
						(optional)</label> <input class="form-control" type="text"
						name="meetingLink" placeholder="Zoom / Google Meet link">

					<button class="primary-btn" type="submit">Schedule Meeting
					</button>
				</form>

				<hr style="margin: 30px 0;">

				<!-- ===== Today’s Meetings (INSIDE SAME TAB) ===== -->
				<h3>
					<i class="fa-solid fa-calendar-check"></i> Today’s Meetings
				</h3>

				<%
				List<com.smartoffice.model.Meeting> todayMeetings = (List<com.smartoffice.model.Meeting>) request
						.getAttribute("todayMeetings");

				if (todayMeetings != null && !todayMeetings.isEmpty()) {
					for (com.smartoffice.model.Meeting m : todayMeetings) {
				%>

				<div class="employee-card">
					<div class="emp-header">
						<i class="fa-solid fa-video"></i> <span class="emp-name"><%=m.getTitle()%></span>
					</div>

					<div class="emp-body">
						<div>
							<b>Start:</b>
							<%=m.getStartTime()%></div>
						<div>
							<b>End:</b>
							<%=m.getEndTime()%></div>

						<%
						if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {
						%>
						<div>
							<a href="<%=m.getMeetingLink()%>" target="_blank"> Join
								Meeting </a>
						</div>
						<%
						}
						%>
					</div>
				</div>

				<%
				}
				} else {
				%>
				<p>No meetings scheduled for today.</p>
				<%
				}
				%>
			</div>

			<!-- ===== Team Attendance ===== -->
			<div class="box" id="attendance" style="display: none;">
				<div class="team-attendance-header">
					<h3 class="team-title">Team Attendance (Today)</h3>

					<div class="export-actions">
						<form action="<%=request.getContextPath()%>/exportTeamAttendance"
							method="get">
							<button type="submit" class="export-btn">
								<i class="fa-solid fa-file-export"></i> Export Attendance
							</button>
						</form>

						<form action="<%=request.getContextPath()%>/exportTeamPerformance"
							method="get">
							<button type="submit" class="export-btn">
								<i class="fa-solid fa-file-export"></i> Export Performance
							</button>
						</form>
					</div>
				</div>

				<div class="employee-grid">
					<%
					List<TeamAttendance> teamAttendance = (List<TeamAttendance>) request.getAttribute("teamAttendance");

					if (teamAttendance != null && !teamAttendance.isEmpty()) {
						for (TeamAttendance ta : teamAttendance) {
					%>


					<div class="employee-card">
						<div class="emp-header">
							<i class="fa-solid fa-user"></i> <span class="emp-name"><%=ta.getFullName()%></span>
							<span class="emp-status"><%=ta.getStatus()%></span>
						</div>

						<div class="emp-body">
							<div>
								<b>Punch In:</b>
								<%=ta.getPunchIn() != null ? ta.getPunchIn() : "--"%></div>
							<div>
								<b>Punch Out:</b>
								<%=ta.getPunchOut() != null ? ta.getPunchOut() : "--"%></div>
						</div>
					</div>



					<%
					}
					} else {
					%>
					<p>No attendance data available for today.</p>
					<%
					}
					%>

				</div>
			</div>


			<!-- ===== Leave Requests ===== -->
			<div class="box centered-box" id="leave" style="display: none;">
				<h3>Leave Requests</h3>

				<%
				List<LeaveRequest> leaveRequests = (List<LeaveRequest>) request.getAttribute("leaveRequests");

				if (leaveRequests != null && !leaveRequests.isEmpty()) {
					for (LeaveRequest lr : leaveRequests) {
				%>

				<div class="employee-card">
					<div class="emp-header">
						<i class="fa-solid fa-calendar-xmark"></i> <span class="emp-name"><%=lr.getUsername()%></span>
						<span class="emp-status"><%=lr.getStatus()%></span>
					</div>

					<div class="emp-body">
						<div>
							<b>Type:</b>
							<%=lr.getLeaveType()%></div>
						<div>
							<b>From:</b>
							<%=lr.getFromDate()%></div>
						<div>
							<b>To:</b>
							<%=lr.getToDate()%></div>
						<div>
							<b>Reason:</b>
							<%=lr.getReason()%></div>
					</div>

					<%
					if ("PENDING".equals(lr.getStatus())) {
					%>
					<form action="leave-approval" method="post">
						<input type="hidden" name="leaveId" value="<%=lr.getId()%>">

						<button class="primary-btn" name="action" value="approve">
							Approve</button>

						<button class="reject-btn" name="action" value="reject">
							Reject</button>
					</form>
					<%
					}
					%>
				</div>

				<%
				}
				} else {
				%>
				<p>No leave requests.</p>
				<%
				}
				%>
			</div>


			<!-- Calendar -->
			<div class="box centered-box" id="calendarSection"
				style="display: none;">
				<h3>
					<i class="fa-solid fa-calendar-days"></i> Company Calendar
				</h3>

				<iframe id="calendarFrame" src=""
					style="width: 100%; height: 600px; border: none;"></iframe>

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
					<select class="form-control" name="employeeUsername" required>
						<option value="">Select Employee</option>

						<%
						String assignEmployee = (String) request.getAttribute("assignEmployee");

						if (team != null && !team.isEmpty()) {
							for (User u : team) {
						%>
						<option value="<%=u.getUsername()%>"
							<%=u.getUsername().equals(assignEmployee) ? "selected" : ""%>>
							<%=u.getUsername()%>
						</option>
						<%
						}
						} else {
						%>
						<option disabled>No employees available</option>
						<%
						}
						%>
					</select>

					<textarea class="form-control" name="taskDesc" rows="4"
						placeholder="Task Description" required></textarea>
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

						if (team != null && !team.isEmpty()) {
							for (User u : team) {
						%>
						<option value="<%=u.getUsername()%>"
							<%=u.getUsername().equals(viewEmployee) ? "selected" : ""%>>
							<%=u.getFullname()%> (<%=u.getUsername()%>)
						</option>
						<%
						}
						} else {
						%>
						<option disabled>No employees available</option>
						<%
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
	<script>
setTimeout(() => {
    const toast = document.getElementById("toast");
    if (toast) toast.remove();
}, 4200);
</script>

	<script>
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const tab = params.get("tab");
    const success = params.get("success");

    // ---- Restore correct tab ----
    if (tab) {
        showSection(tab);
    } else {
        showSection("selfAttendance"); // default
    }

    // ---- Success toast (optional, safe) ----
    if (success === "MeetingScheduled") {
        const toast = document.createElement("div");
        toast.className = "toast-success";
        toast.innerHTML = `
            <i class="fa-solid fa-circle-check"></i>
            <span>Meeting scheduled successfully</span>
        `;
        document.body.appendChild(toast);

        setTimeout(() => toast.remove(), 4000);
    }

    // ---- Clean URL (prevents reload issues) ----
    if (tab || success) {
        setTimeout(() => {
            window.history.replaceState({}, document.title, window.location.pathname);
        }, 100);
    }
    
    if (params.get("success") === "PerformanceSaved") {
        const toast = document.createElement("div");
        toast.className = "toast-success";
        toast.innerHTML = `
            <i class="fa-solid fa-circle-check"></i>
            <span>Performance submitted successfully</span>
        `;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }
    
 // ---- Assign Task messages ----
    if (params.get("success") === "TaskAssigned") {
        const toast = document.createElement("div");
        toast.className = "toast-success";
        toast.innerHTML = `
            <i class="fa-solid fa-circle-check"></i>
            <span>Task assigned successfully</span>
        `;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }

    if (params.get("error") === "SelectEmployee") {
        alert("Please select an employee");
    }
    if (params.get("error") === "InvalidEmployee") {
        alert("You cannot assign task to this employee");
    }
    if (params.get("error") === "EmptyTask") {
        alert("Task description cannot be empty");
    }
    if (params.get("error") === "AlreadyRated") {
        const toast = document.createElement("div");
        toast.className = "toast-success";
        toast.innerHTML = `
            <i class="fa-solid fa-circle-exclamation"></i>
            <span>Performance already submitted for this employee this month</span>
        `;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }
    
});
</script>

	<script>
document.getElementById("meetingForm").addEventListener("submit", function (e) {
    e.preventDefault();

    const form = e.target;
    const formData = new FormData(form);

    fetch("schedulemeeting", {
        method: "POST",
        body: formData
    })
    .then(res => res.text())
    .then(text => {
        switch (text.trim()) {
            case "SUCCESS":
                showToast("Meeting scheduled successfully ✅");
                form.reset();
                break;

            case "INVALID":
                showToast("Please fill all required fields ❌");
                break;

            case "INVALID_TIME":
                showToast("End time must be after start time ⏰");
                break;

            default:
                showToast("Something went wrong ❌");
        }
    })
    .catch(() => {
        showToast("Server error ❌");
    });
});

function showToast(message) {
    const toast = document.createElement("div");
    toast.textContent = message;

    Object.assign(toast.style, {
        position: "fixed",
        bottom: "20px",
        right: "20px",
        background: "#1f2933",
        color: "#fff",
        padding: "12px 18px",
        borderRadius: "6px",
        fontSize: "14px",
        boxShadow: "0 4px 10px rgba(0,0,0,0.2)",
        zIndex: "9999",
        opacity: "0",
        transition: "opacity 0.3s ease"
    });

    document.body.appendChild(toast);

    requestAnimationFrame(() => toast.style.opacity = "1");

    setTimeout(() => {
        toast.style.opacity = "0";
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}
</script>

	<script>

function openSettings() {

    document.getElementById("settingsPanel").style.right = "0";

    document.getElementById("overlay").style.display = "block";

}
 
function closeSettings() {

    document.getElementById("settingsPanel").style.right = "-320px";

}
 
function openChangePassword() {

    document.getElementById("passwordModal").style.display = "block";

    document.getElementById("overlay").style.display = "block";

}
 
function closeChangePassword() {

    document.getElementById("passwordModal").style.display = "none";

}
 
function toggleTheme() {

    document.body.classList.toggle("dark-theme");

}
 
function closeAll() {

    closeSettings();

    closeChangePassword();

    document.getElementById("overlay").style.display = "none";

}
</script>


</body>
</html>
