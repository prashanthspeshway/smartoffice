<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}

int openTasks = request.getAttribute("openTasks") != null ? (Integer) request.getAttribute("openTasks") : 0;
int overdueTasks = request.getAttribute("overdueTasks") != null ? (Integer) request.getAttribute("overdueTasks") : 0;
int pendingLeaves = request.getAttribute("pendingLeaves") != null ? (Integer) request.getAttribute("pendingLeaves") : 0;
int upcomingMeetingsCount = request.getAttribute("upcomingMeetingsCount") != null ? (Integer) request.getAttribute("upcomingMeetingsCount") : 0;

Integer taskAssigned = (Integer) request.getAttribute("taskAssigned");
Integer taskCompleted = (Integer) request.getAttribute("taskCompleted");
Integer taskSubmitted = (Integer) request.getAttribute("taskSubmitted");
Integer taskOverdue = (Integer) request.getAttribute("taskOverdue");
int vTA = taskAssigned != null ? taskAssigned : 0;
int vTC = taskCompleted != null ? taskCompleted : 0;
int vTS = taskSubmitted != null ? taskSubmitted : 0;
int vTO = taskOverdue != null ? taskOverdue : 0;

Integer leaveSick = (Integer) request.getAttribute("leaveSick");
Integer leaveAnnual = (Integer) request.getAttribute("leaveAnnual");
Integer leavePersonal = (Integer) request.getAttribute("leavePersonal");
Integer leaveMaternity = (Integer) request.getAttribute("leaveMaternity");
Integer leaveOther = (Integer) request.getAttribute("leaveOther");
int vLS = leaveSick != null ? leaveSick : 0;
int vLA = leaveAnnual != null ? leaveAnnual : 0;
int vLP = leavePersonal != null ? leavePersonal : 0;
int vLM = leaveMaternity != null ? leaveMaternity : 0;
int vLO = leaveOther != null ? leaveOther : 0;

Integer punchBefore8 = (Integer) request.getAttribute("punchBefore8");
Integer punch8to9 = (Integer) request.getAttribute("punch8to9");
Integer punch9to10 = (Integer) request.getAttribute("punch9to10");
Integer punch10to11 = (Integer) request.getAttribute("punch10to11");
Integer punchAfter11 = (Integer) request.getAttribute("punchAfter11");
int vP0 = punchBefore8 != null ? punchBefore8 : 0;
int vP1 = punch8to9 != null ? punch8to9 : 0;
int vP2 = punch9to10 != null ? punch9to10 : 0;
int vP3 = punch10to11 != null ? punch10to11 : 0;
int vP4 = punchAfter11 != null ? punchAfter11 : 0;

int attRate7d = request.getAttribute("attRate7d") != null ? (Integer) request.getAttribute("attRate7d") : 0;
int taskCompletionRate = request.getAttribute("taskCompletionRate") != null ? (Integer) request.getAttribute("taskCompletionRate") : 0;
int onTimePunchPct = request.getAttribute("onTimePunchPct") != null ? (Integer) request.getAttribute("onTimePunchPct") : 0;

String weekLabels = (String) request.getAttribute("weekLabels");
String weekPresentData = (String) request.getAttribute("weekPresentData");
String weekAbsentData = (String) request.getAttribute("weekAbsentData");
if (weekLabels == null) weekLabels = "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'";
if (weekPresentData == null) weekPresentData = "0,0,0,0,0,0,0";
if (weekAbsentData == null) weekAbsentData = "0,0,0,0,0,0,0";

String todayStatus = request.getAttribute("todayStatus") != null ? (String) request.getAttribute("todayStatus") : "—";
java.sql.Timestamp pi = (java.sql.Timestamp) request.getAttribute("punchIn");
java.sql.Timestamp po = (java.sql.Timestamp) request.getAttribute("punchOut");

@SuppressWarnings("unchecked")
List<Map<String, String>> recentActivities = (List<Map<String, String>>) request.getAttribute("recentActivities");

