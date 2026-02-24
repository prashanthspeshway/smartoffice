<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>My Profile</title>

<style>
.profile-card {
	max-width: 420px;
	margin: 40px auto;
	background: white;
	padding: 25px;
	border-radius: 10px;
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
}

.profile-item {
	margin-bottom: 12px;
	font-size: 15px;
}

.profile-item span {
	font-weight: bold;
	color: #2563eb;
}
</style>
</head>

<body>
	<div class="profile-card">
		<h3>👤 My Profile</h3>

		<div class="profile-item">
			Name: <span>${user.fullname}</span>
		</div>
		<div class="profile-item">
			Username: <span>${user.username}</span>
		</div>
		<div class="profile-item">
			Email: <span>${user.email}</span>
		</div>
		<div class="profile-item">
			Role: <span>${user.role}</span>
		</div>
		<div class="profile-item">
			Phone: <span>${user.phone}</span>
		</div>
	</div>
</body>
</html>