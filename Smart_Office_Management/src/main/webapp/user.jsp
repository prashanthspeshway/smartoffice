<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.User"%>
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
	height: 100vh;
	overflow: hidden; /* 🔑 FIX */
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f4f6f8;
}

/* ================= TOP BAR ================= */
.top-bar {
	backdrop-filter: blur(10px);
	background: #e2ebf0;
	border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	padding: 15px 30px;
	display: flex;
	height: 50px;
	justify-content: space-between;
	align-items: center;
}

.top-bar h2 {
	font-size: 22px;
	font-weight: 600;
	color: #2d3748;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 15px;
}

.icon-btn {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
}

.icon-btn i {
	font-size: 16px;
	margin-left: -7px;
}

.logout-btn {
	padding: 8px 14px;
	border-radius: 8px;
	border: none;
	background: #e53e3e;
	color: white;
	cursor: pointer;
}

/* ===== Layout ===== */
.container {
	display: flex;
	height: calc(100vh - 60px);
}

/* ================= SIDEBAR  ================= */
.left-panel {
	width: 250px;
	backdrop-filter: blur(10px);
	background: #e2ebf0;
	border-right: 1px solid rgba(255, 255, 255, 0.3);
	padding: 18px 12px;
}

/* BUTTON */
.nav-btn {
	width: 100%;
	padding: 12px 14px;
	margin-bottom: 10px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 10px;
	color: #2d3748;
	transition: 0.25s;
}

/* Hover */
.nav-btn:hover {
	background: rgba(102, 126, 234, 0.9);
	color: white;
	font-size: 15px;
}

/* Active */
.nav-btn.active {
	background: linear-gradient(135deg, #e7e6eb);
	color: black;
	box-shadow: 0 6px 15px rgba(102, 126, 234, 0.4);
	position: relative;
	font-size: 15px;
}

.nav-btn.active::before {
	content: "";
	position: absolute;
	left: 0;
	top: 10%;
	width: 4px;
	height: 80%;
	background: white;
	border-radius: 2px;
}

/* ===== Card ===== */
.box {
	/* 	background: white; */
	overflow-y: auto;
	overflow-x: hidden;
	padding: 28px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
	height: 100%; /* 🔑 remove fixed height */
}
/* ================= RIGHT PANEL ================= */
.right-panel {
	flex: 1;
	background: #c3cfe2;
	/*     padding:25px; */
	overflow: hidden;
}

/* Card Box */
/* .box{ */
/*     background:white; */
/*     border-radius:14px; */
/*     padding:25px; */
/*     height:100%; */
/*     overflow-y:auto; */
/*     box-shadow:0 10px 25px rgba(0,0,0,0.1); */
/* } */

/* ================= ATTENDANCE FIELDSET ================= */
.attendance-fieldset {
	/*     border: 1px solid rgba(99,102,241,0.35); */
	border-radius: 10px;
	padding: 25px 20px 30px;
	border: none;
	background: #c3cfe2;
	box-shadow: 0 12px 30px rgba(0, 0, 0, 0.4);
}

/* Legend (Title) */
.attendance-fieldset legend {
	padding: 6px 14px;
	font-size: 15px;
	font-weight: 600;
	color: #222;
	border-radius: 10px;
	background: #e2ebfa;
	border: 1px solid rgba(99, 102, 241, 0.35);
}

/* Status Badge Center */
.attendance-fieldset .status-badge {
	margin: 15px auto 20px;
	display: inline-block;
}

/* Time Cards */
.attendance-fieldset .time-card {
	display: flex;
	justify-content: space-between;
	padding: 10px 0;
	border-bottom: 1px dashed rgba(0, 0, 0, 0.1);
}

/* Punch Buttons */
.attendance-fieldset .punch-actions {
	display: flex;
	gap: 15px;
	margin-top: 20px;
}

.attendance-fieldset button {
	flex: 1;
	padding: 10px  22px;
	border-radius:22px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: white;
	border: none;
	font-weight: 600;
	transition:all ease  0.2s;
	cursor: pointer;
}

/* Disabled State */
.attendance-fieldset button:disabled {
	opacity: 0.6;
	background: #a0aec0;
	cursor: not-allowed;
}
/* ================= TASK CARD ================= */
.task-card {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 15px 18px;
	margin-top: 15px;
	border-radius: 12px;
	background: rgba(99, 102, 241, 0.08);
	transition: 0.3s;
}

.task-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
}

