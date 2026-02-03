<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
hello add user
<form action="addUser" method="post">
username: <input type="text" name="username"/><br/><br>
password: <input type="password" name="password"/><br/><br>
role:
<select name="role">
    <option value="admin">Admin</option>
    <option value="manager">Manager</option>
    <option value="user">User</option>
</select>
<br/><br>

status:
<select name="status">
    <option value="active">Active</option>
    <option value="inactive">Inactive</option>
</select><br><br>

Full Name: <input type="text" name="fullname" required="required"/><br/><br>
Email: <input type="email" name="email"/><br/><br>
Joined Date: <input type="date" name="joinedDate"/><br/><br>

<button type="submit">Add User</button>
<br/>
</form>
</body>
</html>