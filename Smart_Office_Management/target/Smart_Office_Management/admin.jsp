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
<title>AdminDashboard • Smart Office HRMS</title>
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
/* Notification bell + badge — circle (1–9) vs pill (10+) */
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
/* Wider label for 10+ or "99+" — same height as circle, no vertical squeeze */
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
<body class="bg-slate-100 min-h-screen flex flex-col h-screen overflow-hidden">

	<!-- Top Bar -->
	<header
		class="bg-white border-b border-slate-200 px-3 sm:px-6 py-3 sm:py-4 flex flex-wrap gap-2 justify-between items-center shadow-sm shrink-0">
		<div class="flex items-center gap-2 min-w-0 flex-1">
			<button type="button" id="adminMobileNavToggle" class="md:hidden inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50" aria-label="Open navigation menu" aria-expanded="false" aria-controls="adminSidebar">
				<i class="fa-solid fa-bars text-lg" aria-hidden="true"></i>
			</button>
			<h1 class="text-base sm:text-xl font-semibold text-slate-800 truncate min-w-0">Smart Office •
				AdminDashboard</h1>
		</div>
		<div class="flex items-center gap-2 sm:gap-4 shrink-0">
			<button type="button" onclick="openAdminNotifications()"
				class="notif-trigger group relative inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-slate-200/90 bg-white text-slate-600 shadow-sm transition-all hover:border-slate-300 hover:bg-slate-50 hover:text-slate-900 hover:shadow focus:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500/35"
				title="Notifications" aria-label="Notifications">
				<i class="fa-regular fa-bell pointer-events-none text-[1.15rem] transition-transform duration-200 group-hover:scale-105" aria-hidden="true"></i>
				<span id="notifBadge" role="status"
					class="notif-badge <%= unreadNotifCount > 0 ? "" : "hidden" %> <%= unreadNotifCount > 9 ? "notif-badge--pill" : "" %>"><%= unreadNotifCount > 99 ? "99+" : unreadNotifCount %></span>
			</button>
			<span class="text-xs sm:text-sm text-slate-600 truncate max-w-[min(42vw,200px)] sm:max-w-none">Welcome, <strong
				class="text-slate-800">${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
		</div>
	</header>

	<div id="adminNavOverlay" class="fixed inset-0 z-40 bg-slate-900/50 md:hidden hidden" aria-hidden="true"></div>

	<!-- Main Layout -->
	<div class="flex flex-1 min-h-0 overflow-hidden relative">
		<!-- Sidebar -->
		<aside id="adminSidebar"
			class="fixed md:relative z-50 inset-y-0 left-0 w-64 max-w-[85vw] h-full md:h-auto bg-white border-r border-slate-200 flex flex-col shadow-lg md:shadow-sm transform transition-transform duration-200 ease-out -translate-x-full md:translate-x-0 overflow-hidden">
			<nav class="flex-1 py-4 px-3 overflow-y-auto min-h-0">
				<button type="button" data-admin-view="adminOverview" onclick="loadPage(this,'adminOverview')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-chart-line w-5"></i> <span>Admin
						Overview</span>
				</button>
				<button type="button" data-admin-view="viewUser" onclick="loadPage(this,'viewUser')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-users w-5"></i> <span>Employees</span>
				</button>
				<button type="button" data-admin-view="adminAttendance" onclick="loadPage(this,'adminAttendance')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-user-check w-5"></i> <span>Attendance</span>
				</button>
				<button type="button" data-admin-view="adminTasks" onclick="loadPage(this,'adminTasks')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-list-check w-5"></i> <span>Tasks</span>
				</button>
				<button type="button" data-admin-view="teams" onclick="loadPage(this,'teams')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-people-group w-5"></i> <span>Teams</span>
				</button>
				<button type="button" data-admin-view="adminMeetings" onclick="loadPage(this,'adminMeetings')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900">
					<i class="fa-solid fa-video"></i> <span>Meetings</span>
				</button>
				<button type="button" data-admin-view="calendar.jsp" onclick="loadPage(this,'calendar.jsp')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-days w-5"></i> <span>Calendar</span>
				</button>
				<button type="button" data-admin-view="adminLeave" onclick="loadPage(this,'adminLeave')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-xmark w-5"></i> <span>Leave</span>
				</button>
			</nav>
			<div class="border-t border-slate-200 px-3 py-4">
				<button type="button" data-admin-view="adminSettingsPage.jsp" onclick="loadPage(this,'adminSettingsPage.jsp')"
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
		<main class="flex-1 min-h-0 overflow-auto bg-slate-100 flex flex-col w-full min-w-0">
			<iframe id="contentFrame" src="adminOverview"
				class="w-full flex-1 min-h-[50vh] md:min-h-0 border-0 block" title="Admin content"></iframe>
		</main>
	</div>

	<!-- Toast -->
	<div id="toast"
		class="toast fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg hidden text-sm font-medium"></div>

	<script>
	function closeAdminMobileNav() {
		var aside = document.getElementById('adminSidebar');
		var overlay = document.getElementById('adminNavOverlay');
		var toggle = document.getElementById('adminMobileNavToggle');
		if (aside) { aside.classList.add('-translate-x-full'); aside.classList.remove('translate-x-0'); }
		if (overlay) overlay.classList.add('hidden');
		if (toggle) { toggle.setAttribute('aria-expanded', 'false'); }
	}
	function openAdminMobileNav() {
		var aside = document.getElementById('adminSidebar');
		var overlay = document.getElementById('adminNavOverlay');
		var toggle = document.getElementById('adminMobileNavToggle');
		if (window.matchMedia('(min-width: 768px)').matches) return;
		if (aside) { aside.classList.remove('-translate-x-full'); aside.classList.add('translate-x-0'); }
		if (overlay) overlay.classList.remove('hidden');
		if (toggle) { toggle.setAttribute('aria-expanded', 'true'); }
	}
	function toggleAdminMobileNav() {
		var aside = document.getElementById('adminSidebar');
		if (!aside) return;
		if (aside.classList.contains('-translate-x-full')) openAdminMobileNav();
		else closeAdminMobileNav();
	}
	function syncAdminUrl(page) {
		try {
			var qs = new URLSearchParams(window.location.search);
			qs.set('view', page);
			var q = qs.toString();
			window.history.replaceState({}, document.title, window.location.pathname + (q ? '?' + q : ''));
		} catch (e) { /* ignore */ }
	}

	/** Notifications overlay iframe — does not change ?view= so refresh returns to last section */
	function openAdminNotifications() {
		document.getElementById('contentFrame').src = 'sharedNotifications.jsp';
		closeAdminMobileNav();
	}

	function loadPage(btn, page) {
		document.getElementById('contentFrame').src = page;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		if (btn) btn.classList.add('bg-indigo-50', 'text-indigo-700');
		syncAdminUrl(page);
		closeAdminMobileNav();
	}

	function applyAdminViewFromUrl() {
		var qs = new URLSearchParams(window.location.search);
		var view = qs.get('view');
		if (!view) return;
		var target = null;
		document.querySelectorAll('.sidebar-btn[data-admin-view]').forEach(function (b) {
			if (b.getAttribute('data-admin-view') === view) target = b;
		});
		if (!target) return;
		document.getElementById('contentFrame').src = view;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		target.classList.add('bg-indigo-50', 'text-indigo-700');
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
		var t = document.getElementById('adminMobileNavToggle');
		var o = document.getElementById('adminNavOverlay');
		if (t) t.addEventListener('click', function(e) { e.stopPropagation(); toggleAdminMobileNav(); });
		if (o) o.addEventListener('click', closeAdminMobileNav);
		window.addEventListener('resize', function() {
			if (window.matchMedia('(min-width: 768px)').matches) closeAdminMobileNav();
		});
		applyAdminViewFromUrl();
		const params = new URLSearchParams(window.location.search);
		if (!params.get('view')) {
			var btns = document.querySelectorAll('.sidebar-btn');
			var overviewBtn = Array.from(btns).find(function(b) { return b.textContent.indexOf('Admin Overview') >= 0; });
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