.task-left {
	display: flex;
	align-items: center;
	gap: 12px;
}

.task-left i {
	font-size: 18px;
	color: #6366f1;
}

/* Status */
.task-status {
	padding: 6px 12px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 600;
}

.task-status.pending {
	background: #fff4e5;
	color: #d97706;
}

.task-status.done {
	background: #dcfce7;
	color: #15803d;
}

/* Done Button */
.task-btn {
	padding: 8px 14px;
	border: none;
	border-radius: 8px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: white;
	font-size: 13px;
	font-weight: 600;
	cursor: pointer;
	margin-left: 10px;
	transition: 0.25s;
}

.task-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 15px rgba(99, 102, 241, 0.35);
}

/* Empty Text */
.no-task-text {
	margin-top: 15px;
	font-size: 14px;
	color: #6b7280;
}

/* ================= LEAVE FORM ================= */
.leave-form {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.leave-form input, .leave-form select, .leave-form textarea {
	padding: 6px 6px;
	border-radius: 8px;
	background: #e2ebf0;
	border: 1px solid #cbd5e1;
	font-size: 14px;
}

.leave-form textarea {
	height: 50px;
	resize: none;
}

#myLeaveSection h3 {
	color: black !important;
}

.apply-leave-btn {
	margin-top: 10px;
	padding: 12px;
	border-radius: 10px;
	border: none;
	font-weight: 600;
	background: linear-gradient(135deg, #2563eb, #4f46e5);
	color: white;
	cursor: pointer;
}

/* ===== Scheduled Meetings Scroll ===== */
/* ================= MEETING FIELDSET BACKGROUND ================= */
#meetingSection .attendance-fieldset {
	background: #c3cfe2;
	max-height: 460px;
	overflow-y: auto;
	border: none;
	border-radius: 8px;
	padding: 28px 22px;
	box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4);
}
/* Legend Styling */
#meetingSection legend {
	padding: 6px 16px;
	font-size: 15px;
	font-weight: 600;
	color: #333;
	background: #e2ebf0;
	border-radius: 10px;
	border: 1px solid rgba(99, 102, 241, 0.35);
}

/* ================= MEETING CARD ================= */
#meetingSection .task-card {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 18px 20px;
	margin-top: 18px;
	border-radius: 14px;
	background: rgba(99, 102, 241, 0.07);
	overflow: auto;
	transition: all 0.3s ease;
}

/* Hover Effect */
#meetingSection .task-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

/* Left Content */
#meetingSection .task-left {
	display: flex;
	gap: 14px;
	align-items: flex-start;
}

#meetingSection .task-left i {
	font-size: 20px;
	color: #444;
	margin-top: 4px;
}

/* Title */
#meetingSection .task-left b {
	font-size: 15px;
	color: #1f2937;
}

/* Description */
#meetingSection .task-left small {
	font-size: 13px;
	color: #444;
}

/* ================= JOIN BUTTON ================= */
#meetingSection .task-btn {
	padding: 10px 18px;
	border-radius: 10px;
	border: none;
	font-weight: 600;
	background: #4f46e5;
	color: white;
	cursor: pointer;
	transition: 0.25s;
}

#meetingSection .task-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(34, 197, 94, 0.35);
}

/* Empty Message */
#meetingSection .no-task-text {
	margin-top: 15px;
	font-size: 14px;
	color: #6b7280;
}

#meetingSection .attendance-fieldset::-webkit-scrollbar {
	width: 6px;
}

#meetingSection .attendance-fieldset::-webkit-scrollbar-thumb {
	background: #94a3b8;
	border-radius: 4px;
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

