<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>

<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.model.TeamAttendance"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="com.smartoffice.model.Notification"%>

<%
String activeTab = (String) request.getAttribute("tab");
if (activeTab == null) {
	activeTab = "selfAttendance";
}
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
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager Dashboard • Smart Office</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ================= GLOBAL ================= */
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
	height: 100vh;
	display: flex;
	flex-direction: column;
	background: linear-gradient(135deg, #c3cfe2 0%, #e2ebf0 100%);
	overflow: hidden;
}

/* ================= TOP BAR ================= */
.top-bar {
	backdrop-filter: blur(10px);
	background: rgba(255, 255, 255, 0.25);
	border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	padding: 15px 30px;
	display: flex;
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

.welcome {
	font-size: 14px;
}

/* Buttons */
.settings-btn {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
}

.logout-btn {
	padding: 8px 14px;
	border-radius: 8px;
	border: none;
	background: #e53e3e;
	color: white;
	cursor: pointer;
}

/* ================= LAYOUT ================= */
.main-container {
	flex: 1;
	display: flex;
}

/* ================= SIDEBAR ================= */
.sidebar {
	width: 250px;
	backdrop-filter: blur(10px);
	background: rgba(255, 255, 255, 0.2);
	border-right: 1px solid rgba(255, 255, 255, 0.3);
	padding: 18px 12px;
}

/* NORMAL BUTTON (NO BG) */
.sidebar-btn {
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

/* HOVER */
.sidebar-btn:hover {
	background: rgba(102, 126, 234);
	color: white;
	font-size: 15px;
}

/* ACTIVE */
.sidebar-btn.active {
	background: linear-gradient(135deg, #e7e6eb);
	color: black;
	box-shadow: 0 6px 15px rgba(102, 126, 234, 0.4);
	position: relative;
	font-size: 15px;
}

.sidebar-btn.active::before {
	content: "";
	position: absolute;
	left: 0;
	top: 10%;
	width: 4px;
	height: 80%;
	background: white;
	border-radius: 2px;
}

/* ================= CONTENT ================= */
.content-area {
	flex: 1;
	padding: 25px;
	background: #c3cfe2;
	overflow-y: auto;
}

#contentFrame {
	width: 100%;
	height: 100%;
	border: none;
	background: rgb(255, 255, 255, 0);
}

/* ================= MODALS ================= */
/* ===== Modal Overlay ===== */
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

/* Show Modal */
.modal.show {
	display: flex;
}

/* ===== Modal Box ===== */
.modal-content {
	width: 50%;
	max-width: 700px;
	height: 420px;
	background: #ffffff;
	border-radius: 14px;
	box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
	display: flex;
	flex-direction: column;
	overflow: hidden;
	animation: modalFade 0.35s ease;
}

/* ===== Header ===== */
.modal-header {
	height: 70px;
	padding: 0 20px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.modal-header h4 {
	margin: 0;
	font-size: 18px;
	font-weight: 600;
}

/* Close Button */
.modal-close {
	font-size: 22px;
	cursor: pointer;
	transition: transform 0.2s, opacity 0.2s;
}

.modal-close:hover {
	transform: scale(1.15);
	opacity: 0.8;
}

/* ===== Iframe ===== */
#profileFrame {
	flex: 1;
	width: 100%;
	border: none;
	background: #f9fafb;
}
/* ===== Password Modal Form Styling ONLY ===== */
#passwordModal .modal-body {
	padding: 30px 25px;
	display: flex;
	flex-direction: column;
	align-items: center;
}

/* Inputs */
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

/* Input Focus */
#passwordModal input[type="password"]:focus {
	border-color: #6366f1;
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
}

/* Button */
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

/* Button Hover */
#passwordModal button:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

/* Button Active */
#passwordModal button:active {
	transform: scale(0.97);
}

/* Mobile Friendly */
@media ( max-width : 480px) {
	#passwordModal input[type="password"], #passwordModal button {
		max-width: 100%;
	}
}

/* ===== Animation ===== */
@
keyframes modalFade {from { opacity:0;
	transform: scale(0.95);
}

to {
	opacity: 1;
	transform: scale(1);
}

}

