<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>

<%
String successMsg = (String) session.getAttribute("successMsg");
String errorMsg = (String) session.getAttribute("errorMsg");

session.removeAttribute("successMsg");
session.removeAttribute("errorMsg");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add User</title>

<style>
* {
	box-sizing: border-box;
}

body {
	margin: 0;
	/* 	padding: 30px; */
	font-family: "Segoe UI", Arial, sans-serif;
	/* 	background:#fffafa; */
	height: auto;
	display: flex;
	justify-content: center;
	align-items: center;
}

.container {
	height: 100%;
	width: 100%;
	background: #c3cfe2;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

h2 {
	margin-bottom: 24px;
	text-align: center;
	font-size: 22px;
	color: #222;
}

.form-group {
	/* 	margin-bottom: 16px; */
	
}

label {
	display: block;
	margin-bottom: 6px;
	font-size: 13px;
	font-weight: 600;
	color: #444;
}

input, select {
	width: 100%;
	height: 44px;
	padding: 8px;
	font-size: 14px;
	border: 1px solid #ccc;
	border-radius: 5px;
}

input:focus, select:focus {
	outline: none;
	border-color: #4a6cf7;
}

button {
	width: 100%;
	height: 42px;
	margin-top: 10px;
	background-color: #4a6cf7;
	border: none;
	border-radius: 5px;
	font-size: 15px;
	color: #fff;
	cursor: pointer;
}

button:hover {
	background-color: #3f5eea;
}

/* ================= TOAST ================= */
.toast {
	position: fixed;
	top: 30px;
	right: 25px;
	background: #e2ebf0;
	color: black;
	padding: 14px 20px 14px 44px;
	border-radius: 10px;
	font-size: 15px;
	font-weight: 500;
	display: none;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
	z-index: 3000;
	line-height: 1.4;
	animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1);
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

/* SUCCESS */
.toast.success {
	background: #e2ebf0;
	color: black;
}

/* ERROR */
.toast.error {
	background: #e2ebf0;
	color: black;
}

.toast.error::before {
	content: "✖";
}

/* INFO */
.toast.info {
	background: #e2ebf0;
	color: black;
}

.toast.info::before {
	content: "ℹ";
}

@
keyframes toastIn {from { opacity:0;
	transform: translateX(120px);
}

to {
	opacity: 1;
	transform: translateX(0);
}

}
@
keyframes toastOut {from { opacity:1;
	transform: translateX(0);
}

to {
	opacity: 0;
	transform: translateX(120px);
}

}

/* DARK MODE FIX FOR ADD USER PAGE */
body.dark-theme {
	background: #121212 !important;
}
/* FIX CONTAINER BACKGROUND */
body.dark-theme .container {
	background: #1e1e1e !important;
	color: #ffffff !important;
}

body.dark-theme .form-container, body.dark-theme .page, body.dark-theme .card
	{
	background: #1e1e1e !important;
	color: #ffffff !important;
}

/* Labels */
body.dark-theme label {
	color: #ffffff !important;
}

/* Headings */
body.dark-theme h2, body.dark-theme h3 {
	color: #ffffff !important;
}

/* Inputs */
body.dark-theme input, body.dark-theme select {
	background: #2c2c2c !important;
	color: #ffffff !important;
	border: 1px solid #555 !important;
}

/* Placeholder text */
body.dark-theme input::placeholder {
	color: #bbbbbb !important;
}

/* Dropdown options */
body.dark-theme select option {
	background: #2c2c2c;
	color: #ffffff;
}

/* ===== Form Container ===== */
fieldset {
	width: 96%;
	margin: 30px auto;
	padding: 30px 35px;
	border-radius: 14px;
	border: none;
	background: #c3cfe2;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
}

/* ===== Legend ===== */
legend {
	padding: 8px 18px;
	font-size: 18px;
	font-weight: bold;
	color: #1f2937;
	background: #e2ebf0;
	border-radius: 8px;
}

/* ===== Grid Layout ===== */
fieldset {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 18px 28px;
}

/* Full-width items */
fieldset button {
	grid-column: span 2;
}

/* ===== Form Group ===== */
.form-group {
	display: flex;
	flex-direction: column;
}

/* ===== Labels ===== */
.form-group label {
	font-size: 14px;
	font-weight: 600;
	margin-bottom: 6px;
	color: #374151;
}

/* ===== Inputs & Select ===== */
.form-group input, .form-group select {
	padding: 12px 14px;
	font-size: 14px;
	border-radius: 8px;
	border: 1px solid #d1d5db;
	outline: none;
	transition: 0.25s ease;
	/*     background: #f9fafb; */
	background: #f2f0f0;
}

/* ===== Focus Effect ===== */
.form-group input:focus, .form-group select:focus {
	border-color: #2563eb;
	box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
	background: #ffffff;
}

/* ===== Select Arrow Fix ===== */
select {
	cursor: pointer;
}

/* ===== Button ===== */
button[type="submit"] {
	margin-top: 15px;
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

/* ===== Button Hover ===== */
button[type="submit"]:hover {
	background: linear-gradient(135deg, #1d4ed8, #1e40af);
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35);
}

/* ===== Button Active ===== */
button[type="submit"]:active {
	transform: scale(0.98);
}

/* ===== Responsive (Mobile) ===== */
@media ( max-width : 768px) {
	fieldset {
		grid-template-columns: 1fr;
	}
	fieldset button {
		grid-column: span 1;
	}
}
</style>
</head>

<body>

	<!-- 🔔 Toast -->
	<div id="toast" class="toast"></div>

	<div class="container">
		<!-- 		<h2>Add Employee</h2> -->

		<form action="addUser" method="post">
			<fieldset>
				<legend>Add Employee</legend>
				<div class="form-group">
					<label>Username</label> <input type="text" name="username" required>
				</div>

				<div class="form-group">
					<label>Password</label> <input type="password" name="password"
						required>
				</div>

				<div class="form-group">
					<label>Role</label> <select name="role" id="role" required>
						<option value="">Select Role</option>
						<option value="manager">Manager</option>
						<option value="user">Employee</option>
					</select>
				</div>

				<div class="form-group">
					<label>Status</label> <select name="status" required>
						<option value="">Select Status</option>
						<option value="active">Active</option>
						<option value="inactive">Inactive</option>
						<option value="banned">Banned</option>
						<option value="pending">Pending</option>
						<option value="suspended">Suspended</option>
					</select>
				</div>

				<div class="form-group">
					<label>Full Name</label> <input type="text" name="fullname"
						required>
				</div>

				<div class="form-group">
					<label>Phone Number</label> <input type="number" name="phonenumber"
						required>
				</div>

				<div class="form-group">
					<label>Manager</label> <select name="manager" id="managerSelect">
						<option value="">Select Manager</option>
						<option value="admin">Admin</option>

						<%
						List<String> managers = (List<String>) request.getAttribute("managers");
						if (managers != null) {
							for (String m : managers) {
						%>
						<option value="<%=m%>"><%=m%></option>
						<%
						}
						}
						%>
					</select>
				</div>

				<div class="form-group">
					<label>Email</label> <input type="email" name="email" required>
				</div>

				<div class="form-group">
					<label>Joined Date</label> <input type="date" name="joinedDate"
						required>
				</div>

				<button type="submit">Add Employee</button>
			</fieldset>
		</form>
		<hr style="margin: 30px 0">

		<form action="bulkUploadEmployees" method="post"
			enctype="multipart/form-data">

			<fieldset>
				<legend>Upload Bulk Employees</legend>

				<div class="form-group">
					<input type="file" name="excelFile" accept=".xlsx,.csv" required>
				</div>

				<button type="submit">Add Bulk Employees</button>

			</fieldset>

		</form>
	</div>

	<script>


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

</script>

	<script>
document.addEventListener("DOMContentLoaded", function () {

    const roleSelect = document.getElementById("role");
    const managerSelect = document.getElementById("managerSelect");

    function toggleManager() {
        if (roleSelect.value === "manager") {
            managerSelect.value = "admin";
            managerSelect.disabled = true;
        } else {
            managerSelect.disabled = false;
            managerSelect.value = "";
        }
    }

    roleSelect.addEventListener("change", toggleManager);
    toggleManager(); // run once on page load
});
</script>

	<script>
window.onload = function () {

    // ✅ Apply dark theme from parent iframe
    if (window.parent && window.parent.document.body.classList.contains("dark-theme")) {
        document.body.classList.add("dark-theme");
    }

    <%if (successMsg != null) {%>
        showToast("<%=successMsg%>", "success");
    <%}%>

    <%if (errorMsg != null) {%>
        showToast("<%=errorMsg%>", "error");
    <%}%>
};

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;

</script>


</body>
</html>

