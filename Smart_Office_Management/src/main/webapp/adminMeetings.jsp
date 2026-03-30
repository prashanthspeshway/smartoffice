<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.smartoffice.model.*, java.text.SimpleDateFormat" %>
<%
    List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");
    List<User> users       = (List<User>)   request.getAttribute("users");
    List<Team> teams       = (List<Team>)   request.getAttribute("teams");
    String error   = request.getParameter("error");
    String success = request.getParameter("success");
    SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

    int totalToday        = (meetings != null) ? meetings.size() : 0;
    int totalParticipants = 0;
    if (meetings != null) for (Meeting m : meetings) totalParticipants += m.getParticipantCount();

    String safeSuccess = success != null ? success.replace("&","&amp;").replace("\"","&quot;") : "";
    String safeError   = error   != null ? error.replace("&","&amp;").replace("\"","&quot;")   : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Meetings • Smart Office HRMS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>
:root {
    --bg:           #f4f6fb;
    --surface:      #ffffff;
    --surface2:     #f8f9fc;
    --border:       #e8ecf4;
    --border2:      #d4daea;
    --text:         #1a1d2e;
    --text2:        #5a6278;
    --text3:        #8d96b0;
    --accent:       #4f6ef7;
    --accent-light: #eef1fe;
    --accent-hover: #3a58e8;
    --success:      #22c55e;
    --success-light:#f0fdf4;
    --danger:       #ef4444;
    --danger-light: #fef2f2;
    --warning:      #f59e0b;
    --warning-light:#fffbeb;
    --purple:       #a855f7;
    --purple-light: #faf5ff;
    --shadow-sm:    0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
    --shadow:       0 4px 16px rgba(0,0,0,.07), 0 1px 4px rgba(0,0,0,.04);
    --shadow-lg:    0 20px 50px rgba(0,0,0,.12);
    --radius:       14px;
    --radius-sm:    8px;
    --radius-full:  9999px;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: 'Geist', system-ui, sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    line-height: 1.6;
}
.page { max-width: 1100px; margin: 0 auto; padding: 36px 24px; }

/* ── Header ── */
.page-header {
    display: flex; align-items: flex-start;
    justify-content: space-between; gap: 16px;
    margin-bottom: 32px; flex-wrap: wrap;
}
.page-title {
    font-family: 'Geist', system-ui, sans-serif;
    font-size: 28px; font-weight: 600; color: var(--text);
    display: flex; align-items: center; gap: 10px; line-height: 1.2;
}
.page-title i { color: var(--accent); font-size: 22px; }
.page-subtitle { color: var(--text3); font-size: 14px; margin-top: 4px; }

/* ── Stats ── */
.stats-row { display: flex; gap: 16px; margin-bottom: 32px; flex-wrap: wrap; }
.stat-card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); padding: 20px 24px;
    box-shadow: var(--shadow-sm); flex: 1; min-width: 130px;
    display: flex; align-items: center; gap: 14px;
    transition: box-shadow .2s, transform .2s;
}
.stat-card:hover { box-shadow: var(--shadow); transform: translateY(-1px); }
.stat-icon {
    width: 44px; height: 44px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px; flex-shrink: 0;
}
.stat-icon.blue   { background: var(--accent-light);  color: var(--accent); }
.stat-icon.green  { background: var(--success-light); color: var(--success); }
.stat-icon.purple { background: var(--purple-light);  color: var(--purple); }
.stat-num   { font-size: 26px; font-weight: 700; color: var(--text); line-height: 1; }
.stat-label { font-size: 12px; color: var(--text3); font-weight: 500; text-transform: uppercase; letter-spacing: .6px; margin-top: 3px; }