/* ===== Responsive ===== */
@media ( max-width : 768px) {
	.modal-content {
		width: 95%;
		height: 90%;
	}
} /* ================= SETTINGS DRAWER ================= */
/* ===== Settings Drawer ===== */
.settings-drawer {
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

/* Open State */
.settings-drawer.open {
	right: 0;
}

/* Header */
.settings-header {
	padding: 20px;
	font-size: 18px;
	height: 100px;
	font-weight: 600;
	color: #2d3748;
	border-bottom: 1px solid rgba(0, 0, 0, 0.08);
	display: flex;
	justify-content: space-between;
	align-items: center;
}

/* Close Button */
.settings-close {
	cursor: pointer;
	font-size: 20px;
	color: #718096;
	transition: color 0.3s;
}

.settings-close:hover {
	color: #e53e3e;
}

/* Items Container */
.settings-list {
	padding: 10px 0;
}

/* Individual Item */
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

/* Manager-specific styles (appended to override/adapt) */
.icon-btn {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
}

.attendance-fieldset {
	border: 2px solid #c3cfe2;
	border-radius: 14px;
	padding: 20px 24px 24px;
	background: #c3cfe2;
	box-shadow: 0 8px 18px rgba(0, 0, 0, 0.4);
}

.attendance-fieldset legend {
	padding: 10px;
	font-size: 18px;
	font-weight: 600;
	background: #e2ebf0;
	border-radius: 15px;
	color: #2d3748;
}

.attendance-row {
	display: flex;
	justify-content: space-between;
	padding: 10px 0;
	border-bottom: 1px dashed rgba(0, 0, 0, 0.1);
}

.attendance-row:last-child {
	border-bottom: none;
}

.attendance-row .label {
	font-weight: 600;
	color: #4a5568;
}

.attendance-row .value {
	color: #2d3748;
}

/* field set for my team */

/* ===== Fieldset Styling ===== */
.team-fieldset {
	border: 2px solid #c3cfe2;
	border-radius: 14px;
	padding: 20px 24px 30px;
	heigtht: 450px;
	overflow-y: auto;
	background: #c3cfe2;
	box-shadow: 0 8px 18px rgba(0, 0, 0, 0.5);
}

.team-fieldset legend {
	padding: 8px;
	font-size: 18px;
	font-weight: 600;
	background: #e2ebf0;
	border-radius: 15px;
	color: #2d3748;
}

/* ===== Scroll Area ===== */
.team-scroll {
	max-height: 420px; /* Adjust height as needed */
	overflow-y: auto;
	padding-right: 8px;
}

/* Smooth scrolling */
.team-scroll {
	scroll-behavior: smooth;
}

/* ===== Custom Scrollbar (Chrome, Edge, Safari) ===== */
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

/* ===== Firefox ===== */
.team-scroll {
	scrollbar-width: thin;
	scrollbar-color: #c3cfe2 #e2ebf0;
}
/* ===== Grid Layout ===== */
.employee-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
	gap: 20px;
	margin-top: 15px;
}

/* ===== Employee Card ===== */
.employee-card {
	background: #ffffff;
	border-radius: 12px;
	padding: 10px 18px;
	box-shadow: 0 6px 14px rgba(0, 0, 0, 0.7);
	transition: 0.3s ease;
}

.employee-card:hover {
	transform: translateY(-5px);
}

/* ===== Header ===== */
.emp-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12px;
	border-bottom: 1px dashed #cbd5e0;
	padding-bottom: 8px;
}

.emp-left {
	display: flex;
	align-items: center;
	gap: 4px;
}

.emp-name {
	font-weight: 600;
	color: #2d3748;
}

/* ===== Status Badge ===== */
.emp-status {
	padding: 4px 10px;
	font-size: 12px;
	font-weight: 600;
	border-radius: 20px;
	background-color: #c3cfe2;
	color: #2d3748;
}

/* ===== Body ===== */
.emp-body div {
	margin-bottom: 6px;
	font-size: 14px;
	color: #4a5568;
}

/* ===== No Data ===== */
.no-data {
	text-align: center;
	padding: 20px;
	font-weight: 600;
	color: #4a5568;
}

/* Buttons */
.attendance-buttons {
	margin-top: 20px;
	display: flex;
	gap: 15px;
}

.primary-btn {
	padding: 10px 20px;
	background-color: #5a67d8;
	color: #fff;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	font-weight: 600;
}

.primary-btn:disabled {
	background-color: #a0aec0;
	cursor: not-allowed;
}

.reject-btn {
	padding: 10px 20px;
	background-color: #e53e3e;
	color: #fff;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	font-weight: 600;
}

