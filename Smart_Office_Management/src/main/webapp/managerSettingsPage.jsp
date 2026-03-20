<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.User"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}

User userObj = (User) request.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settings</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-4xl mx-auto">
		<div class="flex items-center gap-3 mb-6">
			<i class="fa-solid fa-gear text-indigo-600 text-4xl"></i>
			<div>
				<h1 class="text-3xl font-bold text-slate-800">Settings</h1>
				<p class="text-slate-600">Manage your profile and account preferences.</p>
			</div>
		</div>

		<!-- Tabs -->
		<div class="flex border-b border-slate-200 mb-6">
			<button onclick="showTab('profile')" id="profileTab"
				class="tab-button px-6 py-3 font-semibold text-indigo-600 border-b-2 border-indigo-600">
				<i class="fa-solid fa-user mr-2"></i>My Profile
			</button>
			<button onclick="showTab('password')" id="passwordTab"
				class="tab-button px-6 py-3 font-semibold text-slate-600 hover:text-slate-900">
				<i class="fa-solid fa-lock mr-2"></i>Change Password
			</button>
		</div>

		<!-- Profile Tab -->
		<div id="profileContent" class="bg-slate-50 rounded-2xl p-8 shadow-sm">
			<div class="space-y-6">
				<!-- Full Name -->
				<div class="flex items-center gap-6 px-5 py-5 bg-white rounded-2xl hover:shadow-md transition-shadow">
					<div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
						<i class="fa-solid fa-user text-2xl"></i>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-slate-500 mb-1">Full Name</p>
						<p class="text-xl font-semibold text-slate-900">
							<%=userObj != null && userObj.getFullname() != null && !userObj.getFullname().isEmpty() 
								? userObj.getFullname() : "--"%>
						</p>
					</div>
				</div>

				<!-- Email -->
				<div class="flex items-center gap-6 px-5 py-5 bg-white rounded-2xl hover:shadow-md transition-shadow">
					<div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
						<i class="fa-solid fa-envelope text-2xl"></i>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-slate-500 mb-1">Email</p>
						<p class="text-xl font-semibold text-slate-900">
							<%=userObj != null ? userObj.getEmail() : "--"%>
						</p>
					</div>
				</div>

				<!-- Role -->
				<div class="flex items-center gap-6 px-5 py-5 bg-white rounded-2xl hover:shadow-md transition-shadow">
					<div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
						<i class="fa-solid fa-briefcase text-2xl"></i>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-slate-500 mb-1">Role</p>
						<p class="text-xl font-semibold text-slate-900">
							<%=userObj != null ? userObj.getRole() : "Manager"%>
						</p>
					</div>
				</div>

				<!-- Phone -->
				<div class="flex items-center gap-6 px-5 py-5 bg-white rounded-2xl hover:shadow-md transition-shadow">
					<div class="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-2xl flex items-center justify-center flex-shrink-0">
						<i class="fa-solid fa-phone text-2xl"></i>
					</div>
					<div class="flex-1">
						<p class="text-sm font-medium text-slate-500 mb-1">Phone</p>
						<p class="text-xl font-semibold text-slate-900">
							<%=userObj != null && userObj.getPhone() != null ? userObj.getPhone() : "--"%>
						</p>
					</div>
				</div>
			</div>
		</div>

		<!-- Password Tab -->
		<div id="passwordContent" class="hidden bg-white rounded-2xl p-8 shadow-sm">
			<div class="max-w-md mx-auto">
				<h3 class="text-lg font-semibold text-slate-800 mb-6">Change Password</h3>
				
				<form id="changePasswordForm" class="space-y-4">
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">New Password</label>
						<input type="password" id="newPassword" placeholder="Enter new password" required
							class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Confirm Password</label>
						<input type="password" id="confirmPassword" placeholder="Confirm new password" required
							class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<button type="submit"
						class="w-full px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors">
						<i class="fa-solid fa-lock mr-2"></i>Update Password
					</button>
				</form>
			</div>
		</div>
	</div>

	<!-- Toast Notification -->
	<div id="toast" 
		class="fixed top-4 right-4 px-6 py-4 rounded-lg shadow-lg hidden transform transition-all duration-300">
	</div>

	<script>
	function showTab(tab) {
		const profileContent = document.getElementById('profileContent');
		const passwordContent = document.getElementById('passwordContent');
		const profileTab = document.getElementById('profileTab');
		const passwordTab = document.getElementById('passwordTab');

		if (tab === 'profile') {
			profileContent.classList.remove('hidden');
			passwordContent.classList.add('hidden');
			profileTab.classList.add('text-indigo-600', 'border-b-2', 'border-indigo-600');
			profileTab.classList.remove('text-slate-600');
			passwordTab.classList.remove('text-indigo-600', 'border-b-2', 'border-indigo-600');
			passwordTab.classList.add('text-slate-600');
		} else {
			profileContent.classList.add('hidden');
			passwordContent.classList.remove('hidden');
			passwordTab.classList.add('text-indigo-600', 'border-b-2', 'border-indigo-600');
			passwordTab.classList.remove('text-slate-600');
			profileTab.classList.remove('text-indigo-600', 'border-b-2', 'border-indigo-600');
			profileTab.classList.add('text-slate-600');
		}
	}

	function showToast(message, type = 'success') {
		const toast = document.getElementById('toast');
		toast.className = 'fixed top-4 right-4 px-6 py-4 rounded-lg shadow-lg transform transition-all duration-300';
		
		if (type === 'success') {
			toast.classList.add('bg-emerald-500', 'text-white');
		} else {
			toast.classList.add('bg-red-500', 'text-white');
		}
		
		toast.textContent = message;
		toast.classList.remove('hidden');
		
		setTimeout(() => {
			toast.classList.add('hidden');
		}, 3000);
	}

	// Password change form
	document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
		e.preventDefault();
		
		const newPassword = document.getElementById('newPassword').value.trim();
		const confirmPassword = document.getElementById('confirmPassword').value.trim();

		if (!newPassword || !confirmPassword) {
			showToast('Please fill all fields', 'error');
			return;
		}

		if (newPassword !== confirmPassword) {
			showToast('Passwords do not match', 'error');
			return;
		}

		fetch('<%=request.getContextPath()%>/changePassword', {
			method: 'POST',
			headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
			body: new URLSearchParams({
				newPassword: newPassword,
				confirmPassword: confirmPassword
			})
		})
		.then(res => res.text())
		.then(response => {
			switch(response.trim()) {
				case 'Success':
					showToast('Password updated successfully');
					document.getElementById('changePasswordForm').reset();
					break;
				case 'PasswordMismatch':
					showToast('Passwords do not match', 'error');
					break;
				case 'MissingFields':
					showToast('All fields are required', 'error');
					break;
				case 'Unauthorized':
					showToast('Session expired. Please login again', 'error');
					break;
				default:
					showToast('Something went wrong', 'error');
			}
		})
		.catch(() => {
			showToast('Server error', 'error');
		});
	});

	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
