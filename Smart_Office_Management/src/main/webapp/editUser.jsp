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

body {
	background: #c3cfe2;
	font-family: Arial, sans-serif;
	display: flex;
	justify-content: center;
	padding: 40px;
}

.card {
	width: 100%;
}

.form-fieldset {
	border: none;
	border-radius: 12px;
	padding: 25px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
	background: #c3cfe2;
}

.form-fieldset legend {
	padding: 8px 14px;
	font-size: 16px;
	font-weight: 600;
	color: #333;
	background: #e2ebf0;
	border-radius: 14px;
	display: flex;
	align-items: center;
	gap: 8px;
}

.form-group {
	display: flex;
	flex-direction: column;
	margin-bottom: 15px;
}

.form-group label {
	font-size: 14px;
	margin-bottom: 6px;
	color: #444;
}

.form-group input, .form-group select {
	padding: 9px;
	border-radius: 6px;
	background: #e2ebf0;
	border: 1px solid #ccc;
	font-size: 14px;
}

.form-group input:focus, .form-group select:focus {
	outline: none;
	border-color: #6a7be7;
	box-shadow: 0 0 0 2px rgba(106, 123, 231, 0.2);
}

.btn {
	width: 100%;
	padding: 12px;
	border: none;
	border-radius: 8px;
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	color: white;
	font-size: 16px;
	font-weight: 500;
	cursor: pointer;
	transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
}

.password-wrapper {
	position: relative;
	display: flex;
	align-items: center;
}

.password-wrapper input {
	width: 100%;
	padding-right: 40px; /* space for icon */
}

.toggle-password {
	position: absolute;
	right: 12px;
	cursor: pointer;
	color: #555;
	font-size: 14px;
	transition: 0.2s;
}

.toggle-password:hover {
	color: #667eea;
}
</style>
</head>

<body>

	<div class="card">
		<fieldset class="form-fieldset">
			<legend>
				<i class="fa-solid fa-user-pen"></i> Edit Employee
			</legend>

			<form action="editUser" method="post">

				<!-- Hidden ID -->
				<input type="hidden" name="id" value="${id}">

				<div class="form-group">
					<label>Username</label> <input type="text" name="username"
						value="${username}" readonly>
				</div>

				<!-- Role -->
				<div class="form-group">
					<label>Role</label> <select name="role" id="roleSelect" required>
						<option value="admin"
							${role eq 'admin' ? 'selected="selected"' : ''}>Admin</option>
						<option value="manager"
							${role eq 'manager' ? 'selected="selected"' : ''}>Manager</option>
						<option value="user"
							${role eq 'user' ? 'selected="selected"' : ''}>Employee</option>
					</select>
				</div>

				<!-- Status -->
				<div class="form-group">
					<label>Status</label> <select name="status" required>
						<option value="active"
							${status eq 'active' ? 'selected="selected"' : ''}>Active</option>
						<option value="inactive"
							${status eq 'inactive' ? 'selected="selected"' : ''}>Inactive</option>
						<option value="pending"
							${status eq 'pending' ? 'selected="selected"' : ''}>Pending</option>
						<option value="banned"
							${status eq 'banned' ? 'selected="selected"' : ''}>Banned</option>
						<option value="suspended"
							${status eq 'suspended' ? 'selected="selected"' : ''}>Suspended</option>
					</select>
				</div>

				<div class="form-group">
					<label>Full Name</label> <input type="text" name="fullname"
						value="${fullname}" required>
				</div>

				<div class="form-group">
					<label>Phone Number</label> <input type="text" name="number"
						value="${phone}" required>
				</div>

				<div class="form-group">
					<label>Email</label> <input type="email" name="email"
						value="${email}" required>
				</div>

				<!-- Manager -->
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
							<%=(selectedManager != null && selectedManager.equals(m)) ? "selected=\"selected\"" : ""%>>
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
					<i class="fa-solid fa-floppy-disk"></i> Update Employee
				</button>

			</form>
		</fieldset>
	</div>

	<script>
		document.addEventListener("DOMContentLoaded", function() {

			const roleSelect = document.getElementById("roleSelect");
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
			toggleManager();
		});

		const passwordField = document.getElementById("passwordField");
		const togglePassword = document.getElementById("togglePassword");

		togglePassword
				.addEventListener(
						"click",
						function() {
							const type = passwordField.getAttribute("type") === "password" ? "text"
									: "password";
							passwordField.setAttribute("type", type);

							// Change icon
							this.classList.toggle("fa-eye");
							this.classList.toggle("fa-eye-slash");
						});
		
		document.addEventListener('contextmenu', e => e.preventDefault());
		document.onkeydown = e =>
		  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
		    ? false
		    : true;
		
	</script>

</body>
</html>
