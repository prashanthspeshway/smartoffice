<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.AttendanceLogEntry"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Calendar"%>
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
List<LeaveRequest> myLeaves = (List<LeaveRequest>) request.getAttribute("myLeaves");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Employee Dashboard</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
	rel="stylesheet">
<style>
body {
	margin: 0;
	height: 100vh;
	overflow: hidden;
	font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
	background: #f1f5f9;
}

/* ================= TOP BAR ================= */
.top-bar {
	background: #ffffff;
	border-bottom: 1px solid #e2e8f0;
	padding: 15px 24px;
	display: flex;
	height: 56px;
	justify-content: space-between;
	align-items: center;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.top-bar h2 {
	font-size: 20px;
	font-weight: 600;
	color: #1e293b;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 12px;
	color: #64748b;
	font-weight: 500;
	font-size: 14px;
}

.user-area b {
	color: #1e293b;
}

.icon-btn {
	width: 40px;
	height: 40px;
	border-radius: 50%;
	border: none;
	background: #4f46e5;
	color: white;
	cursor: pointer;
	transition: all 0.2s;
	display: inline-flex;
	align-items: center;
	justify-content: center;
}

.icon-btn:hover {
	background: #4338ca;
}

.icon-btn i {
	font-size: 16px;
}

/* ===== Layout ===== */
.container {
	display: flex;
	height: calc(100vh - 80px);
}

/* ================= SIDEBAR ================= */
.left-panel {
	width: 256px;
	background: #ffffff;
	border-right: 1px solid #e2e8f0;
	padding: 16px 12px;
	box-shadow: 1px 0 0 rgba(0, 0, 0, 0.05);
	display: flex;
	flex-direction: column;
}

.nav-links {
	display: flex;
	flex-direction: column;
	flex: 1;
}

.nav-btn {
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
	transition: 0.2s;
}

.nav-btn:hover {
	background: #f1f5f9;
	color: #1e293b;
}

.nav-btn.active {
	background: #eef2ff;
	color: #4f46e5;
	font-weight: 600;
}

/* ================= SIDEBAR BOTTOM ================= */
.sidebar-bottom {
	padding-top: 10px;
	border-top: 1px solid #e2e8f0;
	margin-top: 8px;
}

/* ===== Settings toggle button ===== */
.settings-toggle-btn {
	width: 100%;
	padding: 12px 16px;
	margin-bottom: 2px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 12px;
	color: #475569;
	transition: background 0.2s, color 0.2s;
	text-align: left;
}

.settings-toggle-btn i.main-icon {
	width: 18px;
	text-align: center;
	font-size: 15px;
	flex-shrink: 0;
}

.settings-toggle-btn:hover {
	background: #f1f5f9;
	color: #1e293b;
}

.settings-toggle-btn.open {
	background: #eef2ff;
	color: #4f46e5;
	font-weight: 600;
}

.settings-toggle-btn .chevron {
	margin-left: auto;
	font-size: 11px;
	transition: transform 0.25s ease;
	flex-shrink: 0;
}

.settings-toggle-btn.open .chevron {
	transform: rotate(180deg);
}

/* ===== Settings inline submenu ===== */
.settings-submenu {
	overflow: hidden;
	max-height: 0;
	opacity: 0;
	transition: max-height 0.3s ease, opacity 0.25s ease;
}

.settings-submenu.open {
	max-height: 200px;
	opacity: 1;
}

.settings-sub-btn {
	width: 100%;
	padding: 10px 16px 10px 46px;
	margin-bottom: 2px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 13px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 10px;
	color: #64748b;
	transition: background 0.2s, color 0.2s;
	text-align: left;
}

.settings-sub-btn i {
	font-size: 13px;
	color: #6366f1;
	width: 16px;
	text-align: center;
}

.settings-sub-btn:hover {
	background: #f1f5f9;
	color: #4f46e5;
}

/* ===== Logout button ===== */
.sidebar-logout-btn {
	width: 100%;
	padding: 10px 14px;
	border-radius: 8px;
	border: 1px solid #fecaca;
	cursor: pointer;
	font-size: 13px;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 10px;
	background: #fef2f2;
	color: #dc2626;
	transition: all 0.2s;
	text-align: left;
	text-decoration: none;
	margin-top: 4px;
}

.sidebar-logout-btn:hover {
	background: #fee2e2;
	color: #b91c1c;
}

.sidebar-logout-btn i {
	width: 18px;
	text-align: center;
	flex-shrink: 0;
}

/* ===== Card ===== */
.box {
	overflow-y: auto;
	overflow-x: hidden;
	padding: 24px;
	height: 100%;
	background: #ffffff;
	border-radius: 12px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

/* ================= RIGHT PANEL ================= */
.right-panel {
	flex: 1;
	background: #f1f5f9;
	overflow: hidden;
}

/* ================= ATTENDANCE FIELDSET ================= */
.attendance-fieldset {
	border-radius: 12px;
	padding: 24px;
	border: 1px solid #e2e8f0;
	background: #ffffff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.attendance-fieldset legend {
	padding: 8px 16px;
	font-size: 15px;
	font-weight: 600;
	color: #1e293b;
	border-radius: 8px;
	background: #eef2ff;
	border: none;
}

.attendance-fieldset .time-card {
	display: flex;
	justify-content: space-between;
	padding: 12px 0;
	border-bottom: 1px dashed rgba(102, 126, 234, 0.2);
	color: #4a5568;
	font-weight: 500;
}

.attendance-fieldset .punch-actions {
	display: flex;
	gap: 15px;
	margin-top: 20px;
}

.attendance-fieldset button {
	flex: 1;
	padding: 12px 20px;
	border-radius: 8px;
	background: #4f46e5;
	color: white;
	border: none;
	font-weight: 600;
	font-size: 14px;
	transition: all 0.2s;
	cursor: pointer;
}

.attendance-fieldset button:hover:not(:disabled) {
	background: #4338ca;
}

.attendance-fieldset button:disabled {
	opacity: 0.5;
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
	background: linear-gradient(135deg, rgba(102, 126, 234, 0.05),
		rgba(118, 75, 162, 0.05));
	border: 1px solid rgba(102, 126, 234, 0.15);
	transition: 0.3s;
}

.task-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
	border-color: rgba(102, 126, 234, 0.3);
}

.task-left {
	display: flex;
	align-items: center;
	gap: 12px;
}

.task-left i {
	font-size: 18px;
	color: #667eea;
}

.task-status {
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.5px;
}

.task-status.pending {
	background: linear-gradient(135deg, #fff4e5, #ffe8cc);
	color: #d97706;
	border: 1px solid rgba(217, 119, 6, 0.2);
}

.task-status.done {
	background: linear-gradient(135deg, #dcfce7, #bbf7d0);
	color: #15803d;
	border: 1px solid rgba(21, 128, 61, 0.2);
}

.task-status.out {
	background: linear-gradient(135deg, #fecaca, #fca5a5);
	color: #7f1d1d;
	border: 1px solid rgba(127, 29, 29, 0.2);
}

.task-btn {
	padding: 8px 16px;
	border: none;
	border-radius: 20px;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	font-size: 13px;
	font-weight: 700;
	cursor: pointer;
	margin-left: 10px;
	transition: 0.25s;
	box-shadow: 0 4px 12px rgba(102, 126, 234, 0.35);
}

.task-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(102, 126, 234, 0.5);
}

.no-task-text {
	margin-top: 15px;
	font-size: 14px;
	color: #6b7280;
}

.task-dropdown {
	padding: 6px 10px;
	border-radius: 16px;
	border: 1px solid #ccc;
	font-size: 13px;
	cursor: pointer;
	background: #f8f9ff;
	transition: all 0.2s ease;
}

.task-dropdown:hover {
	border-color: #667eea;
}

/* ================= MY TASK ================= */
#taskSection {
	max-height: auto;
	overflow-y: auto;
	overflow-x: hidden;
	padding: 10px;
}

#taskSection::-webkit-scrollbar { width: 4px; }
#taskSection::-webkit-scrollbar-track { background: #f0f2ff; border-radius: 10px; }
#taskSection::-webkit-scrollbar-thumb { background: #667eea; border-radius: 8px; }
#taskSection::-webkit-scrollbar-thumb:hover { background: #764ba2; }

/* ================= SUBMIT TASK UPDATE BUTTON ================= */
.submit-btn {
	padding: 9px 20px;
	border: none;
	border-radius: 20px;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	font-size: 13px;
	font-weight: 700;
	cursor: pointer;
	transition: 0.25s;
	box-shadow: 0 4px 12px rgba(102, 126, 234, 0.35);
	flex: unset !important;
}

.submit-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(102, 126, 234, 0.5);
}

.submit-btn:disabled {
	opacity: 0.6;
	cursor: not-allowed;
	transform: none !important;
}

/* ================= LEAVE SECTION — updated 2-column layout ================= */

/* Tab row — same pill style as original but now with proper active state */
.leave-tab-row {
	display: flex;
	gap: 12px;
	margin-bottom: 20px;
}

.leave-tab-btn {
	flex: 1;
	padding: 12px 20px;
	border-radius: 8px;
	border: none;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	transition: background 0.2s, color 0.2s;
	background: #94a3b8;
	color: #fff;
}

.leave-tab-btn.leave-tab-active {
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: #fff;
}

.leave-tab-btn:hover:not(.leave-tab-active) {
	background: #64748b;
}

/* Two-column apply leave grid */
.leave-apply-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	align-items: start;
}

