<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Enable / Disable User</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #c3cfe2;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

/* ===== Container (unchanged behavior) ===== */
.container {
    width: 900px;
    height: auto;
}

/* ===== Fieldset (COPIED FROM adduser.jsp STYLE) ===== */
fieldset {
    max-width: 900px;
    margin: 30px auto;
    padding: 30px 35px;
    border-radius: 14px;
    border: none;
    background: #c3cfe2;
    box-shadow: 0 10px 30px rgba(0,0,0,0.12);
}

/* ===== Legend (same as adduser.jsp) ===== */
legend {
    padding: 8px 18px;
    font-size: 18px;
    font-weight: bold;
    color: #1f2937;
    background:#e2ebf0;
    border-radius: 8px;
}

/* ===== Heading ===== */
h2 {
    text-align: center;
    margin: 16px 0 24px;
    font-size: 20px;
    color: #1f2937;
}

/* ===== Label ===== */
label {
    font-size: 14px;
    font-weight: 700;
    color: #374151;
}

/* ===== Input ===== */
input {
    width: 100%;
    height: 42px;
    margin-top: 6px;
    margin-bottom: 18px;
    padding: 0 12px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 14px;
    background: #f2f0f0;
    outline: none;
    transition: 0.25s;
}

input:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.15);
    background: #ffffff;
}

/* ===== Buttons ===== */
.buttons {
    display: flex;
    gap: 14px;
    margin-top: 10px;
}

button {
    flex: 1;
    height: 46px;
    border: none;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 600;
    color: #ffffff;
    cursor: pointer;
    transition: 0.3s ease;
}

button.active {
   background: linear-gradient(135deg, #2563eb, #1e40af);
}

button.inactive {
   background: linear-gradient(135deg, #ef4444, #991b1b);
}

button:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 18px rgba(0,0,0,0.2);
}

button:active {
    transform: scale(0.97);
}

/* ===== TOAST (SAME STYLE AS DASHBOARD) ===== */
.toast {
    position: fixed;
    top: 20px;
    right: 25px;
    background: #e2ebf0;
    color: black;
    padding: 14px 20px 14px 44px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    display: none;
    box-shadow: 0 10px 25px rgba(0,0,0,0.25);
    z-index: 3000;
    line-height: 1.4;
    animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Toast Types */
.toast.success {
    background: #e2ebf0;
    color: black;
}

.toast.error {
    background: #e2ebf0;
    color: black;
}

.toast.warning {
    background: #e2ebf0;
    color: black;
}

.toast.info {
    background: #e2ebf0;
    color: black;
}

.toast.hide {
    animation: toastOut 0.4s ease forwards;
}

/* Icon */
.toast::before {
    content: "✔";
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 16px;
    font-weight: bold;
}

/* Animations */
@keyframes toastIn {
    from {
        opacity: 0;
        transform: translateX(120px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes toastOut {
    from {
        opacity: 1;
        transform: translateX(0);
    }
    to {
        opacity: 0;
        transform: translateX(120px);
    }
}

/* ===== Dark Mode (kept intact) ===== */
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

body.dark-theme h2,
body.dark-theme label {
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

<!-- Toasts -->
<div id="toast" class="toast"></div>

<div class="container">

    <form action="enableanddisable" method="post">
        <fieldset>

            <legend>Manage Employee Status</legend>

            <h2>Enable / Disable User</h2>

            <label>Email</label>
            <input type="email" name="email" required placeholder="user@example.com">

            <div class="buttons">
                <button class="active" type="submit" name="status" value="active">
                    Active
                </button>
                <button class="inactive" type="submit" name="status" value="inactive">
                    Inactive
                </button>
            </div>

        </fieldset>
    </form>

</div>

<script>
const params = new URLSearchParams(window.location.search);

function showToast(message, type = "success") {
    const toast = document.getElementById("toast");

    toast.className = "toast " + type;
    toast.textContent = message;
    toast.style.display = "block";

    setTimeout(() => {
        toast.classList.add("hide");

        setTimeout(() => {
            toast.style.display = "none";
            toast.classList.remove("hide");
        }, 400);
    }, 2500);
}

// Handle messages
if (params.get("msg")) {
    showToast(params.get("msg").replaceAll("_", " "), "success");
}

if (params.get("error")) {
    showToast("Update Failed", "error");
}

// Clean URL
if (params.get("msg") || params.get("error")) {
    window.history.replaceState({}, document.title, window.location.pathname);
}

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;

</script>

</body>
</html>