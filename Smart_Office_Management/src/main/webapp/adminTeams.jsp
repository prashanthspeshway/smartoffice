<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>

<%
String successMsg = (String) session.getAttribute("teamsSuccess");
String errorMsg = (String) session.getAttribute("teamsError");
session.removeAttribute("teamsSuccess");
session.removeAttribute("teamsError");

List<Team> teams = (List<Team>) request.getAttribute("teams");
List<User> managers = (List<User>) request.getAttribute("managers");
List<User> employees = (List<User>) request.getAttribute("employees");
if (teams == null)
	teams = new java.util.ArrayList<>();
if (managers == null)
	managers = new java.util.ArrayList<>();
if (employees == null)
	employees = new java.util.ArrayList<>();
Set<String> assignedUsernames = (Set<String>) request.getAttribute("assignedUsernames");
if (assignedUsernames == null)
	assignedUsernames = new java.util.HashSet<>();
int totalMembers = 0;
for (Team t : teams) {
	totalMembers += t.getMembers().size();
}
int availableCount = 0;
for (User e : employees) {
	if (!assignedUsernames.contains(e.getEmail()))
		availableCount++;
}

String safeSuccess = (successMsg != null)
		? successMsg.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;")
		: "";
String safeError = (errorMsg != null)
		? errorMsg.replace("&", "&amp;").replace("\"", "&quot;").replace("'", "&#39;")
		: "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Teams • Smart Office HRMS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
:root {
	--bg: #f4f6fb;
	--surface: #ffffff;
	--surface2: #f8f9fc;
	--border: #e8ecf4;
	--border2: #d4daea;
	--text: #1a1d2e;
	--text2: #5a6278;
	--text3: #8d96b0;
	--accent: #4f6ef7;
	--accent-light: #eef1fe;
	--accent-hover: #3a58e8;
	--success: #22c55e;
	--success-light: #f0fdf4;
	--danger: #ef4444;
	--danger-light: #fef2f2;
	--warning: #f59e0b;
	--warning-light: #fffbeb;
	--shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px
		rgba(0, 0, 0, 0.04);
	--shadow: 0 4px 16px rgba(0, 0, 0, 0.07), 0 1px 4px rgba(0, 0, 0, 0.04);
	--shadow-lg: 0 20px 50px rgba(0, 0, 0, 0.12);
	--radius: 14px;
	--radius-sm: 8px;
	--radius-full: 9999px;
}

*, *::before, *::after {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

body {
	font-family: 'Geist', system-ui, sans-serif;
	background: var(--bg);
	color: var(--text);
	min-height: 100vh;
	line-height: 1.6;
}

/* ── Page wrapper ── */
.page {
	max-width: 1100px;
	margin: 0 auto;
	padding: 36px 24px;
}

/* ── Header ── */
.page-header {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 16px;
	margin-bottom: 32px;
	flex-wrap: wrap;
}

.page-title {
	font-family: 'Geist', system-ui, sans-serif;
	font-size: 28px;
	font-weight: 600;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 10px;
	line-height: 1.2;
}

.page-title i {
	color: var(--accent);
	font-size: 22px;
}

.page-subtitle {
	color: var(--text3);
	font-size: 14px;
	margin-top: 4px;
}

/* ── Stat cards ── */
.stats-row {
	display: flex;
	gap: 16px;
	margin-bottom: 32px;
	flex-wrap: wrap;
}

.stat-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 20px 24px;
	box-shadow: var(--shadow-sm);
	flex: 1;
	min-width: 130px;
	display: flex;
	align-items: center;
	gap: 14px;
	transition: box-shadow 0.2s, transform 0.2s;
}

.stat-card:hover {
	box-shadow: var(--shadow);
	transform: translateY(-1px);
}

.stat-icon {
	width: 44px;
	height: 44px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	flex-shrink: 0;
}

.stat-icon.blue {
	background: var(--accent-light);
	color: var(--accent);
}

.stat-icon.green {
	background: var(--success-light);
	color: var(--success);
}

.stat-icon.amber {
	background: var(--warning-light);
	color: var(--warning);
}

.stat-num {
	font-size: 26px;
	font-weight: 700;
	color: var(--text);
	line-height: 1;
}

.stat-label {
	font-size: 12px;
	color: var(--text3);
	font-weight: 500;
	text-transform: uppercase;
	letter-spacing: 0.6px;
	margin-top: 3px;
}

/* ── Two-column grid ── */
.top-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	margin-bottom: 32px;
}

@media ( max-width : 768px) {
	.top-grid {
		grid-template-columns: 1fr;
	}
}

/* ── Card ── */
.card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 24px;
	box-shadow: var(--shadow-sm);
}

.card-title {
	font-size: 15px;
	font-weight: 600;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 20px;
}

.card-title i {
	color: var(--accent);
}

/* ── Form controls ── */
.field {
	margin-bottom: 16px;
}

.field label {
	display: block;
	font-size: 13px;
	font-weight: 600;
	color: var(--text2);
	margin-bottom: 6px;
}

.field input, .field select {
	width: 100%;
	padding: 10px 14px;
	border: 1.5px solid var(--border2);
	border-radius: var(--radius-sm);
	font-size: 14px;
	font-family: inherit;
	color: var(--text);
	background: var(--surface);
	transition: border-color 0.15s, box-shadow 0.15s;
	outline: none;
}

.field input:focus, .field select:focus {
	border-color: var(--accent);
	box-shadow: 0 0 0 3px rgba(79, 110, 247, 0.1);
}

.field input::placeholder {
	color: var(--text3);
}

/* ── Buttons ── */
.btn {
	display: inline-flex;
	align-items: center;
	gap: 7px;
	padding: 10px 18px;
	border-radius: var(--radius-sm);
	font-size: 13px;
	font-weight: 600;
	font-family: inherit;
	cursor: pointer;
	border: none;
	transition: all 0.15s;
	text-decoration: none;
}

.btn-primary {
	background: var(--accent);
	color: #fff;
}

