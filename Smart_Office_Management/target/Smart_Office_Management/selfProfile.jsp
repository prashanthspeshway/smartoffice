<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>My Profile</title>

<style>
body {
    margin: 0;
    font-family: "Segoe UI", sans-serif;
    background: transparent;   /* IMPORTANT */
}

/* Remove full screen flex */

.profile-card {
    width: 100%;
    max-width: 480px;
    margin: 25px auto;
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.1);
}

.profile-item {
    background: #f3f4f6;
    padding: 12px 14px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 14px;
}

.profile-item span {
    font-weight: 600;
    color: #1e293b;
}
</style>
</head>

<body>

<div class="profile-card">

    <div class="profile-header">
        <h3>👤 My Profile</h3>
    </div>

    <div class="profile-body">
        <div class="profile-item">
            Full Name: <span>${user.fullname}</span>
        </div>

        <div class="profile-item">
            Email: <span>${user.email}</span>
        </div>

        <div class="profile-item">
            Role: <span>${user.role}</span>
        </div>

        <div class="profile-item">
            Phone: <span>${user.phone}</span>
        </div>
    </div>

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