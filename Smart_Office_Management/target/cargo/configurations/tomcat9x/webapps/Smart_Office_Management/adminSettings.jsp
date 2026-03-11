<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Admin Settings</title>

<!-- Font Awesome -->
<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* ===== Reset & Base ===== */
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    background: #f4f6f8;
    font-family: "Segoe UI", Arial, sans-serif;
    display: flex;
    align-items: flex-start;
    justify-content: center;
}

/* ===== Card ===== */
.card {
    width: 520px;
    margin-top: 40px;
    background: #ffffff;
    padding: 28px 30px;
    border-radius: 14px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}

/* ===== Header ===== */
.card-header {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-bottom: 26px;
}

.card-header i {
    font-size: 18px;
    color: #3b82f6;
}

.card-header h2 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
    color: #1f2933;
}

/* ===== Form ===== */
.form-group {
    margin-bottom: 18px;
}

label {
    display: block;
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 500;
    color: #374151;
}

input,
select {
    width: 100%;
    height: 44px;
    padding: 0 14px;
    font-size: 14px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    background: #fafafa;
    transition: 0.2s;
}

input:focus,
select:focus {
    outline: none;
    background: #ffffff;
    border-color: #3b82f6;
}

/* ===== Button ===== */
.btn {
    width: 100%;
    height: 46px;
    margin-top: 8px;
    background: #3b82f6;
    border: none;
    border-radius: 10px;
    color: #ffffff;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: 0.2s;
}

.btn:hover {
    background: #2563eb;
}
</style>
</head>

<body>

<div class="card">

    <!-- Header -->
    <div class="card-header">
        <i class="fa-solid fa-gear"></i>
        <h2>Admin Settings</h2>
    </div>

    <!-- Form -->
    <form action="updateAdminSettings" method="post">

        <div class="form-group">
            <label>Admin Email</label>
            <input type="email" name="email" value="${sessionScope.email}" required>
        </div>

        <div class="form-group">
            <label>Change Password</label>
            <input type="password" name="password" placeholder="Leave blank to keep current">
        </div>

        <div class="form-group">
            <label>Default User Role</label>
            <select name="defaultRole">
                <option value="user">User</option>
                <option value="manager">Manager</option>
            </select>
        </div>

        <button type="submit" class="btn">
            Save Settings
        </button>

    </form>

</div>

</body>

<script>

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;
  </script>
</html>
