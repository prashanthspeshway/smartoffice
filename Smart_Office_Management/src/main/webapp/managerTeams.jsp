<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.dao.TaskDAO"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
if (myTeams == null)
	myTeams = java.util.Collections.emptyList();

Map<String, List<Task>> tasksByEmail = new HashMap<>();
try {
	for (Team tm : myTeams) {
		for (User m : tm.getMembers()) {
	String email = m.getEmail();
	if (email != null && !tasksByEmail.containsKey(email)) {
		List<Task> empTasks = TaskDAO.getTasksForEmployee(email);
		tasksByEmail.put(email, empTasks != null ? empTasks : new ArrayList<>());
	}
		}
	}
} catch (Exception ignored) {
}

java.text.SimpleDateFormat sdfDate = new java.text.SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Teams • Smart Office HRMS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ══════════════════════════════════════════
   DESIGN TOKENS — Admin Overview System
══════════════════════════════════════════ */
:root {
	--bg: #f0f2f8;
	--surface: #fff;
	--surface2: #f7f8fc;
	--border: #e4e8f0;
	--text: #1a1d2e;
	--text2: #5a6278;
	--text3: #9aa0b8;
	--blue: #4f6ef7;
	--green: #22c55e;
	--violet: #8b5cf6;
	--amber: #f59e0b;
	--red: #ef4444;
	--shadow-sm: 0 1px 3px rgba(0, 0, 0, .06);
	--shadow: 0 4px 16px rgba(0, 0, 0, .07);
	--shadow-lg: 0 20px 50px rgba(0, 0, 0, .1);
	--radius: 16px;
	--radius-sm: 10px;
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
	-webkit-font-smoothing: antialiased;
}

button {
	font-family: inherit;
	cursor: pointer;
	border: none;
	background: none;
}

input, select, textarea {
	font-family: inherit;
}

::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-track { background: var(--bg); }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 99px; }
::-webkit-scrollbar-thumb:hover { background: var(--text3); }

/* ══════════════════════════════════════════
   PAGE LAYOUT
══════════════════════════════════════════ */
.page {
	max-width: 1200px;
	margin: 0 auto;
	padding: clamp(16px, 4vw, 32px) clamp(12px, 4vw, 20px);
}

/* ══════════════════════════════════════════
   PAGE HEADER
══════════════════════════════════════════ */
.page-header { margin-bottom: 28px; }

.page-title {
	font-family: 'Geist', system-ui, sans-serif;
	font-size: clamp(1.25rem, 2.2vw + 0.4rem, 1.625rem);
	font-weight: 600;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 10px;
}

.page-title i { color: var(--blue); font-size: 20px; }
.page-subtitle { color: var(--text3); font-size: 13px; margin-top: 4px; }

/* ══════════════════════════════════════════
   STAT CARDS
══════════════════════════════════════════ */
.stats-row {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 14px;
	margin-bottom: 24px;
}

@media (max-width: 900px) { .stats-row { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 480px) { .stats-row { grid-template-columns: repeat(2, 1fr); } }

.stat-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 18px 16px;
	box-shadow: var(--shadow-sm);
	transition: box-shadow .2s, transform .2s;
	position: relative;
	overflow: hidden;
}
.stat-card::before {
	content: '';
	position: absolute; top: 0; left: 0; right: 0; height: 3px;
	border-radius: var(--radius) var(--radius) 0 0;
}
.stat-card:hover { box-shadow: var(--shadow); transform: translateY(-2px); }
.stat-card.blue::before  { background: var(--blue); }
.stat-card.green::before { background: var(--green); }
.stat-card.violet::before{ background: var(--violet); }
.stat-card.amber::before { background: var(--amber); }

