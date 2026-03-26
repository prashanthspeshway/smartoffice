<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.dao.NotificationReadsDAO"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}

// Detect role from session
String role = (String) session.getAttribute("role");
if (role == null) role = "employee"; // fallback

/*
 * ROLE → DASHBOARD URL MAPPING
 * ─────────────────────────────────────────────────────────────
 *  admin    → admin.jsp?view=adminTasks / adminMeetings / adminLeave
 *  manager  → managerDashboard.jsp?view=managerTasks / managerMeetings / managerLeave
 *  employee → userDashboard.jsp?view=tasks / meetings / leave
 * ─────────────────────────────────────────────────────────────
 */
String taskRedirect, meetingRedirect, leaveRedirect;

if (role.equalsIgnoreCase("admin")) {
    taskRedirect    = request.getContextPath() + "/admin.jsp?view=adminTasks";
    meetingRedirect = request.getContextPath() + "/admin.jsp?view=adminMeetings";
    leaveRedirect   = request.getContextPath() + "/admin.jsp?view=adminLeave";
} else if (role.equalsIgnoreCase("manager")) {
    taskRedirect    = request.getContextPath() + "/managerDashboard.jsp?view=managerTasks";
    meetingRedirect = request.getContextPath() + "/managerDashboard.jsp?view=managerMeetings";
    leaveRedirect   = request.getContextPath() + "/managerDashboard.jsp?view=managerLeave";
} else {
    // employee / user
    taskRedirect    = request.getContextPath() + "/user?view=userTasks";
    meetingRedirect = request.getContextPath() + "/user?view=userMeetings";
    leaveRedirect   = request.getContextPath() + "/user?view=userLeave";
}

