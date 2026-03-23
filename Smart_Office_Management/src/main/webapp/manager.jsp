<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.TeamAttendance"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
String activeTab = request.getParameter("tab");
if (activeTab == null) {
	activeTab = "attendance";
}
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
%>

<%
List<Task> assignTasks = (List<Task>) request.getAttribute("assignTasks");
List<Task> viewTasks = (List<Task>) request.getAttribute("viewTasks");
%>
<%
java.sql.Timestamp punchIn = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp punchOut = (java.sql.Timestamp) request.getAttribute("punchOut");

java.util.Calendar cal = java.util.Calendar.getInstance();
int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
boolean isWeekend = (dow == java.util.Calendar.SATURDAY || dow == java.util.Calendar.SUNDAY);

String status = "Not Punched In";
if (punchIn != null && punchOut == null)
	status = "Punched In";
if (punchOut != null)
	status = "Punched Out";

boolean onBreak = Boolean.TRUE.equals(request.getAttribute("onBreak"));
%>
<%
User userObj = (User) request.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager Dashboard • Smart Office</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
	rel="stylesheet">
<style>
/* ================= GLOBAL (Figma / Admin / Employee aligned) ================= */
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	height: 100vh;
	display: flex;
	flex-direction: column;
	background: #f1f5f9;
	overflow: hidden;
	font-family: 'Inter', system-ui, -apple-system, sans-serif;
	font-size: 14px;
	color: #1e293b;
}

/* ================= TOP BAR ================= */
.top-bar {
	background: #ffffff;
	border-bottom: 1px solid #e2e8f0;
	padding: 0 24px;
	height: 56px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	flex-shrink: 0;
}

.top-bar h2 {
	font-size: 20px;
	font-weight: 600;
	color: #1e293b;
	letter-spacing: -0.02em;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 12px;
	color: #64748b;
	font-size: 14px;
	font-weight: 500;
}

.user-area .welcome {
	color: #64748b;
}

.user-area strong {
	color: #1e293b;
}

.icon-btn {
	width: 40px;
	height: 40px;
	min-width: 40px;
	border-radius: 50%;
	border: none;
	background: #4f46e5;
	color: white;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	transition: background 0.2s;
}

.icon-btn:hover {
	background: #4338ca;
}

.icon-btn i {
	font-size: 16px;
}

/* ================= LAYOUT ================= */
.main-container {
	flex: 1;
	display: flex;
	min-height: 0;
}

/* ================= SIDEBAR ================= */
.sidebar {
	width: 256px;
	min-width: 256px;
	background: #ffffff;
	border-right: 1px solid #e2e8f0;
	padding: 16px 12px;
	box-shadow: 1px 0 0 rgba(0, 0, 0, 0.04);
	flex-shrink: 0;
	display: flex;
	flex-direction: column;
}

/* Nav section takes all available space */
.sidebar-nav {
	flex: 1;
}

/* Bottom section for settings & logout */
.sidebar-bottom {
	padding-top: 12px;
	border-top: 1px solid #e2e8f0;
	margin-top: 8px;
}

.sidebar-btn {
	width: 100%;
	padding: 12px 16px;
	margin-bottom: 4px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 12px;
	color: #64748b;
	transition: background 0.2s, color 0.2s;
	text-align: left;
}

.sidebar-btn i {
	width: 20px;
	text-align: center;
	font-size: 16px;
}

.sidebar-btn:hover {
	background: #f1f5f9;
	color: #1e293b;
}

.sidebar-btn.active {
	background: #eef2ff;
	color: #4f46e5;
	font-weight: 600;
}

/* Logout button in sidebar */
.sidebar-logout-btn {
	width: 100%;
	padding: 12px 16px;
	margin-bottom: 4px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 12px;
	color: #dc2626;
	transition: background 0.2s, color 0.2s;
	text-align: left;
	text-decoration: none;
}

.sidebar-logout-btn i {
	width: 20px;
	text-align: center;
	font-size: 16px;
}

.sidebar-logout-btn:hover {
	background: #fef2f2;
	color: #b91c1c;
}

/* Manager dashboard: stack + scroll on small screens */
@media ( max-width : 768px) {
	body {
		height: auto;
		min-height: 100vh;
		overflow: auto;
	}
	.top-bar {
		padding: 0 12px;
		height: auto;
		min-height: 52px;
		flex-wrap: wrap;
		gap: 8px;
	}
	.top-bar h2 {
		font-size: 15px;
		line-height: 1.3;
		flex: 1;
		min-width: 0;
	}
	.main-container {
		flex-direction: column;
		min-height: 0;
	}
	.sidebar {
		width: 100%;
		min-width: 0;
		max-height: none;
		flex-direction: row;
		flex-wrap: wrap;
		align-items: stretch;
		padding: 10px 8px;
		border-right: none;
		border-bottom: 1px solid #e2e8f0;
		box-shadow: none;
	}
	.sidebar-nav {
		display: flex;
		flex-wrap: wrap;
		gap: 6px;
		flex: 1 1 auto;
		min-width: 0;
	}
	.sidebar-btn, .sidebar-logout-btn {
		flex: 1 1 calc(50% - 6px);
		min-width: 140px;
		margin-bottom: 0;
		font-size: 13px;
		padding: 10px 12px;
	}
	.sidebar-bottom {
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
		gap: 6px;
		width: 100%;
		padding-top: 8px;
		margin-top: 8px;
		border-top: 1px solid #e2e8f0;
	}
	.sidebar-bottom .sidebar-btn, .sidebar-bottom .sidebar-logout-btn {
		flex: 1 1 calc(50% - 6px);
	}
	.content-area {
		padding: 16px 12px;
		min-width: 0;
		overflow-x: auto;
	}
}

/* ================= CONTENT ================= */
.content-area {
	flex: 1;
	padding: 24px;
	background: #f1f5f9;
	overflow-y: auto;
	min-height: 0;
}

.box {
	background: #ffffff;
	border-radius: 12px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	padding: 24px;
	overflow-y: auto;
	max-height: 100%;
}

#contentFrame {
	width: 100%;
	height: 100%;
	border: none;
	background: rgb(255, 255, 255, 0);
}

/* ================= MODALS ================= */
.modal {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.45);
	backdrop-filter: blur(6px);
	display: none;
	align-items: center;
	justify-content: center;
	z-index: 2000;
}

.modal.show {
	display: flex;
}

.modal-content {
	width: 720px;
	max-width: 92%;
	align-items: center;
	max-height: 85vh;
	background: #f8fbff;
	border-radius: 14px;
	overflow: hidden;
	box-shadow: 0 25px 60px rgba(0, 0, 0, 0.25);
	animation: modalFade 0.3s ease;
}

.modal-header {
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: #ffffff;
	width: 100%;
	padding: 14px 20px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.modal-header h3 {
	margin: 0;
	font-size: 18px;
	font-weight: 600;
}

.modal-close {
	font-size: 22px;
	cursor: pointer;
	opacity: 0.85;
}

.modal-close:hover {
	opacity: 1;
}

.modal-body {
	padding: 18px;
	width: 100%;
	overflow-y: auto;
	max-height: calc(85vh - 60px);
}

.modal-body::-webkit-scrollbar {
	width: 8px;
}

.modal-body::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #c3cfe2, #9faed9);
	border-radius: 10px;
}

.modal-body::-webkit-scrollbar-track {
	background: #eef2f7;
}

.meeting-item {
	background: #f2f7ff;
	border-radius: 12px;
	padding: 14px 16px;
	margin-bottom: 14px;
	box-shadow: inset 4px 0 0 #3b82f6, 0 4px 12px rgba(0, 0, 0, 0.06);
}

.meeting-title {
	display: flex;
	align-items: center;
	gap: 8px;
	font-weight: 600;
	color: #1e3a8a;
	margin-bottom: 8px;
}

.meeting-title i {
	color: #2563eb;
}

.meeting-info {
	font-size: 14px;
	color: #475569;
	margin-bottom: 4px;
}

.meeting-info b {
	color: #334155;
}

.join-btn {
	margin-top: 10px;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 6px 14px;
	background: #93c5fd;
	color: #1e3a8a;
	border-radius: 18px;
	font-size: 13px;
	font-weight: 600;
	text-decoration: none;
	transition: 0.2s ease;
}

.join-btn i {
	font-size: 14px;
}

.join-btn:hover {
	background: #60a5fa;
}

@
keyframes modalFade {from { opacity:0;
	transform: scale(0.96);
}

to {
	opacity: 1;
	transform: scale(1);
}

}

/* ===== Password Modal Form Styling ONLY ===== */
#passwordModal .modal-body {
	padding: 30px 25px;
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 80%;
}

#passwordModal input[type="password"] {
	width: 100%;
	padding: 12px 14px;
	font-size: 15px;
	border-radius: 8px;
	border: 1px solid #cbd5e1;
	outline: none;
	transition: border 0.3s, box-shadow 0.3s;
	margin-bottom: 10px;
}

#passwordModal input[type="password"]:focus {
	border-color: #6366f1;
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
}

#passwordModal button {
	width: 100%;
	margin-top: 10px;
	padding: 12px;
	font-size: 15px;
	font-weight: 600;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #ffffff;
	transition: transform 0.2s, box-shadow 0.2s;
}

#passwordModal button:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

#passwordModal button:active {
	transform: scale(0.97);
}

@media ( max-width : 480px) {
	#passwordModal input[type="password"], #passwordModal button {
		max-width: 100%;
	}
}

/* ================= SETTINGS DRAWER ================= */
.settings-drawer {
	position: fixed;
	top: 0;
	right: -340px;
	width: 340px;
	height: 100%;
	background: #ffffff;
	box-shadow: -4px 0 24px rgba(0, 0, 0, 0.12);
	transition: right 0.4s ease;
	z-index: 1000;
	border-left: 1px solid #e2e8f0;
}

.settings-drawer.open {
	right: 0;
}

#settingsPanel .modal-header {
	background: #4f46e5;
	color: #fff;
	padding: 16px 20px;
	font-size: 18px;
	font-weight: 600;
	border-bottom: none;
}

.settings-close {
	cursor: pointer;
	font-size: 20px;
	color: #718096;
	transition: color 0.3s;
}

.settings-close:hover {
	color: #e53e3e;
}

.settings-list {
	padding: 10px 0;
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

.settings-item:hover {
	background: rgba(99, 102, 241, 0.12);
	transform: translateX(4px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.settings-item i {
	font-size: 18px;
	color: #6366f1;
}

.settings-item.active {
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
}

.settings-item.active i {
	color: #fff;
}

/* ================= ATTENDANCE CARD ================= */
.attendance-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 24px;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	margin-bottom: 0;
}

.attendance-fieldset legend {
	padding: 8px 16px;
	font-size: 15px;
	font-weight: 600;
	background: #eef2ff;
	border-radius: 8px;
	color: #1e293b;
	border: none;
}

.attendance-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12px 0;
	border-bottom: 1px dashed rgba(102, 126, 234, 0.2);
}

.attendance-row:last-child {
	border-bottom: none;
}

.attendance-row .label {
	font-weight: 600;
	color: #475569;
	font-size: 14px;
}

.attendance-row .value {
	color: #1e293b;
	font-weight: 600;
	font-size: 14px;
}

/* field set for my team */
.team-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 20px 24px 24px;
	height: 450px;
	overflow-y: auto;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.team-fieldset legend {
	padding: 8px 16px;
	font-size: 15px;
	font-weight: 600;
	background: #eef2ff;
	border-radius: 8px;
	color: #1e293b;
}

.team-scroll {
	max-height: 420px;
	overflow-y: auto;
	padding-right: 8px;
	scroll-behavior: smooth;
}

.team-scroll::-webkit-scrollbar {
	width: 10px;
}

.team-scroll::-webkit-scrollbar-track {
	background: #e2ebf0;
	border-radius: 10px;
}

.team-scroll::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #c3cfe2, #9faed9);
	border-radius: 10px;
	border: 1px solid #e2ebf0;
}