.stat-icon {
	width: 38px; height: 38px; border-radius: 10px;
	display: flex; align-items: center; justify-content: center;
	font-size: 16px; margin-bottom: 12px;
}
.stat-card.blue   .stat-icon { background: #eef1fe; color: var(--blue); }
.stat-card.green  .stat-icon { background: #f0fdf4; color: var(--green); }
.stat-card.violet .stat-icon { background: #f5f3ff; color: var(--violet); }
.stat-card.amber  .stat-icon { background: #fffbeb; color: var(--amber); }

.stat-num {
	font-size: clamp(1.35rem, 3.5vw + 0.35rem, 1.75rem);
	font-weight: 700; line-height: 1; color: var(--text);
}
.stat-label {
	font-size: clamp(0.65rem, 0.8vw + 0.45rem, 0.75rem);
	color: var(--text3); font-weight: 500; margin-top: 4px;
	text-transform: uppercase; letter-spacing: .5px;
}

/* ══════════════════════════════════════════
   SECTION LABEL
══════════════════════════════════════════ */
.section-label {
	font-size: .65rem; font-weight: 700; letter-spacing: .1em;
	text-transform: uppercase; color: var(--text3); margin-bottom: 14px;
}

/* ══════════════════════════════════════════
   TEAM CARDS
══════════════════════════════════════════ */
.teams-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
	gap: 14px; margin-bottom: 28px;
}

.team-card {
	background: var(--surface); border: 1px solid var(--border);
	border-radius: var(--radius); padding: 20px 18px 16px;
	cursor: pointer; position: relative; overflow: hidden;
	box-shadow: var(--shadow-sm);
	transition: box-shadow .2s, transform .2s, border-color .2s;
	animation: fadeUp .45s ease both;
}
.team-card::before {
	content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
	border-radius: var(--radius) var(--radius) 0 0;
	background: linear-gradient(90deg, var(--blue), var(--violet));
	transform: scaleX(0); transform-origin: left center;
	transition: transform .3s cubic-bezier(.22, 1, .36, 1);
}
.team-card:hover { box-shadow: var(--shadow); transform: translateY(-2px); border-color: #c7d2fe; }
.team-card:hover::before { transform: scaleX(1); }
.team-card.selected { border-color: var(--blue); box-shadow: var(--shadow), 0 0 0 3px rgba(79,110,247,.1); }
.team-card.selected::before { transform: scaleX(1); }

.tc-icon-wrap {
	width: 38px; height: 38px; border-radius: 10px;
	background: #eef1fe; color: var(--blue);
	display: flex; align-items: center; justify-content: center;
	font-size: 16px; margin-bottom: 14px;
	transition: background .2s, color .2s, box-shadow .2s;
}
.team-card:hover .tc-icon-wrap, .team-card.selected .tc-icon-wrap {
	background: var(--blue); color: #fff;
	box-shadow: 0 4px 12px rgba(79,110,247,.3);
}
.tc-name { font-size: .9rem; font-weight: 700; color: var(--text); margin-bottom: 4px; line-height: 1.3; }
.tc-mgr  { font-size: .72rem; color: var(--text3); display: flex; align-items: center; gap: 4px; }
.tc-foot { display: flex; align-items: center; justify-content: space-between; margin-top: 16px; padding-top: 12px; border-top: 1px solid var(--border); }
.tc-count { font-size: .72rem; color: var(--text2); display: flex; align-items: center; gap: 4px; }
.tc-count i { color: var(--blue); font-size: .62rem; }
.tc-badge {
	font-size: .62rem; font-weight: 600; padding: 2px 8px; border-radius: 99px;
	background: #eef1fe; color: var(--blue);
	opacity: 0; transform: translateX(-4px);
	transition: opacity .2s, transform .2s;
}
.team-card:hover .tc-badge, .team-card.selected .tc-badge { opacity: 1; transform: translateX(0); }

.team-card:nth-child(1){animation-delay:.05s}
.team-card:nth-child(2){animation-delay:.10s}
.team-card:nth-child(3){animation-delay:.15s}
.team-card:nth-child(4){animation-delay:.20s}
.team-card:nth-child(5){animation-delay:.25s}
.team-card:nth-child(6){animation-delay:.30s}

/* ══════════════════════════════════════════
   EMPTY STATE
══════════════════════════════════════════ */
.empty-state {
	background: var(--surface); border: 1px dashed var(--border);
	border-radius: var(--radius); padding: 52px 24px;
	text-align: center; color: var(--text3);
}
.empty-state i { font-size: 32px; color: var(--border); display: block; margin-bottom: 12px; }
.empty-state strong { display: block; font-size: .88rem; font-weight: 600; color: var(--text2); margin-bottom: 4px; }
.empty-state p { font-size: .76rem; }

/* ══════════════════════════════════════════
   TEAM DETAIL
══════════════════════════════════════════ */
#teamDetail { animation: fadeUp .4s ease both; }

/* Breadcrumb */
.breadcrumb {
	display: flex; align-items: center; gap: 8px;
	margin-bottom: 20px; font-size: .76rem;
}
.btn-back {
	display: inline-flex; align-items: center; gap: 6px;
	padding: 6px 14px; border-radius: var(--radius-sm);
	font-size: .73rem; font-weight: 600;
	color: var(--blue); background: #eef1fe; border: 1px solid #c7d2fe;
	transition: all .15s;
}
.btn-back:hover { background: var(--blue); color: #fff; border-color: var(--blue); transform: translateX(-2px); }
.bc-sep { color: var(--border); }
.bc-cur { font-weight: 600; color: var(--text2); }

/* ══════════════════════════════════════════
   EXPORT BUTTONS — matches attendance style
══════════════════════════════════════════ */
.btn-export {
	display: inline-flex; align-items: center; gap: 7px;
	font-size: .73rem; font-weight: 600;
	padding: 7px 15px; border-radius: var(--radius-sm);
	transition: all .18s; white-space: nowrap;
	font-family: 'Geist', system-ui, sans-serif;
	cursor: pointer; text-decoration: none;
}
.btn-export i { font-size: .72rem; }

/* CSV — neutral grey, warms to amber on hover */
.btn-export-csv {
	background: var(--surface);
	color: var(--text2);
	border: 1.5px solid var(--border);
}
.btn-export-csv:hover {
	background: #FFFDE7;
	color: #E65100;
	border-color: #FFD54F;
	box-shadow: 0 2px 10px rgba(245,158,11,.18);
	transform: translateY(-1px);
}

/* Excel — green, mirrors the "Present" cell colour in attendance export */
.btn-export-xlsx {
	background: #E8F5E9;
	color: #1B5E20;
	border: 1.5px solid #A5D6A7;
	box-shadow: 0 2px 8px rgba(34,197,94,.12);
}
.btn-export-xlsx:hover {
	background: #C8E6C9;
	color: #1B5E20;
	border-color: #66BB6A;
	box-shadow: 0 4px 16px rgba(34,197,94,.28);
	transform: translateY(-1px);
}
.btn-export-xlsx:active { transform: translateY(0); }

/* Loading spinner state */
.btn-export-xlsx.loading {
	opacity: .75;
	pointer-events: none;
}

/* ══════════════════════════════════════════
   ASSIGN BAR
══════════════════════════════════════════ */
.assign-bar {
	background: var(--surface); border: 1px solid var(--border);
	border-radius: var(--radius); padding: 18px 20px;
	box-shadow: var(--shadow-sm);
	display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
	margin-bottom: 14px; animation: fadeUp .3s ease both;
}
.ab-icon {
	width: 38px; height: 38px; border-radius: 10px;
	background: #eef1fe; color: var(--blue);
	display: flex; align-items: center; justify-content: center; font-size: 15px;
}
.ab-label { font-size: .88rem; font-weight: 700; color: var(--text); }
.ab-sub   { font-size: .72rem; color: var(--text3); margin-top: 2px; }

/* ══════════════════════════════════════════
   CHART CARD
══════════════════════════════════════════ */
.chart-card {
	background: var(--surface); border: 1px solid var(--border);
	border-radius: var(--radius); padding: 20px;
	box-shadow: var(--shadow-sm); animation: fadeUp .5s ease both;
}
.chart-card:hover { box-shadow: var(--shadow); }

.chart-header {
	display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;
}
.chart-title { font-size: 14px; font-weight: 700; color: var(--text); display: flex; align-items: center; gap: 7px; }
.chart-title i { font-size: 13px; color: var(--blue); }
.chart-subtitle { font-size: 11px; color: var(--text3); margin-top: 2px; }
.chart-badge { font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 99px; background: #eef1fe; color: var(--blue); }

/* ══════════════════════════════════════════
   MEMBER TABLE
══════════════════════════════════════════ */
.table-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-bottom: 16px; }
.table-top-right { display: flex; align-items: center; gap: 10px; }

.search-wrap { position: relative; }
.search-wrap i {
	position: absolute; left: 10px; top: 50%; transform: translateY(-50%);
	color: var(--text3); font-size: .72rem; pointer-events: none; transition: color .15s;
}
.search-input {
	padding: 8px 12px 8px 30px; border: 1px solid var(--border);
	border-radius: var(--radius-sm); font-size: .76rem; color: var(--text);
	background: var(--surface2); width: 180px; outline: none;
	font-family: 'Geist', sans-serif; transition: all .2s;
}
.search-input::placeholder { color: var(--text3); }
.search-input:focus { border-color: var(--blue); background: var(--surface); box-shadow: 0 0 0 3px rgba(79,110,247,.08); width: 220px; }
.search-wrap:focus-within i { color: var(--blue); }

table { width: 100%; border-collapse: collapse; }
thead tr { background: var(--surface2); }
thead th {
	padding: 10px 14px; text-align: left; font-size: .6rem; font-weight: 700;
	text-transform: uppercase; letter-spacing: .1em; color: var(--text3);
	white-space: nowrap; border-bottom: 1px solid var(--border);
}
tbody tr { border-bottom: 1px solid var(--surface2); transition: background .12s; cursor: pointer; }
tbody tr:last-child { border-bottom: none; }
tbody tr:hover { background: #f5f7ff; }
tbody td { padding: 13px 14px; font-size: .8rem; color: var(--text2); vertical-align: middle; }

.emp-avatar {
	width: 34px; height: 34px; border-radius: 50%;
	background: linear-gradient(135deg, var(--blue) 0%, var(--violet) 100%);
	display: flex; align-items: center; justify-content: center;
	color: #fff; font-size: .63rem; font-weight: 700; flex-shrink: 0;
	font-family: 'Geist Mono', monospace;
	box-shadow: 0 2px 8px rgba(79,110,247,.2);
}
.emp-name  { font-weight: 600; color: var(--text); font-size: .82rem; }
.emp-email { font-size: .65rem; color: var(--text3); font-family: 'Geist Mono', monospace; margin-top: 2px; }

.desig-pill {
	display: inline-block; font-size: .65rem; font-weight: 500;
	color: var(--text2); background: var(--surface2);
	border: 1px solid var(--border); padding: 2px 9px; border-radius: 99px;
}
.num { font-weight: 700; font-size: .82rem; }
.num-default { color: var(--text2); }
.num-green   { color: var(--green); }
.num-amber   { color: var(--amber); }
.num-rose    { color: var(--red); }
.num-ghost   { color: var(--text3); }

.bar-wrap { height: 5px; background: var(--border); border-radius: 99px; overflow: hidden; min-width: 70px; }
.bar-fill { height: 100%; background: linear-gradient(90deg, var(--blue), var(--green)); border-radius: 99px; transition: width .7s cubic-bezier(.22,1,.36,1); }
.bar-pct { font-size: .68rem; font-weight: 700; color: var(--text2); white-space: nowrap; }

/* small action buttons */
.btn-sm { display: inline-flex; align-items: center; gap: 4px; font-size: .68rem; font-weight: 600; padding: 5px 11px; border-radius: var(--radius-sm); transition: all .15s; white-space: nowrap; }
.btn-sm-blue  { background: #eef1fe; color: var(--blue); border: 1px solid #c7d2fe; }
.btn-sm-blue:hover  { background: var(--blue); color: #fff; border-color: var(--blue); }
.btn-sm-ghost { background: var(--surface2); color: var(--text2); border: 1px solid var(--border); }
.btn-sm-ghost:hover { background: var(--border); color: var(--text); }

/* primary button */
.btn-primary {
	margin-left: auto; flex-shrink: 0;
	display: inline-flex; align-items: center; gap: 7px;
	background: var(--blue); color: #fff;
	font-weight: 600; font-size: .76rem; white-space: nowrap;
	padding: 9px 18px; border-radius: var(--radius-sm);
	box-shadow: 0 4px 14px rgba(79,110,247,.3);
	transition: background .15s, transform .15s, box-shadow .15s;
}
.btn-primary:hover { background: #3d5ce6; transform: translateY(-1px); box-shadow: 0 8px 24px rgba(79,110,247,.35); }
.btn-primary:active { transform: translateY(0); }

/* ══════════════════════════════════════════
   MODALS
══════════════════════════════════════════ */
.overlay {
	position: fixed; inset: 0; z-index: 900;
	background: rgba(26,29,46,.45); backdrop-filter: blur(8px);
	display: flex; align-items: center; justify-content: center; padding: 16px;
	opacity: 0; pointer-events: none; transition: opacity .25s ease;
}
.overlay.open { opacity: 1; pointer-events: all; }

.modal {
	background: var(--surface); border-radius: var(--radius); width: 100%;
	box-shadow: var(--shadow-lg); border: 1px solid var(--border);
	transform: translateY(20px) scale(.975);
	transition: transform .32s cubic-bezier(.22,1,.36,1);
	max-height: 90vh; overflow-y: auto;
}
.overlay.open .modal { transform: translateY(0) scale(1); }

.modal-header {
	display: flex; align-items: center; gap: 14px;
	padding: 20px 22px 16px; border-bottom: 1px solid var(--border);
	position: sticky; top: 0; background: var(--surface); z-index: 10;
	border-radius: var(--radius) var(--radius) 0 0;
}
.modal-close {
	width: 30px; height: 30px; border-radius: 50%;
	margin-left: auto; flex-shrink: 0;
	background: var(--surface2); color: var(--text2); border: 1px solid var(--border);
	display: flex; align-items: center; justify-content: center; font-size: .76rem; transition: all .15s;
}
.modal-close:hover { background: #fef2f2; color: var(--red); border-color: #fecaca; }
.modal-body { padding: 20px 22px; }

/* stat row in modal */
.mstat-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; margin-bottom: 16px; }
.mstat-box {
	background: var(--surface2); border: 1px solid var(--border);
	border-radius: var(--radius); padding: 14px; text-align: center;
	transition: border-color .15s, box-shadow .15s;
}
.mstat-box:hover { border-color: #c7d2fe; box-shadow: var(--shadow-sm); }
.mstat-box .sv { font-size: 1.5rem; font-weight: 700; line-height: 1; }
.mstat-box .sl { font-size: .58rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--text3); margin-top: 5px; }

/* ring */
.ring-section {
	display: flex; align-items: center; gap: 18px;
	background: var(--surface2); border: 1px solid var(--border);
	border-radius: var(--radius); padding: 16px; margin-bottom: 16px;
}
.ring-wrap { position: relative; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ring-wrap svg { transform: rotate(-90deg); }
.ring-bg   { fill: none; stroke: var(--border); stroke-width: 7; }
.ring-fill { fill: none; stroke-width: 7; stroke-linecap: round; transition: stroke-dashoffset 1s cubic-bezier(.22,1,.36,1); }
.ring-pct  { position: absolute; font-size: 1rem; font-weight: 700; color: var(--text); font-family: 'Geist', sans-serif; }

/* task status pills */
.t-pill { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 99px; font-size: .65rem; font-weight: 700; white-space: nowrap; }
.tp-done    { background: #f0fdf4; color: #166534; }
.tp-open    { background: #fffbeb; color: #92400e; }
.tp-overdue { background: #fef2f2; color: #991b1b; }
.tp-review  { background: #f5f3ff; color: #5b21b6; }

/* modal tabs */
.tab-bar { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 14px; }
.tab-btn {
	padding: 5px 14px; border-radius: 99px; font-size: .71rem; font-weight: 600;
	border: 1px solid var(--border); color: var(--text2); background: var(--surface2); transition: all .15s;
}
.tab-btn:hover { border-color: #c7d2fe; color: var(--blue); background: #eef1fe; }
.tab-btn.active { background: var(--blue); color: #fff; border-color: var(--blue); box-shadow: 0 2px 8px rgba(79,110,247,.25); }

/* task items */
.task-item {
	display: flex; align-items: flex-start; gap: 12px;
	padding: 11px 13px; border-radius: var(--radius-sm);
	border: 1px solid var(--border); background: var(--surface);
	margin-bottom: 7px; transition: border-color .15s, box-shadow .15s, transform .15s;
}
.task-item:hover { border-color: #c7d2fe; background: var(--surface2); box-shadow: var(--shadow-sm); transform: translateX(2px); }
.task-item-body  { flex: 1; min-width: 0; }
.task-item-title { font-size: .81rem; font-weight: 700; color: var(--text); }
.task-item-desc  { font-size: .68rem; color: var(--text3); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.task-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-top: 5px; font-size: .66rem; color: var(--text3); }
.prio-high   { color: var(--red);   font-weight: 700; }
.prio-medium { color: var(--amber); font-weight: 700; }
.prio-low    { color: var(--green); font-weight: 700; }

/* ══════════════════════════════════════════
   ASSIGN FORM
══════════════════════════════════════════ */
.form-group { margin-bottom: 15px; }
.form-label { display: block; font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .07em; color: var(--text2); margin-bottom: 6px; }
.form-label .req { color: var(--red); }
.form-control {
	width: 100%; padding: 8px 12px; border: 1px solid var(--border);
	border-radius: var(--radius-sm); font-size: .8rem; color: var(--text);
	background: var(--surface2); outline: none; font-family: 'Geist', sans-serif;
	transition: border-color .15s, box-shadow .15s, background .15s;
}
.form-control::placeholder { color: var(--text3); }
.form-control:focus { border-color: var(--blue); background: var(--surface); box-shadow: 0 0 0 3px rgba(79,110,247,.08); }
textarea.form-control { resize: vertical; min-height: 76px; }
.form-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

/* picker */
.picker-wrap { position: relative; }
.picker-trigger {
	width: 100%; min-height: 40px;
	display: flex; align-items: center; justify-content: space-between; gap: 8px;
	padding: 6px 12px; border: 1px solid var(--border); border-radius: var(--radius-sm);
	background: var(--surface2); cursor: pointer;
	transition: border-color .15s, box-shadow .15s, background .15s; user-select: none;
}
.picker-trigger.open, .picker-trigger:focus {
	border-color: var(--blue); background: var(--surface);
	box-shadow: 0 0 0 3px rgba(79,110,247,.08); outline: none;
}
.picker-chips { display: flex; flex-wrap: wrap; gap: 4px; flex: 1; min-width: 0; }
.picker-ph { font-size: .8rem; color: var(--text3); }
.picker-chevron { font-size: .65rem; color: var(--text3); flex-shrink: 0; transition: transform .2s; }

.picker-dropdown {
	position: absolute; z-index: 300; top: calc(100% + 5px); left: 0; right: 0;
	background: var(--surface); border: 1px solid var(--border);
	border-radius: var(--radius); box-shadow: var(--shadow-lg);
	max-height: 220px; overflow-y: auto; display: none;
}
.picker-dropdown.open { display: block; animation: fadeUp .18s ease; }

.picker-search { padding: 8px 10px; border-bottom: 1px solid var(--surface2); position: sticky; top: 0; background: var(--surface); z-index: 1; }
.picker-search input {
	width: 100%; padding: 6px 10px; border: 1px solid var(--border);
	border-radius: var(--radius-sm); font-size: .76rem; outline: none;
	background: var(--surface2); font-family: 'Geist', sans-serif; color: var(--text);
}
.picker-search input:focus { border-color: var(--blue); background: var(--surface); }

.picker-select-all { display: flex; align-items: center; gap: 8px; padding: 7px 12px; border-bottom: 1px solid var(--surface2); cursor: pointer; }
.picker-select-all:hover { background: var(--surface2); }
.picker-select-all label { font-size: .68rem; font-weight: 700; color: var(--blue); text-transform: uppercase; letter-spacing: .05em; cursor: pointer; }

.picker-opt {
	display: flex; align-items: center; gap: 10px; padding: 8px 12px;
	cursor: pointer; border-bottom: 1px solid var(--surface2); font-size: .8rem; transition: background .1s;
}
.picker-opt:last-child { border-bottom: none; }
.picker-opt:hover    { background: #f5f7ff; }
.picker-opt.selected { background: #eef1fe; }
.picker-opt input[type="checkbox"] { accent-color: var(--blue); width: 14px; height: 14px; flex-shrink: 0; cursor: pointer; }

.chip {
	display: inline-flex; align-items: center; gap: 4px;
	background: #eef1fe; color: var(--blue); border: 1px solid #c7d2fe;
	border-radius: 99px; padding: 2px 8px 2px 9px; font-size: .65rem; font-weight: 600;
}
.chip-x { cursor: pointer; color: #818cf8; font-size: .6rem; margin-left: 2px; transition: color .12s; }
.chip-x:hover { color: var(--red); }

.form-error { font-size: .68rem; color: var(--red); margin-top: 4px; display: none; }
.form-error i { margin-right: 3px; }

.preview-box { background: #eef1fe; border: 1px solid #c7d2fe; border-radius: var(--radius-sm); padding: 11px 13px; display: none; animation: fadeUp .2s ease both; }
.preview-title { font-size: .68rem; font-weight: 700; color: var(--blue); margin-bottom: 7px; }
.preview-tags  { display: flex; flex-wrap: wrap; gap: 5px; }
.preview-tag {
	font-size: .65rem; font-weight: 600; color: var(--blue);
	background: var(--surface); border: 1px solid #c7d2fe;
	border-radius: 99px; padding: 2px 9px;
}

.submitted-pill {
	display: inline-flex; align-items: center; gap: 5px;
	padding: 4px 11px; border-radius: 99px; font-size: .68rem; font-weight: 600;
	background: #f5f3ff; color: var(--violet); border: 1px solid #ddd6fe;
}

@keyframes fadeUp {
	from { opacity: 0; transform: translateY(14px); }
	to   { opacity: 1; transform: translateY(0); }
}
.a1 { animation-delay: .05s; }
.a2 { animation-delay: .10s; }
.a3 { animation-delay: .15s; }
.a4 { animation-delay: .20s; }
</style>
</head>
<body class="user-iframe-page">

<!-- ════════ JSON DATA ISLAND ════════ -->
<script id="teams-json" type="application/json">
[
<%boolean firstTeam = true;
for (Team tm : myTeams) {
	if (!firstTeam) out.print(",");
	firstTeam = false;
	String tmName = tm.getName() != null ? tm.getName().replace("\\","\\\\").replace("\"","\\\"") : "";
	String mgr = tm.getManagerFullname() != null
		? tm.getManagerFullname().replace("\\","\\\\").replace("\"","\\\"")
		: (tm.getManagerUsername() != null ? tm.getManagerUsername().replace("\\","\\\\").replace("\"","\\\"") : "");%>
{"id":<%=tm.getId()%>,"name":"<%=tmName%>","manager":"<%=mgr%>","memberCount":<%=tm.getMembers().size()%>,"members":[
<%boolean firstMem = true;
for (User m : tm.getMembers()) {
	if (!firstMem) out.print(",");
	firstMem = false;
	String fn = "";
	if (m.getFirstname() != null) fn += m.getFirstname().trim();
	if (m.getLastname()  != null) fn += (fn.isEmpty() ? "" : " ") + m.getLastname().trim();
	if (fn.isEmpty()) fn = m.getEmail() != null ? m.getEmail() : "";
	String email = m.getEmail()       != null ? m.getEmail().replace("\\","\\\\").replace("\"","\\\"")       : "";
	String desig = m.getDesignation() != null ? m.getDesignation().replace("\\","\\\\").replace("\"","\\\"") : "";
	String role  = m.getRole()        != null ? m.getRole().replace("\\","\\\\").replace("\"","\\\"")        : "";
	fn = fn.replace("\\","\\\\").replace("\"","\\\"");

	List<Task> empTasks = tasksByEmail.getOrDefault(m.getEmail(), new ArrayList<>());
	int total=0, completed=0, open=0, overdue=0, submitted=0;
	java.util.Date todayD = new java.util.Date();
	for (Task t : empTasks) {
		total++;
		String st = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "";
		if ("COMPLETED".equals(st)) completed++;
		else if ("SUBMITTED".equals(st)||"PROCESSING".equals(st)) { submitted++; open++; }
		else open++;
		if (!"COMPLETED".equals(st) && t.getDeadline()!=null && t.getDeadline().before(todayD)) overdue++;
	}
	int compPct = total>0?(completed*100/total):0;%>
{"email":"<%=email%>","name":"<%=fn%>","desig":"<%=desig%>","role":"<%=role%>","stats":{"total":<%=total%>,"completed":<%=completed%>,"open":<%=open%>,"overdue":<%=overdue%>,"submitted":<%=submitted%>,"compPct":<%=compPct%>},"tasks":[
<%boolean firstTask = true;
for (Task t : empTasks) {
	if (!firstTask) out.print(",");
	firstTask = false;
	String tTitle    = t.getTitle()        !=null?t.getTitle().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n"):"Untitled";
	String tStatus   = t.getStatus()       !=null?t.getStatus().trim().toUpperCase():"ASSIGNED";
	String tPriority = t.getPriority()     !=null?t.getPriority().trim().toUpperCase():"MEDIUM";
	String tDeadline = t.getDeadline()     !=null?t.getDeadline().toString():"";
	String tAssigned = t.getAssignedDate() !=null?sdfDate.format(t.getAssignedDate()):"";
	String tDesc     = t.getDescription()  !=null?t.getDescription().replace("\\","\\\\").replace("\"","\\\"").replace("\n"," "):"";%>
{"id":<%=t.getId()%>,"title":"<%=tTitle%>","status":"<%=tStatus%>","priority":"<%=tPriority%>","deadline":"<%=tDeadline%>","assigned":"<%=tAssigned%>","desc":"<%=tDesc%>"}
<%}%>
]}
<%}%>
]}
<%}%>
]
</script>

<!-- ════════ PAGE ════════ -->
<div class="page">

	<!-- Header -->
	<div class="page-header">
		<div class="page-title"><i class="fa-solid fa-people-group"></i> My Teams</div>
		<div class="page-subtitle">Select a team to view members and manage tasks</div>
	</div>

	<!-- Summary stat cards -->
	<div class="stats-row" id="summaryStats">
		<div class="stat-card blue a1">
			<div class="stat-icon"><i class="fa-solid fa-layer-group"></i></div>
			<div class="stat-num" id="statTeams">0</div>
			<div class="stat-label">Total Teams</div>
		</div>
		<div class="stat-card green a2">
			<div class="stat-icon"><i class="fa-solid fa-users"></i></div>
			<div class="stat-num" id="statMembers">0</div>
			<div class="stat-label">Total Members</div>
		</div>
		<div class="stat-card violet a3">
			<div class="stat-icon"><i class="fa-solid fa-list-check"></i></div>
			<div class="stat-num" id="statTasks">0</div>
			<div class="stat-label">Tasks Assigned</div>
		</div>
		<div class="stat-card amber a4">
			<div class="stat-icon"><i class="fa-solid fa-circle-check"></i></div>
			<div class="stat-num" id="statDone">0</div>
			<div class="stat-label">Tasks Completed</div>
		</div>
	</div>

	<!-- Teams Grid -->
	<div class="section-label">Teams</div>
	<div id="teamsGrid" class="teams-grid"></div>
	<div id="noTeams" class="empty-state" style="display:none;">
		<i class="fa-solid fa-people-group"></i>
		<strong>No teams assigned yet</strong>
		<p>Ask your admin to create a team and assign you as manager.</p>
	</div>

	<!-- Team Detail -->
	<div id="teamDetail" style="display:none;">

		<!-- ── Breadcrumb + Export Buttons ── -->
		<div class="breadcrumb" style="justify-content:space-between;">
			<div style="display:flex;align-items:center;gap:8px;">
				<button class="btn-back" onclick="backToTeams()">
					<i class="fa-solid fa-chevron-left" style="font-size:.6rem;"></i> All Teams
				</button>
				<span class="bc-sep">›</span>
				<span class="bc-cur" id="detailTeamName"></span>
			</div>

			<!-- Export buttons — styled to match attendance export -->
			<div style="display:flex;align-items:center;gap:8px;">
				<button class="btn-export btn-export-csv" onclick="exportTeamTasksCsv()" id="exportCsvBtn">
					<i class="fa-solid fa-file-csv"></i> Export CSV
				</button>
				<button class="btn-export btn-export-xlsx" onclick="exportTeamTasksXlsx()" id="exportXlsxBtn">
					<i class="fa-solid fa-file-excel"></i> Export Excel
				</button>
			</div>
		</div>

		<!-- Assign bar -->
		<div class="assign-bar">
			<div class="ab-icon"><i class="fa-solid fa-paper-plane"></i></div>
			<div>
				<div class="ab-label">Assign a Task</div>
				<div class="ab-sub">Assign to one or multiple team members at once</div>
			</div>
			<button class="btn-primary" onclick="openAssignModal([])">
				<i class="fa-solid fa-plus"></i> Assign to Team Member(s)
			</button>
		</div>

		<!-- Members table -->
		<div class="chart-card">
			<div class="chart-header">
				<div>
					<div class="chart-title">
						<i class="fa-solid fa-users"></i>
						<span id="detailTeamLabel">Team Members</span>
					</div>
					<div class="chart-subtitle" id="detailTeamMgr"></div>
				</div>
				<div class="table-top-right">
					<div class="search-wrap">
						<i class="fa-solid fa-magnifying-glass"></i>
						<input type="text" class="search-input" id="empSearch"
							placeholder="Search employees…" oninput="filterEmpTable(this.value)">
					</div>
					<span class="chart-badge" id="empCountBadge">0 members</span>
				</div>
			</div>

			<div style="overflow-x:auto;">
				<table>
					<thead>
						<tr>
							<th>#</th><th>Employee</th><th>Designation</th>
							<th>Total</th><th>Done</th><th>Open</th><th>Overdue</th>
							<th>Progress</th><th>Actions</th>
						</tr>
					</thead>
					<tbody id="empTableBody"></tbody>
				</table>
			</div>

			<div id="empTableEmpty" class="empty-state"
				style="display:none;border:none;border-radius:0;padding:32px 0;">
				<i class="fa-solid fa-user-slash"></i>
				<strong>No employees match your search</strong>
			</div>
		</div>
	</div>
</div>

<!-- ════════ EMPLOYEE STATS MODAL ════════ -->
<div id="empModal" class="overlay" onclick="if(event.target===this)closeEmpModal()">
	<div class="modal" style="max-width:740px;" onclick="event.stopPropagation()">
		<div class="modal-header">
			<div id="modalAvatar" class="emp-avatar"
				style="width:46px;height:46px;font-size:.85rem;border-radius:12px;flex-shrink:0;">?</div>
			<div style="flex:1;min-width:0;">
				<div id="modalName" style="font-size:1rem;font-weight:700;color:var(--text);"></div>
				<div id="modalDesig" style="font-size:.72rem;color:var(--text2);margin-top:2px;"></div>
				<div id="modalEmail" style="font-size:.65rem;color:var(--text3);font-family:'Geist Mono',monospace;margin-top:2px;"></div>
			</div>
			<button class="btn-primary" onclick="openAssignFromModal()" style="margin-left:0;">
				<i class="fa-solid fa-plus"></i> Assign Task
			</button>
			<button class="modal-close" onclick="closeEmpModal()"><i class="fa-solid fa-xmark"></i></button>
		</div>
		<div class="modal-body">
			<div class="mstat-row">
				<div class="mstat-box"><div class="sv" style="color:var(--blue);"  id="mStat-total">0</div><div class="sl">Total</div></div>
				<div class="mstat-box"><div class="sv" style="color:var(--green);" id="mStat-done">0</div><div class="sl">Completed</div></div>
				<div class="mstat-box"><div class="sv" style="color:var(--amber);" id="mStat-open">0</div><div class="sl">In Progress</div></div>
				<div class="mstat-box"><div class="sv" style="color:var(--red);"   id="mStat-over">0</div><div class="sl">Overdue</div></div>
			</div>
			<div class="ring-section">
				<div class="ring-wrap">
					<svg width="84" height="84" viewBox="0 0 84 84">
						<circle class="ring-bg" cx="42" cy="42" r="34"></circle>
						<circle class="ring-fill" id="modalRingFill" cx="42" cy="42" r="34"
							stroke="url(#ringGrad)" stroke-dasharray="213.63" stroke-dashoffset="213.63"></circle>
						<defs>
							<linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="0%">
								<stop offset="0%"   stop-color="#4f6ef7"/>
								<stop offset="100%" stop-color="#22c55e"/>
							</linearGradient>
						</defs>
					</svg>
					<span class="ring-pct" id="modalRingPct">0%</span>
				</div>
				<div style="flex:1;">
					<div style="font-size:.86rem;font-weight:700;color:var(--text);margin-bottom:4px;">Completion Rate</div>
					<div style="font-size:.76rem;color:var(--text3);" id="modalCompLabel"></div>
					<div style="margin-top:10px;">
						<span id="pill-submitted" class="submitted-pill" style="display:none;">
							<i class="fa-solid fa-hourglass-half" style="font-size:.6rem;"></i>
							<span id="pill-sub-val">0</span> Awaiting Review
						</span>
					</div>
				</div>
			</div>
			<div class="tab-bar" id="modalTabBar">
				<button class="tab-btn active" onclick="switchModalTab('all',this)">All Tasks</button>
				<button class="tab-btn" onclick="switchModalTab('open',this)">Open</button>
				<button class="tab-btn" onclick="switchModalTab('completed',this)">Completed</button>
				<button class="tab-btn" onclick="switchModalTab('overdue',this)">Overdue</button>
			</div>
			<div id="modalTaskList"></div>
		</div>
	</div>
</div>

<!-- ════════ ASSIGN TASK MODAL ════════ -->
<div id="assignModal" class="overlay" onclick="if(event.target===this)closeAssignModal()">
	<div class="modal" style="max-width:500px;" onclick="event.stopPropagation()">
		<div class="modal-header">
			<div style="width:36px;height:36px;background:#eef1fe;border:1px solid #c7d2fe;border-radius:var(--radius-sm);display:flex;align-items:center;justify-content:center;color:var(--blue);font-size:14px;flex-shrink:0;">
				<i class="fa-solid fa-paper-plane"></i>
			</div>
			<div>
				<div style="font-size:.92rem;font-weight:700;color:var(--text);">Assign New Task</div>
				<div style="font-size:.68rem;color:var(--text3);margin-top:2px;">Select one or multiple employees</div>
			</div>
			<button class="modal-close" onclick="closeAssignModal()"><i class="fa-solid fa-xmark"></i></button>
		</div>
		<div class="modal-body">
			<form action="<%=request.getContextPath()%>/managerTasks" method="post"
				enctype="multipart/form-data" id="assignModalForm"
				onsubmit="return validateAssignForm()">
				<input type="hidden" name="action" value="assign">

				<div class="form-group">
					<label class="form-label">Assign To <span class="req">*</span>
						<span id="selCountLabel" style="color:var(--blue);font-weight:600;text-transform:none;letter-spacing:0;margin-left:4px;"></span>
					</label>
					<div class="picker-wrap" id="empPickerWrapper">
						<div class="picker-trigger" id="empPickerTrigger" tabindex="0"
							onclick="toggleEmpPicker()"
							onkeydown="if(event.key==='Enter'||event.key===' ')toggleEmpPicker()">
							<div class="picker-chips" id="empPickerChips">
								<span class="picker-ph">Select employees…</span>
							</div>
							<i class="fa-solid fa-chevron-down picker-chevron" id="empPickerChevron"></i>
						</div>
						<div class="picker-dropdown" id="empPickerDropdown">
							<div class="picker-search">
								<input type="text" placeholder="Search employees…"
									id="empPickerSearchInput"
									oninput="filterPickerOptions(this.value)"
									onclick="event.stopPropagation()">
							</div>
							<div class="picker-select-all" onclick="toggleSelectAll()">
								<input type="checkbox" id="selectAllCb"
									onclick="event.stopPropagation();toggleSelectAll()"
									style="accent-color:var(--blue);width:14px;height:14px;cursor:pointer;">
								<label for="selectAllCb"><i class="fa-solid fa-users" style="margin-right:4px;"></i>Select All</label>
							</div>
							<div id="empPickerOptions"></div>
						</div>
					</div>
					<div id="empHiddenInputs"></div>
					<div id="empPickerError" class="form-error">
						<i class="fa-solid fa-circle-exclamation"></i>Please select at least one employee.
					</div>
				</div>

				<div class="form-group">
					<label class="form-label">Title <span class="req">*</span></label>
					<input type="text" name="title" class="form-control" placeholder="e.g. Submit weekly report" required>
				</div>
				<div class="form-group">
					<label class="form-label">Description <span class="req">*</span></label>
					<textarea name="taskDesc" class="form-control" rows="3" placeholder="Add clear instructions…" required></textarea>
				</div>
				<div class="form-group form-grid-2">
					<div>
						<label class="form-label">Deadline <span class="req">*</span></label>
						<input type="date" name="deadline" id="assignModalDeadline" class="form-control" required>
					</div>
					<div>
						<label class="form-label">Priority <span class="req">*</span></label>
						<select name="priority" class="form-control" required>
							<option value="HIGH">High</option>
							<option value="MEDIUM" selected>Medium</option>
							<option value="LOW">Low</option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="form-label">Attachment
						<span style="color:var(--text3);font-weight:400;text-transform:none;letter-spacing:0;">(optional)</span>
					</label>
					<input type="file" name="attachment" class="form-control"
						accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg"
						style="padding:6px 10px;cursor:pointer;">
				</div>
				<div id="assignPreview" class="preview-box form-group">
					<div class="preview-title">
						<i class="fa-solid fa-paper-plane" style="margin-right:4px;"></i>Assigning to:
						<span id="assignPreviewCount" style="font-weight:800;"></span>
					</div>
					<div class="preview-tags" id="assignPreviewNames"></div>
				</div>
				<button type="submit" class="btn-primary"
					style="width:100%;justify-content:center;padding:11px;margin-top:2px;">
					<i class="fa-solid fa-paper-plane"></i>
					<span id="assignSubmitLabel">Assign Task</span>
				</button>
			</form>
		</div>
	</div>
</div>

<script>
/* ══════════ DATA ══════════ */
const TEAMS = JSON.parse(document.getElementById('teams-json').textContent);
let selectedTeam   = null;
let modalEmployee  = null;
let selectedEmails = new Set();

/* ══════════ HELPERS ══════════ */
function getInitials(name) {
  if (!name) return '?';
  const p = name.trim().split(/\s+/);
  return (p[0][0] + (p[1] ? p[1][0] : '')).toUpperCase();
}
function esc(s) {
  if (!s) return '';
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ══════════ SUMMARY STATS ══════════ */
function computeSummaryStats() {
  var totalTeams=TEAMS.length, totalMembers=0, totalTasks=0, totalDone=0;
  TEAMS.forEach(function(tm){
    totalMembers += tm.memberCount;
    tm.members.forEach(function(m){ totalTasks += m.stats.total; totalDone += m.stats.completed; });
  });
  animateNum('statTeams',totalTeams); animateNum('statMembers',totalMembers);
  animateNum('statTasks',totalTasks); animateNum('statDone',totalDone);
}
function animateNum(id,target) {
  var el=document.getElementById(id); if(!el) return;
  var start=0,dur=800,step=16,inc=target/(dur/step);
  var iv=setInterval(function(){
    start=Math.min(start+inc,target); el.textContent=Math.round(start);
    if(start>=target) clearInterval(iv);
  },step);
}

/* ══════════ RENDER TEAMS ══════════ */
function renderTeams() {
  var grid=document.getElementById('teamsGrid');
  if (!TEAMS.length) {
    document.getElementById('noTeams').style.display='';
    document.querySelector('.section-label').style.display='none';
    return;
  }
  TEAMS.forEach(function(tm){
    var card=document.createElement('div');
    card.className='team-card';
    card.innerHTML=
      '<div class="tc-icon-wrap"><i class="fa-solid fa-people-group"></i></div>'+
      '<div class="tc-name">'+esc(tm.name)+'</div>'+
      '<div class="tc-mgr"><i class="fa-solid fa-user-tie"></i>'+esc(tm.manager)+'</div>'+
      '<div class="tc-foot">'+
        '<span class="tc-count"><i class="fa-solid fa-users"></i>'+tm.memberCount+' member'+(tm.memberCount!==1?'s':'')+'</span>'+
        '<span class="tc-badge">View →</span>'+
      '</div>';
    card.onclick=function(){ selectTeam(tm,card); };
    grid.appendChild(card);
  });
}

/* ══════════ TEAM SELECTION ══════════ */
function selectTeam(tm,cardEl) {
  selectedTeam=tm;
  document.querySelectorAll('.team-card').forEach(function(c){ c.classList.remove('selected'); });
  if (cardEl) cardEl.classList.add('selected');
  document.getElementById('detailTeamName').textContent=tm.name;
  document.getElementById('detailTeamLabel').textContent=tm.name;
  document.getElementById('detailTeamMgr').innerHTML='<i class="fa-solid fa-user-tie"></i> Manager: '+esc(tm.manager);
  document.getElementById('empCountBadge').textContent=tm.memberCount+' employee'+(tm.memberCount!==1?'s':'');
  document.getElementById('empSearch').value='';
  renderEmpTable(tm.members);
  var detail=document.getElementById('teamDetail');
  detail.style.display=''; detail.style.animation='none';
  void detail.offsetWidth; detail.style.animation='';
  setTimeout(function(){ detail.scrollIntoView({behavior:'smooth',block:'start'}); },60);
}
function backToTeams() {
  selectedTeam=null;
  document.getElementById('teamDetail').style.display='none';
  document.querySelectorAll('.team-card').forEach(function(c){ c.classList.remove('selected'); });
  window.scrollTo({top:0,behavior:'smooth'});
}

/* ══════════ EMP TABLE ══════════ */
function renderEmpTable(members) {
  var tbody=document.getElementById('empTableBody');
  tbody.innerHTML='';
  if (!members.length) { document.getElementById('empTableEmpty').style.display=''; return; }
  document.getElementById('empTableEmpty').style.display='none';
  members.forEach(function(m,i){
    var s=m.stats, barW=Math.max(0,Math.min(100,s.compPct));
    var tr=document.createElement('tr');
    tr.className='emp-table-row';
    tr.dataset.name=(m.name||'').toLowerCase();
    tr.style.animation='fadeUp .35s cubic-bezier(.22,1,.36,1) both';
    tr.style.animationDelay=(i*0.04)+'s';
    tr.innerHTML=
      '<td style="color:var(--text3);font-size:.65rem;font-family:\'Geist Mono\',monospace;font-weight:500;">'+String(i+1).padStart(2,'0')+'</td>'+
      '<td><div style="display:flex;align-items:center;gap:10px;">'+
        '<div class="emp-avatar">'+getInitials(m.name)+'</div>'+
        '<div><div class="emp-name">'+esc(m.name)+'</div><div class="emp-email">'+esc(m.email)+'</div></div>'+
      '</div></td>'+
      '<td><span class="desig-pill">'+esc(m.desig||'—')+'</span></td>'+
      '<td><span class="num num-default">'+s.total+'</span></td>'+
      '<td><span class="num num-green">'+s.completed+'</span></td>'+
      '<td><span class="num num-amber">'+s.open+'</span></td>'+
      '<td>'+(s.overdue>0?'<span class="num num-rose">'+s.overdue+'</span>':'<span class="num num-ghost">0</span>')+'</td>'+
      '<td style="min-width:120px;"><div style="display:flex;align-items:center;gap:8px;">'+
        '<div class="bar-wrap" style="flex:1;"><div class="bar-fill" style="width:'+barW+'%;"></div></div>'+
        '<span class="bar-pct">'+s.compPct+'%</span>'+
      '</div></td>'+
      '<td><div style="display:flex;align-items:center;gap:5px;">'+
        '<button onclick="openEmpModal(event,\''+m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'")+'\')" class="btn-sm btn-sm-blue"><i class="fa-solid fa-chart-bar"></i> Stats</button>'+
        '<button onclick="openAssignModal([\''+m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'")+'\'])" class="btn-sm btn-sm-ghost"><i class="fa-solid fa-plus"></i></button>'+
      '</div></td>';
    tr.onclick=function(e){ if(!e.target.closest('button')) openEmpModal(e,m.email); };
    tbody.appendChild(tr);
  });
}
function filterEmpTable(q) {
  var visible=0;
  document.querySelectorAll('.emp-table-row').forEach(function(r){
    var match=!q||r.dataset.name.includes(q.toLowerCase());
    r.style.display=match?'':'none';
    if(match) visible++;
  });
  document.getElementById('empTableEmpty').style.display=visible>0?'none':'';
}

/* ══════════ EMP STATS MODAL ══════════ */
function findMember(email) {
  return selectedTeam?(selectedTeam.members.find(function(m){return m.email===email;})||null):null;
}
function openEmpModal(e,email) {
  if(e) e.stopPropagation();
  var m=findMember(email); if(!m) return;
  modalEmployee=m;
  document.getElementById('modalAvatar').textContent=getInitials(m.name);
  document.getElementById('modalName').textContent=m.name;
  document.getElementById('modalDesig').textContent=m.desig||m.role||'';
  document.getElementById('modalEmail').textContent=m.email;
  var s=m.stats;
  document.getElementById('mStat-total').textContent=s.total;
  document.getElementById('mStat-done').textContent=s.completed;
  document.getElementById('mStat-open').textContent=s.open;
  document.getElementById('mStat-over').textContent=s.overdue;
  var circ=213.63, ring=document.getElementById('modalRingFill');
  ring.style.strokeDashoffset=circ;
  setTimeout(function(){ ring.style.strokeDashoffset=circ-(s.compPct/100)*circ; },80);
  document.getElementById('modalRingPct').textContent=s.compPct+'%';
  document.getElementById('modalCompLabel').textContent=s.completed+' of '+s.total+' tasks completed';
  var pillSub=document.getElementById('pill-submitted');
  if(s.submitted>0){ document.getElementById('pill-sub-val').textContent=s.submitted; pillSub.style.display=''; }
  else pillSub.style.display='none';
  document.querySelectorAll('#modalTabBar .tab-btn').forEach(function(t){ t.classList.remove('active'); });
  document.querySelector('#modalTabBar .tab-btn').classList.add('active');
  renderModalTasks('all');
  document.getElementById('empModal').classList.add('open');
  document.body.style.overflow='hidden';
}
function closeEmpModal() {
  document.getElementById('empModal').classList.remove('open');
  document.body.style.overflow='';
  modalEmployee=null;
}
function switchModalTab(tab,btn) {
  document.querySelectorAll('#modalTabBar .tab-btn').forEach(function(t){ t.classList.remove('active'); });
  if(btn) btn.classList.add('active');
  renderModalTasks(tab);
}
function renderModalTasks(tab) {
  if(!modalEmployee) return;
  var container=document.getElementById('modalTaskList');
  var tasks=modalEmployee.tasks||[];
  var today=new Date(); today.setHours(0,0,0,0);
  var filtered=tasks.filter(function(t){
    var ic=t.status==='COMPLETED', io=!ic&&t.deadline&&new Date(t.deadline)<today;
    switch(tab){ case 'completed':return ic; case 'open':return!ic; case 'overdue':return io; default:return true; }
  });
  if(!filtered.length){
    container.innerHTML='<div class="empty-state" style="border:none;padding:28px 0;"><i class="fa-solid fa-inbox" style="font-size:26px;"></i><strong>No tasks in this category</strong></div>';
    return;
  }
  container.innerHTML='<div style="font-size:.6rem;font-weight:700;letter-spacing:.10em;text-transform:uppercase;color:var(--text3);margin-bottom:10px;">'+filtered.length+' task'+(filtered.length!==1?'s':'')+'</div>';
  filtered.forEach(function(t){
    var ic=t.status==='COMPLETED', io=!ic&&t.deadline&&new Date(t.deadline)<today, ir=t.status==='SUBMITTED'||t.status==='PROCESSING';
    var pillCls,pillLabel;
    if(ic)      {pillCls='tp-done';    pillLabel='<i class="fa-solid fa-check-circle"></i> Done';}
    else if(ir) {pillCls='tp-review';  pillLabel='<i class="fa-solid fa-hourglass-half"></i> Review';}
    else if(io) {pillCls='tp-overdue'; pillLabel='<i class="fa-solid fa-exclamation-circle"></i> Overdue';}
    else        {pillCls='tp-open';    pillLabel='<i class="fa-solid fa-clock"></i> Open';}
    var prioCls=t.priority==='HIGH'?'prio-high':t.priority==='LOW'?'prio-low':'prio-medium';
    var deadlineLabel=t.deadline?(io?'<span style="color:var(--red);font-weight:700;">Due: '+t.deadline+'</span>':'<span>Due: '+t.deadline+'</span>'):'';
    var row=document.createElement('div');
    row.className='task-item';
    row.innerHTML='<div class="task-item-body"><div class="task-item-title">'+esc(t.title)+'</div>'+(t.desc?'<div class="task-item-desc">'+esc(t.desc)+'</div>':'')+
      '<div class="task-meta">'+deadlineLabel+(t.assigned?'<span>Assigned: '+t.assigned+'</span>':'')+
      '<span class="'+prioCls+'"><i class="fa-solid fa-flag" style="margin-right:3px;font-size:.6rem;"></i>'+t.priority+'</span></div></div>'+
      '<span class="t-pill '+pillCls+'">'+pillLabel+'</span>';
    container.appendChild(row);
  });
}

/* ══════════ PICKER ══════════ */
function buildPickerOptions(members,preselected) {
  var container=document.getElementById('empPickerOptions');
  container.innerHTML='';
  members.forEach(function(m){
    var opt=document.createElement('div');
    opt.className='picker-opt'+(preselected.includes(m.email)?' selected':'');
    opt.dataset.email=m.email; opt.dataset.name=(m.name||'').toLowerCase();
    opt.innerHTML='<input type="checkbox"'+(preselected.includes(m.email)?' checked':'')+' onclick="event.stopPropagation();togglePickerOption(\''+m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") +'\',this.checked)">'+
      '<div class="emp-avatar" style="width:26px;height:26px;font-size:.6rem;flex-shrink:0;">'+getInitials(m.name)+'</div>'+
      '<div style="flex:1;min-width:0;"><div style="font-weight:600;font-size:.78rem;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">'+esc(m.name)+'</div>'+
      '<div style="font-size:.65rem;color:var(--text3);font-family:\'Geist Mono\',monospace;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">'+esc(m.email)+'</div></div>';
    opt.onclick=function(){ togglePickerOption(m.email,!selectedEmails.has(m.email)); };
    container.appendChild(opt);
  });
}
function filterPickerOptions(q) {
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    opt.style.display=!q||opt.dataset.name.includes(q.toLowerCase())?'':'none';
  });
}
function togglePickerOption(email,checked) {
  var member=selectedTeam?selectedTeam.members.find(function(m){return m.email===email;}):null;
  if(!member) return;
  if(checked) selectedEmails.add(email); else selectedEmails.delete(email);
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    if(opt.dataset.email===email){
      opt.classList.toggle('selected',checked);
      var cb=opt.querySelector('input[type="checkbox"]');
      if(cb) cb.checked=checked;
    }
  });
  updatePickerUI();
}
function toggleSelectAll() {
  if(!selectedTeam) return;
  var allEmails=selectedTeam.members.map(function(m){return m.email;});
  var allChecked=allEmails.every(function(e){return selectedEmails.has(e);});
  if(allChecked) allEmails.forEach(function(e){selectedEmails.delete(e);});
  else allEmails.forEach(function(e){selectedEmails.add(e);});
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    var checked=selectedEmails.has(opt.dataset.email);
    opt.classList.toggle('selected',checked);
    var cb=opt.querySelector('input[type="checkbox"]'); if(cb) cb.checked=checked;
  });
  var allCb=document.getElementById('selectAllCb'); if(allCb) allCb.checked=!allChecked;
  updatePickerUI();
}
function updatePickerUI() {
  var chipsEl=document.getElementById('empPickerChips');
  var hiddenInputs=document.getElementById('empHiddenInputs');
  var selCount=document.getElementById('selCountLabel');
  var preview=document.getElementById('assignPreview');
  var previewCount=document.getElementById('assignPreviewCount');
  var previewNames=document.getElementById('assignPreviewNames');
  var submitLabel=document.getElementById('assignSubmitLabel');
  hiddenInputs.innerHTML='';
  selectedEmails.forEach(function(email){
    var inp=document.createElement('input');
    inp.type='hidden'; inp.name='employeeUsername'; inp.value=email;
    hiddenInputs.appendChild(inp);
  });
  if(selectedEmails.size===0){
    chipsEl.innerHTML='<span class="picker-ph">Select employees…</span>';
    selCount.textContent=''; preview.style.display='none'; submitLabel.textContent='Assign Task';
  } else {
    chipsEl.innerHTML='';
    selectedEmails.forEach(function(email){
      var member=selectedTeam?selectedTeam.members.find(function(m){return m.email===email;}):null;
      if(!member) return;
      var chip=document.createElement('span');
      chip.className='chip';
      chip.innerHTML=esc(member.name||email)+'<span class="chip-x" onclick="event.stopPropagation();togglePickerOption(\''+email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") +'\',false)">✕</span>';
      chipsEl.appendChild(chip);
    });
    var n=selectedEmails.size;
    selCount.textContent='('+n+' selected)';
    preview.style.display='';
    previewCount.textContent=n+' employee'+(n!==1?'s':'');
    previewNames.innerHTML='';
    selectedEmails.forEach(function(email){
      var member=selectedTeam?selectedTeam.members.find(function(m){return m.email===email;}):null;
      if(!member) return;
      var tag=document.createElement('span');
      tag.className='preview-tag'; tag.textContent=member.name||email;
      previewNames.appendChild(tag);
    });
    submitLabel.textContent=n>1?'Assign to '+n+' Employees':'Assign Task';
  }
  if(selectedTeam){
    var allCb=document.getElementById('selectAllCb');
    if(allCb) allCb.checked=selectedTeam.members.every(function(m){return selectedEmails.has(m.email);});
  }
  if(selectedEmails.size>0) document.getElementById('empPickerError').style.display='none';
}
function toggleEmpPicker() {
  var dd=document.getElementById('empPickerDropdown');
  var trigger=document.getElementById('empPickerTrigger');
  var chevron=document.getElementById('empPickerChevron');
  var isOpen=dd.classList.contains('open');
  dd.classList.toggle('open',!isOpen); trigger.classList.toggle('open',!isOpen);
  chevron.style.transform=isOpen?'rotate(0deg)':'rotate(180deg)';
  if(!isOpen){ var si=document.getElementById('empPickerSearchInput'); if(si){si.value='';filterPickerOptions('');si.focus();} }
}
function closeEmpPickerDropdown() {
  document.getElementById('empPickerDropdown').classList.remove('open');
  document.getElementById('empPickerTrigger').classList.remove('open');
  document.getElementById('empPickerChevron').style.transform='rotate(0deg)';
}

/* ══════════ ASSIGN MODAL ══════════ */
function openAssignModal(preselectedEmails) {
  if(!selectedTeam) return;
  selectedEmails.clear();
  if(preselectedEmails&&preselectedEmails.length)
    preselectedEmails.forEach(function(e){selectedEmails.add(e);});
  buildPickerOptions(selectedTeam.members,preselectedEmails||[]);
  updatePickerUI(); closeEmpPickerDropdown();
  var today=new Date(), pad=function(n){return n<10?'0'+n:''+n;};
  var todayStr=today.getFullYear()+'-'+pad(today.getMonth()+1)+'-'+pad(today.getDate());
  var dlEl=document.getElementById('assignModalDeadline');
  dlEl.min=todayStr; dlEl.value='';
  var form=document.getElementById('assignModalForm');
  form.querySelector('input[name="title"]').value='';
  form.querySelector('textarea[name="taskDesc"]').value='';
  document.getElementById('empPickerError').style.display='none';
  document.getElementById('assignModal').classList.add('open');
  document.body.style.overflow='hidden';
}
function openAssignFromModal() {
  var email=modalEmployee?modalEmployee.email:null;
  closeEmpModal();
  setTimeout(function(){ openAssignModal(email?[email]:[]); },220);
}
function closeAssignModal() {
  document.getElementById('assignModal').classList.remove('open');
  document.body.style.overflow=''; closeEmpPickerDropdown();
}
function validateAssignForm() {
  if(selectedEmails.size===0){
    document.getElementById('empPickerError').style.display='';
    document.getElementById('empPickerDropdown').classList.add('open');
    document.getElementById('empPickerTrigger').classList.add('open');
    document.getElementById('empPickerChevron').style.transform='rotate(180deg)';
    return false;
  }
  return true;
}

document.addEventListener('click',function(e){
  var wrapper=document.getElementById('empPickerWrapper');
  if(wrapper&&!wrapper.contains(e.target)) closeEmpPickerDropdown();
});
document.addEventListener('keydown',function(e){
  if(e.key==='Escape'){ closeEmpModal(); closeAssignModal(); }
});

/* ══════════ BOOT ══════════ */
computeSummaryStats();
renderTeams();
document.addEventListener('contextmenu',function(e){e.preventDefault();});
document.onkeydown=function(e){ return(e.keyCode===123||(e.ctrlKey&&e.shiftKey&&['I','J','C'].includes(e.key.toUpperCase())))?false:true; };

/* ══════════════════════════════════════════
   EXPORT — CSV (client-side)
══════════════════════════════════════════ */
function exportTeamTasksCsv() {
  if (!selectedTeam) return;

  var headers = ['#','Employee Name','Email','Designation',
                 'Task Title','Description','Status','Priority',
                 'Deadline','Assigned Date',
                 'Total','Completed','Open','Overdue','Completion %'];
  var rows = [];
  var n = 1;

  selectedTeam.members.forEach(function(m) {
    if (!m.tasks || !m.tasks.length) {
      rows.push([n++, m.name||'', m.email||'', m.desig||'',
                 '—','—','—','—','—','—',
                 m.stats.total, m.stats.completed, m.stats.open,
                 m.stats.overdue, m.stats.compPct+'%']);
    } else {
      m.tasks.forEach(function(t, ti) {
        rows.push([
          ti===0 ? n++ : '',
          ti===0 ? (m.name||'')  : '',
          ti===0 ? (m.email||'') : '',
          ti===0 ? (m.desig||'') : '',
          t.title||'', t.desc||'', t.status||'', t.priority||'',
          t.deadline||'', t.assigned||'',
          ti===0 ? m.stats.total      : '',
          ti===0 ? m.stats.completed  : '',
          ti===0 ? m.stats.open       : '',
          ti===0 ? m.stats.overdue    : '',
          ti===0 ? m.stats.compPct+'%': ''
        ]);
      });
    }
  });

  var csvEsc = function(v) {
    var s = String(v==null?'':v);
    return s.includes(',')||s.includes('"')||s.includes('\n')
      ? '"'+s.replace(/"/g,'""')+'"' : s;
  };
  var csv = [headers].concat(rows)
    .map(function(r){ return r.map(csvEsc).join(','); }).join('\r\n');
  var blob = new Blob(['\uFEFF'+csv], {type:'text/csv;charset=utf-8;'});
  var teamName = (selectedTeam.name||'team').replace(/[^a-z0-9]/gi,'_');
  _triggerDownload(blob, teamName+'_tasks_'+new Date().toISOString().slice(0,10)+'.csv');
}

/* ══════════════════════════════════════════
   EXPORT — Excel (server-side via ExportTeamTasksServlet)
   Uses same POI styling as ExportTeamAttendanceServlet:
   - Indigo (#3F51B5) header rows
   - Color-coded status & priority cells
   - Freeze panes, alternating employee shading, Legend sheet
══════════════════════════════════════════ */
function exportTeamTasksXlsx() {
  if (!selectedTeam) return;

  var btn = document.getElementById('exportXlsxBtn');
  var origHTML = btn.innerHTML;

  /* Loading state */
  btn.classList.add('loading');
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Generating…';

  /* Hit the servlet — browser will trigger download automatically */
  var url = '<%=request.getContextPath()%>/exportTeamTasks?teamId=' + selectedTeam.id;
  window.location.href = url;

  /* Restore button after a moment */
  setTimeout(function() {
    btn.classList.remove('loading');
    btn.innerHTML = origHTML;
  }, 3000);
}

function _triggerDownload(blob, name) {
  var url = URL.createObjectURL(blob);
  var a = document.createElement('a');
  a.href = url; a.download = name;
  document.body.appendChild(a); a.click();
  setTimeout(function(){ document.body.removeChild(a); URL.revokeObjectURL(url); }, 200);
}
</script>
</body>
</html>
