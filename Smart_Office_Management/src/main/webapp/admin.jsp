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
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>
/* Notification bell + badge — circle (1–9) vs pill (10+) */
.notif-trigger {
	position: relative;
}

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

.notif-badge.hidden {
	display: none !important;
}

/* Top bar only: charcoal + subtle depth (matches sidebar tone; soft highlight like a matte bar) */
#adminShellHeader.so-header {
	background:
		linear-gradient(180deg, rgba(255, 255, 255, 0.055) 0%, rgba(255, 255, 255, 0) 42%),
		linear-gradient(180deg, #343434 0%, var(--so-sidebar-bg) 45%, #232323 100%) !important;
	border-color: var(--so-sidebar-border) !important;
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.06);
}
#adminShellHeader.so-header h1 {
	color: rgba(255, 255, 255, 0.95) !important;
}
#adminShellHeader .so-welcome {
	color: rgba(255, 255, 255, 0.75) !important;
}
#adminShellHeader .so-welcome strong,
#adminShellHeader strong.text-slate-800 {
	color: #ffffff !important;
}
#adminShellHeader .so-menu-btn {
	border-color: rgba(255, 255, 255, 0.22) !important;
	background: transparent !important;
	color: rgba(255, 255, 255, 0.92) !important;
}
#adminShellHeader .so-menu-btn:hover {
	background: var(--so-sidebar-hover) !important;
	color: #ffffff !important;
}
#adminShellHeader .notif-trigger {
	border-color: rgba(255, 255, 255, 0.22) !important;
	background: transparent !important;
	color: rgba(255, 255, 255, 0.92) !important;
}
#adminShellHeader .notif-trigger:hover {
	background: var(--so-sidebar-hover) !important;
	color: #ffffff !important;
}
#adminShellHeader .notif-badge {
	border-color: #232323 !important;
}
</style>
</head>
<body
	class="so-shell bg-slate-100 min-h-screen flex flex-col h-screen overflow-hidden">

	<!-- Top Bar (charcoal matches .so-sidebar via #adminShellHeader rules above) -->
	<header id="adminShellHeader"
		class="so-header border-b flex flex-wrap gap-2 justify-between items-center shrink-0">
		<div class="flex items-center gap-2 min-w-0 flex-1">
			<button type="button" id="adminMobileNavToggle"
				class="so-menu-btn md:hidden inline-flex shrink-0 items-center justify-center border shadow-sm"
				aria-label="Open navigation menu" aria-expanded="false"
				aria-controls="adminSidebar">
				<i class="fa-solid fa-bars text-lg" aria-hidden="true"></i>
			</button>
			<h1 class="truncate min-w-0">AdminDashboard</h1>
		</div>
		<div class="flex items-center gap-2 sm:gap-4 shrink-0">
			<button type="button" onclick="openAdminNotifications()"
				class="notif-trigger group relative inline-flex shrink-0 items-center justify-center border shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-white/25"
				title="Notifications" aria-label="Notifications">
				<i
					class="fa-regular fa-bell pointer-events-none text-[1.15rem] transition-transform duration-200 group-hover:scale-105"
					aria-hidden="true"></i> <span id="notifBadge" role="status"
					class="notif-badge <%=unreadNotifCount > 0 ? "" : "hidden"%> <%=unreadNotifCount > 9 ? "notif-badge--pill" : ""%>"><%=unreadNotifCount > 99 ? "99+" : unreadNotifCount%></span>
			</button>
			<span
				class="so-welcome truncate max-w-[min(42vw,200px)] sm:max-w-none">Welcome,
				<strong class="text-slate-800">${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong>
			</span>
		</div>
	</header>

	<div id="adminNavOverlay"
		class="fixed inset-0 z-40 bg-slate-900/50 md:hidden hidden"
		aria-hidden="true"></div>

	<!-- Main Layout -->
	<div class="flex flex-1 min-h-0 overflow-hidden relative">
		<!-- Sidebar -->
		<aside id="adminSidebar"
			class="so-sidebar fixed md:relative z-50 inset-y-0 left-0 max-w-[min(85vw,var(--so-sidebar-width))] w-full min-w-0 h-full md:h-auto border-r border-slate-200 flex flex-col shadow-lg md:shadow-sm transform transition-transform duration-200 ease-out -translate-x-full md:translate-x-0 overflow-hidden">
			<nav class="flex-1 py-4 px-3 overflow-y-auto min-h-0">
				<button type="button" data-admin-view="adminOverview"
					onclick="loadPage(this,'adminOverview')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-chart-line w-5"></i> <span>Admin
						Overview</span>
				</button>
				<button type="button" data-admin-view="viewUser"
					onclick="loadPage(this,'viewUser')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-users w-5"></i> <span>Employees</span>
				</button>
				<button type="button" data-admin-view="adminAttendance"
					onclick="loadPage(this,'adminAttendance')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-user-check w-5"></i> <span>Attendance</span>
				</button>
				<button type="button" data-admin-view="adminTasks"
					onclick="loadPage(this,'adminTasks')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-list-check w-5"></i> <span>Tasks</span>
				</button>
				<button type="button" data-admin-view="teams"
					onclick="loadPage(this,'teams')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-people-group w-5"></i> <span>Teams</span>
				</button>
				<button type="button" data-admin-view="adminMeetings"
					onclick="loadPage(this,'adminMeetings')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900">
					<i class="fa-solid fa-video"></i> <span>Meetings</span>
				</button>
				<button type="button" data-admin-view="calendar.jsp"
					onclick="loadPage(this,'calendar.jsp')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-days w-5"></i> <span>Calendar</span>
				</button>
				<button type="button" data-admin-view="adminLeave"
					onclick="loadPage(this,'adminLeave')"
					class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
					<i class="fa-solid fa-calendar-xmark w-5"></i> <span>Leave</span>
				</button>
			</nav>
			<div class="border-t border-slate-200 px-3 py-4">
				<button type="button" data-admin-view="adminSettingsPage.jsp"
					onclick="loadPage(this,'adminSettingsPage.jsp')"
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
		<main
			class="so-main flex-1 min-h-0 overflow-auto bg-slate-100 flex flex-col w-full min-w-0">
			<iframe id="contentFrame" src="adminOverview"
				class="w-full flex-1 min-h-[50vh] md:min-h-0 border-0 block"
				title="Admin content"></iframe>
		</main>
	</div>

	<div id="toast" aria-live="polite"></div>

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
	var ADMIN_VIEW_STORAGE_KEY = 'so_admin_dash_view';

	function stripAdminViewQueryFromUrl() {
		var u = new URL(window.location.href);
		u.searchParams.delete('view');
		u.searchParams.delete('tab');
		window.history.replaceState({}, document.title, u.pathname + (u.search || ''));
	}

	/** Persist section in sessionStorage and keep the address bar free of ?view= */
	function syncAdminUrl(page) {
		if (!page) return;
		try { sessionStorage.setItem(ADMIN_VIEW_STORAGE_KEY, page); } catch (e) {}
		stripAdminViewQueryFromUrl();
	}

	/** Notifications iframe — same storage + clean URL as sidebar */
	function openAdminNotifications() {
		document.getElementById('contentFrame').src = 'sharedNotifications.jsp';
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		syncAdminUrl('sharedNotifications.jsp');
		closeAdminMobileNav();
	}

	function loadPage(btn, page) {
		document.getElementById('contentFrame').src = page;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		if (btn) btn.classList.add('bg-indigo-50', 'text-indigo-700');
		syncAdminUrl(page);
		closeAdminMobileNav();
	}

	function resolveAdminViewFromParams(params) {
		var view = params.get('view');
		var tab = params.get('tab');
		if (tab) {
			if (tab === 'attendance') view = view || 'adminAttendance';
			if (tab === 'overview') view = view || 'adminOverview';
			if (tab === 'users') view = view || 'viewUser';
		}
		return view;
	}

	function applyAdminViewToFrame(view) {
		if (!view) return false;
		var frame = document.getElementById('contentFrame');
		if (view === 'sharedNotifications.jsp') {
			frame.src = 'sharedNotifications.jsp';
			document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
			return true;
		}
		var target = null;
		document.querySelectorAll('.sidebar-btn[data-admin-view]').forEach(function (b) {
			if (b.getAttribute('data-admin-view') === view) target = b;
		});
		if (!target) return false;
		frame.src = view;
		document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('bg-indigo-50', 'text-indigo-700'));
		target.classList.add('bg-indigo-50', 'text-indigo-700');
		return true;
	}

	/** URL ?view= (legacy/bookmarks) or sessionStorage; then remove view/tab from visible URL */
	function applyAdminDashboardView() {
		var params = new URLSearchParams(window.location.search);
		var view = resolveAdminViewFromParams(params);
		var fromUrl = !!view;
		if (!view) {
			try { view = sessionStorage.getItem(ADMIN_VIEW_STORAGE_KEY); } catch (e) {}
		}
		if (!view) return false;
		if (!applyAdminViewToFrame(view)) return false;
		try { sessionStorage.setItem(ADMIN_VIEW_STORAGE_KEY, view); } catch (e) {}
		if (fromUrl) stripAdminViewQueryFromUrl();
		return true;
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

	// ── WebSocket live updates ──
	(function initLiveUpdates() {
		var ctx = '<%=request.getContextPath()%>';
		var proto = (location.protocol === 'https:') ? 'wss://' : 'ws://';
		var wsUrl = proto + location.host + ctx + '/ws/live';
		var backoffMs = 1000;
		var maxBackoff = 15000;
		var ws;

		function safeJsonParse(s) { try { return JSON.parse(s); } catch (e) { return null; } }
		function refreshIfOn(viewPrefix) {
			var frame = document.getElementById('contentFrame');
			if (!frame || !frame.src) return;
			if (frame.src.indexOf('/' + viewPrefix) !== -1 || frame.src.endsWith('/' + viewPrefix) || frame.src.indexOf(viewPrefix) !== -1) {
				try { frame.contentWindow.location.reload(); } catch (e) { frame.src = frame.src; }
			}
		}
		function maybeRefreshForType(type) {
			var t = String(type || '').toUpperCase();
			if (t === 'TASK') refreshIfOn('adminTasks');
			if (t === 'LEAVE') refreshIfOn('adminLeave');
			if (t === 'MEETING') refreshIfOn('adminMeetings');
			refreshIfOn('adminOverview');
		}

		function connect() {
			try { ws = new WebSocket(wsUrl); } catch (e) { scheduleReconnect(); return; }
			ws.onopen = function() { backoffMs = 1000; };
			ws.onclose = function() { scheduleReconnect(); };
			ws.onerror = function() { try { ws.close(); } catch (e) {} };
			ws.onmessage = function(ev) {
				var data = safeJsonParse(ev.data);
				if (!data || data.kind !== 'notification') return;
				updateBadge();
				maybeRefreshForType(data.type);
			};
		}
		function scheduleReconnect() {
			setTimeout(connect, backoffMs);
			backoffMs = Math.min(maxBackoff, Math.round(backoffMs * 1.6));
		}
		connect();
	})();
	document.addEventListener('DOMContentLoaded', function() {
		var t = document.getElementById('adminMobileNavToggle');
		var o = document.getElementById('adminNavOverlay');
		if (t) t.addEventListener('click', function(e) { e.stopPropagation(); toggleAdminMobileNav(); });
		if (o) o.addEventListener('click', closeAdminMobileNav);
		window.addEventListener('resize', function() {
			if (window.matchMedia('(min-width: 768px)').matches) closeAdminMobileNav();
		});
		var appliedView = applyAdminDashboardView();
		var params = new URLSearchParams(window.location.search);
		if (!appliedView) {
			var btns = document.querySelectorAll('.sidebar-btn');
			var overviewBtn = Array.from(btns).find(function(b) { return b.textContent.indexOf('Admin Overview') >= 0; });
			if (overviewBtn) overviewBtn.classList.add('bg-indigo-50', 'text-indigo-700');
			else if (btns[0]) btns[0].classList.add('bg-indigo-50', 'text-indigo-700');
		}
		if (params.get('success') === 'Login') {
			showToast('Logged in successfully', 'success');
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
	// NOTE: removed aggressive 500ms polling; live updates come via WebSocket now.

	/* showToast: js/smart-office-toast.js */

	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
