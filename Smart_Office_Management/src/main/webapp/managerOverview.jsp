<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.smartoffice.model.Team, com.smartoffice.model.Meeting, java.text.SimpleDateFormat"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }

Integer totalTeams    = (Integer) request.getAttribute("totalTeams");
Integer totalMembers  = (Integer) request.getAttribute("totalMembers");
Integer presentCount  = (Integer) request.getAttribute("presentCount");
Integer absentCount   = (Integer) request.getAttribute("absentCount");
Integer onBreakCount  = (Integer) request.getAttribute("onBreakCount");
Integer pendingTasks  = (Integer) request.getAttribute("pendingTasks");
Integer completedTasks= (Integer) request.getAttribute("completedTasks");
Integer overdueTasks  = (Integer) request.getAttribute("overdueTasks");
Integer pendingLeaves = (Integer) request.getAttribute("pendingLeaves");
Integer meetingCount  = (Integer) request.getAttribute("meetingCount");
Integer ratedEmployees= (Integer) request.getAttribute("ratedEmployees");
Integer pendingRatings= (Integer) request.getAttribute("pendingRatings");

List<Team> teams                          = (List<Team>) request.getAttribute("teams");
List<Meeting> todayMeetings               = (List<Meeting>) request.getAttribute("todayMeetings");
List<Map<String,String>> recentActivities = (List<Map<String,String>>) request.getAttribute("recentActivities");

// Analytics — weekly attendance
String weekLabels      = (String) request.getAttribute("weekLabels");
String weekPresentData = (String) request.getAttribute("weekPresentData");
String weekAbsentData  = (String) request.getAttribute("weekAbsentData");

// Analytics — task status (exact DB values: ASSIGNED / COMPLETED / SUBMITTED + computed OVERDUE)
Integer taskAssigned  = (Integer) request.getAttribute("taskAssigned");
Integer taskCompleted = (Integer) request.getAttribute("taskCompleted");
Integer taskSubmitted = (Integer) request.getAttribute("taskSubmitted");
Integer taskOverdue   = (Integer) request.getAttribute("taskOverdue");

// Analytics — leave types (keyword-bucketed)
Integer leaveSick      = (Integer) request.getAttribute("leaveSick");
Integer leaveAnnual    = (Integer) request.getAttribute("leaveAnnual");
Integer leavePersonal  = (Integer) request.getAttribute("leavePersonal");
Integer leaveMaternity = (Integer) request.getAttribute("leaveMaternity");
Integer leaveOther     = (Integer) request.getAttribute("leaveOther");

// Analytics — punch-in distribution
Integer punchBefore8 = (Integer) request.getAttribute("punchBefore8");
Integer punch8to9    = (Integer) request.getAttribute("punch8to9");
Integer punch9to10   = (Integer) request.getAttribute("punch9to10");
Integer punch10to11  = (Integer) request.getAttribute("punch10to11");
Integer punchAfter11 = (Integer) request.getAttribute("punchAfter11");

// Safe int conversions
int sP  = presentCount   != null ? presentCount   : 0;
int sA  = absentCount    != null ? absentCount     : 0;
int sB  = onBreakCount   != null ? onBreakCount    : 0;
int sPT = pendingTasks   != null ? pendingTasks    : 0;
int sCT = completedTasks != null ? completedTasks  : 0;
int sOT = overdueTasks   != null ? overdueTasks    : 0;
int sR  = ratedEmployees != null ? ratedEmployees  : 0;
int sPR = pendingRatings != null ? pendingRatings  : 0;
int sL  = pendingLeaves  != null ? pendingLeaves   : 0;
int sM  = meetingCount   != null ? meetingCount    : 0;
int sTM = totalMembers   != null ? totalMembers    : 0;
int sTC = totalTeams     != null ? totalTeams      : 0;

// Computed rates
int totalAtt = sP + sA + sB;
int attRate  = totalAtt > 0 ? (sP * 100 / totalAtt) : 0;
int totalT   = sPT + sCT;
int compRate = totalT > 0 ? (sCT * 100 / totalT) : 0;
int totalRev = sR + sPR;
int revRate  = totalRev > 0 ? (sR * 100 / totalRev) : 0;

// Chart data safe defaults
if (weekLabels      == null) weekLabels      = "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'";
if (weekPresentData == null) weekPresentData = "0,0,0,0,0,0,0";
if (weekAbsentData  == null) weekAbsentData  = "0,0,0,0,0,0,0";
int vTA = taskAssigned  != null ? taskAssigned  : 0;
int vTC = taskCompleted != null ? taskCompleted : 0;
int vTS = taskSubmitted != null ? taskSubmitted : 0;
int vTO = taskOverdue   != null ? taskOverdue   : 0;
int vLS = leaveSick     != null ? leaveSick     : 0;
int vLA = leaveAnnual   != null ? leaveAnnual   : 0;
int vLP = leavePersonal != null ? leavePersonal : 0;
int vLM = leaveMaternity!= null ? leaveMaternity: 0;
int vLO = leaveOther    != null ? leaveOther    : 0;
int vP0 = punchBefore8  != null ? punchBefore8  : 0;
int vP1 = punch8to9     != null ? punch8to9     : 0;
int vP2 = punch9to10    != null ? punch9to10    : 0;
int vP3 = punch10to11   != null ? punch10to11   : 0;
int vP4 = punchAfter11  != null ? punchAfter11  : 0;

