<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
String msg = request.getParameter("msg");
String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete User</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6f8;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.container {
    width: 360px;
    background: #ffffff;
    padding: 28px;
    border-radius: 8px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

h2 {
    text-align: center;
    margin-bottom: 22px;
    color: #222;
}

.form-group {
    margin-bottom: 18px;
}

label {
    display: block;
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 500;
    color: #444;
}

input {
    width: 100%;
    height: 40px;
    padding: 0 12px;
    font-size: 14px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

input:focus {
    outline: none;
    border-color: #ef4444;
}

button {
    width: 100%;
    height: 42px;
    background: #ef4444;
    border: none;
    border-radius: 5px;
    font-size: 15px;
    color: white;
    cursor: pointer;
}

button:hover {
    background: #dc2626;
}

/* 🔔 Toast */
.toast {
    position: fixed;
    top: 20px;
    right: 45%;
    padding: 14px 20px;
    color: white;
    font-size: 14px;
    border-radius: 6px;
    box-shadow: 0 6px 16px rgba(0,0,0,0.15);
    display: none;
    animation: slideIn 0.4s ease;
}

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
</style>
</head>

<body>

<!-- 🔔 Toast -->
<div id="toast" class="toast"></div>

<div class="container">
    <h2>Delete User</h2>

    <form action="deletecheck" method="post"
          onsubmit="return confirm('Are you sure you want to delete this user?');">

        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" required>
        </div>

        <button type="submit">Delete User</button>
    </form>
</div>

<script>
window.onload = function () {
    <% if ("UserDeleted".equals(msg)) { %>
        showToast("User deleted successfully!", "success");
    <% } %>

    <% if ("DeleteFailed".equals(error)) { %>
        showToast("User not found!", "error");
    <% } %>
};

function showToast(message, type) {
    const toast = document.getElementById("toast");
    toast.innerText = message;

    toast.style.background = type === "error" ? "#dc2626" : "#16a34a";
    toast.style.display = "block";

    setTimeout(() => {
        toast.style.display = "none";
    }, 3000);
}
</script>

</body>
</html>
