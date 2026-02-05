<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Users</title>

<style>
body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6f8;
}

/* Page container */
.page {
    max-width: 900px;
    margin: 30px auto;
    background: white;
    padding: 25px;
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
    overflow: hidden;
    border-radius: 8px;
}

th {
    background: #e5e7eb;
    color: #374151;
    text-align: left;
    padding: 12px;
    font-size: 14px;
}

td {
    padding: 12px;
    font-size: 14px;
    color: #374151;
    border-bottom: 1px solid #e5e7eb;
}

tr:hover {
    background: #f9fafb;
}

/* Center empty message */
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
    display: inline-block;
}

.active {
    background: #e6f4ea;
    color: #1e7e34;
}

.inactive {
    background: #f1f3f5;
    color: #6c757d;
}

.banned {
    background: #fdecea;
    color: #c0392b;
}
</style>

</head>
<body>

<div class="page">

    <h2>User List</h2>

    <table>
        <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Role</th>
            <th>Status</th>
        </tr>

        <%= request.getAttribute("rows") != null 
            ? request.getAttribute("rows") 
            : "<tr><td colspan='4' class='empty'>No Data Found</td></tr>" %>
    </table>

</div>

</body>
</html>
