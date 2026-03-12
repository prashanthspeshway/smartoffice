<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.List"%>
<%
List<String> designations = (List<String>) request.getAttribute("designations");
if (designations == null) designations = java.util.Collections.emptyList();
String currentDesignation = (String) request.getAttribute("designation");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Employee • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-2xl mx-auto">
	<!-- Pill-style title -->
	<div class="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-indigo-100 text-indigo-700 font-semibold text-lg mb-6">
		<i class="fa-solid fa-user-pen"></i> Edit Employee
	</div>

	<div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
		<form action="editUser" method="post">
			<input type="hidden" name="id" value="${id}">

			<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Email</label>
					<input type="email" name="email" value="${email}" required readonly class="w-full px-4 py-2.5 border border-slate-300 rounded-lg bg-slate-50 text-slate-600 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Role</label>
					<select name="role" id="roleSelect" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
						<option value="manager" ${role eq 'manager' ? 'selected' : ''}>Manager</option>
						<option value="employee" ${(role eq 'user' or role eq 'employee') ? 'selected' : ''}>Employee</option>
					</select>
				</div>
				<div id="designationWrap" class="hidden">
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Designation</label>
					<select name="designation" id="designationSelect" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
						<option value="">Select Designation</option>
						<%
							for (String d : designations) {
								String esc = d != null ? d.replace("\"", "&quot;").replace("'", "&#39;") : "";
								boolean sel = currentDesignation != null && currentDesignation.equalsIgnoreCase(d);
						%>
							<option value="<%= esc %>" <%= sel ? "selected" : "" %>><%= d %></option>
						<% } %>
					</select>
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Status</label>
					<select name="status" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
						<option value="active" ${status eq 'active' ? 'selected' : ''}>Active</option>
						<option value="inactive" ${status eq 'inactive' ? 'selected' : ''}>Inactive</option>
					</select>
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">First Name</label>
					<input type="text" name="firstname" value="${firstname}" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Last Name</label>
					<input type="text" name="lastname" value="${lastname}" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Phone Number</label>
					<input type="text" name="number" value="${phone}" maxlength="10" pattern="[0-9]*" placeholder="Up to 10 digits" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-1.5">Joined Date</label>
					<input type="date" name="joinedDate" value="${joinedDate}" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
				</div>
			</div>

			<div class="mt-6 flex gap-3">
				<button type="submit" class="inline-flex items-center gap-2 px-6 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium transition-colors">
					<i class="fa-solid fa-floppy-disk"></i> Update Employee
				</button>
				<a href="viewUser" class="inline-flex items-center gap-2 px-6 py-2.5 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg font-medium transition-colors">
					Cancel
				</a>
			</div>
		</form>
	</div>
</div>

<script>
function syncDesignationVisibility() {
	var roleSel = document.getElementById('roleSelect');
	var wrap = document.getElementById('designationWrap');
	if (!roleSel || !wrap) return;
	if ((roleSel.value || '').toLowerCase() === 'employee') wrap.classList.remove('hidden');
	else wrap.classList.add('hidden');
}
document.addEventListener('DOMContentLoaded', function() {
	var roleSel = document.getElementById('roleSelect');
	if (roleSel) roleSel.addEventListener('change', syncDesignationVisibility);
	syncDesignationVisibility();
});
document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
</script>
</body>
</html>
