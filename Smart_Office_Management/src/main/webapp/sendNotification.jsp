<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Send Notification</title>

<style>
.form-container {
	width: 50%;
	height: 50vh;
	margin: 40px auto;
	background: #ffffff;
	padding: 50px;
	border-radius: 10px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.form-container h3 {
	margin-bottom: 20px;
	text-align: center;
}

.form-group {
	margin-bottom: 15px;
}

.form-group input, .form-group textarea {
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
	width: 105%;
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
/* ===== DARK MODE ===== */
body.dark-theme {
	background: #121212 !important;
}

body.dark-theme .form-container {
	background: #1e1e1e !important;
	color: #ffffff !important;
}

body.dark-theme .form-container h3 {
	color: #ffffff !important;
}

body.dark-theme input, body.dark-theme textarea {
	background: #2c2c2c !important;
	color: #ffffff !important;
	border: 1px solid #555 !important;
}
</style>
</head>

<body>

	<div class="form-container">
		<h3>📢 Send Notification</h3>

		<form action="addNotification" method="post">
			<div class="form-group">
				<input type="text" name="message" placeholder="Notification message"
					required>
			</div>

			<button type="submit">Send Notification</button>
		</form>
	</div>

	<div id="toast"
		style="position: fixed; top: 80px; right: 20px; background: #10b981; color: white; padding: 12px 18px; border-radius: 8px; font-size: 14px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2); opacity: 0; transform: translateY(-10px); transition: all 0.4s ease; z-index: 9999;">
		Notification sent successfully</div>

	<script>
function showToast(message) {
	const toast = document.getElementById("toast");
	toast.innerText = message;

	toast.style.opacity = "1";
	toast.style.transform = "translateY(0)";

	setTimeout(() => {
		toast.style.opacity = "0";
		toast.style.transform = "translateY(-10px)";
	}, 2500);
}

/* Show toast if redirected with success */
window.onload = function () {
	const params = new URLSearchParams(window.location.search);
	if (params.get("success") === "true") {
		showToast("Notification sent successfully");
		// optional: clean URL
		window.history.replaceState({}, document.title, window.location.pathname);
	}
};
</script>

</body>
</html>