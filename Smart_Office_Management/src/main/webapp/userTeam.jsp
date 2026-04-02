<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="java.util.List"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Team</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
<style>
    .member-chip {
        cursor: pointer;
        transition: background-color 0.15s, transform 0.1s;
    }
    .member-chip:hover {
        background-color: #e0e7ff;
        transform: scale(1.03);
    }

    /* Modal overlay */
    #member-modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.4);
        z-index: 1000;
        align-items: center;
        justify-content: center;
    }
    #member-modal-overlay.active {
        display: flex;
    }
    #member-modal {
        background: white;
        border-radius: 16px;
        padding: 28px 28px 24px;
        width: 340px;
        max-width: 90vw;
        box-shadow: 0 8px 40px rgba(0,0,0,0.18);
        position: relative;
        animation: popIn 0.18s ease;
    }
    @keyframes popIn {
        from { transform: scale(0.92); opacity: 0; }
        to   { transform: scale(1);    opacity: 1; }
    }
    #modal-close-btn {
        position: absolute;
        top: 14px; right: 16px;
        background: none; border: none;
        font-size: 18px; color: #94a3b8;
        cursor: pointer;
        line-height: 1;
    }
    #modal-close-btn:hover { color: #475569; }
    .modal-avatar {
        width: 56px; height: 56px;
        border-radius: 50%;
        background: #e0e7ff;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; font-weight: 700; color: #6366f1;
        margin-bottom: 12px;
    }
    .modal-label {
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.07em;
        color: #94a3b8;
        margin-bottom: 2px;
    }
    .modal-value {
        font-size: 14px;
        color: #1e293b;
        font-weight: 500;
        margin-bottom: 12px;
    }
    .modal-divider {
        border: none;
        border-top: 1px solid #f1f5f9;
        margin: 12px 0;
    }
</style>
</head>
<body class="user-iframe-page p-6">

<!-- Member Detail Modal -->
<div id="member-modal-overlay" onclick="closeModal(event)">
    <div id="member-modal">
        <button id="modal-close-btn" onclick="closeModalDirect()">
            <i class="fa-solid fa-xmark"></i>
        </button>
        <div class="modal-avatar" id="modal-avatar">JD</div>
        <div style="font-size:18px; font-weight:700; color:#1e293b; margin-bottom:4px;" id="modal-fullname">John Doe</div>
        <div style="font-size:13px; color:#6366f1; margin-bottom:14px;" id="modal-role">Team Member</div>
        <hr class="modal-divider">
        <div class="modal-label">Username</div>
        <div class="modal-value" id="modal-username">—</div>
        <div class="modal-label">Email</div>
        <div class="modal-value" id="modal-email">—</div>
        <div class="modal-label">Team</div>
        <div class="modal-value" id="modal-team">—</div>
    </div>
</div>

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800">
            <i class="fa-solid fa-users mr-2 text-indigo-500"></i>My Team
        </h2>
        <p class="text-slate-500 text-sm mt-1">Teams you are a member of.</p>
    </div>

    <%if (myTeams == null || myTeams.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
        <i class="fa-solid fa-people-group text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">You are not part of any team yet.</p>
    </div>
    <%} else { for (Team t : myTeams) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
        <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center flex-shrink-0">
                <i class="fa-solid fa-people-group text-indigo-500 text-xl"></i>
            </div>
            <div class="flex-1 min-w-0">
                <h3 class="font-bold text-slate-800 text-lg"><%=t.getName()%></h3>
                <div class="flex flex-wrap gap-4 mt-2 text-sm text-slate-500">
                    <span>
                        <i class="fa-solid fa-user-tie mr-1.5 text-indigo-400"></i>
                        Manager: <strong class="text-slate-700"><%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%></strong>
                    </span>
                    <span>
                        <i class="fa-solid fa-users mr-1.5 text-indigo-400"></i>
                        Members: <strong class="text-slate-700"><%=t.getMembers().size()%></strong>
                    </span>
                </div>
                <%if (!t.getMembers().isEmpty()) {%>
                <div class="mt-3 flex flex-wrap gap-2">
                    <%for (User m : t.getMembers()) {
                        String displayName = (m.getFullname() != null && !m.getFullname().isEmpty()) ? m.getFullname() : m.getEmail();
                        String emailVal    = (m.getEmail()    != null) ? m.getEmail()    : "";
                        String usernameVal = (m.getUsername() != null) ? m.getUsername() : "";
                        String teamName    = t.getName();
                    %>
                    <span
                        class="member-chip inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-medium px-3 py-1 rounded-full"
                        onclick="openMemberModal('<%=displayName.replace("'", "\\'")%>', '<%=usernameVal.replace("'", "\\'")%>', '<%=emailVal.replace("'", "\\'")%>', '<%=teamName.replace("'", "\\'")%>')"
                        title="Click to view details"
                    >
                        <i class="fa-solid fa-circle-user text-indigo-400 text-xs"></i>
                        <%=displayName%>
                    </span>
                    <%}%>
                </div>
                <%}%>
            </div>
        </div>
    </div>
    <%}}%>
</div>

<script>
function openMemberModal(fullname, username, email, team) {
    var initials = fullname.trim().split(/\s+/).map(function(w){ return w[0]; }).slice(0,2).join('').toUpperCase();
    document.getElementById('modal-avatar').textContent   = initials || '?';
    document.getElementById('modal-fullname').textContent = fullname  || '—';
    document.getElementById('modal-username').textContent = username  || '—';
    document.getElementById('modal-email').textContent    = email     || '—';
    document.getElementById('modal-team').textContent     = team      || '—';
    document.getElementById('member-modal-overlay').classList.add('active');
}

function closeModal(e) {
    if (e.target === document.getElementById('member-modal-overlay')) {
        closeModalDirect();
    }
}

function closeModalDirect() {
    document.getElementById('member-modal-overlay').classList.remove('active');
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModalDirect();
});
</script>
</body>
</html>