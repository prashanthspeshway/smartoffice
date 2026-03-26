<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Notification"%>
<%@ page import="com.smartoffice.dao.NotificationReadsDAO"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.text.SimpleDateFormat"%>
<!-- SMARTOFFICE-NOTIF-V3 -->
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }

    NotificationReadsDAO nDao = new NotificationReadsDAO();
    List<Notification> unreadList = new ArrayList<Notification>();
    List<Notification> readList   = new ArrayList<Notification>();
    String loadError = null;
    try {
        unreadList = nDao.getUnreadNotifications(username);
        readList   = nDao.getReadNotifications(username);
    } catch (Exception ex) {
        loadError = ex.getMessage();
    }
    SimpleDateFormat nFmt = new SimpleDateFormat("MMM d, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notifications v3</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<style>
.notif-card {
	transition: opacity 0.3s ease, transform 0.3s ease;
}

.notif-card.fade-out {
	opacity: 0 !important;
	transform: translateX(30px);
	pointer-events: none;
}

@
keyframes fadeSlideIn {from { opacity:0;
	transform: translateX(-20px);
}

to {
	opacity: 1;
	transform: translateX(0);
}

}
.fade-in {
	animation: fadeSlideIn 0.35s ease forwards;
}

#readSection {
	margin-top: 2rem;
}
</style>
</head>
<body class="user-iframe-page p-6">

	<div class="max-w-3xl mx-auto">

		<%-- Show error banner if DB load failed --%>
		<% if (loadError != null) { %>
		<div
			class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-xs font-mono">
			DB Error:
			<%=loadError%>
		</div>
		<% } %>

		<!-- ── Header ────────────────────────────────────────────── -->
		<div class="flex items-center justify-between mb-6">
			<div>
				<h2 class="text-2xl font-bold text-slate-800">
					<i class="fa-solid fa-bell mr-2 text-indigo-500"></i>Notifications
				</h2>
				<p class="text-slate-500 text-sm mt-1">Review and manage your
					notifications.</p>
			</div>
			<% if (!unreadList.isEmpty()) { %>
			<button id="markAllBtn" onclick="markAll()"
				class="px-4 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-xs font-semibold border border-slate-200 transition-colors">
				<i class="fa-solid fa-check-double mr-1"></i>Mark all as read
			</button>
			<% } %>
		</div>
	</div>
		<!-- ── Toast ─────────────────────────────────────────────── -->
		<div id="toast"
			class="fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg hidden text-sm font-medium text-white"
			style="max-width: min(92vw, 22rem)"></div>

		<!-- ═══════════════════════════════════════════
       UNREAD SECTION
  ════════════════════════════════════════════ -->
		<div class="mb-2">
			<div class="flex items-center gap-2 mb-3">
				<span
					class="text-xs font-bold uppercase tracking-widest text-slate-400">Unread</span>
				<span id="unreadBadge"
					class="inline-flex items-center justify-center min-w-[1.4rem] h-5 px-1.5 rounded-full bg-indigo-100 text-indigo-700 text-xs font-bold">
					<%=unreadList.size()%>
				</span>
			</div>

			<div id="unreadList" class="space-y-3">
				<% if (unreadList.isEmpty()) { %>
				<div id="unreadEmpty"
					class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
					<i
						class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>
					<p class="text-slate-400 font-semibold text-base">You're all
						caught up!</p>
					<p class="text-slate-400 text-sm mt-1">No new notifications.</p>
				</div>
				<% } else {
           for (Notification n : unreadList) {
             String nType = (n.getType() != null && n.getType().trim().length() > 0) ? n.getType().trim() : "GENERAL";

             String nIcon, nBg, nBorder, nIconColor, nBadge;
             if ("TASK".equals(nType)) {
               nIcon="fa-list-check"; nBg="bg-violet-50"; nBorder="border-l-violet-500"; nIconColor="text-violet-500"; nBadge="bg-violet-100 text-violet-700";
             } else if ("MEETING".equals(nType)) {
               nIcon="fa-video"; nBg="bg-blue-50"; nBorder="border-l-blue-500"; nIconColor="text-blue-500"; nBadge="bg-blue-100 text-blue-700";
             } else if ("LEAVE".equals(nType)) {
               nIcon="fa-calendar-xmark"; nBg="bg-amber-50"; nBorder="border-l-amber-500"; nIconColor="text-amber-500"; nBadge="bg-amber-100 text-amber-700";
             } else {
               nIcon="fa-bell"; nBg="bg-indigo-50"; nBorder="border-l-indigo-500"; nIconColor="text-indigo-500"; nBadge="bg-indigo-100 text-indigo-700";
             }

             String nTime = (n.getCreatedAt() != null) ? nFmt.format(n.getCreatedAt()) : "";
             String nBy   = (n.getCreatedBy() != null && n.getCreatedBy().trim().length() > 0) ? n.getCreatedBy() : "System";
             String nMsg  = (n.getMessage() != null) ? n.getMessage() : "";
             String nMsgAttr = nMsg.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
             String nByAttr  = nBy.replace("\"","&quot;").replace("'","&#39;");
             String nTimeAttr = nTime.replace("\"","&quot;");
      %>
				<div
					class="notif-card bg-white rounded-xl border border-slate-200 border-l-4 <%=nBorder%> shadow-sm p-5 flex items-start gap-4 hover:shadow-md"
					id="notif-<%=n.getId()%>" data-id="<%=n.getId()%>"
					data-message="<%=nMsgAttr%>" data-by="<%=nByAttr%>"
					data-time="<%=nTimeAttr%>" data-type="<%=nType%>">
					<div
						class="w-10 h-10 rounded-full <%=nBg%> flex items-center justify-center flex-shrink-0 mt-0.5">
						<i class="fa-solid <%=nIcon%> <%=nIconColor%>"></i>
					</div>
					<div class="flex-1 min-w-0">
						<p class="text-sm text-slate-700 font-medium leading-relaxed"><%=nMsg%></p>
						<div class="flex flex-wrap items-center gap-3 mt-1.5">
							<span class="text-xs text-slate-400"><i
								class="fa-solid fa-user mr-1"></i><%=nBy%></span>
							<% if (nTime.length() > 0) { %>
							<span class="text-xs text-slate-300">•</span> <span
								class="text-xs text-slate-400"><i
								class="fa-regular fa-clock mr-1"></i><%=nTime%></span>
							<% } %>
							<span
								class="text-xs font-semibold px-2 py-0.5 rounded-full <%=nBadge%>"><%=nType%></span>
						</div>
					</div>
					<button onclick="markAsRead(<%=n.getId()%>, this)"
						class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-semibold transition-colors mt-0.5 whitespace-nowrap">
						<i class="fa-solid fa-check mr-1"></i>Mark as read
					</button>
				</div>
				<% }} %>
			</div>
		</div>

		<!-- ═══════════════════════════════════════════
     READ SECTION
