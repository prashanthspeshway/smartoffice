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
}

/* Page container */
.page {
    max-width: 1000px;
    background: white;
    padding: 10px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

/* Heading */
h2 {
    margin-bottom: 20px;
    color: #1f2933;
}

/* Table */
table {
    width: 100%;
    border-collapse: collapse;
    border-radius: 8px;
    overflow: hidden;
}

th {
    background: #e5e7eb;
    color: #374151;
    text-align: left;
    padding: 12px;
    font-size: 14px;
}

td {
    padding: 10px;
    font-size: 14px;
    color: #374151;
    border-bottom: 1px solid #e5e7eb;
}

tr:hover {
    background: #f9fafb;
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

/* Toast Notification */
#toast {
    position: fixed;
    top: 20px;
    right: 20px;
    min-width: 260px;
    padding: 14px 18px;
    border-radius: 8px;
    color: white;
    font-size: 14px;
    font-weight: 500;
    box-shadow: 0 6px 15px rgba(0,0,0,0.2);
    display: none;
    z-index: 9999;
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

        <%= request.getAttribute("rows") != null
            ? request.getAttribute("rows")
            : "<tr><td colspan='7' class='empty'>No Data Found</td></tr>" %>

    </table>
    <div style="margin-top:15px; text-align:center;">

<%
int currentPage = request.getAttribute("currentPage") != null
        ? (int) request.getAttribute("currentPage") : 1;

int totalPages = request.getAttribute("totalPages") != null
        ? (int) request.getAttribute("totalPages") : 1;

for (int i = 1; i <= totalPages; i++) {
%>
    <a href="viewUser?page=<%=i%>"
       style="padding:6px 10px; margin:3px; border-radius:5px;
              text-decoration:none;
              background:<%= (i == currentPage) ? "#3b82f6" : "#e5e7eb" %>;
              color:<%= (i == currentPage) ? "white" : "#374151" %>;">
        <%=i%>
    </a>
<%
}
%>

</div>
    
</div>

<div id="toast"></div>


<script>
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

// Read URL parameter
const params = new URLSearchParams(window.location.search);
const msg = params.get("msg");

if (msg === "deleted") {
    showToast("User deleted successfully", "success");
}
else if (msg === "error") {
    showToast("Failed to delete user", "error");
}
</script>


</body>
</html>