NotificationReadsDAO nDao = new NotificationReadsDAO();
List<Notification> unreadNotifications = new ArrayList<>();
List<Notification> readNotifications   = new ArrayList<>();
try {
    unreadNotifications = nDao.getUnreadNotifications(username);
    readNotifications   = nDao.getReadNotifications(username);
} catch (Exception e) {
    e.printStackTrace();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notifications</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<style>
/* Only transition, NO animation — avoids forwards fill-mode locking opacity */
.notif-card {
    transition: opacity 0.3s ease, transform 0.3s ease;
}
/* Clickable card styling */
.notif-card.clickable {
    cursor: pointer;
}
.notif-card.clickable:hover {
    box-shadow: 0 4px 16px 0 rgba(99,102,241,0.10);
}
/* Redirect hint badge */
.redirect-hint {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 0.68rem;
    font-weight: 600;
    color: #6366f1;
    opacity: 0;
    transition: opacity 0.2s ease;
    pointer-events: none;
    white-space: nowrap;
}
.notif-card.clickable:hover .redirect-hint {
    opacity: 1;
}
</style>
</head>
<body class="user-iframe-page p-6">

<div class="max-w-3xl mx-auto space-y-5">

    <!-- Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-2xl font-bold text-slate-800">
                <i class="fa-solid fa-bell mr-2 text-indigo-500"></i>Notifications
            </h2>
            <p class="text-slate-500 text-sm mt-1">Stay on top of your updates.</p>
        </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-2 border-b border-slate-200">
        <button id="tabUnread" onclick="switchTab('unread')"
            class="px-5 py-2.5 text-sm font-semibold rounded-t-lg border border-b-0 border-slate-200 bg-white text-indigo-600 -mb-px z-10 transition-colors">
            <i class="fa-solid fa-bell mr-1.5"></i>Unread
            <%if (!unreadNotifications.isEmpty()) {%>
            <span id="unreadBadge" class="ml-1.5 px-2 py-0.5 rounded-full bg-indigo-100 text-indigo-700 text-xs font-bold"><%=unreadNotifications.size()%></span>
            <%}%>
        </button>
        <button id="tabRead" onclick="switchTab('read')"
            class="px-5 py-2.5 text-sm font-semibold rounded-t-lg border border-b-0 border-transparent text-slate-400 hover:text-slate-600 -mb-px transition-colors">
            <i class="fa-solid fa-check-double mr-1.5"></i>Read
            <%if (!readNotifications.isEmpty()) {%>
            <span id="readBadge" class="ml-1.5 px-2 py-0.5 rounded-full bg-slate-100 text-slate-500 text-xs font-bold"><%=readNotifications.size()%></span>
            <%}%>
        </button>
    </div>

    <!-- Toast -->
    <div id="toast" class="fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg hidden text-sm font-medium max-w-[min(92vw,24rem)]"></div>

    <!-- ═══════════ UNREAD PANE ═══════════ -->
    <div id="paneUnread">

        <%if (!unreadNotifications.isEmpty()) {%>
        <div class="flex justify-end mb-3" id="markAllBar">
            <button onclick="markAll()"
                class="px-4 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-xs font-semibold border border-slate-200 transition-colors">
                <i class="fa-solid fa-check-double mr-1"></i>Mark all as read
            </button>
        </div>
        <%}%>

        <div id="unreadList" class="space-y-3">
        <%if (unreadNotifications.isEmpty()) {%>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">
                <i class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>
                <p class="text-slate-400 font-semibold text-base">You're all caught up!</p>
                <p class="text-slate-400 text-sm mt-1">No new notifications.</p>
            </div>
        <%} else {
            for (Notification n : unreadNotifications) {
                String type = n.getType() != null ? n.getType() : "GENERAL";
                String iconClass, bgClass, borderClass, iconColor, badgeCls, redirectUrl, redirectLabel, redirectIcon;
                switch (type) {
                    case "TASK":
                        iconClass="fa-list-check"; bgClass="bg-violet-50"; borderClass="border-l-violet-500";
                        iconColor="text-violet-500"; badgeCls="bg-violet-100 text-violet-700";
                        redirectUrl=taskRedirect;
                        redirectLabel="View Tasks"; redirectIcon="fa-list-check"; break;
                    case "MEETING":
                        iconClass="fa-video"; bgClass="bg-blue-50"; borderClass="border-l-blue-500";
                        iconColor="text-blue-500"; badgeCls="bg-blue-100 text-blue-700";
                        redirectUrl=meetingRedirect;
                        redirectLabel="View Meetings"; redirectIcon="fa-video"; break;
                    case "LEAVE":
                        iconClass="fa-calendar-xmark"; bgClass="bg-amber-50"; borderClass="border-l-amber-500";
                        iconColor="text-amber-500"; badgeCls="bg-amber-100 text-amber-700";
                        redirectUrl=leaveRedirect;
                        redirectLabel="View Leave"; redirectIcon="fa-calendar-xmark"; break;
                    default:
                        iconClass="fa-bell"; bgClass="bg-indigo-50"; borderClass="border-l-indigo-500";
                        iconColor="text-indigo-500"; badgeCls="bg-indigo-100 text-indigo-700";
                        redirectUrl="#"; redirectLabel=""; redirectIcon=""; break;
                }
                java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("MMM d, hh:mm a");
                String timeStr = n.getCreatedAt() != null ? fmt.format(n.getCreatedAt()) : "";
                String safeMsg = n.getMessage() != null
                    ? n.getMessage().replace("\\","\\\\").replace("'","\\'").replace("\r","").replace("\n"," ") : "";
                String safeBy = n.getCreatedBy() != null
                    ? n.getCreatedBy().replace("\\","\\\\").replace("'","\\'") : "System";
                String safeTime = timeStr.replace("'","\\'");
                String safeUrl = redirectUrl.replace("'","\\'");
                String safeLabel = redirectLabel.replace("'","\\'");
                String safeRedirectIcon = redirectIcon.replace("'","\\'");
                boolean hasRedirect = !redirectUrl.equals("#");
        %>
        <div class="notif-card bg-white rounded-xl border border-slate-200 border-l-4 <%=borderClass%> shadow-sm p-5 flex items-start gap-4 hover:shadow-md <%=hasRedirect ? "clickable" : ""%>"
             id="notif-<%=n.getId()%>"
             data-msg="<%=safeMsg%>"
             data-by="<%=safeBy%>"
             data-time="<%=safeTime%>"
             data-type="<%=type%>"
             data-icon="<%=iconClass%>"
             data-bg="<%=bgClass%>"
             data-border="<%=borderClass%>"
             data-iconcolor="<%=iconColor%>"
             data-badge="<%=badgeCls%>"
             data-url="<%=safeUrl%>"
             data-label="<%=safeLabel%>"
             data-redirecticon="<%=safeRedirectIcon%>"
             <%=hasRedirect ? "onclick=\"handleNotifClick(" + n.getId() + ", '" + safeUrl + "', event)\"" : ""%>>

            <div class="w-10 h-10 rounded-full <%=bgClass%> flex items-center justify-center flex-shrink-0 mt-0.5">
                <i class="fa-solid <%=iconClass%> <%=iconColor%>"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-sm text-slate-700 font-medium leading-relaxed"><%=n.getMessage()%></p>
                <div class="flex items-center gap-3 mt-1.5 flex-wrap">
                    <span class="text-xs text-slate-400">
                        <i class="fa-solid fa-user mr-1"></i><%=n.getCreatedBy() != null ? n.getCreatedBy() : "System"%>
                    </span>
                    <%if (!timeStr.isEmpty()) {%>
                    <span class="text-xs text-slate-300">•</span>
                    <span class="text-xs text-slate-400">
                        <i class="fa-regular fa-clock mr-1"></i><%=timeStr%>
                    </span>
                    <%}%>
                    <span class="text-xs font-semibold px-2 py-0.5 rounded-full <%=badgeCls%>"><%=type%></span>
                    <%if (hasRedirect) {%>
                    <span class="redirect-hint">
                        <i class="fa-solid <%=redirectIcon%>"></i><%=redirectLabel%> <i class="fa-solid fa-arrow-right text-[0.6rem]"></i>
                    </span>
                    <%}%>
                </div>
            </div>
            <button onclick="markAsRead(<%=n.getId()%>, this)"
                class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-semibold transition-colors mt-0.5 whitespace-nowrap">
                <i class="fa-solid fa-check mr-1"></i>Mark as read
            </button>
        </div>
        <%}}%>
        </div>
    </div>

    <!-- ═══════════ READ PANE ═══════════ -->
    <div id="paneRead" class="hidden">

        <div class="flex justify-end mb-3" id="deleteAllBar"
            <%if (readNotifications.isEmpty()) {%>style="display:none"<%}%>>
            <button onclick="deleteAll()"
                class="px-4 py-2 rounded-lg bg-red-50 hover:bg-red-100 text-red-600 text-xs font-semibold border border-red-200 transition-colors">
                <i class="fa-solid fa-trash mr-1"></i>Delete all
            </button>
        </div>

        <div id="readList" class="space-y-3">
        <%if (readNotifications.isEmpty()) {%>
            <div id="emptyRead" class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">
                <i class="fa-solid fa-inbox text-5xl text-slate-300 mb-4 block"></i>
                <p class="text-slate-400 font-semibold text-base">No read notifications yet.</p>
                <p class="text-slate-400 text-sm mt-1">Notifications you've read will appear here.</p>
            </div>
        <%} else {
            for (Notification n : readNotifications) {
                String type = n.getType() != null ? n.getType() : "GENERAL";
                String iconClass, bgClass, borderClass, iconColor, badgeCls, redirectUrl, redirectLabel, redirectIcon;
                switch (type) {
                    case "TASK":
                        iconClass="fa-list-check"; bgClass="bg-violet-50"; borderClass="border-l-violet-500";
                        iconColor="text-violet-500"; badgeCls="bg-violet-100 text-violet-700";
                        redirectUrl=taskRedirect;
                        redirectLabel="View Tasks"; redirectIcon="fa-list-check"; break;
                    case "MEETING":
                        iconClass="fa-video"; bgClass="bg-blue-50"; borderClass="border-l-blue-500";
                        iconColor="text-blue-500"; badgeCls="bg-blue-100 text-blue-700";
                        redirectUrl=meetingRedirect;
                        redirectLabel="View Meetings"; redirectIcon="fa-video"; break;
                    case "LEAVE":
                        iconClass="fa-calendar-xmark"; bgClass="bg-amber-50"; borderClass="border-l-amber-500";
                        iconColor="text-amber-500"; badgeCls="bg-amber-100 text-amber-700";
                        redirectUrl=leaveRedirect;
                        redirectLabel="View Leave"; redirectIcon="fa-calendar-xmark"; break;
                    default:
                        iconClass="fa-bell"; bgClass="bg-indigo-50"; borderClass="border-l-indigo-500";
                        iconColor="text-indigo-500"; badgeCls="bg-indigo-100 text-indigo-700";
                        redirectUrl="#"; redirectLabel=""; redirectIcon=""; break;
                }
                java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("MMM d, hh:mm a");
                String timeStr = n.getCreatedAt() != null ? fmt.format(n.getCreatedAt()) : "";
                String safeUrl = redirectUrl.replace("'","\\'");
                String safeLabel = redirectLabel.replace("'","\\'");
                String safeRedirectIcon = redirectIcon.replace("'","\\'");
                boolean hasRedirect = !redirectUrl.equals("#");
        %>
        <div class="notif-card bg-white rounded-xl border border-slate-200 border-l-4 <%=borderClass%> shadow-sm p-5 flex items-start gap-4 hover:shadow-md <%=hasRedirect ? "clickable" : ""%>"
             id="read-<%=n.getId()%>"
             style="opacity:0.75"
             <%=hasRedirect ? "onclick=\"handleReadClick('" + safeUrl + "', event)\"" : ""%>
             onmouseenter="this.style.opacity='1'"
             onmouseleave="this.style.opacity='0.75'">

            <div class="w-10 h-10 rounded-full <%=bgClass%> flex items-center justify-center flex-shrink-0 mt-0.5">
                <i class="fa-solid <%=iconClass%> <%=iconColor%>"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-sm text-slate-500 font-medium leading-relaxed"><%=n.getMessage()%></p>
                <div class="flex items-center gap-3 mt-1.5 flex-wrap">
                    <span class="text-xs text-slate-400">
                        <i class="fa-solid fa-user mr-1"></i><%=n.getCreatedBy() != null ? n.getCreatedBy() : "System"%>
                    </span>
                    <%if (!timeStr.isEmpty()) {%>
                    <span class="text-xs text-slate-300">•</span>
                    <span class="text-xs text-slate-400">
                        <i class="fa-regular fa-clock mr-1"></i><%=timeStr%>
                    </span>
                    <%}%>
                    <span class="text-xs font-semibold px-2 py-0.5 rounded-full <%=badgeCls%>"><%=type%></span>
                    <%if (hasRedirect) {%>
                    <span class="redirect-hint">
                        <i class="fa-solid <%=redirectIcon%>"></i><%=redirectLabel%> <i class="fa-solid fa-arrow-right text-[0.6rem]"></i>
                    </span>
                    <%}%>
                </div>
            </div>
            <button onclick="deleteNotification(<%=n.getId()%>, this)"
                class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-red-50 hover:bg-red-600 hover:text-white text-red-500 border border-red-200 text-xs font-semibold transition-colors mt-0.5 whitespace-nowrap">
                <i class="fa-solid fa-trash mr-1"></i>Delete
            </button>
        </div>
        <%}}%>
        </div>
    </div>

</div>

<script>
/* ══════════════════════════════════
   TAB SWITCHING
══════════════════════════════════ */
function switchTab(tab) {
    const isUnread = tab === 'unread';
    document.getElementById('paneUnread').classList.toggle('hidden', !isUnread);
    document.getElementById('paneRead').classList.toggle('hidden', isUnread);
    const tU = document.getElementById('tabUnread');
    const tR = document.getElementById('tabRead');
    if (isUnread) {
        tU.classList.add('bg-white','text-indigo-600','border-slate-200');
        tU.classList.remove('border-transparent','text-slate-400');
        tR.classList.add('border-transparent','text-slate-400');
        tR.classList.remove('bg-white','text-indigo-600','border-slate-200');
    } else {
        tR.classList.add('bg-white','text-indigo-600','border-slate-200');
        tR.classList.remove('border-transparent','text-slate-400');
        tU.classList.add('border-transparent','text-slate-400');
        tU.classList.remove('bg-white','text-indigo-600','border-slate-200');
    }
}

/* ══════════════════════════════════
   TOAST
══════════════════════════════════ */
function showToast(msg, type) {
    const t = document.getElementById('toast');
    t.className = 'fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-sm font-medium max-w-[min(92vw,24rem)] text-white';
    t.classList.add(type === 'success' ? 'bg-emerald-500' : 'bg-red-500');
    t.textContent = msg;
    t.classList.remove('hidden');
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.add('hidden'), 2500);
}

