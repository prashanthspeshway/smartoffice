<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard • Smart Office</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>

/* ================= GLOBAL ================= */
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
	height: 100vh;
	display: flex;
	flex-direction: column;
	background: linear-gradient(135deg, #c3cfe2 0%, #e2ebf0 100%);
	overflow: hidden;
}

/* ================= TOP BAR ================= */
.top-bar {
	backdrop-filter: blur(10px);
	background: rgba(255, 255, 255, 0.25);
	border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	padding: 15px 30px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.top-bar h2 {
	font-size: 22px;
	font-weight: 600;
	color: #2d3748;
}

.user-area {
	display: flex;
	align-items: center;
	gap: 15px;
}

.welcome {
	font-size: 14px;
}

/* Buttons */
.settings-btn {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
	color: white;
	cursor: pointer;
}

.logout-btn {
	padding: 8px 14px;
	border-radius: 8px;
	border: none;
	background: #e53e3e;
	color: white;
	cursor: pointer;
}

/* ================= LAYOUT ================= */
.main-container {
	flex: 1;
	display: flex;
}

/* ================= SIDEBAR ================= */
.sidebar {
	width: 250px;
	backdrop-filter: blur(10px);
	background: rgba(255, 255, 255, 0.2);
	border-right: 1px solid rgba(255, 255, 255, 0.3);
	padding: 18px 12px;
}

/* NORMAL BUTTON (NO BG) */
.sidebar-btn {
	width: 100%;
	padding: 12px 14px;
	margin-bottom: 10px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 10px;
	color: #2d3748;
	transition: 0.25s;
}

/* HOVER */
.sidebar-btn:hover {
	background: rgba(102, 126, 234);
	color: white;
	font-size: 15px;
}

/* ACTIVE */
.sidebar-btn.active {
	background: linear-gradient(135deg, #e7e6eb);
	color: black;
	box-shadow: 0 6px 15px rgba(102, 126, 234, 0.4);
	position: relative;
	font-size: 15px;
}

.sidebar-btn.active::before {
	content: "";
	position: absolute;
	left: 0;
	top: 10%;
	width: 4px;
	height: 80%;
	background: white;
	border-radius: 2px;
}

/* ================= CONTENT ================= */
.content-area {
	flex: 1;
	/*     padding:25px; */
	background: #fffafa;
}

#contentFrame {
	width: 100%;
	height: 100%;
	border: none;
	/*     border-radius:15px; */
	background: rgb(255, 255, 255, 0);
	/*      backdrop-filter:blur(10px); */
}

/* ================= MODALS ================= */
/* ===== Modal Overlay ===== */
.modal {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.45);
	backdrop-filter: blur(6px);
	display: none;
	align-items: center;
	justify-content: center;
	z-index: 2000;
}

/* Show Modal */
.modal.show {
	display: flex;
}

/* ===== Modal Box ===== */
.modal-content {
	width: 50%;
	max-width: 700px;
	height: 500px;
	background: #ffffff;
	border-radius: 14px;
	box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25);
	display: flex;
	flex-direction: column;
	overflow: hidden;
	animation: modalFade 0.35s ease;
}

/* ===== Header ===== */
.modal-header {
	height: 70px;
	padding: 0 20px;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.modal-header h4 {
	margin: 0;
	font-size: 18px;
	font-weight: 600;
}

/* Close Button */
.modal-close {
	font-size: 22px;
	cursor: pointer;
	transition: transform 0.2s, opacity 0.2s;
}

.modal-close:hover {
	transform: scale(1.15);
	opacity: 0.8;
}

/* ===== Iframe ===== */
#profileFrame {
	flex: 1;
	width: 100%;
	border: none;
	background: #f9fafb;
}
/* ===== Password Modal Form Styling ONLY ===== */
#passwordModal .modal-body {
	padding: 30px 25px;
	display: flex;
	flex-direction: column;
	align-items: center;
}

/* Inputs */
#passwordModal input[type="password"] {
	width: 100%;
	/*     max-width: 320px; */
	padding: 12px 14px;
	font-size: 15px;
	border-radius: 8px;
	border: 1px solid #cbd5e1;
	outline: none;
	transition: border 0.3s, box-shadow 0.3s;
}

/* Input Focus */
#passwordModal input[type="password"]:focus {
	border-color: #6366f1;
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
}

/* Button */
#passwordModal button {
	width: 100%;
	/*     max-width: 320px; */
	margin-top: 10px;
	padding: 12px;
	font-size: 15px;
	font-weight: 600;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #ffffff;
	transition: transform 0.2s, box-shadow 0.2s;
}

/* Button Hover */
#passwordModal button:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(99, 102, 241, 0.35);
}

/* Button Active */
#passwordModal button:active {
	transform: scale(0.97);
}

/* Mobile Friendly */
@media ( max-width : 480px) {
	#passwordModal input[type="password"], #passwordModal button {
		max-width: 100%;
	}
}

