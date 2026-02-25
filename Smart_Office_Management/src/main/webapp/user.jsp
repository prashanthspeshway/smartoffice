<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.User" %>
<%
User userObj = (User) request.getAttribute("user");
%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

String email = (String) session.getAttribute("email");
String role = (String) session.getAttribute("role");
String phone = (String) session.getAttribute("phone");

java.sql.Timestamp punchIn = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");

String status = "Not Punched In";
if (punchIn != null && punchOut == null)
	status = "Punched In";
if (punchOut != null)
	status = "Punched Out";
%>

<%
List<LeaveRequest> myLeaves = (List<LeaveRequest>) request.getAttribute("myLeaves");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Employee Dashboard</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
body {
	margin: 0;
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f4f6f8;
}

/* ===== Top Bar ===== */
.top-bar {
	display: flex;
	align-items: center;
	padding: 15px 30px;
	background: #1f2933;
	color: white;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-left: auto;
}

.icon-btn {
	background: transparent;
	border: none;
	color: white;
	font-size: 18px;
	cursor: pointer;
}

.logout-btn {
	background: #ef4444;
	border: none;
	padding: 8px 16px;
	border-radius: 6px;
	color: white;
	cursor: pointer;
}

/* ===== Layout ===== */
.container {
	display: flex;
	height: calc(100vh - 60px);
}

.left-panel {
	width: 240px;
	background: white;
	padding: 25px;
	box-shadow: 2px 0 8px rgba(0, 0, 0, 0.08);
}

.nav-btn {
	width: 100%;
	padding: 12px;
	margin-bottom: 12px;
	border: none;
	border-radius: 6px;
	background: #3b82f6;
	color: white;
	cursor: pointer;
}

.right-panel {
	flex: 1;
	padding: 30px;
	overflow-y: auto;
}

/* ===== Card ===== */
.box {
	max-width: auto;
	background: white;
	padding: 28px;
	border-radius: 14px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

/* ===== Attendance ===== */
.status-badge {
	display: inline-block;
	padding: 6px 16px;
	border-radius: 20px;
	font-size: 14px;
	font-weight: bold;
	margin: 14px 0;
}

.status-badge.in {
	background: #dcfce7;
	color: #166534;
}

.status-badge.out {
	background: #fee2e2;
	color: #7f1d1d;
}

.status-badge.none {
	background: #e5e7eb;
	color: #374151;
}

.time-card {
	display: flex;
	align-items: center;
	gap: 12px;
	background: #f1f5f9;
	padding: 14px;
	border-radius: 8px;
	margin-bottom: 12px;
}

.punch-actions {
	display: flex;
	justify-content: center;
	gap: 16px;
	margin-top: 20px;
}

.punch-in-btn {
	background: #16a34a;
}

.punch-out-btn {
	background: #dc2626;
}

button {
	padding: 10px 18px;
	border-radius: 6px;
	border: none;
	cursor: pointer;
	color: white;
	font-weight: 600;
}

button:disabled {
	background: #9ca3af;
	cursor: not-allowed;
}

/* ===== Tasks ===== */
.task-card {
	display: flex;
	justify-content: space-between;
	align-items: center;
	background: #eef2ff;
	padding: 16px;
	border-radius: 12px;
	margin-bottom: 16px;
	border: 1px solid #c7d2fe;
}

.task-left {
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 500;
}

.task-status {
	padding: 6px 14px;
	border-radius: 14px;
	font-size: 12px;
	font-weight: bold;
}

.task-status.pending {
	background: #fde68a;
	color: #92400e;
}

.task-status.done {
	background: #bbf7d0;
	color: #166534;
}

.task-btn {
	background: #2563eb;
}

/* ===== Leave ===== */
.leave-form {
	display: flex;
	flex-direction: column;
	gap: 14px;
}

.leave-form label {
	font-weight: 600;
}

.leave-form input, .leave-form select, .leave-form textarea {
	padding: 12px;
	border-radius: 8px;
	border: 1px solid #d1d5db;
}

.leave-form textarea {
	resize: none;
	height: 90px;
}

.apply-leave-btn {
	background: #16a34a;
}

/* ===== Settings Popup ===== */
.popup {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.45);
	z-index: 999;
}

