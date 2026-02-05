<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit User</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background-color: #f4f6f8;
        }

        .topbar {
            background-color: #1f2933;
            color: white;
            padding: 16px 30px;
            font-size: 18px;
            font-weight: 600;
        }

        .container {
            max-width: 420px;
            margin: 50px auto;
            background: white;
            padding: 28px;
            border-radius: 12px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }

        h2 {
            text-align: center;
            margin-bottom: 22px;
            color: #333;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-size: 14px;
            color: #555;
            font-weight: 500;
        }

        input, select {
            width: 100%;
            height: 42px;
            padding: 0 12px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
            background-color: #fafafa;
        }

        input:focus, select:focus {
            outline: none;
            border-color: #3b82f6;
            background-color: #fff;
        }

        .btn {
            width: 100%;
            height: 44px;
            background-color: #3b82f6;
            border: none;
            color: white;
            font-size: 15px;
            border-radius: 8px;
            cursor: pointer;
            margin-top: 12px;
            font-weight: 500;
        }

        .btn:hover {
            background-color: #2563eb;
        }
    </style>
</head>

<body>

<div class="topbar">
    Smart Office • Edit User
</div>

<div class="container">
    <h2>Edit User</h2>

    <form action="editUserDetails" method="post">

        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" value="${user.username}" required>
        </div>

        <div class="form-group">
            <label>Role</label>
            <select name="role" required>
                <option value="">-- Select Role --</option>
                <option value="admin"   ${user.role == 'admin' ? 'selected' : ''}>Admin</option>
                <option value="manager" ${user.role == 'manager' ? 'selected' : ''}>Manager</option>
                <option value="user"    ${user.role == 'user' ? 'selected' : ''}>User</option>
            </select>
        </div>

        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="fullname" value="${user.fullname}" required>
        </div>

        <div class="form-group">
            <label>Email</label>
            <input type="email" name="email" value="${user.email}" required>
        </div>

        <div class="form-group">
            <label>Joined Date</label>
            <input type="date" name="joinedDate" value="${user.joinedDate}">
        </div>

        <button type="submit" class="btn">Update User</button>
    </form>
</div>

</body>
</html>