.team-scroll::-webkit-scrollbar-thumb:hover {
	background: linear-gradient(180deg, #9faed9, #7f8fd1);
}

.team-scroll {
	scrollbar-width: thin;
	scrollbar-color: #c3cfe2 #e2ebf0;
}

.employee-grid {
	width: 90%;
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	gap: 16px;
	margin-top: 10px;
}

.employee-card {
	padding: 14px 16px;
	margin-bottom: 12px;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.employee-card:hover {
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
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

#leave {
	max-width: 100%;
}

.form-control {
	width: 100%;
	padding: 12px 14px;
	border-radius: 8px;
	border: 1px solid #e2e8f0;
	margin-bottom: 12px;
	background: #fff;
	font-size: 14px;
	color: #1e293b;
	transition: border-color 0.2s, box-shadow 0.2s;
}

.form-control:focus {
	outline: none;
	border-color: #4f46e5;
	box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
}

.attendance-buttons {
	margin-top: 15px;
	display: flex;
	gap: 15px;
}

.attendance-buttons button {
	min-width: 100px;
}

#calendarSection {
	max-width: 100%;
}

#settings p {
	margin-bottom: 12px;
}

.tasks-title {
	margin-top: 25px;
	margin-bottom: 14px;
	font-size: 18px;
	font-weight: 600;
	color: #1e293b;
}

.task-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 20px 24px 24px;
	margin-bottom: 20px;
	overflow-y: auto;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.task-fieldset legend {
	padding: 8px 16px;
	font-size: 15px;
	font-weight: 600;
	border-radius: 8px;
	background: #eef2ff;
	color: #1e293b;
}

.task-error {
	color: #c53030;
	font-weight: 600;
	margin-bottom: 15px;
}

.task-list {
	margin-top: 15px;
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.task-card {
	background: #ffffff;
	border-radius: 12px;
	padding: 14px 16px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	box-shadow: 0 6px 14px rgba(0, 0, 0, 0.06);
}

.task-card.completed {
	opacity: 0.75;
}

.task-status {
	padding: 6px 12px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 600;
	flex-shrink: 0;
}

.task-status.completed {
	background: #dcfce7;
	color: #166534;
}

.task-status.assigned, .task-status.pending {
	background: #fef3c7;
	color: #b45309;
}

#assignTask {
	max-height: 100%;
	overflow-y: auto;
	overflow-x: hidden;
	padding: 20px;
	background: transparent;
	border-radius: 12px;
}

#assignTask::-webkit-scrollbar {
	width: 8px;
}

#assignTask::-webkit-scrollbar-track {
	background: #e2ebf0;
	border-radius: 10px;
}

#assignTask::-webkit-scrollbar-thumb {
	background: #c3cfe2;
	border-radius: 10px;
}

#assignTask::-webkit-scrollbar-thumb:hover {
	background: #aebed6;
}

/* ================= LEAVE FIELDSET ================= */
.leave-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 24px;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.leave-fieldset legend {
	padding: 8px 16px;
	font-size: 15px;
	border-radius: 8px;
	font-weight: 600;
	background: #eef2ff;
	color: #1e293b;
}

.leave-tab-row {
	display: flex;
	gap: 12px;
	margin-bottom: 20px;
}

.leave-tab-btn {
	flex: 1;
	padding: 12px 16px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	background: #94a3b8;
	color: #fff;
	transition: background 0.2s;
}

.leave-tab-btn.leave-tab-active {
	background: #4f46e5;
	color: #fff;
}

.leave-tab-btn:hover:not(.leave-tab-active) {
	background: #64748b;
}

.leave-scroll {
	max-height: 460px;
	overflow-y: auto;
	padding-right: 6px;
	scroll-behavior: smooth;
}

.leave-scroll::-webkit-scrollbar {
	width: 2px;
}

.leave-scroll::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #c3cfe2, #9faed9);
	border-radius: 10px;
}

.leave-scroll::-webkit-scrollbar-track {
	background: #e2ebf0;
}

/* ===== Leave Form ===== */
.leave-form label {
	display: block;
	margin-top: 12px;
	font-weight: 600;
	color: #2d3748;
	font-size: 14px;
}

.leave-form input, .leave-form select, .leave-form textarea {
	width: 100%;
	padding: 10px 14px;
	margin-top: 6px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	font-size: 14px;
	color: #1e293b;
	background: #fff;
	transition: border-color 0.2s, box-shadow 0.2s;
	box-sizing: border-box;
}

.leave-form input:focus, .leave-form select:focus, .leave-form textarea:focus
	{
	outline: none;
	border-color: #4f46e5;
	box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.12);
}

.leave-form textarea {
	min-height: 90px;
	resize: vertical;
}

.leave-form button[type="submit"] {
	margin-top: 20px;
	width: 100%;
}

/* Leave apply grid */
.leave-apply-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	align-items: start;
}

.leave-apply-left {
	background: #f8faff;
	border-radius: 10px;
	padding: 20px;
	border: 1px solid #e2e8f0;
}

.leave-apply-right {
	background: #f8faff;
	border-radius: 10px;
	padding: 20px;
	border: 1px solid #e2e8f0;
	max-height: 420px;
	overflow-y: auto;
}

.leave-apply-right h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	margin-bottom: 14px;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
}

@media ( max-width : 768px) {
	.leave-apply-grid {
		grid-template-columns: 1fr;
	}
}

/* Pending leave request card */
.pending-leave-card {
	background: #ffffff;
	border: 1px solid #e2e8f0;
	border-left: 4px solid #f59e0b;
	border-radius: 10px;
	padding: 14px 16px;
	margin-bottom: 12px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.pending-leave-card .plc-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 8px;
}

.pending-leave-card .plc-name {
	font-weight: 700;
	color: #1e293b;
	font-size: 14px;
}

.pending-leave-card .plc-type {
	font-size: 12px;
	font-weight: 600;
	padding: 3px 10px;
	border-radius: 20px;
	background: #fef3c7;
	color: #b45309;
}

.pending-leave-card .plc-body {
	font-size: 13px;
	color: #475569;
	margin-bottom: 10px;
}

.pending-leave-card .plc-actions {
	display: flex;
	gap: 10px;
}

/* Leave actions */
.leave-actions {
	margin-top: 12px;
	display: flex;
	gap: 12px;
}

/* ================= MEETING FIELDSET (improved alignment) ================= */
.meeting-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 24px;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.meeting-fieldset legend {
	padding: 8px 16px;
	background: #eef2ff;
	border-radius: 8px;
	font-size: 15px;
	font-weight: 600;
	color: #1e293b;
}

.section-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
}

/* ===== Meeting Grid layout ===== */
.meeting-grid {
	display: grid;
	grid-template-columns: 1.1fr 0.9fr;
	gap: 20px;
	align-items: start;
}

@media ( max-width : 900px) {
	.meeting-grid {
		grid-template-columns: 1fr;
	}
}

.meeting-left {
	background: #f8faff;
	padding: 20px;
	border-radius: 12px;
	border: 1px solid #e2e8f0;
}

.meeting-left h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	margin-bottom: 16px;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
}

.meeting-left .form-row {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 12px;
}

.meeting-left label {
	display: block;
	font-size: 13px;
	font-weight: 600;
	color: #475569;
	margin-bottom: 5px;
	margin-top: 12px;
}

.meeting-left label:first-child {
	margin-top: 0;
}

.meeting-left .form-control {
	margin-bottom: 0;
}

.meeting-right {
	background: #f8faff;
	padding: 20px;
	border-radius: 12px;
	border: 1px solid #e2e8f0;
	max-height: 460px;
	overflow-y: auto;
}

.meeting-right h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	margin-bottom: 14px;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
	display: flex;
	align-items: center;
	gap: 8px;
}

.meeting-right::-webkit-scrollbar {
	width: 3px;
}

.meeting-right::-webkit-scrollbar-thumb {
	background: #c7d2fe;
	border-radius: 6px;
}

.meeting-right::-webkit-scrollbar-track {
	background: #e2ebf0;
}

.meeting-scroll {
	padding: 4px 0;
	max-height: 320px;
	overflow-y: auto;
	scroll-behavior: smooth;
}

.meeting-scroll::-webkit-scrollbar {
	width: 8px;
}

.meeting-scroll::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #c3cfe2, #9faed9);
	border-radius: 10px;
}

.meeting-scroll::-webkit-scrollbar-track {
	background: #e2ebf0;
}

.join-meeting-btn {
	margin-top: 10px;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 6px 12px;
	border-radius: 20px;
	background: #bee3f8;
	color: #2b6cb0;
	font-weight: 600;
	font-size: 13px;
	text-decoration: none;
}

.join-meeting-btn:hover {
	background: #90cdf4;
}

#schedulemeeting {
	max-height: 500px;
	overflow-y: auto;
	padding: 6px;
	overflow-x: hidden;
	border-radius: 10px;
}

#schedulemeeting::-webkit-scrollbar {
	width: 8px;
}

#schedulemeeting::-webkit-scrollbar-track {
	background: #e2ebf0;
	border-radius: 10px;
}

#schedulemeeting::-webkit-scrollbar-thumb {
	background: #c3cfe2;
	border-radius: 10px;
}

#schedulemeeting::-webkit-scrollbar-thumb:hover {
	background: #b2c2d8;
}

/* ================= BUTTONS ================= */
.primary-btn {
	padding: 12px 20px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	background: #4f46e5;
	color: #fff;
	transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
}

.primary-btn:hover:not(:disabled) {
	background: #4338ca;
	transform: translateY(-1px);
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
}

.primary-btn:disabled {
	background: #94a3b8;
	color: #fff;
	cursor: not-allowed;
	opacity: 0.8;
	transform: none;
	box-shadow: none;
}

.reject-btn {
	padding: 12px 20px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	background: #dc2626;
	color: #fff;
	transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
}

.reject-btn:hover:not(:disabled) {
	background: #b91c1c;
	transform: translateY(-1px);
	box-shadow: 0 4px 12px rgba(220, 38, 38, 0.35);
}

.reject-btn:disabled {
	background: #cbd5e1;
	color: #64748b;
	cursor: not-allowed;
	opacity: 0.8;
	transform: none;
	box-shadow: none;
}

.secondary-btn {
	background: #4f46e5;
	color: #fff;
	padding: 10px 18px;
	border: none;
	border-radius: 8px;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
}

.secondary-btn:hover {
	background: #4338ca;
	transform: translateY(-1px);
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
}

.view-all-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 10px 18px;
	border-radius: 8px;
	border: none;
	background: #4f46e5;
	color: #fff;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	transition: background 0.2s, box-shadow 0.2s;
}

.view-all-btn:hover {
	background: #4338ca;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
}

/* ================= NOTIFICATION PANEL ================= */
.notification-panel {
	position: fixed;
	bottom: 30px;
	right: -380px;
	width: 350px;
	height: 450px;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	box-shadow: 0 10px 40px rgba(0, 0, 0, 0.12);
	border-radius: 12px;
	transition: right 0.3s ease-in-out;
	z-index: 1000;
	font-family: 'Inter', system-ui, sans-serif;
}

.notification-panel.show {
	right: 25px;
}

.notification-header {
	background: #4f46e5;
	color: #fff;
	padding: 16px 20px;
	border-radius: 12px 12px 0 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	font-weight: 600;
	font-size: 15px;
}

.notification-header button {
	background: rgba(255, 255, 255, 0.2);
	border: none;
	color: #fff;
	font-size: 18px;
	cursor: pointer;
	width: 32px;
	height: 32px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
}

.notification-list {
	padding: 15px;
	max-height: 380px;
	overflow-y: auto;
}

.notification-item {
	background: #f8fafc;
	padding: 12px 14px;
	margin-bottom: 10px;
	border: 1px solid #e2e8f0;
	border-left: 4px solid #4f46e5;
	border-radius: 8px;
	font-size: 14px;
}

.notification-list::-webkit-scrollbar {
	width: 6px;
}

.notification-list::-webkit-scrollbar-thumb {
	background: rgba(0, 0, 0, 0.25);
	border-radius: 4px;
}

/* ================= PASSWORD MODAL ================= */
.password-modal {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.35);
	backdrop-filter: blur(6px);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 2000;
	visibility: hidden;
	opacity: 0;
	transition: opacity 0.25s ease;
}

.password-box {
	width: 400px;
	max-width: 90%;
	background: white;
	align-items: center;
	border-radius: 14px;
	box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
	overflow: hidden;
	animation: fadeIn 0.25s ease;
}

