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
	font-family: "Segoe UI", Arial, sans-serif;
	background-color: #f4f6f8;
	min-height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
}

.container {
	width: 420px;
	background: #ffffff;
	padding: 28px;
	border-radius: 8px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

h2 {
	margin-bottom: 24px;
	text-align: center;
	font-size: 22px;
	color: #222;
}

.form-group {
	margin-bottom: 16px;
}

label {
	display: block;
	margin-bottom: 6px;
	font-size: 13px;
	font-weight: 500;
	color: #444;
}

input, select {
	width: 100%;
	height: 40px;
	padding: 0 12px;
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

/* 🔔 Toast */
.toast {
	position: fixed;
	top: 20px;
	right: 20px;
	padding: 14px 20px;
	color: white;
	font-size: 14px;
	border-radius: 6px;
	box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
	display: none;
	animation: slideIn 0.4s ease;
}

@keyframes slideIn {from { transform:translateX(100%);
	opacity: 0;
}

to {
	transform: translateX(0);
	opacity: 1;
}
}
</style>
</head>

<body>

	<!-- 🔔 Toast -->
	<div id="toast" class="toast"></div>

	<div class="container">
		<h2>Add User</h2>

		<form action="addUser" method="post">

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
					<option value="user">User</option>
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
				<label>Full Name</label> <input type="text" name="fullname" required>
			</div>

			<div class="form-group">
				<label>Phone Number</label> <input type="number" name="phonenumber"
					required>
			</div>

			<div class="form-group">
				<label>Manager</label> <select name="manager" id="managerSelect">
					<option value="">Select Manager</option>

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

			<button type="submit">Add User</button>
		</form>
	</div>

	<script>
window.onload = function () {
    <%if (successMsg != null) {%>
        showToast("<%=successMsg%>", "success");
    <%}%>

    <%if (errorMsg != null) {%>
        showToast("<%=errorMsg%>", "error");
    <%}%>
};

function showToast(message, type) {
    const toast = document.getElementById("toast");
    toast.innerText = message;

    toast.style.background =
        type === "error" ? "#dc2626" : "#16a34a";

    toast.style.display = "block";

    setTimeout(() => {
        toast.style.display = "none";
    }, 3000);
}

</script>

<script>
document.addEventListener("DOMContentLoaded", function () {

    const roleSelect = document.getElementById("role");
    const managerSelect = document.getElementById("managerSelect");

    function toggleManager() {
        if (roleSelect.value === "manager") {
            managerSelect.value = "";
            managerSelect.disabled = true;
        } else {
            managerSelect.disabled = false;
        }
    }

    roleSelect.addEventListener("change", toggleManager);
    toggleManager(); // run once on page load
});
</script>



</body>
</html>

