<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%!private static String attr(javax.servlet.http.HttpServletRequest r, String key, String def) {
		Object v = r.getAttribute(key);
		return (v != null && !v.toString().isEmpty()) ? v.toString() : def;
	}
	private static int attrInt(javax.servlet.http.HttpServletRequest r, String key, int def) {
		Object v = r.getAttribute(key);
		if (v == null)
			return def;
		try {
			return Integer.parseInt(v.toString());
		} catch (Exception e) {
			return def;
		}
	}%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Overview • Smart Office HRMS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script
	src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
:root {
	--bg: #f0f2f8;
	--surface: #fff;
	--surface2: #f7f8fc;
	--border: #e4e8f0;
	--text: #1a1d2e;
	--text2: #5a6278;
	--text3: #9aa0b8;
	--blue: #4f6ef7;
	--green: #22c55e;
	--violet: #8b5cf6;
	--amber: #f59e0b;
	--red: #ef4444;
	--shadow-sm: 0 1px 3px rgba(0, 0, 0, .06);
	--shadow: 0 4px 16px rgba(0, 0, 0, .07);
	--shadow-lg: 0 20px 50px rgba(0, 0, 0, .1);
	--radius: 16px;
	--radius-sm: 10px;
}

*, *::before, *::after {
	box-sizing: border-box;
	margin: 0;
	padding: 0
}

body {
	font-family: 'DM Sans', system-ui, sans-serif;
	background: var(--bg);
	color: var(--text);
	min-height: 100vh
}

.page {
	max-width: 1200px;
	margin: 0 auto;
	padding: 32px 20px
}

.page-header {
	margin-bottom: 28px
}

.page-title {
	font-family: 'Fraunces', Georgia, serif;
	font-size: 26px;
	font-weight: 600;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 10px
}

.page-title i {
	color: var(--blue);
	font-size: 20px
}

.page-subtitle {
	color: var(--text3);
	font-size: 13px;
	margin-top: 4px
}

.stats-row {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 14px;
	margin-bottom: 24px
}

@media ( max-width :900px) {
	.stats-row {
		grid-template-columns: repeat(3, 1fr)
	}
}

@media ( max-width :560px) {
	.stats-row {
		grid-template-columns: repeat(2, 1fr)
	}
}

.stat-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 18px 16px;
	box-shadow: var(--shadow-sm);
	transition: box-shadow .2s, transform .2s;
	position: relative;
	overflow: hidden
}

.stat-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 3px;
	border-radius: var(--radius) var(--radius) 0 0
}

.stat-card:hover {
	box-shadow: var(--shadow);
	transform: translateY(-2px)
}

.stat-card.blue::before {
	background: var(--blue)
}

.stat-card.green::before {
	background: var(--green)
}

.stat-card.violet::before {
	background: var(--violet)
}

.stat-card.amber::before {
	background: var(--amber)
}

.stat-card.red::before {
	background: var(--red)
}

.stat-icon {
	width: 38px;
	height: 38px;
	border-radius: 10px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 16px;
	margin-bottom: 12px
}

.stat-card.blue .stat-icon {
	background: #eef1fe;
	color: var(--blue)
}

.stat-card.green .stat-icon {
	background: #f0fdf4;
	color: var(--green)
}

.stat-card.violet .stat-icon {
	background: #f5f3ff;
	color: var(--violet)
}

.stat-card.amber .stat-icon {
	background: #fffbeb;
	color: var(--amber)
}

.stat-card.red .stat-icon {
	background: #fef2f2;
	color: var(--red)
}

.stat-num {
	font-size: 28px;
	font-weight: 700;
	line-height: 1;
	color: var(--text)
}

.stat-label {
	font-size: 12px;
	color: var(--text3);
	font-weight: 500;
	margin-top: 4px;
	text-transform: uppercase;
	letter-spacing: .5px
}

.charts-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	margin-bottom: 20px
}

.charts-grid-3 {
	display: grid;
	grid-template-columns: 1fr 1fr 1fr;
	gap: 20px;
	margin-bottom: 20px
}

