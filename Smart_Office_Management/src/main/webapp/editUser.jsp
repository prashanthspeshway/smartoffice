<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Check</title>

<style>
    body {
        margin: 0;
        padding: 0;
        font-family: Arial, sans-serif;
        background-color: #f5f6fa;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }

    .card {
        background: #ffffff;
        width: 360px;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    .card h2 {
        margin-bottom: 20px;
        font-size: 20px;
        text-align: center;
        color: #2c3e50;
    }

    label {
        font-size: 14px;
        color: #555;
        display: block;
        margin-bottom: 6px;
    }

    input[type="text"] {
        width: 100%;
        padding: 10px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 4px;
        box-sizing: border-box;
    }

    input[type="text"]:focus {
        outline: none;
        border-color: #4a6cf7;
    }

    button {
        width: 100%;
        margin-top: 20px;
        padding: 10px;
        font-size: 15px;
        border: none;
        border-radius: 4px;
        background-color: #4a6cf7;
        color: #fff;
        cursor: pointer;
    }

    button:hover {
        background-color: #3b5bdb;
    }
</style>
</head>

<body>
    <div class="card">
        <h2>User Verification</h2>

        <form action="UserCheck" method="post">
            <label for="username">User Name</label>
            <input type="text" name="username" id="username" required>

            <button type="submit">Submit</button>
        </form>
    </div>
</body>
</html>