/* ══════════════════════════════════
   FADE HELPERS — pure JS, no CSS animation
══════════════════════════════════ */
function fadeOut(el, cb) {
    el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    el.style.opacity = '0';
    el.style.transform = 'translateX(10px)';
    setTimeout(() => { el.remove(); if (cb) cb(); }, 320);
}

function fadeInReadCard(el) {
    el.style.opacity = '0';
    el.style.transform = 'translateY(-6px)';
    el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    el.getBoundingClientRect();
    el.style.opacity = '0.75';
    el.style.transform = 'translateY(0)';
}

/* ══════════════════════════════════
   CLICK TO REDIRECT — UNREAD
   Marks as read silently, then navigates parent window.
   Ignores clicks on buttons inside the card.
══════════════════════════════════ */
function handleNotifClick(id, url, event) {
    if (!url || url === '#') return;
    // If the click was on the "Mark as read" button, let that handler run instead
    if (event.target.closest('button')) return;

    // Mark as read silently in background, then redirect
    fetch('<%=request.getContextPath()%>/markNotificationRead?id=' + id, { method: 'POST' })
        .finally(() => {
            if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
            // Navigate the parent (dashboard) window, not just the iframe
            navigateTo(url);
        });
}

/* ══════════════════════════════════
   CLICK TO REDIRECT — READ
   Just navigates; already marked as read.
══════════════════════════════════ */
function handleReadClick(url, event) {
    if (!url || url === '#') return;
    // Ignore clicks on the Delete button
    if (event.target.closest('button')) return;
    navigateTo(url);
}