.reject-btn:disabled {
	background-color: #feb2b2;
	cursor: not-allowed;
}

.primary-btn, .reject-btn {
	padding: 10px 22px;
	border-radius: 22px;
	cursor: pointer;
	font-weight: 500;
	transition: all 0.2s ease;
	border: none;
	margin: 5px;
}

.primary-btn {
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
}

.primary-btn:hover:not(:disabled) {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

.reject-btn {
	background: #e53e3e;
	color: #fff;
}

.reject-btn:hover:not(:disabled) {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(229, 62, 62, 0.35);
}

.primary-btn:disabled, .reject-btn:disabled {
	background: #e5e7eb;
	color: #9ca3af;
	cursor: not-allowed;
	box-shadow: none;
	transform: none;
}

.secondary-btn {
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
	padding: 8px 18px;
	border: none;
	border-radius: 18px;
	cursor: pointer;
	transition: transform 0.2s, box-shadow 0.2s;
}

.secondary-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

.employee-grid {
	width: 100%;
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
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.employee-card:hover {
	transform: translateY(-5px);
	box-shadow: 0 10px 20px rgba(0, 0, 0, 0.20);
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
	padding: 12px;
	border-radius: 10px;
	border: 1px solid #d1d5db;
	margin-bottom: 15px;
	background: rgba(255, 255, 255, 0.8);
}

.attendance-buttons {
	margin-top: 15px;
	display: flex;
	gap: 15px;
}

.attendance-buttons button {
	min-width: 100px;
}

/* calendar */
#calendarSection {
	max-width: 100%;
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
	background: linear-gradient(135deg, #667eea, #764ba2);
	border-radius: 14px;
	padding: 18px;
	border: 1px solid #e5e7eb;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
	transition: transform 0.2s ease, box-shadow 0.2s ease;
	color: white;
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

.join-meeting-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 8px 14px;
	border-radius: 18px;
	background: #2563eb;
	color: #ffffff;
	text-decoration: none;
	font-size: 13px;
	font-weight: 600;
	transition: all 0.2s ease;
}

.join-meeting-btn i {
	font-size: 14px;
}

.join-meeting-btn:hover {
	background: #1d4ed8;
	transform: translateY(-1px);
	box-shadow: 0 6px 14px rgba(37, 99, 235, 0.35);
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
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
	font-size: 14px;
	cursor: pointer;
	min-width: 190px;
	justify-content: center;
	transition: all 0.2s ease;
}

.export-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
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
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: white;
	font-weight: 600;
	cursor: pointer;
}

.export-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

/* ===== Performance Matrix Styling ===== */
#performance {
	width: 100%;
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
	right: 20px;
	background: linear-gradient(135deg, #16a34a, #22c55e);
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

/* ===== Schedule Meeting Grid ===== */
.meeting-grid {
	display: grid;
	grid-template-columns: 1.1fr 0.9fr;
	gap: 10px;
}

/* Left: form */
.meeting-left {
	background: rgba(255, 255, 255, 0.8);
	height: 100%;
	padding: 10px;
	border-radius: 14px;
}

/* Right: meetings list */
.meeting-right {
	background: #ffffff;
	padding: 10px;
	border-radius: 14px;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.05);
	max-height: 430px; /* 👈 controls visible height */
	overflow-y: auto; /* 👈 vertical scroll */
}

/* Optional: smoother scrollbar (Chrome / Edge) */
.meeting-right::-webkit-scrollbar {
	width: 6px;
}

.meeting-right::-webkit-scrollbar-thumb {
	background: #c7d2fe;
	border-radius: 10px;
}

.meeting-right::-webkit-scrollbar-track {
	background: transparent;
}

/* Responsive (mobile friendly) */
@media ( max-width : 900px) {
	.meeting-grid {
		grid-template-columns: 1fr;
	}
}

/* ===== Section Header ===== */
.section-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 15px;
}

/* View All button */
.view-all-btn {
	display: flex;
	align-items: center;
	gap: 6px;
	padding: 8px 16px;
	border-radius: 18px;
	border: none;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #ffffff;
	font-size: 13px;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s ease;
}

.view-all-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