@media (max-width: 768px) {
	.leave-apply-grid { grid-template-columns: 1fr; }
}

.leave-apply-left {
	background: #f8faff;
	border-radius: 10px;
	padding: 20px;
	border: 1px solid #e2e8f0;
}

.leave-apply-left h4 {
	font-size: 14px;
	font-weight: 700;
	color: #1e293b;
	margin: 0 0 16px 0;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
	display: flex;
	align-items: center;
	gap: 6px;
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
	margin: 0 0 14px 0;
	padding-bottom: 10px;
	border-bottom: 1px solid #e2e8f0;
	display: flex;
	align-items: center;
	gap: 6px;
}

/* Leave form inside the new left panel */
.leave-form-inner {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.leave-form-inner label {
	font-size: 13px;
	font-weight: 600;
	color: #475569;
	margin-bottom: 2px;
	display: block;
}

.leave-form-inner select,
.leave-form-inner input,
.leave-form-inner textarea {
	width: 100%;
	padding: 10px 12px;
	border-radius: 8px;
	border: 1px solid #e2e8f0;
	font-size: 14px;
	color: #1e293b;
	background: #fff;
	box-sizing: border-box;
	transition: border-color 0.2s, box-shadow 0.2s;
	outline: none;
}

.leave-form-inner select:focus,
.leave-form-inner input:focus,
.leave-form-inner textarea:focus {
	border-color: #667eea;
	box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.leave-form-inner textarea {
	min-height: 90px;
	resize: vertical;
}

.leave-date-row {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 12px;
}

.leave-submit-btn {
	width: 100%;
	padding: 12px;
	border-radius: 8px;
	border: none;
	font-weight: 700;
	font-size: 14px;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
	transition: all 0.2s;
	margin-top: 4px;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 8px;
}

.leave-submit-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
}

/* Leave policy info cards */
.leave-policy-item {
	padding: 12px 14px;
	background: #fff;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	margin-bottom: 10px;
	font-size: 13px;
	color: #475569;
}

.leave-policy-item b {
	display: block;
	color: #1e293b;
	font-size: 13px;
	margin-bottom: 4px;
}

.leave-policy-casual  { border-left: 4px solid #4f46e5; }
.leave-policy-sick    { border-left: 4px solid #10b981; }
.leave-policy-earned  { border-left: 4px solid #f59e0b; }
.leave-policy-note {
	background: #fef2f2;
	border: 1px solid #fecaca;
	border-radius: 8px;
	padding: 10px 12px;
	font-size: 12px;
	color: #475569;
	display: flex;
	align-items: flex-start;
	gap: 6px;
}

.leave-policy-note i { color: #dc2626; flex-shrink: 0; margin-top: 1px; }

/* My leave requests scroll area */
.leave-requests-scroll {
	max-height: 400px;
	overflow-y: auto;
	padding-right: 4px;
}

.leave-requests-scroll::-webkit-scrollbar { width: 4px; }
.leave-requests-scroll::-webkit-scrollbar-thumb { background: #c3cfe2; border-radius: 4px; }

/* ================= OLD LEAVE FORM (kept for compatibility, hidden) ================= */
.leave-form {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.leave-form input, .leave-form select, .leave-form textarea {
	padding: 10px 12px;
	border-radius: 10px;
	background: #f8f9ff;
	border: 2px solid #e0e4ff;
	font-size: 14px;
	transition: border-color 0.2s;
	outline: none;
}

.leave-form input:focus, .leave-form select:focus, .leave-form textarea:focus {
	border-color: #667eea;
	box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.leave-form textarea {
	height: 50px;
	resize: none;
}

#myLeaveSection h3 { color: #667eea !important; font-weight: 700; }

#myLeaveSection {
	max-height: 300px;
	overflow-y: auto;
	overflow-x: hidden;
	padding: 10px;
}

#myLeaveSection::-webkit-scrollbar { width: 4px; }
#myLeaveSection::-webkit-scrollbar-track { background: #f0f2ff; border-radius: 10px; }
#myLeaveSection::-webkit-scrollbar-thumb { background: #667eea; border-radius: 8px; }
#myLeaveSection::-webkit-scrollbar-thumb:hover { background: #764ba2; }

.apply-leave-btn {
	margin-top: 10px;
	padding: 12px;
	border-radius: 25px;
	border: none;
	font-weight: 700;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
	transition: all 0.2s;
}

.apply-leave-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
}

/* ===== Scheduled Meetings ===== */
#meetingSection .attendance-fieldset {
	background: #ffffff;
	max-height: 460px;
	overflow-y: auto;
	border: none;
	border-radius: 16px;
	padding: 28px 22px;
	box-shadow: 0 8px 32px rgba(102, 126, 234, 0.15);
}

#meetingSection legend {
	padding: 8px 18px;
	font-size: 15px;
	font-weight: 700;
	color: #fff;
	border-radius: 20px;
	background: linear-gradient(135deg, #667eea, #764ba2);
	border: none;
	box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

#meetingSection .task-card {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 18px 20px;
	margin-top: 18px;
	border-radius: 14px;
	background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
	border: 1px solid rgba(102, 126, 234, 0.15);
	overflow: auto;
	transition: all 0.3s ease;
}

#meetingSection .task-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 10px 28px rgba(102, 126, 234, 0.2);
}

#meetingSection .task-left { display: flex; gap: 14px; align-items: flex-start; }
#meetingSection .task-left i { font-size: 20px; color: #667eea; margin-top: 4px; }
#meetingSection .task-left b { font-size: 15px; color: #1f2937; }
#meetingSection .task-left small { font-size: 13px; color: #6b7280; }

#meetingSection .task-btn {
	padding: 10px 20px;
	border-radius: 20px;
	border: none;
	font-weight: 700;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
	transition: 0.25s;
	box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

#meetingSection .task-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(102, 126, 234, 0.5);
}

#meetingSection .no-task-text { margin-top: 15px; font-size: 14px; color: #6b7280; }
#meetingSection .attendance-fieldset::-webkit-scrollbar { width: 4px; }
#meetingSection .attendance-fieldset::-webkit-scrollbar-thumb { background: #667eea; border-radius: 4px; }

/* ===== Calendar ===== */
#calendarSection {
	max-height: calc(100vh - 120px);
	overflow-y: auto;
	padding-right: 10px;
	scrollbar-width: none;
	-ms-overflow-style: none;
}

#calendarSection::-webkit-scrollbar { width: 0; background: transparent; }
#calendarSection h3 { position: sticky; top: 0; background: #f0f2ff; padding-bottom: 10px; z-index: 10; color: #667eea; }

/* ================= TOAST ================= */
.toast {
	position: fixed;
	top: 90px;
	right: 15px;
	background: #ffffff;
	color: #1a1a2e;
	padding: 14px 20px 14px 50px;
	border-radius: 12px;
	font-size: 15px;
	font-weight: 600;
	display: none;
	box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
	z-index: 3000;
	line-height: 1.4;
	border-left: 4px solid #667eea;
	min-width: 240px;
}

.toast.show { animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1); }
.toast.hide { animation: toastOut 0.4s ease forwards; }

.toast::before {
	content: "✔";
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	font-size: 16px;
	font-weight: bold;
	width: 26px;
	height: 26px;
	border-radius: 50%;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	display: flex;
	align-items: center;
	justify-content: center;
	text-align: center;
	line-height: 26px;
}

.toast.success { border-left-color: #10b981; }
.toast.success::before { content: "✔"; background: linear-gradient(135deg, #10b981, #059669); }
.toast.error { border-left-color: #ef4444; }
.toast.error::before { content: "✖"; background: linear-gradient(135deg, #ef4444, #dc2626); }
.toast.info { border-left-color: #667eea; }
.toast.info::before { content: "ℹ"; background: linear-gradient(135deg, #667eea, #764ba2); }

@keyframes toastIn { from { opacity: 0; transform: translateX(120px); } to { opacity: 1; transform: translateX(0); } }
@keyframes toastOut { from { opacity: 1; transform: translateX(0); } to { opacity: 0; transform: translateX(120px); } }

/* notification */
.notification-panel {
	position: fixed;
	bottom: 30px;
	right: -380px;
	width: 350px;
	height: 450px;
	background: #ffffff;
	box-shadow: -3px 0 30px rgba(102, 126, 234, 0.2);
	border-radius: 16px;
	transition: right 0.3s ease-in-out;
	z-index: 1000;
	font-family: Arial, sans-serif;
	border: 1px solid rgba(102, 126, 234, 0.2);
}

.notification-panel.show { right: 25px; }

.notification-header {
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	padding: 15px;
	border-radius: 16px 16px 0 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	font-weight: 700;
}

.notification-header button {
	background: rgba(255, 255, 255, 0.2);
	border: 1px solid rgba(255, 255, 255, 0.3);
	border-radius: 50%;
	color: white;
	font-size: 16px;
	cursor: pointer;
	width: 28px;
	height: 28px;
}

.notification-list {
	padding: 15px;
	max-height: 350px;
	overflow-y: auto;
}

.notification-item {
	background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
	padding: 12px;
	margin-bottom: 10px;
	border-left: 4px solid #667eea;
	border-radius: 8px;
	font-size: 14px;
	border: 1px solid rgba(102, 126, 234, 0.15);
}

.notification-list::-webkit-scrollbar { width: 6px; }
.notification-list::-webkit-scrollbar-thumb { background: rgba(102, 126, 234, 0.4); border-radius: 4px; }

/* ================= MODAL ================= */
.password-modal {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.45);
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
	border-radius: 16px;
	box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3);
	overflow: hidden;
	animation: fadeIn 0.25s ease;
}

.password-header {
	padding: 16px 20px;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.password-header h4 { margin: 0; font-size: 16px; font-weight: 700; }

.password-body {
	padding: 25px;
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.password-body .time-card {
	background: #f8f9ff;
	padding: 12px 14px;
	border-radius: 10px;
	margin-bottom: 10px;
	font-size: 14px;
	border: 1px solid #e0e4ff;
}

.password-body input {
	width: 100%;
	padding: 12px 14px;
	border-radius: 10px;
	border: 2px solid #e0e4ff;
	font-size: 14px;
	box-sizing: border-box;
	outline: none;
	transition: border-color 0.2s;
}

.password-body input:focus {
	border-color: #667eea;
	box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.password-body button {
	width: 100%;
	padding: 12px;
	border-radius: 25px;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	font-weight: 700;
	font-size: 14px;
	cursor: pointer;
	transition: 0.25s;
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.password-body button:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
}

.close-btn {
	cursor: pointer;
	font-size: 18px;
	background: rgba(255, 255, 255, 0.2);
	border: 1px solid rgba(255, 255, 255, 0.3);
	border-radius: 50%;
	width: 30px;
	height: 30px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: white;
}

@keyframes fadeIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }

/* ================= DARK THEME ================= */
.dark-theme { background: #121212; color: white; }
.dark-theme .password-box { background: #1e1e1e; color: white; }
.dark-theme input { background: #2c2c2c; color: white; border: 1px solid #555; }

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
	background: linear-gradient(135deg, rgba(14, 165, 233, 0.08), rgba(99, 102, 241, 0.08));
	border-radius: 10px;
	border: 1px solid rgba(14, 165, 233, 0.15);
	margin-bottom: 12px;
}

.break-total-row .tr-label { font-size: 12px; color: #6b7280; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
.break-total-row .tr-val { font-size: 15px; font-weight: 800; color: #0ea5e9; letter-spacing: 1px; }

.break-actions { display: flex; gap: 12px; margin-bottom: 14px; }

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

.break-actions button:disabled { opacity: 0.4; cursor: not-allowed; transform: none !important; box-shadow: none !important; }

.break-log {
	max-height: 110px;
	overflow-y: auto;
	display: flex;
	flex-direction: column;
	margin-bottom: 10px;
	gap: 6px;
}

.break-log::-webkit-scrollbar { width: 3px; }
.break-log::-webkit-scrollbar-thumb { background: rgba(14, 165, 233, 0.3); border-radius: 3px; }

/* ================= NEXUS-STYLE ATTENDANCE ================= */
.attendance-subtitle { color: #64748b; font-size: 14px; margin: -8px 0 20px 0; font-weight: 500; }

.attendance-section-title {
	font-size: 13px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 12px;
}

.attendance-cards-row {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	margin-bottom: 24px;
	align-items: stretch;
}

@media (max-width: 768px) { .attendance-cards-row { grid-template-columns: 1fr; } }

.status-card, .break-card, .activity-log-card {
	background: #ffffff;
	border: 1px solid #e2e8f0;
	border-radius: 12px;
	padding: 20px 24px;
	margin-bottom: 20px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.attendance-cards-row .status-card,
.attendance-cards-row .break-card {
	margin-bottom: 0;
	min-height: 280px;
	display: flex;
	flex-direction: column;
	transition: box-shadow 0.2s ease, transform 0.2s ease;
}

.attendance-cards-row .status-card:hover,
.attendance-cards-row .break-card:hover { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); }

.attendance-cards-row .break-card .break-log { flex: 1; min-height: 60px; }

.status-card .punch-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 10px 0;
	border-bottom: 1px solid #f1f5f9;
}

.status-card .punch-row:last-of-type { border-bottom: none; }
.status-card .punch-label { color: #64748b; font-weight: 600; font-size: 14px; }
.status-card .punch-value { color: #1e293b; font-weight: 600; font-size: 14px; }

.punch-actions-nexus { display: flex; gap: 12px; margin-top: 20px; flex-wrap: wrap; }

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

.punch-in-btn-nexus:not(:disabled) { background: #4f46e5; }
.punch-in-btn-nexus:hover:not(:disabled) { background: #4338ca; }
.punch-in-btn-nexus:disabled { opacity: 0.7; cursor: not-allowed; }

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

.punch-out-btn-nexus:hover:not(:disabled) { background: #b91c1c; }
.punch-out-btn-nexus:disabled { background: #94a3b8; opacity: 0.7; cursor: not-allowed; }

.break-action-btn {
	padding: 11px 20px;
	border-radius: 8px;
	border: none;
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	transition: opacity 0.2s, background 0.2s;
}

.break-action-btn:disabled { opacity: 0.45; cursor: not-allowed; pointer-events: auto; }
.start-break-btn { background: #7c3aed !important; color: #fff !important; }
.start-break-btn:hover:not(:disabled) { background: #6d28d9 !important; }
.end-break-btn-nexus { background: #64748b !important; color: #fff !important; }
.end-break-btn-nexus:hover:not(:disabled) { background: #475569 !important; }

.break-card .tr-label { text-transform: uppercase; }

.time-card {
	background: #f8f9ff;
	padding: 10px 12px;
	border-radius: 8px;
	font-size: 12px;
	border: 1px solid rgba(148, 163, 184, 0.4);
	margin-bottom: 4px;
}

.activity-log-card h3 {
	font-size: 16px;
	font-weight: 700;
	color: #1e293b;
	margin: 0 0 16px 0;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.activity-log-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 14px;
}

.activity-log-table th {
	text-align: left;
	padding: 12px 10px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	font-size: 11px;
	letter-spacing: 0.5px;
	border-bottom: 2px solid #e2e8f0;
}

.activity-log-table td {
	padding: 12px 10px;
	border-bottom: 1px solid #f1f5f9;
	color: #334155;
}

.activity-log-table tr:hover td { background: #f8fafc; }

.status-badge-present { color: #15803d; font-weight: 700; }
.status-badge-absent { color: #64748b; font-weight: 600; }

.log-nav {
	display: inline-flex;
	align-items: center;
	gap: 4px;
	background: none;
	border: none;
	color: #64748b;
	cursor: pointer;
	padding: 6px 10px;
	border-radius: 6px;
	font-size: 14px;
	transition: color 0.2s, background 0.2s;
}

.log-nav:hover { color: #4f46e5; background: #f1f5f9; }
.log-nav:disabled { opacity: 0.4; cursor: not-allowed; }

/* ================= TASK UPDATE FORM INSIDE CARD ================= */
.task-update-form {
	display: flex;
	flex-direction: column;
	gap: 8px;
	min-width: 220px;
}

.task-update-form select,
.task-update-form textarea,
.task-update-form input[type="file"] {
	padding: 7px 10px;
	border-radius: 8px;
	border: 1.5px solid #e0e4ff;
	font-size: 13px;
	background: #f8f9ff;
	outline: none;
	transition: border-color 0.2s;
	width: 100%;
	box-sizing: border-box;
}

.task-update-form select:focus,
.task-update-form textarea:focus {
	border-color: #667eea;
	box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.task-update-form textarea {
	height: 48px;
	resize: none;
}
</style>
</head>

<body>

	<!-- CHANGE PASSWORD MODAL -->
	<div id="passwordModal" class="password-modal">
		<div class="password-box">
			<div class="password-header">
				<h4>Change Password</h4>
				<span class="close-btn" onclick="closeChangePassword()">✖</span>
			</div>
			<div class="password-body">
				<input type="password" id="newPassword" placeholder="New Password">
				<input type="password" id="confirmPassword" placeholder="Confirm Password">
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

	<!-- TOP BAR -->
	<div class="top-bar">
		<h2>Smart Office • Employee Dashboard</h2>
		<div class="user-area">
			<button class="icon-btn"
				onclick="setActive(this); openNotifications(); setTab('notificationPanel');">
				<i class="fa-solid fa-bell"></i>
			</button>
			Welcome, <b><%=session.getAttribute("fullName") != null ? session.getAttribute("fullName") : username%></b>
		</div>
	</div>

	<div class="container">

		<div class="left-panel">

			<!-- Navigation Links -->
			<div class="nav-links">
				<button class="nav-btn active"
					onclick="setActive(this); showAttendance(); setTab('attendance');">
					<i class="fa-solid fa-user-check"></i> <span>My Attendance</span>
				</button>

				<button class="nav-btn"
					onclick="setActive(this); showTasks(); setTab('tasks');">
					<i class="fa-solid fa-list-check"></i> <span>Tasks</span>
				</button>

				<button class="nav-btn"
					onclick="setActive(this); showMyTeam(); setTab('myteam');">
					<i class="fa-solid fa-users"></i> <span>My Team</span>
				</button>

				<button class="nav-btn"
					onclick="setActive(this); showLeave(); setTab('leave');">
					<i class="fa-solid fa-calendar-xmark"></i> <span>Apply Leave</span>
				</button>

				<button class="nav-btn"
					onclick="setActive(this); showMeetings(); setTab('meetings');">
					<i class="fa-solid fa-handshake"></i> <span>Scheduled Meetings</span>
				</button>

				<button class="nav-btn"
					onclick="setActive(this); openCalendar(); setTab('calendar');">
					<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
				</button>
			</div>

			<!-- Bottom: Settings (inline expand) + Logout -->
			<div class="sidebar-bottom">

				<!-- Settings toggle -->
				<button class="settings-toggle-btn" id="settingsToggleBtn" onclick="toggleSettingsMenu()">
					<i class="fa-solid fa-gear main-icon"></i>
					<span>Settings</span>
					<i class="fa-solid fa-chevron-down chevron"></i>
				</button>

				<!-- Inline sub-menu -->
				<div class="settings-submenu" id="settingsSubmenu">
					<button class="settings-sub-btn" onclick="openProfile()">
						<i class="fa-solid fa-user"></i> My Profile
					</button>
					<button class="settings-sub-btn" onclick="openChangePassword()">
						<i class="fa-solid fa-lock"></i> Change Password
					</button>
				</div>

				<!-- Logout -->
				<a href="<%=request.getContextPath()%>/logout" style="text-decoration: none;">
					<button class="sidebar-logout-btn">
						<i class="fa-solid fa-right-to-bracket"></i>
						<span>Logout</span>
					</button>
				</a>

			</div>
		</div>

		<div class="right-panel">

			<!-- Attendance (Nexus-style) -->
			<div class="box" id="attendanceSection">
				<h2 style="font-size: 20px; font-weight: 700; color: #1e293b; margin: 0 0 4px 0;">
					<i class="fa-solid fa-clock" style="margin-right: 8px;"></i>Attendance
				</h2>
				<p class="attendance-subtitle">Track your work sessions and breaks.</p>

				<div class="attendance-cards-row">
					<!-- Status card -->
					<div class="status-card">
						<div class="attendance-section-title">Status</div>
						<div class="punch-row">
							<span class="punch-label">Punch In</span>
							<span class="punch-value"><%=punchIn != null ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(punchIn) : "--"%></span>
						</div>
						<div class="punch-row">
							<span class="punch-label">Punch Out</span>
							<span class="punch-value"><%=punchOut != null ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(punchOut) : "--"%></span>
						</div>
						<%
						if (isWeekend) {
						%>
						<p style="color: #64748b; font-size: 13px; margin: 12px 0 0 0;">Attendance is closed on weekends.</p>
						<%
						} else {
						%>
						<div class="punch-actions-nexus">
							<form action="attendance" method="post" style="display: inline;">
								<input type="hidden" name="action" value="punchin">
								<button type="submit" class="punch-in-btn-nexus" <%=punchIn != null ? "disabled" : ""%>>Punch In</button>
							</form>
							<form action="attendance" method="post" style="display: inline;">
								<input type="hidden" name="action" value="punchout">
								<button type="submit" class="punch-out-btn-nexus" <%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>Punch Out</button>
							</form>
						</div>
						<%
						}
						%>
					</div>

					<!-- Break card -->
					<div class="break-card" id="breakSection">
						<div class="attendance-section-title">TOTAL BREAK TODAY</div>
						<div class="break-total-row">
							<span class="tr-label">Total Break Today</span>
							<span class="tr-val">
								<%
								int breakSecs = 0;
								if (request.getAttribute("breakTotalSeconds") != null) {
									breakSecs = (Integer) request.getAttribute("breakTotalSeconds");
								}
								int bh = breakSecs / 3600;
								int bm = (breakSecs % 3600) / 60;
								int bs = breakSecs % 60;
								%>
								<%=String.format("%02d:%02d:%02d", bh, bm, bs)%>
							</span>
						</div>
						<div class="break-actions">
							<form action="break" method="post" style="display: inline;">
								<input type="hidden" name="action" value="start">
								<input type="hidden" name="redirect" value="user">
								<button type="submit" class="start-break-btn break-action-btn"
									<%=(punchIn == null || punchOut != null || onBreak) ? "disabled" : ""%>>Start Break</button>
							</form>
							<form action="break" method="post" style="display: inline; margin-left: 8px;">
								<input type="hidden" name="action" value="end">
								<input type="hidden" name="redirect" value="user">
								<button type="submit" class="end-break-btn-nexus break-action-btn"
									<%=!onBreak ? "disabled" : ""%>>End Break</button>
							</form>
						</div>
						<div class="break-log" style="margin-top: 10px;">
							<%
							java.util.List<com.smartoffice.model.BreakLog> empBreaks = (java.util.List<com.smartoffice.model.BreakLog>) request.getAttribute("breakLogs");
							SimpleDateFormat timeOnlyFmt = new SimpleDateFormat("HH:mm:ss");
							if (empBreaks != null && !empBreaks.isEmpty()) {
								for (com.smartoffice.model.BreakLog b : empBreaks) {
									String startStr = b.getStartTime() != null ? timeOnlyFmt.format(b.getStartTime()) : "--";
									String endStr = b.getEndTime() != null ? timeOnlyFmt.format(b.getEndTime()) : "--";
							%>
							<div class="time-card">From <b><%=startStr%></b> to <b><%=endStr%></b></div>
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

				<!-- Recent Activity Log -->
				<div class="activity-log-card">
					<h3>
						Recent Activity Log
						<span class="log-nav-wrap">
							<button type="button" class="log-nav" id="logPrev" aria-label="Previous">
								<i class="fa-solid fa-chevron-left"></i>
							</button>
							<button type="button" class="log-nav" id="logNext" aria-label="Next">
								<i class="fa-solid fa-chevron-right"></i>
							</button>
						</span>
					</h3>
					<table class="activity-log-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Punch In / Out</th>
								<th>Break</th>
								<th>Total</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody id="activityLogBody">
							<%
							List<AttendanceLogEntry> activityLog = (List<AttendanceLogEntry>) request.getAttribute("attendanceLog");
							SimpleDateFormat dateFmt = new SimpleDateFormat("MMM d, yyyy");
							SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
							if (activityLog != null && !activityLog.isEmpty()) {
								for (AttendanceLogEntry e : activityLog) {
									java.sql.Timestamp pi = e.getPunchIn();
									java.sql.Timestamp po = e.getPunchOut();
									int br = e.getBreakSeconds();
									long totalSec = 0;
									if (pi != null && po != null) {
										totalSec = Math.max(0, (po.getTime() - pi.getTime()) / 1000 - br);
									}
									int th = (int) (totalSec / 3600);
									int tm = (int) ((totalSec % 3600) / 60);
									String totalStr = th + "h " + tm + "m";
									int brH = br / 3600;
									int brM = (br % 3600) / 60;
									String breakStr = brH + "h " + String.format("%02d", brM) + "m";
									String inOutStr = pi != null ? timeFmt.format(pi) : "--";
									if (po != null)
										inOutStr += " (" + timeFmt.format(po) + ")";
							%>
							<tr data-log-row>
								<td><%=e.getAttendanceDate() != null ? dateFmt.format(e.getAttendanceDate()) : "--"%></td>
								<td><%=inOutStr%></td>
								<td><%=breakStr%></td>
								<td><%=totalStr%></td>
								<td><span class="<%="Present".equals(e.getStatus()) ? "status-badge-present" : "status-badge-absent"%>"><%=e.getStatus() != null ? e.getStatus() : "--"%></span></td>
							</tr>
							<%
							}
							} else {
							%>
							<tr>
								<td colspan="5" style="text-align: center; padding: 24px; color: #64748b;">No attendance records yet.</td>
							</tr>
							<%
							}
							%>
						</tbody>
					</table>
				</div>
			</div>

			<script>
			(function() {
				var rows = document.querySelectorAll('#activityLogBody tr[data-log-row]');
				var perPage = 5;
				var totalPages = Math.max(1, Math.ceil(rows.length / perPage));
				var cur = 0;
				function showPage() {
					for (var i = 0; i < rows.length; i++) {
						rows[i].style.display = (i >= cur * perPage && i < (cur + 1) * perPage) ? '' : 'none';
					}
					document.getElementById('logPrev').disabled = cur <= 0;
					document.getElementById('logNext').disabled = cur >= totalPages - 1;
				}
				if (rows.length > 0) {
					showPage();
					document.getElementById('logPrev').onclick = function() { if (cur > 0) { cur--; showPage(); } };
					document.getElementById('logNext').onclick = function() { if (cur < totalPages - 1) { cur++; showPage(); } };
				} else {
					document.getElementById('logPrev').disabled = true;
					document.getElementById('logNext').disabled = true;
				}
			})();
			</script>

			<!-- Tasks -->
			<div class="box" id="taskSection" style="display: none;">
				<fieldset class="attendance-fieldset">
					<legend><i class="fa-solid fa-list-check"></i> Assigned Tasks</legend>
					<%
					List<Task> tasks = (List<Task>) request.getAttribute("tasks");
					if (tasks == null || tasks.isEmpty()) {
					%>
					<p class="no-task-text">No tasks assigned.</p>
					<%
					} else {
						for (Task t : tasks) {
					%>
					<div class="task-card" id="task-card-<%=t.getId()%>">
						<div class="task-left">
							<i class="fa-solid fa-file-lines"></i>
							<div>
								<b><%=t.getTitle() != null ? t.getTitle() : t.getDescription()%></b><br>
								<small><%=t.getDescription()%></small><br>
								<small>
									<%
									java.sql.Date dl = t.getDeadline();
									String pr = t.getPriority();
									%>
									Deadline: <%=dl != null ? dl.toString() : "--"%> &nbsp; | Priority: <%=pr != null ? pr : "MEDIUM"%>
								</small><br>
								<%
								String attName = t.getAttachmentName();
								if (attName != null && !attName.isEmpty()) {
								%>
								<small><a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>" target="_blank">Download: <%=attName%></a></small><br>
								<%
								}
								%>
								<small>Assigned by: <%=t.getAssignedBy()%></small>
							</div>
						</div>
						<div class="task-actions">
							<div class="task-update-form" id="task-form-<%=t.getId()%>">
								<select id="status-<%=t.getId()%>" class="task-dropdown">
									<option value="">Update Status</option>
									<option value="COMPLETED" <%="COMPLETED".equals(t.getStatus()) ? "selected" : ""%>>Complete</option>
									<option value="INCOMPLETE" <%="INCOMPLETE".equals(t.getStatus()) ? "selected" : ""%>>Incomplete</option>
									<option value="ERRORS_RAISED" <%="ERRORS_RAISED".equals(t.getStatus()) ? "selected" : ""%>>Errors Raised</option>
									<option value="DOCUMENT_VERIFICATION" <%="DOCUMENT_VERIFICATION".equals(t.getStatus()) ? "selected" : ""%>>Document Verification</option>
								</select>
								<input type="file" id="file-<%=t.getId()%>" accept="*/*">
								<textarea id="comment-<%=t.getId()%>" placeholder="Add comment" style="height:48px; resize:none; padding:7px 10px; border-radius:8px; border:1.5px solid #e0e4ff; font-size:13px; background:#f8f9ff; outline:none; width:100%; box-sizing:border-box;"></textarea>
								<button
									class="submit-btn"
									onclick="submitTaskUpdate(<%=t.getId()%>, this)"
									type="button">
									Submit Update
								</button>
							</div>
						</div>
					</div>
					<%
					}
					}
					%>
				</fieldset>
			</div>

			<!-- My Team -->
			<div class="box" id="myTeamSection" style="display: none;">
				<fieldset class="attendance-fieldset">
					<legend><i class="fa-solid fa-users"></i> My Team</legend>
					<div class="team-scroll">
						<div class="employee-grid">
							<%
							List<com.smartoffice.model.Team> myTeamsEmp = (List<com.smartoffice.model.Team>) request.getAttribute("myTeams");
							if (myTeamsEmp != null && !myTeamsEmp.isEmpty()) {
								for (com.smartoffice.model.Team t : myTeamsEmp) {
							%>
							<div class="task-card">
								<div class="task-left">
									<i class="fa-solid fa-people-group"></i>
									<div>
										<b><%=t.getName()%></b><br>
										<small>Manager: <%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%></small><br>
										<small>Members: <%=t.getMembers().size()%></small>
										<%
										if (!t.getMembers().isEmpty()) {
										%>
										<br><small>
											<%
											for (com.smartoffice.model.User m : t.getMembers()) {
											%>
											<span style="display: inline-block; background: #e2e8f0; padding: 2px 8px; border-radius: 999px; margin: 1px; font-size: 11px;">
												<%=m.getFullname() != null ? m.getFullname() : m.getEmail()%>
											</span>
											<%
											}
											%>
										</small>
										<%
										}
										%>
									</div>
								</div>
							</div>
							<%
							}
							} else {
							%>
							<p class="no-task-text">You are not part of any team yet.</p>
							<%
							}
							%>
						</div>
					</div>
				</fieldset>
			</div>

			<!-- Meetings -->
			<div class="box" id="meetingSection" style="display: none;">
				<fieldset class="attendance-fieldset">
					<legend><i class="fa-solid fa-video"></i> Scheduled Meetings</legend>
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
								<b><%=m.getTitle()%></b><br>
								<small><%=m.getDescription()%></small><br>
								<small>🕒 <%=m.getStartTime()%> → <%=m.getEndTime()%></small>
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
				<iframe id="calendarFrame" src="" style="width: 100%; height: 100%; border: none;"></iframe>
			</div>

			<!-- ===== Leave — updated 2-column layout ===== -->
			<div class="box" id="leaveSection" style="display: none;">
				<fieldset class="attendance-fieldset">
					<legend><i class="fa-solid fa-calendar-days"></i> Leave</legend>

					<!-- Tab buttons -->
					<div class="leave-tab-row">
						<button id="applyLeaveTabBtn" type="button"
							class="leave-tab-btn leave-tab-active"
							onclick="showApplyLeave()">Apply Leave</button>
						<button id="myLeavesTabBtn" type="button"
							class="leave-tab-btn"
							onclick="showMyLeaves()">My Leave Requests</button>
					</div>

					<!-- Apply Leave: 2-column grid -->
					<div id="applyLeaveSection">
						<div class="leave-apply-grid">

							<!-- LEFT: form -->
							<div class="leave-apply-left">
								<h4>
									<i class="fa-solid fa-paper-plane" style="color:#667eea;"></i>
									Submit Request
								</h4>
								<form class="leave-form-inner" action="applyLeave" method="post">
									<div>
										<label>Leave Type</label>
										<select name="leaveType" required>
											<option value="">Select</option>
											<option>Casual Leave</option>
											<option>Sick Leave</option>
											<option>Earned Leave</option>
										</select>
									</div>

									<div class="leave-date-row">
										<div>
											<label>From Date</label>
											<input type="date" name="fromDate" required>
										</div>
										<div>
											<label>To Date</label>
											<input type="date" name="toDate" required>
										</div>
									</div>

									<div>
										<label>Reason</label>
										<textarea name="reason" required placeholder="Briefly describe the reason..."></textarea>
									</div>

									<button type="submit" class="leave-submit-btn">
										<i class="fa-solid fa-paper-plane"></i> Submit Request
									</button>
								</form>
							</div>

							<!-- RIGHT: leave policy -->
							<div class="leave-apply-right">
								<h4>
									<i class="fa-solid fa-circle-info" style="color:#667eea;"></i>
									Leave Policy
								</h4>

								<div class="leave-policy-item leave-policy-casual">
									<b>Casual Leave</b>
									For personal errands or short-notice absences. Typically limited to a set number of days per year.
								</div>

								<div class="leave-policy-item leave-policy-sick">
									<b>Sick Leave</b>
									Applicable when you are unwell and unable to attend work. A medical certificate may be required.
								</div>

								<div class="leave-policy-item leave-policy-earned">
									<b>Earned Leave</b>
									Accrued over time based on service. Plan in advance and get approval from HR.
								</div>

								<div class="leave-policy-note">
									<i class="fa-solid fa-triangle-exclamation"></i>
									<span>All leave requests are subject to admin approval. Submit at least 2 working days in advance when possible.</span>
								</div>
							</div>

						</div>
					</div>

					<!-- My Leave Requests -->
					<div id="myLeaveSection" style="display: none;">
						<div class="leave-requests-scroll">
							<%
							if (myLeaves == null || myLeaves.isEmpty()) {
							%>
							<p class="no-task-text">No leave requests found.</p>
							<%
							} else {
								for (LeaveRequest lr : myLeaves) {
							%>
							<div class="task-card">
								<div class="task-left">
									<i class="fa-solid fa-plane-departure"></i>
									<div>
										<b><%=lr.getLeaveType()%></b><br>
										<small><%=lr.getFromDate()%> → <%=lr.getToDate()%></small>
									</div>
								</div>
								<%
								String st = lr.getStatus();
								String cls = "pending";
								if ("APPROVED".equalsIgnoreCase(st)) cls = "done";
								if ("REJECTED".equalsIgnoreCase(st)) cls = "out";
								%>
								<span class="task-status <%=cls%>"><%=st%></span>
							</div>
							<%
							}
							}
							%>
						</div>
					</div>

				</fieldset>
			</div>

			<!-- Notification Panel -->
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
						🔔 <%=n.getMessage()%><br>
						<small>By <%=n.getCreatedBy()%></small>
						<div style="margin-top: 8px; text-align: right;">
							<button
								style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 4px 10px; border-radius: 12px; cursor: pointer; font-size: 12px; font-weight: 600;"
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

			<!-- Toast -->
			<div id="toast" class="toast"></div>

		</div>
	</div>

	<script>
	/* ================= SETTINGS INLINE TOGGLE ================= */
	function toggleSettingsMenu() {
	    var btn = document.getElementById("settingsToggleBtn");
	    var menu = document.getElementById("settingsSubmenu");
	    btn.classList.toggle("open");
	    menu.classList.toggle("open");
	}

	/* ================= THEME ================= */
	function toggleTheme() {
	    document.body.classList.toggle("dark-theme");
	    localStorage.setItem("theme",
	        document.body.classList.contains("dark-theme") ? "dark" : "light"
	    );
	}

	if (localStorage.getItem("theme") === "dark") {
	    document.body.classList.add("dark-theme");
	}

	/* ================= SECTION VISIBILITY ================= */
	function hideAllSections() {
	    document.getElementById("attendanceSection").style.display = "none";
	    document.getElementById("taskSection").style.display = "none";
	    document.getElementById("leaveSection").style.display = "none";
	    document.getElementById("calendarSection").style.display = "none";
	    document.getElementById("meetingSection").style.display = "none";
	    var myTeam = document.getElementById("myTeamSection");
	    if (myTeam) myTeam.style.display = "none";
	}

	function showAttendance() { hideAllSections(); document.getElementById("attendanceSection").style.display = "block"; }
	function showTasks()      { hideAllSections(); document.getElementById("taskSection").style.display = "block"; }
	function showMyTeam()     { hideAllSections(); var t = document.getElementById("myTeamSection"); if (t) t.style.display = "block"; }
	function showMeetings()   { hideAllSections(); document.getElementById("meetingSection").style.display = "block"; }
	function showLeave()      { hideAllSections(); document.getElementById("leaveSection").style.display = "block"; }

	function openCalendar() {
	    hideAllSections();
	    document.getElementById("calendarSection").style.display = "block";
	    document.getElementById("calendarFrame").src = "calendar.jsp";
	}

	/* ================= LEAVE TAB SWITCHING ================= */
	function showApplyLeave() {
	    document.getElementById("applyLeaveSection").style.display = "block";
	    document.getElementById("myLeaveSection").style.display = "none";
	    document.getElementById("applyLeaveTabBtn").classList.add("leave-tab-active");
	    document.getElementById("myLeavesTabBtn").classList.remove("leave-tab-active");
	}

	function showMyLeaves() {
	    document.getElementById("applyLeaveSection").style.display = "none";
	    document.getElementById("myLeaveSection").style.display = "block";
	    document.getElementById("myLeavesTabBtn").classList.add("leave-tab-active");
	    document.getElementById("applyLeaveTabBtn").classList.remove("leave-tab-active");
	}

	/* ================= NOTIFICATIONS ================= */
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
	                var el = document.getElementById("notif-" + notificationId);
	                if (el) el.remove();
	                var list = document.getElementById("notificationList");
	                var remaining = list.querySelectorAll(".notification-item");
	                if (remaining.length === 0) {
	                    list.innerHTML = '<div class="notification-item">No notifications</div>';
	                }
	            }
	        })
	        .catch(err => console.error(err));
	}

	/* ================= MODALS ================= */
	function openChangePassword() {
	    var modal = document.getElementById("passwordModal");
	    modal.style.visibility = "visible";
	    modal.style.opacity = "1";
	}

	function closeChangePassword() {
	    var modal = document.getElementById("passwordModal");
	    modal.style.visibility = "hidden";
	    modal.style.opacity = "0";
	}

	function openProfile() {
	    var modal = document.getElementById("profileModal");
	    modal.style.visibility = "visible";
	    modal.style.opacity = "1";
	}

	function closeProfile() {
	    var modal = document.getElementById("profileModal");
	    modal.style.visibility = "hidden";
	    modal.style.opacity = "0";
	}

	window.onclick = function(e) {
	    var modal = document.getElementById("passwordModal");
	    var profile = document.getElementById("profileModal");
	    if (e.target === modal) closeChangePassword();
	    if (e.target === profile) closeProfile();
	};

	/* ================= TOAST ================= */
	function showToast(message, type) {
	    type = type || "success";
	    var toast = document.getElementById("toast");
	    toast.style.display = "none";
	    toast.className = "toast";
	    toast.offsetHeight;
	    toast.classList.add(type);
	    toast.textContent = message;
	    toast.style.display = "block";
	    toast.classList.add("show");
	    setTimeout(function() {
	        toast.classList.remove("show");
	        toast.classList.add("hide");
	        setTimeout(function() {
	            toast.style.display = "none";
	            toast.className = "toast";
	        }, 400);
	    }, 2500);
	}

	/* ================= PASSWORD CHANGE ================= */
	function submitPassword() {
	    var newPassword = document.getElementById("newPassword").value.trim();
	    var confirmPassword = document.getElementById("confirmPassword").value.trim();
	    if (!newPassword || !confirmPassword) { showToast("Please fill all fields", "error"); return; }
	    fetch("<%=request.getContextPath()%>/changePassword", {
	        method: "POST",
	        headers: { "Content-Type": "application/x-www-form-urlencoded" },
	        body: new URLSearchParams({ newPassword: newPassword, confirmPassword: confirmPassword })
	    })
	    .then(function(res) { return res.text(); })
	    .then(function(data) {
	        if (data === "Success") {
	            showToast("Password updated successfully", "success");
	            closeChangePassword();
	            document.getElementById("newPassword").value = "";
	            document.getElementById("confirmPassword").value = "";
	        } else if (data === "PasswordMismatch") {
	            showToast("Passwords do not match", "error");
	        } else if (data === "MissingFields") {
	            showToast("All fields are required", "error");
	        } else if (data === "Unauthorized") {
	            showToast("Session expired. Please login again.", "error");
	        } else {
	            showToast("Something went wrong", "error");
	        }
	    })
	    .catch(function() { showToast("Server error", "error"); });
	}

	/* ================= AJAX TASK UPDATE — NO PAGE REDIRECT ================= */
	function submitTaskUpdate(taskId, btn) {
	    var statusEl  = document.getElementById("status-"  + taskId);
	    var commentEl = document.getElementById("comment-" + taskId);
	    var fileEl    = document.getElementById("file-"    + taskId);

	    var selectedStatus = statusEl ? statusEl.value : "";
	    if (!selectedStatus) {
	        showToast("Please select a status before submitting.", "error");
	        return;
	    }

	    var formData = new FormData();
	    formData.append("taskId",  taskId);
	    formData.append("status",  selectedStatus);
	    formData.append("comment", commentEl ? commentEl.value : "");
	    if (fileEl && fileEl.files.length > 0) {
	        formData.append("employeeFile", fileEl.files[0]);
	    }

	    btn.disabled    = true;
	    btn.textContent = "Submitting…";

	    fetch("<%=request.getContextPath()%>/submitTaskUpdate", {
	        method: "POST",
	        body:   formData
	    })
	    .then(function(response) {
	        if (response.ok || response.redirected) {
	            showToast("Task updated successfully! ✔", "success");
	            if (statusEl)  statusEl.value  = "";
	            if (commentEl) commentEl.value = "";
	            if (fileEl)    fileEl.value    = "";
	        } else {
	            return response.text().then(function(txt) {
	                showToast("Update failed: " + (txt || response.statusText), "error");
	            });
	        }
	    })
	    .catch(function(err) {
	        showToast("Network error. Please try again.", "error");
	        console.error("Task update error:", err);
	    })
	    .finally(function() {
	        btn.disabled    = false;
	        btn.textContent = "Submit Update";
	    });
	}

	/* ================= SET ACTIVE NAV ================= */
	function setActive(btn) {
	    document.querySelectorAll(".nav-btn").forEach(function(b) { b.classList.remove("active"); });
	    btn.classList.add("active");
	}

	function setTab(tabName) {
	    sessionStorage.setItem("activeTab", tabName);
	}

	/* ================= INIT ON LOAD ================= */
	window.onload = function() {
	    var params = new URLSearchParams(window.location.search);
	    var tab = params.get("tab");
	    var sub = params.get("sub");
	    var buttons = document.querySelectorAll(".nav-btn");

	    if (params.has("success")) {
	        var success = params.get("success");
	        if (success === "LeaveApplied")     showToast("Leave applied successfully", "success");
	        else if (success === "PasswordUpdated") showToast("Password updated successfully", "success");
	        else if (success === "Login")        showToast("Logged in successfully", "success");
	        else if (success === "PunchIn")      showToast("Punched in successfully 🕘", "success");
	        else if (success === "PunchOut")     showToast("Punched out successfully 🕔", "success");
	    }

	    if (params.has("error")) {
	        var error = params.get("error");
	        if (error === "WrongOldPassword")      showToast("Old password is incorrect", "error");
	        else if (error === "PasswordMismatch") showToast("Passwords do not match", "error");
	        else if (error === "HolidayAttendance") showToast("Today is a holiday. Attendance not allowed.", "error");
	        else if (error === "accessDenied")     showToast("Access denied. You do not have permission for that page.", "error");
	        else showToast("Something went wrong", "error");
	    }

	    if (tab === "tasks")       { showTasks();    setActive(buttons[1]); }
	    else if (tab === "leave")  {
	        showLeave(); setActive(buttons[3]);
	        if (sub === "apply")         showApplyLeave();
	        else if (sub === "myLeaves") showMyLeaves();
	    }
	    else if (tab === "meetings") { showMeetings();  setActive(buttons[4]); }
	    else if (tab === "calendar") { openCalendar();  setActive(buttons[5]); }
	    else { showAttendance(); setActive(buttons[0]); }

	    if (params.has("success") || params.has("error")) {
	        setTimeout(function() {
	            window.history.replaceState({}, document.title, window.location.pathname);
	        }, 100);
	    }
	};

	window.addEventListener("beforeunload", function() {
	    if (performance.navigation.type === 1) {
	        sessionStorage.removeItem("activeTab");
	    }
	});

	/* ================= SECURITY ================= */
	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e =>
	    e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
	        ? false : true;
	</script>

	<!-- BREAK TIME SCRIPT -->
	<script>
	var breakStartTime = null;
	var breakInterval  = null;
	var totalBreakMs   = 0;
	var breakEntries   = [];

	function fmtTime(ms) {
	    var s  = Math.floor(ms / 1000);
	    var h  = Math.floor(s / 3600);
	    var m  = Math.floor((s % 3600) / 60);
	    var sc = s % 60;
	    return [h, m, sc].map(function(x) { return String(x).padStart(2, '0'); }).join(':');
	}

	function startBreak() {
	    if (breakStartTime) return;
	    breakStartTime = Date.now();
	    document.getElementById('startBreakBtn').disabled = true;
	    document.getElementById('endBreakBtn').disabled   = false;
	    breakInterval = setInterval(function() {
	        var elapsed = Date.now() - breakStartTime;
	        var el = document.getElementById('breakTimer');
	        if (el) el.textContent = fmtTime(elapsed);
	    }, 1000);
	}

	function endBreak() {
	    if (!breakStartTime) return;
	    clearInterval(breakInterval);
	    var dur = Date.now() - breakStartTime;
	    totalBreakMs += dur;
	    var start = new Date(breakStartTime);
	    var end = new Date();
	    breakEntries.push({ start: start, end: end, dur: dur });
	    renderBreakLog();
	    breakStartTime = null;
	    document.getElementById('startBreakBtn').disabled = false;
	    document.getElementById('endBreakBtn').disabled   = true;
	    var bt = document.getElementById('breakTimer');
	    if (bt) bt.textContent = '00:00:00';
	    var tbt = document.getElementById('totalBreakTime');
	    if (tbt) tbt.textContent = fmtTime(totalBreakMs);
	}

	function renderBreakLog() {
	    var log = document.getElementById('breakLog');
	    if (!log) return;
	    log.innerHTML = '';
	    breakEntries.forEach(function(e, i) {
	        var fmt = function(t) { return t.toTimeString().substring(0, 8); };
	        var div = document.createElement('div');
	        div.className = 'break-entry';
	        div.innerHTML =
	            '<span class="be-label">Break ' + (i + 1) + ' &nbsp; ' + fmt(e.start) + ' – ' + fmt(e.end) + '</span>' +
	            '<span class="be-dur">' + fmtTime(e.dur) + '</span>';
	        log.appendChild(div);
	    });
	}
	</script>

</body>
</html>
