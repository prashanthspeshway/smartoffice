<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.dao.NotificationReadsDAO"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}
int unreadNotifCount = 0;
try {
	unreadNotifCount = new NotificationReadsDAO().getUnreadCount(username);
} catch (Exception ignored) {
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manager Dashboard • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
	rel="stylesheet">
<style>
body {
	font-family: 'Inter', system-ui, sans-serif;
}
.notif-trigger { position: relative; }
.notif-badge {
	position: absolute;
	top: -2px;
	right: -2px;
	z-index: 2;
	box-sizing: border-box;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 1.25rem;
	height: 1.25rem;
	min-width: 1.25rem;
	min-height: 1.25rem;
	padding: 0;
	font-size: 0.6875rem;
	font-weight: 800;
	letter-spacing: 0;
	line-height: 0;
	color: #fff;
	background: linear-gradient(180deg, #f87171 0%, #ef4444 45%, #dc2626 100%);
	border-radius: 50%;
	border: 2px solid #fff;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.22);
	font-variant-numeric: tabular-nums;
}
.notif-badge.notif-badge--pill {
	width: auto;
	min-width: 1.25rem;
	height: 1.25rem;
	min-height: 1.25rem;
	padding: 0 0.35rem;
	border-radius: 9999px;
	font-size: 0.5625rem;
}
.notif-badge.hidden { display: none !important; }
</style>
</head>
<body class="bg-slate-100 min-h-screen flex flex-col">

	<!-- Top Bar -->
	<header
		class="bg-white border-b border-slate-200 px-6 py-4 flex justify-between items-center shadow-sm">
		<h1 class="text-xl font-semibold text-slate-800">Smart Office •
			Manager Dashboard</h1>
		<div class="flex items-center gap-4">
			<button type="button" onclick="openManagerNotifications()"
				class="notif-trigger group relative inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-slate-200/90 bg-white text-slate-600 shadow-sm transition-all hover:border-slate-300 hover:bg-slate-50 hover:text-slate-900 hover:shadow focus:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500/35"
				title="Notifications" aria-label="Notifications">
				<i class="fa-regular fa-bell pointer-events-none text-[1.15rem] transition-transform duration-200 group-hover:scale-105" aria-hidden="true"></i>
				<span id="notifBadge" role="status"
					class="notif-badge <%= unreadNotifCount > 0 ? "" : "hidden" %> <%= unreadNotifCount > 9 ? "notif-badge--pill" : "" %>"><%= unreadNotifCount > 99 ? "99+" : unreadNotifCount %></span>
			</button>
			<span class="text-sm text-slate-600">Welcome, <strong
				class="text-slate-800">${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
		</div>
	</header>

	<!-- Main Layout -->
	<div class="flex flex-1 overflow-hidden">
		<!-- Sidebar -->
		<aside
			class="w-64 bg-white border-r border-slate-200 flex flex-col shadow-sm">
			<nav class="flex-1 py-4 px-3">
				<button type="button" data-manager-view="managerOverview" onclick="loadPage(this,'managerOverview')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-chart-pie w-5"></i> <span>Overview</span>
				</button>
				<button type="button" data-manager-view="managerAttendance" onclick="loadPage(this,'managerAttendance')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-user-check w-5"></i> <span>Attendance</span>
				</button>
				<button type="button" data-manager-view="managerTeams" onclick="loadPage(this,'managerTeams')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-people-group w-5"></i> <span>My Team</span>
				</button>
				<button type="button" data-manager-view="managerTasks" onclick="loadPage(this,'managerTasks')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-list-check w-5"></i> <span>Tasks</span>
				</button>
				<button type="button" data-manager-view="managerMeetings" onclick="loadPage(this,'managerMeetings')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-video w-5"></i> <span>Meetings</span>
				</button>
				<button type="button" data-manager-view="managerLeave" onclick="loadPage(this,'managerLeave')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-xmark w-5"></i> <span>Leave</span>
				</button>
				<button type="button" data-manager-view="managerPerformance" onclick="loadPage(this,'managerPerformance')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-chart-line w-5"></i> <span>Performance</span>
				</button>
				<button type="button" data-manager-view="calendar.jsp" onclick="loadPage(this,'calendar.jsp')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-days w-5"></i> <span>Calendar</span>
				</button>
			</nav>
			<div class="border-t border-slate-200 px-3 py-4">
				<button type="button" data-manager-view="managerSettings" onclick="loadPage(this,'managerSettings')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-gear w-5"></i> <span>Settings</span>
				</button>
				<a href="<%=request.getContextPath()%>/logout"
					class="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-red-600 hover:bg-red-50 transition-colors font-medium">
					<i class="fa-solid fa-right-to-bracket w-5"></i> <span>Logout</span>
				</a>
			</div>
		</aside>

		<!-- Content Area -->
		<main class="flex-1 overflow-auto bg-slate-100">
			<iframe id="contentFrame" src="managerOverview"
				class="w-full h-full border-0"></iframe>
		</main>
	</div>

	<!-- Toast -->
	<div id="toast"
		class="toast fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg hidden text-sm font-medium"></div>

	<script>
	function syncManagerUrl(page) {
		try {
			var qs = new URLSearchParams(window.location.search);
			qs.set('view', page);
			var q = qs.toString();
			window.history.replaceState({}, document.title, window.location.pathname + (q ? '?' + q : ''));
		} catch (e) { /* ignore */ }
	}

	function openManagerNotifications() {
		document.getElementById('contentFrame').src = 'sharedNotifications.jsp';
	}

	function applyManagerViewFromUrl() {
		var qs = new URLSearchParams(window.location.search);
		var view = qs.get('view');
		if (!view) return false;
		var target = null;
		document.querySelectorAll('.sidebar-btn[data-manager-view]').forEach(function (b) {
			if (b.getAttribute('data-manager-view') === view) target = b;
		});
		if (!target) return false;
		document.getElementById('contentFrame').src = view;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		target.classList.add('bg-indigo-50', 'text-indigo-700');
		return true;
	}

	function loadPage(btn, page) {
		document.getElementById('contentFrame').src = page;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		if (btn) btn.classList.add('bg-indigo-50', 'text-indigo-700');
		syncManagerUrl(page);
	}
	function updateBadge() {
		fetch('<%=request.getContextPath()%>/notificationCount', { credentials: 'same-origin' })
			.then(function(r) { return r.json(); })
			.then(function(d) {
				var el = document.getElementById('notifBadge');
				if (!el) return;
				var n = (d && typeof d.count === 'number') ? d.count : 0;
				if (n > 0) {
					el.textContent = n > 99 ? '99+' : String(n);
					el.classList.remove('hidden');
					if (n > 9) el.classList.add('notif-badge--pill');
					else el.classList.remove('notif-badge--pill');
				} else {
					el.classList.add('hidden');
					el.classList.remove('notif-badge--pill');
				}
			})
			.catch(function() {});
	}
	window.updateBadge = updateBadge;
	document.addEventListener('DOMContentLoaded', function() {
		applyManagerViewFromUrl();
		const params = new URLSearchParams(window.location.search);
		if (!params.get('view')) {
			var btns = document.querySelectorAll('.sidebar-btn');
			var overviewBtn = Array.from(btns).find(function(b) { return b.textContent.indexOf('Overview') >= 0; });
			if (overviewBtn) overviewBtn.classList.add('bg-indigo-50', 'text-indigo-700');
			else if (btns[0]) btns[0].classList.add('bg-indigo-50', 'text-indigo-700');
		}
		if (params.get('success') === 'Login') {
			showToast('Logged in successfully', 'info');
			params.delete('success');
			params.delete('error');
			var q = params.toString();
			window.history.replaceState({}, document.title, window.location.pathname + (q ? '?' + q : ''));
		}
		if (params.get('error') === 'accessDenied') {
			showToast('Access denied. You do not have permission for that page.', 'error');
			params.delete('error');
			var qe = params.toString();
			window.history.replaceState({}, document.title, window.location.pathname + (qe ? '?' + qe : ''));
		}
		updateBadge();
		setInterval(updateBadge, 90000);
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
