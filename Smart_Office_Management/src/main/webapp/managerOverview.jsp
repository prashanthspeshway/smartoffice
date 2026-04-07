<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.smartoffice.model.Team, com.smartoffice.model.Meeting, java.text.SimpleDateFormat"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }

// ── Scalars ──────────────────────────────────────────────────────────────
Integer totalTeams     = (Integer) request.getAttribute("totalTeams");
Integer totalMembers   = (Integer) request.getAttribute("totalMembers");
Integer presentCount   = (Integer) request.getAttribute("presentCount");
Integer absentCount    = (Integer) request.getAttribute("absentCount");
Integer onBreakCount   = (Integer) request.getAttribute("onBreakCount");
Integer pendingTasks   = (Integer) request.getAttribute("pendingTasks");
Integer completedTasks = (Integer) request.getAttribute("completedTasks");
Integer overdueTasks   = (Integer) request.getAttribute("overdueTasks");
Integer pendingLeaves  = (Integer) request.getAttribute("pendingLeaves");
Integer meetingCount   = (Integer) request.getAttribute("meetingCount");
Integer ratedEmployees = (Integer) request.getAttribute("ratedEmployees");
Integer pendingRatings = (Integer) request.getAttribute("pendingRatings");

// ── NEW scalars ───────────────────────────────────────────────────────────
Integer taskHighPriority   = (Integer) request.getAttribute("taskHighPriority");
Integer taskMediumPriority = (Integer) request.getAttribute("taskMediumPriority");
Integer taskLowPriority    = (Integer) request.getAttribute("taskLowPriority");
Integer leaveApproved      = (Integer) request.getAttribute("leaveApproved");
Integer leaveRejected      = (Integer) request.getAttribute("leaveRejected");
Integer leavePendingCount  = (Integer) request.getAttribute("leavePendingCount");
Integer perfExcellent      = (Integer) request.getAttribute("perfExcellent");
Integer perfGood           = (Integer) request.getAttribute("perfGood");
Integer perfAverage        = (Integer) request.getAttribute("perfAverage");
Integer perfPoor           = (Integer) request.getAttribute("perfPoor");
Integer avgAtt4Wks         = (Integer) request.getAttribute("avgAttendanceLast4Weeks");
Integer totalTasks         = (Integer) request.getAttribute("totalTasks");

// ── PATCH 1: taskProcessing scalar ───────────────────────────────────────
Integer taskProcessing = (Integer) request.getAttribute("taskProcessing");

// ── Lists ─────────────────────────────────────────────────────────────────
List<Team> teams                           = (List<Team>) request.getAttribute("teams");
List<Meeting> todayMeetings                = (List<Meeting>) request.getAttribute("todayMeetings");
List<Map<String,String>> recentActivities  = (List<Map<String,String>>) request.getAttribute("recentActivities");
List<Map<String,String>> topPerformers     = (List<Map<String,String>>) request.getAttribute("topPerformers");
List<Map<String,String>> overdueEmployees  = (List<Map<String,String>>) request.getAttribute("overdueEmployees");

// ── Chart strings ─────────────────────────────────────────────────────────
String weekLabels      = (String) request.getAttribute("weekLabels");
String weekPresentData = (String) request.getAttribute("weekPresentData");
String weekAbsentData  = (String) request.getAttribute("weekAbsentData");
String workHourLabels  = (String) request.getAttribute("workHourLabels");
String workHourData    = (String) request.getAttribute("workHourData");
String avgWorkHoursToday = (String) request.getAttribute("avgWorkHoursToday");
String leaveTrendLabels  = (String) request.getAttribute("leaveTrendLabels");
String leaveTrendData    = (String) request.getAttribute("leaveTrendData");
String taskTrendLabels   = (String) request.getAttribute("taskTrendLabels");
String taskTrendData     = (String) request.getAttribute("taskTrendData");

// ── Task status ───────────────────────────────────────────────────────────
Integer taskAssigned  = (Integer) request.getAttribute("taskAssigned");
Integer taskCompleted = (Integer) request.getAttribute("taskCompleted");
Integer taskSubmitted = (Integer) request.getAttribute("taskSubmitted");
Integer taskOverdue   = (Integer) request.getAttribute("taskOverdue");

// ── Leave types ───────────────────────────────────────────────────────────
Integer leaveSick      = (Integer) request.getAttribute("leaveSick");
Integer leaveAnnual    = (Integer) request.getAttribute("leaveAnnual");
Integer leavePersonal  = (Integer) request.getAttribute("leavePersonal");
Integer leaveMaternity = (Integer) request.getAttribute("leaveMaternity");
Integer leaveOther     = (Integer) request.getAttribute("leaveOther");

// ── Punch-in ─────────────────────────────────────────────────────────────
Integer punchBefore8 = (Integer) request.getAttribute("punchBefore8");
Integer punch8to9    = (Integer) request.getAttribute("punch8to9");
Integer punch9to10   = (Integer) request.getAttribute("punch9to10");
Integer punch10to11  = (Integer) request.getAttribute("punch10to11");
Integer punchAfter11 = (Integer) request.getAttribute("punchAfter11");

// ── Safe ints ─────────────────────────────────────────────────────────────
int sP   = presentCount   != null ? presentCount   : 0;
int sA   = absentCount    != null ? absentCount    : 0;
int sB   = onBreakCount   != null ? onBreakCount   : 0;
int sPT  = pendingTasks   != null ? pendingTasks   : 0;
int sCT  = completedTasks != null ? completedTasks : 0;
int sOT  = overdueTasks   != null ? overdueTasks   : 0;
int sR   = ratedEmployees != null ? ratedEmployees : 0;
int sPR  = pendingRatings != null ? pendingRatings : 0;
int sL   = pendingLeaves  != null ? pendingLeaves  : 0;
int sM   = meetingCount   != null ? meetingCount   : 0;
int sTM  = totalMembers   != null ? totalMembers   : 0;
int sTC  = totalTeams     != null ? totalTeams     : 0;
int vHP  = taskHighPriority   != null ? taskHighPriority   : 0;
int vMP  = taskMediumPriority != null ? taskMediumPriority : 0;
int vLP2 = taskLowPriority    != null ? taskLowPriority    : 0;
int vLAp = leaveApproved      != null ? leaveApproved      : 0;
int vLRj = leaveRejected      != null ? leaveRejected      : 0;
int vLPd = leavePendingCount  != null ? leavePendingCount  : 0;
int vPEx = perfExcellent      != null ? perfExcellent      : 0;
int vPGo = perfGood           != null ? perfGood           : 0;
int vPAv = perfAverage        != null ? perfAverage        : 0;
int vPPo = perfPoor           != null ? perfPoor           : 0;
int vAA4 = avgAtt4Wks         != null ? avgAtt4Wks         : 0;
int vTA  = taskAssigned  != null ? taskAssigned  : 0;
int vTC2 = taskCompleted != null ? taskCompleted : 0;
int vTS  = taskSubmitted != null ? taskSubmitted : 0;
int vTO  = taskOverdue   != null ? taskOverdue   : 0;
int vLS  = leaveSick     != null ? leaveSick     : 0;
int vLA  = leaveAnnual   != null ? leaveAnnual   : 0;
int vLPs = leavePersonal != null ? leavePersonal : 0;
int vLM  = leaveMaternity!= null ? leaveMaternity: 0;
int vLO  = leaveOther    != null ? leaveOther    : 0;
int vP0  = punchBefore8  != null ? punchBefore8  : 0;
int vP1  = punch8to9     != null ? punch8to9     : 0;
int vP2  = punch9to10    != null ? punch9to10    : 0;
int vP3  = punch10to11   != null ? punch10to11   : 0;
int vP4  = punchAfter11  != null ? punchAfter11  : 0;
int sTT = totalTasks != null ? totalTasks : 0;
// PATCH 1: safe int for taskProcessing
int vTProc = taskProcessing != null ? taskProcessing : 0;

// ── Computed rates ────────────────────────────────────────────────────────
int totalAtt  = sP + sA + sB;
int attRate   = totalAtt > 0 ? (sP * 100 / totalAtt) : 0;
int totalT    = sTT;
int compRate  = totalT > 0 ? (sCT * 100 / totalT) : 0;
int totalRev  = sR + sPR;
int revRate   = totalRev > 0 ? (sR * 100 / totalRev) : 0;
int absentRate = totalAtt > 0 ? (sA * 100 / totalAtt) : 0;
int totalLeaveReqs = vLAp + vLRj + vLPd;