════════════════════════════════════════════ -->
		<div id="readSection" class="mt-8">

			<div class="flex items-center gap-2 mb-3">
				<span
					class="text-xs font-bold uppercase tracking-widest text-slate-400">Read</span>

				<span id="readBadge"
					class="inline-flex items-center justify-center min-w-[1.4rem] h-5 px-1.5 rounded-full bg-slate-100 text-slate-500 text-xs font-bold">
					<%=readList.size()%>
				</span>

				<div id="deleteAllWrapper" class="ml-auto"
					style="<%=readList.isEmpty() ? "display:none" : ""%>">
					<button id="deleteAllBtn" onclick="deleteAll()"
						class="px-3 py-1 rounded-lg bg-red-50 hover:bg-red-100 text-red-500 text-xs font-semibold border border-red-100">
						Delete all read</button>
				</div>
			</div>

			<div id="readList" class="space-y-3">

				<% if (readList.isEmpty()) { %>

				<div id="readEmpty"
					class="bg-white rounded-xl border border-slate-200 shadow-sm p-8 text-center">
					<i class="fa-solid fa-inbox text-4xl text-slate-200 mb-3 block"></i>
					<p class="text-slate-300 text-sm font-medium">No read
						notifications yet.</p>
					<p class="text-slate-300 text-xs mt-1">Notifications you mark
						as read will appear here.</p>
				</div>

				<% } else {

      for (Notification rn : readList) {

        String rType = (rn.getType()!=null && rn.getType().trim().length()>0)
                       ? rn.getType().trim() : "GENERAL";

        String rIcon,rBg,rBorder,rIconColor,rBadge;

        if("TASK".equals(rType)){
            rIcon="fa-list-check"; rBg="bg-violet-50"; rBorder="border-l-violet-300";
            rIconColor="text-violet-300"; rBadge="bg-violet-50 text-violet-400";
        }else if("MEETING".equals(rType)){
            rIcon="fa-video"; rBg="bg-blue-50"; rBorder="border-l-blue-300";
            rIconColor="text-blue-300"; rBadge="bg-blue-50 text-blue-400";
        }else if("LEAVE".equals(rType)){
            rIcon="fa-calendar-xmark"; rBg="bg-amber-50"; rBorder="border-l-amber-300";
            rIconColor="text-amber-300"; rBadge="bg-amber-50 text-amber-400";
        }else{
            rIcon="fa-bell"; rBg="bg-indigo-50"; rBorder="border-l-indigo-300";
            rIconColor="text-indigo-300"; rBadge="bg-indigo-50 text-indigo-400";
        }

        String rTime = (rn.getCreatedAt()!=null) ? nFmt.format(rn.getCreatedAt()) : "";
        String rBy   = (rn.getCreatedBy()!=null && rn.getCreatedBy().trim().length()>0)
                       ? rn.getCreatedBy() : "System";
        String rMsg  = (rn.getMessage()!=null) ? rn.getMessage() : "";
  %>

				<div
					class="notif-card bg-slate-50 rounded-xl border border-slate-200 border-l-4 <%=rBorder%> p-5 flex items-start gap-4 opacity-70 hover:opacity-100 transition-opacity"
					id="read-<%=rn.getId()%>">

					<div
						class="w-10 h-10 rounded-full <%=rBg%> flex items-center justify-center flex-shrink-0 mt-0.5">
						<i class="fa-solid <%=rIcon%> <%=rIconColor%>"></i>
					</div>

					<div class="flex-1 min-w-0">
						<p class="text-sm text-slate-500 font-medium leading-relaxed">
							<%=rMsg%>
						</p>

						<div class="flex flex-wrap items-center gap-3 mt-1.5">

							<span class="text-xs text-slate-400"> <i
								class="fa-solid fa-user mr-1"></i><%=rBy%>
							</span>

							<% if(rTime.length()>0){ %>
							<span class="text-xs text-slate-300">•</span> <span
								class="text-xs text-slate-400"> <i
								class="fa-regular fa-clock mr-1"></i><%=rTime%>
							</span>
							<% } %>

							<span
								class="text-xs font-semibold px-2 py-0.5 rounded-full <%=rBadge%>">
								<%=rType%>
							</span> <span class="text-xs text-emerald-400 font-medium ml-auto">
								<i class="fa-solid fa-check-double mr-1"></i>Read
							</span>

						</div>
					</div>

					<button onclick="deleteNotif(<%=rn.getId()%>, this)"
						class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-red-50 hover:bg-red-500 hover:text-white text-red-400 border border-red-100 hover:border-red-500 text-xs font-semibold transition-all mt-0.5 whitespace-nowrap">

						<i class="fa-solid fa-trash mr-1"></i>Delete

					</button>

				</div>

				<% }} %>

			</div>
		</div>
		<!-- /max-w-3xl -->

		<script>
