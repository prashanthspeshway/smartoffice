<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Send Notification</title>

<style>
.form-container {
    max-width: 450px;
    margin: 40px auto;
    background: #ffffff;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.form-container h3 {
    margin-bottom: 20px;
    text-align: center;
}

.form-group {
    margin-bottom: 15px;
}

.form-group input,
.form-group textarea {
    width: 100%;
    padding: 10px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.form-group textarea {
    resize: none;
    height: 100px;
}

.form-container button {
    width: 100%;
    padding: 10px;
    border: none;
    background: #3b82f6;
    color: white;
    font-size: 15px;
    border-radius: 6px;
    cursor: pointer;
}

.form-container button:hover {
    background: #2563eb;
}
</style>
</head>

<body>

<div class="form-container">
    <h3>📢 Send Notification</h3>

    <form action="addNotification" method="post">
        <div class="form-group">
            <input type="text" name="message"
                   placeholder="Notification message" required>
        </div>

        <button type="submit">Send Notification</button>
    </form>
</div>

</body>
</html>