String todayStr = new java.text.SimpleDateFormat("EEEE, MMMM d yyyy").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Manager Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
:root {
  --bg:#f0f2f8; --surface:#fff; --surface2:#f7f8fc; --border:#e4e8f0;
  --text:#1a1d2e; --text2:#5a6278; --text3:#9aa0b8;
  --blue:#4f6ef7; --green:#22c55e; --violet:#8b5cf6;
  --amber:#f59e0b; --red:#ef4444; --cyan:#06b6d4;
  --shadow-sm:0 1px 3px rgba(0,0,0,.06);
  --shadow:0 4px 16px rgba(0,0,0,.08);
  --r:16px; --r2:10px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Geist',system-ui,sans-serif;background:var(--bg);color:var(--text);min-height:100vh}
.pg{max-width:1200px;margin:0 auto;padding:32px 20px}

/* HERO */
.hero{background:linear-gradient(135deg,#4f6ef7 0%,#6366f1 50%,#8b5cf6 100%);border-radius:20px;padding:26px 30px;color:#fff;margin-bottom:18px;position:relative;overflow:hidden;display:flex;align-items:center;justify-content:space-between;gap:20px;box-shadow:0 8px 32px rgba(79,110,247,.28)}
.hero::before{content:'';position:absolute;top:-60px;right:-60px;width:250px;height:250px;border-radius:50%;background:rgba(255,255,255,.08);pointer-events:none}
.hero::after{content:'';position:absolute;bottom:-70px;right:140px;width:170px;height:170px;border-radius:50%;background:rgba(255,255,255,.05);pointer-events:none}
.hl{position:relative;z-index:1}
.h-eye{font-size:11px;font-weight:600;opacity:.7;letter-spacing:.07em;text-transform:uppercase;margin-bottom:5px}
.h-title{font-family:'Geist',system-ui,sans-serif;font-size:26px;font-weight:600;margin-bottom:5px;line-height:1.25}
.h-sub{font-size:13px;opacity:.72;display:flex;align-items:center;gap:6px}
.hdot{width:7px;height:7px;border-radius:50%;background:#4ade80;display:inline-block;box-shadow:0 0 6px #4ade80}
.hr{position:relative;z-index:1;display:flex;gap:9px;flex-shrink:0}
.hs{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.2);backdrop-filter:blur(8px);border-radius:12px;padding:11px 16px;text-align:center;min-width:72px}
.hs-n{font-size:22px;font-weight:700;color:#fff;line-height:1}
.hs-l{font-size:12px;font-weight:500;opacity:.72;margin-top:3px;text-transform:uppercase;letter-spacing:.04em}

/* KPI */
.krow{display:grid;grid-template-columns:repeat(5,1fr);gap:11px;margin-bottom:16px}
@media(max-width:1000px){.krow{grid-template-columns:repeat(3,1fr)}}
@media(max-width:600px){.krow{grid-template-columns:repeat(2,1fr)}}
.kpi{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:17px 15px;box-shadow:var(--shadow-sm);position:relative;overflow:hidden;transition:box-shadow .2s,transform .2s}
.kpi:hover{box-shadow:var(--shadow);transform:translateY(-2px)}
.kpi::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--r) var(--r) 0 0}
.kpi.bl::before{background:var(--blue)}.kpi.gr::before{background:var(--green)}
.kpi.am::before{background:var(--amber)}.kpi.vi::before{background:var(--violet)}.kpi.re::before{background:var(--red)}
.k-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:11px}
.k-ico{width:38px;height:38px;border-radius:var(--r2);display:flex;align-items:center;justify-content:center;font-size:16px}
.kpi.bl .k-ico{background:#eef1fe;color:var(--blue)}.kpi.gr .k-ico{background:#f0fdf4;color:var(--green)}
.kpi.am .k-ico{background:#fffbeb;color:var(--amber)}.kpi.vi .k-ico{background:#f5f3ff;color:var(--violet)}
.kpi.re .k-ico{background:#fef2f2;color:var(--red)}
.k-chip{font-size:11px;font-weight:700;padding:2px 8px;border-radius:99px}
.k-num{font-size:28px;font-weight:700;line-height:1;color:var(--text)}
.k-lbl{font-size:12px;color:var(--text3);font-weight:500;text-transform:uppercase;letter-spacing:.5px;margin-top:4px}
.k-sub{font-size:11px;color:var(--text3);margin-top:2px}

/* INSIGHT STRIP */
.irow{display:grid;grid-template-columns:repeat(3,1fr);gap:11px;margin-bottom:16px}
@media(max-width:700px){.irow{grid-template-columns:1fr 1fr}}
.ins{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:14px 17px;display:flex;align-items:center;gap:13px;box-shadow:var(--shadow-sm);transition:box-shadow .2s,transform .2s}
.ins:hover{box-shadow:var(--shadow);transform:translateY(-2px)}
.ins-ico{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0}
.ins-lbl{font-size:11px;color:var(--text3);font-weight:500;text-transform:uppercase;letter-spacing:.5px}
.ins-val{font-size:20px;font-weight:700;color:var(--text);line-height:1.1;margin:2px 0}
.ins-bar{height:4px;background:var(--border);border-radius:99px;overflow:hidden;margin-top:5px}
.ins-fill{height:100%;border-radius:99px;transition:width 1.4s cubic-bezier(.4,0,.2,1)}

/* SECTION */
.sec{font-family:'Geist',system-ui,sans-serif;font-size:15px;font-weight:600;color:var(--text);margin-bottom:11px;display:flex;align-items:center;gap:8px}
.sec::after{content:'';flex:1;height:1px;background:var(--border)}

/* CARD */
.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:18px;box-shadow:var(--shadow-sm);transition:box-shadow .2s}
.card:hover{box-shadow:var(--shadow)}
.ch{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:13px}
.ct{font-size:14px;font-weight:700;color:var(--text);display:flex;align-items:center;gap:7px}
.ci{width:26px;height:26px;border-radius:8px;background:#eef1fe;color:var(--blue);display:flex;align-items:center;justify-content:center;font-size:11px}
.cs{font-size:11px;color:var(--text3);margin-top:2px}
.badge{font-size:11px;font-weight:600;padding:2px 8px;border-radius:99px;background:#eef1fe;color:var(--blue);border:1px solid #d4dcfc;white-space:nowrap}
.badge.gr{background:#f0fdf4;color:var(--green);border-color:#bbf7d0}
.badge.am{background:#fffbeb;color:var(--amber);border-color:#fde68a}
.badge.re{background:#fef2f2;color:var(--red);border-color:#fecaca}

/* CHART GRIDS */
.cr2{display:grid;grid-template-columns:1fr 1fr;gap:13px;margin-bottom:13px}
.crw{display:grid;grid-template-columns:3fr 2fr;gap:13px;margin-bottom:13px}
@media(max-width:900px){.cr2,.crw{grid-template-columns:1fr}}

/* MAIN LAYOUT */
.mg{display:grid;grid-template-columns:1fr 340px;gap:13px}
@media(max-width:1000px){.mg{grid-template-columns:1fr}}
.col{display:flex;flex-direction:column;gap:13px}

/* MEETINGS */
.mi{display:flex;align-items:center;gap:11px;padding:12px 13px;background:var(--surface2);border:1px solid var(--border);border-radius:10px;margin-bottom:7px;transition:all .2s}
.mi:last-child{margin-bottom:0}.mi:hover{border-color:#c7d2fe;background:#f5f7ff}
.md{width:3px;height:36px;border-radius:99px;background:var(--blue);flex-shrink:0}
.mt{font-weight:700;font-size:14px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.mm{font-size:12px;color:var(--text2);margin-top:2px;display:flex;align-items:center;gap:7px}
.jb{padding:6px 12px;background:var(--blue);color:#fff;border-radius:8px;font-size:12px;font-weight:700;text-decoration:none;flex-shrink:0;transition:background .2s,transform .15s}
.jb:hover{background:#3d5fff;transform:scale(1.04)}

/* QUICK ACTIONS */
.qg{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}
.qa{display:flex;flex-direction:column;align-items:center;gap:6px;padding:13px 7px;background:var(--surface2);border:1px solid var(--border);border-radius:10px;cursor:pointer;transition:all .2s;font-family:inherit}
.qa:hover{border-color:#c7d2fe;background:#eef1fe;transform:translateY(-2px);box-shadow:var(--shadow-sm)}
.qi{width:38px;height:38px;border-radius:var(--r2);display:flex;align-items:center;justify-content:center;font-size:15px}
.ql{font-size:11px;font-weight:600;color:var(--text2);text-align:center;line-height:1.3}

/* TEAMS */
.tg{display:grid;grid-template-columns:1fr 1fr;gap:9px}
.tc{background:var(--surface2);border:1px solid var(--border);border-radius:10px;padding:13px;transition:all .2s}
.tc:hover{border-color:#c7d2fe;transform:translateY(-2px);box-shadow:var(--shadow-sm)}
.tt{display:flex;align-items:center;gap:8px;margin-bottom:7px}
.ta{width:34px;height:34px;border-radius:var(--r2);display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.tn{font-weight:700;font-size:13px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.tct{font-size:11px;color:var(--text3)}
.td{font-size:12px;color:var(--text2);margin-bottom:8px;line-height:1.4;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.tb{height:3px;background:var(--border);border-radius:99px;overflow:hidden}
.tf{height:100%;border-radius:99px;transition:width 1.2s ease}

/* ALERTS */
.al{display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-radius:9px;border:1px solid;text-decoration:none;margin-bottom:7px;transition:all .15s}
.al:last-child{margin-bottom:0}.al:hover{transform:translateX(3px);filter:brightness(.97)}
.ali{display:flex;align-items:center;gap:9px}
.alic{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.alt{font-size:13px;font-weight:700;color:var(--text)}.als{font-size:11px;color:var(--text3);margin-top:1px}
.alb{font-size:11px;font-weight:700;padding:2px 7px;border-radius:99px}

/* ACTIVITY */
.aci{display:flex;align-items:flex-start;gap:9px;padding:8px 0;border-bottom:1px solid var(--border)}
.aci:last-child{border-bottom:none}
.acd{width:30px;height:30px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0}
.act-t{font-size:12px;font-weight:700;color:var(--text)}.act-d{font-size:11px;color:var(--text2);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;margin-top:1px}.act-tm{font-size:11px;color:var(--text3);margin-top:1px}

/* PERF */
.perf{background:linear-gradient(135deg,#4f6ef7 0%,#6366f1 50%,#8b5cf6 100%);border-radius:var(--r);padding:18px;color:#fff;box-shadow:0 8px 24px rgba(79,110,247,.22)}
.pb-wrap{margin-bottom:10px}
.pb-lbl{display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px}
.pb-lbl span:first-child{opacity:.8}.pb-lbl span:last-child{font-weight:700}
.pb-trk{height:5px;background:rgba(255,255,255,.2);border-radius:99px;overflow:hidden}
.pb-fill{height:100%;border-radius:99px;transition:width 1.4s cubic-bezier(.4,0,.2,1)}
.sep{height:1px;background:rgba(255,255,255,.15);margin:12px 0}

/* DONUT LEGEND */
.leg{display:flex;justify-content:center;gap:12px;margin-top:9px;flex-wrap:wrap}
.leg span{font-size:11px;color:var(--text2);display:flex;align-items:center;gap:4px}
.ld{width:8px;height:8px;border-radius:50%;display:inline-block}

/* EMPTY */
.empty{text-align:center;padding:22px;color:var(--text3)}
.empty i{font-size:26px;color:var(--border);display:block;margin-bottom:7px}
.empty span{font-size:12px}

/* CHART STAT PILLS — shown below charts */
.cpills{display:flex;flex-wrap:wrap;gap:7px;margin-top:12px}
.cpill{display:flex;align-items:center;gap:5px;font-size:12px;font-weight:600;padding:4px 10px;border-radius:99px;background:var(--surface2);border:1px solid var(--border)}
.cpill-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}

@keyframes fu{from{opacity:0;transform:translateY(11px)}to{opacity:1;transform:translateY(0)}}
.a1{animation:fu .4s ease .04s both}.a2{animation:fu .4s ease .08s both}
.a3{animation:fu .4s ease .12s both}.a4{animation:fu .4s ease .16s both}
.a5{animation:fu .4s ease .20s both}.a6{animation:fu .4s ease .24s both}
</style>
</head>
<body>
<div class="pg">

<!-- HERO -->
<div class="hero a1">
  <div class="hl">
    <div class="h-eye">Manager Dashboard</div>
    <div class="h-title">Welcome back, ${sessionScope.fullName != null ? sessionScope.fullName : sessionScope.username}! 👋</div>
    <div class="h-sub"><span class="hdot"></span><%=todayStr%></div>
  </div>
  <div class="hr">
    <div class="hs"><div class="hs-n"><%=sTC%></div><div class="hs-l">Teams</div></div>
    <div class="hs"><div class="hs-n"><%=sTM%></div><div class="hs-l">Members</div></div>
    <div class="hs"><div class="hs-n"><%=attRate%>%</div><div class="hs-l">Attendance</div></div>
  </div>
</div>

<!-- KPI STRIP -->
<div class="krow a2">
  <div class="kpi bl">
    <div class="k-top"><div class="k-ico"><i class="fa-solid fa-user-check"></i></div>
      <span class="k-chip" style="background:#f0fdf4;color:var(--green)">Today</span></div>
    <div class="k-num"><%=sP%></div><div class="k-lbl">Present</div>
    <div class="k-sub"><%=sA%> absent · <%=sB%> on break</div>
  </div>
  <div class="kpi gr">
    <div class="k-top"><div class="k-ico"><i class="fa-solid fa-list-check"></i></div>
      <span class="k-chip" style="background:#fffbeb;color:var(--amber)">Active</span></div>
    <div class="k-num"><%=sPT%></div><div class="k-lbl">Pending Tasks</div>
    <div class="k-sub"><%=sCT%> completed</div>
  </div>
  <div class="kpi am">
    <div class="k-top"><div class="k-ico"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <%if(sOT>0){%><span class="k-chip" style="background:#fef2f2;color:var(--red)">Alert</span>
      <%}else{%><span class="k-chip" style="background:#f0fdf4;color:var(--green)">Clear</span><%}%></div>
    <div class="k-num" style="<%=sOT>0?"color:var(--red)":""%>"><%=sOT%></div>
    <div class="k-lbl">Overdue Tasks</div><div class="k-sub">Past deadline</div>
  </div>
  <div class="kpi vi">
    <div class="k-top"><div class="k-ico"><i class="fa-solid fa-video"></i></div>
      <span class="k-chip" style="background:#f5f3ff;color:var(--violet)">Today</span></div>
    <div class="k-num"><%=sM%></div><div class="k-lbl">Meetings</div>
    <div class="k-sub">Scheduled today</div>
  </div>
  <div class="kpi re">
    <div class="k-top"><div class="k-ico"><i class="fa-solid fa-calendar-xmark"></i></div>
      <%if(sL>0){%><span class="k-chip" style="background:#fef2f2;color:var(--red)">Pending</span>
      <%}else{%><span class="k-chip" style="background:#f0fdf4;color:var(--green)">Clear</span><%}%></div>
    <div class="k-num" style="<%=sL>0?"color:var(--red)":""%>"><%=sL%></div>
    <div class="k-lbl">Leave Requests</div><div class="k-sub">Awaiting approval</div>
  </div>
</div>

<!-- INSIGHT STRIP -->
<div class="irow a3">
  <div class="ins">
    <div class="ins-ico" style="background:#f0fdf4;color:var(--green)"><i class="fa-solid fa-arrow-trend-up"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Attendance Rate</div>
      <div class="ins-val" style="color:var(--green)"><%=attRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=attRate%>%;background:var(--green)"></div></div>
      <div style="font-size:10px;color:var(--text3);margin-top:4px"><%=sP%> present out of <%=totalAtt%></div>
    </div>
  </div>
  <div class="ins">
    <div class="ins-ico" style="background:#eef1fe;color:var(--blue)"><i class="fa-solid fa-circle-check"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Task Completion</div>
      <div class="ins-val" style="color:var(--blue)"><%=compRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=compRate%>%;background:var(--blue)"></div></div>
      <div style="font-size:11px;color:var(--text3);margin-top:4px"><%=sCT%> completed of <%=totalT%> total</div>
    </div>
  </div>
  <div class="ins">
    <div class="ins-ico" style="background:#f5f3ff;color:var(--violet)"><i class="fa-solid fa-star"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Reviews Done</div>
      <div class="ins-val" style="color:var(--violet)"><%=revRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=revRate%>%;background:var(--violet)"></div></div>
      <div style="font-size:11px;color:var(--text3);margin-top:4px"><%=sR%> rated · <%=sPR%> pending</div>
    </div>
  </div>
</div>

<!-- ANALYTICS -->
<div class="sec a4">Analytics</div>

<!-- Row 1: Weekly Attendance + Task Status -->
<div class="cr2 a4">
  <div class="card">
    <div class="ch">
      <div><div class="ct"><div class="ci"><i class="fa-solid fa-calendar-check"></i></div> Weekly Attendance</div>
        <div class="cs">Present vs Absent — last 7 days</div></div>
      <span class="badge">This Week</span>
    </div>
    <canvas id="weeklyAtt" height="190"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>Present: <%=sP%> today</span>
      <span class="cpill"><span class="cpill-dot" style="background:#fca5a5"></span>Absent: <%=sA%> today</span>
    </div>
  </div>
  <div class="card">
    <div class="ch">
      <div><div class="ct"><div class="ci"><i class="fa-solid fa-chart-pie"></i></div> Task Status</div>
        <div class="cs">Breakdown — Assigned · Completed · Submitted · Overdue</div></div>
    </div>
    <canvas id="taskPie" height="190"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>Assigned: <%=vTA%></span>
      <span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Done: <%=vTC%></span>
      <span class="cpill"><span class="cpill-dot" style="background:#f59e0b"></span>Submitted: <%=vTS%></span>
      <%if(vTO>0){%><span class="cpill"><span class="cpill-dot" style="background:#ef4444"></span>Overdue: <%=vTO%></span><%}%>
    </div>
  </div>
</div>

<!-- Row 2: Punch-In Distribution + Leave Types -->
<div class="crw a5">
  <div class="card">
    <div class="ch">
      <div><div class="ct"><div class="ci" style="background:#f0fdf4;color:var(--green)"><i class="fa-solid fa-clock"></i></div> Punch-In Distribution</div>
        <div class="cs">When your team arrives — this week</div></div>
      <span class="badge gr">This Week</span>
    </div>
    <canvas id="punchBar" height="165"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Early (&lt;8am): <%=vP0%></span>
      <span class="cpill"><span class="cpill-dot" style="background:#4f6ef7"></span>On time (8–9am): <%=vP1%></span>
      <span class="cpill"><span class="cpill-dot" style="background:#ef4444"></span>Late (&gt;10am): <%=vP3+vP4%></span>
    </div>
  </div>
  <div class="card">
    <div class="ch">
      <div><div class="ct"><div class="ci" style="background:#fffbeb;color:var(--amber)"><i class="fa-solid fa-plane-departure"></i></div> Leave Breakdown</div>
        <div class="cs">By leave type — all team members</div></div>
    </div>
    <canvas id="leaveDonut" height="165"></canvas>
    <div class="cpills">
      <%if(vLS>0){%><span class="cpill"><span class="cpill-dot" style="background:#ef4444"></span>Sick: <%=vLS%></span><%}%>
      <%if(vLA>0){%><span class="cpill"><span class="cpill-dot" style="background:#22c55e"></span>Annual: <%=vLA%></span><%}%>
      <%if(vLP>0){%><span class="cpill"><span class="cpill-dot" style="background:#f59e0b"></span>Personal: <%=vLP%></span><%}%>
    </div>
  </div>
</div>

<!-- OPERATIONS -->
<div class="sec a6">Operations</div>
<div class="mg a6">

  <!-- LEFT -->
  <div class="col">

    <!-- Meetings -->
    <div class="card">
      <div class="ch">
        <div class="ct"><div class="ci" style="background:#ecfeff;color:var(--cyan)"><i class="fa-solid fa-calendar-day"></i></div> Today's Meetings</div>
        <a href="#" onclick="parent.loadPage(null,'managerMeetings');return false;" style="font-size:12px;font-weight:700;color:var(--blue);text-decoration:none">View All →</a>
      </div>
      <%
      if(todayMeetings!=null&&!todayMeetings.isEmpty()){
        SimpleDateFormat tf=new SimpleDateFormat("h:mm a");
        for(Meeting m:todayMeetings){
      %><div class="mi">
        <div class="md"></div>
        <div style="flex:1;min-width:0">
          <div class="mt"><%=m.getTitle()%></div>
          <div class="mm">
            <span><i class="fa-solid fa-clock" style="opacity:.45;margin-right:3px;font-size:10px"></i><%=tf.format(m.getStartTime())%> – <%=tf.format(m.getEndTime())%></span>
            <%if(m.getDescription()!=null&&!m.getDescription().isEmpty()){%>
            <span style="color:var(--text3)">·</span>
            <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:160px;color:var(--text3)"><%=m.getDescription()%></span>
            <%}%>
          </div>
        </div>
        <%if(m.getMeetingLink()!=null&&!m.getMeetingLink().isEmpty()){%>
        <a href="<%=m.getMeetingLink()%>" target="_blank" class="jb"><i class="fa-solid fa-arrow-up-right-from-square" style="font-size:9px;margin-right:3px"></i>Join</a>
        <%}%>
      </div><%
        }}else{%>
      <div class="empty"><i class="fa-solid fa-calendar-xmark"></i><span>No meetings scheduled today</span></div>
      <%}%>
    </div>

    <!-- Quick Actions -->
    <div class="card">
      <div class="ct" style="margin-bottom:12px"><div class="ci" style="background:#fffbeb;color:var(--amber)"><i class="fa-solid fa-bolt"></i></div> Quick Actions</div>
      <div class="qg">
        <button class="qa" onclick="parent.loadPage(null,'managerTasks')">
          <div class="qi" style="background:#eef1fe;color:var(--blue)"><i class="fa-solid fa-plus"></i></div>
          <span class="ql">Assign Task</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerMeetings')">
          <div class="qi" style="background:#f5f3ff;color:var(--violet)"><i class="fa-solid fa-calendar-plus"></i></div>
          <span class="ql">Schedule Meeting</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerPerformance')">
          <div class="qi" style="background:#f0fdf4;color:var(--green)"><i class="fa-solid fa-star"></i></div>
          <span class="ql">Rate Performance</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerTeams')">
          <div class="qi" style="background:#ecfeff;color:var(--cyan)"><i class="fa-solid fa-users"></i></div>
          <span class="ql">Manage Teams</span>
        </button>
      </div>
    </div>

    <!-- My Teams -->
    <div class="card">
      <div class="ct" style="margin-bottom:12px"><div class="ci" style="background:#ecfeff;color:var(--cyan)"><i class="fa-solid fa-people-group"></i></div> My Teams</div>
      <div class="tg">
        <%
        String[] tC={"var(--blue)","var(--violet)","var(--green)","var(--amber)","var(--red)","var(--cyan)"};
        String[] tB={"#eef1fe","#f5f3ff","#f0fdf4","#fffbeb","#fef2f2","#ecfeff"};
        if(teams!=null&&!teams.isEmpty()){int ti=0;for(Team t:teams){String col=tC[ti%tC.length],bg=tB[ti%tB.length];ti++;int pct=sTM>0?(t.getMembers().size()*100/sTM):0;%>
        <div class="tc">
          <div class="tt">
            <div class="ta" style="background:<%=bg%>;color:<%=col%>"><i class="fa-solid fa-users"></i></div>
            <div style="flex:1;min-width:0"><div class="tn"><%=t.getName()%></div><div class="tct"><%=t.getMembers().size()%> members</div></div>
          </div>
          <div class="td"><%=t.getDescription()!=null?t.getDescription():"No description available"%></div>
          <div class="tb"><div class="tf" style="width:<%=pct%>%;background:<%=col%>"></div></div>
        </div>
        <%}}else{%>
        <div style="grid-column:span 2"><div class="empty"><i class="fa-solid fa-users-slash"></i><span>No teams assigned</span></div></div>
        <%}%>
      </div>
    </div>
  </div>

  <!-- RIGHT -->
  <div class="col">

    <!-- Live Attendance Donut -->
    <div class="card">
      <div class="ch">
        <div><div class="ct"><div class="ci"><i class="fa-solid fa-circle-half-stroke"></i></div> Live Attendance</div>
          <div class="cs">Team presence right now · <%=totalAtt%> total</div></div>
        <span class="badge gr">Today</span>
      </div>
      <canvas id="attDonut" height="155"></canvas>
      <div class="leg">
        <span><span class="ld" style="background:var(--green)"></span>Present (<%=sP%>)</span>
        <span><span class="ld" style="background:var(--red)"></span>Absent (<%=sA%>)</span>
        <span><span class="ld" style="background:var(--amber)"></span>Break (<%=sB%>)</span>
      </div>
      <div style="display:flex;justify-content:center;margin-top:10px;gap:8px;flex-wrap:wrap">
        <div style="text-align:center;padding:8px 14px;background:var(--surface2);border:1px solid var(--border);border-radius:8px;flex:1">
          <div style="font-size:16px;font-weight:700;color:var(--green)"><%=attRate%>%</div>
          <div style="font-size:12px;color:var(--text3)">Attendance Rate</div>
        </div>
        <div style="text-align:center;padding:8px 14px;background:var(--surface2);border:1px solid var(--border);border-radius:8px;flex:1">
          <div style="font-size:16px;font-weight:700;color:var(--red)"><%=sA>0?(sA*100/Math.max(totalAtt,1)):0%>%</div>
          <div style="font-size:12px;color:var(--text3)">Absent Rate</div>
        </div>
      </div>
    </div>

    <!-- Needs Attention -->
    <div class="card">
      <div class="ct" style="margin-bottom:11px"><div class="ci" style="background:#fef2f2;color:var(--red)"><i class="fa-solid fa-bell"></i></div> Needs Attention</div>
      <%if(sL>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerLeave');return false;" style="background:#fef2f2;border-color:#fecaca">
        <div class="ali"><div class="alic" style="background:#fecaca;color:var(--red)"><i class="fa-solid fa-calendar-xmark"></i></div>
          <div><div class="alt">Leave Requests</div><div class="als"><%=sL%> pending approval</div></div></div>
        <span class="alb" style="background:#fecaca;color:#991b1b"><%=sL%></span>
      </a><%}%>
      <%if(sOT>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerTasks');return false;" style="background:#fffbeb;border-color:#fde68a">
        <div class="ali"><div class="alic" style="background:#fde68a;color:var(--amber)"><i class="fa-solid fa-triangle-exclamation"></i></div>
          <div><div class="alt">Overdue Tasks</div><div class="als"><%=sOT%> past deadline</div></div></div>
        <span class="alb" style="background:#fde68a;color:#92400e"><%=sOT%></span>
      </a><%}%>
      <%if(sPR>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerPerformance');return false;" style="background:#f5f3ff;border-color:#ddd6fe">
        <div class="ali"><div class="alic" style="background:#ddd6fe;color:var(--violet)"><i class="fa-solid fa-star"></i></div>
          <div><div class="alt">Reviews Pending</div><div class="als"><%=sPR%> employees to rate</div></div></div>
        <span class="alb" style="background:#ddd6fe;color:#5b21b6"><%=sPR%></span>
      </a><%}%>
      <%if(sL==0&&sOT==0&&sPR==0){%>
      <div class="empty" style="padding:16px"><i class="fa-solid fa-circle-check" style="color:var(--green)"></i>
        <span style="color:var(--green);font-weight:700">All caught up!</span></div>
      <%}%>
    </div>

    <!-- Recent Activity -->
    <div class="card">
      <div class="ct" style="margin-bottom:11px"><div class="ci"><i class="fa-solid fa-clock-rotate-left"></i></div> Recent Activity</div>
      <%
      if(recentActivities!=null&&!recentActivities.isEmpty()){
        for(Map<String,String> act:recentActivities){
          String at=act.get("type"),ic="fa-circle",ac2="var(--text2)",ab2="#f1f5f9";
          if("Task Assigned".equals(at)){ic="fa-list-check";ac2="var(--amber)";ab2="#fef3c7";}
          else if("Leave Request".equals(at)){ic="fa-calendar-xmark";ac2="var(--red)";ab2="#fee2e2";}
          else if("Meeting Scheduled".equals(at)){ic="fa-video";ac2="var(--violet)";ab2="#f3e8ff";}
      %><div class="aci">
        <div class="acd" style="background:<%=ab2%>;color:<%=ac2%>"><i class="fa-solid <%=ic%>"></i></div>
        <div style="flex:1;min-width:0">
          <div class="act-t"><%=at%></div>
          <div class="act-d"><%=act.get("description")%></div>
          <div class="act-tm"><%=act.get("time")%></div>
        </div>
      </div><%
        }}else{%>
      <div class="empty" style="padding:14px"><i class="fa-solid fa-inbox"></i><span>No recent activity</span></div>
      <%}%>
    </div>

    <!-- Performance Card -->
    <div class="perf">
      <div style="font-size:14px;font-weight:700;display:flex;align-items:center;gap:7px;margin-bottom:12px">
        <i class="fa-solid fa-chart-line"></i> Performance Review
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Attendance Rate</span><span><%=attRate%>% (<%=sP%>/<%=totalAtt%>)</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=attRate%>%;background:rgba(255,255,255,.9)"></div></div>
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Task Completion</span><span><%=compRate%>% (<%=sCT%>/<%=totalT%>)</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=compRate%>%;background:rgba(255,255,255,.75)"></div></div>
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Reviews Done</span><span><%=revRate%>% (<%=sR%>/<%=totalRev%>)</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=revRate%>%;background:rgba(255,255,255,.6)"></div></div>
      </div>
      <div class="sep"></div>
      <div style="display:flex;align-items:center;justify-content:space-between">
        <div>
          <div style="font-size:10px;opacity:.7;text-transform:uppercase;letter-spacing:.05em">Rated this month</div>
          <div style="font-size:21px;font-weight:700;margin-top:2px"><%=sR%> <span style="font-size:12px;opacity:.55">/ <%=totalRev%></span></div>
        </div>
        <a href="#" onclick="parent.loadPage(null,'managerPerformance');return false;"
          style="padding:8px 15px;background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.28);color:#fff;border-radius:9px;font-size:13px;font-weight:600;text-decoration:none"
          onmouseover="this.style.background='rgba(255,255,255,.28)'" onmouseout="this.style.background='rgba(255,255,255,.18)'">Rate Now →</a>
      </div>
    </div>

  </div>
</div>
</div>

<script>
Chart.defaults.font.family = "'Geist', system-ui, sans-serif";
Chart.defaults.font.size   = 12;
Chart.defaults.color       = '#9aa0b8';
Chart.defaults.plugins.legend.labels.boxWidth  = 10;
Chart.defaults.plugins.legend.labels.padding   = 11;
Chart.defaults.plugins.legend.labels.color     = '#5a6278';
Chart.defaults.plugins.tooltip.backgroundColor = '#1a1d2e';
Chart.defaults.plugins.tooltip.titleColor      = '#f0f2ff';
Chart.defaults.plugins.tooltip.bodyColor       = '#9aa0b8';
Chart.defaults.plugins.tooltip.borderColor     = '#2e3347';
Chart.defaults.plugins.tooltip.borderWidth     = 1;
Chart.defaults.plugins.tooltip.padding         = 10;
Chart.defaults.plugins.tooltip.cornerRadius    = 8;
Chart.defaults.scale.grid.color                = '#f0f2f8';
Chart.defaults.scale.border.display            = false;
Chart.defaults.scale.ticks.color               = '#9aa0b8';

// ── 1. Weekly Attendance Bar ──────────────────────────────────────────
// Data from DB: attendance.status 'Present'/'Absent', joined via user_email→team_members
new Chart(document.getElementById('weeklyAtt'), {
  type: 'bar',
  data: {
    labels: [<%=weekLabels%>],
    datasets: [
      { label:'Present', data:[<%=weekPresentData%>], backgroundColor:'#4f6ef7', borderRadius:5, borderSkipped:false },
      { label:'Absent',  data:[<%=weekAbsentData%>],  backgroundColor:'#fca5a5', borderRadius:5, borderSkipped:false }
    ]
  },
  options: {
    responsive:true,
    plugins:{ legend:{ position:'top' } },
    scales:{ x:{ grid:{ display:false } }, y:{ ticks:{ stepSize:1 }, beginAtZero:true } }
  }
});

// ── 2. Task Status Pie ────────────────────────────────────────────────
// Data from DB: tasks.status exact values 'ASSIGNED'/'COMPLETED'/'SUBMITTED'
// Overdue = status != 'COMPLETED' AND deadline < CURDATE()
new Chart(document.getElementById('taskPie'), {
  type: 'pie',
  data: {
    labels: ['Assigned','Completed','Submitted','Overdue'],
    datasets:[{
      data: [<%=vTA%>, <%=vTC%>, <%=vTS%>, <%=vTO%>],
      backgroundColor: ['#4f6ef7','#22c55e','#f59e0b','#ef4444'],
      borderWidth: 2, borderColor: '#fff', hoverOffset: 6
    }]
  },
  options:{ responsive:true, plugins:{ legend:{ position:'bottom' } } }
});

// ── 3. Punch-In Distribution Bar ──────────────────────────────────────
// Data from DB: HOUR(attendance.punch_in) bucketed, current ISO week
new Chart(document.getElementById('punchBar'), {
  type: 'bar',
  data: {
    labels: ['Before 8am','8–9am','9–10am','10–11am','After 11am'],
    datasets:[{
      label:'Employees',
      data: [<%=vP0%>, <%=vP1%>, <%=vP2%>, <%=vP3%>, <%=vP4%>],
      backgroundColor: ['#22c55e','#4f6ef7','#f59e0b','#ef4444','#8b5cf6'],
      borderRadius: 6, borderSkipped: false
    }]
  },
  options:{
    responsive:true, plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false } }, y:{ ticks:{ stepSize:1 }, beginAtZero:true } }
  }
});

// ── 4. Leave Type Doughnut ────────────────────────────────────────────
// Data from DB: leave_requests.leave_type keyword-bucketed
new Chart(document.getElementById('leaveDonut'), {
  type: 'doughnut',
  data: {
    labels: ['Sick','Annual','Personal','Maternity','Other'],
    datasets:[{
      data: [<%=vLS%>, <%=vLA%>, <%=vLP%>, <%=vLM%>, <%=vLO%>],
      backgroundColor: ['#ef4444','#22c55e','#f59e0b','#ec4899','#8b5cf6'],
      borderWidth: 2, borderColor: '#fff', hoverOffset: 6
    }]
  },
  options:{ responsive:true, cutout:'58%', plugins:{ legend:{ position:'bottom' } } }
});

// ── 5. Attendance Donut — sidebar ──────────────────────────────────────
// Data from DB: attendance.status 'Present'/'Absent'/'On Break', today only
(function(){
  var tot = <%=sP%> + <%=sA%> + <%=sB%>;
  new Chart(document.getElementById('attDonut'), {
    type: 'doughnut',
    data:{
      labels:['Present','Absent','On Break'],
      datasets:[{
        data: tot > 0 ? [<%=sP%>, <%=sA%>, <%=sB%>] : [1,0,0],
        backgroundColor:['#22c55e','#ef4444','#f59e0b'],
        borderWidth:2, borderColor:'#fff', hoverOffset:5
      }]
    },
    options:{
      cutout:'70%', responsive:true,
      plugins:{ legend:{ display:false }, tooltip:{ callbacks:{ label: ctx => ' '+ctx.label+': '+ctx.raw } } }
    },
    plugins:[{
      id:'cx',
      beforeDraw(c){
        var {ctx, chartArea:{left,top,right,bottom}} = c;
        var cx=(left+right)/2, cy=(top+bottom)/2;
        ctx.save();
        ctx.textAlign='center'; ctx.textBaseline='middle';
        ctx.font = 'bold 20px Geist, sans-serif';
        ctx.fillStyle = '#1a1d2e';
        ctx.fillText(tot, cx, cy-7);
        ctx.font = '10px Geist, sans-serif';
        ctx.fillStyle = '#9aa0b8';
        ctx.fillText('Total', cx, cy+9);
        ctx.restore();
      }
    }]
  });
})();
</script>

<script>
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e => (e.keyCode===123||(e.ctrlKey&&e.shiftKey&&['I','J','C'].includes(e.key.toUpperCase())))?false:true;
</script>
</body>
</html>