/* ══════════════════════════════════
   SMART NAVIGATION
   If inside an iframe (dashboard), navigate the parent.
   Otherwise navigate the current window.
══════════════════════════════════ */
function navigateTo(url) {
    try {
        if (window.self !== window.top) {
            // We're inside an iframe — navigate the parent page
            window.top.location.href = url;
        } else {
            window.location.href = url;
        }
    } catch (e) {
        // Cross-origin fallback
        window.location.href = url;
    }
}

/* ══════════════════════════════════
   BUILD READ CARD — no CSS animation class
══════════════════════════════════ */
function buildReadCard(id, msg, createdBy, timeStr, type, iconClass, bgClass, borderClass, iconColor, badgeCls, redirectUrl, redirectLabel, redirectIcon) {
    const timeHtml = timeStr
        ? `<span class="text-xs text-slate-300">•</span>
           <span class="text-xs text-slate-400"><i class="fa-regular fa-clock mr-1"></i>${timeStr}</span>`
        : '';
    const hasRedirect = redirectUrl && redirectUrl !== '#';
    const redirectHint = hasRedirect
        ? `<span class="redirect-hint"><i class="fa-solid ${redirectIcon}"></i>${redirectLabel} <i class="fa-solid fa-arrow-right" style="font-size:0.6rem"></i></span>`
        : '';
    const clickHandler = hasRedirect
        ? `onclick="handleReadClick('${redirectUrl}', event)"`
        : '';
    return `
    <div class="notif-card bg-white rounded-xl border border-slate-200 border-l-4 ${borderClass} shadow-sm p-5 flex items-start gap-4 hover:shadow-md ${hasRedirect ? 'clickable' : ''}"
         id="read-${id}"
         ${clickHandler}
         onmouseenter="this.style.opacity='1'"
         onmouseleave="this.style.opacity='0.75'">
        <div class="w-10 h-10 rounded-full ${bgClass} flex items-center justify-center flex-shrink-0 mt-0.5">
            <i class="fa-solid ${iconClass} ${iconColor}"></i>
        </div>
        <div class="flex-1 min-w-0">
            <p class="text-sm text-slate-500 font-medium leading-relaxed">${msg}</p>
            <div class="flex items-center gap-3 mt-1.5 flex-wrap">
                <span class="text-xs text-slate-400"><i class="fa-solid fa-user mr-1"></i>${createdBy}</span>
                ${timeHtml}
                <span class="text-xs font-semibold px-2 py-0.5 rounded-full ${badgeCls}">${type}</span>
                ${redirectHint}
            </div>
        </div>
        <button onclick="deleteNotification(${id}, this)"
            class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-red-50 hover:bg-red-600 hover:text-white text-red-500 border border-red-200 text-xs font-semibold transition-colors mt-0.5 whitespace-nowrap">
            <i class="fa-solid fa-trash mr-1"></i>Delete
        </button>
    </div>`;
}

