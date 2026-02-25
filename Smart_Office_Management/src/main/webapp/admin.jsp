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

/* ===== DARK MODE OVERRIDES ===== */

.dark-theme .top-bar {
    background: #1e1e1e;
}

.dark-theme .left-panel {
    background: #1e1e1e;
    color: white;
}

.dark-theme .right-panel {
    background: #121212;
}

.dark-theme #contentFrame {
    background: #1e1e1e;
}

.dark-theme .nav-btn {
    background: #374151;
}

.dark-theme .nav-btn:hover {
    background: #4b5563;
}

.dark-theme .logout-btn {
    background: #b91c1c;
}

.dark-theme .settings-panel {
    background: #1e1e1e;
}

</style>
</head>

<body>


	<div id="overlay" onclick="closeAll()"
		style="display: none; position: fixed; inset: 0; background: rgba(0, 0, 0, 0.4); z-index: 99;">
	</div>

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
				<input type="password" id="newPassword" placeholder="New Password">
				<input type="password" id="confirmPassword"
					placeholder="Confirm Password">
				<button onclick="submitPassword()">Update Password</button>
			</div>
		</div>
	</div>

	<!-- ===== SELF PROFILE MODAL ===== -->
	<div id="profileModal" class="password-modal">
		<div class="password-box" style="width: 600px; height: 450px;">
			<div class="password-header">
				<h4>My Profile</h4>
				<span class="close-btn" onclick="closeProfile()">✖</span>
			</div>

			<div style="height: 100%;">
				<iframe id="profileFrame" src=""
					style="width: 100%; height: 100%; border: none;"> </iframe>
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

			<button class="nav-btn" onclick="loadPage('adminOverview')">
				<i class="fa-solid fa-chart-pie"></i> Admin Overview
			</button>

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
			<button class="nav-btn" onclick="loadPage('sendNotification.jsp')">
				<i class="fa-solid fa-bullhorn"></i> Send Notification
			</button>

		</div>

		<!-- Content -->
		<div class="right-panel">
			<iframe id="contentFrame" src="adminOverview"></iframe>
		</div>

	</div>

	<!-- ===== JS ===== -->
	<script>
	function loadPage(page) {
	    const iframe = document.getElementById("contentFrame");
	    iframe.src = page;

	    iframe.onload = function () {

	        if (document.body.classList.contains("dark-theme")) {

	            const doc = iframe.contentDocument;
	            doc.body.classList.add("dark-theme");

	            const style = doc.createElement("style");

	            style.innerHTML = `
	            body.dark-theme {
	                background: #121212 !important;
	                color: #e5e5e5 !important;
	            }

	            body.dark-theme .page,
	            body.dark-theme .card,
	            body.dark-theme table {
	                background: #1e1e1e !important;
	                color: #e5e5e5 !important;
	            }

	            body.dark-theme h1,
	            body.dark-theme h2,
	            body.dark-theme h3,
	            body.dark-theme h4,
	            body.dark-theme p,
	            body.dark-theme span,
	            body.dark-theme label {
	                color: #ffffff !important;
	            }

	            body.dark-theme th {
	                background: #2c2c2c !important;
	                color: #ffffff !important;
	            }

	            body.dark-theme td {
	                color: #e5e5e5 !important;
	                border-bottom: 1px solid #444 !important;
	            }

	            body.dark-theme tr:hover {
	                background: #2a2a2a !important;
	            }

	            body.dark-theme input,
	            body.dark-theme select,
	            body.dark-theme textarea {
	                background: #2c2c2c !important;
	                color: #ffffff !important;
	                border: 1px solid #555 !important;
	            }

	            body.dark-theme a {
	                color: #60a5fa !important;
	            }

	            body.dark-theme .empty {
	                color: #9ca3af !important;
	            }
	            `;

	            doc.head.appendChild(style);
	        }
	    };
	}



		function openSettings() {
			document.getElementById("settingsPanel").style.right = "0";
			document.getElementById("overlay").style.display = "block";
		}

		function closeSettings() {
			document.getElementById("settingsPanel").style.right = "-320px";
			document.getElementById("overlay").style.display = "none";
		}

		function openProfile() {
			document.getElementById("profileFrame").src = "selfProfile";
			document.getElementById("profileModal").style.display = "block";
			document.getElementById("overlay").style.display = "block";
			closeSettings();
		}
		
		function closeProfile() {
			document.getElementById("profileModal").style.display = "none";
			document.getElementById("profileFrame").src = "";
			document.getElementById("overlay").style.display = "none";
		}

		function openChangePassword() {
			document.getElementById("passwordModal").style.display = "block";
			document.getElementById("overlay").style.display = "block";
		}

		function closeChangePassword() {
			document.getElementById("passwordModal").style.display = "none";
			document.getElementById("overlay").style.display = "none";
		}

		function toggleTheme() {

		    // Toggle main page
		    document.body.classList.toggle("dark-theme");

		    // Save theme state
		    const isDark = document.body.classList.contains("dark-theme");

		    const iframe = document.getElementById("contentFrame");

		    if (iframe && iframe.contentWindow) {

		        const applyTheme = function () {
		            if (isDark) {
		                iframe.contentDocument.body.classList.add("dark-theme");
		            } else {
		                iframe.contentDocument.body.classList.remove("dark-theme");
		            }
		        };

		        // Apply immediately if already loaded
		        if (iframe.contentDocument.readyState === "complete") {
		            applyTheme();
		        }

		        // Apply after every new load
		        iframe.onload = applyTheme;
		    }
		}

		function closeAll() {
			closeSettings();
			closeChangePassword();
			closeProfile();
		}

		function submitPassword() {
			const newPwd = document.getElementById("newPassword").value;
			const confirmPwd = document.getElementById("confirmPassword").value;

			if (!oldPwd || !newPwd || !confirmPwd) {
				alert("All fields are required");
				return;
			}

			if (newPwd !== confirmPwd) {
				alert("Passwords do not match");
				return;
			}

			alert("Password updated successfully (demo)");
			closeChangePassword();

			oldPassword.value = newPassword.value = confirmPassword.value = "";
		}
	</script>


</body>
</html>