/* ── Btn ── */
.btn {
    display: inline-flex; align-items: center; gap: 7px;
    padding: 10px 18px; border-radius: var(--radius-sm);
    font-size: 13px; font-weight: 600; font-family: inherit;
    cursor: pointer; border: none; transition: all .15s; text-decoration: none;
}
.btn-primary { background: var(--accent); color: #fff; }
.btn-primary:hover { background: var(--accent-hover); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,110,247,.3); }
.btn-danger  { background: var(--danger); color: #fff; }
.btn-danger:hover  { background: #dc2626; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(239,68,68,.3); }
.btn-ghost   { background: var(--surface2); color: var(--text2); border: 1px solid var(--border2); }
.btn-ghost:hover { background: var(--border); }
.btn-sm { padding: 6px 12px; font-size: 12px; }

/* ── Alert ── */
.alert {
    padding: 14px 18px; border-radius: 10px; margin-bottom: 24px;
    font-size: 13px; font-weight: 500; display: flex; align-items: center; gap: 10px;
}
.alert.success { background: var(--success-light); color: #15803d; border: 1px solid #86efac; }
.alert.error   { background: var(--danger-light);  color: #b91c1c; border: 1px solid #fca5a5; }

/* ── Meetings grid ── */
.meetings-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 18px;
    align-items: start;
}

/* ── Meeting card ── */
.meeting-card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); overflow: hidden;
    box-shadow: var(--shadow-sm); transition: box-shadow .2s, transform .2s;
    display: flex; flex-direction: column;
}
.meeting-card:hover { box-shadow: var(--shadow); transform: translateY(-2px); }

.meeting-card-top {
    padding: 18px 20px 14px;
    border-bottom: 1px solid var(--border);
    background: linear-gradient(135deg, var(--accent-light) 0%, #f0f4ff 100%);
}
.meeting-card-title {
    font-size: 15px; font-weight: 700; color: var(--text);
    display: flex; align-items: flex-start; gap: 8px; margin-bottom: 8px;
}
.meeting-card-title i { color: var(--accent); margin-top: 2px; flex-shrink: 0; }

.time-badge {
    display: inline-flex; align-items: center; gap: 6px;
    background: #fff; border: 1px solid var(--border2);
    border-radius: var(--radius-full);
    padding: 4px 12px; font-size: 12px; font-weight: 600;
    color: var(--accent);
}

.meeting-card-body { padding: 16px 20px; flex: 1; }
.meeting-desc { font-size: 13px; color: var(--text2); line-height: 1.5; margin-bottom: 14px; }

.meta-row {
    display: flex; align-items: center; gap: 10px;
    flex-wrap: wrap; margin-bottom: 0;
}
.meta-chip {
    display: inline-flex; align-items: center; gap: 5px;
    background: var(--accent-light); color: var(--accent);
    padding: 4px 10px; border-radius: var(--radius-full);
    font-size: 12px; font-weight: 600;
}
.meta-chip.purple { background: var(--purple-light); color: var(--purple); }

.meeting-card-footer {
    padding: 12px 20px; border-top: 1px solid var(--border);
    background: var(--surface2);
    display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
}
.meeting-link-btn {
    display: inline-flex; align-items: center; gap: 6px;
    font-size: 12px; font-weight: 600; color: var(--accent);
    text-decoration: none; padding: 6px 12px;
    background: var(--accent-light); border-radius: var(--radius-sm);
    transition: background .15s;
}
.meeting-link-btn:hover { background: #dde5fd; }

/* ── Empty state ── */
.empty-state {
    text-align: center; padding: 60px 20px; color: var(--text3);
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow-sm);
}
.empty-state i { font-size: 48px; opacity: .25; display: block; margin-bottom: 16px; }
.empty-state h3 { font-size: 16px; font-weight: 600; color: var(--text2); margin-bottom: 6px; }
.empty-state p  { font-size: 13px; }

/* ── Section header ── */
.section-header {
    display: flex; align-items: center;
    justify-content: space-between; margin-bottom: 20px;
}
.section-title {
    font-family: 'Geist', system-ui, sans-serif;
    font-size: 20px; font-weight: 600; color: var(--text);
    display: flex; align-items: center; gap: 8px;
}
.section-title i { color: var(--accent); font-size: 17px; }

/* ── Modal overlay ── */
.modal-overlay {
    display: none; position: fixed; inset: 0;
    background: rgba(15,20,40,.5); backdrop-filter: blur(4px);
    z-index: 9998; align-items: center; justify-content: center; padding: 20px;
}
.modal-overlay.show { display: flex; }
.modal-box {
    background: var(--surface); border-radius: 20px;
    box-shadow: var(--shadow-lg); max-width: 680px; width: 100%;
    max-height: 90vh; overflow-y: auto;
    animation: modalIn .2s ease;
}
@keyframes modalIn { from { transform:scale(.93); opacity:0; } to { transform:scale(1); opacity:1; } }
.modal-header {
    display: flex; justify-content: space-between; align-items: center;
    padding: 24px 28px 20px; border-bottom: 1px solid var(--border);
    background: linear-gradient(135deg, var(--accent-light), #f0f4ff);
    border-radius: 20px 20px 0 0;
}
.modal-title { font-family: 'Geist', system-ui, sans-serif; font-size: 20px; font-weight: 600; color: var(--text); }
.close-btn {
    background: #fff; border: 1px solid var(--border2);
    border-radius: 8px; width: 32px; height: 32px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; color: var(--text2); font-size: 14px; transition: all .15s;
}
.close-btn:hover { background: var(--bg); color: var(--danger); }
.modal-body { padding: 24px 28px; }

/* ── Form ── */
.form-group { margin-bottom: 18px; }
.form-label {
    display: block; font-size: 12px; font-weight: 700;
    color: var(--text2); margin-bottom: 7px;
    text-transform: uppercase; letter-spacing: .5px;
}
.form-input, .form-textarea, .form-select {
    width: 100%; padding: 10px 14px;
    border: 1.5px solid var(--border2); border-radius: var(--radius-sm);
    font-size: 14px; font-family: inherit; color: var(--text);
    background: var(--surface); transition: all .2s; outline: none;
}
.form-textarea { resize: vertical; min-height: 80px; }
.form-input:focus, .form-textarea:focus, .form-select:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(79,110,247,.1);
}
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-datetime-split {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    align-items: end;
}
.form-sublabel {
    display: block;
    font-size: 11px;
    font-weight: 600;
    color: var(--text3);
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}
@media (max-width: 560px) {
    .form-row { grid-template-columns: 1fr; }
}
.radio-group { display: flex; flex-direction: column; gap: 8px; }
.radio-item {
    display: flex; align-items: center; gap: 8px;
    padding: 9px 12px; border: 1.5px solid var(--border); border-radius: 8px;
    cursor: pointer; transition: all .15s;
}
.radio-item:hover { background: var(--accent-light); border-color: var(--accent); }
.radio-item input[type="radio"] { width: 16px; height: 16px; accent-color: var(--accent); cursor: pointer; }
.radio-item label { font-size: 13px; color: var(--text2); cursor: pointer; flex: 1; }
.checkbox-group {
    display: grid; grid-template-columns: repeat(auto-fill, minmax(200px,1fr));
    gap: 8px; max-height: 180px; overflow-y: auto;
    padding: 12px; border: 1.5px solid var(--border); border-radius: var(--radius-sm);
}
.checkbox-item { display: flex; align-items: center; gap: 8px; }
.checkbox-item input[type="checkbox"] { width: 16px; height: 16px; accent-color: var(--accent); cursor: pointer; }
.checkbox-item label { font-size: 13px; color: var(--text2); cursor: pointer; }

/* ── Participants chips ── */
.participants-list { display: flex; flex-wrap: wrap; gap: 8px; }
.participant-chip {
    background: var(--accent-light); color: var(--accent);
    padding: 8px 14px; border-radius: var(--radius-full);
    font-size: 13px; font-weight: 600;
    display: flex; align-items: center; gap: 7px;
    border: 1px solid rgba(79,110,247,.2);
}
.participant-chip .role { opacity: .65; font-size: 11px; font-weight: 500; }

/* ── Animations ── */
@keyframes fadeUp { from { opacity:0; transform:translateY(12px); } to { opacity:1; transform:translateY(0); } }
.anim   { animation: fadeUp .4s ease both; }
.anim-1 { animation-delay: .05s; }
.anim-2 { animation-delay: .1s; }
.anim-3 { animation-delay: .15s; }
.anim-4 { animation-delay: .2s; }
</style>
</head>
<body>

<div id="toast" aria-live="polite"
     data-success="<%=safeSuccess%>"
     data-error="<%=safeError%>"></div>

<div class="page">

    <!-- Header -->
    <div class="page-header anim">
        <div>
            <div class="page-title">
                <i class="fa-solid fa-users-rectangle"></i> Meeting Management
            </div>
            <p class="page-subtitle">Schedule and manage today's meetings across your organisation</p>
        </div>
        <button class="btn btn-primary" onclick="openCreateModal()">
            <i class="fa-solid fa-plus"></i> Schedule Meeting
        </button>
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card anim anim-1">
            <div class="stat-icon blue"><i class="fa-solid fa-calendar-day"></i></div>
            <div>
                <div class="stat-num"><%=totalToday%></div>
                <div class="stat-label">Today's Meetings</div>
            </div>
        </div>
        <div class="stat-card anim anim-2">
            <div class="stat-icon green"><i class="fa-solid fa-users"></i></div>
            <div>
                <div class="stat-num"><%=totalParticipants%></div>
                <div class="stat-label">Total Participants</div>
            </div>
        </div>
        <div class="stat-card anim anim-3">
            <div class="stat-icon purple"><i class="fa-solid fa-clock"></i></div>
            <div>
                <div class="stat-num"><%= new java.text.SimpleDateFormat("hh:mm a").format(new java.util.Date()) %></div>
                <div class="stat-label">Current Time</div>
            </div>
        </div>
    </div>

    <!-- Alerts -->
    <% if (error != null) { %>
    <div class="alert error anim">
        <i class="fa-solid fa-circle-xmark"></i> <%=error%>
    </div>
    <% } %>
    <% if (success != null) { %>
    <div class="alert success anim">
        <i class="fa-solid fa-circle-check"></i> <%=success%>
    </div>
    <% } %>

    <!-- Meetings Section -->
    <div class="anim anim-4">
        <div class="section-header">
            <div class="section-title">
                <i class="fa-solid fa-calendar-check"></i> Today's Scheduled Meetings
            </div>
            <span style="font-size:13px; color:var(--text3); font-weight:500;">
                <%=totalToday%> meeting<%=totalToday != 1 ? "s" : ""%> today
            </span>
        </div>

        <% if (meetings == null || meetings.isEmpty()) { %>
        <div class="empty-state">
            <i class="fa-solid fa-calendar-xmark"></i>
            <h3>No meetings today</h3>
            <p>Schedule a meeting using the button above</p>
        </div>

        <% } else { %>
        <div class="meetings-grid">
            <% for (Meeting m : meetings) {
                String startT = m.getStartTime() != null ? timeFmt.format(m.getStartTime()) : "--";
                String endT   = m.getEndTime()   != null ? timeFmt.format(m.getEndTime())   : "--";
            %>
            <div class="meeting-card">
                <!-- Top band -->
                <div class="meeting-card-top">
                    <div class="meeting-card-title">
                        <i class="fa-solid fa-video"></i>
                        <span><%=m.getTitle()%></span>
                    </div>
                    <span class="time-badge">
                        <i class="fa-solid fa-clock"></i>
                        <%=startT%> &ndash; <%=endT%>
                    </span>
                </div>

                <!-- Body -->
                <div class="meeting-card-body">
                    <% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
                    <p class="meeting-desc"><%=m.getDescription()%></p>
                    <% } %>
                    <div class="meta-row">
                        <span class="meta-chip">
                            <i class="fa-solid fa-users"></i>
                            <%=m.getParticipantCount()%> participant<%=m.getParticipantCount() != 1 ? "s" : ""%>
                        </span>
                        <span class="meta-chip purple">
                            <i class="fa-solid fa-user-shield"></i>
                            <%=m.getCreatedBy()%>
                        </span>
                    </div>
                </div>

                <!-- Footer -->
                <div class="meeting-card-footer">
                    <% if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) { %>
                    <a href="<%=m.getMeetingLink()%>" target="_blank" class="meeting-link-btn">
                        <i class="fa-solid fa-video"></i> Join Meeting
                    </a>
                    <% } %>
                    <button class="btn btn-primary btn-sm" onclick="viewParticipants(<%=m.getId()%>)">
                        <i class="fa-solid fa-eye"></i> Participants
                    </button>
                    <form method="post" action="adminMeetings" style="display:inline;"
                          onsubmit="return confirm('Delete this meeting?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%=m.getId()%>">
                        <button type="submit" class="btn btn-danger btn-sm">
                            <i class="fa-solid fa-trash"></i> Delete
                        </button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<!-- ── Create Meeting Modal ── -->
<div id="createModal" class="modal-overlay" onclick="if(event.target===this)closeCreateModal()">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="modal-header">
            <div class="modal-title">
                <i class="fa-solid fa-calendar-plus" style="color:var(--accent);margin-right:8px;"></i>
                Schedule New Meeting
            </div>
            <button class="close-btn" onclick="closeCreateModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <form method="post" action="adminMeetings">
                <input type="hidden" name="action" value="create">

                <div class="form-group">
                    <label class="form-label">Meeting Title</label>
                    <input type="text" name="title" class="form-input" required placeholder="e.g., Q1 Planning Meeting">
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-textarea" placeholder="Meeting agenda and details..."></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Start</label>
                        <div class="form-datetime-split">
                            <div>
                                <span class="form-sublabel">Date</span>
                                <input type="date" id="meetingStartDate" class="form-input" required>
                            </div>
                            <div>
                                <span class="form-sublabel">Time</span>
                                <input type="time" id="meetingStartTimeOnly" class="form-input" required step="60">
                            </div>
                        </div>
                        <input type="hidden" name="startTime" id="meetingStartTimeHidden" value="">
                    </div>
                    <div class="form-group">
                        <label class="form-label">End</label>
                        <div class="form-datetime-split">
                            <div>
                                <span class="form-sublabel">Date</span>
                                <input type="date" id="meetingEndDate" class="form-input" required>
                            </div>
                            <div>
                                <span class="form-sublabel">Time</span>
                                <input type="time" id="meetingEndTimeOnly" class="form-input" required step="60">
                            </div>
                        </div>
                        <input type="hidden" name="endTime" id="meetingEndTimeHidden" value="">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Meeting Link</label>
                    <input type="url" name="meetingLink" class="form-input" placeholder="https://meet.google.com/...">
                </div>

                <div class="form-group">
                    <label class="form-label">Participants</label>
                    <div class="radio-group">
                        <div class="radio-item">
                            <input type="radio" id="specific" name="participantType" value="specific" checked onchange="toggleParticipants()">
                            <label for="specific">Select Specific Users</label>
                        </div>
                        <div class="radio-item">
                            <input type="radio" id="team" name="participantType" value="team" onchange="toggleParticipants()">
                            <label for="team">Entire Team</label>
                        </div>
                        <div class="radio-item">
                            <input type="radio" id="allManagers" name="participantType" value="allManagers" onchange="toggleParticipants()">
                            <label for="allManagers">All Managers</label>
                        </div>
                        <div class="radio-item">
                            <input type="radio" id="allEmployees" name="participantType" value="allEmployees" onchange="toggleParticipants()">
                            <label for="allEmployees">All Employees</label>
                        </div>
                        <div class="radio-item">
                            <input type="radio" id="everyone" name="participantType" value="everyone" onchange="toggleParticipants()">
                            <label for="everyone">Everyone (Managers + Employees)</label>
                        </div>
                    </div>
                </div>

                <div id="specificUsers" class="form-group">
                    <label class="form-label">Select Users</label>
                    <div class="checkbox-group">
                        <% if (users != null) for (User u : users) {
                            if (!"admin".equalsIgnoreCase(u.getRole())) { %>
                        <div class="checkbox-item">
                            <input type="checkbox" name="participants" value="<%=u.getEmail()%>" id="u_<%=u.getEmail()%>">
                            <label for="u_<%=u.getEmail()%>">
                                <%=u.getFirstname()%> <%=u.getLastname()%>
                                <span style="color:var(--text3);font-size:11px;">(<%=u.getRole()%>)</span>
                            </label>
                        </div>
                        <% } } %>
                    </div>
                </div>

                <div id="teamSelect" class="form-group" style="display:none;">
                    <label class="form-label">Select Team</label>
                    <select name="teamId" class="form-select">
                        <option value="">-- Select Team --</option>
                        <% if (teams != null) for (Team t : teams) { %>
                        <option value="<%=t.getId()%>"><%=t.getName()%></option>
                        <% } %>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary"
                        style="width:100%; margin-top:8px; padding:12px; justify-content:center;">
                    <i class="fa-solid fa-calendar-plus"></i> Schedule Meeting
                </button>
            </form>
        </div>
    </div>
</div>

<!-- ── Participants Modal ── -->
<div id="participantsModal" class="modal-overlay" onclick="if(event.target===this)closeParticipantsModal()">
    <div class="modal-box" style="max-width:500px;" onclick="event.stopPropagation()">
        <div class="modal-header">
            <div class="modal-title">
                <i class="fa-solid fa-users" style="color:var(--accent);margin-right:8px;"></i>
                Meeting Participants
            </div>
            <button class="close-btn" onclick="closeParticipantsModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <div id="participantsList"></div>
        </div>
    </div>
</div>

<script>
/* ── Meeting date + time: separate inputs so type=time min grays past times (datetime-local often does not) ── */
function meetingToDateOnly(d) {
    var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
}
function meetingToTimeOnly(d) {
    var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
    return pad(d.getHours()) + ':' + pad(d.getMinutes());
}
function meetingGetStartDateTime() {
    var sd = document.getElementById('meetingStartDate');
    var st = document.getElementById('meetingStartTimeOnly');
    if (!sd || !st || !sd.value || !st.value) return null;
    return meetingParseLocalDatetime(sd.value + 'T' + st.value);
}
function meetingGetEndDateTime() {
    var ed = document.getElementById('meetingEndDate');
    var et = document.getElementById('meetingEndTimeOnly');
    if (!ed || !et || !ed.value || !et.value) return null;
    return meetingParseLocalDatetime(ed.value + 'T' + et.value);
}
function composeMeetingHiddenFields() {
    var sd = document.getElementById('meetingStartDate');
    var st = document.getElementById('meetingStartTimeOnly');
    var ed = document.getElementById('meetingEndDate');
    var et = document.getElementById('meetingEndTimeOnly');
    var hs = document.getElementById('meetingStartTimeHidden');
    var he = document.getElementById('meetingEndTimeHidden');
    if (!sd || !st || !hs) return;
    hs.value = (sd.value && st.value) ? (sd.value + 'T' + st.value) : '';
    if (ed && et && he) he.value = (ed.value && et.value) ? (ed.value + 'T' + et.value) : '';
}
/** Earliest valid end = start + 1 minute (servlet requires end after start). */
function meetingMinEndDateTime() {
    var startDt = meetingGetStartDateTime();
    if (!startDt) return new Date(Date.now() + 60 * 1000);
    return new Date(startDt.getTime() + 60 * 1000);
}
function meetingParseLocalDatetime(str) {
    if (!str) return null;
    var parts = str.split('T');
    if (parts.length !== 2) return null;
    var da = parts[0].split('-');
    var ti = parts[1].split(':');
    if (da.length < 3 || ti.length < 2) return null;
    return new Date(
        parseInt(da[0], 10),
        parseInt(da[1], 10) - 1,
        parseInt(da[2], 10),
        parseInt(ti[0], 10),
        parseInt(ti[1], 10),
        0,
        0
    );
}
/** Compare calendar minutes (datetime-local has no seconds). */
function meetingMinuteTs(d) {
    return new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes()).getTime();
}
function meetingSameOrAfterMinute(a, b) {
    return meetingMinuteTs(a) >= meetingMinuteTs(b);
}
function meetingAfterMinute(a, b) {
    return meetingMinuteTs(a) > meetingMinuteTs(b);
}
function refreshMeetingDatetimeConstraints() {
    var now = new Date();
    var startDateEl = document.getElementById('meetingStartDate');
    var startTimeEl = document.getElementById('meetingStartTimeOnly');
    var endDateEl = document.getElementById('meetingEndDate');
    var endTimeEl = document.getElementById('meetingEndTimeOnly');
    if (!startDateEl || !startTimeEl || !endDateEl || !endTimeEl) return;

    var todayStr = meetingToDateOnly(now);
    var nowTimeStr = meetingToTimeOnly(now);

    startDateEl.min = todayStr;
    if (startDateEl.value && startDateEl.value < todayStr) startDateEl.value = todayStr;

    if (startDateEl.value === todayStr) {
        startTimeEl.min = nowTimeStr;
    } else {
        startTimeEl.removeAttribute('min');
    }
    if (startDateEl.value === todayStr && startTimeEl.value && startTimeEl.min && startTimeEl.value < startTimeEl.min) {
        startTimeEl.value = startTimeEl.min;
    }

    var minEnd = meetingMinEndDateTime();
    var minEndDateStr = meetingToDateOnly(minEnd);
    var minEndTimeStr = meetingToTimeOnly(minEnd);

    endDateEl.min = minEndDateStr;
    if (endDateEl.value && endDateEl.value < minEndDateStr) endDateEl.value = minEndDateStr;

    if (endDateEl.value === minEndDateStr) {
        endTimeEl.min = minEndTimeStr;
    } else {
        endTimeEl.removeAttribute('min');
    }
    if (endDateEl.value && endTimeEl.value && endDateEl.value === minEndDateStr) {
        if (endTimeEl.min && endTimeEl.value < endTimeEl.min) {
            endTimeEl.value = endTimeEl.min;
        }
    }

    composeMeetingHiddenFields();
}

/* ── Modal controls ── */
function openCreateModal() {
    document.getElementById('createModal').classList.add('show');
    var now = new Date();
    var sd = document.getElementById('meetingStartDate');
    var st = document.getElementById('meetingStartTimeOnly');
    var ed = document.getElementById('meetingEndDate');
    var et = document.getElementById('meetingEndTimeOnly');
    if (sd && st && ed && et) {
        sd.value = meetingToDateOnly(now);
        st.value = meetingToTimeOnly(now);
        var endSuggested = new Date(now.getTime() + 60 * 60 * 1000);
        ed.value = meetingToDateOnly(endSuggested);
        et.value = meetingToTimeOnly(endSuggested);
    }
    refreshMeetingDatetimeConstraints();
}
function closeCreateModal()       { document.getElementById('createModal').classList.remove('show'); }
function closeParticipantsModal() { document.getElementById('participantsModal').classList.remove('show'); }

function toggleParticipants() {
    var type = document.querySelector('input[name="participantType"]:checked').value;
    document.getElementById('specificUsers').style.display = type === 'specific' ? 'block' : 'none';
    document.getElementById('teamSelect').style.display    = type === 'team'     ? 'block' : 'none';
}

/* ── ✅ Participants via JSON — no page navigation ── */
function viewParticipants(meetingId) {
    var list = document.getElementById('participantsList');

    // Show spinner immediately
    list.innerHTML =
        '<div style="text-align:center;padding:32px;">' +
        '<i class="fa-solid fa-spinner fa-spin" style="color:var(--accent);font-size:28px;"></i>' +
        '<p style="margin-top:12px;font-size:13px;color:var(--text3);">Loading participants…</p>' +
        '</div>';

    // Open modal straight away so spinner is visible
    document.getElementById('participantsModal').classList.add('show');

    // ✅ Calls action=participants → servlet returns clean JSON
    fetch('adminMeetings?action=participants&id=' + meetingId)
        .then(function(res) {
            if (!res.ok) throw new Error('Network error');
            return res.json();
        })
        .then(function(data) {
            if (!data || data.length === 0) {
                list.innerHTML =
                    '<div style="text-align:center;padding:32px;color:var(--text3);">' +
                    '<i class="fa-solid fa-user-slash" style="font-size:36px;opacity:.3;display:block;margin-bottom:12px;"></i>' +
                    '<p style="font-size:14px;font-weight:500;">No participants for this meeting.</p>' +
                    '</div>';
                return;
            }
            var html = '<div class="participants-list">';
            data.forEach(function(p) {
                html +=
                    '<div class="participant-chip">' +
                    '<i class="fa-solid fa-user"></i>' +
                    '<span>' + p.name + '</span>' +
                    '<span class="role">(' + p.role + ')</span>' +
                    '</div>';
            });
            html += '</div>';
            list.innerHTML = html;
        })
        .catch(function() {
            list.innerHTML =
                '<p style="text-align:center;color:var(--danger);padding:24px;font-size:14px;">' +
                '<i class="fa-solid fa-triangle-exclamation" style="margin-right:6px;"></i>' +
                'Error loading participants. Please try again.</p>';
        });
}

/* showToast: js/smart-office-toast.js */

document.addEventListener('DOMContentLoaded', function() {
    var toast = document.getElementById('toast');
    var s = toast.getAttribute('data-success');
    var e = toast.getAttribute('data-error');
    if (s) showToast(s, 'success');
    if (e) showToast(e, 'error');

    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(a) { a.style.display = 'none'; });
    }, 5000);

    var sd = document.getElementById('meetingStartDate');
    var st = document.getElementById('meetingStartTimeOnly');
    var ed = document.getElementById('meetingEndDate');
    var et = document.getElementById('meetingEndTimeOnly');
    if (sd && st && ed && et) {
        function bindRefresh(el) {
            el.addEventListener('input', refreshMeetingDatetimeConstraints);
            el.addEventListener('change', refreshMeetingDatetimeConstraints);
            el.addEventListener('focus', refreshMeetingDatetimeConstraints);
        }
        bindRefresh(sd);
        bindRefresh(st);
        bindRefresh(ed);
        bindRefresh(et);

        var form = document.querySelector('#createModal form');
        if (form) {
            form.addEventListener('submit', function(ev) {
                composeMeetingHiddenFields();
                refreshMeetingDatetimeConstraints();
                var now = new Date();
                var sv = meetingGetStartDateTime();
                var evd = meetingGetEndDateTime();
                if (!sv || !evd) return;
                if (!meetingSameOrAfterMinute(sv, now)) {
                    ev.preventDefault();
                    showToast('Start time must be at or after the current date and time.', 'error');
                    return;
                }
                if (!meetingAfterMinute(evd, sv)) {
                    ev.preventDefault();
                    showToast('End time must be after start time.', 'error');
                    return;
                }
            });
        }
    }
});
</script>

</body>
</html>
