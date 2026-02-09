<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manager Dashboard</title>

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
    max-width: 600px;
    background: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

/* ===== Task View ===== */
.task {
    background: #f9fafb;
    padding: 12px;
    margin-bottom: 10px;
    border-radius: 8px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.status {
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 13px;
    color: white;
}

.completed {
    background: #16a34a;
}

.incomplete {
    background: #dc2626;
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
    <h2>Smart Office • Manager Dashboard</h2>

    <div class="user-area">
        <span>Welcome, <b>${sessionScope.username}</b></span>

        <button class="icon-btn" onclick="openSettings()">
            <i class="fa-solid fa-gear"></i>
        </button>

        <a href="<%=request.getContextPath()%>/logout">
            <button class="logout-btn">Logout</button>
        </a>
    </div>
</div>

<!-- ===== Layout ===== -->
<div class="container">

    <!-- Sidebar -->
    <div class="left-panel">
        <button class="nav-btn" onclick="showSection('profile')">View Profile</button>
        <button class="nav-btn" onclick="showSection('assign')">Assign Tasks</button>
        <button class="nav-btn" onclick="showSection('viewTasks')">View Tasks</button>
        <button class="nav-btn" onclick="showSection('attendance')">Attendance Report</button>
        <button class="nav-btn" onclick="showSection('leave')">Leave Requests</button>
    </div>

    <!-- Content -->
    <div class="right-panel">

        <!-- Profile -->
        <div class="box" id="profile">
            <h3>Manager Profile</h3>
            <p>Name: ${sessionScope.username}</p>
            <p>Email: manager@company.com</p>
        </div>

        <!-- Assign Tasks -->
        <div class="box" id="assign" style="display:none;">
            <h3>Assign Tasks</h3>
            <input type="text" placeholder="Employee Name"><br><br>
            <input type="text" placeholder="Task Description"><br><br>
            <button style="background:#16a34a;color:white;padding:8px 14px;border:none;border-radius:6px;">
                Assign Task
            </button>
        </div>

        <!-- View Tasks (ADDED BELOW ASSIGN TASK) -->
        <div class="box" id="viewTasks" style="display:none;">
            <h3>View Tasks</h3>

            <div class="task">
                <div>
                    <b>Employee:</b> Employee A<br>
                    <b>Task:</b> Prepare monthly report
                </div>
                <span class="status completed">Completed</span>
            </div>

            <div class="task">
                <div>
                    <b>Employee:</b> Employee B<br>
                    <b>Task:</b> Update client data
                </div>
                <span class="status incomplete">Incomplete</span>
            </div>

        </div>

        <!-- Attendance -->
        <div class="box" id="attendance" style="display:none;">
            <h3>Attendance Report</h3>
            <p>✔ Employee A - Present</p>
            <p>❌ Employee B - Absent</p>
        </div>

        <!-- Leave -->
        <div class="box" id="leave" style="display:none;">
            <h3>Leave Requests</h3>
            <p>Employee A - Sick Leave</p>
            <button style="background:#16a34a;color:white;">Approve</button>
            <button style="background:#dc2626;color:white;">Reject</button>
        </div>

    </div>
</div>

<!-- ===== Settings Popup ===== -->
<div class="popup" id="settingsPopup">
    <div class="popup-content">

        <div id="settingsMenu">
            <h3>Settings</h3>
            <button style="width:95%;background:#2563eb;color:white;padding:5px;border:none;"
                    onclick="openChangePassword()">
                Change Password
            </button>

            <button onclick="closeSettings()"
                    style="width:95%;margin-top:8px;background:#6b7280;color:white;padding:5px;border:none;">
                Close
            </button>
        </div>

        <div id="changePasswordForm" style="display:none;padding:6px;">
            <h3>Change Password</h3>
            <input type="password" placeholder="Old Password">
            <input type="password" placeholder="New Password">
            <input type="password" placeholder="Confirm Password">

            <button style="width:95%;background:#16a34a;color:white;padding:5px;">
                Update Password
            </button>

            <button onclick="backToSettings()"
                    style="width:95%;margin-top:8px;background:#6b7280;color:white;padding:5px;">
                Back
            </button>
        </div>

    </div>
</div>

<script>
function showSection(id) {
    document.querySelectorAll('.box').forEach(b => b.style.display = 'none');
    document.getElementById(id).style.display = 'block';
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