/* Notification Panel (adapted to drawer style) */
.notification-panel {
	position: fixed;
	top: 0;
	right: -340px;
	width: 340px;
	height: 100vh;
	background: linear-gradient(135deg, rgba(255, 255, 255, 0.85),
		rgba(240, 245, 255, 0.75));
	backdrop-filter: blur(16px);
	box-shadow: -8px 0 25px rgba(0, 0, 0, 0.15);
	transition: right 0.4s ease;
	z-index: 1000;
	border-left: 1px solid rgba(255, 255, 255, 0.4);
	border-radius: 0;
}

.notification-panel.show {
	right: 0;
}

.notification-header {
	padding: 20px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: white;
	border-radius: 14px 14px 0 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	height: 70px;
}

.notification-header button {
	background: none;
	border: none;
	color: white;
	font-size: 18px;
	cursor: pointer;
}

.notification-list {
	padding: 15px;
	max-height: calc(100vh - 100px);
	overflow-y: auto;
}

.notification-item {
	background: rgba(99, 102, 241, 0.12);
	padding: 12px;
	margin-bottom: 10px;
	border-left: 4px solid #2563eb;
	border-radius: 4px;
	font-size: 14px;
	color: #2d3748;
}

/* ================= FULL DARK MODE ================= */
body.dark-theme {
	background: #0f172a !important;
	color: #e5e7eb !important;
}

