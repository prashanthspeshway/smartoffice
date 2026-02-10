<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>

<!-- Font Awesome -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* ===== Base ===== */
<
div class ="form-group "> <label>Manager </label> <input type ="text " name
	="manager "
					value ="${manager
	
}

"
required> </div>body {
	margin: 0;
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f4f6f8;
}

/* ===== Top Bar ===== */
.top-bar {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 15px 30px;
	background: #1f2933;
	color: white;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 15px;
}

/* Settings Button */
.settings-btn {
	width: 36px;
	height: 36px;
	border-radius: 50%;
	background: #374151;
	border: none;
	color: white;
	font-size: 15px;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: 0.2s;
}

.settings-btn:hover {
	background: #4b5563;
	transform: rotate(20deg);
}

/* Logout Button */
.logout-btn {
	background: #ef4444;
	border: none;
	padding: 8px 16px;
	border-radius: 6px;
	color: white;
	cursor: pointer;
	font-size: 14px;
	transition: 0.2s;
}

.logout-btn:hover {
	background: #dc2626;
}

/* ===== Layout ===== */
.container {
	display: flex;
	height: calc(100vh - 64px);
}

/* ===== Sidebar ===== */
.left-panel {
	width: 240px;
	background: white;
	padding: 25px;
	box-shadow: 2px 0 8px rgba(0, 0, 0, 0.08);
}

.left-panel h3 {
	margin-bottom: 20px;
	color: #374151;
}

/* Sidebar Buttons */
.nav-btn {
	width: 100%;
	padding: 12px;
	margin-bottom: 12px;
	border: none;
	border-radius: 6px;
	background: #3b82f6;
	color: white;
	font-size: 14px;
	cursor: pointer;
	transition: 0.2s;
	display: flex;
	align-items: center;
	gap: 10px;
}

.nav-btn i {
	font-size: 15px;
}

.nav-btn:hover {
	background: #2563eb;
	transform: translateX(4px);
}

/* Export Button */
.export-btn {
	background: #10b981;
}

.export-btn:hover {
	background: #059669;
}

/* ===== Content Panel ===== */
.right-panel {
	flex: 1;
	padding: 25px;
}

/* iframe Loader */
#contentFrame {
	width: 100%;
	height: 100%;
	border: none;
	border-radius: 10px;
	background: white;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}
</style>
</head>

<body>

	<!-- ===== Top Bar ===== -->
	<div class="top-bar">
		<h2>Smart Office • Admin Dashboard</h2>

		<div class="user-area">
			<span> Welcome, <strong>${sessionScope.username}</strong>
			</span>

			<!-- Settings -->
			<button class="settings-btn" onclick="loadPage('adminSettings.jsp')"
				title="Settings">
				<i class="fa-solid fa-gear"></i>
			</button>

			<!-- Logout -->
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">
					<i class="fa-solid fa-right-from-bracket"></i> Logout
				</button>
			</a>
		</div>
	</div>

	<!-- ===== Main Layout ===== -->
	<div class="container">

		<!-- Sidebar -->
		<div class="left-panel">
		
			<button class="nav-btn" onclick="loadPage('AdminAttendance.jsp')">
			<i class="fa-solid fa-calendar-check"></i> Attendance
			</button>
		
			<button class="nav-btn" onclick="loadPage('addUser.jsp')">
				<i class="fa-solid fa-user-plus"></i> Add User
			</button>

			<button class="nav-btn" onclick="loadPage('viewUser')">
				<i class="fa-solid fa-users"></i> View Users
			</button>

			<button class="nav-btn" onclick="loadPage('toggleUserStatus.jsp')">
				<i class="fa-solid fa-user-lock"></i> Enable / Disable
			</button>

			<button class="nav-btn export-btn" onclick="loadPage('exportUsers')">
				<i class="fa-solid fa-file-export"></i> Export Users
			</button>

		</div>

		<!-- Content -->
		<div class="right-panel">
			<iframe id="contentFrame"></iframe>
		</div>

	</div>

	<!-- ===== JS ===== -->
	<script>
		function loadPage(page) {
			document.getElementById("contentFrame").src = page;
		}
	</script>

</body>
</html>
