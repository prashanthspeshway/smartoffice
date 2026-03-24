<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.User"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
User userObj = (User) request.getAttribute("user");
// If loaded in iframe, user attr may not be set — fallback to session
String fullName = userObj != null ? userObj.getFullname() : (String) session.getAttribute("fullName");
String email    = userObj != null ? userObj.getEmail()    : (String) session.getAttribute("email");
String role     = userObj != null ? userObj.getRole()     : (String) session.getAttribute("role");
String phone    = userObj != null ? userObj.getPhone()    : (String) session.getAttribute("phone");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Settings</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
</head>
<body class="user-iframe-page p-6">

<div class="max-w-3xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-gear mr-2 text-indigo-500"></i>Settings</h2>
        <p class="text-slate-500 text-sm mt-1">Manage your profile and account preferences.</p>
    </div>

    <!-- Toast -->
    <div id="toast" class="fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg hidden text-sm font-medium max-w-[min(92vw,24rem)]"></div>

    <!-- Inner tabs -->
    <div class="flex gap-1 border-b border-slate-200">
        <button id="tabProfile" onclick="showTab('profile')" class="px-5 py-3 text-sm font-semibold text-indigo-600 border-b-2 border-indigo-600 -mb-px bg-transparent">
            <i class="fa-solid fa-user mr-1.5"></i>My Profile
        </button>
        <button id="tabPassword" onclick="showTab('password')" class="px-5 py-3 text-sm font-semibold text-slate-500 border-b-2 border-transparent -mb-px hover:text-slate-700 bg-transparent">
            <i class="fa-solid fa-lock mr-1.5"></i>Change Password
        </button>
    </div>

    <!-- Profile -->
    <div id="contentProfile">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 max-w-lg">
            <div class="divide-y divide-slate-100">
                <div class="flex justify-between items-center py-4 text-sm">
                    <span class="flex items-center gap-2 font-semibold text-slate-500"><i class="fa-solid fa-id-card text-indigo-400 w-4 text-center"></i>Full Name</span>
                    <span class="font-semibold text-slate-800"><%=fullName != null && !fullName.isEmpty() ? fullName : "--"%></span>
                </div>
                <div class="flex justify-between items-center py-4 text-sm">
                    <span class="flex items-center gap-2 font-semibold text-slate-500"><i class="fa-solid fa-envelope text-indigo-400 w-4 text-center"></i>Email</span>
                    <span class="font-semibold text-slate-800"><%=email != null ? email : "--"%></span>
                </div>
                <div class="flex justify-between items-center py-4 text-sm">
                    <span class="flex items-center gap-2 font-semibold text-slate-500"><i class="fa-solid fa-briefcase text-indigo-400 w-4 text-center"></i>Role</span>
                    <span class="font-semibold text-slate-800"><%=role != null ? role : "--"%></span>
                </div>
                <div class="flex justify-between items-center py-4 text-sm">
                    <span class="flex items-center gap-2 font-semibold text-slate-500"><i class="fa-solid fa-phone text-indigo-400 w-4 text-center"></i>Phone</span>
                    <span class="font-semibold text-slate-800"><%=phone != null ? phone : "--"%></span>
                </div>
            </div>
        </div>
    </div>

    <!-- Change Password -->
    <div id="contentPassword" class="hidden">
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6 max-w-sm">
            <h4 class="font-bold text-slate-800 mb-5 flex items-center gap-2">
                <i class="fa-solid fa-lock text-indigo-500"></i> Update Password
            </h4>
            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">New Password</label>
                    <input type="password" id="cpNew" placeholder="Enter new password" class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Confirm Password</label>
                    <input type="password" id="cpConfirm" placeholder="Confirm new password" class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300">
                </div>
                <button onclick="submitPassword()" class="w-full py-3 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-bold transition-colors flex items-center justify-center gap-2">
                    <i class="fa-solid fa-floppy-disk"></i> Update Password
                </button>
            </div>
        </div>
    </div>
</div>

<script>
function showTab(tab) {
    document.getElementById('contentProfile').classList.toggle('hidden', tab !== 'profile');
    document.getElementById('contentPassword').classList.toggle('hidden', tab !== 'password');
    var active = 'px-5 py-3 text-sm font-semibold text-indigo-600 border-b-2 border-indigo-600 -mb-px bg-transparent';
    var inactive = 'px-5 py-3 text-sm font-semibold text-slate-500 border-b-2 border-transparent -mb-px hover:text-slate-700 bg-transparent';
    document.getElementById('tabProfile').className  = tab === 'profile'  ? active : inactive;
    document.getElementById('tabPassword').className = tab === 'password' ? active : inactive;
}

function showToast(msg, type) {
    const t = document.getElementById('toast');
    t.className = 'fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-sm font-medium max-w-[min(92vw,24rem)]';
    t.classList.add(type === 'success' ? 'bg-emerald-500' : 'bg-red-500', 'text-white');
    t.textContent = msg;
    t.classList.remove('hidden');
    setTimeout(() => t.classList.add('hidden'), 2500);
}

function submitPassword() {
    var np = document.getElementById('cpNew').value.trim();
    var cp = document.getElementById('cpConfirm').value.trim();
    if (!np || !cp) { showToast('Please fill all fields', 'error'); return; }
    fetch('<%=request.getContextPath()%>/changePassword', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ newPassword: np, confirmPassword: cp })
    })
    .then(r => r.text())
    .then(data => {
        const msgs = { Success:'Password updated successfully', PasswordMismatch:'Passwords do not match', MissingFields:'All fields are required', Unauthorized:'Session expired.' };
        const type = data === 'Success' ? 'success' : 'error';
        showToast(msgs[data] || 'Something went wrong', type);
        if (data === 'Success') { document.getElementById('cpNew').value = ''; document.getElementById('cpConfirm').value = ''; }
    })
    .catch(() => showToast('Server error', 'error'));
}
</script>
</body>
</html>
