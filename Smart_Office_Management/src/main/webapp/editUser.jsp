<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.List"%>
<!DOCTYPE html>
<html>
<head>
<title>Edit User</title>

<!-- Font Awesome -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* ===== Reset ===== */
* {
	box-sizing: border-box;
}

/* ===== Base ===== */
body {
	margin: 0;
	background: #f4f6f8;
	font-family: "Segoe UI", Arial, sans-serif;
}

/* ===== Card ===== */
.card {
	width: 100%;
	background: #ffffff;
	padding: 30px 28px;
	border-radius: 12px;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
}

/* ===== Heading ===== */
.card h2 {
	text-align: center;
	margin: 0 0 24px;
	font-size: 18px;
	font-weight: 600;
	color: #1f2933;
}

/* ===== Form ===== */
.form-group {
	display: flex;
	flex-direction: column;
	margin-bottom: 18px;
}

label {
	margin-bottom: 6px;
	font-size: 13px;
	font-weight: 500;
	color: #374151;
}

/* ===== Inputs ===== */
input, select {
	height: 42px;
	padding: 0 12px;
	font-size: 14px;
	border: 1px solid #d1d5db;
	border-radius: 8px;
	background-color: #fafafa;
}

input[readonly] {
	background-color: #f1f5f9;
	color: #6b7280;
}

input:focus, select:focus {
	outline: none;
	border-color: #3b82f6;
	background-color: #ffffff;
}

/* ===== Button ===== */
.btn {
	margin-top: 10px;
	width: 100%;
	height: 44px;
	background: #3b82f6;
	color: #ffffff;
	border: none;
	border-radius: 8px;
	font-size: 14px;
	font-weight: 500;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 6px;
	transition: background 0.2s;
}

.btn:hover {
	background: #2563eb;
}
</style>
</head>

<body>

	<div class="card">
		<h2>Edit User</h2>

		<form action="editUser" method="post">

			<!-- Hidden ID -->
			<input type="hidden" name="id" value="${id}">

			<div class="form-group">
				<label>Username</label> <input type="text" value="${username}"
					readonly>
			</div>

			<div class="form-group">
				<label>Role</label> <select name="role" required>
					<option value="admin" ${role == 'admin' ? 'selected' : ''}>Admin</option>
					<option value="manager" ${role == 'manager' ? 'selected' : ''}>Manager</option>
					<option value="user" ${role == 'user' ? 'selected' : ''}>User</option>
				</select>
			</div>

			<div class="form-group">
				<label>Status</label> <select name="status" required>
					<option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
					<option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
					<option value="pending" ${status == 'pending' ? 'selected' : ''}>Pending</option>
					<option value="banned" ${status == 'banned' ? 'selected' : ''}>Banned</option>
					<option value="suspended"
						${status == 'suspended' ? 'selected' : ''}>Suspended</option>
				</select>
			</div>

			<div class="form-group">
				<label>Full Name</label> <input type="text" name="fullname"
					value="${fullname}" required>
			</div>

			<div class="form-group">
				<label>Password</label> <input type="text" name="password"
					value="${password}" required>
			</div>

			<div class="form-group">
				<label>Phone Number</label> <input type="text" name="number"
					value="${phone}" required>
			</div>

			<div class="form-group">
				<label>Email</label> <input type="email" name="email"
					value="${email}" required>
			</div>

			<div class="form-group">
				<label>Manager</label> <select name="manager" id="managerSelect">
					<option value="">Select Manager</option>

					<%
					List<String> managers = (List<String>) request.getAttribute("managers");
					String selectedManager = (String) request.getAttribute("manager");

					if (managers != null) {
						for (String m : managers) {
					%>
					<option value="<%=m%>"
						<%=m.equals(selectedManager) ? "selected" : ""%>>
						<%=m%>
					</option>
					<%
					}
					}
					%>
				</select>
			</div>

			<div class="form-group">
				<label>Joined Date</label> <input type="date" name="joinedDate"
					value="${joinedDate}">
			</div>

			<button type="submit" class="btn">
				<i class="fa-solid fa-floppy-disk"></i> Update User
			</button>

		</form>
	</div>

	<script>
		document.addEventListener("DOMContentLoaded", function() {

			const roleSelect = document.querySelector("select[name='role']");
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
			toggleManager(); // run on page load
		});
	</script>


</body>
</html>
