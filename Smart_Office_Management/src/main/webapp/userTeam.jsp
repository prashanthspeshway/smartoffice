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
    body {
        font-family: 'Geist', system-ui, -apple-system, sans-serif;
    }
    .team-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
        gap: 16px;
    }
    .team-card {
        border-radius: 16px;
        border: 1px solid #e2e8f0;
        background: #ffffff;
        box-shadow: 0 6px 20px rgba(15, 23, 42, 0.06);
        transition: transform .2s ease, box-shadow .2s ease;
        overflow: hidden;
    }
    .team-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 28px rgba(15, 23, 42, 0.1);
    }
    .team-card-top {
        background: linear-gradient(90deg, #eef2ff 0%, #f8fafc 100%);
        border-bottom: 1px solid #e2e8f0;
        padding: 14px 16px;
    }
    .team-title {
        font-weight: 700;
        font-size: 17px;
        color: #1e293b;
        line-height: 1.2;
    }
    .team-meta {
        font-size: 12px;
        color: #64748b;
        font-weight: 500;
        margin-top: 2px;
    }
    .team-card-body { padding: 14px 16px 16px; }
    .member-list {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
        gap: 8px;
    }
    .member-chip {
        cursor: pointer;
        transition: all 0.16s ease;
        border: 1px solid #e2e8f0;
        background: #f8fafc;
        border-radius: 12px;
        padding: 8px 10px;
        font-weight: 600;
    }
    .member-chip:hover {
        background: #e0e7ff;
        border-color: #c7d2fe;
        transform: translateY(-1px);
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
        border-radius: 18px;
        padding: 20px 20px 16px;
        width: 560px;
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
        width: 54px; height: 54px;
        border-radius: 50%;
        background: linear-gradient(135deg, #e0e7ff, #ede9fe);
        display: flex; align-items: center; justify-content: center;
        font-size: 21px; font-weight: 700; color: #6366f1;
    }
    .mini-stats {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 10px;
        margin-bottom: 12px;
    }
    .mini-stat-card {
        border: 1px solid #e2e8f0;
        background: #f8fafc;
        border-radius: 12px;
        padding: 10px 11px;
    }
    .mini-stat-label {
        color: #94a3b8;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: .05em;
        text-transform: uppercase;
    }
    .mini-stat-val {
        margin-top: 3px;
        color: #1e293b;
        font-size: 20px;
        line-height: 1;
        font-weight: 800;
    }
    .mini-stat-sub {
        margin-top: 4px;
        font-size: 11px;
        color: #64748b;
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
        margin-bottom: 10px;
    }
    .modal-divider {
        border: none;
        border-top: 1px solid #f1f5f9;
        margin: 12px 0;
    }
    .contact-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }
    .contact-card {
        border: 1px solid #e2e8f0;
        border-radius: 11px;
        background: #f8fafc;
        padding: 10px 11px;
    }
    .contact-label {
        font-size: 10px;
        letter-spacing: .04em;
        text-transform: uppercase;
        color: #94a3b8;
        font-weight: 700;
        margin-bottom: 2px;
    }
    .contact-value {
        font-size: 14px;
        font-weight: 600;
        color: #0f172a;
        line-height: 1.35;
        word-break: break-word;
    }
    @media (max-width: 780px) {
        #member-modal { width: 95vw; }
        .mini-stats { grid-template-columns: 1fr; }
        .contact-grid { grid-template-columns: 1fr; }
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
        <div style="display:flex; align-items:center; gap:12px;">
            <div class="modal-avatar" id="modal-avatar">JD</div>
            <div>
                <div style="font-size:18px; font-weight:700; color:#1e293b; margin-bottom:4px;" id="modal-fullname">John Doe</div>
                <div style="font-size:13px; color:#6366f1; margin-bottom:2px;" id="modal-role">Team Member</div>
                <div style="font-size:12px; color:#64748b;" id="modal-status">Available for contact</div>
            </div>
        </div>
        <hr class="modal-divider">
        <div class="mini-stats">
            <div class="mini-stat-card">
                <div class="mini-stat-label">Tasks</div>
                <div class="mini-stat-val" id="st-completed">0</div>
                <div class="mini-stat-sub">Completed</div>
            </div>
            <div class="mini-stat-card">
                <div class="mini-stat-label">Attendance</div>
                <div class="mini-stat-val" id="st-att">0%</div>
                <div class="mini-stat-sub"><span id="st-present">0</span>/7 days</div>
            </div>
            <div class="mini-stat-card">
                <div class="mini-stat-label">Meetings</div>
                <div class="mini-stat-val" id="st-meet">0</div>
                <div class="mini-stat-sub">Upcoming</div>
            </div>
        </div>
        <div class="contact-grid">
            <div class="contact-card">
                <div class="contact-label">Name</div>
                <div class="contact-value" id="modal-fullname-copy">John Doe</div>
            </div>
            <div class="contact-card">
                <div class="contact-label">Role</div>
                <div class="contact-value" id="modal-role-copy">Team Member</div>
            </div>
            <div class="contact-card">
                <div class="contact-label">Email</div>
                <div class="contact-value" id="modal-email">—</div>
            </div>
            <div class="contact-card">
                <div class="contact-label">Username</div>
                <div class="contact-value" id="modal-username">—</div>
            </div>
            <div class="contact-card" style="grid-column: 1 / -1;">
                <div class="contact-label">Team</div>
                <div class="contact-value" id="modal-team">—</div>
            </div>
        </div>
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
    <%} else { %>
    <div class="team-grid">
    <% for (Team t : myTeams) {%>
    <div class="team-card">
        <div class="team-card-top">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-white/80 border border-indigo-100 flex items-center justify-center flex-shrink-0">
                    <i class="fa-solid fa-people-group text-indigo-500"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <h3 class="team-title truncate"><%=t.getName()%></h3>
                    <div class="team-meta">
                        <i class="fa-solid fa-user-tie mr-1 text-indigo-400"></i>
                        <%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%>
                        <span class="mx-2 text-slate-300">•</span>
                        <i class="fa-solid fa-users mr-1 text-indigo-400"></i><%=t.getMembers().size()%> members
                    </div>
                </div>
            </div>
        </div>
        <div class="team-card-body">
            <%if (!t.getMembers().isEmpty()) {%>
                <div class="member-list">
                    <%for (User m : t.getMembers()) {
                        String displayName = (m.getFullname() != null && !m.getFullname().isEmpty()) ? m.getFullname() : m.getEmail();
                        String emailVal    = (m.getEmail()    != null) ? m.getEmail()    : "";
                        String usernameVal = (m.getUsername() != null) ? m.getUsername() : "";
                        String teamName    = t.getName();
                    %>
                    <span
                        class="member-chip inline-flex items-center gap-2 text-slate-700 text-xs font-medium"
                        onclick="openMemberModal('<%=displayName.replace("'", "\\'")%>', '<%=usernameVal.replace("'", "\\'")%>', '<%=emailVal.replace("'", "\\'")%>', '<%=teamName.replace("'", "\\'")%>')"
                        title="Click to view details"
                    >
                        <i class="fa-solid fa-circle-user text-indigo-400"></i>
                        <span style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:130px;"><%=displayName%></span>
                    </span>
                    <%}%>
                </div>
            <%}%>
        </div>
    </div>
    <%}%>
    </div>
    <%}%>
</div>

<script>
const CTX = '<%=request.getContextPath()%>';

function setStatsLoading() {
    document.getElementById('st-completed').textContent = '…';
    document.getElementById('st-att').textContent = '…';
    document.getElementById('st-present').textContent = '…';
    document.getElementById('st-meet').textContent = '…';
}

function openMemberModal(fullname, username, email, team) {
    var initials = fullname.trim().split(/\s+/).map(function(w){ return w[0]; }).slice(0,2).join('').toUpperCase();
    document.getElementById('modal-avatar').textContent   = initials || '?';
    document.getElementById('modal-fullname').textContent = fullname  || '—';
    document.getElementById('modal-fullname-copy').textContent = fullname  || '—';
    document.getElementById('modal-username').textContent = username  || '—';
    document.getElementById('modal-email').textContent    = email     || '—';
    document.getElementById('modal-team').textContent     = team      || '—';
    document.getElementById('modal-role').textContent     = 'Team Member';
    document.getElementById('modal-role-copy').textContent = 'Team Member';
    document.getElementById('modal-status').textContent   = 'Loading quick stats…';
    setStatsLoading();
    document.getElementById('member-modal-overlay').classList.add('active');

    fetch(CTX + '/userTeamMemberStats?email=' + encodeURIComponent(email), { credentials: 'same-origin' })
        .then(function(r) {
            if (!r.ok) throw new Error('Failed');
            return r.json();
        })
        .then(function(d) {
            document.getElementById('modal-fullname').textContent = d.fullName || fullname || '—';
            document.getElementById('modal-fullname-copy').textContent = d.fullName || fullname || '—';
            document.getElementById('modal-username').textContent = d.username || username || '—';
            document.getElementById('modal-email').textContent = d.email || email || '—';
            document.getElementById('modal-role').textContent = d.role || 'Team Member';
            document.getElementById('modal-role-copy').textContent = d.role || 'Team Member';
            document.getElementById('modal-status').textContent = (d.status || 'Active') + ' • Available for contact';

            document.getElementById('st-completed').textContent = d.completedTasks ?? 0;
            document.getElementById('st-att').textContent = (d.attendanceRate7d ?? 0) + '%';
            document.getElementById('st-present').textContent = d.presentDays7d ?? 0;
            document.getElementById('st-meet').textContent = d.upcomingMeetings ?? 0;
        })
        .catch(function() {
            document.getElementById('modal-status').textContent = 'Available for contact';
            document.getElementById('st-completed').textContent = '0';
            document.getElementById('st-att').textContent = '0%';
            document.getElementById('st-present').textContent = '0';
            document.getElementById('st-meet').textContent = '0';
        });
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