<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reset Password</title>
</head>
<body>
    <h2>Reset Password</h2>
    <c:if test="${not empty errorMessage}">
    <div style="color:red">${errorMessage}</div>
</c:if>
    <form action="ResetPasswordServlet" method="post">
        <input type="hidden" name="token" value="<%= request.getParameter("token") %>"/>
        New Password: <input type="password" name="password" required /><br/>
        Confirm Password: <input type="password" name="confirmPassword" required /><br/>
        <button type="submit">Reset Password</button>
    </form>
</body>
</html>
 