/* ══════════════════════════════════
   MARK SINGLE AS READ
══════════════════════════════════ */
function markAsRead(id, btn) {
    if (btn.disabled) return;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';

    fetch('<%=request.getContextPath()%>/markNotificationRead?id=' + id, { method: 'POST' })
    .then(res => {
        if (!res.ok) throw new Error('HTTP ' + res.status);

        const card        = document.getElementById('notif-' + id);
        const msg         = card.dataset.msg;
        const createdBy   = card.dataset.by;
        const timeStr     = card.dataset.time;
        const type        = card.dataset.type;
        const iconClass   = card.dataset.icon;
        const bgClass     = card.dataset.bg;
        const borderClass = card.dataset.border;
        const iconColor   = card.dataset.iconcolor;
        const badgeCls    = card.dataset.badge;
        const redirectUrl = card.dataset.url;
        const redirectLabel = card.dataset.label;
        const redirectIcon  = card.dataset.redirecticon;

        fadeOut(card, () => {
            const emptyRead = document.getElementById('emptyRead');
            if (emptyRead) emptyRead.remove();

            const readList = document.getElementById('readList');
            readList.insertAdjacentHTML('afterbegin',
                buildReadCard(id, msg, createdBy, timeStr, type, iconClass, bgClass, borderClass, iconColor, badgeCls, redirectUrl, redirectLabel, redirectIcon));

            const newCard = document.getElementById('read-' + id);
            if (newCard) fadeInReadCard(newCard);

            const bar = document.getElementById('deleteAllBar');
            if (bar) bar.style.display = '';

            adjustBadge('unreadBadge', -1, 'tabUnread', 'bg-indigo-100', 'text-indigo-700');
            adjustBadge('readBadge',   +1, 'tabRead',   'bg-slate-100',  'text-slate-500');

            checkUnreadEmpty();
        });

        showToast('Marked as read', 'success');
        if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
    })
    .catch(() => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check mr-1"></i>Mark as read';
        showToast('Failed. Try again.', 'error');
    });
}