.btn-primary:hover {
	background: var(--accent-hover);
	transform: translateY(-1px);
	box-shadow: 0 4px 12px rgba(79, 110, 247, 0.3);
}

.btn-danger {
	background: var(--danger);
	color: #fff;
}

.btn-danger:hover {
	background: #dc2626;
	transform: translateY(-1px);
	box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-ghost {
	background: var(--surface2);
	color: var(--text2);
	border: 1px solid var(--border2);
}

.btn-ghost:hover {
	background: var(--border);
}

/* ── Employee list ── */
.employee-box {
	border: 1.5px solid var(--border);
	border-radius: var(--radius-sm);
	overflow: hidden;
	background: var(--surface2);
}

.employee-box-head {
	padding: 10px 14px;
	font-size: 12px;
	font-weight: 600;
	color: var(--text2);
	background: var(--surface);
	border-bottom: 1px solid var(--border);
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.employee-search-wrap {
	padding: 10px;
	background: var(--surface);
	border-bottom: 1px solid var(--border);
	position: relative;
}

.employee-search-wrap i {
	position: absolute;
	left: 20px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text3);
	font-size: 13px;
}

.employee-search {
	width: 100%;
	padding: 8px 12px 8px 32px;
	border: 1.5px solid var(--border2);
	border-radius: var(--radius-sm);
	font-size: 13px;
	font-family: inherit;
	color: var(--text);
	background: var(--bg);
	outline: none;
	transition: border-color 0.15s;
}

.employee-search:focus {
	border-color: var(--accent);
}

.employee-list {
	max-height: 210px;
	overflow-y: auto;
	padding: 8px;
}

.employee-list::-webkit-scrollbar {
	width: 4px;
}

.employee-list::-webkit-scrollbar-track {
	background: transparent;
}

.employee-list::-webkit-scrollbar-thumb {
	background: var(--border2);
	border-radius: 99px;
}

.employee-item {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 9px 10px;
	border-radius: 8px;
	cursor: pointer;
	transition: background 0.12s;
	font-size: 13px;
	font-weight: 500;
	color: var(--text);
}

.employee-item:hover:not(.assigned) {
	background: var(--accent-light);
}

.employee-item.assigned {
	opacity: 0.45;
	cursor: not-allowed;
}

.employee-item input[type="checkbox"] {
	width: 15px;
	height: 15px;
	accent-color: var(--accent);
	flex-shrink: 0;
}

.assigned-tag {
	font-size: 11px;
	color: var(--text3);
	font-weight: 400;
	margin-left: 4px;
}

/* ── Add member row ── */
.add-member-row {
	display: flex;
	gap: 10px;
	align-items: flex-end;
	margin-bottom: 14px;
}

.add-member-row .field {
	flex: 1;
	margin-bottom: 0;
}

/* ── Teams section ── */
.section-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
}

.section-title {
	font-family: 'Geist', system-ui, sans-serif;
	font-size: 20px;
	font-weight: 600;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 8px;
}

.section-title i {
	color: var(--accent);
	font-size: 17px;
}

/* ── Teams grid: stretch = equal-height cards per row ── */
.teams-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
	gap: 18px;
	align-items: stretch;
}

/* ── Team card ── */
.team-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	overflow: hidden;
	box-shadow: var(--shadow-sm);
	transition: box-shadow 0.2s, transform 0.2s;
	display: flex;
	flex-direction: column;
	height: 100%;
	min-height: 0;
}

.team-card:hover {
	box-shadow: var(--shadow);
	transform: translateY(-2px);
}

.team-card-top {
	padding: 18px 20px 14px;
	border-bottom: 1px solid var(--border);
	background: linear-gradient(135deg, var(--accent-light) 0%, #f0f4ff 100%);
}

.team-card-name {
	font-size: 16px;
	font-weight: 700;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 10px;
}

.team-card-name i {
	color: var(--accent);
}

.manager-select-wrap {
	position: relative;
}

.manager-select-wrap::after {
	content: '\f107';
	font-family: 'Font Awesome 6 Free';
	font-weight: 900;
	position: absolute;
	right: 10px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text3);
	pointer-events: none;
	font-size: 12px;
}

.manager-select {
	width: 100%;
	padding: 7px 30px 7px 10px;
	border: 1.5px solid var(--border2);
	border-radius: var(--radius-sm);
	font-size: 12px;
	font-family: inherit;
	color: var(--text2);
	background: var(--surface);
	outline: none;
	cursor: pointer;
	appearance: none;
	transition: border-color 0.15s;
}

.manager-select:focus {
	border-color: var(--accent);
}

.team-card-body {
	padding: 16px 20px;
	flex: 1 1 auto;
	min-height: 0;
	display: flex;
	flex-direction: column;
}

