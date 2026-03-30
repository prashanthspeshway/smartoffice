<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.dao.NotificationReadsDAO"%>
<%@ page import="com.smartoffice.utils.AuthRedirectUtil"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
    AuthRedirectUtil.sendTopWindowRedirect(request, response, "/index.html");
    return;
}
User userObj = (User) request.getAttribute("user");
String ctxPath = request.getContextPath();
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
<title>Employee Dashboard • Smart Office</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<script src="<%= ctxPath %>/js/smart-office-toast.js"></script>
<style>
.sidebar-btn { transition: all 0.2s; text-align: left; }
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
<body class="so-shell bg-slate-100 min-h-screen flex flex-col h-screen overflow-hidden">

<!-- Top Bar -->
<header class="so-header bg-white border-b border-slate-200 flex flex-wrap gap-2 justify-between items-center shadow-sm shrink-0">
    <div class="flex items-center gap-2 min-w-0 flex-1">
        <button type="button" id="userMobileNavToggle" class="so-menu-btn md:hidden inline-flex shrink-0 items-center justify-center border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50" aria-label="Open navigation menu" aria-expanded="false" aria-controls="userSidebar">
            <i class="fa-solid fa-bars text-lg" aria-hidden="true"></i>
        </button>
        <h1 class="truncate min-w-0">Employee Dashboard</h1>
    </div>
    <div class="flex items-center gap-2 sm:gap-4 shrink-0">
        <button type="button" onclick="openUserNotifications()" class="notif-trigger group relative inline-flex shrink-0 items-center justify-center border border-slate-200/90 bg-white text-slate-600 shadow-sm transition-all hover:border-slate-300 hover:bg-slate-50 hover:text-slate-900 hover:shadow focus:outline-none focus-visible:ring-2 focus-visible:ring-slate-400/35" title="Notifications" aria-label="Notifications">
            <i class="fa-regular fa-bell pointer-events-none text-[1.15rem] transition-transform duration-200 group-hover:scale-105" aria-hidden="true"></i>
            <span id="notifBadge" role="status" class="notif-badge <%= unreadNotifCount > 0 ? "" : "hidden" %>"><%= unreadNotifCount > 99 ? "99+" : unreadNotifCount %></span>
        </button>
        <span class="so-welcome truncate max-w-[min(42vw,200px)] sm:max-w-none">Welcome, <strong class="text-slate-800">${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
    </div>
</header>

<div id="userNavOverlay" class="fixed inset-0 z-40 bg-slate-900/50 md:hidden hidden" aria-hidden="true"></div>

<!-- Main Layout -->
<div class="flex flex-1 min-h-0 overflow-hidden relative">
    <!-- Sidebar -->
    <aside id="userSidebar" class="so-sidebar fixed md:relative z-50 inset-y-0 left-0 max-w-[min(85vw,var(--so-sidebar-width))] w-full min-w-0 h-full md:h-auto border-r border-slate-200 flex flex-col shadow-lg md:shadow-sm transform transition-transform duration-200 ease-out -translate-x-full md:translate-x-0 overflow-hidden">
        <nav class="flex-1 py-4 px-3 overflow-y-auto min-h-0">
            <button type="button" data-user-view="userOverview"  onclick="loadPage(this,'userOverview')"  class="sidebar-btn active w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-chart-pie w-5"></i> <span>Overview</span>
            </button>
            <button type="button" data-user-view="userAttendance" onclick="loadPage(this,'userAttendance')" class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-user-check w-5"></i> <span>My Attendance</span>
            </button>
            <button type="button" data-user-view="userTasks"     onclick="loadPage(this,'userTasks')"     class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-list-check w-5"></i> <span>Tasks</span>
            </button>
            <button type="button" data-user-view="userTeam"      onclick="loadPage(this,'userTeam')"      class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-users w-5"></i> <span>My Team</span>
            </button>
            <button type="button" data-user-view="userLeave"     onclick="loadPage(this,'userLeave')"     class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-calendar-xmark w-5"></i> <span>Apply Leave</span>
            </button>
            <button type="button" data-user-view="userMeetings"  onclick="loadPage(this,'userMeetings')"  class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-handshake w-5"></i> <span>Scheduled Meetings</span>
            </button>
            <button type="button" data-user-view="calendar.jsp"  onclick="loadPage(this,'calendar.jsp')"  class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-calendar-days w-5"></i> <span>Calendar</span>
            </button>
        </nav>
        <div class="border-t border-slate-200 px-3 py-4">
            <button type="button" data-user-view="userSettings"  onclick="loadPage(this,'userSettings')"  class="sidebar-btn w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors mb-1 font-medium">
                <i class="fa-solid fa-gear w-5"></i> <span>Settings</span>
            </button>
            <a href="<%=request.getContextPath()%>/logout" class="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-red-600 hover:bg-red-50 transition-colors font-medium">
                <i class="fa-solid fa-right-to-bracket w-5"></i> <span>Logout</span>
            </a>
        </div>
    </aside>

    <!-- Content Area -->
    <main class="so-main flex-1 min-h-0 overflow-auto bg-slate-100 flex flex-col w-full min-w-0">
        <iframe id="contentFrame" src="<%= ctxPath %>/userOverview" class="w-full flex-1 min-h-[50vh] md:min-h-0 border-0 block" title="Dashboard content"></iframe>
    </main>
</div>

<!-- Toast (styled by css/smart-office-toast.css + js/smart-office-toast.js) -->
<div id="toast" aria-live="polite"></div>

<script>
(function() {
    var CTX = '<%= ctxPath %>';
    window.resolveDashboardUrl = function(page) {
        if (!page) return CTX + '/userOverview';
        if (page.indexOf('http') === 0) return page;
        if (page.indexOf(CTX + '/') === 0) return page;
        if (page.charAt(0) === '/') return CTX + page;
        return CTX + '/' + page;
    };
})();

// ── Sidebar active state helper ──
function setActiveSidebarBtn(view) {
    document.querySelectorAll('.sidebar-btn').forEach(function(b) {
        var v = b.getAttribute('data-user-view');
        if (v === view) {
            b.classList.add('active', 'bg-indigo-50', 'text-indigo-700');
        } else {
            b.classList.remove('active', 'bg-indigo-50', 'text-indigo-700');
        }
    });
}

function closeUserMobileNav() {
    var aside   = document.getElementById('userSidebar');
    var overlay = document.getElementById('userNavOverlay');
    var toggle  = document.getElementById('userMobileNavToggle');
    if (aside)   { aside.classList.add('-translate-x-full'); aside.classList.remove('translate-x-0'); }
    if (overlay) overlay.classList.add('hidden');
    if (toggle)  toggle.setAttribute('aria-expanded', 'false');
}
function openUserMobileNav() {
    var aside   = document.getElementById('userSidebar');
    var overlay = document.getElementById('userNavOverlay');
    var toggle  = document.getElementById('userMobileNavToggle');
    if (window.matchMedia('(min-width: 768px)').matches) return;
    if (aside)   { aside.classList.remove('-translate-x-full'); aside.classList.add('translate-x-0'); }
    if (overlay) overlay.classList.remove('hidden');
    if (toggle)  toggle.setAttribute('aria-expanded', 'true');
}
function toggleUserMobileNav() {
    var aside = document.getElementById('userSidebar');
    if (!aside) return;
    if (aside.classList.contains('-translate-x-full')) openUserMobileNav();
    else closeUserMobileNav();
}

var USER_VIEW_STORAGE_KEY = 'so_employee_dash_view';

function stripUserViewQueryFromUrl() {
    var u = new URL(window.location.href);
    u.searchParams.delete('view');
    u.searchParams.delete('tab');
    window.history.replaceState({}, document.title, u.pathname + (u.search || ''));
}

function syncUserUrl(page) {
    if (!page) return;
    try { sessionStorage.setItem(USER_VIEW_STORAGE_KEY, page); } catch (e) {}
    stripUserViewQueryFromUrl();
}

function openUserNotifications() {
    document.getElementById('contentFrame').src = window.resolveDashboardUrl('sharedNotifications.jsp');
    setActiveSidebarBtn(null);
    syncUserUrl('sharedNotifications.jsp');
    closeUserMobileNav();
}

// ── Main navigation function ──
function loadPage(btn, page) {
    document.getElementById('contentFrame').src = window.resolveDashboardUrl(page);
    var view = btn ? btn.getAttribute('data-user-view') : page;
    setActiveSidebarBtn(view || page);
    syncUserUrl(view || page);
    closeUserMobileNav();
}

// ── Badge polling ──
function updateBadge() {
    fetch('<%= ctxPath %>/notificationCount', { credentials: 'same-origin' })
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

// showToast: global from js/smart-office-toast.js

// ── Tab/view name → route mapping ──
var VIEW_MAP = {
    'userOverview':  'userOverview',
    'userAttendance':'userAttendance',
    'userTasks':     'userTasks',
    'userTeam':      'userTeam',
    'userLeave':     'userLeave',
    'userMeetings':  'userMeetings',
    'calendar.jsp':  'calendar.jsp',
    'userSettings':  'userSettings',
    // legacy ?tab= param values
    'overview':    'userOverview',
    'attendance':  'userAttendance',
    'tasks':       'userTasks',
    'team':        'userTeam',
    'leave':       'userLeave',
    'meetings':    'userMeetings',
    'calendar':    'calendar.jsp',
    'settings':    'userSettings'
};

function resolveUserViewFromParams(params) {
    var raw = params.get('view') || params.get('tab');
    if (!raw) return null;
    return VIEW_MAP[raw] || null;
}

function applyUserViewToFrame(view) {
    if (!view) return false;
    if (view === 'sharedNotifications.jsp') {
        document.getElementById('contentFrame').src = window.resolveDashboardUrl('sharedNotifications.jsp');
        setActiveSidebarBtn(null);
        return true;
    }
    var mapped = VIEW_MAP[view] || view;
    if (!document.querySelector('.sidebar-btn[data-user-view="' + mapped + '"]')) return false;
    document.getElementById('contentFrame').src = window.resolveDashboardUrl(mapped);
    setActiveSidebarBtn(mapped);
    return true;
}

function applyEmployeeDashboardView() {
    var params = new URLSearchParams(window.location.search);
    var view = resolveUserViewFromParams(params);
    var fromUrl = !!view;
    if (!view) {
        try { view = sessionStorage.getItem(USER_VIEW_STORAGE_KEY); } catch (e) {}
    }
    if (!view) return false;
    if (!applyUserViewToFrame(view)) return false;
    try { sessionStorage.setItem(USER_VIEW_STORAGE_KEY, view); } catch (e) {}
    if (fromUrl) stripUserViewQueryFromUrl();
    return true;
}

document.addEventListener('DOMContentLoaded', function() {
    var t = document.getElementById('userMobileNavToggle');
    var o = document.getElementById('userNavOverlay');
    if (t) t.addEventListener('click', function(e) { e.stopPropagation(); toggleUserMobileNav(); });
    if (o) o.addEventListener('click', closeUserMobileNav);
    window.addEventListener('resize', function() {
        if (window.matchMedia('(min-width: 768px)').matches) closeUserMobileNav();
    });

    var applied = applyEmployeeDashboardView();
    var params = new URLSearchParams(window.location.search);
    if (!applied) {
        setActiveSidebarBtn('userOverview');
    }

    if (params.get('success')) {
        var s = params.get('success');
        var successMsgs = { Login:'Logged in successfully', LeaveApplied:'Leave applied successfully', PunchIn:'Punched in ✔', PunchOut:'Punched out ✔' };
        if (successMsgs[s]) showToast(successMsgs[s], 'success');
    }
    if (params.get('error')) {
        var err = params.get('error');
        var errorMsgs = { accessDenied:'Access denied.', HolidayAttendance:'Today is a holiday.', PasswordMismatch:'Passwords do not match.' };
        showToast(errorMsgs[err] || 'Something went wrong', 'error');
    }

    var urlAfterFlash = new URL(window.location.href);
    if (urlAfterFlash.searchParams.has('success') || urlAfterFlash.searchParams.has('error')) {
        urlAfterFlash.searchParams.delete('success');
        urlAfterFlash.searchParams.delete('error');
        window.history.replaceState({}, document.title, urlAfterFlash.pathname + (urlAfterFlash.search || ''));
    }

    updateBadge();
    setInterval(updateBadge, 90000);
});

document.addEventListener('contextmenu', function(e) { e.preventDefault(); });
document.onkeydown = function(e) {
    return (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
};
</script>
</body>
</html>