/* ══════════════════════════════════
   MARK ALL AS READ
══════════════════════════════════ */
function markAll() {
    fetch('<%=request.getContextPath()%>/markNotificationRead?id=all', { method: 'POST' })
    .then(res => {
        if (!res.ok) throw new Error('HTTP ' + res.status);

        const cards = [...document.querySelectorAll('#unreadList > div[id^="notif-"]')];
        const emptyRead = document.getElementById('emptyRead');
        if (emptyRead) emptyRead.remove();

        const readList = document.getElementById('readList');
        let done = 0;

        cards.forEach(card => {
            const id            = card.id.replace('notif-', '');
            const msg           = card.dataset.msg;
            const createdBy     = card.dataset.by;
            const timeStr       = card.dataset.time;
            const type          = card.dataset.type;
            const iconClass     = card.dataset.icon;
            const bgClass       = card.dataset.bg;
            const borderClass   = card.dataset.border;
            const iconColor     = card.dataset.iconcolor;
            const badgeCls      = card.dataset.badge;
            const redirectUrl   = card.dataset.url;
            const redirectLabel = card.dataset.label;
            const redirectIcon  = card.dataset.redirecticon;

            fadeOut(card, () => {
                readList.insertAdjacentHTML('afterbegin',
                    buildReadCard(id, msg, createdBy, timeStr, type, iconClass, bgClass, borderClass, iconColor, badgeCls, redirectUrl, redirectLabel, redirectIcon));
                const newCard = document.getElementById('read-' + id);
                if (newCard) fadeInReadCard(newCard);
                done++;
                if (done === cards.length) {
                    const totalRead = document.querySelectorAll('#readList > div[id^="read-"]').length;
                    setAbsoluteBadge('readBadge', 'tabRead', totalRead, 'bg-slate-100', 'text-slate-500');
                    checkUnreadEmpty();
                }
            });
        });

        const bar = document.getElementById('deleteAllBar');
        if (bar) bar.style.display = '';
        const markBar = document.getElementById('markAllBar');
        if (markBar) markBar.style.display = 'none';

        const ub = document.getElementById('unreadBadge');
        if (ub) ub.remove();

        showToast('All marked as read', 'success');
        if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
    })
    .catch(() => showToast('Failed. Try again.', 'error'));
}