// ── Chart defaults ────────────────────────────────────────────────────────
if (weekLabels      == null) weekLabels      = "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'";
if (weekPresentData == null) weekPresentData = "0,0,0,0,0,0,0";
if (weekAbsentData  == null) weekAbsentData  = "0,0,0,0,0,0,0";
if (workHourLabels  == null) workHourLabels  = "'Mon','Tue','Wed','Thu','Fri','Sat','Sun'";
if (workHourData    == null) workHourData    = "0,0,0,0,0,0,0";
if (avgWorkHoursToday == null) avgWorkHoursToday = "0";
if (leaveTrendLabels  == null) leaveTrendLabels = "''";
if (leaveTrendData    == null) leaveTrendData   = "0";
if (taskTrendLabels   == null) taskTrendLabels  = "'Wk 1','Wk 2','Wk 3','Wk 4'";
if (taskTrendData     == null) taskTrendData    = "0,0,0,0";

String todayStr = new java.text.SimpleDateFormat("EEEE, MMMM d yyyy").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Manager Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
:root {
  --bg:#f0f2f8;
  --surface:#ffffff;
  --surface2:#f6f7fb;
  --border:#e3e7f0;
  --text:#18192b;
  --text2:#505573;
  --text3:#9298b3;
  --blue:#4361ee;
  --blue-lt:#eef1fd;
  --green:#16a34a;
  --green-lt:#f0fdf4;
  --violet:#7c3aed;
  --violet-lt:#f5f3ff;
  --amber:#d97706;
  --amber-lt:#fffbeb;
  --red:#dc2626;
  --red-lt:#fef2f2;
  --cyan:#0891b2;
  --cyan-lt:#ecfeff;
  --pink:#db2777;
  --pink-lt:#fdf2f8;
  --shadow-sm:0 1px 3px rgba(0,0,0,.05),0 1px 2px rgba(0,0,0,.04);
  --shadow:0 4px 20px rgba(0,0,0,.08);
  --shadow-lg:0 8px 32px rgba(0,0,0,.11);
  --r:14px;
  --r2:9px;
  --r3:6px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{font-family:'DM Sans',system-ui,sans-serif;background:var(--bg);color:var(--text);min-height:100vh;font-size:14px}
a{text-decoration:none;color:inherit}

/* ── LAYOUT ── */
.pg{max-width:1240px;margin:0 auto;padding:28px 20px}

/* ── HERO ── */
.hero{
  background:linear-gradient(130deg,#1e2d8f 0%,#3b4dd4 42%,#6d4fc7 100%);
  border-radius:20px;padding:28px 32px;color:#fff;margin-bottom:16px;
  position:relative;overflow:hidden;display:flex;align-items:center;
  justify-content:space-between;gap:20px;box-shadow:0 12px 40px rgba(67,97,238,.32)
}
.hero::before{
  content:'';position:absolute;inset:0;
  background:url("data:image/svg+xml,%3Csvg width='400' height='200' xmlns='http://www.w3.org/2000/svg'%3E%3Ccircle cx='350' cy='40' r='130' fill='rgba(255,255,255,.05)'/%3E%3Ccircle cx='80' cy='170' r='80' fill='rgba(255,255,255,.04)'/%3E%3C/svg%3E") no-repeat right center;
  pointer-events:none
}
.hero-l{position:relative;z-index:1}
.hero-eyebrow{font-size:11px;font-weight:600;opacity:.65;letter-spacing:.1em;text-transform:uppercase;margin-bottom:5px}
.hero-title{font-size:27px;font-weight:700;line-height:1.2;margin-bottom:6px}
.hero-sub{font-size:13px;opacity:.7;display:flex;align-items:center;gap:7px}
.live-dot{width:7px;height:7px;border-radius:50%;background:#4ade80;box-shadow:0 0 7px #4ade80;animation:pulse-dot 2s ease-in-out infinite}
@keyframes pulse-dot{0%,100%{box-shadow:0 0 5px #4ade80}50%{box-shadow:0 0 12px #4ade80}}
.hero-r{position:relative;z-index:1;display:flex;gap:10px;flex-shrink:0}
.hero-stat{
  background:rgba(255,255,255,.13);border:1px solid rgba(255,255,255,.2);
  backdrop-filter:blur(10px);border-radius:13px;padding:12px 18px;text-align:center;min-width:76px
}
.hs-num{font-size:24px;font-weight:700;line-height:1}
.hs-lbl{font-size:11px;font-weight:500;opacity:.7;margin-top:3px;text-transform:uppercase;letter-spacing:.05em}

/* ── KPI STRIP ── */
.krow{display:grid;grid-template-columns:repeat(5,1fr);gap:11px;margin-bottom:14px}
@media(max-width:1050px){.krow{grid-template-columns:repeat(3,1fr)}}
@media(max-width:640px){.krow{grid-template-columns:repeat(2,1fr)}}
.kpi{
  background:var(--surface);border:1px solid var(--border);border-radius:var(--r);
  padding:17px 16px;box-shadow:var(--shadow-sm);position:relative;overflow:hidden;
  transition:transform .18s,box-shadow .18s
}
.kpi:hover{transform:translateY(-3px);box-shadow:var(--shadow)}
.kpi::after{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--r) var(--r) 0 0}
.kpi.k-blue::after{background:linear-gradient(90deg,#4361ee,#6d8ef7)}
.kpi.k-green::after{background:linear-gradient(90deg,#16a34a,#22c55e)}
.kpi.k-amber::after{background:linear-gradient(90deg,#d97706,#f59e0b)}
.kpi.k-violet::after{background:linear-gradient(90deg,#7c3aed,#a78bfa)}
.kpi.k-red::after{background:linear-gradient(90deg,#dc2626,#f87171)}
.k-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px}
.k-ico{width:38px;height:38px;border-radius:var(--r2);display:flex;align-items:center;justify-content:center;font-size:15px}
.kpi.k-blue .k-ico{background:var(--blue-lt);color:var(--blue)}
.kpi.k-green .k-ico{background:var(--green-lt);color:var(--green)}
.kpi.k-amber .k-ico{background:var(--amber-lt);color:var(--amber)}
.kpi.k-violet .k-ico{background:var(--violet-lt);color:var(--violet)}
.kpi.k-red .k-ico{background:var(--red-lt);color:var(--red)}
.k-chip{font-size:10px;font-weight:700;padding:2px 8px;border-radius:99px;white-space:nowrap}
.k-num{font-size:30px;font-weight:700;line-height:1;color:var(--text)}
.k-lbl{font-size:11px;color:var(--text3);font-weight:600;text-transform:uppercase;letter-spacing:.5px;margin-top:4px}
.k-sub{font-size:11px;color:var(--text3);margin-top:3px}

/* ── INSIGHT STRIP ── */
.irow{display:grid;grid-template-columns:repeat(3,1fr);gap:11px;margin-bottom:16px}
@media(max-width:720px){.irow{grid-template-columns:1fr 1fr}}
.ins{
  background:var(--surface);border:1px solid var(--border);border-radius:var(--r);
  padding:15px 18px;display:flex;align-items:center;gap:14px;box-shadow:var(--shadow-sm);
  transition:transform .18s,box-shadow .18s
}
.ins:hover{transform:translateY(-2px);box-shadow:var(--shadow)}
.ins-ico{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
.ins-lbl{font-size:11px;color:var(--text3);font-weight:600;text-transform:uppercase;letter-spacing:.5px}
.ins-val{font-size:22px;font-weight:700;line-height:1.1;margin:2px 0}
.ins-bar{height:4px;background:var(--border);border-radius:99px;overflow:hidden;margin-top:6px}
.ins-fill{height:100%;border-radius:99px;transition:width 1.5s cubic-bezier(.4,0,.2,1)}
.ins-note{font-size:10px;color:var(--text3);margin-top:4px}

/* ── SECTION HEADER ── */
.sec{
  font-size:13px;font-weight:700;color:var(--text2);margin-bottom:11px;
  display:flex;align-items:center;gap:8px;text-transform:uppercase;letter-spacing:.06em
}
.sec::after{content:'';flex:1;height:1px;background:var(--border)}
.sec-icon{width:24px;height:24px;border-radius:7px;background:var(--blue-lt);color:var(--blue);display:flex;align-items:center;justify-content:center;font-size:11px}

/* ── CARD ── */
.card{
  background:var(--surface);border:1px solid var(--border);border-radius:var(--r);
  padding:18px;box-shadow:var(--shadow-sm);transition:box-shadow .18s
}
.card:hover{box-shadow:var(--shadow)}
.ch{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:14px;gap:8px}
.ct{font-size:14px;font-weight:700;color:var(--text);display:flex;align-items:center;gap:7px}
.ci{width:27px;height:27px;border-radius:8px;background:var(--blue-lt);color:var(--blue);display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0}
.cs{font-size:11px;color:var(--text3);margin-top:2px}

/* ── BADGES ── */
.badge{font-size:11px;font-weight:700;padding:3px 9px;border-radius:99px;white-space:nowrap}
.badge-blue{background:var(--blue-lt);color:var(--blue);border:1px solid #c7d5fc}
.badge-green{background:var(--green-lt);color:var(--green);border:1px solid #bbf7d0}
.badge-amber{background:var(--amber-lt);color:var(--amber);border:1px solid #fde68a}
.badge-red{background:var(--red-lt);color:var(--red);border:1px solid #fecaca}
.badge-violet{background:var(--violet-lt);color:var(--violet);border:1px solid #ddd6fe}

/* ── CHART GRIDS ── */
.cr2{display:grid;grid-template-columns:1fr 1fr;gap:13px;margin-bottom:13px}
.cr3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:13px;margin-bottom:13px}
.crw{display:grid;grid-template-columns:3fr 2fr;gap:13px;margin-bottom:13px}
.crw2{display:grid;grid-template-columns:2fr 3fr;gap:13px;margin-bottom:13px}
@media(max-width:960px){.cr2,.crw,.crw2{grid-template-columns:1fr}.cr3{grid-template-columns:1fr 1fr}}
@media(max-width:640px){.cr3{grid-template-columns:1fr}}

/* ── CHART PILLS ── */
.cpills{display:flex;flex-wrap:wrap;gap:7px;margin-top:12px}
.cpill{display:flex;align-items:center;gap:5px;font-size:11px;font-weight:600;padding:4px 10px;border-radius:99px;background:var(--surface2);border:1px solid var(--border)}
.cpill-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}

/* ── MAIN 2-COL LAYOUT ── */
.mg{display:grid;grid-template-columns:1fr 340px;gap:13px}
@media(max-width:1050px){.mg{grid-template-columns:1fr}}
.col{display:flex;flex-direction:column;gap:13px}

/* ── MEETINGS ── */
.mi{display:flex;align-items:center;gap:12px;padding:12px 14px;background:var(--surface2);border:1px solid var(--border);border-radius:10px;margin-bottom:8px;transition:all .18s}
.mi:last-child{margin-bottom:0}.mi:hover{border-color:#c0ceff;background:#f2f5ff}
.md{width:3px;height:38px;border-radius:99px;background:var(--blue);flex-shrink:0}
.mt{font-weight:700;font-size:14px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.mm{font-size:12px;color:var(--text2);margin-top:2px;display:flex;align-items:center;gap:7px}
.jb{padding:7px 13px;background:var(--blue);color:#fff;border-radius:8px;font-size:12px;font-weight:700;transition:all .15s;white-space:nowrap}
.jb:hover{background:#2f4dd4;transform:scale(1.04)}

/* ── QUICK ACTIONS ── */
.qg{display:grid;grid-template-columns:repeat(4,1fr);gap:9px}
@media(max-width:500px){.qg{grid-template-columns:repeat(2,1fr)}}
.qa{display:flex;flex-direction:column;align-items:center;gap:7px;padding:14px 8px;background:var(--surface2);border:1px solid var(--border);border-radius:10px;cursor:pointer;font-family:inherit;transition:all .18s}
.qa:hover{border-color:#c0ceff;background:var(--blue-lt);transform:translateY(-2px);box-shadow:var(--shadow-sm)}
.qi{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px}
.ql{font-size:11px;font-weight:600;color:var(--text2);text-align:center;line-height:1.35}

/* ── TEAMS ── */
.tg{display:grid;grid-template-columns:1fr 1fr;gap:9px}
@media(max-width:500px){.tg{grid-template-columns:1fr}}
.tc{background:var(--surface2);border:1px solid var(--border);border-radius:10px;padding:14px;transition:all .18s}
.tc:hover{border-color:#c0ceff;transform:translateY(-2px);box-shadow:var(--shadow-sm)}
.tt{display:flex;align-items:center;gap:8px;margin-bottom:7px}
.ta{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.tn{font-weight:700;font-size:13px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.tct{font-size:11px;color:var(--text3)}
.tdesc{font-size:12px;color:var(--text2);margin-bottom:8px;line-height:1.45;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.tbar{height:3px;background:var(--border);border-radius:99px;overflow:hidden}
.tfill{height:100%;border-radius:99px;transition:width 1.3s ease}

/* ── ATTENTION ALERTS ── */
.al{display:flex;align-items:center;justify-content:space-between;padding:11px 13px;border-radius:10px;border:1px solid;margin-bottom:8px;transition:all .15s;cursor:pointer}
.al:last-child{margin-bottom:0}.al:hover{transform:translateX(3px)}
.ali{display:flex;align-items:center;gap:10px}
.alic{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0}
.alt{font-size:13px;font-weight:700;color:var(--text)}.als{font-size:11px;color:var(--text3);margin-top:1px}
.alb{font-size:11px;font-weight:700;padding:3px 8px;border-radius:99px}

/* ── ACTIVITY ── */
.aci{display:flex;align-items:flex-start;gap:10px;padding:9px 0;border-bottom:1px solid var(--border)}
.aci:last-child{border-bottom:none}
.acd{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.act-t{font-size:12px;font-weight:700;color:var(--text)}.act-d{font-size:11px;color:var(--text2);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;margin-top:1px}.act-tm{font-size:10px;color:var(--text3);margin-top:2px}

/* ── PERF CARD (gradient) ── */
.perf-card{background:linear-gradient(135deg,#1e2d8f 0%,#3b4dd4 50%,#6d4fc7 100%);border-radius:var(--r);padding:20px;color:#fff;box-shadow:0 8px 28px rgba(67,97,238,.25)}
.pb-wrap{margin-bottom:11px}
.pb-lbl{display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px}
.pb-lbl span:first-child{opacity:.75}.pb-lbl span:last-child{font-weight:700}
.pb-trk{height:5px;background:rgba(255,255,255,.18);border-radius:99px;overflow:hidden}
.pb-fill{height:100%;border-radius:99px;transition:width 1.5s cubic-bezier(.4,0,.2,1)}
.sep{height:1px;background:rgba(255,255,255,.15);margin:14px 0}

/* ── ATTENDANCE DONUT ── */
.leg{display:flex;justify-content:center;gap:14px;margin-top:10px;flex-wrap:wrap}
.leg span{font-size:11px;color:var(--text2);display:flex;align-items:center;gap:5px}
.ld{width:8px;height:8px;border-radius:50%;display:inline-block}
.att-stats{display:flex;gap:8px;margin-top:10px}
.att-stat{flex:1;text-align:center;padding:8px 10px;background:var(--surface2);border:1px solid var(--border);border-radius:9px}
.att-stat-num{font-size:17px;font-weight:700}
.att-stat-lbl{font-size:11px;color:var(--text3)}

/* ── TOP PERFORMERS TABLE ── */
.performer-row{display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--border)}
.performer-row:last-child{border-bottom:none}
.perf-rank{width:22px;height:22px;border-radius:50%;font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.perf-avatar{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;flex-shrink:0;color:#fff}
.perf-name{font-size:13px;font-weight:600;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.rating-pill{font-size:10px;font-weight:700;padding:2px 9px;border-radius:99px;white-space:nowrap}
.r-excellent{background:#fef9c3;color:#854d0e}
.r-good{background:var(--green-lt);color:var(--green)}
.r-average{background:var(--amber-lt);color:var(--amber)}
.r-poor{background:var(--red-lt);color:var(--red)}

/* ── OVERDUE TABLE ── */
.overdue-row{display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--border)}
.overdue-row:last-child{border-bottom:none}
.od-name{font-size:13px;font-weight:600;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.od-count{font-size:12px;font-weight:700;padding:2px 10px;border-radius:99px;background:var(--red-lt);color:var(--red);border:1px solid #fecaca;white-space:nowrap}

/* ── SUMMARY MINI STATS ── */
.mini-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:13px}
.mini-stat{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:12px;text-align:center;box-shadow:var(--shadow-sm)}
.mini-stat-num{font-size:22px;font-weight:700;line-height:1}
.mini-stat-lbl{font-size:11px;color:var(--text3);margin-top:3px}

/* ── PRIORITY INDICATOR BARS ── */
.pbar-row{display:flex;align-items:center;gap:10px;margin-bottom:8px}
.pbar-row:last-child{margin-bottom:0}
.pbar-lbl{font-size:12px;font-weight:600;width:70px;flex-shrink:0}
.pbar-track{flex:1;height:6px;background:var(--border);border-radius:99px;overflow:hidden}
.pbar-fill{height:100%;border-radius:99px;transition:width 1.3s ease}
.pbar-num{font-size:12px;font-weight:700;width:28px;text-align:right;flex-shrink:0}

/* ── 4-WEEK TREND MINI ── */
.trend-num{font-size:32px;font-weight:700;line-height:1}
.trend-sub{font-size:11px;color:var(--text3);margin-top:3px}

/* ── EMPTY ── */
.empty{text-align:center;padding:24px 16px;color:var(--text3)}
.empty i{font-size:28px;color:var(--border);display:block;margin-bottom:8px}
.empty span{font-size:12px;display:block}

/* ── ANIMATIONS ── */
@keyframes fadeUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
.a1{animation:fadeUp .4s ease .05s both}
.a2{animation:fadeUp .4s ease .10s both}
.a3{animation:fadeUp .4s ease .15s both}
.a4{animation:fadeUp .4s ease .20s both}
.a5{animation:fadeUp .4s ease .25s both}
.a6{animation:fadeUp .4s ease .30s both}
.a7{animation:fadeUp .4s ease .35s both}
</style>
</head>
<body>
<div class="pg">

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- HERO                                                            -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="hero a1">
  <div class="hero-l">
    <div class="hero-eyebrow">Manager Dashboard</div>
    <div class="hero-title">Welcome back, ${sessionScope.fullName != null ? sessionScope.fullName : sessionScope.username}!</div>
    <div class="hero-sub"><span class="live-dot"></span><%=todayStr%></div>
  </div>
  <div class="hero-r">
    <div class="hero-stat"><div class="hs-num"><%=sTC%></div><div class="hs-lbl">Teams</div></div>
    <div class="hero-stat"><div class="hs-num"><%=sTM%></div><div class="hs-lbl">Members</div></div>
    <div class="hero-stat"><div class="hs-num"><%=attRate%>%</div><div class="hs-lbl">Att. Rate</div></div>
    <div class="hero-stat"><div class="hs-num"><%=vAA4%>%</div><div class="hs-lbl">4-Wk Avg</div></div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- KPI STRIP                                                       -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="krow a2">
  <div class="kpi k-blue">
    <div class="k-top">
      <div class="k-ico"><i class="fa-solid fa-user-check"></i></div>
      <span class="k-chip" style="background:var(--green-lt);color:var(--green)">Today</span>
    </div>
    <div class="k-num"><%=sP%></div>
    <div class="k-lbl">Present</div>
    <div class="k-sub"><%=sA%> absent · <%=sB%> on break</div>
  </div>
  <div class="kpi k-green">
    <div class="k-top">
      <div class="k-ico"><i class="fa-solid fa-list-check"></i></div>
      <span class="k-chip" style="background:var(--amber-lt);color:var(--amber)">Active</span>
    </div>
    <div class="k-num"><%=sPT%></div>
    <div class="k-lbl">Pending Tasks</div>
    <!-- PATCH 2: updated sub-line to include Processing count -->
    <div class="k-sub"><%=sCT%> done · <%=vTProc%> in review · <%=vTO%> overdue</div>
  </div>
  <div class="kpi k-amber">
    <div class="k-top">
      <div class="k-ico"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <%if(sOT>0){%><span class="k-chip" style="background:var(--red-lt);color:var(--red)">Alert</span>
      <%}else{%><span class="k-chip" style="background:var(--green-lt);color:var(--green)">Clear</span><%}%>
    </div>
    <div class="k-num" style="<%=sOT>0?"color:var(--red)":""%>"><%=sOT%></div>
    <div class="k-lbl">Overdue Tasks</div>
    <div class="k-sub">Past deadline</div>
  </div>
  <div class="kpi k-violet">
    <div class="k-top">
      <div class="k-ico"><i class="fa-solid fa-video"></i></div>
      <span class="k-chip" style="background:var(--violet-lt);color:var(--violet)">Today</span>
    </div>
    <div class="k-num"><%=sM%></div>
    <div class="k-lbl">Meetings</div>
    <div class="k-sub">Scheduled today</div>
  </div>
  <div class="kpi k-red">
    <div class="k-top">
      <div class="k-ico"><i class="fa-solid fa-calendar-xmark"></i></div>
      <%if(sL>0){%><span class="k-chip" style="background:var(--red-lt);color:var(--red)">Pending</span>
      <%}else{%><span class="k-chip" style="background:var(--green-lt);color:var(--green)">Clear</span><%}%>
    </div>
    <div class="k-num" style="<%=sL>0?"color:var(--red)":""%>"><%=sL%></div>
    <div class="k-lbl">Leave Requests</div>
    <div class="k-sub">Awaiting approval</div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- INSIGHT STRIP (Progress bars)                                   -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="irow a3">
  <div class="ins">
    <div class="ins-ico" style="background:var(--green-lt);color:var(--green)"><i class="fa-solid fa-arrow-trend-up"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Today's Attendance</div>
      <div class="ins-val" style="color:var(--green)"><%=attRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=attRate%>%;background:var(--green)"></div></div>
      <div class="ins-note"><%=sP%> present of <%=totalAtt%> · 4-wk avg <%=vAA4%>%</div>
    </div>
  </div>
  <div class="ins">
    <div class="ins-ico" style="background:var(--blue-lt);color:var(--blue)"><i class="fa-solid fa-circle-check"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Task Completion</div>
      <div class="ins-val" style="color:var(--blue)"><%=compRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=compRate%>%;background:var(--blue)"></div></div>
      <div class="ins-note"><%=sCT%> done of <%=totalT%> total assigned</div>
    </div>
  </div>
  <div class="ins">
    <div class="ins-ico" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-star"></i></div>
    <div style="flex:1">
      <div class="ins-lbl">Performance Reviews</div>
      <div class="ins-val" style="color:var(--violet)"><%=revRate%>%</div>
      <div class="ins-bar"><div class="ins-fill" style="width:<%=revRate%>%;background:var(--violet)"></div></div>
      <div class="ins-note"><%=sR%> rated · <%=sPR%> still pending</div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- ANALYTICS — Section 1                                          -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="sec a4"><div class="sec-icon"><i class="fa-solid fa-chart-bar"></i></div>Attendance & Work Hours</div>

<div class="cr2 a4">
  <!-- Weekly Attendance -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci"><i class="fa-solid fa-calendar-check"></i></div> Weekly Attendance</div>
        <div class="cs">Present vs Absent — last 7 days</div>
      </div>
      <span class="badge badge-blue">This Week</span>
    </div>
    <canvas id="weeklyAtt" height="185"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--blue)"></span>Present: <%=sP%> today</span>
      <span class="cpill"><span class="cpill-dot" style="background:#fca5a5"></span>Absent: <%=sA%> today</span>
    </div>
  </div>

  <!-- Average Work Hours -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa-solid fa-hourglass-half"></i></div> Avg Work Hours</div>
        <div class="cs">Team average hours/day — last 7 days</div>
      </div>
      <span class="badge badge-green"><%=avgWorkHoursToday%>h today</span>
    </div>
    <canvas id="workHoursChart" height="185"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--cyan)"></span>Avg today: <%=avgWorkHoursToday%>h</span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--amber)"></span>Based on punch-in/out</span>
    </div>
  </div>
</div>

<!-- Punch-In Distribution -->
<div class="crw a5">
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--green-lt);color:var(--green)"><i class="fa-solid fa-clock"></i></div> Punch-In Distribution</div>
        <div class="cs">Arrival time buckets — this week</div>
      </div>
      <span class="badge badge-green">This Week</span>
    </div>
    <canvas id="punchBar" height="160"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Early (&lt;8am): <%=vP0%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--blue)"></span>On time (8–9am): <%=vP1%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--amber)"></span>9–10am: <%=vP2%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--red)"></span>Late (10am+): <%=vP3+vP4%></span>
    </div>
  </div>

  <!-- 4-week attendance trend stat -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--green-lt);color:var(--green)"><i class="fa-solid fa-calendar-week"></i></div> 4-Week Summary</div>
        <div class="cs">Attendance trend over last 28 days</div>
      </div>
    </div>
    <div style="margin-bottom:14px">
      <div class="trend-num" style="color:var(--green)"><%=vAA4%>%</div>
      <div class="trend-sub">Average attendance rate (last 4 weeks)</div>
    </div>
    <div style="margin-bottom:12px">
      <div class="pbar-row">
        <span class="pbar-lbl" style="color:var(--green)">Present</span>
        <div class="pbar-track"><div class="pbar-fill" style="width:<%=attRate%>%;background:var(--green)"></div></div>
        <span class="pbar-num"><%=sP%></span>
      </div>
      <div class="pbar-row">
        <span class="pbar-lbl" style="color:var(--red)">Absent</span>
        <div class="pbar-track"><div class="pbar-fill" style="width:<%=absentRate%>%;background:var(--red)"></div></div>
        <span class="pbar-num"><%=sA%></span>
      </div>
      <div class="pbar-row">
        <span class="pbar-lbl" style="color:var(--amber)">On Break</span>
        <div class="pbar-track"><div class="pbar-fill" style="width:<%=totalAtt>0?(sB*100/totalAtt):0%>%;background:var(--amber)"></div></div>
        <span class="pbar-num"><%=sB%></span>
      </div>
    </div>
    <div style="display:flex;gap:8px">
      <div class="att-stat" style="flex:1"><div class="att-stat-num" style="color:var(--green)"><%=attRate%>%</div><div class="att-stat-lbl">Present Rate</div></div>
      <div class="att-stat" style="flex:1"><div class="att-stat-num" style="color:var(--red)"><%=absentRate%>%</div><div class="att-stat-lbl">Absent Rate</div></div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- ANALYTICS — Section 2: Tasks                                   -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="sec a5"><div class="sec-icon" style="background:var(--amber-lt);color:var(--amber)"><i class="fa-solid fa-list-check"></i></div>Task Analytics</div>

<div class="cr3 a5">
  <!-- Task Status Pie -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--amber-lt);color:var(--amber)"><i class="fa-solid fa-chart-pie"></i></div> Task Status</div>
        <div class="cs">By current status</div>
      </div>
    </div>
    <canvas id="taskPie" height="175"></canvas>
    <!-- PATCH 4: updated cpills to include Processing -->
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--blue)"></span>Assigned: <%=vTA%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Completed: <%=vTC2%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--amber)"></span>Submitted: <%=vTS%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--cyan)"></span>Processing: <%=vTProc%></span>
      <%if(vTO>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--red)"></span>Overdue: <%=vTO%></span><%}%>
    </div>
  </div>

  <!-- Task Priority Breakdown -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--red-lt);color:var(--red)"><i class="fa-solid fa-fire"></i></div> Task Priority</div>
        <div class="cs">Distribution by priority level</div>
      </div>
    </div>
    <canvas id="priorityChart" height="175"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--red)"></span>High: <%=vHP%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--amber)"></span>Med: <%=vMP%></span>
      <span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Low: <%=vLP2%></span>
    </div>
  </div>

  <!-- Task Completion Trend -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--green-lt);color:var(--green)"><i class="fa-solid fa-chart-line"></i></div> Completion Trend</div>
        <div class="cs">Tasks completed — last 4 weeks</div>
      </div>
    </div>
    <canvas id="taskTrendChart" height="175"></canvas>
    <div class="cpills">
      <span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Total completed: <%=sCT%></span>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- ANALYTICS — Section 3: Leave                                   -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="sec a6"><div class="sec-icon" style="background:var(--red-lt);color:var(--red)"><i class="fa-solid fa-calendar-xmark"></i></div>Leave Analytics</div>

<div class="cr2 a6">
  <!-- Leave type donut + approval stats -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--amber-lt);color:var(--amber)"><i class="fa-solid fa-plane-departure"></i></div> Leave Breakdown</div>
        <div class="cs">By type — all team members</div>
      </div>
    </div>
    <canvas id="leaveDonut" height="175"></canvas>
    <div class="cpills">
      <%if(vLS>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--red)"></span>Sick: <%=vLS%></span><%}%>
      <%if(vLA>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Annual: <%=vLA%></span><%}%>
      <%if(vLPs>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--amber)"></span>Personal: <%=vLPs%></span><%}%>
      <%if(vLM>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--pink)"></span>Maternity: <%=vLM%></span><%}%>
      <%if(vLO>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--violet)"></span>Other: <%=vLO%></span><%}%>
    </div>
  </div>

  <!-- Leave approval status + monthly trend -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-chart-area"></i></div> Leave Trends & Approval</div>
        <div class="cs">Monthly requests + approval status</div>
      </div>
    </div>
    <!-- approval mini stats -->
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px">
      <div style="text-align:center;padding:10px;background:var(--green-lt);border:1px solid #bbf7d0;border-radius:9px">
        <div style="font-size:20px;font-weight:700;color:var(--green)"><%=vLAp%></div>
        <div style="font-size:10px;color:var(--green);font-weight:600;text-transform:uppercase;letter-spacing:.04em">Approved</div>
      </div>
      <div style="text-align:center;padding:10px;background:var(--amber-lt);border:1px solid #fde68a;border-radius:9px">
        <div style="font-size:20px;font-weight:700;color:var(--amber)"><%=vLPd%></div>
        <div style="font-size:10px;color:var(--amber);font-weight:600;text-transform:uppercase;letter-spacing:.04em">Pending</div>
      </div>
      <div style="text-align:center;padding:10px;background:var(--red-lt);border:1px solid #fecaca;border-radius:9px">
        <div style="font-size:20px;font-weight:700;color:var(--red)"><%=vLRj%></div>
        <div style="font-size:10px;color:var(--red);font-weight:600;text-transform:uppercase;letter-spacing:.04em">Rejected</div>
      </div>
    </div>
    <canvas id="leaveTrendChart" height="130"></canvas>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- ANALYTICS — Section 4: Performance                             -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="sec a6"><div class="sec-icon" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-star"></i></div>Performance Analytics</div>

<div class="cr2 a6">
  <!-- Rating distribution -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-chart-column"></i></div> Rating Distribution</div>
        <div class="cs">This month's performance ratings</div>
      </div>
      <span class="badge badge-violet">This Month</span>
    </div>
    <canvas id="perfRatingChart" height="175"></canvas>
    <!-- PATCH 5: updated cpills to use "Excellence" label -->
    <div class="cpills">
      <%if(vPEx>0){%><span class="cpill"><span class="cpill-dot" style="background:#f59e0b"></span>Excellence: <%=vPEx%></span><%}%>
      <%if(vPGo>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--green)"></span>Good: <%=vPGo%></span><%}%>
      <%if(vPAv>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--blue)"></span>Average: <%=vPAv%></span><%}%>
      <%if(vPPo>0){%><span class="cpill"><span class="cpill-dot" style="background:var(--red)"></span>Poor: <%=vPPo%></span><%}%>
    </div>
  </div>

  <!-- Top Performers list -->
  <div class="card">
    <div class="ch">
      <div>
        <div class="ct"><div class="ci" style="background:#fef9c3;color:#854d0e"><i class="fa-solid fa-trophy"></i></div> Top Performers</div>
        <div class="cs">Best rated employees this month</div>
      </div>
      <a href="#" onclick="parent.loadPage(null,'managerPerformance');return false;" style="font-size:12px;font-weight:700;color:var(--blue)">View All →</a>
    </div>
    <%
    String[] avatarColors={"#4361ee","#16a34a","#7c3aed","#d97706","#dc2626"};
    if(topPerformers!=null&&!topPerformers.isEmpty()){int ri=0;for(Map<String,String> tp2:topPerformers){
      // PATCH 6: handle EXCELLENCE (uppercase) from DB + ratingDisplay for friendly label
      String rating = tp2.get("rating");
      String ratingCls = "r-average";
      String ratingDisplay = rating != null ? rating : "N/A";
      if ("EXCELLENCE".equalsIgnoreCase(rating)) { ratingCls = "r-excellent"; ratingDisplay = "Excellence"; }
      else if ("GOOD".equalsIgnoreCase(rating))  { ratingCls = "r-good";      ratingDisplay = "Good"; }
      else if ("AVERAGE".equalsIgnoreCase(rating)){ ratingCls = "r-average";  ratingDisplay = "Average"; }
      else if ("POOR".equalsIgnoreCase(rating))  { ratingCls = "r-poor";      ratingDisplay = "Poor"; }
      String name=tp2.get("name"); if(name==null||name.trim().isEmpty())name="Unknown";
      String initials=name.trim().substring(0,1).toUpperCase(); if(name.trim().contains(" ")&&name.trim().indexOf(' ')<name.trim().length()-1)initials+=name.trim().charAt(name.trim().indexOf(' ')+1);
      String acol=avatarColors[ri%avatarColors.length]; ri++;
    %>
    <div class="performer-row">
      <div class="perf-rank" style="background:<%=ri<=3?"#fef9c3":"var(--surface2)"%>;color:<%=ri<=3?"#854d0e":"var(--text3)"%>"><%=ri%></div>
      <div class="perf-avatar" style="background:<%=acol%>"><%=initials%></div>
      <div class="perf-name"><%=name%></div>
      <!-- PATCH 6: use ratingDisplay instead of rating -->
      <span class="rating-pill <%=ratingCls%>"><%=ratingDisplay%></span>
    </div>
    <%}}else{%>
    <div class="empty"><i class="fa-solid fa-star"></i><span>No ratings this month yet</span></div>
    <%}%>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- OPERATIONS — 2-col layout                                      -->
<!-- ═══════════════════════════════════════════════════════════════ -->
<div class="sec a7"><div class="sec-icon" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa-solid fa-bolt"></i></div>Operations</div>
<div class="mg a7">

  <!-- ── LEFT COLUMN ── -->
  <div class="col">

    <!-- Today's Meetings -->
    <div class="card">
      <div class="ch">
        <div class="ct"><div class="ci" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa-solid fa-calendar-day"></i></div> Today's Meetings</div>
        <a href="#" onclick="parent.loadPage(null,'managerMeetings');return false;" style="font-size:12px;font-weight:700;color:var(--blue)">View All →</a>
      </div>
      <%
      if(todayMeetings!=null&&!todayMeetings.isEmpty()){
        SimpleDateFormat tf2=new SimpleDateFormat("h:mm a");
        for(Meeting m:todayMeetings){
      %>
      <div class="mi">
        <div class="md"></div>
        <div style="flex:1;min-width:0">
          <div class="mt"><%=m.getTitle()%></div>
          <div class="mm">
            <span><i class="fa-solid fa-clock" style="opacity:.45;margin-right:3px;font-size:10px"></i><%=tf2.format(m.getStartTime())%> – <%=tf2.format(m.getEndTime())%></span>
            <%if(m.getDescription()!=null&&!m.getDescription().isEmpty()){%>
            <span style="color:var(--text3)">·</span>
            <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:150px;color:var(--text3)"><%=m.getDescription()%></span>
            <%}%>
          </div>
        </div>
        <%if(m.getMeetingLink()!=null&&!m.getMeetingLink().isEmpty()){%>
        <a href="<%=m.getMeetingLink()%>" target="_blank" class="jb"><i class="fa-solid fa-arrow-up-right-from-square" style="font-size:9px;margin-right:3px"></i>Join</a>
        <%}%>
      </div>
      <%}}else{%>
      <div class="empty"><i class="fa-solid fa-calendar-xmark"></i><span>No meetings scheduled today</span></div>
      <%}%>
    </div>

    <!-- Quick Actions -->
    <div class="card">
      <div class="ct" style="margin-bottom:13px"><div class="ci" style="background:var(--amber-lt);color:var(--amber)"><i class="fa-solid fa-bolt"></i></div> Quick Actions</div>
      <div class="qg">
        <button class="qa" onclick="parent.loadPage(null,'managerTasks')">
          <div class="qi" style="background:var(--blue-lt);color:var(--blue)"><i class="fa-solid fa-plus"></i></div>
          <span class="ql">Assign Task</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerMeetings')">
          <div class="qi" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-calendar-plus"></i></div>
          <span class="ql">Schedule Meeting</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerPerformance')">
          <div class="qi" style="background:var(--green-lt);color:var(--green)"><i class="fa-solid fa-star"></i></div>
          <span class="ql">Rate Performance</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerLeave')">
          <div class="qi" style="background:var(--red-lt);color:var(--red)"><i class="fa-solid fa-calendar-check"></i></div>
          <span class="ql">Review Leaves</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerTeams')">
          <div class="qi" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa-solid fa-users"></i></div>
          <span class="ql">Manage Teams</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerAttendance')">
          <div class="qi" style="background:var(--amber-lt);color:var(--amber)"><i class="fa-solid fa-clock"></i></div>
          <span class="ql">View Attendance</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerReports')">
          <div class="qi" style="background:#f0f9ff;color:#0369a1"><i class="fa-solid fa-file-lines"></i></div>
          <span class="ql">Reports</span>
        </button>
        <button class="qa" onclick="parent.loadPage(null,'managerChat')">
          <div class="qi" style="background:var(--violet-lt);color:var(--violet)"><i class="fa-solid fa-message"></i></div>
          <span class="ql">Team Chat</span>
        </button>
      </div>
    </div>

    <!-- My Teams -->
    <div class="card">
      <div class="ct" style="margin-bottom:13px"><div class="ci" style="background:var(--cyan-lt);color:var(--cyan)"><i class="fa-solid fa-people-group"></i></div> My Teams</div>
      <div class="tg">
        <%
        String[] tC={"var(--blue)","var(--violet)","var(--green)","var(--amber)","var(--red)","var(--cyan)"};
        String[] tB={"var(--blue-lt)","var(--violet-lt)","var(--green-lt)","var(--amber-lt)","var(--red-lt)","var(--cyan-lt)"};
        if(teams!=null&&!teams.isEmpty()){int ti=0;for(Team t:teams){String col=tC[ti%tC.length],bg=tB[ti%tB.length];ti++;int pct=sTM>0?(t.getMembers().size()*100/sTM):0;%>
        <div class="tc">
          <div class="tt">
            <div class="ta" style="background:<%=bg%>;color:<%=col%>"><i class="fa-solid fa-users"></i></div>
            <div style="flex:1;min-width:0">
              <div class="tn"><%=t.getName()%></div>
              <div class="tct"><%=t.getMembers().size()%> members</div>
            </div>
          </div>
          <div class="tdesc"><%=t.getDescription()!=null&&!t.getDescription().isEmpty()?t.getDescription():"No description available"%></div>
          <div class="tbar"><div class="tfill" style="width:<%=pct%>%;background:<%=col%>"></div></div>
        </div>
        <%}}else{%>
        <div style="grid-column:span 2"><div class="empty"><i class="fa-solid fa-users-slash"></i><span>No teams assigned</span></div></div>
        <%}%>
      </div>
    </div>

    <!-- Overdue Task Employees -->
    <div class="card">
      <div class="ch">
        <div>
          <div class="ct"><div class="ci" style="background:var(--red-lt);color:var(--red)"><i class="fa-solid fa-user-clock"></i></div> Overdue by Employee</div>
          <div class="cs">Team members with the most overdue tasks</div>
        </div>
        <a href="#" onclick="parent.loadPage(null,'managerTasks');return false;" style="font-size:12px;font-weight:700;color:var(--blue)">View Tasks →</a>
      </div>
      <%if(overdueEmployees!=null&&!overdueEmployees.isEmpty()){
        for(Map<String,String> oe:overdueEmployees){
          String oeName=oe.get("name"); if(oeName==null||oeName.trim().isEmpty())oeName="Unknown";
          String oeCount=oe.get("count"); if(oeCount==null)oeCount="0";
          String oeInit=oeName.trim().substring(0,1).toUpperCase();
      %>
      <div class="overdue-row">
        <div class="perf-avatar" style="background:var(--red);width:30px;height:30px;font-size:11px"><%=oeInit%></div>
        <div class="od-name"><%=oeName%></div>
        <span class="od-count"><%=oeCount%> overdue</span>
      </div>
      <%}}else{%>
      <div class="empty" style="padding:14px"><i class="fa-solid fa-circle-check" style="color:var(--green)"></i><span style="color:var(--green);font-weight:700">No overdue tasks!</span></div>
      <%}%>
    </div>

  </div>

  <!-- ── RIGHT COLUMN ── -->
  <div class="col">

    <!-- Live Attendance Donut -->
    <div class="card">
      <div class="ch">
        <div>
          <div class="ct"><div class="ci"><i class="fa-solid fa-circle-half-stroke"></i></div> Live Attendance</div>
          <div class="cs">Team presence right now · <%=totalAtt%> total</div>
        </div>
        <span class="badge badge-green">Today</span>
      </div>
      <canvas id="attDonut" height="155"></canvas>
      <div class="leg">
        <span><span class="ld" style="background:var(--green)"></span>Present (<%=sP%>)</span>
        <span><span class="ld" style="background:var(--red)"></span>Absent (<%=sA%>)</span>
        <span><span class="ld" style="background:var(--amber)"></span>Break (<%=sB%>)</span>
      </div>
      <div class="att-stats">
        <div class="att-stat"><div class="att-stat-num" style="color:var(--green)"><%=attRate%>%</div><div class="att-stat-lbl">Present Rate</div></div>
        <div class="att-stat"><div class="att-stat-num" style="color:var(--red)"><%=absentRate%>%</div><div class="att-stat-lbl">Absent Rate</div></div>
        <div class="att-stat"><div class="att-stat-num" style="color:var(--amber)"><%=sB%></div><div class="att-stat-lbl">On Break</div></div>
      </div>
    </div>

    <!-- Needs Attention -->
    <div class="card">
      <div class="ct" style="margin-bottom:12px"><div class="ci" style="background:var(--red-lt);color:var(--red)"><i class="fa-solid fa-bell"></i></div> Needs Attention</div>
      <%if(sL>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerLeave');return false;" style="background:var(--red-lt);border-color:#fecaca">
        <div class="ali"><div class="alic" style="background:#fecaca;color:var(--red)"><i class="fa-solid fa-calendar-xmark"></i></div>
          <div><div class="alt">Leave Requests</div><div class="als"><%=sL%> pending approval</div></div></div>
        <span class="alb" style="background:#fecaca;color:#991b1b"><%=sL%></span>
      </a><%}%>
      <%if(sOT>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerTasks');return false;" style="background:var(--amber-lt);border-color:#fde68a">
        <div class="ali"><div class="alic" style="background:#fde68a;color:var(--amber)"><i class="fa-solid fa-triangle-exclamation"></i></div>
          <div><div class="alt">Overdue Tasks</div><div class="als"><%=sOT%> past deadline</div></div></div>
        <span class="alb" style="background:#fde68a;color:#92400e"><%=sOT%></span>
      </a><%}%>
      <%if(sPR>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerPerformance');return false;" style="background:var(--violet-lt);border-color:#ddd6fe">
        <div class="ali"><div class="alic" style="background:#ddd6fe;color:var(--violet)"><i class="fa-solid fa-star"></i></div>
          <div><div class="alt">Reviews Pending</div><div class="als"><%=sPR%> employees to rate</div></div></div>
        <span class="alb" style="background:#ddd6fe;color:#5b21b6"><%=sPR%></span>
      </a><%}%>
      <%if(vHP>0){%>
      <a class="al" href="#" onclick="parent.loadPage(null,'managerTasks');return false;" style="background:var(--red-lt);border-color:#fecaca">
        <div class="ali"><div class="alic" style="background:#fecaca;color:var(--red)"><i class="fa-solid fa-fire"></i></div>
          <div><div class="alt">High Priority Tasks</div><div class="als"><%=vHP%> high priority items active</div></div></div>
        <span class="alb" style="background:#fecaca;color:#991b1b"><%=vHP%></span>
      </a><%}%>
      <%if(sL==0&&sOT==0&&sPR==0&&vHP==0){%>
      <div class="empty" style="padding:16px"><i class="fa-solid fa-circle-check" style="color:var(--green)"></i>
        <span style="color:var(--green);font-weight:700">All caught up!</span></div>
      <%}%>
    </div>

    <!-- Recent Activity -->
    <div class="card">
      <div class="ct" style="margin-bottom:12px"><div class="ci"><i class="fa-solid fa-clock-rotate-left"></i></div> Recent Activity</div>
      <%
      if(recentActivities!=null&&!recentActivities.isEmpty()){
        for(Map<String,String> act:recentActivities){
          String at=act.get("type"),ic="fa-circle",ac2="var(--text2)",ab2="var(--surface2)";
          if("Task Assigned".equals(at)){ic="fa-list-check";ac2="var(--amber)";ab2="var(--amber-lt)";}
          else if("Leave Request".equals(at)){ic="fa-calendar-xmark";ac2="var(--red)";ab2="var(--red-lt)";}
          else if("Meeting Scheduled".equals(at)){ic="fa-video";ac2="var(--violet)";ab2="var(--violet-lt)";}
      %>
      <div class="aci">
        <div class="acd" style="background:<%=ab2%>;color:<%=ac2%>"><i class="fa-solid <%=ic%>"></i></div>
        <div style="flex:1;min-width:0">
          <div class="act-t"><%=at%></div>
          <div class="act-d"><%=act.get("description")%></div>
          <div class="act-tm"><%=act.get("time")%></div>
        </div>
      </div>
      <%}}else{%>
      <div class="empty" style="padding:14px"><i class="fa-solid fa-inbox"></i><span>No recent activity</span></div>
      <%}%>
    </div>

    <!-- Performance Summary Card (gradient) -->
    <div class="perf-card">
      <div style="font-size:14px;font-weight:700;display:flex;align-items:center;gap:8px;margin-bottom:14px">
        <i class="fa-solid fa-chart-line"></i> Performance Overview
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Attendance Rate</span><span><%=attRate%>%</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=attRate%>%;background:rgba(255,255,255,.9)"></div></div>
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Task Completion</span><span><%=compRate%>%</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=compRate%>%;background:rgba(255,255,255,.75)"></div></div>
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>Reviews Done</span><span><%=revRate%>%</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=revRate%>%;background:rgba(255,255,255,.6)"></div></div>
      </div>
      <div class="pb-wrap">
        <div class="pb-lbl"><span>4-Week Avg Attendance</span><span><%=vAA4%>%</span></div>
        <div class="pb-trk"><div class="pb-fill" style="width:<%=vAA4%>%;background:rgba(255,255,255,.45)"></div></div>
      </div>
      <div class="sep"></div>
      <div style="display:flex;align-items:center;justify-content:space-between">
        <div>
          <div style="font-size:10px;opacity:.7;text-transform:uppercase;letter-spacing:.05em">Rated this month</div>
          <div style="font-size:22px;font-weight:700;margin-top:3px"><%=sR%> <span style="font-size:12px;opacity:.5">/ <%=totalRev%></span></div>
        </div>
        <a href="#" onclick="parent.loadPage(null,'managerPerformance');return false;"
          style="padding:9px 16px;background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.28);color:#fff;border-radius:10px;font-size:13px;font-weight:700"
          onmouseover="this.style.background='rgba(255,255,255,.28)'" onmouseout="this.style.background='rgba(255,255,255,.18)'">Rate Now →</a>
      </div>
    </div>

  </div><!-- end right col -->
</div><!-- end .mg -->

</div><!-- end .pg -->

<script>
// ── Chart.js global defaults ──────────────────────────────────────────────
Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
Chart.defaults.font.size   = 12;
Chart.defaults.color       = '#9298b3';
Chart.defaults.plugins.legend.labels.boxWidth = 10;
Chart.defaults.plugins.legend.labels.padding  = 12;
Chart.defaults.plugins.legend.labels.color    = '#505573';
Chart.defaults.plugins.tooltip.backgroundColor = '#18192b';
Chart.defaults.plugins.tooltip.titleColor      = '#f0f2ff';
Chart.defaults.plugins.tooltip.bodyColor       = '#9298b3';
Chart.defaults.plugins.tooltip.borderColor     = '#2e3347';
Chart.defaults.plugins.tooltip.borderWidth     = 1;
Chart.defaults.plugins.tooltip.padding         = 11;
Chart.defaults.plugins.tooltip.cornerRadius    = 9;
Chart.defaults.scale.grid.color                = '#f0f2f8';
Chart.defaults.scale.border.display            = false;
Chart.defaults.scale.ticks.color               = '#9298b3';

// ── 1. Weekly Attendance Bar ──────────────────────────────────────────────
new Chart(document.getElementById('weeklyAtt'), {
  type: 'bar',
  data: {
    labels: [<%=weekLabels%>],
    datasets: [
      { label:'Present', data:[<%=weekPresentData%>], backgroundColor:'#4361ee', borderRadius:5, borderSkipped:false },
      { label:'Absent',  data:[<%=weekAbsentData%>],  backgroundColor:'#fca5a5', borderRadius:5, borderSkipped:false }
    ]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ position:'top' } },
    scales:{ x:{ grid:{ display:false } }, y:{ ticks:{ stepSize:1 }, beginAtZero:true } }
  }
});

// ── 2. Average Work Hours Line ────────────────────────────────────────────
new Chart(document.getElementById('workHoursChart'), {
  type: 'line',
  data: {
    labels: [<%=workHourLabels%>],
    datasets:[{
      label:'Avg Hours',
      data: [<%=workHourData%>],
      borderColor:'#0891b2',
      backgroundColor:'rgba(8,145,178,.1)',
      borderWidth:2.5,
      fill:true,
      tension:.4,
      pointBackgroundColor:'#0891b2',
      pointRadius:4,
      pointHoverRadius:6
    }]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ display:false } },
    scales:{
      x:{ grid:{ display:false } },
      y:{ beginAtZero:true, max:10, ticks:{ stepSize:2, callback: v => v+'h' } }
    }
  }
});

// ── 3. Punch-In Distribution Bar ──────────────────────────────────────────
new Chart(document.getElementById('punchBar'), {
  type: 'bar',
  data: {
    labels: ['Before 8am','8–9am','9–10am','10–11am','After 11am'],
    datasets:[{
      label:'Employees',
      data: [<%=vP0%>, <%=vP1%>, <%=vP2%>, <%=vP3%>, <%=vP4%>],
      backgroundColor: ['#16a34a','#4361ee','#f59e0b','#ef4444','#7c3aed'],
      borderRadius: 6, borderSkipped: false
    }]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false } }, y:{ ticks:{ stepSize:1 }, beginAtZero:true } }
  }
});

// ── 4. Task Status Pie — PATCH 3: added Processing status ────────────────
new Chart(document.getElementById('taskPie'), {
  type: 'pie',
  data: {
    labels: ['Assigned','Completed','Submitted','Processing','Overdue'],
    datasets:[{
      data: [<%=vTA%>, <%=vTC2%>, <%=vTS%>, <%=vTProc%>, <%=vTO%>],
      backgroundColor: ['#4361ee','#16a34a','#f59e0b','#0891b2','#ef4444'],
      borderWidth:2, borderColor:'#fff', hoverOffset:6
    }]
  },
  options:{ responsive:true, plugins:{ legend:{ position:'bottom' } } }
});

// ── 5. Task Priority Chart ────────────────────────────────────────────────
new Chart(document.getElementById('priorityChart'), {
  type: 'doughnut',
  data: {
    labels: ['High','Medium','Low'],
    datasets:[{
      data: [<%=vHP%>, <%=vMP%>, <%=vLP2%>],
      backgroundColor: ['#ef4444','#f59e0b','#16a34a'],
      borderWidth:2, borderColor:'#fff', hoverOffset:5
    }]
  },
  options:{ responsive:true, cutout:'58%', plugins:{ legend:{ position:'bottom' } } }
});

// ── 6. Task Completion Trend ──────────────────────────────────────────────
new Chart(document.getElementById('taskTrendChart'), {
  type: 'line',
  data: {
    labels: [<%=taskTrendLabels%>],
    datasets:[{
      label:'Completed',
      data: [<%=taskTrendData%>],
      borderColor:'#16a34a',
      backgroundColor:'rgba(22,163,74,.1)',
      borderWidth:2.5, fill:true, tension:.35,
      pointBackgroundColor:'#16a34a', pointRadius:4, pointHoverRadius:6
    }]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false } }, y:{ beginAtZero:true, ticks:{ stepSize:1 } } }
  }
});

// ── 7. Leave Type Doughnut ────────────────────────────────────────────────
new Chart(document.getElementById('leaveDonut'), {
  type: 'doughnut',
  data: {
    labels: ['Sick','Annual','Personal','Maternity','Other'],
    datasets:[{
      data: [<%=vLS%>, <%=vLA%>, <%=vLPs%>, <%=vLM%>, <%=vLO%>],
      backgroundColor: ['#ef4444','#16a34a','#f59e0b','#db2777','#7c3aed'],
      borderWidth:2, borderColor:'#fff', hoverOffset:6
    }]
  },
  options:{ responsive:true, cutout:'55%', plugins:{ legend:{ position:'bottom' } } }
});

// ── 8. Leave Trend Line ───────────────────────────────────────────────────
new Chart(document.getElementById('leaveTrendChart'), {
  type: 'bar',
  data: {
    labels: [<%=leaveTrendLabels%>],
    datasets:[{
      label:'Leave Requests',
      data: [<%=leaveTrendData%>],
      backgroundColor:'rgba(220,38,38,.65)',
      borderColor:'#dc2626',
      borderWidth:1.5,
      borderRadius:5, borderSkipped:false
    }]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false } }, y:{ beginAtZero:true, ticks:{ stepSize:1 } } }
  }
});

// ── 9. Performance Rating Bar — PATCH 7: updated labels to 'Excellence' ──
new Chart(document.getElementById('perfRatingChart'), {
  type: 'bar',
  data: {
    labels: ['Excellence','Good','Average','Poor'],
    datasets:[{
      label:'Employees',
      data: [<%=vPEx%>, <%=vPGo%>, <%=vPAv%>, <%=vPPo%>],
      backgroundColor: ['#f59e0b','#16a34a','#4361ee','#ef4444'],
      borderRadius:6, borderSkipped:false
    }]
  },
  options:{
    responsive:true,
    plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false } }, y:{ beginAtZero:true, ticks:{ stepSize:1 } } }
  }
});

// ── 10. Live Attendance Donut ─────────────────────────────────────────────
(function(){
  var tot = <%=sP%>+<%=sA%>+<%=sB%>;
  new Chart(document.getElementById('attDonut'),{
    type:'doughnut',
    data:{
      labels:['Present','Absent','On Break'],
      datasets:[{
        data: tot>0 ? [<%=sP%>,<%=sA%>,<%=sB%>] : [1,0,0],
        backgroundColor:['#16a34a','#ef4444','#f59e0b'],
        borderWidth:2, borderColor:'#fff', hoverOffset:5
      }]
    },
    options:{
      cutout:'70%', responsive:true,
      plugins:{
        legend:{ display:false },
        tooltip:{ callbacks:{ label: ctx=>' '+ctx.label+': '+ctx.raw } }
      }
    },
    plugins:[{
      id:'cx',
      beforeDraw(c){
        var {ctx,chartArea:{left,top,right,bottom}}=c;
        var cx=(left+right)/2, cy=(top+bottom)/2;
        ctx.save(); ctx.textAlign='center'; ctx.textBaseline='middle';
        ctx.font='bold 20px DM Sans,sans-serif'; ctx.fillStyle='#18192b';
        ctx.fillText(tot,cx,cy-7);
        ctx.font='10px DM Sans,sans-serif'; ctx.fillStyle='#9298b3';
        ctx.fillText('Total',cx,cy+9); ctx.restore();
      }
    }]
  });
})();
</script>

<script>
document.addEventListener('contextmenu',e=>e.preventDefault());
document.onkeydown=e=>(e.keyCode===123||(e.ctrlKey&&e.shiftKey&&['I','J','C'].includes(e.key.toUpperCase())))?false:true;
</script>
</body>
</html>
