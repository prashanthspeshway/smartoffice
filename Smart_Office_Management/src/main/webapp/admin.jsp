<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AdminDashboard • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }
</style>
</head>
<body class="bg-slate-100 min-h-screen flex flex-col">

	<!-- Top Bar -->
	<header class="bg-white border-b border-slate-200 px-6 py-4 flex justify-between items-center shadow-sm">
		<h1 class="text-xl font-semibold text-slate-800">Smart Office • AdminDashboard</h1>
		<div class="flex items-center gap-4">
			<button onclick="loadPage(this,'sendNotification.jsp')" class="w-10 h-10 rounded-full bg-indigo-500 hover:bg-indigo-600 text-white flex items-center justify-center transition-colors">
				<i class="fa-solid fa-bell"></i>
			</button>
			<span class="text-sm text-slate-600">Welcome, <strong class="text-slate-800">${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
		</div>
	</header>

	<!-- Main Layout -->
	<div class="flex flex-1 overflow-hidden">
		<!-- Sidebar -->
		<aside class="w-64 bg-white border-r border-slate-200 flex flex-col shadow-sm">
			<nav class="flex-1 py-4 px-3">
				<button onclick="loadPage(this,'adminOverview')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-chart-line w-5"></i>
					<span>Admin Overview</span>
				</button>
				<button onclick="loadPage(this,'viewUser')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-users w-5"></i>
					<span>Employees</span>
				</button>
				<button onclick="loadPage(this,'adminAttendance')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-user-check w-5"></i>
					<span>Attendance</span>
				</button>
				<button onclick="loadPage(this,'adminTasks')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-list-check w-5"></i>
					<span>Tasks</span>
				</button>
				<button onclick="loadPage(this,'teams')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-people-group w-5"></i>
					<span>Teams</span>
				</button>
				<button onclick="loadPage(this,'calendar.jsp')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-days w-5"></i>
					<span>Calendar</span>
				</button>
				<button onclick="loadPage(this,'adminLeave')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-xmark w-5"></i>
					<span>Leave</span>
				</button>
			</nav>
			<div class="border-t border-slate-200 px-3 py-4">
				<button onclick="loadPage(this,'adminSettingsPage.jsp')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-gear w-5"></i>
					<span>Settings</span>
				</button>
				<a href="<%=request.getContextPath()%>/logout" class="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-red-600 hover:bg-red-50 transition-colors font-medium">
					<i class="fa-solid fa-right-to-bracket w-5"></i>
					<span>Logout</span>
				</a>
			</div>
		</aside>

		<!-- Content Area -->
		<main class="flex-1 overflow-auto bg-slate-100">
			<iframe id="contentFrame" src="adminOverview" class="w-full h-full border-0"></iframe>
		</main>
	</div>

	<!-- Toast -->
	<div id="toast" class="toast fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg hidden text-sm font-medium"></div>

	<script>
	function loadPage(btn, page) {
		document.getElementById('contentFrame').src = page;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		if (btn) btn.classList.add('bg-indigo-50', 'text-indigo-700');
	}
	document.addEventListener('DOMContentLoaded', function() {
		var btns = document.querySelectorAll('.sidebar-btn');
		var overviewBtn = Array.from(btns).find(function(b) { return b.textContent.indexOf('Admin Overview') >= 0; });
		if (overviewBtn) overviewBtn.classList.add('bg-indigo-50', 'text-indigo-700');
		else if (btns[0]) btns[0].classList.add('bg-indigo-50', 'text-indigo-700');
		const params = new URLSearchParams(window.location.search);
		if (params.get('success') === 'Login') {
			showToast('Logged in successfully', 'info');
			window.history.replaceState({}, document.title, window.location.pathname);
		}
		if (params.get('error') === 'accessDenied') {
			showToast('Access denied. You do not have permission for that page.', 'error');
		}
	});

	function showToast(message, type) {
		const toast = document.getElementById('toast');
		toast.className = 'toast fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg text-sm font-medium';
		if (type === 'success') toast.classList.add('bg-emerald-500', 'text-white');
		else if (type === 'error') toast.classList.add('bg-red-500', 'text-white');
		else toast.classList.add('bg-indigo-500', 'text-white');
		toast.textContent = message;
		toast.classList.remove('hidden');
		setTimeout(() => toast.classList.add('hidden'), 2500);
	}

	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