/* ══════════════════════════════════
   DELETE SINGLE NOTIFICATION
══════════════════════════════════ */
function deleteNotification(id, btn) {
    if (btn.disabled) return;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';

    fetch('<%=request.getContextPath()%>/deleteNotification?id=' + id, { method: 'POST' })
    .then(res => {
        if (!res.ok) throw new Error('HTTP ' + res.status);

        const el = document.getElementById('read-' + id);
        if (el) {
            fadeOut(el, () => {
                adjustBadge('readBadge', -1, 'tabRead', 'bg-slate-100', 'text-slate-500');
                checkReadEmpty();
            });
        }
        showToast('Notification deleted', 'success');
    })
    .catch(() => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-trash mr-1"></i>Delete';
        showToast('Failed. Try again.', 'error');
    });
}

/* ══════════════════════════════════
   DELETE ALL READ
══════════════════════════════════ */
function deleteAll() {
    fetch('<%=request.getContextPath()%>/deleteNotification?id=all', { method: 'POST' })
    .then(res => {
        if (!res.ok) throw new Error('HTTP ' + res.status);

        const cards = [...document.querySelectorAll('#readList > div[id^="read-"]')];
        cards.forEach(el => fadeOut(el, null));

        const rb = document.getElementById('readBadge');
        if (rb) rb.remove();

        const bar = document.getElementById('deleteAllBar');
        if (bar) bar.style.display = 'none';

        setTimeout(() => checkReadEmpty(), 380);
        showToast('All read notifications deleted', 'success');
    })
    .catch(() => showToast('Failed. Try again.', 'error'));
}

/* ══════════════════════════════════
   EMPTY STATE HELPERS
══════════════════════════════════ */
function checkUnreadEmpty() {
    if (document.querySelectorAll('#unreadList > div[id^="notif-"]').length === 0) {
        document.getElementById('unreadList').innerHTML =
            '<div class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">' +
            '<i class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>' +
            '<p class="text-slate-400 font-semibold text-base">You\'re all caught up!</p>' +
            '<p class="text-slate-400 text-sm mt-1">No new notifications.</p></div>';
        const bar = document.getElementById('markAllBar');
        if (bar) bar.style.display = 'none';
    }
}

function checkReadEmpty() {
    if (document.querySelectorAll('#readList > div[id^="read-"]').length === 0) {
        document.getElementById('readList').innerHTML =
            '<div id="emptyRead" class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">' +
            '<i class="fa-solid fa-inbox text-5xl text-slate-300 mb-4 block"></i>' +
            '<p class="text-slate-400 font-semibold text-base">No read notifications yet.</p>' +
            '<p class="text-slate-400 text-sm mt-1">Notifications you\'ve read will appear here.</p></div>';
        const bar = document.getElementById('deleteAllBar');
        if (bar) bar.style.display = 'none';
    }
}

/* ══════════════════════════════════
   BADGE HELPERS
══════════════════════════════════ */
function adjustBadge(badgeId, delta, tabId, bgCls, textCls) {
    let badge = document.getElementById(badgeId);
    if (badge) {
        let count = parseInt(badge.textContent || '0') + delta;
        if (count <= 0) { badge.remove(); return; }
        badge.textContent = count;
    } else if (delta > 0) {
        const tab = document.getElementById(tabId);
        if (!tab) return;
        const b = document.createElement('span');
        b.id = badgeId;
        b.className = `ml-1.5 px-2 py-0.5 rounded-full ${bgCls} ${textCls} text-xs font-bold`;
        b.textContent = delta;
        tab.appendChild(b);
    }
}

function setAbsoluteBadge(badgeId, tabId, count, bgCls, textCls) {
    let badge = document.getElementById(badgeId);
    if (count <= 0) { if (badge) badge.remove(); return; }
    if (!badge) {
        badge = document.createElement('span');
        badge.className = `ml-1.5 px-2 py-0.5 rounded-full ${bgCls} ${textCls} text-xs font-bold`;
        const tab = document.getElementById(tabId);
        if (tab) tab.appendChild(badge);
    }
    badge.textContent = count;
}
</script>
</body>
</html>
