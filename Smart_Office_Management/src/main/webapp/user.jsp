<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6f8;
}

/* ===== Top Bar ===== */
.top-bar {
    display: flex;
    align-items: center;
    padding: 15px 30px;
    background: #1f2933;
    color: white;
}

.user-area {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-left: auto;
}

.icon-btn {
    background: transparent;
    border: none;
    color: white;
    font-size: 18px;
    cursor: pointer;
}

.logout-btn {
    background: #ef4444;
    border: none;
    padding: 8px 16px;
    border-radius: 6px;
    color: white;
    cursor: pointer;
}

/* ===== Layout ===== */
.container {
    display: flex;
    height: calc(100vh - 60px);
}

/* ===== Sidebar ===== */
.left-panel {
    width: 240px;
    background: white;
    padding: 25px;
    box-shadow: 2px 0 8px rgba(0,0,0,0.08);
}

.nav-btn {
    width: 100%;
    padding: 12px;
    margin-bottom: 12px;
    border: none;
    border-radius: 6px;
    background: #3b82f6;
    color: white;
    cursor: pointer;
    font-size: 15px;
}

/* ===== Content ===== */
.right-panel {
    flex: 1;
    padding: 25px;
}

/* Box */
.box {
    max-width: 420px;
    background: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

button {
    padding: 8px 14px;
    border-radius: 6px;
    background:red;
    border: none;
    color: white;
    cursor: pointer;
}

#punchInBtn { background: #16a34a; }
#punchOutBtn { background: #dc2626; }

/* Tasks */
.task {
    background: #f1f5f9;
    padding: 8px;
    border-radius: 6px;
    margin-bottom: 8px;
    display: flex;
    justify-content: space-between;
}

.task.completed {
    text-decoration: line-through;
    color: green;
}

/* ===== Settings Popup ===== */
.popup {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.4);
}

.popup-content {
    background: white;
    width: 400px;
    padding: 20px;
    border-radius: 10px;
    margin: 12% auto;
}

.popup-content input {
    width: 90%;
    padding: 10px;
    margin-bottom: 10px;
}
</style>
</head>

<body>

<!-- ===== Top Bar ===== -->
<div class="top-bar">
    <h2>Smart Office • User DashBoard</h2>

    <div class="user-area">
        <span>Welcome, <b>${sessionScope.username}</b></span>

        <!-- Settings -->
        <button class="icon-btn" onclick="openSettings()">
            <i class="fa-solid fa-gear"></i>
        </button>

        <!-- Logout -->
        <a href="<%=request.getContextPath()%>/logout">
            <button class="logout-btn">Logout</button>
        </a>
    </div>
</div>

<!-- ===== Layout ===== -->
<div class="container">

    <!-- Sidebar -->
    <div class="left-panel">
        <button class="nav-btn" onclick="showAttendance()">Attendance</button>
        <button class="nav-btn" onclick="showTasks()">Tasks</button>
    </div>

    <!-- Content -->
    <div class="right-panel">

        <!-- Attendance -->
        <div class="box" id="attendanceSection">
            <h3>Attendance</h3>
            <p>Status: <b id="status">Not Punched In</b></p>
            <p id="time"></p>

            <button id="punchInBtn" onclick="punchIn()">Punch In</button>
            <button id="punchOutBtn" onclick="punchOut()" disabled>Punch Out</button>
        </div>

        <!-- Tasks -->
        <div class="box" id="taskSection" style="display:none;">
            <h3>Tasks</h3>

            <h4>Incomplete Tasks</h4>
            <div class="task">
                <span>Prepare report</span>
                <button onclick="completeTask(this)">Done</button>
            </div>

            <div class="task">
                <span>Client meeting</span>
                <button onclick="completeTask(this)">Done</button>
            </div>

            <h4 style="margin-top:15px;">Completed Tasks</h4>
            <div id="completedTasks"></div>
        </div>

    </div>
</div>

<!-- ===== Settings Popup ===== -->
<div class="popup" id="settingsPopup">
    <div class="popup-content">

        <!-- Settings Menu -->
        <div id="settingsMenu">
            <h3>Settings</h3>
            <button style="width:95%;background:#2563eb;"
                    onclick="openChangePassword()">
                Change Password
            </button>

            <button onclick="closeSettings()"
                    style="width:95%;margin-top:8px;background:#6b7280;">
                Close
            </button>
        </div>

        <!-- Change Password Form -->
        <div id="changePasswordForm" style="display:none;">
            <h3>Change Password</h3>

            <input type="password" placeholder="Old Password">
            <input type="password" placeholder="New Password">
            <input type="password" placeholder="Confirm Password">

            <button style="width:95%;background:#16a34a;">
                Update Password
            </button>

            <button onclick="backToSettings()"
                    style="width:95%;margin-top:8px;background:#6b7280;">
                Back
            </button>
        </div>

    </div>
</div>

<script>
function showAttendance() {
    document.getElementById("attendanceSection").style.display = "block";
    document.getElementById("taskSection").style.display = "none";
}

function showTasks() {
    document.getElementById("attendanceSection").style.display = "none";
    document.getElementById("taskSection").style.display = "block";
}

function punchIn() {
    document.getElementById("status").innerText = "Punched In";
    document.getElementById("time").innerText = new Date().toLocaleTimeString();
    document.getElementById("punchInBtn").disabled = true;
    document.getElementById("punchOutBtn").disabled = false;
}

function punchOut() {
    document.getElementById("status").innerText = "Punched Out";
    document.getElementById("time").innerText = new Date().toLocaleTimeString();
}

function completeTask(btn) {
    const taskDiv = btn.parentElement;
    btn.remove();
    taskDiv.classList.add("completed");
    document.getElementById("completedTasks").appendChild(taskDiv);
}

function openSettings() {
    document.getElementById("settingsPopup").style.display = "block";
    document.getElementById("settingsMenu").style.display = "block";
    document.getElementById("changePasswordForm").style.display = "none";
}

function closeSettings() {
    document.getElementById("settingsPopup").style.display = "none";
}

function openChangePassword() {
    document.getElementById("settingsMenu").style.display = "none";
    document.getElementById("changePasswordForm").style.display = "block";
}

function backToSettings() {
    document.getElementById("changePasswordForm").style.display = "none";
    document.getElementById("settingsMenu").style.display = "block";
}
</script>

</body>
</html>
