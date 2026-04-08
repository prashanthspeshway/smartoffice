<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>My Profile</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">

<style>
body {
    margin: 0;
    font-family: 'Geist', system-ui, sans-serif;
    background: #f1f5f9;
    min-height: 100dvh;
}

.profile-page {
    min-height: 100dvh;
    padding: 14px;
    display: flex;
    align-items: flex-start;
    justify-content: center;
}

.profile-card {
    width: 100%;
    max-width: 620px;
    margin: 0 auto;
    background: white;
    padding: 16px;
    border-radius: 14px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
}

.profile-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
}

.profile-header h3 {
    margin: 0;
    font-size: 1.6rem;
    color: #0f172a;
}

.close-btn {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    border: 1px solid #cbd5e1;
    background: #fff;
    color: #64748b;
    font-size: 18px;
    cursor: pointer;
}
.close-btn:hover { background: #f8fafc; color: #0f172a; }

.profile-body { display: grid; gap: 10px; }

@media (max-width: 640px) {
    .profile-page { padding: 8px; }
    .profile-card {
        max-width: 100%;
        min-height: calc(100dvh - 16px);
        border-radius: 12px;
    }
    .profile-header h3 { font-size: 1.8rem; }
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
<div class="profile-page">
<div class="profile-card">

    <div class="profile-header">
        <h3>👤 My Profile</h3>
        <button type="button" class="close-btn" onclick="closeProfile()" aria-label="Close">×</button>
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
</div>

</body>
<script>
function closeProfile() {
  try {
    if (window.parent && typeof window.parent.loadPage === 'function') {
      window.parent.loadPage(null, 'adminSettingsPage.jsp');
      return;
    }
  } catch (e) {}
  window.history.back();
}
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;
  </script>
</html>