.popup-content {
	background: white;
	width: 420px;
	padding: 30px;
	border-radius: 14px; /* FIXED */
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	box-sizing: border-box;
	border-radius: 14px;
}

.popup-content h3 {
	text-align: center;
	margin-bottom: 20px;
}

.popup-content form {
	display: flex;
	flex-direction: column;
	gap: 14px;
}

.popup-content input, .popup-content button {
	width: 100%;
	padding: 12px;
	border-radius: 8px;
	font-size: 14px;
	box-sizing: border-box;
}

.popup-content input {
	border: 1px solid #d1d5db;
}

.update-btn {
	background: #2563eb;
	color: white;
	font-weight: 600;
}

#settingsMenu button {
	width: 100%;
	padding: 12px;
	border-radius: 8px;
	font-size: 14px;
	font-weight: 600;
}

.cancel-btn {
	background: #6b7280;
	color: white;
	font-weight: 600;
}

/* ===== Toast Notification ===== */
.toast {
	position: fixed;
	top: 80px;
	right: 500px;
	background: #16a34a;
	color: white;
	padding: 14px 20px;
	border-radius: 10px;
	font-weight: 600;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
	opacity: 0;
	z-index: 2000;
}

.toast.show {
	opacity: 1;
	animation: slideIn 0.4s ease, fadeOut 0.4s ease 3.6s forwards;
}