/* Top bar */
body.dark-theme .top-bar {
	background: linear-gradient(135deg, #0f172a, #1e293b, #1e3a8a)
		!important;
	border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
}

/* Sidebar */
body.dark-theme .sidebar {
	background: rgba(30, 41, 59, 0.8) !important;
	border-right: 1px solid rgba(255, 255, 255, 0.1) !important;
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

/* Right panel */
body.dark-theme .content-area {
	background: #0f172a !important;
}

/* All boxes */
body.dark-theme .box {
	background: rgba(30, 41, 59, 0.8) !important;
	color: #e5e7eb !important;
	box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3) !important;
}

/* Cards */
body.dark-theme .employee-card, body.dark-theme .task-card, body.dark-theme .meeting-left,
	body.dark-theme .meeting-right {
	background: rgba(30, 41, 59, 0.8) !important;
	color: #eee !important;
	border-left: 5px solid #60a5fa !important;
}

/* Text inside cards */
body.dark-theme .emp-body, body.dark-theme .tasks-title, body.dark-theme h3,
	body.dark-theme h4, body.dark-theme p, body.dark-theme b, body.dark-theme span,
	body.dark-theme .task-desc {
	color: #eee !important;
}

/* Status badges */
body.dark-theme .emp-status {
	background: #334155 !important;
	color: #ffffff !important;
}

/* Inputs & selects */
body.dark-theme input, body.dark-theme select, body.dark-theme textarea,
	body.dark-theme .form-control {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #ffffff !important;
	border: 1px solid #555 !important;
}

/* Task description */
body.dark-theme .task-desc {
	color: #ffffff !important;
}

/* Notification panel */
body.dark-theme .notification-panel {
	background: linear-gradient(135deg, rgba(30, 41, 59, 0.85),
		rgba(51, 65, 85, 0.75)) !important;
}

body.dark-theme .notification-item {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #ffffff !important;
}

/* performance matrix */
body.dark-theme .radio-group label {
	background: rgba(51, 65, 85, 0.8) !important;
	color: #eee !important;
	border: 1px solid #555 !important;
}

/* Settings drawer */
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
</style>
</head>

<body>

	<div id="overlay" onclick="closeAll()" style="display: none;"></div>

	<!-- SETTINGS -->
	<div id="settingsPanel" class="settings-drawer">
		<div class="modal-header">
			<h4>Settings</h4>
			<span onclick="closeSettings()" style="cursor: pointer;">✕</span>
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

	<!-- TOP BAR -->
	<div class="top-bar">
		<h2>Smart Office • Manager Dashboard</h2>
		<div class="user-area">
			<button class="icon-btn" onclick="openNotifications()">
				<i class="fa-solid fa-bell"></i>
			</button>
			<span class="welcome">Welcome, <strong>${sessionScope.username}</strong></span>
			<button class="settings-btn" onclick="openSettings()">
				<i class="fa-solid fa-gear"></i>
			</button>
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">Logout</button>
			</a>
		</div>
	</div>

	<!-- MAIN -->
	<div class="main-container">
		<div class="sidebar">
			<button class="sidebar-btn active"
				onclick="setActive(this); showSection('selfAttendance')">
				<i class="fa-solid fa-user-check"></i> <span>My Attendance</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); showSection('teamSection')">
				<i class="fa-solid fa-users"></i> <span>My Team</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); showSection('assignTask')">
				<i class="fa-solid fa-list-check"></i> <span>Assign Tasks</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); showSection('schedulemeeting')">
				<i class="fa-solid fa-handshake"></i> <span>Schedule Meetings</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); showSection('attendance')">
				<i class="fa-solid fa-clipboard-user"></i> <span>Team
					Attendance</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); location.href='<%=request.getContextPath()%>/manager?tab=leave'">
				<i class="fa-solid fa-calendar-xmark"></i> <span>Leave
					Requests</span>
			</button>

			<button class="sidebar-btn"
				onclick="setActive(this); showSection('performance')">
				<i class="fa-solid fa-chart-line"></i> <span>Performance
					Matrix</span>
			</button>

			<button class="sidebar-btn" onclick="setActive(this); openCalendar()">
				<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
			</button>
		</div>

		<div class="content-area">
			<div class="box" id="blank" style="display: none;">
				<h3>Welcome 👋</h3>
				<p>Select an option from the left menu to continue.</p>
			</div>

			<!-- ===== My Attendance ===== -->
			<div class="box" id="selfAttendance" style="display: none;">

				<fieldset class="attendance-fieldset">
					<legend>My Attendance</legend>

					<div class="attendance-row">
						<span class="label">Status</span> <span class="value"><%=status%></span>
					</div>

					<div class="attendance-row">
						<span class="label">Punch In</span> <span class="value"><%=punchIn != null ? punchIn : "--"%></span>
					</div>

					<div class="attendance-row">
						<span class="label">Punch Out</span> <span class="value"><%=punchOut != null ? punchOut : "--"%></span>
					</div>

					<div class="attendance-buttons">
						<form action="attendance" method="post">
							<input type="hidden" name="action" value="punchin">
							<button class="primary-btn"
								<%=punchIn != null ? "disabled" : ""%>>Punch In</button>
						</form>

						<form action="attendance" method="post">
							<input type="hidden" name="action" value="punchout">
							<button class="reject-btn"
								<%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
								Punch Out</button>
						</form>
					</div>

				</fieldset>
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

			<div class="box" id="schedulemeeting" style="display: none;">
				<div class="section-header">
					<h3>Schedule Meeting</h3>

					<button class="view-all-btn" onclick="openAllMeetings()">
						<i class="fa-solid fa-eye"></i> View All
					</button>
				</div>

				<!-- GRID WRAPPER -->
				<div class="meeting-grid">

					<!-- LEFT : Schedule Form -->
					<div class="meeting-left">

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

							<button class="primary-btn" type="submit">Schedule
								Meeting</button>
						</form>

					</div>

					<!-- RIGHT : Today's Meetings -->
					<div class="meeting-right">

						<h4>
							<i class="fa-solid fa-calendar-check"></i> Today’s Meetings
						</h4>

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
						<p>No meetings scheduled for today.</p>
						<%
						}
						%>

					</div>

				</div>
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

				<fieldset class="team-fieldset">
					<legend>My Team</legend>

					<!-- Scroll Container -->
					<div class="team-scroll">
						<div class="employee-grid">
							<%
							List<User> team = (List<User>) request.getAttribute("teamList");
							if (team != null && !team.isEmpty()) {
								for (User u : team) {
							%>

							<div class="employee-card">
								<div class="emp-header">
									<div class="emp-left">
										<i class="fa-solid fa-user"></i> <span class="emp-name"><%=u.getFullname()%></span>
									</div>
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
							<p class="no-data">No employees found</p>
							<%
							}
							%>
						</div>
					</div>

				</fieldset>
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
					<h3>View Assigned Tasks</h3>
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
				viewTasks = (List<Task>) request.getAttribute("viewTasks");

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
			<!-- ===== Self Profile ===== -->
			<div class="box centered-box" id="selfProfile" style="display: none;">


				<h3>
					<i class="fa-solid fa-user"></i> My Profile
				</h3>

				<%
				com.smartoffice.model.User profileUser = (com.smartoffice.model.User) request.getAttribute("profileUser");

				if (profileUser != null) {
				%>

				<p>
					<b>Full Name:</b>
					<%=profileUser.getFullname()%></p>
				<p>
					<b>Username:</b>
					<%=profileUser.getUsername()%></p>
				<p>
					<b>Email:</b>
					<%=profileUser.getEmail()%></p>
				<p>
					<b>Role:</b>
					<%=profileUser.getRole()%></p>
				<p>
					<b>Phone:</b>
					<%=profileUser.getPhone()%></p>

				<%
				} else {
				%>
				<p>No profile data found.</p>
				<%
				}
				%>

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

	<script>
    // Apply saved theme before page renders
    if (localStorage.getItem("theme") === "dark") {
        document.body.classList.add("dark-theme");
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

        // ---- Manager login toast ----
        if (success === "Login") {
            const toast = document.createElement("div");
            toast.className = "toast-success";
            toast.innerHTML = `
                <i class="fa-solid fa-circle-check"></i>
                <span>Welcome Logged in successfully</span>
            `;
            document.body.appendChild(toast);

            setTimeout(() => toast.remove(), 4000);
        }

        // ---- Attendance toasts ----
        if (success === "PunchIn") {
            const toast = document.createElement("div");
            toast.className = "toast-success";
            toast.innerHTML = `
                <i class="fa-solid fa-circle-check"></i>
                <span>Punched in successfully</span>
            `;
            document.body.appendChild(toast);
            setTimeout(() => toast.remove(), 4000);
        }

        if (success === "PunchOut") {
            const toast = document.createElement("div");
            toast.className = "toast-success";
            toast.innerHTML = `
                <i class="fa-solid fa-circle-check"></i>
                <span>Punched out successfully</span>
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
            background: "linear-gradient(135deg, #6366f1, #818cf8)",
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
</script>

	<script>
    /* Adapted functions from admin */
    function openSettings(){
        document.getElementById("settingsPanel").classList.add("open");
    }
    function closeSettings(){
        document.getElementById("settingsPanel").classList.remove("open");
    }
    function openProfile(){
        closeSettings();
        showSection("selfProfile");
    }
    function closeProfile(){
        document.getElementById("profileModal").classList.remove("show");
    }
    function openChangePassword(){
        document.getElementById("passwordModal").classList.add("show");
    }
    function closeChangePassword(){
        document.getElementById("passwordModal").classList.remove("show");
    }
    function closeAll(){
        closeSettings();
        closeProfile();
        closeChangePassword();
        closeAllMeetings();
    }
    function submitPassword() {
        const newPassword = document.getElementById("newPassword").value.trim();
        const confirmPassword = document.getElementById("confirmPassword").value.trim();

        if (!newPassword || !confirmPassword) {
            showToast("Please fill all fields ❌");
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
        .then(response => {
            switch (response.trim()) {
                case "Success":
                    showToast("Password updated successfully ✅");
                    closeChangePassword();

                    document.getElementById("newPassword").value = "";
                    document.getElementById("confirmPassword").value = "";
                    break;

                case "PasswordMismatch":
                    showToast("Passwords do not match ❌");
                    break;

                case "MissingFields":
                    showToast("All fields are required ❌");
                    break;

                case "Unauthorized":
                    showToast("Session expired. Please login again ❌");
                    break;

                default:
                    showToast("Something went wrong ❌");
            }
        })
        .catch(err => {
            console.error(err);
            showToast("Server error ❌");
        });
    }

    function showSection(id) {
        document.querySelectorAll('.box').forEach(b => b.style.display = 'none');
        document.getElementById(id).style.display = 'block';
    }

    function toggleTheme() {
        document.body.classList.toggle("dark-theme");

        if (document.body.classList.contains("dark-theme")) {
            localStorage.setItem("theme", "dark");
        } else {
            localStorage.setItem("theme", "light");
        }
    }

    function openCalendar() {
        // hide all sections (same logic as showSection)
        document.querySelectorAll('.box').forEach(b => b.style.display = 'none');

        // show calendar section
        document.getElementById("calendarSection").style.display = "block";

        // load calendar jsp in iframe
        document.getElementById("calendarFrame").src = "<%=request.getContextPath()%>/calendar.jsp";
    }

    function openNotifications() {
        document.getElementById("notificationPanel").classList.add("show");
    }

    function closeNotifications() {
        document.getElementById("notificationPanel").classList.remove("show");
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

    function setActive(button) {
        // remove active from all buttons
        document.querySelectorAll('.sidebar-btn')
            .forEach(btn => btn.classList.remove('active'));

        // add active to clicked button
        button.classList.add('active');
    }
</script>

</body>
</html>