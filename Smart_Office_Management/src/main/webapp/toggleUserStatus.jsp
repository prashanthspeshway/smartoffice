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
    background: #f4f6f8;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.container {
    width: 98%;
    height: 94vh;
    background: #fff;
    padding: 26px;
    border-radius: 8px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.08);
}

h2 {
    text-align: center;
    margin-bottom: 20px;
    color: #222;
}

label {
    font-size: 13px;
    color: #444;
}

input {
    width: 100%;
    height: 40px;
    margin-top: 6px;
    padding: 0 12px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

.buttons {
    display: flex;
    gap: 10px;
    margin-top: 18px;
}

button {
    flex: 1;
    height: 42px;
    border: none;
    border-radius: 5px;
    font-size: 14px;
    color: #fff;
    cursor: pointer;
}

.active {
    background: #16a34a;
}

.inactive {
    background: #dc2626;
}

/* 🔔 Toast */
.toast {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 14px 20px;
    border-radius: 6px;
    font-size: 14px;
    color: white;
    display: none;
    box-shadow: 0 6px 16px rgba(0,0,0,0.15);
}

.toast.success {
    background: #16a34a;
}

.toast.error {
    background: #dc2626;
}
/* ===== DARK MODE ===== */

body.dark-theme {
    background: #121212 !important;
}

body.dark-theme .container {
    background: #1e1e1e !important;
    color: #ffffff !important;
}

body.dark-theme h2 {
    color: #ffffff !important;
}

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
<div id="successToast" class="toast success"></div>
<div id="errorToast" class="toast error"></div>

<div class="container">
    <h2>Manage Employee Status</h2>

    <form action="enableanddisable" method="post">
        <label>Username</label>
        <input type="text" name="username" required>

        <div class="buttons">
            <button class="active" type="submit" name="status" value="active">
                Active
            </button>
            <button class="inactive" type="submit" name="status" value="inactive">
                Inctivate
            </button>
        </div>
    </form>
</div>

<script>
const params = new URLSearchParams(window.location.search);

if (params.get("msg")) {
    const toast = document.getElementById("successToast");
    toast.innerText = params.get("msg").replace("_", " ");
    toast.style.display = "block";
    setTimeout(() => toast.style.display = "none", 3000);
}

if (params.get("error")) {
    const toast = document.getElementById("errorToast");
    toast.innerText = "Update Failed";
    toast.style.display = "block";
    setTimeout(() => toast.style.display = "none", 3000);
}
</script>

</body>
</html>
