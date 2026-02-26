<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body{
    height:100vh;
    display:flex;
    flex-direction:column;
    background: linear-gradient(135deg, #c3cfe2 0%, #e2ebf0 100%);
    overflow:hidden;
}

/* ================= TOP BAR ================= */
.top-bar{
    backdrop-filter: blur(10px);
    background: rgba(255,255,255,0.25);
    border-bottom:1px solid rgba(255,255,255,0.3);
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.top-bar h2{
    font-size:22px;
    font-weight:600;
    color:#2d3748;
}

.user-area{
    display:flex;
    align-items:center;
    gap:15px;
}

.welcome{
    font-size:14px;
}

/* Buttons */
.settings-btn{
    width:38px;
    height:38px;
    border-radius:50%;
    border:none;
    background: linear-gradient(135deg,#667eea,#764ba2);
    color:white;
    cursor:pointer;
}

.logout-btn{
    padding:8px 14px;
    border-radius:8px;
    border:none;
    background:#e53e3e;
    color:white;
    cursor:pointer;
}

/* ================= LAYOUT ================= */
.main-container{
    flex:1;
    display:flex;
}

/* ================= SIDEBAR ================= */
.sidebar{
    width:250px;
    backdrop-filter: blur(10px);
    background: rgba(255,255,255,0.2);
    border-right:1px solid rgba(255,255,255,0.3);
    padding:18px 12px;
}

/* NORMAL BUTTON (NO BG) */
.sidebar-btn{
    width:100%;
    padding:12px 14px;
    margin-bottom:10px;
    border:none;
    background:transparent;
    border-radius:8px;
    cursor:pointer;
    font-size:14px;
    font-weight:500;
    display:flex;
    align-items:center;
    gap:10px;
    color:#2d3748;
    transition:0.25s;
}

/* HOVER */
.sidebar-btn:hover{
    background:rgba(102,126,234);
    color:white;
    font-size:15px;
}

/* ACTIVE */
.sidebar-btn.active{
    background: linear-gradient(135deg,#e7e6eb);
    color:black;
    box-shadow:0 6px 15px rgba(102,126,234,0.4);
    position:relative;
    font-size:15px;
}

.sidebar-btn.active::before{
    content:"";
    position:absolute;
    left:0;
    top:10%;
    width:4px;
    height:80%;
    background:white;
    border-radius:2px;
}

/* ================= CONTENT ================= */
.content-area{
     flex:1; 
/*     padding:25px; */
    background:#fffafa;
}

#contentFrame{
    width:100%;
    height:100%;
    border:none;
/*     border-radius:15px; */
    background:rgb(255,255,255,0);
/*     backdrop-filter:blur(10px); */
}

/* ================= MODALS ================= */
.modal{
    display:none;
    position:fixed;
    inset:0;
/*     background:rgba(0,0,0,0.4); */
/*     backdrop-filter:blur(4px); */
    align-items:center;
    justify-content:center;
}

.modal-content{
    background:white;
    border-radius:12px;
    width:90%;
    max-width:420px;
}

.modal-header{
    padding:14px;
    background:linear-gradient(135deg,#667eea,#764ba2);
    color:white;
    display:flex;
    justify-content:space-between;
}

.modal-body{
    padding:20px;
}

/* ================= SETTINGS DRAWER ================= */
.settings-drawer{
    position:fixed;
    top:0;
    right:-320px;
    width:320px;
    height:100%;
    background:rgba(255,255,255,0.35);
    backdrop-filter:blur(10px);
    transition:0.35s;
}

.settings-drawer.open{
    right:0;
}

.settings-item{
    padding:15px 20px;
    cursor:pointer;
}

</style>
</head>

<body>

<div id="overlay" onclick="closeAll()"></div>

<!-- SETTINGS -->
<div id="settingsPanel" class="settings-drawer">
    <div class="modal-header">
        <h4>Settings</h4>
        <span onclick="closeSettings()">✕</span>
    </div>
    <div class="settings-item" onclick="openProfile()">My Profile</div>
    <div class="settings-item" onclick="openChangePassword()">Change Password</div>
</div>

<!-- PASSWORD MODAL -->
<div id="passwordModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h4>Change Password</h4>
            <span onclick="closeChangePassword()">✕</span>
        </div>
        <div class="modal-body">
            <input type="password" placeholder="New Password"><br><br>
            <button onclick="submitPassword()">Update</button>
        </div>
    </div>
</div>

<!-- PROFILE MODAL -->
<div id="profileModal" class="modal">
    <div class="modal-content" style="height:500px;">
        <div class="modal-header">
            <h4>My Profile</h4>
            <span onclick="closeProfile()">✕</span>
        </div>
        <iframe id="profileFrame" style="width:100%; height:100%; border:none;"></iframe>
    </div>
</div>

<!-- TOP BAR -->
<div class="top-bar">
    <h2>Smart Office • Admin Dashboard</h2>
    <div class="user-area">
        <span class="welcome">Welcome, <strong>${sessionScope.username}</strong></span>
        <button class="settings-btn" onclick="openSettings()"><i class="fa fa-gear"></i></button>
        <a href="<%=request.getContextPath()%>/logout">
            <button class="logout-btn">Logout</button>
        </a>
    </div>
</div>

<!-- MAIN -->
<div class="main-container">
   <div class="sidebar">
    <button class="sidebar-btn active" onclick="loadPage(this,'adminOverview')">
        <i class="fa-solid fa-chart-line"></i>
        <span>Admin Overview</span>
    </button>

    <button class="sidebar-btn" onclick="loadPage(this,'addUser')">
        <i class="fa-solid fa-user-plus"></i>
        <span>Add Employee</span>
    </button>

    <button class="sidebar-btn" onclick="loadPage(this,'viewUser')">
        <i class="fa-solid fa-users"></i>
        <span>View Employees</span>
    </button>

    <button class="sidebar-btn" onclick="loadPage(this,'toggleUserStatus.jsp')">
        <i class="fa-solid fa-user-gear"></i>
        <span>Manage Status</span>
    </button>

    <button class="sidebar-btn" onclick="loadPage(this,'calendar.jsp')">
        <i class="fa-solid fa-calendar-days"></i>
        <span>Calendar</span>
    </button>

    <button class="sidebar-btn" onclick="loadPage(this,'sendNotification.jsp')">
        <i class="fa-solid fa-bell"></i>
        <span>Send Notifications</span>
    </button>

    <button class="sidebar-btn" onclick="exportUsers()">
        <i class="fa-solid fa-file-export"></i>
        <span>Export Employees</span>
    </button>
</div>

    <div class="content-area">
        <iframe id="contentFrame" src="adminOverview"></iframe>
    </div>
</div>

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
function submitPassword(){alert("Password updated");closeChangePassword();}
function exportUsers(){document.getElementById("contentFrame").src="exportUsers";}

</script>

</body>
</html>