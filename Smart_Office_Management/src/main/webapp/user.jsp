<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Employee Dashboard</title>
<style type="text/css">
	body{
	text-align: center;
	}
</style>
</head>
<body>
	<h2>Hello Employee</h2>
	<a href="<%= request.getContextPath() %>/logout">
		<button>Logout</button>
	</a>
</body>
</html>