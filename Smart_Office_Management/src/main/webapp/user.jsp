<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>

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
}

/* ===== Card ===== */
.box {
	max-width: 620px;
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
	animation: slideIn 0.4s ease, fadeOut 0.4s ease 3.6s forwards;
	/* 	transform: translateY(-20px); */
	transition: all 0.4s ease;
	z-index: 2000;
}

.toast.show {
	opacity: 1;
	/* 	transform: translateY(0); */
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
    top: 60px;
    right: -380px;
    width: 350px;
    height: 100%;
    background: #ffffff;
    box-shadow: -3px 0 10px rgba(0,0,0,0.15);
    transition: right 0.3s ease-in-out;
    z-index: 1000;
    font-family: Arial, sans-serif;
}
 
.notification-panel.show {
    right: 0;
}
 
.notification-header {
    background: #1f2937;
    color: #fff;
    padding: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
 
.notification-header button {
    background: none;
    border: none;
    color: #fff;
    font-size: 18px;
    cursor: pointer;
}
 
.notification-list {
    padding: 15px;
}
 
.notification-item {
    background: #f3f4f6;
    padding: 12px;
    margin-bottom: 10px;
    border-left: 4px solid #2563eb;
    border-radius: 4px;
    font-size: 14px;
}
 
 
</style>
</head>

<body>

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
			<a href="<%=request.getContextPath()%>/viewMeetings?tab=meetings">
				<button class="nav-btn">Meetings</button>
			</a>
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

	<!-- Settings Popup -->
	<div class="popup" id="settingsPopup">
		<div class="popup-content">

			<!-- Settings Menu -->
			<div id="settingsMenu">
				<h3>Settings</h3>
				<button class="update-btn" onclick="showProfile()">View
					Profile</button>
				<br> <br>
				<button class="apply-leave-btn" onclick="showPassword()">Change
					Password</button>
				<br> <br>
				<button class="cancel-btn" onclick="closeSettings()">Close</button>
			</div>

			<!-- View Profile -->
			<div id="profileSection" style="display: none;">
				<h3>My Profile</h3>

				<div class="time-card">
					Username: <b><%=username%></b>
				</div>
				<div class="time-card">
					Email: <b><%=email != null ? email : "--"%></b>
				</div>
				<div class="time-card">
					Phone: <b><%=phone != null ? phone : "--"%></b>
				</div>
				<div class="time-card">
					Role: <b><%=role != null ? role : "User"%></b>
				</div>

				<button class="cancel-btn" onclick="backToSettings()">Back</button>
			</div>

			<!-- Change Password -->
			<div id="passwordSection" style="display: none;">
				<h3>Change Password</h3>

				<form action="changePassword" method="post">
					<input type="password" name="oldPassword"
						placeholder="Old Password" required> <input
						type="password" name="newPassword" placeholder="New Password"
						required> <input type="password" name="confirmPassword"
						placeholder="Confirm Password" required>

					<button class="update-btn">Update Password</button>
					<button type="button" class="cancel-btn" onclick="backToSettings()">Back</button>
				</form>
			</div>

		</div>
	</div>

	<div id="notificationPanel" class="notification-panel">
		<div class="notification-header">
			<span>🔔 Smart Office Notifications</span>
			<button onclick="closeNotifications()">✖</button>
		</div>

		<div class="notification-list">
			<div class="notification-item">📅 Meeting Reminder: Project
				Sync at 3:00 PM</div>
			<div class="notification-item">📝 Approval Needed: Leave
				request from Rahul</div>
			<div class="notification-item">⚠️ System Alert: Printer 2 is
				out of paper</div>
			<div class="notification-item">📢 Announcement: Office will be
				closed on Friday</div>
			<div class="notification-item">✅ Task Update: Monthly report
				submitted successfully</div>
		</div>
	</div>

	<!-- Toast Notification -->
	<div id="toast" class="toast"></div>



	<script>
	function hideAllSections() {
		attendanceSection.style.display = "none";
		taskSection.style.display = "none";
		leaveSection.style.display = "none";
		calendarSection.style.display = "none";
		meetingSection.style.display = "none";
	}
	
	function openNotifications() {
        document.getElementById("notificationPanel").classList.add("show");
    }

    function closeNotifications() {
        document.getElementById("notificationPanel").classList.remove("show");
    }

	function showAttendance() {
		hideAllSections();
		attendanceSection.style.display = "block";
	}

	function showTasks() {
		hideAllSections();
		taskSection.style.display = "block";
	}
	
	function showMeetings() {
	    hideAllSections();
	    meetingSection.style.display = "block";
	}
	
	function showApplyLeave() {
	    document.getElementById("applyLeaveSection").style.display = "block";
	    document.getElementById("myLeaveSection").style.display = "none";
	}

	function showMyLeaves() {
	    document.getElementById("applyLeaveSection").style.display = "none";
	    document.getElementById("myLeaveSection").style.display = "block";
	}

	function showLeave() {
		hideAllSections();
		leaveSection.style.display = "block";
	}

	function showCalendar() {
		hideAllSections();
		calendarSection.style.display = "block";
	}
		function completeTask(btn) {
			btn.disabled = true;
			btn.previousElementSibling.className = "task-status done";
			btn.previousElementSibling.innerText = "Completed";
		}
		function openSettings() {
			settingsPopup.style.display = "block";
			backToSettings();
		}

		function closeSettings() {
			settingsPopup.style.display = "none";
		}

		function showProfile() {
			settingsMenu.style.display = "none";
			profileSection.style.display = "block";
			passwordSection.style.display = "none";
		}

		function showPassword() {
			settingsMenu.style.display = "none";
			profileSection.style.display = "none";
			passwordSection.style.display = "block";
		}

		function backToSettings() {
			settingsMenu.style.display = "block";
			profileSection.style.display = "none";
			passwordSection.style.display = "none";
		}
		function showToast(message, isError) {
			const toast = document.getElementById("toast");
			toast.innerText = message;

			toast.className = "toast show" + (isError ? " error" : "");

			setTimeout(() => {
				toast.className = "toast";
			}, 3500);
		}

		// Read URL parameters
		const params = new URLSearchParams(window.location.search);

		if (params.has("success")) {
			if (params.get("success") === "PasswordUpdated") {
				showToast("Password updated successfully", false);
			}
		}

		if (params.has("error")) {
			const error = params.get("error");

			if (error === "WrongOldPassword") {
				showToast("Old password is incorrect", true);
			} else if (error === "PasswordMismatch") {
				showToast("Passwords do not match", true);
			}
			else if (error === "HolidayAttendance") {
		        showToast("Today is a holiday. Attendance not allowed.", true);
		    }else {
				showToast("Something went wrong", true);
			}
		}
		if (params.has("success") || params.has("error")) {
			setTimeout(() => {
				window.history.replaceState({}, document.title, window.location.pathname);
			}, 100);
		}
		
		// Auto-open Tasks tab after redirect
		const tab = new URLSearchParams(window.location.search).get("tab");

		if (tab === "tasks") {
		    showTasks();
		}
		else if (tab === "meetings") {
			showMeetings();
		}
		else if (tab === "calendar") {
			openCalendar();
		}
		function openCalendar() {
		    hideAllSections();   // hide attendance/tasks/leave
		    document.getElementById("calendarSection").style.display = "block";
		    document.getElementById("calendarFrame").src = "calendar.jsp";
		}

	</script>

</body>
</html>