/* ===== Calendar Scroll ===== */
#calendarSection {
	max-height: calc(100vh - 120px);
	overflow-y: auto;
	padding-right: 10px;
	/* Hide scrollbar */
	scrollbar-width: none; /* Firefox */
	-ms-overflow-style: none; /* IE */
}

#calendarSection::-webkit-scrollbar {
	width: 0;
	background: c3cfe2; /* Chrome / Edge / Safari */
}

#calendarSection h3 {
	position: sticky;
	top: 0;
	background: white;
	padding-bottom: 10px;
	z-index: 10;
}

/* ================= TOAST ================= */
.toast {
    position: fixed;
    top: 90px;
    right: 15px;
    background: #e2ebf0;
    color: black;
    padding: 14px 20px 14px 44px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    display: none;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
    z-index: 3000;
    line-height: 1.4;
}

.toast.show {
    animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}

.toast.hide {
    animation: toastOut 0.4s ease forwards;
}

.toast::before {
    content: "✔";
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 16px;
    font-weight: bold;
}

/* SUCCESS */
.toast.success {
    background: #e2ebf0;
    color: black;
}

.toast.success::before {
    content: "✔";
}

/* ERROR */
.toast.error {
    background: #e2ebf0;
    color: black;
}

.toast.error::before {
    content: "✖";
}

/* INFO */
.toast.info {
    background: #e2ebf0;
    color: black;
}

.toast.info::before {
    content: "✔";
}

