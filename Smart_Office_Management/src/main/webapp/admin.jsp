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
div

 

class

 

="
form-group

 

">
<
label
>
Manager

 

</
label
>
<
input

 

type

 

="
text

 

"
name


	

="
manager

 

"
value

 

="${
manager


	


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
	width: 96.5%;
	margin-top: -7px;
	margin-left: -7.7px;
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

/* ================= SETTINGS ICON ================= */
.settings-icon {
	position: absolute;
	top: 20px;
	left: 20px;
	font-size: 26px;
	cursor: pointer;
	background: #ffffff;
	padding: 10px;
	border-radius: 50%;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
	z-index: 101;
}

/* ================= SETTINGS PANEL ================= */
.settings-panel {
	position: fixed;
	top: 0;
	right: -320px;
	width: 300px;
	height: 100%;
	background: #f9f9f9;
	box-shadow: -4px 0 10px rgba(0, 0, 0, 0.3);
	transition: right 0.3s ease;
	z-index: 100;
}

.settings-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 15px;
	background: #2c3e50;
	color: white;
}

.close-btn {
	cursor: pointer;
	font-size: 18px;
}

.settings-list {
	list-style: none;
	padding: 0;
	margin: 0;
}

.settings-list li {
	padding: 15px;
	cursor: pointer;
	border-bottom: 1px solid #ddd;
}

.settings-list li:hover {
	background: #eaeaea;
}

/* ================= CHANGE PASSWORD MODAL ================= */
.password-modal {
	display: none;
	position: fixed;
	inset: 0;
	z-index: 200;
}

.password-box {
	width: 350px;
	background: #fff;
	margin: 10% auto;
	border-radius: 6px;
	overflow: hidden;
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
}

.password-header {
	background: #34495e;
	color: white;
	padding: 12px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.password-body {
	padding: 20px;
}

.password-body input {
	width: 100%;
	padding: 10px;
	margin-bottom: 12px;
	border: 1px solid #ccc;
	border-radius: 4px;
}

.password-body button {
	width: 100%;
	padding: 10px;
	background: #2ecc71;
	border: none;
	color: white;
	font-size: 15px;
	cursor: pointer;
	border-radius: 4px;
}

.password-body button:hover {
	background: #27ae60;
}

/* ================= DARK THEME ================= */
.dark-theme {
	background: #121212;
	color: white;
}

.dark-theme .settings-panel {
	background: #1e1e1e;
}

.dark-theme .password-box {
	background: #1e1e1e;
	color: white;
}

.dark-theme input {
	background: #2c2c2c;
	color: white;
	border: 1px solid #555;
}
</style>
</head>

<body>

	<!-- SETTINGS PANEL -->
	<div id="settingsPanel" class="settings-panel">
		<div class="settings-header">
			<h3>Settings</h3>
			<span class="close-btn" onclick="closeSettings()">✖</span>
		</div>

		<ul class="settings-list">
			<li onclick="openProfile()">👤 Self Profile</li>
			<li onclick="openChangePassword()">🔐 Change Password</li>
			<li onclick="toggleTheme()">🌗 Theme</li>
		</ul>
	</div>


	<!-- CHANGE PASSWORD MODAL -->
	<div id="passwordModal" class="password-modal">
		<div class="password-box">
			<div class="password-header">
				<h4>Change Password</h4>
				<span class="close-btn" onclick="closeChangePassword()">✖</span>
			</div>

			<div class="password-body">
				<input type="password" id="oldPassword" placeholder="Old Password">
				<input type="password" id="newPassword" placeholder="New Password">
				<input type="password" id="confirmPassword"
					placeholder="Confirm Password">
				<button onclick="submitPassword()">Update Password</button>
			</div>
		</div>
	</div>

	<!-- ===== Top Bar ===== -->
	<div class="top-bar">
		<h2>Smart Office • Admin Dashboard</h2>

		<div class="user-area">
			<span> Welcome, <strong>${sessionScope.username}</strong>
			</span>

			<!-- Settings -->
			<button class="settings-btn" onclick="openSettings()"
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

			<button class="nav-btn" onclick="loadPage('addUser')">
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
			<button class="nav-btn" onclick="loadPage('calendar.jsp')">
				<i class="fa-solid fa-calendar-days"></i> Calendar
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

	<script>
		function openSettings() {

			document.getElementById("settingsPanel").style.right = "0";

			document.getElementById("overlay").style.display = "block";

		}

		function closeSettings() {

			document.getElementById("settingsPanel").style.right = "-320px";

		}

		function openChangePassword() {

			document.getElementById("passwordModal").style.display = "block";

			document.getElementById("overlay").style.display = "block";

		}

		function closeChangePassword() {

			document.getElementById("passwordModal").style.display = "none";

		}

		function toggleTheme() {

			document.body.classList.toggle("dark-theme");

		}

		function closeAll() {

			closeSettings();

			closeChangePassword();

			document.getElementById("overlay").style.display = "none";

		}
	</script>


</body>
</html>