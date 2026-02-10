<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.User"%>

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
.primary-btn {
	background: #22c55e;
	color: #fff;
	padding: 10px 22px;
	border: none;
	border-radius: 22px;
	cursor: pointer;
}

.primary-btn, .reject-btn {
	transition: all 0.2s ease;
	font-weight: 500;
}

.primary-btn:hover:not(:disabled) {
	background: #16a34a;
	transform: translateY(-1px);
	box-shadow: 0 6px 14px rgba(34, 197, 94, 0.35);
}

.reject-btn:hover:not(:disabled) {
	background: #dc2626;
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

.reject-btn {
	background: #ef4444;
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

/* ===== Employee Card ===== */
.employee-card {
	border-left: 4px solid #3b82f6;
	padding: 14px 16px;
	background: linear-gradient(135deg, #f8fafc, #eef2ff); border-left :
	5px solid #2563eb; border-radius : 12px;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
	border-left: 5px solid #2563eb;
	border-radius: 12px;
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

/* ===== Form ===== */
.form-control {
	width: 100%;
	padding: 12px;
	border-radius: 10px;
	border: 1px solid #d1d5db;
	margin-bottom: 15px;
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
			<button class="nav-btn" onclick="showSection('assign')">Assign
				Tasks</button>
			<button class="nav-btn" onclick="showSection('attendance')">Team
				Attendance</button>
			<button class="nav-btn" onclick="showSection('leave')">Leave
				Requests</button>
		</div>

		<!-- ===== Content ===== -->
		<div class="right-panel">

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

				<form action="attendance" method="post" style="display: inline;">
					<input type="hidden" name="action" value="punchin">
					<button class="primary-btn" <%=punchIn != null ? "disabled" : ""%>>Punch
						In</button>
				</form>

				<form action="attendance" method="post" style="display: inline;">
					<input type="hidden" name="action" value="punchout">
					<button class="reject-btn"
						<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
						Punch Out</button>
				</form>
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

			<!-- ===== Assign ===== -->
			<div class="box" id="assign" style="display: none;">
				<h3>Assign Task</h3>
				<input class="form-control" placeholder="Employee Name">
				<textarea class="form-control" rows="4"
					placeholder="Task Description"></textarea>
				<button class="primary-btn">Assign Task</button>
			</div>

			<!-- ===== Attendance ===== -->
			<div class="box" id="attendance" style="display: none;">
				<h3>Team Attendance</h3>
			</div>

			<!-- ===== Leave ===== -->
			<div class="box" id="leave" style="display: none;">
				<h3>Leave Requests</h3>
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
</script>

</body>
</html>