var ctx = '<%=request.getContextPath()%>';

/* Toast */
function showToast(msg, ok) {
  var t = document.getElementById('toast');
  t.className = 'fixed bottom-6 right-4 z-50 px-5 py-3 rounded-lg shadow-lg text-sm font-medium text-white ' + (ok ? 'bg-emerald-500' : 'bg-red-500');
  t.textContent = msg;
  t.classList.remove('hidden');
  setTimeout(function(){ t.classList.add('hidden'); }, 2600);
}

/* Badge counters */
function syncBadges() {
  document.getElementById('unreadBadge').textContent = document.querySelectorAll('#unreadList .notif-card').length;
  document.getElementById('readBadge').textContent   = document.querySelectorAll('#readList .notif-card').length;
}

/* Empty-state: unread */
function checkUnreadEmpty() {
  if (!document.querySelector('#unreadList .notif-card')) {
    document.getElementById('unreadList').innerHTML =
      '<div id="unreadEmpty" class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">' +
      '<i class="fa-solid fa-bell-slash text-5xl text-slate-300 mb-4 block"></i>' +
      '<p class="text-slate-400 font-semibold text-base">You\'re all caught up!</p>' +
      '<p class="text-slate-400 text-sm mt-1">No new notifications.</p></div>';
    var b = document.getElementById('markAllBtn');
    if (b) b.style.display = 'none';
  }
}

