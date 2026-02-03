<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>
<%@ page import="com.smartoffice.utils.DBConnectionUtil" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>

<style>
    body {
        margin: 0;
        font-family: Arial, sans-serif;
        background: #f4f6f8;
    }

    /* Top bar */
    .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 30px;
        background: #2c3e50;
        color: white;
    }

    .logout-btn {
        background: #e74c3c;
        color: white;
        font-size: 16px;
        font-weight: bold;
        border: none;
        padding: 8px 16px;
        border-radius: 5px;
        cursor: pointer;
    }
    .logout-btn:hover {
    	background: #217dbb;
    	box-shadow: 0 2px 8px rgba(52,152,219,0.15);
    	transition: background 0.2s, box-shadow 0.2s;
    	transform: translateY(-2px);
	}

    /* Layout */
    .container {
        display: flex;
        height: calc(100vh - 60px);
    }

    /* Left panel */
    .left-panel {
        width: 25%;
        background: white;
        padding: 30px;
        box-shadow: 2px 0 8px rgba(0,0,0,0.1);
    }

    .info {
        margin-bottom: 12px;
        color: #555;
    }

    /* Right panel */
    .right-panel {
        width: 75%;
        padding: 30px;
    }

    /* Action buttons */
    .actions-bar {
        display: flex;
        gap: 15px;
        margin-bottom: 25px;
    }

    .action-btn {
    	width: 170px;
        padding: 12px 18px;
        border: none;
        border-radius: 6px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        color: white;
        background: #3498db;
    }
    
    
	.action-btn:hover {
    	background: #217dbb;
    	box-shadow: 0 2px 8px rgba(52,152,219,0.15);
    	transition: background 0.2s, box-shadow 0.2s;
    	transform: translateY(-2px);
	}
  
    .danger { background: #e67e22; }
    .toggle { background: #2ecc71; }

    /* Table */
    table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
        overflow: hidden;
    }

    th {
        background: #2c3e50;
        color: white;
        padding: 12px;
        text-align: left;
    }

    td {
        padding: 10px;
        border-bottom: 1px solid #eee;
    }

    tr:hover {
        background: #f9fbfd;
    }

    .badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: bold;
    }

    .active { background: #e6f4ea; color: #1e7e34; }
    .inactive { background: #f1f3f5; color: #6c757d; }
    .banned { background: #fdecea; color: #c0392b; }

    .table-actions button {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 16px;
    }
</style>
</head>

<body>

<!-- Top Bar -->
<div class="top-bar">
    <h2>Admin Dashboard</h2>
    <a href="<%= request.getContextPath() %>/logout">
        <button class="logout-btn">Logout</button>
    </a>
</div>

<div class="container">

    <!-- Left Panel -->
    <div class="left-panel">
        <h3>Admin Details</h3>
        <div class="info"><strong>Username:</strong> <%= session.getAttribute("username") %></div>
        <div class="info"><strong>Role:</strong> Admin</div>
        <div class="info"><strong>Status:</strong> Active</div>
    </div>

    <!-- Right Panel -->
    <div class="right-panel">

        <!-- Action Buttons -->
        <div class="actions-bar">
            <button class="action-btn" onclick="location.href='addUser.jsp'">
            	Add User
            </button>
            <button class="action-btn" onclick="location.href='viewUser.jsp'">
            	View Users
            </button>
            <button class="action-btn danger" onclick="location.href='editUser.jsp'">
            	Edit User
            </button>
            <button class="action-btn toggle" onclick="location.href='toggleUserStatus.jsp'">
            	Enable / Disable
            </button>
            <button class="action-btn danger" onclick="location.href='deleteUser.jsp'">
            	Delete User
            </button>
        </div>

        

    </div>
</div>

</body>
</html>