.charts-grid-wide {
	display: grid;
	grid-template-columns: 2fr 1fr;
	gap: 20px;
	margin-bottom: 20px
}

@media ( max-width :900px) {
	.charts-grid, .charts-grid-3, .charts-grid-wide {
		grid-template-columns: 1fr
	}
}

.chart-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 20px;
	box-shadow: var(--shadow-sm);
	animation: fadeUp .5s ease both
}

.chart-card:hover {
	box-shadow: var(--shadow)
}

.chart-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 16px
}

.chart-title {
	font-size: 14px;
	font-weight: 700;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 7px
}

.chart-title i {
	font-size: 13px;
	color: var(--blue)
}

.chart-subtitle {
	font-size: 11px;
	color: var(--text3);
	margin-top: 2px
}

.chart-badge {
	font-size: 11px;
	font-weight: 600;
	padding: 3px 8px;
	border-radius: 99px;
	background: #eef1fe;
	color: var(--blue)
}

canvas {
	max-width: 100%
}

.insight-row {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 14px;
	margin-bottom: 20px
}

@media ( max-width :900px) {
	.insight-row {
		grid-template-columns: repeat(2, 1fr)
	}
}

.insight-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 16px;
	box-shadow: var(--shadow-sm);
	display: flex;
	align-items: center;
	gap: 12px
}

.insight-icon {
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 17px;
	flex-shrink: 0
}

.insight-label {
	font-size: 11px;
	color: var(--text3);
	font-weight: 500;
	text-transform: uppercase;
	letter-spacing: .5px
}

.insight-value {
	font-size: 20px;
	font-weight: 700;
	color: var(--text);
	line-height: 1.2
}

.insight-sub {
	font-size: 11px;
	color: var(--text3);
	margin-top: 1px
}

