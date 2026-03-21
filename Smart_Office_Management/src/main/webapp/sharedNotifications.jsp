<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.dao.NotificationReadsDAO"%>
<%@ page import="java.util.List"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }

// Always load fresh from DB
List<Notification> notifications = new NotificationReadsDAO().getUnreadNotifications(username);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Notifications</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body { font-family: 'Inter', system-ui, sans-serif; }</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-3xl mx-auto space-y-5">

    <!-- Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-2xl font-bold text-slate-800">
                <i class="fa-solid fa-bell mr-2 text-indigo-500"></i>Notifications
            </h2>
            <p class="text-slate-500 text-sm mt-1">Your unread notifications.</p>
        </div>
        <%if (notifications != null && !notifications.isEmpty()) {%>
        <button onclick="markAll()"
            class="px-4 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-xs font-semibold border border-slate-200 transition-colors">
            <i class="fa-solid fa-check-double mr-1"></i> Mark all as read
        </button>
        <%}%>
    </div>

    <!-- Toast -->
    <div id="toast" class="fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg hidden text-sm font-medium"></div>

    <!-- Notification list -->
    <div id="notifList" class="space-y-3">

    <%if (notifications == null || notifications.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">
        <i class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>
        <p class="text-slate-400 font-semibold text-base">You're all caught up!</p>
        <p class="text-slate-400 text-sm mt-1">No new notifications.</p>
    </div>
    <%} else {
        for (Notification n : notifications) {
            // Icon & color based on type
            String type = n.getType() != null ? n.getType() : "GENERAL";
            String iconClass, bgClass, borderClass;
            switch (type) {
                case "TASK":
                    iconClass = "fa-list-check"; bgClass = "bg-violet-50"; borderClass = "border-l-violet-500";
                    break;
                case "MEETING":
                    iconClass = "fa-video"; bgClass = "bg-blue-50"; borderClass = "border-l-blue-500";
                    break;
                case "LEAVE":
                    iconClass = "fa-calendar-xmark"; bgClass = "bg-amber-50"; borderClass = "border-l-amber-500";
                    break;
                default:
                    iconClass = "fa-bell"; bgClass = "bg-indigo-50"; borderClass = "border-l-indigo-500";
            }
            String iconColor = type.equals("TASK") ? "text-violet-500"
                : type.equals("MEETING") ? "text-blue-500"
                : type.equals("LEAVE") ? "text-amber-500" : "text-indigo-500";

            java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("MMM d, hh:mm a");
            String timeStr = n.getCreatedAt() != null ? fmt.format(n.getCreatedAt()) : "";
    %>
    <div class="bg-white rounded-xl border border-slate-200 border-l-4 <%=borderClass%> shadow-sm p-5 flex items-start gap-4 transition-all hover:shadow-md"
         id="notif-<%=n.getId()%>">

        <!-- Icon -->
        <div class="w-10 h-10 rounded-full <%=bgClass%> flex items-center justify-center flex-shrink-0 mt-0.5">
            <i class="fa-solid <%=iconClass%> <%=iconColor%>"></i>
        </div>

        <!-- Content -->
        <div class="flex-1 min-w-0">
            <p class="text-sm text-slate-700 font-medium leading-relaxed"><%=n.getMessage()%></p>
            <div class="flex items-center gap-3 mt-1.5">
                <span class="text-xs text-slate-400">
                    <i class="fa-solid fa-user mr-1"></i><%=n.getCreatedBy() != null ? n.getCreatedBy() : "System"%>
                </span>
                <%if (!timeStr.isEmpty()) {%>
                <span class="text-xs text-slate-300">•</span>
                <span class="text-xs text-slate-400">
                    <i class="fa-regular fa-clock mr-1"></i><%=timeStr%>
                </span>
                <%}%>
                <!-- Type badge -->
                <span class="text-xs font-semibold px-2 py-0.5 rounded-full
                    <%=type.equals("TASK")?"bg-violet-100 text-violet-700":
                       type.equals("MEETING")?"bg-blue-100 text-blue-700":
                       type.equals("LEAVE")?"bg-amber-100 text-amber-700":
                       "bg-indigo-100 text-indigo-700"%>">
                    <%=type%>
                </span>
            </div>
        </div>

        <!-- Mark as read button -->
        <button onclick="markAsRead(<%=n.getId()%>, this)"
            class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-semibold transition-colors mt-0.5 whitespace-nowrap">
            Mark as read
        </button>
    </div>
    <%}}%>

    </div>
</div>

<script>
function showToast(msg, type) {
    const t = document.getElementById('toast');
    t.className = 'fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-sm font-medium';
    t.classList.add(type === 'success' ? 'bg-emerald-500' : 'bg-red-500', 'text-white');
    t.textContent = msg;
    t.classList.remove('hidden');
    setTimeout(() => t.classList.add('hidden'), 2500);
}

function markAsRead(id, btn) {
    btn.disabled = true;
    btn.textContent = '…';
    fetch('<%=request.getContextPath()%>/markNotificationRead?id=' + id, { method: 'POST' })
    .then(res => {
        if (res.ok) {
            const el = document.getElementById('notif-' + id);
            if (el) {
                el.style.transition = 'opacity 0.3s ease';
                el.style.opacity = '0';
                setTimeout(() => el.remove(), 300);
            }
            setTimeout(() => checkEmpty(), 350);
            showToast('Marked as read', 'success');
            // Update parent badge immediately
            if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
        }
    })
    .catch(() => { btn.disabled = false; btn.textContent = 'Mark as read'; showToast('Failed. Try again.', 'error'); });
}

function markAll() {
    fetch('<%=request.getContextPath()%>/markNotificationRead?id=all', { method: 'POST' })
    .then(res => {
        if (res.ok) {
            document.querySelectorAll('#notifList > div[id^="notif-"]').forEach(el => {
                el.style.transition = 'opacity 0.3s ease';
                el.style.opacity = '0';
                setTimeout(() => el.remove(), 300);
            });
            setTimeout(() => checkEmpty(), 400);
            showToast('All marked as read', 'success');
            if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
        }
    })
    .catch(() => showToast('Failed. Try again.', 'error'));
}

function checkEmpty() {
    const remaining = document.querySelectorAll('#notifList > div[id^="notif-"]');
    if (remaining.length === 0) {
        document.getElementById('notifList').innerHTML =
            '<div class="bg-white rounded-xl border border-slate-200 shadow-sm p-14 text-center">' +
            '<i class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>' +
            '<p class="text-slate-400 font-semibold text-base">You\'re all caught up!</p>' +
            '<p class="text-slate-400 text-sm mt-1">No new notifications.</p></div>';
    }
}
</script>
</body>
</html>