.password-header {
	padding: 14px 18px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: white;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.password-header .close-btn {
	background: none;
	border: none;
	color: white;
	font-size: 18px;
	cursor: pointer;
}

.password-header h4 {
	margin: 0;
	font-size: 16px;
}

.password-body {
	padding: 25px;
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.password-body .time-card {
	background: #f3f4f6;
	padding: 12px 14px;
	border-radius: 8px;
	margin-bottom: 10px;
	font-size: 14px;
}

.password-body input {
	width: 100%;
	padding: 12px 14px;
	border-radius: 8px;
	border: 1px solid #d1d5db;
	font-size: 14px;
	box-sizing: border-box;
}

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

@
keyframes fadeIn {from { opacity:0;
	transform: scale(0.95);
}

to {
	opacity: 1;
	transform: scale(1);
}

}

/* ================= BREAK TIME ================= */
.break-fieldset {
	border-radius: 16px;
	padding: 22px 20px 26px;
	border: none;
	background: #ffffff;
	box-shadow: 0 8px 32px rgba(14, 165, 233, 0.15);
	height: auto;
	margin-top: 18px;
}

.break-fieldset legend {
	padding: 8px 18px;
	font-size: 15px;
	font-weight: 700;
	color: #fff;
	border-radius: 20px;
	background: linear-gradient(135deg, #0ea5e9, #6c63ff);
	border: none;
	box-shadow: 0 4px 12px rgba(14, 165, 233, 0.4);
}

.break-total-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 10px 14px;
	background: linear-gradient(135deg, rgba(14, 165, 233, 0.08),
		rgba(99, 102, 241, 0.08));
	border-radius: 10px;
	border: 1px solid rgba(14, 165, 233, 0.15);
	margin-bottom: 12px;
}

.break-total-row .tr-label {
	font-size: 12px;
	color: #6b7280;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.break-total-row .tr-val {
	font-size: 15px;
	font-weight: 800;
	color: #0ea5e9;
	letter-spacing: 1px;
}

.break-actions {
	display: flex;
	gap: 12px;
	margin-bottom: 14px;
}

.break-actions button {
	flex: 1;
	padding: 11px 10px;
	border-radius: 25px;
	border: none;
	font-weight: 700;
	font-size: 13px;
	cursor: pointer;
	transition: all 0.2s;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 7px;
}

.break-actions button:disabled {
	opacity: 0.4;
	cursor: not-allowed;
	transform: none !important;
	box-shadow: none !important;
}

.break-log {
	max-height: 110px;
	overflow-y: auto;
	display: flex;
	flex-direction: column;
	margin-top: 8px;
	gap: 6px;
}

.break-log::-webkit-scrollbar {
	width: 3px;
}

.break-log::-webkit-scrollbar-thumb {
	background: rgba(14, 165, 233, 0.3);
	border-radius: 3px;
}

.no-task-text {
	font-size: 14px;
	color: #64748b;
	margin-top: 8px;
}

.time-card {
	background: #f8f9ff;
	padding: 10px 12px;
	border-radius: 8px;
	font-size: 12px;
	border: 1px solid rgba(148, 163, 184, 0.4);
}

/* ================= MANAGER ATTENDANCE ================= */
.attendance-cards-row {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	margin-bottom: 24px;
	align-items: stretch;
}

@media ( max-width : 768px) {
	.attendance-cards-row {
		grid-template-columns: 1fr;
	}
}

.attendance-cards-row .status-card, .attendance-cards-row .break-card {
	background: #ffffff;
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 20px 24px;
	margin-bottom: 0;
	min-height: 280px;
	display: flex;
	flex-direction: column;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	transition: box-shadow 0.2s ease;
}

.attendance-cards-row .status-card:hover, .attendance-cards-row .break-card:hover
	{
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.attendance-cards-row .break-card .break-log {
	flex: 1;
	min-height: 60px;
}

.attendance-section-title {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 12px;
}

.status-card .punch-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 10px 0;
	border-bottom: 1px solid #f1f5f9;
}

.status-card .punch-row:last-of-type {
	border-bottom: none;
}

.status-card .punch-label {
	color: #64748b;
	font-weight: 600;
	font-size: 14px;
}

.status-card .punch-value {
	color: #1e293b;
	font-weight: 600;
	font-size: 14px;
}

.punch-actions-nexus {
	display: flex;
	gap: 12px;
	margin-top: 20px;
	flex-wrap: wrap;
}

.punch-in-btn-nexus {
	padding: 12px 24px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	background: #64748b;
	color: #fff;
	transition: background 0.2s;
}

.punch-in-btn-nexus:not(:disabled) {
	background: #4f46e5;
}

.punch-in-btn-nexus:hover:not(:disabled) {
	background: #4338ca;
}

.punch-in-btn-nexus:disabled {
	opacity: 0.7;
	cursor: not-allowed;
}

.punch-out-btn-nexus {
	padding: 12px 24px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	background: #dc2626;
	color: #fff;
	transition: background 0.2s;
}

.punch-out-btn-nexus:hover:not(:disabled) {
	background: #b91c1c;
}

.punch-out-btn-nexus:disabled {
	background: #94a3b8;
	opacity: 0.7;
	cursor: not-allowed;
}

.break-action-btn {
	padding: 11px 20px;
	border-radius: 8px;
	border: none;
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	transition: opacity 0.2s, background 0.2s;
}

.break-action-btn:disabled {
	opacity: 0.45;
	cursor: not-allowed;
	pointer-events: auto;
}

.start-break-btn {
	background: #7c3aed !important;
	color: #fff !important;
}

.start-break-btn:hover:not(:disabled) {
	background: #6d28d9 !important;
}

.end-break-btn-nexus {
	background: #64748b !important;
	color: #fff !important;
}

.end-break-btn-nexus:hover:not(:disabled) {
	background: #475569 !important;
}

/* ================= TEAM ATTENDANCE VIEW TOGGLE ================= */
.team-attendance-toolbar {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 12px;
	margin-bottom: 16px;
}

.team-attendance-view-toggle {
	display: inline-flex;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	overflow: hidden;
	background: #f8fafc;
}

.team-attendance-view-toggle button {
	padding: 10px 18px;
	border: none;
	background: transparent;
	font-size: 14px;
	font-weight: 600;
	color: #64748b;
	cursor: pointer;
	transition: background 0.2s, color 0.2s;
}

.team-attendance-view-toggle button:first-child {
	border-right: 1px solid #e2e8f0;
}

.team-attendance-view-toggle button:hover {
	background: #f1f5f9;
	color: #334155;
}

.team-attendance-view-toggle button.active {
	background: #4f46e5;
	color: #fff;
}

.employee-grid-3 {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 20px;
	margin-top: 12px;
}

@media ( max-width : 1100px) {
	.employee-grid-3 {
		grid-template-columns: repeat(2, 1fr);
	}
}

@media ( max-width : 600px) {
	.employee-grid-3 {
		grid-template-columns: 1fr;
	}
}

.employee-list-view {
	display: none;
	margin-top: 12px;
}

.employee-list-view.active {
	display: block;
}

.employee-grid-wrap {
	display: block;
}

.employee-grid-wrap.list-mode .employee-grid-3 {
	display: none;
}

.employee-grid-wrap.list-mode .employee-list-view {
	display: block;
}

.team-attendance-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 14px;
	background: #fff;
	border-radius: 12px;
	overflow: hidden;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	border: 1px solid #e2e8f0;
}

.team-attendance-table th {
	text-align: left;
	padding: 14px 16px;
	background: #f1f5f9;
	color: #334155;
	font-weight: 600;
	font-size: 13px;
}

.team-attendance-table td {
	padding: 14px 16px;
	border-top: 1px solid #e2e8f0;
	color: #475569;
}

.team-attendance-table tbody tr:hover {
	background: #f8fafc;
}

.team-attendance-table .list-status {
	display: inline-block;
	padding: 4px 10px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 600;
}

.team-attendance-table .list-status.present {
	background: #dcfce7;
	color: #166534;
}

.team-attendance-table .list-status.absent {
	background: #fee2e2;
	color: #991b1b;
}

.team-attendance-table .list-status.punched-in {
	background: #dbeafe;
	color: #1e40af;
}

/* Export buttons */
.export-actions {
	display: flex;
	gap: 12px;
}

.export-btn {
	padding: 10px 18px;
	background: #4f46e5;
	border: none;
	border-radius: 8px;
	font-weight: 600;
	font-size: 14px;
	color: #fff;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: background 0.2s, box-shadow 0.2s;
}

.export-btn:hover {
	background: #4338ca;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
}

.export-btn i {
	font-size: 14px;
}

.team-attendance-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
}

.team-title {
	margin: 0;
	white-space: nowrap;
}

.attendance-scroll {
	max-height: 420px;
	overflow-y: auto;
	border-radius: 8px;
	padding-right: 6px;
	scroll-behavior: smooth;
}

.attendance-scroll::-webkit-scrollbar {
	width: 8px;
}