.holiday-card {
	background: linear-gradient(135deg, #4f6ef7 0%, #8b5cf6 100%);
	border-radius: var(--radius);
	padding: 20px;
	color: white;
	box-shadow: var(--shadow)
}

.holiday-title {
	font-size: 14px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 7px;
	margin-bottom: 14px;
	opacity: .95
}

.holiday-item {
	background: rgba(255, 255, 255, .15);
	backdrop-filter: blur(4px);
	border-radius: var(--radius-sm);
	padding: 10px 14px;
	font-size: 13px;
	font-weight: 500;
	margin-bottom: 8px;
	border: 1px solid rgba(255, 255, 255, .2)
}

.holiday-item:last-child {
	margin-bottom: 0
}

@
keyframes fadeUp {
	from {opacity: 0;
	transform: translateY(14px)
}

to {
	opacity: 1;
	transform: translateY(0)
}

}
.a1 {
	animation-delay: .05s
}

.a2 {
	animation-delay: .10s
}

.a3 {
	animation-delay: .15s
}

.a4 {
	animation-delay: .20s
}

.a5 {
	animation-delay: .25s
}

.a6 {
	animation-delay: .30s
}
</style>
</head>
<body>
	<div class="page">

		<div class="page-header">
			<div class="page-title">
				<i class="fa-solid fa-chart-line"></i> Admin Overview
			</div>
			<div class="page-subtitle">Real-time insights across
				attendance, tasks, leaves and workforce</div>
		</div>

		<div class="stats-row">
			<div class="stat-card blue">
				<div class="stat-icon">
					<i class="fa-solid fa-user-tie"></i>
				</div>
				<div class="stat-num">${managers}</div>
				<div class="stat-label">Managers</div>
			</div>
			<div class="stat-card green">
				<div class="stat-icon">
					<i class="fa-solid fa-users"></i>
				</div>
				<div class="stat-num">${employees}</div>
				<div class="stat-label">Employees</div>
			</div>
			<div class="stat-card violet">
				<div class="stat-icon">
					<i class="fa-solid fa-building-user"></i>
				</div>
				<div class="stat-num">${totalStaff}</div>
				<div class="stat-label">Total Staff</div>
			</div>
			<div class="stat-card amber">
				<div class="stat-icon">
					<i class="fa-solid fa-circle-check"></i>
				</div>
				<div class="stat-num">${presentToday}</div>
				<div class="stat-label">Present Today</div>
			</div>
			<div class="stat-card red">
				<div class="stat-icon">
					<i class="fa-solid fa-user-minus"></i>
				</div>
				<div class="stat-num">${absentToday}</div>
				<div class="stat-label">Absent Today</div>
			</div>
		</div>

		<div class="insight-row">
			<div class="insight-card">
				<div class="insight-icon"
					style="background: #f0fdf4; color: #22c55e">
					<i class="fa-solid fa-arrow-trend-up"></i>
				</div>
				<div>
					<div class="insight-label">Attendance Rate</div>
					<div class="insight-value"><%=attrInt(request, "attendanceRate", 0)%>%
					</div>
					<div class="insight-sub">This month</div>
				</div>
			</div>
			<div class="insight-card">
				<div class="insight-icon"
					style="background: #eef1fe; color: #4f6ef7">
					<i class="fa-solid fa-list-check"></i>
				</div>
				<div>
					<div class="insight-label">Tasks Completed</div>
					<div class="insight-value"><%=attrInt(request, "tasksCompleted", 0)%></div>
					<div class="insight-sub">This month</div>
				</div>
			</div>
			<div class="insight-card">
				<div class="insight-icon"
					style="background: #fff7ed; color: #f97316">
					<i class="fa-solid fa-umbrella-beach"></i>
				</div>
				<div>
					<div class="insight-label">Leaves Pending</div>
					<div class="insight-value"><%=attrInt(request, "leavesPending", 0)%></div>
					<div class="insight-sub">Awaiting approval</div>
				</div>
			</div>
			<div class="insight-card">
				<div class="insight-icon"
					style="background: #fdf4ff; color: #a855f7">
					<i class="fa-solid fa-people-group"></i>
				</div>
				<div>
					<div class="insight-label">Active Teams</div>
					<div class="insight-value"><%=attrInt(request, "activeTeams", 0)%></div>
					<div class="insight-sub">Across departments</div>
				</div>
			</div>
		</div>

		<div class="charts-grid">
			<div class="chart-card a1">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-calendar-check"></i> Weekly Attendance
						</div>
						<div class="chart-subtitle">Present vs Absent — last 7 days</div>
					</div>
					<span class="chart-badge">This Week</span>
				</div>
				<canvas id="attendanceBarChart" height="200"></canvas>
			</div>
			<div class="chart-card a2">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-chart-pie"></i> Task Status
						</div>
						<div class="chart-subtitle">Distribution by current status</div>
					</div>
				</div>
				<canvas id="taskPieChart" height="200"></canvas>
			</div>
		</div>

		<div class="charts-grid-wide">
			<div class="chart-card a3">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-chart-line"></i> Monthly Attendance Trend
						</div>
						<div class="chart-subtitle">30-day rolling attendance curve</div>
					</div>
					<span class="chart-badge">30 Days</span>
				</div>
				<canvas id="attendanceTrendChart" height="160"></canvas>
			</div>
			<div class="chart-card a4">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-plane-departure"></i> Leave Types
						</div>
						<div class="chart-subtitle">Breakdown by leave category</div>
					</div>
				</div>
				<canvas id="leaveDoughnutChart" height="160"></canvas>
			</div>
		</div>

		<div class="charts-grid-3">
			<div class="chart-card a4">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-bars-progress"></i> Task Completion
						</div>
						<div class="chart-subtitle">By month this year</div>
					</div>
				</div>
				<canvas id="taskBarChart" height="200"></canvas>
			</div>
			<div class="chart-card a5">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-users-gear"></i> Staff Roles
						</div>
						<div class="chart-subtitle">Manager vs Employee ratio</div>
					</div>
				</div>
				<canvas id="staffRolePieChart" height="200"></canvas>
			</div>
			<div class="chart-card a6">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-mug-hot"></i> Break Analytics
						</div>
						<div class="chart-subtitle">Avg break duration by day</div>
					</div>
				</div>
				<canvas id="breakBarChart" height="200"></canvas>
			</div>
		</div>

		<div class="charts-grid">
			<div class="holiday-card a5">
				<div class="holiday-title">
					<i class="fa-solid fa-calendar-days"></i> Upcoming Holidays
				</div>
				<c:choose>
					<c:when test="${not empty holidays}">
						<c:forEach var="h" items="${holidays}">
							<div class="holiday-item">${h}</div>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<div class="holiday-item">No upcoming holidays scheduled</div>
					</c:otherwise>
				</c:choose>
			</div>
			<div class="chart-card a6">
				<div class="chart-header">
					<div>
						<div class="chart-title">
							<i class="fa-solid fa-hourglass-half"></i> Punch-In Distribution
						</div>
						<div class="chart-subtitle">When employees arrive (this
							week)</div>
					</div>
				</div>
				<canvas id="punchInChart" height="200"></canvas>
			</div>
		</div>

	</div>

	<script>
Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
Chart.defaults.font.size   = 12;
Chart.defaults.color       = '#9aa0b8';
Chart.defaults.plugins.legend.labels.boxWidth = 12;
Chart.defaults.plugins.legend.labels.padding  = 14;

var managers  = <%=attrInt(request, "managers", 3)%>;
var employees = <%=attrInt(request, "employees", 22)%>;

var weekLabels  = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
var weekPresent = [<%=attr(request, "weekPresent", "18,20,17,21,19,10,5")%>];
var weekAbsent  = [<%=attr(request, "weekAbsent", "7,5,8,4,6,15,20")%>];

var taskCompleted    = <%=attrInt(request, "taskCompleted", 42)%>;
var taskInProgress   = <%=attrInt(request, "taskInProgress", 18)%>;
var taskPending      = <%=attrInt(request, "taskPending", 11)%>;
var taskErrorsRaised = <%=attrInt(request, "taskErrorsRaised", 5)%>;
var taskDocVerify    = <%=attrInt(request, "taskDocVerify", 7)%>;

var trendLabels = [];
var trendData   = [<%=attr(request, "attendanceTrend",
		"72,75,80,78,82,85,83,87,84,88,86,90,89,91,88,85,87,90,92,89,91,94,92,88,90,93,91,89,87,90")%>];
for (var i = 1; i <= 30; i++) trendLabels.push('D' + i);

var leaveSick      = <%=attrInt(request, "leaveSick", 12)%>;
var leaveAnnual    = <%=attrInt(request, "leaveAnnual", 18)%>;
var leavePersonal  = <%=attrInt(request, "leavePersonal", 7)%>;
var leaveMaternity = <%=attrInt(request, "leaveMaternity", 3)%>;
var leaveUnpaid    = <%=attrInt(request, "leaveUnpaid", 5)%>;

var monthLabels   = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
var taskMonthData = [<%=attr(request, "taskMonthData", "8,12,15,10,18,22,19,24,20,17,21,25")%>];

var breakData = [<%=attr(request, "breakData", "28,32,25,35,30,20,18")%>];

var punchLabels = ['Before 8','8-9','9-10','10-11','After 11'];
var punchData   = [<%=attr(request, "punchData", "3,14,7,2,1")%>];

new Chart(document.getElementById('attendanceBarChart'), {
  type: 'bar',
  data: {
    labels: weekLabels,
    datasets: [
      { label:'Present', data:weekPresent, backgroundColor:'#4f6ef7', borderRadius:6, borderSkipped:false },
      { label:'Absent',  data:weekAbsent,  backgroundColor:'#fca5a5', borderRadius:6, borderSkipped:false }
    ]
  },
  options: {
    responsive:true, plugins:{ legend:{ position:'top' } },
    scales:{
      x:{ grid:{ display:false }, border:{ display:false } },
      y:{ grid:{ color:'#f0f2f8' }, border:{ display:false }, ticks:{ stepSize:5 } }
    }
  }
});

new Chart(document.getElementById('taskPieChart'), {
  type: 'pie',
  data: {
    labels: ['Completed','In Progress','Pending','Errors Raised','Doc Verify'],
    datasets: [{ data:[taskCompleted,taskInProgress,taskPending,taskErrorsRaised,taskDocVerify], backgroundColor:['#22c55e','#4f6ef7','#f59e0b','#ef4444','#8b5cf6'], borderWidth:2, borderColor:'#fff' }]
  },
  options: { responsive:true, plugins:{ legend:{ position:'bottom' } } }
});

new Chart(document.getElementById('attendanceTrendChart'), {
  type: 'line',
  data: {
    labels: trendLabels,
    datasets: [{ label:'Attendance %', data:trendData, borderColor:'#4f6ef7', backgroundColor:'rgba(79,110,247,0.08)', borderWidth:2.5, pointRadius:0, pointHoverRadius:5, fill:true, tension:0.4 }]
  },
  options: {
    responsive:true, plugins:{ legend:{ display:false } },
    scales:{
      x:{ grid:{ display:false }, border:{ display:false }, ticks:{ maxTicksLimit:8 } },
      y:{ min:50, max:100, grid:{ color:'#f0f2f8' }, border:{ display:false }, ticks:{ callback:function(v){ return v+'%'; } } }
    }
  }
});

new Chart(document.getElementById('leaveDoughnutChart'), {
  type: 'doughnut',
  data: {
    labels: ['Sick','Annual','Personal','Maternity','Unpaid'],
    datasets: [{ data:[leaveSick,leaveAnnual,leavePersonal,leaveMaternity,leaveUnpaid], backgroundColor:['#ef4444','#22c55e','#f59e0b','#ec4899','#8b5cf6'], borderWidth:2, borderColor:'#fff', hoverOffset:6 }]
  },
  options: { responsive:true, cutout:'60%', plugins:{ legend:{ position:'bottom' } } }
});

new Chart(document.getElementById('taskBarChart'), {
  type: 'bar',
  data: {
    labels: monthLabels,
    datasets: [{ label:'Tasks Completed', data:taskMonthData, backgroundColor:'rgba(34,197,94,0.85)', borderRadius:6, borderSkipped:false }]
  },
  options: {
    responsive:true, plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false }, border:{ display:false } }, y:{ grid:{ color:'#f0f2f8' }, border:{ display:false } } }
  }
});