/* ===== Animation ===== */
@
keyframes modalFade {from { opacity:0;
	transform: scale(0.95);
}

to {
	opacity: 1;
	transform: scale(1);
}

}
@
keyframes slideIn {from { opacity:0;
	transform: translateX(40px);
}

to {
	opacity: 1;
	transform: translateX(0);
}

}

/* ===== Responsive ===== */
@media ( max-width : 768px) {
	.modal-content {
		width: 95%;
		height: 90%;
	}
} /* ================= SETTINGS DRAWER ================= */
/* ===== Settings Drawer ===== */
.settings-drawer {
	position: fixed;
	top: 0;
	right: -340px;
	width: 340px;
	height: 100%;
	background: linear-gradient(135deg, rgba(255, 255, 255, 0.85),
		rgba(240, 245, 255, 0.75));
	backdrop-filter: blur(16px);
	box-shadow: -8px 0 25px rgba(0, 0, 0, 0.15);
	transition: right 0.4s ease, opacity 0.3s ease;
	z-index: 1000;
	border-left: 1px solid rgba(255, 255, 255, 0.4);
}

/* Open State */
.settings-drawer.open {
	right: 0;
}

/* Header */
.settings-header {
	padding: 20px;
	font-size: 18px;
	height: 100px;
	font-weight: 600;
	color: #2d3748;
	border-bottom: 1px solid rgba(0, 0, 0, 0.08);
	display: flex;
	justify-content: space-between;
	align-items: center;
}

/* Close Button */
.settings-close {
	cursor: pointer;
	font-size: 20px;
	color: #718096;
	transition: color 0.3s;
}

.settings-close:hover {
	color: #e53e3e;
}

/* Items Container */
.settings-list {
	padding: 10px 0;
}

/* Individual Item */
.settings-item {
	padding: 14px 22px;
	margin: 6px 12px;
	border-radius: 10px;
	cursor: pointer;
	font-size: 15px;
	font-weight: 500;
	color: #2d3748;
	display: flex;
	align-items: center;
	gap: 12px;
	transition: background 0.3s, transform 0.2s, box-shadow 0.2s;
}