.attendance-scroll::-webkit-scrollbar-thumb {
	background: linear-gradient(180deg, #c3cfe2, #9faed9);
	border-radius: 10px;
}

.attendance-scroll::-webkit-scrollbar-track {
	background: #e2ebf0;
}

/* ================= PERFORMANCE MATRIX — 3-Step Flow ================= */
.performance-fieldset {
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 24px;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.performance-fieldset legend {
	padding: 8px 16px;
	background: #eef2ff;
	border-radius: 8px;
	font-size: 15px;
	font-weight: 600;
	color: #1e293b;
}

/* Step indicator */
.perf-steps {
	display: flex;
	align-items: center;
	margin-bottom: 22px;
	padding: 0 2px;
}

.perf-step {
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 13px;
	font-weight: 500;
	color: #94a3b8;
	transition: color 0.25s;
}

.perf-step.active {
	color: #1e293b;
}

.perf-step.done {
	color: #10b981;
}

.perf-step-num {
	width: 28px;
	height: 28px;
	border-radius: 50%;
	border: 2px solid #cbd5e1;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	font-weight: 700;
	flex-shrink: 0;
	transition: all 0.25s;
	background: #fff;
}

.perf-step.active .perf-step-num {
	background: #4f46e5;
	color: #fff;
	border-color: #4f46e5;
	box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
}

.perf-step.done .perf-step-num {
	background: #10b981;
	color: #fff;
	border-color: #10b981;
}

.perf-step-line {
	flex: 1;
	height: 2px;
	background: #e2e8f0;
	margin: 0 10px;
	border-radius: 2px;
	transition: background 0.25s;
}

.perf-step-line.done {
	background: #10b981;
}

/* 3-column layout for performance panels */
.performance-layout {
	display: grid;
	grid-template-columns: 1fr 1fr 1fr;
	gap: 16px;
	margin-top: 8px;
	align-items: start;
}

@media ( max-width : 900px) {
	.performance-layout {
		grid-template-columns: 1fr;
	}
}

/* Panel base */
.perf-team-panel {
	background: #f8faff;
	border: 1px solid #e2e8f0;
	border-radius: 10px;
	padding: 18px;
	transition: opacity 0.25s, box-shadow 0.25s;
}

.perf-team-panel.locked {
	opacity: 0.45;
	pointer-events: none;
}

.perf-team-panel h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	margin-bottom: 14px;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
}

/* Member/Team list */
.perf-member-list {
	display: flex;
	flex-direction: column;
	gap: 8px;
	max-height: 300px;
	overflow-y: auto;
}

.perf-member-list::-webkit-scrollbar {
	width: 4px;
}

.perf-member-list::-webkit-scrollbar-thumb {
	background: #c3cfe2;
	border-radius: 4px;
}

/* Individual member/team card */
.perf-member-card {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 10px 14px;
	background: #ffffff;
	border: 2px solid #e2e8f0;
	border-radius: 10px;
	cursor: pointer;
	transition: border-color 0.2s, box-shadow 0.2s, transform 0.15s;
}

.perf-member-card:hover {
	border-color: #a5b4fc;
	transform: translateY(-1px);
	box-shadow: 0 4px 10px rgba(79, 70, 229, 0.12);
}

.perf-member-card.selected {
	border-color: #4f46e5;
	background: #eef2ff;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2);
}

/* Avatar — round for members, rounded-square for teams */
.perf-member-avatar {
	width: 36px;
	height: 36px;
	border-radius: 50%;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
	font-size: 13px;
	font-weight: 700;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.perf-team-avatar {
	border-radius: 9px !important;
	background: linear-gradient(135deg, #ec4899, #f43f5e) !important;
}

.perf-member-info {
	flex: 1;
	min-width: 0;
}

.perf-member-name {
	font-size: 13px;
	font-weight: 600;
	color: #1e293b;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.perf-member-email {
	font-size: 11px;
	color: #64748b;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.perf-member-check {
	width: 20px;
	height: 20px;
	border-radius: 50%;
	border: 2px solid #e2e8f0;
	background: #fff;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	transition: background 0.2s, border-color 0.2s;
}

.perf-member-card.selected .perf-member-check {
	background: #4f46e5;
	border-color: #4f46e5;
	color: #fff;
}

/* Selected banner inside panels 2 and 3 */
.perf-selected-banner {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 9px 12px;
	background: #eef2ff;
	border: 1px solid #c7d2fe;
	border-radius: 8px;
	margin-bottom: 12px;
	min-height: 42px;
	font-size: 12px;
	color: #64748b;
}

.perf-selected-banner .sel-tag {
	background: #4f46e5;
	color: #fff;
	border-radius: 5px;
	padding: 2px 8px;
	font-size: 11px;
	font-weight: 600;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	max-width: 120px;
}

/* Right panel: rating form */
.perf-rating-panel {
	background: #f8faff;
	border: 1px solid #e2e8f0;
	border-radius: 10px;
	padding: 18px;
	display: flex;
	flex-direction: column;
	gap: 14px;
	transition: opacity 0.25s;
}

.perf-rating-panel.locked {
	opacity: 0.45;
	pointer-events: none;
}

.perf-rating-panel h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
	margin: 0;
}

/* Selected employee display (panel 3) */
.perf-selected-emp {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 12px 14px;
	background: #eef2ff;
	border: 1px solid #c7d2fe;
	border-radius: 10px;
	min-height: 60px;
}

.perf-selected-emp .placeholder-text {
	color: #94a3b8;
	font-size: 13px;
	font-style: italic;
}

.perf-selected-emp .selected-name {
	font-size: 14px;
	font-weight: 600;
	color: #1e293b;
}

.perf-selected-emp .selected-email {
	font-size: 12px;
	color: #4f46e5;
}

/* Rating options */
.radio-group {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 10px;
}

.radio-group label {
	background: #ffffff;
	padding: 12px 14px;
	border-radius: 10px;
	display: flex;
	align-items: center;
	gap: 10px;
	font-weight: 500;
	cursor: pointer;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
	border: 2px solid #e2e8f0;
	transition: border-color 0.2s, background 0.2s, transform 0.15s;
	font-size: 13px;
}

.radio-group label:hover {
	transform: translateY(-1px);
	border-color: #a5b4fc;
}

.radio-group input[type="radio"]:checked+span {
	font-weight: 700;
	color: #4f46e5;
}

.radio-group label:has(input[type="radio"]:checked) {
	border-color: #4f46e5;
	background: #eef2ff;
}

@media ( max-width : 600px) {
	.radio-group {
		grid-template-columns: 1fr;
	}
}

.no-data {
	text-align: center;
	padding: 20px;
	font-weight: 600;
	color: #4a5568;
}

/* ================= TOAST ================= */
.toast {
	position: fixed;
	top: 80px;
	right: 30px;
	background: #e2ebf0;
	color: black;
	padding: 14px 20px 14px 44px;
	border-radius: 10px;
	font-size: 15px;
	font-weight: 500;
	display: none;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
	z-index: 9999;
	line-height: 1.4;
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

.toast.success {
	background: #e2ebf0;
	color: black;
}

.toast.success::before {
	content: "✔";
}

.toast.error {
	background: #e2ebf0;
	color: black;
}

.toast.error::before {
	content: "✖";
}

@
keyframes toastIn {from { opacity:0;
	transform: translateX(120px);
}

to {
	opacity: 1;
	transform: translateX(0);
}

}
@
keyframes toastOut {from { opacity:1;
	transform: translateX(0);
}

to {
	opacity: 0;
	transform: translateX(120px);
}

}

/* ================= FULL DARK MODE ================= */
body.dark-theme {
	background: #0f172a !important;
	color: #e5e7eb !important;
}

body.dark-theme .top-bar {
	background: linear-gradient(135deg, #0f172a, #1e293b, #1e3a8a)
		!important;
	border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
}

body.dark-theme .sidebar {
	background: rgba(30, 41, 59, 0.8) !important;
	border-right: 1px solid rgba(255, 255, 255, 0.1) !important;
}

body.dark-theme .sidebar-bottom {
	border-top: 1px solid rgba(255, 255, 255, 0.1) !important;
}

body.dark-theme .sidebar-btn.active {
	background: linear-gradient(135deg, #d60f47, #948e90) !important;
	color: #ffffff !important;
	box-shadow: 0 4px 12px rgba(37, 99, 235, 0.5);
}

body.dark-theme .sidebar-btn:hover {
	background: rgba(102, 126, 234, 0.8) !important;
	color: white !important;
}

body.dark-theme .sidebar-btn {
	color: #e5e7eb !important;
}

body.dark-theme .sidebar-logout-btn {
	color: #fca5a5 !important;
}

body.dark-theme .sidebar-logout-btn:hover {
	background: rgba(220, 38, 38, 0.2) !important;
}

body.dark-theme .content-area {
	background: #0f172a !important;
}

body.dark-theme .box {
	background: rgba(30, 41, 59, 0.8) !important;
	color: #e5e7eb !important;
	box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3) !important;
}

body.dark-theme .employee-card, body.dark-theme .task-card, body.dark-theme .meeting-left,
	body.dark-theme .meeting-right {
	background: rgba(30, 41, 59, 0.8) !important;
	color: #eee !important;
	border-left: 5px solid #60a5fa !important;
}

body.dark-theme .emp-body, body.dark-theme .tasks-title, body.dark-theme h3,
	body.dark-theme h4, body.dark-theme p, body.dark-theme b, body.dark-theme span,
	body.dark-theme .task-desc {
	color: #eee !important;
}

body.dark-theme .emp-status {
	background: #334155 !important;
	color: #ffffff !important;
}

body.dark-theme input, body.dark-theme select, body.dark-theme textarea,
	body.dark-theme .form-control {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #ffffff !important;
	border: 1px solid #555 !important;
}

body.dark-theme .task-desc {
	color: #ffffff !important;
}

body.dark-theme .notification-panel {
	background: linear-gradient(135deg, rgba(30, 41, 59, 0.85),
		rgba(51, 65, 85, 0.75)) !important;
}

body.dark-theme .notification-item {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #ffffff !important;
}

body.dark-theme .radio-group label {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #eee !important;
	border: 1px solid #555 !important;
}

body.dark-theme .settings-drawer {
	background: linear-gradient(135deg, rgba(30, 41, 59, 0.85),
		rgba(51, 65, 85, 0.75)) !important;
}

body.dark-theme .settings-item:hover {
	background: rgba(99, 102, 241, 0.2) !important;
}

body.dark-theme .settings-item {
	color: #e5e7eb !important;
}

body.dark-theme .settings-item i {
	color: #a5b4fc !important;
}

body.dark-theme .perf-team-panel, body.dark-theme .perf-rating-panel,
	body.dark-theme .perf-member-card, body.dark-theme .meeting-left, body.dark-theme .meeting-right,
	body.dark-theme .leave-apply-left, body.dark-theme .leave-apply-right {
	background: rgba(30, 41, 59, 0.8) !important;
	border-color: #334155 !important;
	color: #eee !important;
}

body.dark-theme .perf-member-card.selected {
	background: rgba(79, 70, 229, 0.3) !important;
	border-color: #818cf8 !important;
}

body.dark-theme .perf-selected-emp, body.dark-theme .perf-selected-banner
	{
	background: rgba(79, 70, 229, 0.2) !important;
	border-color: #4f46e5 !important;
}
</style>
</head>

<body>

	<div id="overlay" onclick="closeAll()" style="display: none;"></div>

	<!-- SETTINGS DRAWER -->
	<div id="settingsPanel" class="settings-drawer">
		<div class="modal-header">
			<h4>Settings</h4>
			<span onclick="closeSettings()" style="cursor: pointer;">X</span>
		</div>
		<div class="settings-item" onclick="openProfile()">
			<i class="fa-solid fa-user"></i> My Profile
		</div>
		<div class="settings-item" onclick="openChangePassword()">
			<i class="fa-solid fa-lock"></i> Change Password
		</div>
	</div>

	<!-- PASSWORD MODAL -->
	<div id="passwordModal" class="modal">
		<div class="modal-content" style="text-align: center;">
			<div class="modal-header">
				<h4>Change Password</h4>
				<span onclick="closeChangePassword()" style="cursor: pointer;">✕</span>
			</div>
			<div class="modal-body">
				<input type="password" id="newPassword" placeholder="New Password">
				<input type="password" id="confirmPassword"
					placeholder="Confirm Password">
				<button onclick="submitPassword()">Update Password</button>
			</div>
		</div>
	</div>

	<!-- TOP BAR -->
	<div class="top-bar">
		<h2>Smart Office • Manager Dashboard</h2>
		<div class="user-area">
			<button class="icon-btn" onclick="openNotifications()">
				<i class="fa-solid fa-bell"></i>
			</button>
			<span class="welcome">Welcome, <strong>${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
		</div>
	</div>

	<!-- MAIN -->
	<div class="main-container">
		<div class="sidebar">

			<!-- Nav buttons -->
			<div class="sidebar-nav">
				<button
					class="sidebar-btn <%=activeTab.equals("attendance") ? "active" : ""%>"
					onclick="setActive(this); showSection('attendance')">
					<i class="fa-solid fa-user-check"></i> <span>Attendance</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("teamSection") ? "active" : ""%>"
					onclick="setActive(this); showSection('teamSection')">
					<i class="fa-solid fa-users"></i> <span>My Team</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("assignTask") ? "active" : ""%>"
					onclick="setActive(this); showSection('assignTask')">
					<i class="fa-solid fa-list-check"></i> <span>Tasks</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("schedulemeeting") ? "active" : ""%>"
					onclick="setActive(this); showSection('schedulemeeting')">
					<i class="fa-solid fa-handshake"></i> <span>Schedule
						Meetings</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("leave") ? "active" : ""%>"
					onclick="setActive(this); location.href='<%=request.getContextPath()%>/manager?tab=leave'">
					<i class="fa-solid fa-calendar-xmark"></i> <span>Leave
						Requests</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("performance") ? "active" : ""%>"
					onclick="setActive(this); showSection('performance')">
					<i class="fa-solid fa-chart-line"></i> <span>Performance
						Matrix</span>
				</button>

				<button
					class="sidebar-btn <%=activeTab.equals("calendar") ? "active" : ""%>"
					onclick="setActive(this); openCalendar()">
					<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
				</button>
			</div>

			<!-- Bottom: Settings + Logout -->
			<div class="sidebar-bottom">
				<button
					class="sidebar-btn <%=activeTab.equals("settings") ? "active" : ""%>"
					onclick="setActive(this); showSection('settings')">
					<i class="fa-solid fa-gear"></i> <span>Settings</span>
				</button>
				<a href="<%=request.getContextPath()%>/logout"
					class="sidebar-logout-btn"> <i
					class="fa-solid fa-right-to-bracket"></i> <span>Logout</span>
				</a>
			</div>
		</div>

		<!-- ===== NEW SETTINGS (exactly like your screenshot) ===== -->
		<div class="box" id="settings" style="display: none; padding: 32px;">
			<div class="flex items-center gap-3 mb-2">
				<i class="fa-solid fa-gear text-4xl text-indigo-600"></i>
				<h1 class="text-3xl font-semibold text-gray-900">Settings</h1>
			</div>
			<p class="text-gray-600 mb-10">Manage your profile and account
				preferences.</p>

			<!-- TABS -->
			<div class="flex border-b border-gray-200 mb-10">
				<button onclick="openProfileTab()" id="profile-tab-btn"
					class="tab-button active flex items-center gap-3 px-10 py-4 text-base font-medium text-indigo-600">
					<i class="fa-solid fa-user"></i> My Profile
				</button>
				<button onclick="openChangePasswordTab()" id="password-tab-btn"
					class="tab-button flex items-center gap-3 px-10 py-4 text-base font-medium text-gray-600 hover:text-gray-900">
					<i class="fa-solid fa-lock"></i> Change Password
				</button>
			</div>

			<!-- MY PROFILE CARD (exactly like image) -->
			<div id="profile-content"
				class="bg-slate-50 rounded-3xl p-8 shadow-sm">
				<div class="space-y-6">
					<!-- Full Name -->
					<div
						class="flex items-center gap-6 px-5 py-5 hover:bg-white rounded-2xl transition-all">
						<div
							class="w-11 h-11 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
							<i class="fa-solid fa-user text-2xl"></i>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-500">Full Name</p>
							<p class="text-xl font-semibold text-gray-900">
								<%=userObj != null && userObj.getFullname() != null && !userObj.getFullname().isEmpty()
		? userObj.getFullname()
		: "--"%>
							</p>
						</div>
					</div>

					<!-- Email -->
					<div
						class="flex items-center gap-6 px-5 py-5 hover:bg-white rounded-2xl transition-all">
						<div
							class="w-11 h-11 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
							<i class="fa-solid fa-envelope text-2xl"></i>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-500">Email</p>
							<p class="text-xl font-semibold text-gray-900">
								<%=userObj != null ? userObj.getEmail() : "--"%>
							</p>
						</div>
					</div>

					<!-- Role -->
					<div
						class="flex items-center gap-6 px-5 py-5 hover:bg-white rounded-2xl transition-all">
						<div
							class="w-11 h-11 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
							<i class="fa-solid fa-briefcase text-2xl"></i>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-500">Role</p>
							<p class="text-xl font-semibold text-gray-900">
								<%=userObj != null ? userObj.getRole() : "Manager"%>
							</p>
						</div>
					</div>

					<!-- Phone -->
					<div
						class="flex items-center gap-6 px-5 py-5 hover:bg-white rounded-2xl transition-all">
						<div
							class="w-11 h-11 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
							<i class="fa-solid fa-phone text-2xl"></i>
						</div>
						<div class="flex-1">
							<p class="text-sm font-medium text-gray-500">Phone</p>
							<p class="text-xl font-semibold text-gray-900">
								<%=userObj != null && userObj.getPhone() != null ? userObj.getPhone() : "--"%>
							</p>
						</div>
					</div>
				</div>
			</div>

			<!-- (Change Password tab will open your existing modal - no new code needed) -->
		</div>




		<div class="content-area">
			<div class="box" id="blank" style="display: none;">
				<h3>Welcome 👋</h3>
				<p>Select an option from the left menu to continue.</p>
			</div>

			<!-- ===== Self Profile ===== -->
			<div id="profileModal" class="password-modal">
				<div class="password-box">
					<div class="password-header">
						<h4>My Profile</h4>
						<span class="close-btn" onclick="closeProfile()">✖</span>
					</div>
					<div class="password-body">
						<div class="time-card">
							Full Name: <b><%=userObj != null && userObj.getFullname() != null && !userObj.getFullname().isEmpty()
		? userObj.getFullname()
		: "--"%></b>
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

			<!-- ===== Performance Matrix (3-Step: Team → Member → Rate) ===== -->
			<div class="box centered-box" id="performance" style="display: none;">
				<fieldset class="performance-fieldset">
					<legend>
						<i class="fa-solid fa-chart-line"></i> Performance Matrix
					</legend>

					<!-- Step Indicator -->
					<div class="perf-steps">
						<div class="perf-step active" id="perfStep1">
							<div class="perf-step-num">1</div>
							<span>Select Team</span>
						</div>
						<div class="perf-step-line" id="perfLine1"></div>
						<div class="perf-step" id="perfStep2">
							<div class="perf-step-num">2</div>
							<span>Select Member</span>
						</div>
						<div class="perf-step-line" id="perfLine2"></div>
						<div class="perf-step" id="perfStep3">
							<div class="perf-step-num">3</div>
							<span>Rate Performance</span>
						</div>
					</div>

					<div class="performance-layout">

						<!-- PANEL 1: Team Selection -->
						<div class="perf-team-panel" id="panelTeam">
							<h4>
								<i class="fa-solid fa-layer-group"
									style="margin-right: 6px; color: #ec4899;"></i>Select Team
							</h4>
							<div class="perf-member-list" id="perfTeamList">
								<%
								List<Team> perfTeams = (List<Team>) request.getAttribute("myTeams");
								if (perfTeams != null && !perfTeams.isEmpty()) {
									for (Team t : perfTeams) {
										String tName = t.getName();
										String tInitials = "";
										String[] tParts = tName.trim().split("\\s+");
										for (String tp : tParts) {
									if (!tp.isEmpty())
										tInitials += tp.substring(0, 1).toUpperCase();
										}
										if (tInitials.length() > 2)
									tInitials = tInitials.substring(0, 2);
										int memberCount = t.getMembers() != null ? t.getMembers().size() : 0;
								%>
								<div class="perf-member-card" data-teamname="<%=tName%>"
									onclick="selectPerfTeam(this)">
									<div class="perf-member-avatar perf-team-avatar"><%=tInitials%></div>
									<div class="perf-member-info">
										<div class="perf-member-name"><%=tName%></div>
										<div class="perf-member-email"><%=memberCount%>
											member<%=memberCount != 1 ? "s" : ""%></div>
									</div>
									<div class="perf-member-check">
										<i class="fa-solid fa-check"
											style="font-size: 10px; display: none;"></i>
									</div>
								</div>
								<%
								}
								} else {
								%>
								<p class="no-data" style="padding: 16px 0;">No teams found.</p>
								<%
								}
								%>
							</div>
						</div>

						<!-- PANEL 2: Member Selection (locked until team chosen) -->
						<div class="perf-team-panel locked" id="panelMember">
							<h4>
								<i class="fa-solid fa-users"
									style="margin-right: 6px; color: #4f46e5;"></i>Select Member
							</h4>
							<div class="perf-selected-banner" id="perfTeamBanner">
								<span
									style="font-style: italic; color: #94a3b8; font-size: 12px;">←
									Select a team first</span>
							</div>
							<div class="perf-member-list" id="perfMemberList">
								<p class="no-data" style="padding: 10px 0; font-size: 13px;">No
									team selected.</p>
							</div>
						</div>

						<!-- PANEL 3: Rating (locked until member chosen) -->
						<div class="perf-rating-panel locked" id="panelRating">
							<h4>
								<i class="fa-solid fa-star"
									style="margin-right: 6px; color: #f59e0b;"></i>Rate Performance
							</h4>

							<!-- Selected member display -->
							<div class="perf-selected-emp" id="perfSelectedDisplay">
								<span class="placeholder-text">← Select a team member to
									rate</span>
							</div>

							<form id="performanceForm"
								action="<%=request.getContextPath()%>/submitPerformance"
								method="post">

								<!-- Hidden fields -->
								<input type="hidden" id="perfTeamInput" name="team" value="">
								<input type="hidden" id="perfEmployeeInput" name="employee"
									value="">

								<!-- Rating Options -->
								<div>
									<div
										style="font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 10px;">
										Performance Rating</div>
									<div class="radio-group">
										<label> <input type="radio" name="rating"
											value="EXCELLENCE" required> <span>⭐
												Excellence</span>
										</label> <label> <input type="radio" name="rating"
											value="GOOD"> <span>👍 Good</span>
										</label> <label> <input type="radio" name="rating"
											value="AVERAGE"> <span>😐 Average</span>
										</label> <label> <input type="radio" name="rating"
											value="BELOW_AVERAGE"> <span>📉 Below Average</span>
										</label>
									</div>
								</div>

								<button class="primary-btn" type="submit" id="perfSubmitBtn"
									disabled style="width: 100%; margin-top: 8px; opacity: 0.6;">
									<i class="fa-solid fa-paper-plane" style="margin-right: 6px;"></i>Submit
									Performance
								</button>

							</form>
						</div>

					</div>
					<!-- /.performance-layout -->
				</fieldset>
			</div>

			<!-- ===== Schedule Meeting (improved alignment) ===== -->
			<div class="box" id="schedulemeeting" style="display: none;">

				<fieldset class="meeting-fieldset">
					<legend>Schedule Meeting</legend>

					<div class="section-header">
						<span style="font-size: 13px; color: #64748b;">Fill in the
							details below to schedule a new meeting.</span>
						<button class="view-all-btn" onclick="openAllMeetings()">
							<i class="fa-solid fa-eye"></i> View All
						</button>
					</div>

					<!-- GRID WRAPPER -->
					<div class="meeting-grid">

						<!-- LEFT: Schedule Form -->
						<div class="meeting-left">
							<h4>
								<i class="fa-solid fa-calendar-plus"
									style="margin-right: 6px; color: #4f46e5;"></i>New Meeting
							</h4>

							<form id="scheduleMeetingForm"
								action="<%=request.getContextPath()%>/schedulemeeting"
								method="post">

								<label>Meeting Title</label> <input class="form-control"
									type="text" name="title" placeholder="e.g. Weekly Standup"
									required> <label>Description</label>
								<textarea class="form-control" name="description"
									placeholder="Briefly describe the agenda" rows="3" required></textarea>

								<div class="form-row">
									<div>
										<label>Start Time</label> <input class="form-control"
											type="datetime-local" name="startTime" required>
									</div>
									<div>
										<label>End Time</label> <input class="form-control"
											type="datetime-local" name="endTime" required>
									</div>
								</div>

								<label>Meeting Link <span
									style="font-weight: 400; color: #94a3b8;">(optional)</span></label> <input
									class="form-control" type="text" name="meetingLink"
									placeholder="Zoom / Google Meet link">

								<button class="primary-btn" type="submit"
									style="width: 100%; margin-top: 16px;">
									<i class="fa-solid fa-calendar-check"
										style="margin-right: 6px;"></i>Schedule Meeting
								</button>

							</form>
						</div>

						<!-- RIGHT: Today's Meetings -->
						<div class="meeting-right">
							<h4>
								<i class="fa-solid fa-calendar-check"></i> Today's Meetings
							</h4>

							<div class="meeting-scroll">
								<%
								List<com.smartoffice.model.Meeting> todayMeetings = (List<com.smartoffice.model.Meeting>) request
										.getAttribute("todayMeetings");

								if (todayMeetings != null && !todayMeetings.isEmpty()) {
									for (com.smartoffice.model.Meeting m : todayMeetings) {
								%>
								<div class="employee-card" style="margin-bottom: 10px;">
									<div class="emp-header">
										<i class="fa-solid fa-video"></i> <span class="emp-name"><%=m.getTitle()%></span>
									</div>
									<div class="emp-body">
										<div>
											<b>Start:</b>
											<%=new java.text.SimpleDateFormat("hh:mm a").format(m.getStartTime())%></div>
										<div>
											<b>End:</b>
											<%=new java.text.SimpleDateFormat("hh:mm a").format(m.getEndTime())%></div>
										<%
										if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {
										%>
										<a href="<%=m.getMeetingLink()%>" target="_blank"
											class="join-meeting-btn"> <i class="fa-solid fa-video"></i>
											Join Meeting
										</a>
										<%
										}
										%>
									</div>
								</div>
								<%
								}
								} else {
								%>
								<p class="no-data">No meetings scheduled for today.</p>
								<%
								}
								%>
							</div>
						</div>

					</div>
				</fieldset>
			</div>

			<!-- ===== Attendance (Self + Team) ===== -->
			<div class="box" id="attendance" style="display: none;">
				<h2>Attendance</h2>
				<p class="attendance-subtitle"
					style="color: #64748b; font-size: 14px; margin: 0 0 20px 0;">Track
					your work sessions and breaks.</p>

				<!-- My Attendance + Break Time side-by-side -->
				<div class="attendance-cards-row">
					<!-- Status card -->
					<div class="status-card">
						<div class="attendance-section-title">Status</div>
						<div class="punch-row">
							<span class="punch-label">Punch In</span> <span
								class="punch-value"><%=punchIn != null ? new SimpleDateFormat("HH:mm:ss").format(punchIn) : "--"%></span>
						</div>
						<div class="punch-row">
							<span class="punch-label">Punch Out</span> <span
								class="punch-value"><%=punchOut != null ? new SimpleDateFormat("HH:mm:ss").format(punchOut) : "--"%></span>
						</div>
						<%
						if (isWeekend) {
						%>
						<p style="color: #64748b; font-size: 13px; margin: 12px 0 0 0;">Attendance
							is closed on weekends.</p>
						<%
						} else {
						%>
						<div class="punch-actions-nexus">
							<form action="<%=request.getContextPath()%>/attendance"
								method="post" style="display: inline;">
								<input type="hidden" name="action" value="punchin"> <input
									type="hidden" name="tab" value="attendance">
								<button type="submit" class="punch-in-btn-nexus"
									<%=punchIn != null ? "disabled" : ""%>>Punch In</button>
							</form>
							<form action="<%=request.getContextPath()%>/attendance"
								method="post" style="display: inline;">
								<input type="hidden" name="action" value="punchout"> <input
									type="hidden" name="tab" value="attendance">
								<button type="submit" class="punch-out-btn-nexus"
									<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>Punch
									Out</button>
							</form>
						</div>
						<%
						}
						%>
					</div>

					<!-- Break card -->	
					<div class="break-card">
						<div class="attendance-section-title">TOTAL BREAK TODAY</div>
						<div class="break-total-row">
							<span class="tr-label">Total Break Today</span> <span
								class="tr-val"> <%
 int mgrBreakSecs = 0;
 if (request.getAttribute("breakTotalSeconds") != null) {
 	mgrBreakSecs = (Integer) request.getAttribute("breakTotalSeconds");
 }
 int mbh = mgrBreakSecs / 3600;
 int mbm = (mgrBreakSecs % 3600) / 60;
 int mbs = mgrBreakSecs % 60;
 %> <%=String.format("%02d:%02d:%02d", mbh, mbm, mbs)%>
							</span>
						</div>
						<div class="break-actions">
							<form action="<%=request.getContextPath()%>/break" method="post"
								style="display: inline;">
								<input type="hidden" name="action" value="start"> <input
									type="hidden" name="redirect" value="manager"> <input
									type="hidden" name="tab" value="attendance">
								<button type="submit" class="start-break-btn break-action-btn"
									<%=(punchIn == null || punchOut != null || onBreak) ? "disabled" : ""%>>Start
									Break</button>
							</form>
							<form action="<%=request.getContextPath()%>/break" method="post"
								style="display: inline; margin-left: 8px;">
								<input type="hidden" name="action" value="end"> <input
									type="hidden" name="redirect" value="manager"> <input
									type="hidden" name="tab" value="attendance">
								<button type="submit"
									class="end-break-btn-nexus break-action-btn"
									<%=!onBreak ? "disabled" : ""%>>End Break</button>
							</form>
						</div>
						<div class="break-log" style="margin-top: 10px;">
							<%
							java.util.List<com.smartoffice.model.BreakLog> mgrBreaks = (java.util.List<com.smartoffice.model.BreakLog>) request
									.getAttribute("breakLogs");
							SimpleDateFormat mgrTimeFmt = new SimpleDateFormat("HH:mm:ss");
							if (mgrBreaks != null && !mgrBreaks.isEmpty()) {
								for (com.smartoffice.model.BreakLog b : mgrBreaks) {
									String mStart = b.getStartTime() != null ? mgrTimeFmt.format(b.getStartTime()) : "--";
									String mEnd = b.getEndTime() != null ? mgrTimeFmt.format(b.getEndTime()) : "--";
							%>
							<div class="time-card">
								From <b><%=mStart%></b> to <b><%=mEnd%></b>
							</div>
							<%
							}
							} else {
							%>
							<p class="no-task-text">No breaks recorded today.</p>
							<%
							}
							%>
						</div>
					</div>
				</div>

				<!-- Team Attendance -->
				<fieldset class="attendance-fieldset" style="margin-top: 18px;">
					<legend>Team Attendance (Today)</legend>

					<div class="team-attendance-toolbar">
						<div class="export-actions">
							<form action="<%=request.getContextPath()%>/exportTeamAttendance"
								method="get" style="display: inline;">
								<button type="submit" class="export-btn">
									<i class="fa-solid fa-file-export"></i> Export Attendance
								</button>
							</form>
							<form
								action="<%=request.getContextPath()%>/exportTeamPerformance"
								method="get" style="display: inline; margin-left: 8px;">
								<button type="submit" class="export-btn">
									<i class="fa-solid fa-file-export"></i> Export Performance
								</button>
							</form>
						</div>
						<div class="team-attendance-view-toggle">
							<button type="button" id="teamViewGrid" class="active"
								onclick="setTeamAttendanceView('grid')" title="Grid view">
								<i class="fa-solid fa-th-large" style="margin-right: 6px;"></i>Grid
							</button>
							<button type="button" id="teamViewList"
								onclick="setTeamAttendanceView('list')" title="List view">
								<i class="fa-solid fa-list" style="margin-right: 6px;"></i>List
							</button>
						</div>
					</div>

					<div class="employee-grid-wrap" id="teamAttendanceWrap">
						<%
						List<TeamAttendance> teamAttendance = (List<TeamAttendance>) request.getAttribute("teamAttendance");
						if (teamAttendance != null && !teamAttendance.isEmpty()) {
						%>
						<!-- 3-column grid -->
						<div class="employee-grid-3" id="teamGrid">
							<%
							for (TeamAttendance ta : teamAttendance) {
								String st = ta.getStatus() != null ? ta.getStatus().toLowerCase() : "";
								String listStatusClass = st.contains("present") || st.contains("punched")
								? "present"
								: (st.contains("absent") ? "absent" : "punched-in");
							%>
							<div class="employee-card">
								<div class="emp-header">
									<div class="emp-left">
										<i class="fa-solid fa-user"></i> <span class="emp-name"><%=ta.getFullName()%></span>
									</div>
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
							%>
						</div>
						<!-- List view (table) -->
						<div class="employee-list-view" id="teamList">
							<table class="team-attendance-table">
								<thead>
									<tr>
										<th>Employee</th>
										<th>Status</th>
										<th>Punch In</th>
										<th>Punch Out</th>
									</tr>
								</thead>
								<tbody>
									<%
									for (TeamAttendance ta : teamAttendance) {
										String st = ta.getStatus() != null ? ta.getStatus().toLowerCase() : "";
										String listStatusClass = st.contains("present") || st.contains("punched")
										? "present"
										: (st.contains("absent") ? "absent" : "punched-in");
									%>
									<tr>
										<td><i class="fa-solid fa-user"
											style="margin-right: 8px; color: #64748b;"></i><strong><%=ta.getFullName()%></strong></td>
										<td><span class="list-status <%=listStatusClass%>"><%=ta.getStatus()%></span></td>
										<td><%=ta.getPunchIn() != null ? ta.getPunchIn() : "--"%></td>
										<td><%=ta.getPunchOut() != null ? ta.getPunchOut() : "--"%></td>
									</tr>
									<%
									}
									%>
								</tbody>
							</table>
						</div>
						<%
						} else {
						%>
						<p class="no-data">No attendance data available for today.</p>
						<%
						}
						%>
					</div>
				</fieldset>
			</div>

			<!-- ===== Leave (Apply Leave + My Leave Requests, improved layout) ===== -->
			<div class="box centered-box" id="leave" style="display: none;">

				<fieldset class="leave-fieldset">
					<legend>Leave</legend>

					<div class="leave-tab-row">
						<button id="managerApplyTab" type="button"
							class="leave-tab-btn leave-tab-active"
							onclick="showManagerApplyLeave()">Apply Leave</button>
						<button id="managerMyLeavesTab" type="button"
							class="leave-tab-btn" onclick="showManagerMyLeaves()">My
							Leave Requests</button>
					</div>

					<!-- Apply Leave: two-column layout -->
					<div id="managerApplyLeaveSection">
						<div class="leave-apply-grid">
							<!-- Left: form -->
							<div class="leave-apply-left">
								<h4
									style="font-size: 14px; font-weight: 700; color: #1e293b; margin-bottom: 16px; padding-bottom: 10px; border-bottom: 1px solid #e2e8f0;">
									<i class="fa-solid fa-paper-plane"
										style="margin-right: 6px; color: #4f46e5;"></i>Submit Request
								</h4>
								<form class="leave-form" action="applyLeave" method="post">
									<label>Leave Type</label> <select name="leaveType" required>
										<option value="">Select</option>
										<option>Casual Leave</option>
										<option>Sick Leave</option>
										<option>Earned Leave</option>
									</select>

									<div
										style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
										<div>
											<label>From Date</label> <input type="date" name="fromDate"
												required>
										</div>
										<div>
											<label>To Date</label> <input type="date" name="toDate"
												required>
										</div>
									</div>

									<label>Reason</label>
									<textarea name="reason" required
										placeholder="Briefly describe the reason..."></textarea>

									<button type="submit" class="primary-btn"
										style="width: 100%; margin-top: 16px;">
										<i class="fa-solid fa-paper-plane" style="margin-right: 6px;"></i>Submit
										Request
									</button>
								</form>
							</div>

							<!-- Right: leave policy / info -->
							<div class="leave-apply-right">
								<h4>
									<i class="fa-solid fa-circle-info"
										style="margin-right: 6px; color: #4f46e5;"></i>Leave Policy
								</h4>
								<div
									style="display: flex; flex-direction: column; gap: 12px; font-size: 13px; color: #475569;">
									<div
										style="padding: 12px 14px; background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; border-left: 4px solid #4f46e5;">
										<b style="color: #1e293b;">Casual Leave</b><br> For
										personal errands or short-notice absences. Typically limited
										to a set number of days per year.
									</div>
									<div
										style="padding: 12px 14px; background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; border-left: 4px solid #10b981;">
										<b style="color: #1e293b;">Sick Leave</b><br> Applicable
										when you are unwell and unable to attend work. A medical
										certificate may be required.
									</div>
									<div
										style="padding: 12px 14px; background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; border-left: 4px solid #f59e0b;">
										<b style="color: #1e293b;">Earned Leave</b><br> Accrued
										over time based on service. Plan in advance and get approval
										from HR.
									</div>
									<div
										style="padding: 12px 14px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px; font-size: 12px;">
										<i class="fa-solid fa-triangle-exclamation"
											style="color: #dc2626; margin-right: 4px;"></i> All leave
										requests are subject to admin approval. Submit at least 2
										working days in advance when possible.
									</div>
								</div>
							</div>
						</div>
					</div>

					<!-- My Leave Requests -->
					<div id="managerMyLeaveSection" style="display: none;">
						<div class="leave-scroll">
							<%
							List<LeaveRequest> myLeaves = (List<LeaveRequest>) request.getAttribute("myLeaves");
							if (myLeaves == null || myLeaves.isEmpty()) {
							%>
							<p class="no-data">No leave requests found.</p>
							<%
							} else {
							for (LeaveRequest lr : myLeaves) {
							%>
							<div class="employee-card">
								<div class="emp-header">
									<div class="emp-left">
										<i class="fa-solid fa-plane-departure"></i> <span
											class="emp-name"><%=lr.getLeaveType()%></span>
									</div>
									<span
										class="emp-status <%="APPROVED".equalsIgnoreCase(lr.getStatus())
		? "done"
		: "REJECTED".equalsIgnoreCase(lr.getStatus()) ? "out" : "pending"%>"><%=lr.getStatus()%></span>
								</div>
								<div class="emp-body">
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
							</div>
							<%
							}
							}
							%>
						</div>
					</div>
				</fieldset>
			</div>

			<!-- Calendar -->
			<div class="box centered-box" id="calendarSection"
				style="display: none;">
				<iframe id="calendarFrame" src=""
					style="width: 100%; height: 600px; border: none;"></iframe>
			</div>

			<!-- ===== Settings ===== -->
			<div class="box" id="settings" style="display: none;">
				<h3>Settings</h3>
				<p>
					<b>Name:</b> ${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}
				</p>
				<p>
					<b>Role:</b> Manager
				</p>
				<button class="secondary-btn" onclick="toggleTheme()">Toggle
					Theme</button>
			</div>

			<!-- ===== My Teams ONLY (My Team Members section removed) ===== -->
			<div class="box" id="teamSection" style="display: none;">

				<!-- My Teams -->
				<fieldset class="team-fieldset">
					<legend>
						<i class="fa-solid fa-people-group"></i> My Teams
					</legend>
					<div class="team-scroll">
						<div class="employee-grid">
							<%
							List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
							if (myTeams != null && !myTeams.isEmpty()) {
								for (Team t : myTeams) {
							%>
							<div class="employee-card" style="min-width: 280px;">
								<div class="emp-header">
									<div class="emp-left">
										<i class="fa-solid fa-people-group"></i> <span
											class="emp-name"><%=t.getName()%></span>
									</div>
								</div>
								<div class="emp-body">
									<div>
										<b>Manager:</b>
										<%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%></div>
									<div>
										<b>Members:</b>
										<%=t.getMembers().size()%></div>
									<%
									if (!t.getMembers().isEmpty()) {
									%>
									<div style="margin-top: 8px;">
										<%
										for (User m : t.getMembers()) {
										%>
										<span
											style="display: inline-block; background: #e2e8f0; padding: 4px 8px; border-radius: 6px; margin: 2px; font-size: 12px;"><%=m.getFullname() != null ? m.getFullname() : m.getEmail()%></span>
										<%
										}
										%>
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
							<p class="no-data">No teams assigned to you yet. Ask admin to
								create a team and assign you as manager.</p>
							<%
							}
							%>
						</div>
					</div>
				</fieldset>

			</div>

			<!-- ===== Assign Tasks ===== -->
			<div class="box" id="assignTask"
				style="display: none; padding: 20px;">

				<div
					style="display: grid; grid-template-columns: minmax(0, 1.2fr) minmax(0, 1fr); gap: 20px;">

					<!-- Assign Task Fieldset -->
					<fieldset class="task-fieldset" style="background: #f8fafc;">
						<legend>
							<i class="fa-solid fa-paper-plane"></i> New Task
						</legend>

						<%
						String errorMessage = (String) request.getAttribute("errorMessage");
						if (errorMessage != null) {
						%>
						<div class="task-error"><%=errorMessage%></div>
						<%
						}
						%>

						<form action="<%=request.getContextPath()%>/assignTask"
							method="post" enctype="multipart/form-data"
							style="display: flex; flex-direction: column; gap: 12px;">

							<label style="font-size: 13px; font-weight: 600; color: #475569;">Assign
								to</label> <select class="form-control" name="employeeUsername" required>
								<option value="">Select Employee</option>
								<%
								List<User> team = (List<User>) request.getAttribute("teamList");
								String assignEmployee = (String) request.getAttribute("assignEmployee");
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
								<%
								}
								%>
							</select> <label
								style="font-size: 13px; font-weight: 600; color: #475569;">Task
								title</label> <input class="form-control" type="text" name="title"
								placeholder="E.g. Submit weekly report" required> <label
								style="font-size: 13px; font-weight: 600; color: #475569;">Description</label>
							<textarea class="form-control" name="taskDesc" rows="4"
								placeholder="Add clear instructions and details" required></textarea>

							<div style="display: flex; gap: 12px; flex-wrap: wrap;">
								<div style="flex: 1; min-width: 160px;">
									<label
										style="font-size: 13px; font-weight: 600; color: #475569;">Deadline</label>
									<input class="form-control" type="date" name="deadline">
								</div>
								<div style="flex: 1; min-width: 160px;">
									<label
										style="font-size: 13px; font-weight: 600; color: #475569;">Priority</label>
									<select class="form-control" name="priority">
										<option value="HIGH">High</option>
										<option value="MEDIUM" selected>Medium</option>
										<option value="LOW">Low</option>
									</select>
								</div>
							</div>

							<div>
								<label
									style="font-size: 13px; font-weight: 600; color: #475569;">Attachment
									(optional)</label> <input class="form-control" type="file"
									name="attachment"
									accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg">
								<small style="font-size: 11px; color: #6b7280;"> Attach
									any reference document or file your employee needs. </small>
							</div>

							<div style="margin-top: 4px;">
								<button class="primary-btn" type="submit"
									style="min-width: 150px; border-radius: 999px;">Assign
									Task</button>
							</div>
						</form>
					</fieldset>

					<!-- View Tasks Fieldset -->
					<fieldset class="task-fieldset" style="background: #eef2ff;">
						<legend>
							<i class="fa-solid fa-list-check"></i> View Assigned Tasks
						</legend>

						<form action="<%=request.getContextPath()%>/viewAssignedTasks"
							method="post"
							style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 12px;">

							<label style="font-size: 13px; font-weight: 600; color: #475569;">Employee</label>
							<select class="form-control" name="employeeUsername" required>
								<option value="">Select Employee</option>
								<%
								String viewEmployee = (String) request.getAttribute("viewEmployee");
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
								<%
								}
								%>
							</select>

							<button class="secondary-btn" type="submit"
								style="align-self: flex-start; border-radius: 999px;">View
								Tasks</button>
						</form>

						<%
						viewTasks = (List<Task>) request.getAttribute("viewTasks");
						if (viewTasks != null) {
						%>
						<h4 class="tasks-title" style="margin-top: 10px;">
							Tasks for <span style="color: #4f46e5;"><%=viewEmployee%></span>
						</h4>

						<div class="task-list">
							<%
							if (viewTasks.isEmpty()) {
							%>
							<p class="no-data">No tasks found for this employee.</p>
							<%
							} else {
							for (Task t : viewTasks) {
							%>
							<div
								class="task-card <%=t.getStatus().equals("COMPLETED") ? "completed" : ""%>">
								<div class="task-desc">
									<strong><%=t.getTitle() != null ? t.getTitle() : "Task"%></strong><br>
									<%=t.getDescription()%><br> <small
										style="font-size: 11px; color: #6b7280;"> <%
 java.sql.Date dl = t.getDeadline();
 String pr = t.getPriority();
 %> Deadline: <%=dl != null ? dl.toString() : "--"%> &nbsp; | Priority:
										<%=pr != null ? pr : "MEDIUM"%>
									</small>
									<%
									String attName = t.getAttachmentName();
									if (attName != null && !attName.isEmpty()) {
									%>
									<br> <a
										href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>"
										target="_blank"
										style="font-size: 12px; color: #2563eb; text-decoration: underline;">
										Download: <%=attName%>
									</a>
									<%
									}
									%>
								</div>
								<span
									class="task-status <%=t.getStatus().equals("COMPLETED") ? "completed" : "assigned"%>">
									<%=t.getStatus()%>
								</span>
								<%
								String empFile = t.getEmployeeAttachmentName();
								if (empFile != null && !empFile.isEmpty()) {
								%>
								<br> <a
									href="<%=request.getContextPath()%>/employeeTaskAttachment?id=<%=t.getId()%>"
									target="_blank"
									style="font-size: 12px; color: #16a34a; text-decoration: underline;">
									Employee Submission: <%=empFile%>
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
						<%
						}
						%>
					</fieldset>
				</div>
			</div>

		</div>
	</div>

	<!-- ===== ALL MEETINGS MODAL ===== -->
	<div id="allMeetingsModal" class="modal">
		<div class="modal-content">
			<div class="modal-header">
				<h3>All Scheduled Meetings</h3>
				<span class="modal-close" onclick="closeAllMeetings()">✕</span>
			</div>
			<div class="modal-body" id="allMeetingsContent">
				<!-- meetings will load here -->
			</div>
		</div>
	</div>

	<!-- ===== NOTIFICATION PANEL ===== -->
	<div id="notificationPanel" class="notification-panel">
		<div class="notification-header">
			<span>🔔 Smart Office Notifications</span>
			<button onclick="closeNotifications()">✕</button>
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
						style="background: linear-gradient(135deg, #6366f1, #818cf8); color: white; border: none; padding: 4px 10px; border-radius: 6px; cursor: pointer; font-size: 12px;"
						data-id="<%=n.getId()%>"
						onclick="markAsRead(parseInt(this.dataset.id, 10));">Mark
						as read</button>
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

	<script>
/* ================= INITIAL THEME ================= */
if (localStorage.getItem("theme") === "dark") {
    document.body.classList.add("dark-theme");
}

/* ================= TEAM ATTENDANCE VIEW TOGGLE ================= */
function setTeamAttendanceView(mode) {
    var wrap = document.getElementById("teamAttendanceWrap");
    var btnGrid = document.getElementById("teamViewGrid");
    var btnList = document.getElementById("teamViewList");
    if (!wrap || !btnGrid || !btnList) return;
    if (mode === "list") {
        wrap.classList.add("list-mode");
        btnList.classList.add("active");
        btnGrid.classList.remove("active");
    } else {
        wrap.classList.remove("list-mode");
        btnGrid.classList.add("active");
        btnList.classList.remove("active");
    }
}

/* ===============================================================
   PERFORMANCE MATRIX — 3-Step: Team → Member → Rate
   =============================================================== */

var perfTeamMembers = {};
<%List<Team> perfTeamsJS = (List<Team>) request.getAttribute("myTeams");
if (perfTeamsJS != null && !perfTeamsJS.isEmpty()) {
	out.println("perfTeamMembers = {");
	boolean firstTeam = true;
	for (Team t : perfTeamsJS) {
		if (!firstTeam)
			out.println(",");
		firstTeam = false;
		String tNameJs = t.getName().replace("\"", "\\\"").replace("'", "\\'");
		out.print("  \"" + tNameJs + "\": [");
		boolean firstMember = true;
		if (t.getMembers() != null) {
			for (User m : t.getMembers()) {
				if (!firstMember)
					out.print(",");
				firstMember = false;
				String mName = (m.getFullname() != null ? m.getFullname() : m.getEmail()).replace("\"", "\\\"");
				String mEmail = m.getEmail().replace("\"", "\\\"");
				out.print("{\"name\":\"" + mName + "\",\"email\":\"" + mEmail + "\"}");
			}
		}
		out.print("]");
	}
	out.println("};");
}%>

function setPerfStep(n) {
    for (var i = 1; i <= 3; i++) {
        var stepEl = document.getElementById("perfStep" + i);
        stepEl.classList.remove("active", "done");
        if (i < n)  stepEl.classList.add("done");
        if (i === n) stepEl.classList.add("active");
    }
    var line1 = document.getElementById("perfLine1");
    var line2 = document.getElementById("perfLine2");
    if (line1) line1.classList.toggle("done", n > 1);
    if (line2) line2.classList.toggle("done", n > 2);
}

function perfInitials(name) {
    var parts = name.trim().split(/\s+/);
    var ini = parts[0].charAt(0).toUpperCase();
    if (parts.length > 1) ini += parts[parts.length - 1].charAt(0).toUpperCase();
    return ini;
}

function selectPerfTeam(card) {
    document.querySelectorAll('#perfTeamList .perf-member-card').forEach(function(c) {
        c.classList.remove('selected');
        var ico = c.querySelector('.perf-member-check i');
        if (ico) ico.style.display = 'none';
    });

    card.classList.add('selected');
    var ico = card.querySelector('.perf-member-check i');
    if (ico) ico.style.display = 'inline';

    var teamName = card.getAttribute('data-teamname');
    document.getElementById('perfTeamInput').value = teamName;

    var members = perfTeamMembers[teamName] || [];
    var list = document.getElementById('perfMemberList');

    if (members.length === 0) {
        list.innerHTML = '<p class="no-data" style="padding:10px 0; font-size:13px;">No members in this team.</p>';
    } else {
        list.innerHTML = members.map(function(m) {
            var ini = perfInitials(m.name);
            return '<div class="perf-member-card"' +
                   ' data-email="' + m.email + '"' +
                   ' data-name="'  + m.name.replace(/"/g, '&quot;') + '"' +
                   ' onclick="selectPerfMember(this)">' +
                   '<div class="perf-member-avatar">' + ini + '</div>' +
                   '<div class="perf-member-info">' +
                     '<div class="perf-member-name">' + m.name + '</div>' +
                     '<div class="perf-member-email">' + m.email + '</div>' +
                   '</div>' +
                   '<div class="perf-member-check">' +
                     '<i class="fa-solid fa-check" style="font-size:10px; display:none;"></i>' +
                   '</div>' +
                   '</div>';
        }).join('');
    }

    document.getElementById('perfTeamBanner').innerHTML =
        '<i class="fa-solid fa-layer-group" style="color:#ec4899; font-size:13px;"></i>' +
        '<span class="sel-tag">' + teamName + '</span>';

    document.getElementById('panelMember').classList.remove('locked');
    document.getElementById('panelRating').classList.add('locked');
    document.getElementById('perfSelectedDisplay').innerHTML =
        '<span class="placeholder-text">\u2190 Select a team member to rate</span>';
    document.getElementById('perfEmployeeInput').value = '';
    document.getElementById('perfSubmitBtn').disabled = true;
    document.getElementById('perfSubmitBtn').style.opacity = '0.6';
    document.querySelectorAll('input[name="rating"]').forEach(function(r) { r.checked = false; });

    setPerfStep(2);
}

function selectPerfMember(card) {
    document.querySelectorAll('#perfMemberList .perf-member-card').forEach(function(c) {
        c.classList.remove('selected');
        var ico = c.querySelector('.perf-member-check i');
        if (ico) ico.style.display = 'none';
    });

    card.classList.add('selected');
    var ico = card.querySelector('.perf-member-check i');
    if (ico) ico.style.display = 'inline';

    var empEmail = card.getAttribute('data-email');
    var empName  = card.getAttribute('data-name');
    document.getElementById('perfEmployeeInput').value = empEmail;

    var ini = perfInitials(empName);
    document.getElementById('perfSelectedDisplay').innerHTML =
        '<div class="perf-member-avatar" style="width:40px;height:40px;border-radius:50%;' +
        'background:linear-gradient(135deg,#6366f1,#818cf8);color:#fff;font-size:15px;' +
        'font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;">' +
        ini + '</div>' +
        '<div>' +
          '<div class="selected-name">' + empName + '</div>' +
          '<div class="selected-email">' + empEmail + '</div>' +
        '</div>';

    document.getElementById('panelRating').classList.remove('locked');
    checkPerfSubmit();
    setPerfStep(3);
}

function checkPerfSubmit() {
    var emp   = document.getElementById('perfEmployeeInput').value;
    var rated = document.querySelector('input[name="rating"]:checked');
    var btn   = document.getElementById('perfSubmitBtn');
    btn.disabled      = !(emp && rated);
    btn.style.opacity = (emp && rated) ? '1' : '0.6';
}

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll('input[name="rating"]').forEach(function(r) {
        r.addEventListener('change', checkPerfSubmit);
    });
});

/* ================= MAIN DOMContentLoaded ================= */
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const tab = params.get("tab");
    const success = params.get("success");
    const error = params.get("error");

    var serverTab = "<%=activeTab%>";
    var initialTab = serverTab || tab || "attendance";
    if (initialTab === "calendar") {
        openCalendar();
        syncSidebarActive("calendarSection");
    } else {
        showSection(initialTab);
        syncSidebarActive(initialTab);
    }

    /* -------- SUCCESS MESSAGES -------- */
    if (success === "Login")
        showToast("Welcome! Logged in successfully");
    else if (success === "MeetingScheduled")
        showToast("Meeting scheduled successfully");
    else if (success === "PunchIn")
        showToast("Punched in successfully");
    else if (success === "PunchOut")
        showToast("Punched out successfully");
    else if (success === "PerformanceSaved")
        showToast("Performance submitted successfully");
    else if (success === "LeaveApplied")
        showToast("Leave applied successfully");
    else if (success === "true")
        showToast("Task assigned successfully");

    /* -------- ERROR MESSAGES -------- */
    if (error === "SelectEmployee")
        showToast("Please select an employee", "error");
    else if (error === "InvalidEmployee")
        showToast("You cannot assign task to this employee", "error");
    else if (error === "EmptyTask")
        showToast("Task description cannot be empty", "error");
    else if (error === "InvalidDeadline")
        showToast("Invalid deadline date", "error");
    else if (error === "EmptyTitle")
        showToast("Task title cannot be empty", "error");
    else if (error === "AlreadyRated")
        showToast("Performance already submitted for this employee this month", "error");
    else if (error === "accessDenied")
        showToast("Access denied. You do not have permission for that page.", "error");

    /* -------- Clean flash params; keep ?tab= -------- */
    if (success || error) {
        setTimeout(() => {
            const qs = new URLSearchParams(window.location.search);
            qs.delete("success");
            qs.delete("error");
            const q = qs.toString();
            window.history.replaceState({}, document.title, window.location.pathname + (q ? "?" + q : ""));
        }, 100);
    }

    /* -------- Meeting Form AJAX -------- */
    const meetingForm = document.getElementById("meetingForm");
    if (meetingForm) {
        meetingForm.addEventListener("submit", function (e) {
            e.preventDefault();
            const formData = new FormData(meetingForm);
            fetch("schedulemeeting", {
                method: "POST",
                body: formData
            })
            .then(res => res.text())
            .then(text => {
                switch (text.trim()) {
                    case "SUCCESS":
                        showToast("Meeting scheduled successfully");
                        meetingForm.reset();
                        break;
                    case "INVALID":
                        showToast("Please fill all required fields", "error");
                        break;
                    case "INVALID_TIME":
                        showToast("End time must be after start time", "error");
                        break;
                    default:
                        showToast("Something went wrong", "error");
                }
            })
            .catch(() => {
                showToast("Server error", "error");
            });
        });
    }
});

/* Sync sidebar button highlight with the currently visible section */
function syncSidebarActive(sectionId) {
    document.querySelectorAll('.sidebar .sidebar-btn').forEach(function(btn) {
        btn.classList.remove('active');
    });
    if (sectionId === 'settings') {
        var sbtn = document.querySelector('.sidebar-bottom .sidebar-btn');
        if (sbtn) sbtn.classList.add('active');
        return;
    }
    var map = {
        'attendance':     0,
        'teamSection':    1,
        'assignTask':     2,
        'schedulemeeting':3,
        'leave':          4,
        'performance':    5,
        'calendar':       6,
        'calendarSection':6
    };
    var idx = map[sectionId];
    if (idx !== undefined) {
        var btns = document.querySelectorAll('.sidebar-nav .sidebar-btn');
        if (btns[idx]) btns[idx].classList.add('active');
    }
}

/* ================= TOAST FUNCTION ================= */
function showToast(message, type = "success") {
    const toast = document.getElementById("toast");
    toast.style.display = "none";
    toast.className = "toast";
    toast.offsetHeight;
    toast.classList.add(type);
    toast.textContent = message;
    toast.style.display = "block";
    setTimeout(() => {
        toast.classList.add("hide");
        setTimeout(() => {
            toast.style.display = "none";
            toast.className = "toast";
        }, 400);
    }, 2500);
}

/* ================= UI FUNCTIONS ================= */

function sectionIdToTab(sec) {
    if (sec === 'calendarSection') return 'calendar';
    return sec;
}

function pushManagerTab(tab) {
    try {
        var qs = new URLSearchParams(window.location.search);
        qs.set('tab', tab);
        var q = qs.toString();
        window.history.replaceState({}, document.title, window.location.pathname + (q ? '?' + q : ''));
    } catch (e) { /* ignore */ }
}

function showSection(id) {
    document.querySelectorAll(".content-area > .box").forEach(b => {
        if (b.id !== "profileModal") b.style.display = "none";
    });
    var el = document.getElementById(id);
    if (el) {
        el.style.display = "block";
        pushManagerTab(sectionIdToTab(id));
    }
}

function setManagerLeaveTabs(active) {
    const applyTab = document.getElementById("managerApplyTab");
    const myTab = document.getElementById("managerMyLeavesTab");
    if (!applyTab || !myTab) return;
    applyTab.classList.remove("leave-tab-active");
    myTab.classList.remove("leave-tab-active");
    if (active === "apply") applyTab.classList.add("leave-tab-active");
    else myTab.classList.add("leave-tab-active");
}

function showManagerApplyLeave() {
    document.getElementById("managerApplyLeaveSection").style.display = "block";
    document.getElementById("managerMyLeaveSection").style.display = "none";
    setManagerLeaveTabs("apply");
}

function showManagerMyLeaves() {
    document.getElementById("managerApplyLeaveSection").style.display = "none";
    document.getElementById("managerMyLeaveSection").style.display = "block";
    setManagerLeaveTabs("my");
}

function toggleTheme() {
    document.body.classList.toggle("dark-theme");
    localStorage.setItem("theme",
        document.body.classList.contains("dark-theme") ? "dark" : "light"
    );
}

function openAllMeetings() {
    document.getElementById("allMeetingsModal").classList.add("show");
    fetch("<%=request.getContextPath()%>/allMeetings")
        .then(res => res.text())
        .then(html => {
            document.getElementById("allMeetingsContent").innerHTML = html;
        })
        .catch(() => {
            document.getElementById("allMeetingsContent").innerHTML =
                "<p>Error loading meetings</p>";
        });
}

function closeAllMeetings() {
    document.getElementById("allMeetingsModal").classList.remove("show");
}

function openSettings() { document.getElementById("settingsPanel").classList.add("open"); }
function closeSettings() { document.getElementById("settingsPanel").classList.remove("open"); }

function openProfile() {
    document.getElementById("profileModal").style.visibility = "visible";
    document.getElementById("profileModal").style.opacity = "1";
}

function closeProfile() {
    document.getElementById("profileModal").style.visibility = "hidden";
    document.getElementById("profileModal").style.opacity = "0";
}

function openChangePassword() {
    document.getElementById("passwordModal").classList.add("show");
}

function closeChangePassword() {
    document.getElementById("passwordModal").classList.remove("show");
}

function closeAll() {
    closeSettings();
    closeProfile();
    closeChangePassword();
    closeAllMeetings();
}

function submitPassword() {
    const newPassword = document.getElementById("newPassword").value.trim();
    const confirmPassword = document.getElementById("confirmPassword").value.trim();

    if (!newPassword || !confirmPassword) {
        showToast("Please fill all fields", "error");
        return;
    }

    fetch("<%=request.getContextPath()%>/changePassword", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
            newPassword: newPassword,
            confirmPassword: confirmPassword
        })
    })
    .then(res => res.text())
    .then(response => {
        switch (response.trim()) {
            case "Success":
                showToast("Password updated successfully");
                closeChangePassword();
                document.getElementById("newPassword").value = "";
                document.getElementById("confirmPassword").value = "";
                break;
            case "PasswordMismatch":
                showToast("Passwords do not match", "error");
                break;
            case "MissingFields":
                showToast("All fields are required", "error");
                break;
            case "Unauthorized":
                showToast("Session expired. Please login again", "error");
                break;
            default:
                showToast("Something went wrong", "error");
        }
    })
    .catch(() => {
        showToast("Server error", "error");
    });
}

function openCalendar() {
    document.querySelectorAll(".content-area > .box").forEach(b => {
        if (b.id !== "profileModal") b.style.display = "none";
    });
    document.getElementById("calendarSection").style.display = "block";
    document.getElementById("calendarFrame").src =
        "<%=request.getContextPath()%>/calendar.jsp";
    pushManagerTab("calendar");
}

function openNotifications() {
    document.getElementById("notificationPanel").classList.add("show");
}

function closeNotifications() {
    document.getElementById("notificationPanel").classList.remove("show");
}

function markAsRead(notificationId) {
    fetch("markNotificationRead?id=" + notificationId, { method: "POST" })
        .then(response => {
            if (response.ok) {
                const el = document.getElementById("notif-" + notificationId);
                if (el) el.remove();
                const list = document.getElementById("notificationList");
                const remaining = list.querySelectorAll(".notification-item");
                if (remaining.length === 0) {
                    list.innerHTML = `<div class="notification-item">No notifications</div>`;
                }
            }
        })
        .catch(err => console.error(err));
}

function setActive(button) {
    document.querySelectorAll('.sidebar-btn')
        .forEach(btn => btn.classList.remove('active'));
    button.classList.add('active');
}

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;
  
  
  
  function openProfileTab() {
	    document.getElementById('profile-content').style.display = 'block';
	    document.getElementById('profile-tab-btn').classList.add('active');
	    document.getElementById('password-tab-btn').classList.remove('active');
	}

	function openChangePasswordTab() {
	    // Keep your existing modal - no change in functionality
	    openChangePassword();
	    // Highlight tab
	    document.getElementById('profile-tab-btn').classList.remove('active');
	    document.getElementById('password-tab-btn').classList.add('active');
	}
</script>
	<!-- Toast -->
	<div id="toast" class="toast"></div>
</body>
</html>
