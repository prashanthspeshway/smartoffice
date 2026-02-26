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
    background: #f9fafb;
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

/* ===== Toast ===== */
.toast {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 14px 20px;
    border-radius: 8px;
    font-size: 14px;
    color: #ffffff;
    display: none;
    box-shadow: 0 8px 20px rgba(0,0,0,0.25);
}

.toast.success { background: #16a34a; }
.toast.error { background: #dc2626; }

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
<div id="successToast" class="toast success"></div>
<div id="errorToast" class="toast error"></div>

<div class="container">

    <form action="enableanddisable" method="post">
        <fieldset>

            <legend>Manage Employee Status</legend>

            <h2>Enable / Disable User</h2>

            <label>Username</label>
            <input type="text" name="username" required>

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