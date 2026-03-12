<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Overview • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body { font-family: 'Inter', system-ui, sans-serif; }</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-6xl mx-auto">
	<h1 class="text-2xl font-semibold text-slate-800 mb-6 flex items-center gap-2">
		<i class="fa-solid fa-chart-line text-indigo-500"></i>
		Admin Overview
	</h1>

	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
		<div class="bg-gradient-to-br from-blue-500 to-blue-700 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-shadow">
			<h3 class="text-sm font-medium opacity-90 mb-2">Managers</h3>
			<p class="text-2xl font-bold">${managers}</p>
		</div>
		<div class="bg-gradient-to-br from-emerald-500 to-emerald-700 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-shadow">
			<h3 class="text-sm font-medium opacity-90 mb-2">Employees</h3>
			<p class="text-2xl font-bold">${employees}</p>
		</div>
		<div class="bg-gradient-to-br from-violet-500 to-violet-700 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-shadow">
			<h3 class="text-sm font-medium opacity-90 mb-2">Total Staff</h3>
			<p class="text-2xl font-bold">${totalStaff}</p>
		</div>
		<div class="bg-gradient-to-br from-amber-500 to-amber-700 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-shadow">
			<h3 class="text-sm font-medium opacity-90 mb-2">Present Today</h3>
			<p class="text-2xl font-bold">${presentToday}</p>
		</div>
		<div class="bg-gradient-to-br from-red-500 to-red-700 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-shadow">
			<h3 class="text-sm font-medium opacity-90 mb-2">Absent Today</h3>
			<p class="text-2xl font-bold">${absentToday}</p>
		</div>
	</div>

	<div class="mt-6 bg-gradient-to-br from-teal-500 to-teal-700 rounded-xl p-6 text-white shadow-lg">
		<h3 class="text-lg font-semibold mb-4">Upcoming Holiday</h3>
		<ul class="space-y-2">
			<c:choose>
				<c:when test="${not empty holidays}">
					<c:forEach var="h" items="${holidays}">
						<li class="bg-white/20 rounded-lg px-4 py-3 font-medium">${h}</li>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<li class="bg-white/20 rounded-lg px-4 py-3">No upcoming holidays</li>
				</c:otherwise>
			</c:choose>
		</ul>
	</div>
</div>

<script>
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
</script>
</body>
</html>
