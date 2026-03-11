<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String successMsg = (String) session.getAttribute("successMsg");
String errorMsg = (String) session.getAttribute("errorMsg");
session.removeAttribute("successMsg");
session.removeAttribute("errorMsg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Employee • Smart Office</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --bg: #f1f5f9;
  --card: #ffffff;
  --card-border: #e2e8f0;
  --text: #0f172a;
  --text-muted: #64748b;
  --accent: #0ea5e9;
  --success: #10b981;
  --danger: #ef4444;
  --radius: 12px;
  --radius-sm: 8px;
  --shadow: 0 1px 3px rgba(0,0,0,0.06);
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
  line-height: 1.5;
}
.page { max-width: 720px; margin: 0 auto; padding: 32px 24px; }
.page-title { font-size: 24px; font-weight: 700; margin-bottom: 8px; display: flex; align-items: center; gap: 10px; }
.page-title i { color: var(--accent); }
.page-subtitle { font-size: 14px; color: var(--text-muted); margin-bottom: 24px; }

.card {
  background: var(--card);
  border: 1px solid var(--card-border);
  border-radius: var(--radius);
  padding: 28px;
  box-shadow: var(--shadow);
}
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px 20px;
}
@media (max-width: 600px) { .form-grid { grid-template-columns: 1fr; } }
.form-group { margin-bottom: 16px; }
.form-group.full-width { grid-column: span 2; }
@media (max-width: 600px) { .form-group.full-width { grid-column: span 1; } }
.form-group label { display: block; font-size: 13px; font-weight: 500; color: var(--text); margin-bottom: 6px; }
.form-group input, .form-group select {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--card-border);
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-family: inherit;
  background: var(--card);
  transition: border-color 0.2s, box-shadow 0.2s;
}
.form-group input:focus, .form-group select:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.15);
}
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  background: linear-gradient(135deg, var(--accent), #0284c7);
  color: white;
  margin-top: 8px;
}
.btn:hover { opacity: 0.95; }

.toast {
  position: fixed;
  top: 24px;
  right: 24px;
  padding: 14px 20px;
  border-radius: var(--radius-sm);
  z-index: 9999;
  display: none;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 10px 40px -10px rgba(0,0,0,0.2);
}
.toast.success { background: var(--success); color: white; }
.toast.error { background: var(--danger); color: white; }

/* Bulk upload section */
.bulk-section { margin-top: 32px; }
.bulk-section .card { padding: 20px; }
.bulk-section .form-group { margin-bottom: 12px; }
</style>
</head>
<body>

<div id="toast" class="toast" data-success="<%= successMsg != null ? successMsg.replace("\"", "&quot;").replace("'", "&#39;") : "" %>" data-error="<%= errorMsg != null ? errorMsg.replace("\"", "&quot;").replace("'", "&#39;") : "" %>"></div>

<div class="page">
  <h1 class="page-title"><i class="fa-solid fa-user-plus"></i> Add Employee</h1>
  <p class="page-subtitle">Create a new employee account</p>

  <div class="card">
    <form id="addEmployeeForm" action="<%= request.getContextPath() %>/addUser" method="post">
      <div class="form-grid">
        <div class="form-group">
          <label>First Name</label>
          <input type="text" name="firstname" required placeholder="First name">
        </div>
        <div class="form-group">
          <label>Last Name</label>
          <input type="text" name="lastname" required placeholder="Last name">
        </div>
        <div class="form-group">
          <label>Email</label>
          <input type="email" name="email" required placeholder="email@example.com">
        </div>
        <div class="form-group">
          <label>Phone Number</label>
          <input type="text" name="phonenumber" placeholder="Up to 10 digits" maxlength="10" pattern="[0-9]*" title="Enter up to 10 digits">
        </div>
        <div class="form-group">
          <label>Role</label>
          <select name="role" id="role" required>
            <option value="">Select Role</option>
            <option value="manager">Manager</option>
            <option value="user">Employee</option>
          </select>
        </div>
        <div class="form-group">
          <label>Password</label>
          <input type="password" name="password" id="password" required placeholder="Set password">
        </div>
        <div class="form-group">
          <label>Confirm Password</label>
          <input type="password" name="confirmPassword" id="confirmPassword" required placeholder="Confirm password">
        </div>
        <div class="form-group">
          <label>Status</label>
          <select name="status" required>
            <option value="">Select Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="pending">Pending</option>
          </select>
        </div>
        <div class="form-group">
          <label>Joined Date <span style="color:var(--text-muted);font-weight:400;">(optional)</span></label>
          <input type="date" name="joinedDate" placeholder="yyyy-mm-dd">
        </div>
      </div>
      <button type="submit" class="btn"><i class="fa-solid fa-plus"></i> Add Employee</button>
    </form>
  </div>

  <div class="bulk-section">
    <div class="card">
      <div class="form-group">
        <label>Upload Bulk Employees</label>
        <form action="<%= request.getContextPath() %>/bulkUploadEmployees" method="post" enctype="multipart/form-data" style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;">
          <input type="file" name="excelFile" accept=".xlsx,.csv" required style="flex:1;min-width:200px;">
          <button type="submit" class="btn">Add Bulk</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
function showToast(msg, type) {
  var t = document.getElementById('toast');
  if (!t) return;
  t.className = 'toast ' + type;
  t.textContent = msg;
  t.style.display = 'block';
  setTimeout(function() { t.style.display = 'none'; }, 2500);
}
document.addEventListener('DOMContentLoaded', function() {
  var toast = document.getElementById('toast');
  if (toast) {
    var s = toast.getAttribute('data-success'), e = toast.getAttribute('data-error');
    if (s) showToast(s, 'success');
    if (e) showToast(e, 'error');
  }
  var form = document.getElementById('addEmployeeForm');
  if (form) {
    form.addEventListener('submit', function(ev) {
      var pwd = document.getElementById('password').value;
      var confirm = document.getElementById('confirmPassword').value;
      if (pwd !== confirm) {
        ev.preventDefault();
        showToast('Passwords do not match.', 'error');
      }
    });
  }
});
</script>
</body>
</html>
