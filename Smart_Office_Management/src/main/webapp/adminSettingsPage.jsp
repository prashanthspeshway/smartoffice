<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settings • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>body { font-family: 'Geist', system-ui, sans-serif; }</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-2xl mx-auto">
	<h1 class="text-2xl font-semibold text-slate-800 mb-6 flex items-center gap-2">
		<i class="fa-solid fa-gear text-indigo-500"></i>
		Settings
	</h1>

	<div class="space-y-6">
		<!-- My Profile Card -->
		<div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
			<h2 class="text-lg font-semibold text-slate-800 mb-2">My Profile</h2>
			<p class="text-slate-500 text-sm mb-4">View and manage your profile information.</p>
			<button type="button" onclick="loadProfile()" class="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors">
				<i class="fa-solid fa-user"></i>
				Open My Profile
			</button>
		</div>

		<!-- Designations Card -->
		<div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
			<h2 class="text-lg font-semibold text-slate-800 mb-2">Designations</h2>
			<p class="text-slate-500 text-sm mb-4">Add designations for employees. These appear in the Employee designation dropdown.</p>

			<form action="<%=request.getContextPath()%>/manageDesignations" method="post" class="flex gap-3 items-end flex-wrap">
				<div class="flex-1 min-w-[220px]">
					<label class="block text-sm font-medium text-slate-700 mb-1.5">New Designation</label>
					<input type="text" name="name" placeholder="e.g. Software Engineer" required
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<button type="submit" class="px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors">
					<i class="fa-solid fa-plus"></i> Add
				</button>
			</form>

			<div class="mt-5">
				<div class="flex items-center justify-between mb-2">
					<h3 class="text-sm font-semibold text-slate-800">Active designations</h3>
					<button type="button" onclick="loadDesignations()" class="text-sm text-indigo-600 hover:text-indigo-700 font-medium">Refresh</button>
				</div>
				<div id="designationList" class="space-y-2"></div>
				<p id="designationEmpty" class="hidden text-sm text-slate-500">No designations yet.</p>
			</div>
		</div>

		<!-- Change Password Card -->
		<div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
			<h2 class="text-lg font-semibold text-slate-800 mb-2">Change Password</h2>
			<p class="text-slate-500 text-sm mb-4">Update your account password.</p>
			<form id="pwdForm" onsubmit="return submitPassword(event)" class="space-y-4">
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">New Password</label>
					<input type="password" id="newPassword" placeholder="Enter new password" required
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Confirm Password</label>
					<input type="password" id="confirmPassword" placeholder="Confirm new password" required
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<button type="submit" class="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors">
					Update Password
				</button>
			</form>
		</div>
	</div>
</div>

<script>
function loadProfile() {
	var frame = window.parent && window.parent.document && window.parent.document.getElementById('contentFrame');
	if (frame) frame.src = 'selfProfile';
}

function submitPassword(e) {
	e.preventDefault();
	var newPwd = document.getElementById('newPassword').value.trim();
	var confirmPwd = document.getElementById('confirmPassword').value.trim();
	if (newPwd !== confirmPwd) {
		if (window.parent.showToast) window.parent.showToast('Passwords do not match', 'error');
		else alert('Passwords do not match');
		return false;
	}
	fetch('<%=request.getContextPath()%>/changePassword', {
		method: 'POST',
		headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
		body: new URLSearchParams({ newPassword: newPwd, confirmPassword: confirmPwd })
	})
	.then(function(r) { return r.text(); })
	.then(function(data) {
		if (data === 'Success') {
			if (window.parent.showToast) window.parent.showToast('Password updated successfully', 'success');
			else alert('Password updated');
			document.getElementById('newPassword').value = '';
			document.getElementById('confirmPassword').value = '';
		} else if (data === 'PasswordMismatch') {
			if (window.parent.showToast) window.parent.showToast('Passwords do not match', 'error');
			else alert('Passwords do not match');
		} else if (data === 'MissingFields') {
			if (window.parent.showToast) window.parent.showToast('Please fill all fields', 'warning');
			else alert('Please fill all fields');
		} else {
			if (window.parent.showToast) window.parent.showToast('Password must be 8+ chars with uppercase, lowercase, number, symbol', 'error');
			else alert('Invalid password format');
		}
	})
	.catch(function() {
		if (window.parent.showToast) window.parent.showToast('Server error', 'error');
		else alert('Server error');
	});
	return false;
}

function loadDesignations() {
    fetch('<%=request.getContextPath()%>/manageDesignations')
        .then(function(r) { return r.json(); })
        .then(function(list) {
            var wrap  = document.getElementById('designationList');
            var empty = document.getElementById('designationEmpty');
            wrap.innerHTML = '';
            if (!list || list.length === 0) {
                empty.classList.remove('hidden');
                return;
            }
            empty.classList.add('hidden');
            list.forEach(function(name) {
                var row = document.createElement('div');
                row.className = 'flex items-center justify-between p-3 rounded-lg border border-slate-200 bg-slate-50';
                row.innerHTML =
                    '<div class="font-medium text-slate-800">' + escapeHtml(name) + '</div>' +
                    '<button type="button" class="px-3 py-1.5 text-sm bg-white border border-slate-300 hover:bg-red-50 hover:border-red-300 hover:text-red-600 text-slate-700 rounded-lg transition-colors">' +
                    '<i class="fa-solid fa-trash mr-1"></i>Remove</button>';

                // ✅ FIX: attach click with the actual name variable — no form, no redirect
                row.querySelector('button').addEventListener('click', function() {
                    removeDesignation(name, row);
                });
                wrap.appendChild(row);
            });
        })
        .catch(function() {
            document.getElementById('designationList').innerHTML =
                '<p class="text-sm text-red-600">Unable to load designations</p>';
        });
}

function removeDesignation(name, rowEl) {
    // Optimistic UI — remove the row immediately
    rowEl.style.opacity = '0.4';
    rowEl.style.pointerEvents = 'none';

    var params = new URLSearchParams();
    params.append('action', 'deactivate');
    params.append('name', name);   // ✅ name passed directly — no HTML escaping issues

    fetch('<%=request.getContextPath()%>/manageDesignations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(function(r) {
        // Servlet redirects (302) — fetch follows it, response is the redirected page HTML
        // We don't care about the response body, just reload the list
        loadDesignations();
        // Show toast if available
        if (window.parent && window.parent.showToast) {
            window.parent.showToast('Designation removed', 'success');
        }
    })
    .catch(function() {
        // Restore row on failure
        rowEl.style.opacity = '1';
        rowEl.style.pointerEvents = '';
        if (window.parent && window.parent.showToast) {
            window.parent.showToast('Failed to remove designation', 'error');
        }
    });
}

function escapeHtml(s){ return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;').replace(/'/g,'&#39;'); }
function escapeAttr(s){ return String(s || '').replace(/\"/g,'&quot;').replace(/'/g,'&#39;'); }

document.addEventListener('DOMContentLoaded', function() {
	loadDesignations();
});
</script>
</body>
</html>
