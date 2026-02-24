<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Overview</title>

<style>
body {
	font-family: Arial, sans-serif;
	background: #f3f4f6;
	padding: 20px;
}

h2 {
	margin-bottom: 20px;
}

.dashboard {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
	gap: 20px;
}

/* Common Card Style */
.card {
	padding: 20px;
	border-radius: 12px;
	text-align: center;
	color: #ffffff;
	transition: 0.3s ease;
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.7);
}

.card:hover {
	transform: translateY(-5px);
}

/* Individual Card Colors */
.managers {
	background: #3f73e6;
} /* Blue */
.employees {
	background: #51aa72;
} /* Green */
.total {
	background: #601dd4;
} /* Purple */
.present {
	background: #f0a628;
} /* Orange */
.absent {
	background: #e23939;
} /* Red */
.holidays {
	background: #0f766e;
} /* Teal */
.card h3 {
	margin-bottom: 20px;
	font-size: 22px;
}

.card span {
	font-size: 19px;
	font-weight: bold;
	display: block;
}

/* Fade In Animation */
@
keyframes fadeInDashboard {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.dashboard {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
	gap: 20px;
	animation: fadeInDashboard 0.8s ease-in-out;
}

/* ===== Upcoming Holidays List ===== */
.holiday-list {
	list-style: none;
	padding: 0;
	margin: 0;
}

.holiday-list li {
	background: rgba(255, 255, 255, 0.15);
	margin-bottom: 10px;
	padding: 10px 12px;
	border-radius: 8px;
	font-size: 16px;
	font-weight: 500;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: 0.25s ease;
}

/* Divider feel */
.holiday-list li:last-child {
	margin-bottom: 0;
}

/* Hover effect */
.holiday-list li:hover {
	background: rgba(255, 255, 255, 0.25);
	transform: scale(1.03);
}

.holiday-list li i {
	margin-right: 8px;
}
</style>
</head>

<body>

	<h2>📊 Admin Overview</h2>

	<div class="dashboard">

		<div class="card managers">
			<h3>Managers</h3>
			<span>${managers}</span>
		</div>

		<div class="card employees">
			<h3>Employees</h3>
			<span>${employees}</span>
		</div>

		<div class="card total">
			<h3>Total Staff</h3>
			<span>${totalStaff}</span>
		</div>

		<div class="card present">
			<h3>Present Today</h3>
			<span>${presentToday}</span>
		</div>

		<div class="card absent">
			<h3>Absent Today</h3>
			<span>${absentToday}</span>
		</div>

		<div class="card holidays">
			<h3>Upcoming Holidays</h3>

			<ul class="holiday-list">
				<c:choose>
					<c:when test="${not empty holidays}">
						<c:forEach var="h" items="${holidays}">
							<li><i class="fa-solid fa-calendar-day"></i> ${h}</li>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<li>No upcoming holidays</li>
					</c:otherwise>
				</c:choose>
			</ul>
		</div>

	</div>
	<script>
		window.onload = function() {
			document.getElementById("adminSection").style.display = "block";
		};
	</script>
</body>
</html>