/* Hover Effect */
.settings-item:hover {
	background: rgba(99, 102, 241, 0.12);
	transform: translateX(4px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* Icon Styling (Font Awesome) */
.settings-item i {
	font-size: 18px;
	color: #6366f1;
}

/* Active Item */
.settings-item.active {
	background: linear-gradient(135deg, #6366f1, #818cf8);
	color: #fff;
}

.settings-item.active i {
	color: #fff;
}

/* ================= TOAST ================= */
.toast {
    position: fixed;
    top: 90px;
    right: 15px;
    background: #e2ebf0;
    color: black;
    padding: 14px 20px 14px 44px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    display: none;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
    z-index: 3000;
    line-height: 1.4;
}

.toast.show {
    animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}

.toast.hide {
    animation: toastOut 0.4s ease forwards;
}

.toast::before {
    content: "✔";
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 16px;
    font-weight: bold;
}

/* SUCCESS */
.toast.success::before {
    content: "✔";
}

/* ERROR */
.toast.error::before {
    content: "✖";
}

/* INFO */
.toast.info::before {
    content: "✔";
}

@keyframes toastIn {
    from {
        opacity: 0;
        transform: translateX(120px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes toastOut {
    from {
        opacity: 1;
        transform: translateX(0);
    }
    to {
        opacity: 0;
        transform: translateX(120px);
    }
}


</style>
</head>

<body>

	<div id="overlay" onclick="closeAll()"></div>

	<!-- SETTINGS -->
	<div id="settingsPanel" class="settings-drawer">
		<div class="modal-header">
			<h4>Settings</h4>
			<span onclick="closeSettings()" style="cursor: pointer;">✕</span>
		</div>
		<div class="settings-item" onclick="openProfile()">My Profile</div>
		<div class="settings-item" onclick="openChangePassword()">Change
			Password</div>
	</div>

	<!-- PASSWORD MODAL -->
	<div id="passwordModal" class="modal">
		<div class="modal-content" style="text-align: center;">
			<div class="modal-header">
				<h4>Change Password</h4>
				<span onclick="closeChangePassword()" style="cursor: pointer;">✕</span>
			</div>
			<div class="modal-body">
				<input type="password" id="newPassword" placeholder="New Password"><br>
				<br> <input type="password" id="confirmPassword"
					placeholder="Confirm Password"><br> <br>

				<button onclick="submitPassword()">Update</button>
			</div>
		</div>
	</div>

	<!-- PROFILE MODAL -->
	<div id="profileModal" class="modal">
		<div class="modal-content">
			<div class="modal-header">
				<h4>My Profile</h4>
				<span class="modal-close" onclick="closeProfile()"
					style="cursor: pointer;">✕</span>
			</div>
			<iframe id="profileFrame"></iframe>
		</div>
	</div>

	<!-- TOP BAR -->
	<div class="top-bar">
		<h2>Smart Office • Admin Dashboard</h2>
		<div class="user-area">
			<span class="welcome">Welcome, <strong>${sessionScope.username}</strong></span>
			<button class="settings-btn" onclick="openSettings()">
				<i class="fa fa-gear"></i>
			</button>
			<a href="<%=request.getContextPath()%>/logout">
				<button class="logout-btn">Logout <i class="fa-solid fa-right-to-bracket"></i></button>
			</a>
		</div>
	</div>

	<!-- MAIN -->
	<div class="main-container">
		<div class="sidebar">
			<button class="sidebar-btn active"
				onclick="loadPage(this,'adminOverview')">
				<i class="fa-solid fa-chart-line"></i> <span>Admin Overview</span>
			</button>

			<button class="sidebar-btn" onclick="loadPage(this,'addUser')">
				<i class="fa-solid fa-user-plus"></i> <span>Add Employee</span>
			</button>

			<button class="sidebar-btn" onclick="loadPage(this,'viewUser')">
				<i class="fa-solid fa-users"></i> <span>View Employees</span>
			</button>

			<button class="sidebar-btn"
				onclick="loadPage(this,'toggleUserStatus.jsp')">
				<i class="fa-solid fa-user-gear"></i> <span>Manage Status</span>
			</button>

			<button class="sidebar-btn" onclick="loadPage(this,'calendar.jsp')">
				<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
			</button>

			<button class="sidebar-btn"
				onclick="loadPage(this,'sendNotification.jsp')">
				<i class="fa-solid fa-bell"></i> <span>Send Notifications</span>
			</button>

			<button class="sidebar-btn" onclick="exportUsers()">
				<i class="fa-solid fa-file-export"></i> <span>Export
					Employees</span>
			</button>
		</div>

		<div class="content-area">
			<iframe id="contentFrame" src="adminOverview"></iframe>
		</div>
	</div>

	<div id="toast" class="toast"></div>

	<script>

/* LOAD PAGE + ACTIVE BUTTON */
function loadPage(btn,page){
    document.getElementById("contentFrame").src = page;

    document.querySelectorAll(".sidebar-btn").forEach(b=>{
        b.classList.remove("active");
    });

    btn.classList.add("active");
}

/* EXISTING FUNCTIONS */
function openSettings(){document.getElementById("settingsPanel").classList.add("open");}
function closeSettings(){document.getElementById("settingsPanel").classList.remove("open");}
function openProfile(){
    document.getElementById("profileFrame").src="selfProfile";
    document.getElementById("profileModal").style.display="flex";
}
function closeProfile(){document.getElementById("profileModal").style.display="none";}
function openChangePassword(){document.getElementById("passwordModal").style.display="flex";}
function closeChangePassword(){document.getElementById("passwordModal").style.display="none";}
function closeAll(){closeSettings();closeProfile();closeChangePassword();}
function submitPassword() {
    const newPassword = document.getElementById("newPassword").value.trim();
    const confirmPassword = document.getElementById("confirmPassword").value.trim();

    if (!newPassword || !confirmPassword) {
        showToast("Please fill all fields");
        return;
    }

    fetch("<%=request.getContextPath()%>/changePassword", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: new URLSearchParams({
            newPassword: newPassword,
            confirmPassword: confirmPassword
        })
    })
    .then(res => res.text())
    .then(data => {
        if (data === "Success") {
        	showToast("Password updated successfully", "success");
            closeChangePassword();
            document.getElementById("newPassword").value = "";
            document.getElementById("confirmPassword").value = "";
        } 
        else if (data === "PasswordMismatch") {
        	showToast("Passwords do not match", "error");
        } 
        else if (data === "MissingFields") {
        	showToast("Please fill all fields", "warning");
        } 
        else {
            showToast("Something went wrong");
        }
    })
    .catch(err => {
        console.error(err);
        showToast("Server error");
    });
}
function exportUsers(){document.getElementById("contentFrame").src="exportUsers";}


/* ===== LOGIN SUCCESS TOAST ===== */
document.addEventListener("DOMContentLoaded", function () {

    const params = new URLSearchParams(window.location.search);
    const success = params.get("success");

    if (success === "Login") {
    	showToast("Logged-In Successfully", "info");
        
        // remove ?success=Login from URL
        window.history.replaceState(
            {},
            document.title,
            window.location.pathname
        );
    }
});

function showToast(message, type = "success") {
    const toast = document.getElementById("toast");

    toast.style.display = "none";
    toast.className = "toast";
    toast.offsetHeight; // force reflow

    toast.classList.add(type);
    toast.textContent = message;
    toast.style.display = "block";

    toast.classList.add("show");

    setTimeout(() => {
        toast.classList.remove("show");
        toast.classList.add("hide");

        setTimeout(() => {
            toast.style.display = "none";
            toast.className = "toast";
        }, 400);
    }, 2500);
}

</script>

</body>
</html>