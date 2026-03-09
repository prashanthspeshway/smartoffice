<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Users</title>

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        :root {
            --primary-color: #3b82f6;
            --text-color: #374151;
            --bg-color: #f4f6f8;
            --border-color: #e5e7eb;
            --shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            --success-bg: #d1fae5;
            --success-text: #065f46;
            --error-bg: #fee2e2;
            --error-text: #991b1b;
            --warning-bg: #fef3c7;
            --warning-text: #92400e;
            --info-bg: #dbeafe;
            --info-text: #1e40af;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background:#c3cfe2;
            line-height: 1.5;
        }

        /* Page container */
/*         .page { */
/*             width: 100%; */
/*             min-height: 100vh; */
/*             background: #c3cfe2; */
/* /*          padding: 10px; */ */
/*             border-radius: 10px; */
/*             box-shadow: var(--shadow); */
/*             margin: 0 auto; */
/*             max-width: 1200px; */
/*         } */

        /* Heading */
        h2 {
            margin-bottom: 20px;
            color: var(--text-color);
            text-align: center;
        }

        /* Table container for responsiveness */
        .table-container {
        	background: #c3cfe2;
            overflow-x: auto;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
            background:#c3cfe2;
        }

        th {
            background: var(--border-color);
            color: var(--text-color);
            text-align: left;
            padding: 12px 16px;
            font-size: 14px;
            font-weight: 600;
            white-space: nowrap;
        }

        td {
            padding: 12px 16px;
            font-size: 14px;
            color: var(--text-color);
            border-bottom: 1px solid var(--border-color);
        }

        tr:hover {
            background: #f9fafb;
        }

        /* Empty state */
        .empty {
            text-align: center;
            color: #6b7280;
            padding: 40px 20px;
            font-style: italic;
        }

        /* Status badges */
        .badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .active {
            background: var(--success-bg);
            color: var(--success-text);
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
            transition: all 0.2s ease;
        }

        .icon-btn.edit {
            background: var(--info-bg);
            color: var(--info-text);
        }

        .icon-btn.edit:hover {
            background: #bfdbfe;
        }

        .icon-btn.delete {
            background: var(--error-bg);
            color: var(--error-text);
        }

        .icon-btn.delete:hover {
            background: #fecaca;
        }

        /* Pagination */
        .pagination {
            margin-top: 20px;
            text-align: center;
        }

        .pagination a {
            display: inline-block;
            padding: 8px 12px;
            margin: 0 4px;
            border-radius: 6px;
            text-decoration: none;
            background: var(--border-color);
            color: var(--text-color);
            transition: all 0.2s ease;
            font-size: 14px;
        }

        .pagination a:hover,
        .pagination a.active {
            background: var(--primary-color);
            color: white;
        }

        /* Toast */
        .toast {
            position: fixed;
            top: 20px;
            right: 20px;
            max-width: 350px;
            width: 90%;
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

        .toast.success {
            background: var(--success-bg);
            color: var(--success-text);
        }

        .toast.error {
            background: var(--error-bg);
            color: var(--error-text);
        }

        .toast.warning {
            background: var(--warning-bg);
            color: var(--warning-text);
        }

        .toast.info {
            background: var(--info-bg);
            color: var(--info-text);
        }

        .toast::before {
            content: "✔";
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
            font-weight: bold;
        }

        .toast.error::before {
            content: "✘";
        }

        .toast.warning::before {
            content: "⚠";
        }

        .toast.info::before {
            content: "ℹ";
        }

        .toast.hide {
            animation: toastOut 0.4s ease forwards;
        }

        @keyframes toastIn {
            from {
                opacity: 0;
                transform: translateX(100%);
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
                transform: translateX(100%);
            }
        }

        /* Delete Confirmation Modal */
        #deleteModal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal-content {
            background:#c3cfe2;
            padding: 25px;
            border-radius: 10px;
            width: 100%;
            max-width: 320px;
            text-align: center;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
        }

        .modal-content h3 {
            margin: 0 0 10px;
            color: var(--text-color);
        }

        .modal-content p {
            color: #6b7280;
            margin-bottom: 20px;
        }

        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .modal-buttons button {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s ease;
        }

        .btn-cancel {
            background: var(--border-color);
            color: var(--text-color);
        }

        .btn-cancel:hover {
            background: #d1d5db;
        }

        .btn-delete {
            background: #dc2626;
            color: white;
        }

        .btn-delete:hover {
            background: #b91c1c;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .page {
                padding: 10px;
                border-radius: 0;
            }

            h2 {
                font-size: 18px;
                margin-bottom: 15px;
            }

            th,
            td {
                padding: 8px 12px;
                font-size: 13px;
            }

            .icon-btn {
                width: 28px;
                height: 28px;
                font-size: 12px;
            }

            .pagination a {
                padding: 6px 10px;
                font-size: 13px;
                margin: 0 2px;
            }

            .toast {
                right: 10px;
                left: 10px;
                max-width: none;
                width: auto;
                font-size: 14px;
            }

            .modal-content {
                padding: 20px;
                max-width: none;
                width: 100%;
            }

            .modal-buttons {
                flex-direction: column;
            }

            .modal-buttons button {
                width: 100%;
            }
        }

        @media (max-width: 480px) {
            th,
            td {
                padding: 6px 8px;
                font-size: 12px;
            }

            .badge {
                font-size: 11px;
                padding: 3px 8px;
            }
        }
    </style>
</head>
<body>

<div class="page">
    <h2>User List</h2>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Joined Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%= request.getAttribute("rows") != null
                        ? request.getAttribute("rows")
                        : "<tr><td colspan='7' class='empty'>No Data Found</td></tr>" %>
            </tbody>
        </table>
    </div>

    <div class="pagination">
        <%
            int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
            int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;

            for (int i = 1; i <= totalPages; i++) {
        %>
        <a href="viewUser?page=<%= i %>"
           class="<%= i == currentPage ? "active" : "" %>">
            <%= i %>
        </a>
        <%
            }
        %>
    </div>
</div>

<div id="toast" class="toast"></div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal">
    <div class="modal-content">
        <h3>Delete Employee</h3>
        <p>Are you sure you want to delete this employee?</p>
        <div class="modal-buttons">
            <button class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
            <button class="btn-delete" onclick="confirmDelete()">Delete</button>
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
    } else if (msg === "error") {
        showToast("Failed to delete user", "error");
    } else if (msg === "updated") {
        showToast("User updated successfully", "success");
    }

    // Disable right-click and dev tools shortcuts
    document.addEventListener('contextmenu', e => e.preventDefault());
    document.onkeydown = e =>
        e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I', 'J', 'C'].includes(e.key.toUpperCase()))
            ? e.preventDefault()
            : true;
</script>

</body>
</html>