/* Empty-state: read */
function checkReadEmpty() {
  if (!document.querySelector('#readList .notif-card')) {
    document.getElementById('readList').innerHTML =
      '<div id="readEmpty" class="bg-white rounded-xl border border-slate-200 shadow-sm p-8 text-center">' +
      '<i class="fa-solid fa-inbox text-4xl text-slate-200 mb-3 block"></i>' +
      '<p class="text-slate-300 text-sm font-medium">No read notifications yet.</p>' +
      '<p class="text-slate-300 text-xs mt-1">Notifications you mark as read will appear here.</p></div>';
    var daw = document.getElementById('deleteAllWrapper');
    if (daw) daw.style.display = 'none';
  }
}

/* Style map */
var STYLES = {
  'TASK'   : ['fa-list-check',     'bg-violet-50', 'border-l-violet-300', 'text-violet-300', 'bg-violet-50 text-violet-400'],
  'MEETING': ['fa-video',          'bg-blue-50',   'border-l-blue-300',   'text-blue-300',   'bg-blue-50 text-blue-400'],
  'LEAVE'  : ['fa-calendar-xmark', 'bg-amber-50',  'border-l-amber-300',  'text-amber-300',  'bg-amber-50 text-amber-400'],
  'GENERAL': ['fa-bell',           'bg-indigo-50', 'border-l-indigo-300', 'text-indigo-300', 'bg-indigo-50 text-indigo-400']
};