String todayStr = new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date());
String displayName = session.getAttribute("fullName") != null ? (String) session.getAttribute("fullName") : username;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Overview • Employee</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
:root {
  --bg:#f0f2f8; --surface:#fff; --surface2:#f7f8fc; --border:#e4e8f0;
  --text:#1a1d2e; --text2:#5a6278; --text3:#9aa0b8;
  --blue:#4f6ef7; --green:#22c55e; --violet:#8b5cf6; --amber:#f59e0b; --red:#ef4444;
  --shadow:0 4px 16px rgba(0,0,0,.07); --shadow-sm:0 1px 3px rgba(0,0,0,.06);
  --r:16px; --r2:10px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'DM Sans',system-ui,sans-serif;background:var(--bg);color:var(--text);min-height:100vh}
.pg{max-width:1200px;margin:0 auto;padding:28px 20px}

/* Hero — welcome only (no Teams / Upcoming / Unread) */
.hero{background:linear-gradient(135deg,#4f6ef7 0%,#6366f1 50%,#8b5cf6 100%);border-radius:20px;padding:26px 30px;color:#fff;margin-bottom:18px;position:relative;overflow:hidden;box-shadow:0 8px 32px rgba(79,110,247,.28)}
.hero::before{content:'';position:absolute;top:-50px;right:-40px;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,.08);pointer-events:none}
/* Main title only — same role as adminOverview .page-title */
.hero h1{font-family:'Fraunces',Georgia,serif;font-size:26px;font-weight:600;margin-bottom:6px;position:relative;z-index:1;line-height:1.25}
.hero .sub{opacity:.92;font-size:.95rem;position:relative;z-index:1}
.hero .date{font-size:.8rem;opacity:.85;margin-top:10px;display:flex;align-items:center;gap:8px;position:relative;z-index:1}
.hero .date i{opacity:.7}

.krow{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:14px;margin-bottom:22px}
.kpi{background:var(--surface);border:1px solid var(--border);border-radius:var(--r2);padding:16px 18px;box-shadow:var(--shadow-sm)}
.kpi .ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1rem;margin-bottom:10px}
.kpi .ico.bl{background:#eef2ff;color:var(--blue)}
.kpi .ico.am{background:#fffbeb;color:var(--amber)}
.kpi .ico.gr{background:#ecfdf5;color:var(--green)}
.kpi .ico.vi{background:#f5f3ff;color:var(--violet)}
.kpi .num{font-size:28px;font-weight:700;line-height:1;color:var(--text)}
.kpi .lbl{font-size:12px;color:var(--text3);font-weight:500;text-transform:uppercase;letter-spacing:.5px;margin-top:4px}

/* Insight strip — manager-style */
.irow{display:grid;grid-template-columns:repeat(3,1fr);gap:11px;margin-bottom:18px}
@media(max-width:800px){.irow{grid-template-columns:1fr}}
.ins{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:14px 17px;display:flex;align-items:center;gap:13px;box-shadow:var(--shadow-sm)}
.ins-ico{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0}
.ins-lbl{font-size:11px;color:var(--text3);font-weight:500;text-transform:uppercase;letter-spacing:.5px}
.ins-val{font-size:20px;font-weight:700;color:var(--text);line-height:1.1;margin:2px 0}
.ins-bar{height:4px;background:var(--border);border-radius:99px;overflow:hidden;margin-top:5px}
.ins-fill{height:100%;border-radius:99px;transition:width 1.4s cubic-bezier(.4,0,.2,1)}

.sec{font-family:'DM Sans',system-ui,sans-serif;font-size:15px;font-weight:600;color:var(--text);margin-bottom:11px;display:flex;align-items:center;gap:8px}
.sec::after{content:'';flex:1;height:1px;background:var(--border)}

.cr2{display:grid;grid-template-columns:1fr 1fr;gap:13px;margin-bottom:13px}
.crw{display:grid;grid-template-columns:3fr 2fr;gap:13px;margin-bottom:13px}
@media(max-width:900px){.cr2,.crw{grid-template-columns:1fr}}

.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:18px;box-shadow:var(--shadow-sm)}
.ch{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:13px}
.ct{font-size:14px;font-weight:700;color:var(--text);display:flex;align-items:center;gap:7px}
.ci{width:26px;height:26px;border-radius:8px;background:#eef1fe;color:var(--blue);display:flex;align-items:center;justify-content:center;font-size:11px}
.cs{font-size:11px;color:var(--text3);margin-top:2px}
.badge{font-size:11px;font-weight:600;padding:2px 8px;border-radius:99px;background:#eef1fe;color:var(--blue);border:1px solid #d4dcfc;white-space:nowrap}
.badge.gr{background:#f0fdf4;color:var(--green);border-color:#bbf7d0}
.cpills{display:flex;flex-wrap:wrap;gap:7px;margin-top:12px}
.cpill{display:flex;align-items:center;gap:5px;font-size:12px;font-weight:600;padding:4px 10px;border-radius:99px;background:var(--surface2);border:1px solid var(--border)}
.cpill-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}

.twocol{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px}
@media (max-width:900px){.twocol{grid-template-columns:1fr}}

/* Match adminOverview .chart-title */
.card h2{font-family:'DM Sans',system-ui,sans-serif;font-size:14px;font-weight:700;margin-bottom:14px;display:flex;align-items:center;gap:10px;color:var(--text)}
.card h2 i{color:var(--violet);font-size:13px}

.status-pill{display:inline-flex;align-items:center;gap:8px;padding:8px 14px;background:var(--surface2);border-radius:99px;font-size:.9rem;font-weight:600;color:var(--text2);margin-bottom:12px}
.status-pill i{color:var(--violet)}
.punch-line{font-size:.85rem;color:var(--text2);margin-top:6px}
.punch-line strong{color:var(--text)}

.act{list-style:none}
.act li{display:flex;gap:12px;padding:12px 0;border-bottom:1px solid var(--border);align-items:flex-start}
.act li:last-child{border-bottom:0}
.act .dot{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.9rem}
.act .dot.task{background:#eef2ff;color:var(--blue)}
.act .dot.leave{background:#fff7ed;color:var(--amber)}
.act .t{font-size:.88rem;font-weight:600;color:var(--text)}
.act .d{font-size:.78rem;color:var(--text3);margin-top:2px}
.act .w{font-size:.72rem;color:var(--text3);margin-top:4px}

.empty{text-align:center;padding:28px;color:var(--text3);font-size:.88rem}
.empty i{font-size:1.6rem;display:block;margin-bottom:8px;opacity:.4}
</style>
</head>
<body>
<div class="pg">

  <div class="hero">
    <h1>Welcome back, <%= displayName %>!</h1>
    <p class="sub">Your work snapshot — attendance, tasks, and what needs attention.</p>
    <div class="date"><i class="fa-regular fa-calendar"></i> <%= todayStr %></div>
  </div>

  <div class="krow">
    <div class="kpi">
      <div class="ico bl"><i class="fa-solid fa-briefcase"></i></div>
      <div class="num"><%= openTasks %></div>
      <div class="lbl">Open tasks</div>
    </div>
    <div class="kpi">
      <div class="ico am"><i class="fa-solid fa-clock-rotate-left"></i></div>
      <div class="num"><%= overdueTasks %></div>
      <div class="lbl">Overdue</div>
    </div>
    <div class="kpi">
      <div class="ico gr"><i class="fa-solid fa-calendar-check"></i></div>
      <div class="num"><%= pendingLeaves %></div>
      <div class="lbl">Leave pending</div>
    </div>
    <div class="kpi">
      <div class="ico vi"><i class="fa-solid fa-handshake"></i></div>
      <div class="num"><%= upcomingMeetingsCount %></div>
      <div class="lbl">Meetings</div>
    </div>
  </div>

  <div class="irow">
    <div class="ins">
      <div class="ins-ico" style="background:#f0fdf4;color:var(--green)"><i class="fa-solid fa-calendar-week"></i></div>
      <div style="flex:1">
        <div class="ins-lbl">7-day attendance</div>
        <div class="ins-val" style="color:var(--green)"><%= attRate7d %>%</div>
        <div class="ins-bar"><div class="ins-fill" style="width:<%=attRate7d%>%;background:var(--green)"></div></div>
        <div style="font-size:10px;color:var(--text3);margin-top:4px">Present vs absent (last 7 days)</div>
      </div>
    </div>
    <div class="ins">
      <div class="ins-ico" style="background:#eef1fe;color:var(--blue)"><i class="fa-solid fa-circle-check"></i></div>
      <div style="flex:1">
        <div class="ins-lbl">Tasks completed</div>
        <div class="ins-val" style="color:var(--blue)"><%= taskCompletionRate %>%</div>
        <div class="ins-bar"><div class="ins-fill" style="width:<%=taskCompletionRate%>%;background:var(--blue)"></div></div>
        <div style="font-size:11px;color:var(--text3);margin-top:4px">Share of your tasks marked done</div>
      </div>
    </div>
    <div class="ins">
      <div class="ins-ico" style="background:#fffbeb;color:var(--amber)"><i class="fa-solid fa-sun"></i></div>
      <div style="flex:1">
        <div class="ins-lbl">On-time punch (week)</div>
        <div class="ins-val" style="color:var(--amber)"><%= onTimePunchPct %>%</div>
        <div class="ins-bar"><div class="ins-fill" style="width:<%=onTimePunchPct%>%;background:var(--amber)"></div></div>
        <div style="font-size:11px;color:var(--text3);margin-top:4px">Before 9am vs all punch-ins this week</div>
      </div>
    </div>
  </div>

  <div class="sec">Analytics</div>

  <div class="cr2">
    <div class="card">
      <div class="ch">
        <div><div class="ct"><div class="ci"><i class="fa-solid fa-calendar-check"></i></div> Weekly attendance</div>
          <div class="cs">Present vs absent — last 7 days</div></div>
        <span class="badge">You</span>
      </div>
      <canvas id="weeklyAtt" height="190"></canvas>
      <div class="cpills">
        <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>Present days</span>
        <span class="cpill"><span class="cpill-dot" style="background:#fca5a5"></span>Absent</span>
      </div>
    </div>
    <div class="card">
      <div class="ch">
        <div><div class="ct"><div class="ci"><i class="fa-solid fa-chart-pie"></i></div> Task status</div>
          <div class="cs">Assigned · Completed · Submitted · Overdue</div></div>
      </div>
      <canvas id="taskPie" height="190"></canvas>
      <div class="cpills">
        <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>Assigned: <%=vTA%></span>
        <span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Done: <%=vTC%></span>
        <span class="cpill"><span class="cpill-dot" style="background:#f59e0b"></span>Submitted: <%=vTS%></span>
        <% if (vTO > 0) { %><span class="cpill"><span class="cpill-dot" style="background:#ef4444"></span>Overdue: <%=vTO%></span><% } %>
      </div>
    </div>
  </div>

  <div class="crw">
    <div class="card">
      <div class="ch">
        <div>
          <div class="ct"><div class="ci" style="background:#f0fdf4;color:var(--green)"><i class="fa-solid fa-clock"></i></div> Punch-in times</div>
          <div class="cs">When you start work — this week</div>
        </div>
        <span class="badge gr">This week</span>
      </div>
      <canvas id="punchBar" height="165"></canvas>
      <div class="cpills">
        <span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Early (&lt;8am): <%=vP0%></span>
        <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>8–9am: <%=vP1%></span>
      </div>
    </div>
    <div class="card">
      <div class="ch">
        <div>
          <div class="ct"><div class="ci" style="background:#fffbeb;color:var(--amber)"><i class="fa-solid fa-plane-departure"></i></div> Leave mix</div>
          <div class="cs">Your leave requests by type</div>
        </div>
      </div>
      <canvas id="leaveDonut" height="165"></canvas>
      <div class="cpills">
        <% if (vLS > 0) { %><span class="cpill"><span class="cpill-dot" style="background:#ef4444"></span>Sick: <%=vLS%></span><% } %>
        <% if (vLA > 0) { %><span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Annual: <%=vLA%></span><% } %>
        <% if (vLP > 0) { %><span class="cpill"><span class="cpill-dot" style="background:#f59e0b"></span>Personal: <%=vLP%></span><% } %>
      </div>
    </div>
  </div>

  <div class="twocol">
    <div class="card">
      <h2><i class="fa-solid fa-user-check"></i> Today</h2>
      <div class="status-pill"><i class="fa-solid fa-circle-dot"></i> <%= todayStatus %></div>
      <p class="punch-line">Punch in: <strong><%= pi != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(pi) : "—" %></strong></p>
      <p class="punch-line">Punch out: <strong><%= po != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(po) : "—" %></strong></p>
      <p class="punch-line" style="margin-top:14px;font-size:.8rem;">Use <strong>My Attendance</strong> in the sidebar to punch or manage breaks.</p>
    </div>
    <div class="card">
      <h2><i class="fa-solid fa-bolt"></i> Quick links</h2>
      <p class="punch-line" style="margin-bottom:8px;">Jump to common actions from the sidebar:</p>
      <p class="punch-line"><i class="fa-solid fa-list-check" style="color:var(--violet);width:18px;"></i> Tasks &amp; submissions</p>
      <p class="punch-line"><i class="fa-solid fa-calendar-xmark" style="color:var(--amber);width:18px;"></i> Apply or track leave</p>
      <p class="punch-line"><i class="fa-solid fa-calendar-days" style="color:var(--blue);width:18px;"></i> Company calendar</p>
    </div>
  </div>

  <div class="card" style="margin-top:16px;">
    <h2><i class="fa-solid fa-clock-rotate-left"></i> Recent activity</h2>
    <% if (recentActivities == null || recentActivities.isEmpty()) { %>
      <div class="empty"><i class="fa-regular fa-folder-open"></i>No recent tasks or leave activity yet.</div>
    <% } else { %>
      <ul class="act">
        <% for (Map<String, String> a : recentActivities) {
            String kind = a.get("kind");
            boolean isTask = "task".equals(kind);
        %>
        <li>
          <div class="dot <%= isTask ? "task" : "leave" %>"><i class="fa-solid <%= isTask ? "fa-list-check" : "fa-plane-departure" %>"></i></div>
          <div>
            <div class="t"><%= a.get("title") != null ? a.get("title") : "" %></div>
            <div class="d"><%= a.get("detail") != null ? a.get("detail") : "" %></div>
            <div class="w"><%= a.get("when") != null ? a.get("when") : "" %></div>
          </div>
        </li>
        <% } %>
      </ul>
    <% } %>
  </div>

</div>

<script>
Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
Chart.defaults.font.size = 12;
Chart.defaults.color = '#9aa0b8';
Chart.defaults.plugins.legend.labels.boxWidth = 10;
Chart.defaults.plugins.legend.labels.padding = 11;
Chart.defaults.scale.grid.color = '#f0f2f8';
Chart.defaults.scale.border.display = false;

new Chart(document.getElementById('weeklyAtt'), {
  type: 'bar',
  data: {
    labels: [<%= weekLabels %>],
    datasets: [
      { label: 'Present', data: [<%= weekPresentData %>], backgroundColor: '#4f6ef7', borderRadius: 5, borderSkipped: false },
      { label: 'Absent',  data: [<%= weekAbsentData %>],  backgroundColor: '#fca5a5', borderRadius: 5, borderSkipped: false }
    ]
  },
  options: {
    responsive: true,
    plugins: { legend: { position: 'top' } },
    scales: { x: { grid: { display: false } }, y: { ticks: { stepSize: 1 }, beginAtZero: true } }
  }
});

new Chart(document.getElementById('taskPie'), {
  type: 'pie',
  data: {
    labels: ['Assigned','Completed','Submitted','Overdue'],
    datasets: [{
      data: [<%= vTA %>, <%= vTC %>, <%= vTS %>, <%= vTO %>],
      backgroundColor: ['#4f6ef7','#22c55e','#f59e0b','#ef4444'],
      borderWidth: 2, borderColor: '#fff', hoverOffset: 6
    }]
  },
  options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
});

new Chart(document.getElementById('punchBar'), {
  type: 'bar',
  data: {
    labels: ['Before 8am','8–9am','9–10am','10–11am','After 11am'],
    datasets: [{
      label: 'Days',
      data: [<%= vP0 %>, <%= vP1 %>, <%= vP2 %>, <%= vP3 %>, <%= vP4 %>],
      backgroundColor: ['#22c55e','#4f6ef7','#f59e0b','#ef4444','#8b5cf6'],
      borderRadius: 6, borderSkipped: false
    }]
  },
  options: {
    responsive: true,
    plugins: { legend: { display: false } },
    scales: { x: { grid: { display: false } }, y: { ticks: { stepSize: 1 }, beginAtZero: true } }
  }
});

new Chart(document.getElementById('leaveDonut'), {
  type: 'doughnut',
  data: {
    labels: ['Sick','Annual','Personal','Maternity','Other'],
    datasets: [{
      data: [<%= vLS %>, <%= vLA %>, <%= vLP %>, <%= vLM %>, <%= vLO %>],
      backgroundColor: ['#ef4444','#22c55e','#f59e0b','#ec4899','#8b5cf6'],
      borderWidth: 2, borderColor: '#fff', hoverOffset: 6
    }]
  },
  options: { responsive: true, cutout: '58%', plugins: { legend: { position: 'bottom' } } }
});
</script>
</body>
</html>
