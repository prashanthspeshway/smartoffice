<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Send Notification</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Geist', system-ui, sans-serif;
    background: #c3cfe2;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

/* ===== Container (aligned with adduser.jsp) ===== */
.container {
    width: 100%;
}

/* ===== Fieldset (COPIED FROM adduser.jsp) ===== */
fieldset {
    max-width: 900px;
    margin: 30px auto;
    padding: 30px 35px;
    border-radius: 14px;
    border: none;
    background: #c3cfe2;
    box-shadow: 0 10px 30px rgba(0,0,0,0.12);
}

/* ===== Legend ===== */
legend {
    padding: 8px 18px;
    font-size: 18px;
    font-weight: bold;
    color: #1f2937;
    background:#e2ebf0;
    border-radius: 8px;
}

/* ===== Heading ===== */
h3 {
    margin-bottom: 24px;
    text-align: center;
    font-size: 20px;
    color: #1f2937;
}

/* ===== Form Group ===== */
.form-group {
    display: flex;
    flex-direction: column;
    margin-bottom: 20px;
}

/* ===== Input ===== */
.form-group input {
    padding: 12px 14px;
    font-size: 14px;
    border-radius: 8px;
    border: 1px solid #d1d5db;
    outline: none;
    transition: 0.25s ease;
    background: #f2f0f0;
}

.form-group input:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.15);
    background: #ffffff;
}

/* ===== Button (same style as adduser.jsp) ===== */
button[type="submit"] {
    margin-top: 10px;
    padding: 14px;
    font-size: 16px;
    font-weight: bold;
    color: #ffffff;
    background: linear-gradient(135deg, #2563eb, #1d4ed8);
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: 0.3s ease;
}

button[type="submit"]:hover {
    background: linear-gradient(135deg, #1d4ed8, #1e40af);
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(37,99,235,0.35);
}

button[type="submit"]:active {
    transform: scale(0.98);
}

/* ===== Dark Mode (same logic preserved) ===== */
body.dark-theme {
    background: #121212 !important;
}

body.dark-theme fieldset {
    background: #1e1e1e !important;
}

body.dark-theme legend {
    background: #2c2c2c !important;
    color: #ffffff !important;
}

body.dark-theme h3 {
    color: #ffffff !important;
}

body.dark-theme input {
    background: #2c2c2c !important;
    color: #ffffff !important;
    border: 1px solid #555 !important;
}
</style>
</head>

<body>

<div class="container">
    <form action="addNotification" method="post">
        <fieldset>
            <legend>Send Notification</legend>

            <h3>📢 Send Notification</h3>

            <div class="form-group">
                <input type="text" name="message" placeholder="Notification message" required>
            </div>

            <button type="submit">Send Notification</button>
        </fieldset>
    </form>
</div>

<div id="toast" aria-live="polite"></div>

<script>
window.onload = function () {
    const params = new URLSearchParams(window.location.search);
    if (params.get("success") === "true") {
        showToast("Notification sent successfully", "success");
        window.history.replaceState({}, document.title, window.location.pathname);
    }
};

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;

</script>

</body>
</html>