new Chart(document.getElementById('staffRolePieChart'), {
  type: 'doughnut',
  data: {
    labels: ['Managers','Employees'],
    datasets: [{ data:[managers,employees], backgroundColor:['#4f6ef7','#8b5cf6'], borderWidth:2, borderColor:'#fff', hoverOffset:6 }]
  },
  options: { responsive:true, cutout:'55%', plugins:{ legend:{ position:'bottom' } } }
});

new Chart(document.getElementById('breakBarChart'), {
  type: 'bar',
  data: {
    labels: weekLabels,
    datasets: [{ label:'Avg Break (min)', data:breakData, backgroundColor:'rgba(245,158,11,0.85)', borderRadius:6, borderSkipped:false }]
  },
  options: {
    responsive:true, plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false }, border:{ display:false } }, y:{ grid:{ color:'#f0f2f8' }, border:{ display:false }, ticks:{ callback:function(v){ return v+'m'; } } } }
  }
});

new Chart(document.getElementById('punchInChart'), {
  type: 'bar',
  data: {
    labels: punchLabels,
    datasets: [{ label:'Employees', data:punchData, backgroundColor:['#22c55e','#4f6ef7','#f59e0b','#ef4444','#8b5cf6'], borderRadius:8, borderSkipped:false }]
  },
  options: {
    responsive:true, plugins:{ legend:{ display:false } },
    scales:{ x:{ grid:{ display:false }, border:{ display:false } }, y:{ grid:{ color:'#f0f2f8' }, border:{ display:false }, ticks:{ stepSize:2 } } }
  }
});
</script>
	<script>
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
</script>
</body>
</html>