@keyframes toastIn {
    from {
        opacity: 0;
        transform: translateX(120px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes toastOut {
    from {
        opacity: 1;
        transform: translateX(0);
    }
    to {
        opacity: 0;
        transform: translateX(120px);
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
	height: 450px;
	background: #c3cfe2;
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
	background: #e2ebf0;
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
	max-height: 330px; /* Adjust as needed */
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

.notification-list::-webkit-scrollbar {
	width: 6px;
}

.notification-list::-webkit-scrollbar-thumb {
	background: rgba(0, 0, 0, 0.25);
	border-radius: 4px;
}
/* ================= SETTINGS ICON ================= */
.settings-icon {
	position: absolute;
	top: 20px;
	left: 20px;
	font-size: 26px;
	margin-left: 20px;
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
	right: -340px;
	width: 340px;
	height: 100%;
	background: linear-gradient(135deg, rgba(255, 255, 255, 0.85),
		rgba(240, 245, 255, 0.75));
	backdrop-filter: blur(16px);
	box-shadow: -8px 0 25px rgba(0, 0, 0, 0.15);
	transition: right 0.4s ease, opacity 0.3s ease;
	z-index: 1000;
	border-left: 1px solid rgba(255, 255, 255, 0.4);
}

.settings-header {
	display: flex;
	height: 50px;
	justify-content: space-between;
	align-items: center;
	padding: 15px;
	background: linear-gradient(135deg, #6366f1, #818cfa);
	color: white;
}
/* Open State */
.settings-panel.open {
	right: 0;
}

.close-btn {
	cursor: pointer;
	font-size: 18px;
}

.settings-item {
	padding: 14px 22px;
	margin: 6px 12px;
	border-radius: 10px;
	cursor: pointer;
	font-size: 15px;
	font-weight: 500;
	color: #2d3748;
	display: flex;
	align-items: center;
	gap: 12px;
	transition: background 0.3s, transform 0.2s, box-shadow 0.2s;
}

/* Hover Effect */
.settings-item:hover {
	background: rgba(99, 102, 241, 0.12);
	transform: translateX(4px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* Icon Styling (Font Awesome) */
.settings-item i {
	font-size: 18px;
	color: #6366f1;
}

/* Active Item */
.settings-item.active {
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
}

.settings-item.active i {
	color: #fff;
}
/* ================= CHANGE PASSWORD MODAL ================= */
/* ================= MODAL (ADMIN STYLE) ================= */
/* ================= MODAL ================= */
.password-modal {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.35);
    backdrop-filter: blur(6px);

    display: flex;
    align-items: center;
    justify-content: center;

    z-index: 2000;

    visibility: hidden;
    opacity: 0;
    transition: opacity 0.25s ease;
}

/* Centered Box */
.password-box {
    width: 400px;          /* fixed clean width */
    max-width: 90%;
    background: white;
    border-radius: 14px;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
    overflow: hidden;
    animation: fadeIn 0.25s ease;
}

/* Header */
.password-header {
    padding: 14px 18px;
    background: linear-gradient(135deg, #6366f1, #818cf8);
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.password-header h4 {
    margin: 0;
    font-size: 16px;
}

/* Body */
.password-body {
    padding: 25px;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

/* Profile Cards */
.password-body .time-card {
    background: #f3f4f6;
    padding: 12px 14px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 14px;
}

/* Inputs */
.password-body input {
    width: 100%;
    padding: 12px 14px;
    border-radius: 8px;
    border: 1px solid #d1d5db;
    font-size: 14px;
    box-sizing: border-box;
}

/* Button */
.password-body button {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: none;
    background: linear-gradient(135deg, #6366f1, #818cf8);
    color: white;
    font-weight: 600;
    font-size: 14px;
    cursor: pointer;
    transition: 0.25s;
}

.password-body button:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(99, 102, 241, 0.35);
}

/* Animation */
@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
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

		<div class="settings-item" onclick="openProfile()">My Profile</div>
		<div class="settings-item" onclick="openChangePassword()">Change
			Password</div>
	</div>

	<!-- CHANGE PASSWORD MODAL -->
	<div id="passwordModal" class="password-modal">
		<div class="password-box">
			<div class="password-header">
				<h4>Change Password</h4>
				<span class="close-btn" onclick="closeChangePassword()">✖</span>
			</div>

			<div class="password-body">
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
					Name: <b><%=userObj != null ? userObj.getFullname() : "--"%></b>
				</div>
				<div class="time-card">
					Username: <b><%=userObj != null ? userObj.getUsername() : "--"%></b>
				</div>
				<div class="time-card">
					Email: <b><%=userObj != null ? userObj.getEmail() : "--"%></b>
				</div>
				<div class="time-card">
					Role: <b><%=userObj != null ? userObj.getRole() : "--"%></b>
				</div>
				<div class="time-card">
					Phone: <b><%=userObj != null ? userObj.getPhone() : "--"%></b>
				</div>

			</div>
		</div>
	</div>






	<div class="top-bar">
		<h2>Smart Office • Employee Dashboard</h2>
		<div class="user-area">
			Welcome, <b><%=username%></b>
			<button class="icon-btn" onclick="openSettings()"
				style="margin-left: 10px;">
				<i class="fa-solid fa-gear" style="margin-left: 2px;"></i>
			</button>
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">Logout <i class="fa-solid fa-right-to-bracket"></i></button>
			</a>
		</div>
	</div>

	<div class="container">

		<!-- Font Awesome -->

		<div class="left-panel">
			<button class="nav-btn active"
				onclick="setActive(this); showAttendance();">
				<i class="fa-solid fa-user-check"></i> <span>My Attendance</span>
			</button>

			<button class="nav-btn" onclick="setActive(this); showTasks();">
				<i class="fa-solid fa-list-check"></i> <span>Assigned Tasks</span>
			</button>

			<button class="nav-btn" onclick="setActive(this); showLeave();">
				<i class="fa-solid fa-calendar-xmark"></i> <span>Apply Leave</span>
			</button>

			<button class="nav-btn" onclick="setActive(this); showMeetings();">
				<i class="fa-solid fa-handshake"></i> <span>Scheduled
					Meetings</span>
			</button>

			<button class="nav-btn" onclick="setActive(this); openCalendar();">
				<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
			</button>

			<button class="nav-btn"
				onclick="setActive(this); openNotifications();">
				<i class="fa-solid fa-bell"></i> <span>Notifications</span>
			</button>
		</div>
		<div class="right-panel">

			<!-- Attendance -->
			<div class="box" id="attendanceSection">

				<fieldset class="attendance-fieldset">
					<legend>
						<i class="fa-solid fa-clock"></i> Attendance
					</legend>

					<div class="time-card">
						<span class="label">Status</span> <span class="value"><%=status%></span>
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
								<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
								Punch Out</button>
						</form>
					</div>

				</fieldset>

			</div>
			<!-- Tasks -->
			<div class="box" id="taskSection" style="display: none;">

				<fieldset class="attendance-fieldset">
					<legend>
						<i class="fa-solid fa-list-check"></i> My Tasks
					</legend>

					<%
					List<Task> tasks = (List<Task>) request.getAttribute("tasks");

					if (tasks == null || tasks.isEmpty()) {
					%>
					<p class="no-task-text">No tasks assigned.</p>
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

				</fieldset>

			</div>

			<!-- Meetings -->
			<div class="box" id="meetingSection" style="display: none;">

				<fieldset class="attendance-fieldset">
					<legend>
						<i class="fa-solid fa-video"></i> Scheduled Meetings
					</legend>

					<%
					List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");

					if (meetings == null || meetings.isEmpty()) {
					%>
					<p class="no-task-text">No upcoming meetings.</p>
					<%
					} else {
					for (Meeting m : meetings) {
					%>

					<div class="task-card">
						<div class="task-left">
							<i class="fa-solid fa-users"></i>
							<div>
								<b><%=m.getTitle()%></b><br> <small><%=m.getDescription()%></small><br>
								<small> 🕒 <%=m.getStartTime()%> → <%=m.getEndTime()%></small>
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

				</fieldset>

			</div>

			<!-- Calendar -->
			<div class="box" id="calendarSection" style="display: none;">

				<iframe id="calendarFrame" src=""
					style="width: 100%; height: 100%; border: none;"> </iframe>

			</div>

			<!-- Leave -->
			<div class="box" id="leaveSection" style="display: none;">

				<fieldset class="attendance-fieldset">
					<legend>
						<i class="fa-solid fa-calendar-days"></i> Leave
					</legend>

					<!-- Leave Tabs -->
					<div style="display: flex; gap: 12px; margin-bottom: 20px;">
						<button class="nav-btn"
							style="flex: 1; background: #2563eb; color: white;"
							onclick="showApplyLeave()">Apply Leave</button>
						<button class="nav-btn"
							style="flex: 1; background: #6b7280; color: white;"
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

							<button class="apply-leave-btn" style="color: white;">Apply
								Leave</button>
						</form>
					</div>

					<!-- My Leave Requests -->
					<div id="myLeaveSection" style="display: none;">
						<h3 style="margin-top: 10px; color: black;">
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

				</fieldset>

			</div>


			<div id="notificationPanel" class="notification-panel">
				<div class="notification-header">
					<span>🔔 Smart Office Notifications</span>
					<button onclick="closeNotifications()">✖</button>
				</div>

				<div class="notification-list" id="notificationList">
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
        document.getElementById("calendarSection").style.display = "block";
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

    // ===== Notifications =====
    function openNotifications() {
        document.getElementById("notificationPanel").classList.add("show");
    }

    function closeNotifications() {
        document.getElementById("notificationPanel").classList.remove("show");
    }

    // ===== Toast =====
    function showToast(message, type = "success") {
    const toast = document.getElementById("toast");

    toast.style.display = "none";
    toast.className = "toast";
    toast.offsetHeight; // force reflow

    toast.classList.add(type);
    toast.textContent = message;
    toast.style.display = "block";

    toast.classList.add("show");

    setTimeout(() => {
        toast.classList.remove("show");
        toast.classList.add("hide");

        setTimeout(() => {
            toast.style.display = "none";
            toast.className = "toast";
        }, 400);
    }, 2500);
}

    // ===== URL PARAM HANDLING (IMPORTANT PART) =====
    const params = new URLSearchParams(window.location.search);
    const tab = params.get("tab");
    const sub = params.get("sub");

    // ---- SUCCESS ----
    if (params.has("success")) {
    const success = params.get("success");

    if (success === "LeaveApplied") {
        showToast("Leave applied successfully", success);
    } 
    else if (success === "PasswordUpdated") {
        showToast("Password updated successfully", success);
    }
    else if (success === "Login") {
        showToast("Logged in successfully", success);
    }
    else if (success === "PunchIn") {
        showToast("Punched in successfully 🕘", success);
    }
    else if (success === "PunchOut") {
        showToast("Punched out successfully 🕔", success);
    }
}

    // ---- ERROR ----
    if (params.has("error")) {
        const error = params.get("error");

        if (error === "WrongOldPassword") {
            showToast("Old password is incorrect", error);
        } else if (error === "PasswordMismatch") {
            showToast("Passwords do not match", error);
        } else if (error === "HolidayAttendance") {
            showToast("Today is a holiday. Attendance not allowed.", error);
        } else {
            showToast("Something went wrong", error);
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
    document.getElementById("settingsPanel").classList.add("open");
}

function closeSettings() {
    document.getElementById("settingsPanel").classList.remove("open");
}
 
function openChangePassword() {
    closeSettings();
    const modal = document.getElementById("passwordModal");
    modal.style.visibility = "visible";
    modal.style.opacity = "1";
}

function closeChangePassword() {
    const modal = document.getElementById("passwordModal");
    modal.style.visibility = "hidden";
    modal.style.opacity = "0";
}
 
function toggleTheme() {

    document.body.classList.toggle("dark-theme");

}
 
function closeAll() {

    closeSettings();

    closeChangePassword();


}
function openProfile() {
    closeSettings();
    const modal = document.getElementById("profileModal");
    modal.style.visibility = "visible";
    modal.style.opacity = "1";
}

function closeProfile() {
    const modal = document.getElementById("profileModal");
    modal.style.visibility = "hidden";
    modal.style.opacity = "0";
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

            // ✅ CHECK IF EMPTY
            const list = document.getElementById("notificationList");

            // Count remaining notification items
            const remaining = list.querySelectorAll(".notification-item");

            if (remaining.length === 0) {
                list.innerHTML = `
                    <div class="notification-item">
                        No notifications
                    </div>
                `;
            }
        }
    })
    .catch(err => console.error(err));
}

</script>

			<script>
			function submitPassword() {
			    const newPassword = document.getElementById("newPassword").value.trim();
			    const confirmPassword = document.getElementById("confirmPassword").value.trim();

			    if (!newPassword || !confirmPassword) {
			        showToast("Please fill all fields", "error");
			        return;
			    }

			    fetch("<%=request.getContextPath()%>/changePassword", {
			        method: "POST",
			        headers: {
			            "Content-Type": "application/x-www-form-urlencoded"
			        },
			        body: new URLSearchParams({
			            newPassword: newPassword,
			            confirmPassword: confirmPassword
			        })
			    })
			    .then(res => res.text())
			    .then(data => {

			        if (data === "Success") {
			            showToast("Password updated successfully", "success");
			            closeChangePassword();

			            document.getElementById("newPassword").value = "";
			            document.getElementById("confirmPassword").value = "";
			        }
			        else if (data === "PasswordMismatch") {
			            showToast("Passwords do not match", "error");
			        }
			        else if (data === "MissingFields") {
			            showToast("All fields are required", "error");
			        }
			        else if (data === "Unauthorized") {
			            showToast("Session expired. Please login again.", "error");
			        }
			        else {
			            showToast("Something went wrong", "error");
			        }
			    })
			    .catch(err => {
			        console.error(err);
			        showToast("Server error", "error");
			    });
			}
</script>

			<script>
function setActive(button) {
    // Remove active class from all buttons
    const buttons = document.querySelectorAll('.nav-btn');
    buttons.forEach(btn => btn.classList.remove('active'));

    // Add active class to clicked button
    button.classList.add('active');
}

window.onclick = function(e) {
    const modal = document.getElementById("passwordModal");
    const profile = document.getElementById("profileModal");

    if (e.target === modal) closeChangePassword();
    if (e.target === profile) closeProfile();
};

</script>
</body>
</html>