.members-label {
	font-size: 11px;
	font-weight: 700;
	color: var(--text3);
	text-transform: uppercase;
	letter-spacing: 0.6px;
	margin-bottom: 10px;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.member-count-badge {
	background: var(--accent-light);
	color: var(--accent);
	font-size: 11px;
	font-weight: 700;
	padding: 2px 8px;
	border-radius: var(--radius-full);
}

.members-chips {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 6px;
	flex: 1 1 auto;
	min-height: 0;
	align-content: start;
}

.member-chip {
	display: flex;
	align-items: center;
	gap: 6px;
	background: var(--surface2);
	border: 1px solid var(--border);
	border-radius: 8px;
	padding: 6px 8px;
	font-size: 12px;
	font-weight: 500;
	color: var(--text);
	min-width: 0;
	overflow: hidden;
}

.member-chip-name {
	flex: 1;
	min-width: 0;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	font-size: 12px;
	font-weight: 500;
	color: var(--text);
}

.member-chip-avatar {
	width: 22px;
	height: 22px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--accent), #818cf8);
	color: #fff;
	font-size: 9px;
	font-weight: 700;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.member-remove {
	background: none;
	border: none;
	cursor: pointer;
	color: var(--text3);
	font-size: 12px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	min-width: 28px;
	min-height: 28px;
	padding: 0;
	flex-shrink: 0;
	transition: color 0.15s, background 0.15s;
	border-radius: 6px;
}

.member-remove:hover {
	color: var(--danger);
	background: var(--danger-light);
}

.no-members {
	font-size: 13px;
	color: var(--text3);
	font-style: italic;
}

.member-chip-more {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 5px;
	background: var(--accent-light);
	border: 1.5px solid var(--accent);
	border-radius: 8px;
	padding: 6px 8px;
	font-size: 11px;
	font-weight: 700;
	color: var(--accent);
	cursor: pointer;
	transition: background 0.15s, transform 0.15s;
	white-space: nowrap;
	min-width: 0;
}

.member-chip-more:hover {
	background: #dde5fd;
	transform: translateY(-1px);
}

.team-card-footer {
	padding: 12px 20px;
	border-top: 1px solid var(--border);
	background: var(--surface2);
	margin-top: auto;
	flex-shrink: 0;
}

.team-card-footer .btn {
	width: 100%;
	justify-content: center;
	box-sizing: border-box;
}

/* ── Empty state ── */
.empty-state {
	text-align: center;
	padding: 60px 20px;
	color: var(--text3);
}

.empty-state i {
	font-size: 48px;
	opacity: 0.25;
	display: block;
	margin-bottom: 16px;
}

.empty-state h3 {
	font-size: 16px;
	font-weight: 600;
	color: var(--text2);
	margin-bottom: 6px;
}

.empty-state p {
	font-size: 13px;
}

/* ── Toast ── */
.toast {
	position: fixed;
	bottom: 24px;
	right: 20px;
	top: auto;
	padding: 13px 18px;
	border-radius: 10px;
	z-index: 9999;
	display: none;
	font-size: 14px;
	font-weight: 500;
	box-shadow: var(--shadow-lg);
	animation: slideIn 0.25s ease;
	max-width: 340px;
}

@
keyframes slideIn {from { transform:translateX(110%);
	opacity: 0;
}

to {
	transform: translateX(0);
	opacity: 1;
}

}
.toast.success {
	background: #166534;
	color: #fff;
}

.toast.error {
	background: #991b1b;
	color: #fff;
}

/* ── Modal ── */
.modal-overlay {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(15, 20, 40, 0.5);
	backdrop-filter: blur(4px);
	z-index: 9998;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.modal-overlay.show {
	display: flex;
}

/* Stacked above “all members” modal when both open */
.modal-overlay--high {
	z-index: 10050;
}

.modal-box {
	background: var(--surface);
	border-radius: 20px;
	box-shadow: var(--shadow-lg);
	max-width: 400px;
	width: 100%;
	padding: 32px 28px;
	text-align: center;
	animation: modalIn 0.2s ease;
}

@
keyframes modalIn {from { transform:scale(0.93);
	opacity: 0;
}

to {
	transform: scale(1);
	opacity: 1;
}

}
.modal-icon {
	width: 60px;
	height: 60px;
	border-radius: 50%;
	background: var(--danger-light);
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 auto 18px;
}

.modal-icon i {
	font-size: 24px;
	color: var(--danger);
}

.modal-title {
	font-size: 18px;
	font-weight: 700;
	color: var(--text);
	margin-bottom: 8px;
}

.modal-subtitle {
	font-size: 14px;
	color: var(--text2);
	margin-bottom: 6px;
}

.modal-teamname {
	font-size: 15px;
	font-weight: 700;
	color: var(--text);
	margin-bottom: 8px;
}

.modal-warning {
	font-size: 12px;
	color: var(--text3);
	margin-bottom: 24px;
}

.modal-actions {
	display: flex;
	gap: 12px;
	justify-content: center;
}

/* ── Animations ── */
@
keyframes fadeUp {from { opacity:0;
	transform: translateY(12px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.anim {
	animation: fadeUp 0.4s ease both;
}

.anim-1 {
	animation-delay: 0.05s;
}

.anim-2 {
	animation-delay: 0.1s;
}

.anim-3 {
	animation-delay: 0.15s;
}

.anim-4 {
	animation-delay: 0.2s;
}

/* ── Searchable Dropdown ── */
.dropdown-wrap {
	position: relative;
	width: 100%;
}

.dropdown-trigger {
	width: 100%;
	padding: 10px 36px 10px 14px;
	border: 1.5px solid var(--border2);
	border-radius: var(--radius-sm);
	font-size: 14px;
	font-family: inherit;
	color: var(--text);
	background: var(--surface);
	cursor: pointer;
	text-align: left;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;
	transition: border-color 0.15s, box-shadow 0.15s;
	outline: none;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.dropdown-trigger:focus, .dropdown-trigger.open {
	border-color: var(--accent);
	box-shadow: 0 0 0 3px rgba(79, 110, 247, 0.1);
}

.dropdown-trigger .dt-text {
	flex: 1;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
	color: var(--text);
}

.dropdown-trigger .dt-text.placeholder {
	color: var(--text3);
}

.dropdown-trigger .dt-arrow {
	flex-shrink: 0;
	font-size: 11px;
	color: var(--text3);
	transition: transform 0.2s;
}

.dropdown-trigger.open .dt-arrow {
	transform: rotate(180deg);
}

.dropdown-panel {
	display: none;
	position: absolute;
	top: calc(100% + 4px);
	left: 0;
	right: 0;
	background: var(--surface);
	border: 1.5px solid var(--border2);
	border-radius: var(--radius-sm);
	box-shadow: var(--shadow-lg);
	z-index: 1000;
	overflow: hidden;
	animation: dropIn 0.15s ease;
}

@
keyframes dropIn {from { opacity:0;
	transform: translateY(-6px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.dropdown-panel.open {
	display: block;
}

.dropdown-search-wrap {
	padding: 8px 8px 8px 8px;
	border-bottom: 1px solid var(--border);
	position: relative;
	background: var(--surface);
}

.dropdown-search-wrap i {
	position: absolute;
	left: 15px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text3);
	font-size: 12px;
	pointer-events: none;
	z-index: 1;
}

.dropdown-search {
	width: 100%;
	padding: 8px 10px 8px 24px;
	border: 1.5px solid var(--border2);
	border-radius: 6px;
	font-size: 13px;
	font-family: inherit;
	color: var(--text);
	background: var(--surface);
	outline: none;
	transition: border-color 0.15s;
	position: relative;
}

.dropdown-search:focus {
	border-color: var(--accent);
}

.dropdown-options {
	max-height: 200px; /* shows ~5 items then scrolls */
	overflow-y: auto;
	padding: 4px;
}

.dropdown-options::-webkit-scrollbar {
	width: 4px;
}

.dropdown-options::-webkit-scrollbar-track {
	background: transparent;
}

.dropdown-options::-webkit-scrollbar-thumb {
	background: var(--border2);
	border-radius: 99px;
}

.dropdown-option {
	padding: 9px 12px;
	border-radius: 6px;
	font-size: 13px;
	font-weight: 500;
	color: var(--text2);
	cursor: pointer;
	transition: background 0.1s, color 0.1s;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.dropdown-option:hover {
	background: var(--accent-light);
	color: var(--accent);
}

.dropdown-option.selected {
	background: var(--accent-light);
	color: var(--accent);
	font-weight: 600;
}

.dropdown-option.hidden {
	display: none;
}

.dropdown-no-results {
	padding: 12px;
	text-align: center;
	font-size: 12px;
	color: var(--text3);
	display: none;
}

/* Hidden real select (keeps form working) */
.dropdown-hidden-select {
	display: none;
}

/* ── Responsive (Teams page + modals) ── */
@media ( max-width : 768px) {
	.page {
		padding: 20px 14px;
		max-width: 100%;
	}
	.page-title {
		font-size: 22px;
	}
	.stats-row .stat-card {
		min-width: calc(50% - 8px);
		flex: 1 1 140px;
	}
	.teams-grid {
		grid-template-columns: 1fr;
	}
	.members-chips {
		grid-template-columns: 1fr;
	}
	.add-member-row {
		flex-direction: column;
		align-items: stretch;
	}
	.add-member-row .btn {
		width: 100%;
		justify-content: center;
	}
	.toast {
		left: 12px;
		right: 12px;
		max-width: none;
	}
	.modal-overlay {
		padding: 12px;
		align-items: center;
	}
	.modal-box {
		max-width: 100% !important;
		width: 100%;
		border-radius: 16px 16px 0 0;
		max-height: 92vh;
		overflow-y: auto;
	}
	#membersModal .modal-box {
		border-radius: 16px;
		max-height: min(92vh, 640px);
	}
}

@media ( max-width : 480px) {
	.page-header {
		margin-bottom: 20px;
	}
	.stat-num {
		font-size: 22px;
	}
}

/* Members modal row + remove */
.member-modal-row {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 10px 12px;
	background: var(--surface2);
	border: 1px solid var(--border);
	border-radius: 10px;
	min-width: 0;
}
.member-modal-row .member-modal-info {
	flex: 1;
	min-width: 0;
}
.member-modal-remove {
	background: none;
	border: none;
	cursor: pointer;
	color: var(--text3);
	width: 32px;
	height: 32px;
	border-radius: 8px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	transition: color 0.15s, background 0.15s;
}
.member-modal-remove:hover {
	color: var(--danger);
	background: var(--danger-light);
}
</style>
</head>
<body>

	<div id="toast" class="toast" data-success="<%=safeSuccess%>"
		data-error="<%=safeError%>"></div>

	<div class="page">

		<!-- Header -->
		<div class="page-header anim">
			<div>
				<div class="page-title">
					<i class="fa-solid fa-people-group"></i> Team Management
				</div>
				<p class="page-subtitle">Create teams, assign managers, and
					organise your workforce</p>
			</div>
		</div>

		<!-- Stats -->
		<div class="stats-row">
			<div class="stat-card anim anim-1">
				<div class="stat-icon blue">
					<i class="fa-solid fa-layer-group"></i>
				</div>
				<div>
					<div class="stat-num"><%=teams.size()%></div>
					<div class="stat-label">Teams</div>
				</div>
			</div>
			<div class="stat-card anim anim-2">
				<div class="stat-icon green">
					<i class="fa-solid fa-users"></i>
				</div>
				<div>
					<div class="stat-num"><%=totalMembers%></div>
					<div class="stat-label">Members</div>
				</div>
			</div>
			<div class="stat-card anim anim-3">
				<div class="stat-icon amber">
					<i class="fa-solid fa-user-check"></i>
				</div>
				<div>
					<div class="stat-num"><%=availableCount%></div>
					<div class="stat-label">Available</div>
				</div>
			</div>
		</div>

		<!-- Create Team + Add Members -->
		<div class="top-grid">

			<!-- Create Team -->
			<div class="card anim anim-2">
				<div class="card-title">
					<i class="fa-solid fa-circle-plus"></i> Create New Team
				</div>
				<form action="<%=request.getContextPath()%>/teams" method="post">
					<input type="hidden" name="action" value="create">
					<div class="field">
						<label>Team Name</label> <input type="text" name="teamName"
							required placeholder="e.g. Development Team">
					</div>
					<div class="field">
						<label>Assign Manager</label> <select name="managerUsername"
							required class="dropdown-hidden-select" id="createManagerSel">
							<option value="">Select Manager</option>
							<%
							for (User m : managers) {
							%>
							<option value="<%=m.getEmail()%>"><%=m.getFullname() != null ? m.getFullname() : m.getEmail()%></option>
							<%
							}
							%>
						</select>
						<div class="dropdown-wrap" data-for="createManagerSel">
							<button type="button" class="dropdown-trigger" tabindex="0">
								<span class="dt-text placeholder">Select Manager</span> <i
									class="fa-solid fa-chevron-down dt-arrow"></i>
							</button>
							<div class="dropdown-panel">
								<div class="dropdown-search-wrap">
									<i class="fa-solid fa-search"></i> <input type="text"
										class="dropdown-search" placeholder="Search manager…">
								</div>
								<div class="dropdown-options">
									<div class="dropdown-option" data-value="">Select Manager</div>
									<%
									for (User m : managers) {
										String mn = m.getFullname() != null ? m.getFullname() : m.getEmail();
									%>
									<div class="dropdown-option" data-value="<%=m.getEmail()%>"><%=mn%></div>
									<%
									}
									%>
								</div>
								<div class="dropdown-no-results">No results found</div>
							</div>
						</div>
					</div>
					<button type="submit" class="btn btn-primary">
						<i class="fa-solid fa-plus"></i> Create Team
					</button>
				</form>
			</div>

			<!-- Add Members -->
			<div class="card anim anim-3">
				<div class="card-title">
					<i class="fa-solid fa-user-plus"></i> Add Employees to Team
				</div>
				<form id="addMemberForm"
					action="<%=request.getContextPath()%>/teams" method="post">
					<input type="hidden" name="action" value="addMember">
					<div class="add-member-row">
						<div class="field">
							<label>Select Team</label> <select name="teamId" id="teamSelect"
								required class="dropdown-hidden-select">
								<option value="">Choose a team…</option>
								<%
								for (Team t : teams) {
								%>
								<option value="<%=t.getId()%>"><%=t.getName()%></option>
								<%
								}
								%>
							</select>
							<div class="dropdown-wrap" data-for="teamSelect">
								<button type="button" class="dropdown-trigger" tabindex="0">
									<span class="dt-text placeholder">Choose a team…</span> <i
										class="fa-solid fa-chevron-down dt-arrow"></i>
								</button>
								<div class="dropdown-panel">
									<div class="dropdown-search-wrap">
										<i class="fa-solid fa-search"></i> <input type="text"
											class="dropdown-search" placeholder="Search team…">
									</div>
									<div class="dropdown-options">
										<div class="dropdown-option" data-value="">Choose a
											team…</div>
										<%
										for (Team t : teams) {
										%>
										<div class="dropdown-option" data-value="<%=t.getId()%>"><%=t.getName()%></div>
										<%
										}
										%>
									</div>
									<div class="dropdown-no-results">No results found</div>
								</div>
							</div>
						</div>
						<button type="submit" class="btn btn-primary"
							style="margin-bottom: 0; white-space: nowrap;">
							<i class="fa-solid fa-arrow-right"></i> Add
						</button>
					</div>

					<div class="employee-box">
						<div class="employee-box-head">
							Select Employees <span
								style="font-weight: 400; text-transform: none; letter-spacing: 0; color: var(--text3)">(faded
								= already assigned)</span>
						</div>
						<div class="employee-search-wrap">
							<i class="fa-solid fa-search"></i> <input type="text"
								id="employeeSearch" class="employee-search"
								placeholder="Search by name or email…" autocomplete="off">
						</div>
						<div class="employee-list" id="employeeCheckboxList">
							<%
							for (User e : employees) {
								boolean assigned = assignedUsernames.contains(e.getEmail());
								String displayName = e.getFullname() != null ? e.getFullname() : e.getEmail();
								String searchText = (displayName + " " + e.getEmail()).toLowerCase();
							%>
							<label class="employee-item <%=assigned ? "assigned" : ""%>"
								data-search="<%=searchText.replace("\"", "&quot;")%>"> <input
								type="checkbox" name="username" value="<%=e.getEmail()%>"
								<%=assigned ? "disabled" : ""%>> <span><%=displayName%>
									<%
									if (assigned) {
									%><span class="assigned-tag">(assigned)</span> <%
 }
 %></span>
							</label>
							<%
							}
							%>
							<p id="employeeNoResults"
								style="display: none; padding: 16px; text-align: center; font-size: 13px; color: var(--text3);">No
								matches found</p>
							<%
							if (employees.isEmpty()) {
							%>
							<p
								style="padding: 16px; text-align: center; font-size: 13px; color: var(--text3);">No
								employees available</p>
							<%
							}
							%>
						</div>
					</div>
				</form>
			</div>
		</div>

		<!-- All Teams -->
		<div class="card anim anim-4">
			<div class="section-header">
				<div class="section-title">
					<i class="fa-solid fa-layer-group"></i> All Teams
				</div>
				<span
					style="font-size: 13px; color: var(--text3); font-weight: 500;"><%=teams.size()%>
					team<%=teams.size() != 1 ? "s" : ""%></span>
			</div>

			<%
			if (teams.isEmpty()) {
			%>
			<div class="empty-state">
				<i class="fa-solid fa-people-group"></i>
				<h3>No teams yet</h3>
				<p>Create your first team using the form above</p>
			</div>
			<%
			} else {
			%>
			<div class="teams-grid">
				<%
				for (Team t : teams) {
				%>
				<div class="team-card">

					<!-- Top band -->
					<div class="team-card-top">
						<div class="team-card-name">
							<i class="fa-solid fa-users"></i>
							<%=t.getName()%></div>
						<%
						String currentMgrName = "";
						for (User m : managers) {
							if (m.getEmail().equals(t.getManagerUsername())) {
								currentMgrName = m.getFullname() != null ? m.getFullname() : m.getEmail();
								break;
							}
						}
						String cardDropId = "mgr_" + t.getId();
						%>
						<form action="<%=request.getContextPath()%>/teams" method="post"
							style="display: inline;" id="mgrForm_<%=t.getId()%>">
							<input type="hidden" name="action" value="updateManager">
							<input type="hidden" name="teamId" value="<%=t.getId()%>">
							<select name="managerUsername" class="dropdown-hidden-select"
								id="<%=cardDropId%>">
								<%
								for (User m : managers) {
								%>
								<option value="<%=m.getEmail()%>"
									<%=m.getEmail().equals(t.getManagerUsername()) ? "selected" : ""%>>
									<%=m.getFullname() != null ? m.getFullname() : m.getEmail()%>
								</option>
								<%
								}
								%>
							</select>
							<div class="dropdown-wrap" data-for="<%=cardDropId%>"
								data-autosubmit="mgrForm_<%=t.getId()%>">
								<button type="button" class="dropdown-trigger"
									style="font-size: 12px; padding: 7px 30px 7px 10px;"
									tabindex="0">
									<span
										class="dt-text <%=currentMgrName.isEmpty() ? "placeholder" : ""%>"><%=currentMgrName.isEmpty() ? "Select Manager" : currentMgrName%></span>
									<i class="fa-solid fa-chevron-down dt-arrow"></i>
								</button>
								<div class="dropdown-panel">
									<div class="dropdown-search-wrap">
										<i class="fa-solid fa-search"></i> <input type="text"
											class="dropdown-search" placeholder="Search manager…">
									</div>
									<div class="dropdown-options">
										<%
										for (User m : managers) {
											String mn = m.getFullname() != null ? m.getFullname() : m.getEmail();
											boolean isCurrent = m.getEmail().equals(t.getManagerUsername());
										%>
										<div class="dropdown-option <%=isCurrent ? "selected" : ""%>"
											data-value="<%=m.getEmail()%>"><%=mn%></div>
										<%
										}
										%>
									</div>
									<div class="dropdown-no-results">No results found</div>
								</div>
							</div>
						</form>
					</div>

					<!-- Body -->
					<%
					int MAX_VISIBLE = 5;
					java.util.List<User> members = t.getMembers();
					StringBuilder membersJson = new StringBuilder("[");
					for (int mi2 = 0; mi2 < members.size(); mi2++) {
						User mem2 = members.get(mi2);
						String mn2 = mem2.getFullname() != null ? mem2.getFullname() : mem2.getEmail();
						String em2 = mem2.getEmail() != null ? mem2.getEmail() : "";
						String[] mp2 = mn2.trim().split("\\s+");
						String av2 = mp2.length >= 2
						? ("" + mp2[0].charAt(0) + mp2[mp2.length - 1].charAt(0)).toUpperCase()
						: mn2.length() >= 2 ? mn2.substring(0, 2).toUpperCase() : mn2.toUpperCase();
						membersJson.append("{").append("\"name\":\"").append(mn2.replace("\\", "\\\\").replace("\"", "\\\"")).append("\",")
						.append("\"email\":\"").append(em2.replace("\\", "\\\\").replace("\"", "\\\"")).append("\",")
						.append("\"initials\":\"").append(av2).append("\"").append("}");
						if (mi2 < members.size() - 1)
							membersJson.append(",");
					}
					membersJson.append("]");
					%>
					<div class="team-card-body">
						<div class="members-label">
							Members <span class="member-count-badge"><%=members.size()%></span>
						</div>
						<div class="members-chips">
							<%
							if (members.isEmpty()) {
							%>
							<div
								style="grid-column: 1/-1; font-size: 13px; color: var(--text3); font-style: italic;">No
								members yet</div>
							<%
							} else {
							int showCount = Math.min(MAX_VISIBLE, members.size());
							for (int mi3 = 0; mi3 < showCount; mi3++) {
								User mem = members.get(mi3);
								String mn = mem.getFullname() != null ? mem.getFullname() : mem.getEmail();
								String[] mp = mn.trim().split("\\s+");
								String mi = mp.length >= 2
								? ("" + mp[0].charAt(0) + mp[mp.length - 1].charAt(0)).toUpperCase()
								: mn.length() >= 2 ? mn.substring(0, 2).toUpperCase() : mn.toUpperCase();
							%>
							<span class="member-chip"> <span
								class="member-chip-avatar"><%=mi%></span> <span
								class="member-chip-name" title="<%=mn%>"><%=mn%></span>
								<button type="button" class="member-remove" title="Remove from team"
									data-team-id="<%=t.getId()%>"
									data-team-name="<%=t.getName().replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;")%>"
									data-member-name="<%=mn.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;")%>"
									data-username="<%=mem.getEmail().replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;")%>"
									onclick="openRemoveMemberModalFromChip(this)">
										<i class="fa-solid fa-xmark"></i>
								</button>
							</span>
							<%
							}
							%>

							<%
							if (members.size() > MAX_VISIBLE) {
							%>
							<button type="button" class="member-chip-more"
								onclick='openMembersModal(<%=t.getId()%>, "<%=t.getName().replace("\"", "\\\"")%>", <%=membersJson%>)'>
								+<%=members.size() - MAX_VISIBLE%>
								more <i class="fa-solid fa-arrow-up-right-from-square"
									style="font-size: 9px;"></i>
							</button>
							<%
							}
							%>
							<%
							}
							%>
						</div>
					</div>

					<!-- Footer -->
					<div class="team-card-footer">
						<button type="button"
							onclick="openDeleteModal('<%=t.getId()%>', '<%=t.getName().replace("'", "\\'")%>')"
							class="btn btn-danger"
							style="font-size: 12px; padding: 8px 14px;">
							<i class="fa-solid fa-trash"></i> Delete Team
						</button>
					</div>
				</div>
				<%
				}
				%>
			</div>
			<%
			}
			%>
		</div>
	</div>

	<!-- Delete Modal -->
	<div id="deleteTeamModal" class="modal-overlay"
		onclick="if(event.target===this)closeDeleteModal()">
		<div class="modal-box" onclick="event.stopPropagation()">
			<div class="modal-icon">
				<i class="fa-solid fa-trash"></i>
			</div>
			<div class="modal-title">Delete Team</div>
			<p class="modal-subtitle">You are about to delete</p>
			<p class="modal-teamname" id="deleteTeamName"></p>
			<p class="modal-warning">This action is permanent. All members
				will be unassigned from this team.</p>
			<div class="modal-actions">
				<button type="button" onclick="closeDeleteModal()"
					class="btn btn-ghost">Cancel</button>
				<form id="deleteTeamForm"
					action="<%=request.getContextPath()%>/teams" method="post"
					style="display: inline;">
					<input type="hidden" name="action" value="delete"> <input
						type="hidden" name="teamId" id="deleteTeamId">
					<button type="submit" class="btn btn-danger">
						<i class="fa-solid fa-trash"></i> Yes, Delete
					</button>
				</form>
			</div>
		</div>
	</div>

	<!-- Remove member (same style as Delete Team) -->
	<div id="removeMemberModal" class="modal-overlay modal-overlay--high"
		onclick="if(event.target===this)closeRemoveMemberModal()">
		<div class="modal-box" onclick="event.stopPropagation()">
			<div class="modal-icon">
				<i class="fa-solid fa-user-minus"></i>
			</div>
			<div class="modal-title">Remove from Team</div>
			<p class="modal-subtitle">You are about to remove</p>
			<p class="modal-teamname" id="removeMemberDisplayName"></p>
			<p class="modal-subtitle" id="removeMemberTeamLabel" style="margin-top: 4px; margin-bottom: 6px;"></p>
			<p class="modal-warning" id="removeMemberExtraLine"></p>
			<div class="modal-actions">
				<button type="button" onclick="closeRemoveMemberModal()"
					class="btn btn-ghost">Cancel</button>
				<form id="removeMemberForm"
					action="<%=request.getContextPath()%>/teams" method="post"
					style="display: inline;">
					<input type="hidden" name="action" value="removeMember">
					<input type="hidden" name="teamId" id="removeMemberTeamId">
					<input type="hidden" name="username" id="removeMemberUsername">
					<button type="submit" class="btn btn-danger">
						<i class="fa-solid fa-user-minus"></i> Yes, Remove
					</button>
				</form>
			</div>
		</div>
	</div>

	<!-- Members View All Modal -->
	<div id="membersModal" class="modal-overlay"
		onclick="if(event.target===this)closeMembersModal()">
		<div class="modal-box members-modal-panel"
			style="max-width: min(480px, calc(100vw - 24px)); width: 100%; text-align: left; padding: 28px;"
			onclick="event.stopPropagation()">
			<div
				style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
				<div>
					<div style="font-size: 17px; font-weight: 700; color: var(--text)"
						id="membersModalTitle"></div>
					<div style="font-size: 12px; color: var(--text3); margin-top: 3px;"
						id="membersModalCount"></div>
				</div>
				<button onclick="closeMembersModal()"
					style="background: var(--surface2); border: 1px solid var(--border2); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text2); font-size: 14px;">
					<i class="fa-solid fa-xmark"></i>
				</button>
			</div>

			<!-- Search inside modal -->
			<div style="position: relative; margin-bottom: 14px;">
				<i class="fa-solid fa-search"
					style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--text3); font-size: 13px;"></i>
				<input type="text" id="membersModalSearch"
					placeholder="Search members…"
					style="width: 100%; padding: 9px 12px 9px 34px; border: 1.5px solid var(--border2); border-radius: 8px; font-size: 13px; font-family: inherit; outline: none; color: var(--text);"
					oninput="filterModalMembers(this.value)">
			</div>

			<div id="membersModalList"
				style="max-height: 320px; overflow-y: auto; display: flex; flex-direction: column; gap: 6px;">
				<!-- populated by JS -->
			</div>
		</div>
	</div>

	<script>
function showToast(msg, type) {
  var t = document.getElementById('toast');
  if (!t) return;
  t.className = 'toast ' + type;
  t.textContent = msg;
  t.style.display = 'block';
  clearTimeout(window.__tt);
  window.__tt = setTimeout(function() { t.style.display = 'none'; }, 3000);
}

function openDeleteModal(teamId, teamName) {
  document.getElementById('deleteTeamId').value = teamId;
  document.getElementById('deleteTeamName').textContent = '"' + teamName + '"';
  document.getElementById('deleteTeamModal').classList.add('show');
}

function closeDeleteModal() {
  document.getElementById('deleteTeamModal').classList.remove('show');
}

function openRemoveMemberModal(teamId, teamName, memberName, username) {
  document.getElementById('removeMemberTeamId').value = teamId;
  document.getElementById('removeMemberUsername').value = username;
  document.getElementById('removeMemberDisplayName').textContent = '"' + memberName + '"';
  var teamLbl = document.getElementById('removeMemberTeamLabel');
  if (teamLbl) {
    if (teamName) {
      teamLbl.textContent = 'Team: "' + teamName + '"';
      teamLbl.style.display = 'block';
    } else {
      teamLbl.textContent = '';
      teamLbl.style.display = 'none';
    }
  }
  var extra = document.getElementById('removeMemberExtraLine');
  if (extra) {
    extra.textContent = 'This removes them from this team only. Their user account is not deleted.';
  }
  document.getElementById('removeMemberModal').classList.add('show');
}

function closeRemoveMemberModal() {
  var el = document.getElementById('removeMemberModal');
  if (el) el.classList.remove('show');
}

function openRemoveMemberModalFromChip(btn) {
  if (!btn) return;
  var teamId = parseInt(btn.getAttribute('data-team-id'), 10);
  var teamName = btn.getAttribute('data-team-name') || '';
  var memberName = btn.getAttribute('data-member-name') || '';
  var username = btn.getAttribute('data-username') || '';
  openRemoveMemberModal(teamId, teamName, memberName, username);
}

document.addEventListener('DOMContentLoaded', function () {
  var toast = document.getElementById('toast');
  if (toast) {
    var s = toast.getAttribute('data-success'), e = toast.getAttribute('data-error');
    if (s) showToast(s, 'success');
    if (e) showToast(e, 'error');
  }

  // Add member form validation
  var form = document.getElementById('addMemberForm');
  if (form) {
    form.addEventListener('submit', function (ev) {
      var checked = form.querySelectorAll('input[name="username"]:checked');
      if (checked.length === 0) { ev.preventDefault(); showToast('Please select at least one employee.', 'error'); }
    });
  }

  // Employee search
  var search = document.getElementById('employeeSearch');
  var list   = document.getElementById('employeeCheckboxList');
  var noRes  = document.getElementById('employeeNoResults');
  if (search && list) {
    search.addEventListener('input', function () {
      var q = this.value.trim().toLowerCase();
      var items = list.querySelectorAll('.employee-item');
      var n = 0;
      items.forEach(function (el) {
        var match = !q || (el.getAttribute('data-search') || '').indexOf(q) >= 0;
        el.style.display = match ? '' : 'none';
        if (match) n++;
      });
      if (noRes) noRes.style.display = (items.length > 0 && q && n === 0) ? '' : 'none';
    });
  }
});

var _currentModalTeamId = null;
var _currentModalMembers = [];
var _teamsCtx = '<%=request.getContextPath()%>';

function escAttr(s) {
  if (s == null) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function openMembersModal(teamId, teamName, members) {
  _currentModalTeamId = teamId;
  _currentModalMembers = members;
  document.getElementById('membersModalTitle').textContent = teamName;
  document.getElementById('membersModalCount').textContent = members.length + ' member' + (members.length !== 1 ? 's' : '');
  document.getElementById('membersModalSearch').value = '';
  renderModalMembers(members);
  document.getElementById('membersModal').classList.add('show');
}

function closeMembersModal() {
  document.getElementById('membersModal').classList.remove('show');
}

function filterModalMembers(q) {
  var filtered = q.trim()
    ? _currentModalMembers.filter(function(m) { return m.name.toLowerCase().indexOf(q.toLowerCase()) >= 0 || m.email.toLowerCase().indexOf(q.toLowerCase()) >= 0; })
    : _currentModalMembers;
  renderModalMembers(filtered);
}

function renderModalMembers(members) {
  var list = document.getElementById('membersModalList');
  var tid = _currentModalTeamId;
  var teamNameEl = document.getElementById('membersModalTitle');
  var teamName = teamNameEl ? teamNameEl.textContent : '';
  if (!members.length) {
    list.innerHTML = '<p style="text-align:center;color:var(--text3);font-size:13px;padding:20px 0;">No members found</p>';
    return;
  }
  list.innerHTML = members.map(function(m) {
    var name = escAttr(m.name);
    var email = escAttr(m.email);
    var initials = escAttr(m.initials);
    var teamNameAttr = escAttr(teamName);
    var nameAttr = escAttr(m.name);
    var emailAttr = escAttr(m.email);
    return '<div class="member-modal-row">'
      + '<div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--accent),#818cf8);color:#fff;font-size:13px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;">' + initials + '</div>'
      + '<div class="member-modal-info">'
      + '<div style="font-size:13px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + name + '</div>'
      + '<div style="font-size:12px;color:var(--text3);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + email + '</div>'
      + '</div>'
      + '<button type="button" class="member-modal-remove" title="Remove from team" aria-label="Remove from team"'
      + ' data-team-id="' + tid + '"'
      + ' data-team-name="' + teamNameAttr + '"'
      + ' data-member-name="' + nameAttr + '"'
      + ' data-username="' + emailAttr + '"'
      + ' onclick="openRemoveMemberModalFromChip(this)">'
      + '<i class="fa-solid fa-xmark" style="font-size:14px;"></i>'
      + '</button>'
      + '</div>';
  }).join('');
}

//── Searchable Dropdown Engine ──
document.addEventListener('DOMContentLoaded', function () {
  initAllDropdowns();
});

function initAllDropdowns() {
  document.querySelectorAll('.dropdown-wrap').forEach(function (wrap) {
    var forId      = wrap.getAttribute('data-for');
    var autoSubmit = wrap.getAttribute('data-autosubmit');
    var hiddenSel  = document.getElementById(forId);
    var trigger    = wrap.querySelector('.dropdown-trigger');
    var panel      = wrap.querySelector('.dropdown-panel');
    var search     = wrap.querySelector('.dropdown-search');
    var options    = wrap.querySelectorAll('.dropdown-option');
    var noRes      = wrap.querySelector('.dropdown-no-results');
    var dtText     = trigger.querySelector('.dt-text');

    if (!hiddenSel || !trigger || !panel) return;

    // Open / close
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      var isOpen = panel.classList.contains('open');
      closeAllDropdowns();
      if (!isOpen) {
        panel.classList.add('open');
        trigger.classList.add('open');
        if (search) { search.value = ''; filterOptions(options, noRes, ''); search.focus(); }
      }
    });

    // Search
    if (search) {
      search.addEventListener('input', function () {
        filterOptions(options, noRes, this.value.trim().toLowerCase());
      });
      search.addEventListener('click', function (e) { e.stopPropagation(); });
    }

    // Select option
    options.forEach(function (opt) {
      opt.addEventListener('click', function () {
        var val  = opt.getAttribute('data-value');
        var text = opt.textContent.trim();

        // update hidden select
        hiddenSel.value = val;

        // update trigger label
        dtText.textContent = text;
        dtText.classList.toggle('placeholder', !val);

        // mark selected
        options.forEach(function (o) { o.classList.remove('selected'); });
        opt.classList.add('selected');

        closeAllDropdowns();

        // auto-submit for manager card dropdowns
        if (autoSubmit) {
          var f = document.getElementById(autoSubmit);
          if (f) f.submit();
        }
      });
    });
  });

  // Close on outside click
  document.addEventListener('click', closeAllDropdowns);
}

function filterOptions(options, noRes, q) {
  var visible = 0;
  options.forEach(function (opt) {
    var match = !q || opt.textContent.toLowerCase().indexOf(q) >= 0;
    opt.classList.toggle('hidden', !match);
    if (match) visible++;
  });
  if (noRes) noRes.style.display = (visible === 0) ? 'block' : 'none';
}

function closeAllDropdowns() {
  document.querySelectorAll('.dropdown-panel.open').forEach(function (p) {
    p.classList.remove('open');
  });
  document.querySelectorAll('.dropdown-trigger.open').forEach(function (t) {
    t.classList.remove('open');
  });
}
</script>
</body>
</html>
