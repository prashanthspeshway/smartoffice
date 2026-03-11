<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<!DOCTYPE html>
<html>
<head>
<title>Settings</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
* { box-sizing: border-box; }
body { margin: 0; font-family: "Segoe UI", Arial, sans-serif; background: #c3cfe2; padding: 24px; }
.settings-title { font-size: 22px; font-weight: 600; color: #2d3748; margin-bottom: 24px; }
.settings-grid { display: flex; flex-direction: column; gap: 20px; max-width: 480px; }
.settings-card {
    background: white; padding: 24px; border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}
.settings-card h3 { margin: 0 0 12px; font-size: 16px; color: #2d3748; }
.settings-card p { margin: 0 0 16px; font-size: 14px; color: #64748b; }
.btn { padding: 10px 18px; border-radius: 8px; border: none; cursor: pointer; font-size: 14px; font-weight: 500; }
.btn-primary { background: #3b82f6; color: white; }
.btn-primary:hover { background: #2563eb; }
.form-group { margin-bottom: 14px; }
.form-group label { display: block; margin-bottom: 6px; font-size: 13px; color: #374151; }
.form-group input { width: 100%; padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px; }
</style>
</head>
<body>

<div class="settings-title"><i class="fa-solid fa-gear"></i> Settings</div>

<div class="settings-grid">
    <div class="settings-card">
        <h3>My Profile</h3>
        <p>View and manage your profile information.</p>
        <button type="button" class="btn btn-primary" onclick="loadProfile()">
            <i class="fa-solid fa-user"></i> Open My Profile
        </button>
    </div>

    <div class="settings-card">
        <h3>Change Password</h3>
        <p>Update your account password.</p>
        <form id="pwdForm" onsubmit="return submitPassword(event)">
            <div class="form-group">
                <label>New Password</label>
                <input type="password" id="newPassword" placeholder="Enter new password" required>
            </div>
            <div class="form-group">
                <label>Confirm Password</label>
                <input type="password" id="confirmPassword" placeholder="Confirm new password" required>
            </div>
            <button type="submit" class="btn btn-primary">Update Password</button>
        </form>
    </div>
</div>

<script>
function loadProfile() {
    var frame = window.parent && window.parent.document && window.parent.document.getElementById('contentFrame');
    if (frame) frame.src = 'selfProfile';
}

function submitPassword(e) {
    e.preventDefault();
    var newPwd = document.getElementById('newPassword').value.trim();
    var confirmPwd = document.getElementById('confirmPassword').value.trim();
    if (newPwd !== confirmPwd) {
        if (window.parent.showToast) window.parent.showToast('Passwords do not match', 'error');
        else alert('Passwords do not match');
        return false;
    }
    fetch('<%=request.getContextPath()%>/changePassword', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ newPassword: newPwd, confirmPassword: confirmPwd })
    })
    .then(function(r) { return r.text(); })
    .then(function(data) {
        if (data === 'Success') {
            if (window.parent.showToast) window.parent.showToast('Password updated successfully', 'success');
            else alert('Password updated');
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
        } else if (data === 'PasswordMismatch') {
            if (window.parent.showToast) window.parent.showToast('Passwords do not match', 'error');
            else alert('Passwords do not match');
        } else if (data === 'MissingFields') {
            if (window.parent.showToast) window.parent.showToast('Please fill all fields', 'warning');
            else alert('Please fill all fields');
        } else {
            if (window.parent.showToast) window.parent.showToast('Password must be 8+ chars with uppercase, lowercase, number, symbol', 'error');
            else alert('Invalid password format');
        }
    })
    .catch(function() {
        if (window.parent.showToast) window.parent.showToast('Server error', 'error');
        else alert('Server error');
    });
    return false;
}
</script>

</body>
</html>
