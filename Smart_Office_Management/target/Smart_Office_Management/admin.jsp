<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	
	<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

String email = (String) session.getAttribute("email");
String role = (String) session.getAttribute("role");
String phone = (String) session.getAttribute("phone");

%>
	
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

/* Notification button */
.settings-btn {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	border: none;
	background: linear-gradient(135deg, #667eea, #764ba2);
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
	display: flex;
	flex-direction: column;
}

.sidebar-nav {
	flex: 1;
}

.sidebar-bottom {
	margin-top: auto;
	padding-top: 12px;
	border-top: 1px solid rgba(255, 255, 255, 0.3);
}

.sidebar-bottom .sidebar-btn {
	margin-bottom: 8px;
}

.sidebar-bottom .logout-link {
	display: flex;
	align-items: center;
	gap: 10px;
	width: 100%;
	padding: 12px 14px;
	border: none;
	background: transparent;
	border-radius: 8px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	color: #e53e3e;
	text-decoration: none;
	transition: 0.25s;
}

.sidebar-bottom .logout-link:hover {
	background: rgba(229, 62, 62, 0.15);
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
	padding:25px;
	background: #c3cfe2;
}

#contentFrame {
	width: 100%;
	height: 100%;
	border: none;
	/*     border-radius:15px; */
	background: #c3cfe2;
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
@keyframes modalFade {from { opacity:0;
	transform: scale(0.95);
}

to {
	opacity: 1;
	transform: scale(1);
}

}
@keyframes slideIn {from { opacity:0;
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

	<!-- TOP BAR -->
	<div class="top-bar">
		<h2>Smart Office • Admin Dashboard</h2>
		<div class="user-area">
			<button class="settings-btn" onclick="loadPage(this,'sendNotification.jsp')">
				<i class="fa-solid fa-bell"></i>
			</button>
			<span class="welcome">Welcome, <strong>${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></span>
		</div>
	</div>

	<!-- MAIN -->
	<div class="main-container">
		<div class="sidebar">
			<div class="sidebar-nav">
				<button class="sidebar-btn active" onclick="loadPage(this,'adminOverview')">
					<i class="fa-solid fa-chart-line"></i> <span>Admin Overview</span>
				</button>

				<button class="sidebar-btn" onclick="loadPage(this,'addUser')">
					<i class="fa-solid fa-user-plus"></i> <span>Add Employee</span>
				</button>

				<button class="sidebar-btn" onclick="loadPage(this,'viewUser')">
					<i class="fa-solid fa-users"></i> <span>View Employees</span>
				</button>

				<button class="sidebar-btn" onclick="loadPage(this,'teams')">
					<i class="fa-solid fa-people-group"></i> <span>Teams</span>
				</button>

				<button class="sidebar-btn" onclick="loadPage(this,'calendar.jsp')">
					<i class="fa-solid fa-calendar-days"></i> <span>Calendar</span>
				</button>
				<button class="sidebar-btn" onclick="exportUsers()">
					<i class="fa-solid fa-file-export"></i> <span>Export Employees</span>
				</button>
			</div>

			<div class="sidebar-bottom">
				<button class="sidebar-btn" onclick="loadPage(this,'adminSettingsPage.jsp')">
					<i class="fa-solid fa-gear"></i> <span>Settings</span>
				</button>
				<a href="<%=request.getContextPath()%>/logout" class="logout-link">
					<i class="fa-solid fa-right-to-bracket"></i> <span>Logout</span>
				</a>
			</div>
		</div>

		<div class="content-area" id="contentArea">
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

    const error = params.get("error");
    if (error === "accessDenied") {
        showToast("Access denied. You do not have permission for that page.", "error");
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

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;

</script>

</body>
</html>