/* HTML escape */
function esc(str) {
  return String(str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

/* Build a read card element */
function buildReadCard(id, message, by, time, type) {
  var s = STYLES[type] || STYLES['GENERAL'];
  var div = document.createElement('div');
  div.id = 'read-' + id;
  div.className = 'notif-card fade-in bg-slate-50 rounded-xl border border-slate-200 border-l-4 ' + s[2] + ' p-5 flex items-start gap-4 opacity-70 hover:opacity-100 transition-opacity';
  div.innerHTML =
    '<div class="w-10 h-10 rounded-full ' + s[1] + ' flex items-center justify-center flex-shrink-0 mt-0.5">' +
      '<i class="fa-solid ' + s[0] + ' ' + s[3] + '"></i></div>' +
    '<div class="flex-1 min-w-0">' +
      '<p class="text-sm text-slate-500 font-medium leading-relaxed">' + esc(message) + '</p>' +
      '<div class="flex flex-wrap items-center gap-3 mt-1.5">' +
        '<span class="text-xs text-slate-400"><i class="fa-solid fa-user mr-1"></i>' + esc(by) + '</span>' +
        (time ? '<span class="text-xs text-slate-300">•</span><span class="text-xs text-slate-400"><i class="fa-regular fa-clock mr-1"></i>' + esc(time) + '</span>' : '') +
        '<span class="text-xs font-semibold px-2 py-0.5 rounded-full ' + s[4] + '">' + esc(type) + '</span>' +
        '<span class="text-xs text-emerald-400 font-medium ml-auto"><i class="fa-solid fa-check-double mr-1"></i>Read</span>' +
      '</div></div>' +
    '<button onclick="deleteNotif(' + id + ', this)" ' +
      'class="flex-shrink-0 px-3 py-1.5 rounded-lg bg-red-50 hover:bg-red-500 hover:text-white text-red-400 border border-red-100 hover:border-red-500 text-xs font-semibold transition-all mt-0.5 whitespace-nowrap">' +
      '<i class="fa-solid fa-trash mr-1"></i>Delete</button>';
  return div;
}

/* Show "Delete all" wrapper */
function showDeleteAllBtn() {
  var daw = document.getElementById('deleteAllWrapper');
  if (daw) daw.style.display = '';
}

/* ── MARK SINGLE AS READ ── */
function markAsRead(id, btn) {
  btn.disabled = true;
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';

  var card = document.getElementById('notif-' + id);
  if (!card) { showToast('Card not found', false); return; }

  var payload = {
    message : card.getAttribute('data-message'),
    by      : card.getAttribute('data-by'),
    time    : card.getAttribute('data-time'),
    type    : card.getAttribute('data-type')
  };

  fetch(ctx + '/markNotificationRead?id=' + id, { method: 'POST' })
    .then(function(res) {
      if (!res.ok) throw new Error('HTTP ' + res.status);

      card.classList.add('fade-out');
      setTimeout(function() {
        card.remove();
        checkUnreadEmpty();

        /* Remove empty placeholder in read list */
        var emp = document.getElementById('readEmpty');
        if (emp) emp.remove();
        showDeleteAllBtn();

        /* Prepend the card into read section */
        var readList = document.getElementById('readList');
        readList.insertBefore(
          buildReadCard(id, payload.message, payload.by, payload.time, payload.type),
          readList.firstChild
        );
        syncBadges();
      }, 320);

      showToast('Moved to Read section ✓', true);
      if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
    })
    .catch(function(err) {
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-check mr-1"></i>Mark as read';
      showToast('Failed: ' + err.message, false);
    });
}

/* ── MARK ALL AS READ ── */
function markAll() {
  var btn = document.getElementById('markAllBtn');
  if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i>'; }

  fetch(ctx + '/markNotificationRead?id=all', { method: 'POST' })
    .then(function(res) {
      if (!res.ok) throw new Error('HTTP ' + res.status);

      var cards = Array.prototype.slice.call(document.querySelectorAll('#unreadList .notif-card'));
      var emp   = document.getElementById('readEmpty');
      if (emp) emp.remove();
      showDeleteAllBtn();

      var readList = document.getElementById('readList');
      cards.forEach(function(card, i) {
        var p = {
          message : card.getAttribute('data-message'),
          by      : card.getAttribute('data-by'),
          time    : card.getAttribute('data-time'),
          type    : card.getAttribute('data-type'),
          id      : card.getAttribute('data-id')
        };
        card.classList.add('fade-out');
        setTimeout(function() {
          card.remove();
          readList.insertBefore(
            buildReadCard(p.id, p.message, p.by, p.time, p.type),
            readList.firstChild
          );
          syncBadges();
        }, 300 + i * 60);
      });

      setTimeout(function() { checkUnreadEmpty(); syncBadges(); }, 300 + cards.length * 60 + 80);
      showToast('All moved to Read section ✓', true);
      if (window.parent && window.parent.updateBadge) window.parent.updateBadge();
    })
    .catch(function(err) {
      if (btn) { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-check-double mr-1"></i>Mark all as read'; }
      showToast('Failed: ' + err.message, false);
    });
}

/* ── DELETE SINGLE ── */
function deleteNotif(id, btn) {
  btn.disabled = true;
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
  fetch(ctx + '/deleteNotification?id=' + id, { method: 'POST' })
    .then(function(res) {
      if (!res.ok) throw new Error('HTTP ' + res.status);
      var card = document.getElementById('read-' + id);
      if (card) {
        card.classList.add('fade-out');
        setTimeout(function() { card.remove(); checkReadEmpty(); syncBadges(); }, 320);
      }
      showToast('Notification deleted', true);
    })
    .catch(function(err) {
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-trash mr-1"></i>Delete';
      showToast('Failed: ' + err.message, false);
    });
}

/* ── DELETE ALL READ ── */
function deleteAll() {
  var btn = document.getElementById('deleteAllBtn');
  if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i>Deleting…'; }
  fetch(ctx + '/deleteNotification?id=all', { method: 'POST' })
    .then(function(res) {
      if (!res.ok) throw new Error('HTTP ' + res.status);
      var cards = Array.prototype.slice.call(document.querySelectorAll('#readList .notif-card'));
      cards.forEach(function(card, i) {
        card.classList.add('fade-out');
        setTimeout(function() { card.remove(); }, 280 + i * 50);
      });
      setTimeout(function() { checkReadEmpty(); syncBadges(); }, 280 + cards.length * 50 + 80);
      showToast('All read notifications deleted', true);
    })
    .catch(function(err) {
      if (btn) { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-trash mr-1"></i>Delete all read'; }
      showToast('Failed: ' + err.message, false);
    });
}
</script>
</body>
</html>
