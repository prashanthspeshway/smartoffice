<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Users</title>

<!-- Font Awesome -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
body {
	margin: 0;
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f4f6f8;
	border:1px solid black;
}

/* Page container */
.page {
	width: 100%;
	height: 105vh;
	background: #c3cfe2 ;
/* 	padding: 10px; */
 	border-radius: 10px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
	
}

/* Heading */
h2 {
	margin-bottom: 20px;
	color: #1f2933;
}

/* Table */
table {
	width: 100%;
	border :none;
	
	border-collapse: collapse;
 	border-radius: 8px;
	overflow: hidden;
}

th {
	background: #e5e7eb;
	color: #374151;
	text-align: left;
	padding: 10px;
	font-size: 14px;
}

td {
	padding: 9px;
	font-size: 14px;
	color: #374151;
	border-bottom: 1px solid #e5e7eb;
}

tr:hover {
	background: #e2ebf0;
}

/* Empty state */
.empty {
	text-align: center;
	color: #6b7280;
	padding: 20px;
}

/* Status badges */
.badge {
	padding: 4px 10px;
	border-radius: 12px;
	font-size: 12px;
	font-weight: 600;
}

.active {
	background: #e6f4ea;
	color: #1e7e34;
}

.inactive {
	background: #f1f3f5;
	color: #6c757d;
}

/* Action icons */
.actions {
	white-space: nowrap;
}

.icon-btn {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 32px;
	height: 32px;
	border-radius: 6px;
	text-decoration: none;
	font-size: 14px;
	margin-right: 6px;
	transition: 0.2s;
}

/* Edit */
.icon-btn.edit {
	background: #e0f2fe;
	color: #0369a1;
}

.icon-btn.edit:hover {
	background: #bae6fd;
}

/* Delete */
.icon-btn.delete {
	background: #fee2e2;
	color: #991b1b;
}

.icon-btn.delete:hover {
	background: #fecaca;
}

/* ================= TOAST ================= */
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
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
    z-index: 3000;
    line-height: 1.4;
    animation: toastIn 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Success */
.toast.success {
    background: #e2ebf0;
    color: black;
}

/* Error */
.toast.error {
    background: #e2ebf0;
    color: black;
}

/* Warning */
.toast.warning {
    background: #e2ebf0;
    color: black;
}

/* Info */
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
</style>

</head>
<body>

	<div class="page">
		<!--     <h2>User List</h2> -->

		<table>
			<tr>
				<th>Username</th>
				<th>Role</th>
				<th>Status</th>
				<th>Full Name</th>
				<th>Email</th>
				<th>Joined Date</th>
				<th>Actions</th>
			</tr>

			<%=request.getAttribute("rows") != null
		? request.getAttribute("rows")
		: "<tr><td colspan='9' class='empty'>No Data Found</td></tr>"%>

		</table>
		<div style="margin-top: 15px; text-align: center;">

			<%
			int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;

			int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;

			for (int i = 1; i <= totalPages; i++) {
			%>
			<a href="viewUser?page=<%=i%>"
				style="padding:6px 10px; margin:3px; border-radius:5px;
              text-decoration:none;
              background:<%=(i == currentPage) ? "#3b82f6" : "#e5e7eb"%>;
              color:<%=(i == currentPage) ? "white" : "#374151"%>;">
				<%=i%>
			</a>
			<%
			}
			%>

		</div>

	</div>

	<div id="toast" class="toast"></div>



	<!-- Delete Confirmation Modal -->
	<div id="deleteModal"
		style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.4); z-index: 9999; align-items: center; justify-content: center;">

		<div
			style="background: white; padding: 25px; border-radius: 10px; width: 320px; text-align: center; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);">

			<h3 style="margin: 0 0 10px;">Delete Employee</h3>
			<p style="color: #6b7280;">Are you sure you want to delete this
				employee?</p>

			<div
				style="margin-top: 20px; display: flex; gap: 10px; justify-content: center;">
				<button onclick="closeDeleteModal()"
					style="padding: 8px 16px; border: none; background: #e5e7eb; border-radius: 6px; cursor: pointer;">
					Cancel</button>

				<button onclick="confirmDelete()"
					style="padding: 8px 16px; border: none; background: #dc2626; color: white; border-radius: 6px; cursor: pointer;">
					Delete</button>
			</div>
		</div>
	</div>

	<script>
let deleteUserId = null;

function openDeleteModal(id) {
    deleteUserId = id;
    document.getElementById("deleteModal").style.display = "flex";
}

function closeDeleteModal() {
    deleteUserId = null;
    document.getElementById("deleteModal").style.display = "none";
}

function confirmDelete() {
    if (deleteUserId !== null) {
        window.location.href = "deleteUser?id=" + deleteUserId;
    }
}
</script>


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

// Read URL parameter
const params = new URLSearchParams(window.location.search);
const msg = params.get("msg");

if (msg === "deleted") {
    showToast("User deleted successfully", "success");
}
else if (msg === "error") {
    showToast("Failed to delete user", "error");
}
else if (msg === "updated") {
    showToast("User updated successfully", "success");
}
</script>


</body>
</html>