.toast.error {
	background: #dc2626;
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
.task-status.out {
	background: #fecaca;
	color: #7f1d1d;
}

/* notification */
.notification-panel {
	position: fixed;
	bottom: 30px;
	right: -380px;
	width: 350px;
	height: auto;
	background: #ffffff;
	box-shadow: -3px 0 10px rgba(0, 0, 0, 0.15);
	border-radius: 14px;
	transition: right 0.3s ease-in-out;
	z-index: 1000;
	font-family: Arial, sans-serif;
}

.notification-panel.show {
	right: 25px;
}

.notification-header {
	background: #f5fa5c;
	color: black;
	padding: 15px;
	border-radius: 14px 14px 0 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.notification-header button {
	background: none;
	border: none;
	color: black;
	font-size: 18px;
	cursor: pointer;
}

.notification-list {
	padding: 15px;
	max-height: 250px; /* Adjust as needed */
	overflow-y: auto;
}

.notification-item {
	background: #f3f4f6;
	padding: 12px;
	margin-bottom: 10px;
	border-left: 4px solid #2563eb;
	border-radius: 4px;
	font-size: 14px;
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
	
	<!-- SELF PROFILE MODAL -->
<div id="profileModal" class="password-modal">
    <div class="password-box">
        <div class="password-header">
            <h4>My Profile</h4>
            <span class="close-btn" onclick="closeProfile()">✖</span>
        </div>

        <div class="password-body">
        <div class="time-card">
        Name: <b><%= userObj != null ? userObj.getFullname() : "--" %></b>
    </div>
     <div class="time-card">
        Username: <b><%= userObj != null ? userObj.getUsername() : "--" %></b>
    </div>
             <div class="time-card">  
              Email: <b><%=userObj != null ? userObj.getEmail() : "--"%></b></div>
              <div class="time-card">  
             Role: <b><%=userObj != null ? userObj.getRole() : "--"%></b></div>
<div class="time-card">          
Phone: <b><%=userObj != null ? userObj.getPhone() : "--"%></b></div>

        </div>
    </div>
</div>
	





	<div class="top-bar">
		<h2>Smart Office • Employee Dashboard</h2>
		<div class="user-area">
			Welcome, <b><%=username%></b>
			<button class="icon-btn" onclick="openSettings()">
				<i class="fa-solid fa-gear"></i>
			</button>
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">Logout</button>
			</a>
		</div>
	</div>

	<div class="container">

		<div class="left-panel">
			<button class="nav-btn" onclick="showAttendance()">Attendance</button>
			<button class="nav-btn" onclick="showTasks()">Tasks</button>
			<button class="nav-btn" onclick="showLeave()">Leave</button>
			<button class="nav-btn" onclick="showMeetings()">Meetings</button>
			<button class="nav-btn" onclick="openCalendar()">Calendar</button>
			<button class="nav-btn" onclick="openNotifications()">Notification</button>

		</div>

		<div class="right-panel">

			<!-- Attendance -->
			<div class="box" id="attendanceSection">
				<h3>
					<i class="fa-solid fa-clock"></i> Attendance
				</h3>

				<div
					class="status-badge <%=status.equals("Punched In") ? "in" : status.equals("Punched Out") ? "out" : "none"%>">
					<%=status%>
				</div>

				<div class="time-card">
					Punch In: <b><%=punchIn != null ? punchIn : "--"%></b>
				</div>
				<div class="time-card">
					Punch Out: <b><%=punchOut != null ? punchOut : "--"%></b>
				</div>

				<div class="punch-actions">
					<form action="attendance" method="post">
						<input type="hidden" name="action" value="punchin">
						<button class="punch-in-btn"
							<%=punchIn != null ? "disabled" : ""%>>Punch In</button>
					</form>

					<form action="attendance" method="post">
						<input type="hidden" name="action" value="punchout">
						<button class="punch-out-btn"
							<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>Punch
							Out</button>
					</form>
				</div>
			</div>

			<!-- Tasks -->
			<div class="box" id="taskSection" style="display: none;">
				<h3>
					<i class="fa-solid fa-list-check"></i> My Tasks
				</h3>

				<%
				List<Task> tasks = (List<Task>) request.getAttribute("tasks");

				if (tasks == null || tasks.isEmpty()) {
				%>
				<p>No tasks assigned.</p>
				<%
				} else {
				for (Task t : tasks) {
				%>

				<div class="task-card">
					<div class="task-left">
						<i class="fa-solid fa-file-lines"></i>
						<div>
							<b><%=t.getDescription()%></b><br> <small>Assigned
								by: <%=t.getAssignedBy()%></small>
						</div>
					</div>

					<div class="task-actions">

						<%
						if (!"COMPLETED".equals(t.getStatus())) {
						%>

						<span class="task-status pending">PENDING</span>

						<form action="updateTaskStatus" method="post"
							style="display: inline;">
							<input type="hidden" name="taskId" value="<%=t.getId()%>">
							<input type="hidden" name="status" value="COMPLETED">
							<button class="task-btn">Done</button>
						</form>

						<%
						} else {
						%>

						<span class="task-status done">✔ Completed</span>

						<%
						}
						%>

					</div>

				</div>

				<%
				}
				}
				%>
			</div>

			<!-- Meetings -->

			<div class="box" id="meetingSection" style="display: none;">
				<h3>
					<i class="fa-solid fa-video"></i> Scheduled Meetings
				</h3>

				<%
				List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");

				if (meetings == null || meetings.isEmpty()) {
				%>
				<p>No upcoming meetings.</p>
				<%
				} else {
				for (Meeting m : meetings) {
				%>

				<div class="task-card">
					<div class="task-left">
						<i class="fa-solid fa-users"></i>
						<div>
							<b><%=m.getTitle()%></b><br> <small><%=m.getDescription()%></small><br>
							<small> 🕒 <%=m.getStartTime()%> → <%=m.getEndTime()%>
							</small>
						</div>
					</div>

					<%
					if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {
					%>
					<a href="<%=m.getMeetingLink()%>" target="_blank">
						<button class="task-btn">Join</button>
					</a>
					<%
					}
					%>
				</div>

				<%
				}
				}
				%>
			</div>

			<!-- Calendar -->
			<div class="box" id="calendarSection" style="display: none;">
				<h3>
					<i class="fa-solid fa-calendar-days"></i> Company Calendar
				</h3>

				<iframe id="calendarFrame" src=""
					style="width: 100%; height: 600px; border: none;"></iframe>

			</div>
			<!-- Leave -->
			<div class="box" id="leaveSection" style="display: none;">
				<h3>
					<i class="fa-solid fa-calendar-days"></i> Leave
				</h3>

				<!-- Leave Tabs -->
				<div style="display: flex; gap: 12px; margin-bottom: 20px;">
					<button class="nav-btn" style="flex: 1;" onclick="showApplyLeave()">Apply
						Leave</button>
					<button class="nav-btn" style="flex: 1; background: #6b7280;"
						onclick="showMyLeaves()">My Leave Requests</button>
				</div>

				<!-- Apply Leave -->
				<div id="applyLeaveSection">
					<form class="leave-form" action="applyLeave" method="post">
						<label>Leave Type</label> <select name="leaveType" required>
							<option value="">Select</option>
							<option>Casual Leave</option>
							<option>Sick Leave</option>
							<option>Earned Leave</option>
						</select> <label>From Date</label> <input type="date" name="fromDate"
							required> <label>To Date</label> <input type="date"
							name="toDate" required> <label>Reason</label>
						<textarea name="reason" required></textarea>

						<button class="apply-leave-btn">Apply Leave</button>
					</form>
				</div>

				<!-- My Leave Requests -->
				<div id="myLeaveSection" style="display: none;">
					<h3 style="margin-top: 10px;">
						<i class="fa-solid fa-list"></i> My Leave Requests
					</h3>

					<%
					if (myLeaves == null || myLeaves.isEmpty()) {
					%>
					<p>No leave requests found.</p>
					<%
					} else {
					for (LeaveRequest lr : myLeaves) {
					%>

					<div class="task-card">
						<div class="task-left">
							<i class="fa-solid fa-plane-departure"></i>
							<div>
								<b><%=lr.getLeaveType()%></b><br> <small><%=lr.getFromDate()%>
									→ <%=lr.getToDate()%></small>
							</div>
						</div>

						<%
						String st = lr.getStatus();
						String cls = "pending";
						if ("APPROVED".equalsIgnoreCase(st))
							cls = "done";
						if ("REJECTED".equalsIgnoreCase(st))
							cls = "out";
						%>

						<span class="task-status <%=cls%>"><%=st%></span>
					</div>

					<%
					}
					}
					%>
				</div>
			</div>


		</div>
	</div>


	<div id="notificationPanel" class="notification-panel">
		<div class="notification-header">
			<span>🔔 Smart Office Notifications</span>
			<button onclick="closeNotifications()">✖</button>
		</div>

		<div class="notification-list">
			<%
			List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");

			if (notifications != null && !notifications.isEmpty()) {
				for (Notification n : notifications) {
			%>
			<div class="notification-item" id="notif-<%=n.getId()%>">
				🔔
				<%=n.getMessage()%><br> <small>By <%=n.getCreatedBy()%></small>

				<div style="margin-top: 8px; text-align: right;">
					<button
						style="background: #2563eb; color: white; border: none; padding: 4px 10px; border-radius: 6px; cursor: pointer; font-size: 12px;"
						onclick="markAsRead(<%=n.getId()%>)">Mark as read</button>
				</div>
			</div>
			<%
			}
			} else {
			%>
			<div class="notification-item">No notifications</div>
			<%
			}
			%>
		</div>
	</div>

	<!-- Toast Notification -->
	<div id="toast" class="toast"></div>



	<script>
    // ===== Section Helpers =====
   function hideAllSections() {
    document.getElementById("attendanceSection").style.display = "none";
    document.getElementById("taskSection").style.display = "none";
    document.getElementById("leaveSection").style.display = "none";
    document.getElementById("calendarSection").style.display = "none";
    document.getElementById("meetingSection").style.display = "none";
}

function showAttendance() {
    hideAllSections();
    document.getElementById("attendanceSection").style.display = "block";
}

function showTasks() {
    hideAllSections();
    document.getElementById("taskSection").style.display = "block";
}

function showMeetings() {
    hideAllSections();
    document.getElementById("meetingSection").style.display = "block";
}

function showLeave() {
    hideAllSections();
    document.getElementById("leaveSection").style.display = "block";
}

function openCalendar() {
    hideAllSections();
    document.getElementById("calendarSection").style.display = "block";
    document.getElementById("calendarFrame").src = "calendar.jsp";
}

    

    function showCalendar() {
        hideAllSections();
        calendarSection.style.display = "block";
        document.getElementById("calendarFrame").src = "calendar.jsp";
    }

    function showApplyLeave() {
        document.getElementById("applyLeaveSection").style.display = "block";
        document.getElementById("myLeaveSection").style.display = "none";
    }

    function showMyLeaves() {
        document.getElementById("applyLeaveSection").style.display = "none";
        document.getElementById("myLeaveSection").style.display = "block";
    }

       function openCalendar() {
			hideAllSections();
			calendarSection.style.display = "block";
			document.getElementById("calendarFrame").src = "calendar.jsp";
		}

    // ===== Notifications =====
    function openNotifications() {
        document.getElementById("notificationPanel").classList.add("show");
    }

    function closeNotifications() {
        document.getElementById("notificationPanel").classList.remove("show");
    }

    // ===== Toast =====
    function showToast(message, isError) {
    if (!message) return; // 🔒 SAFETY

    const toast = document.getElementById("toast");
    toast.innerText = message;
    toast.className = "toast show" + (isError ? " error" : "");

    setTimeout(() => {
        toast.className = "toast";
        toast.innerText = "";
    }, 4000);
}

    // ===== URL PARAM HANDLING (IMPORTANT PART) =====
    const params = new URLSearchParams(window.location.search);
    const tab = params.get("tab");
    const sub = params.get("sub");

    // ---- SUCCESS ----
    if (params.has("success")) {
        const success = params.get("success");

        if (success === "LeaveApplied") {
            showToast("Leave applied successfully", false);
        } else if (success === "PasswordUpdated") {
            showToast("Password updated successfully", false);
        }
    }

    // ---- ERROR ----
    if (params.has("error")) {
        const error = params.get("error");

        if (error === "WrongOldPassword") {
            showToast("Old password is incorrect", true);
        } else if (error === "PasswordMismatch") {
            showToast("Passwords do not match", true);
        } else if (error === "HolidayAttendance") {
            showToast("Today is a holiday. Attendance not allowed.", true);
        } else {
            showToast("Something went wrong", true);
        }
    }

    // ---- TAB RESTORE LOGIC ----
    if (tab === "leave") {
        showLeave();

        if (sub === "apply") {
            showApplyLeave();
        } else if (sub === "myLeaves") {
            showMyLeaves();
        }
    }
    else if (tab === "tasks") {
        showTasks();
    }
    else if (tab === "meetings") {
        showMeetings();
    }
    else if (tab === "calendar") {
    	openCalendar();
    }
    else {
        // Default view
        showAttendance();
    }

    // ---- Clean URL ----
    if (params.has("success") || params.has("error")) {
        setTimeout(() => {
            window.history.replaceState({}, document.title, window.location.pathname);
        }, 100);
    }
</script>

	<script>

function openSettings() {

    document.getElementById("settingsPanel").style.right = "0";

    

}
 
function closeSettings() {

    document.getElementById("settingsPanel").style.right = "-320px";

}
 
function openChangePassword() {

    document.getElementById("passwordModal").style.display = "block";


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


}
function openProfile() {
    closeSettings(); // close sliding panel
    document.getElementById("profileModal").style.display = "block";
}

function closeProfile() {
    document.getElementById("profileModal").style.display = "none";
}

function markAsRead(notificationId) {

    fetch("markNotificationRead?id=" + notificationId, {
        method: "POST"
    })
    .then(response => {
        if (response.ok) {
            // Remove notification from UI
            const el = document.getElementById("notif-" + notificationId);
            if (el) el.remove();
        }
    })
    .catch(err => console.error(err));
}

</script>

</body>
</html>