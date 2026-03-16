<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Collections"%>

<%!
  private static String h(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
  }
%>

<%
String successMsg = (String) session.getAttribute("successMsg");
String errorMsg = (String) session.getAttribute("errorMsg");
session.removeAttribute("successMsg");
session.removeAttribute("errorMsg");

List<String> designations = (List<String>) request.getAttribute("designations");
if (designations == null) designations = Collections.emptyList();

String successSafe = h(successMsg);
String errorSafe = h(errorMsg);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Employee • Smart Office HRMS</title>

  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    body { font-family: 'Inter', system-ui, sans-serif; }
  </style>
</head>

<body class="min-h-screen bg-gradient-to-br from-indigo-50 via-slate-50 to-emerald-50 px-4 py-6 sm:p-6 lg:p-10">
  <!-- Toast -->
  <div
    id="toast"
    class="fixed top-4 right-4 z-50 hidden max-w-[92vw] sm:max-w-md px-4 sm:px-6 py-3 sm:py-4 rounded-xl shadow-lg text-sm font-medium break-words"
    data-success="<%= successSafe %>"
    data-error="<%= errorSafe %>"
    role="status"
    aria-live="polite"
  ></div>

  <div class="mx-auto w-full max-w-4xl">
    <!-- Header -->
    <div class="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between mb-6">
      <div>
        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/70 backdrop-blur border border-indigo-200 text-indigo-700 font-semibold text-base sm:text-lg shadow-sm">
          <i class="fa-solid fa-user-plus"></i> Add Employee
        </div>
        <p class="text-slate-500 text-sm mt-2">Create a new employee account</p>
      </div>

      <div class="flex flex-col sm:flex-row gap-3">

							<button
							type="button"
							onclick="window.parent.loadPage(null,'viewUser')"
							class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border border-slate-200 bg-white/80 backdrop-blur text-slate-700 hover:bg-white font-medium transition-colors w-full sm:w-auto">
							
							<i class="fa-solid fa-arrow-left"></i> Back
							
							</button>
							
	</div>

    </div>

    <!-- Add Employee Form (fit screen) -->
    <div class="bg-white/80 backdrop-blur rounded-2xl shadow-sm border border-slate-200 p-5 sm:p-6">
      <form id="addEmployeeForm" action="<%= request.getContextPath() %>/addUser" method="post" class="space-y-6">
        <div class="flex items-center justify-between gap-3">
          <h2 class="text-base sm:text-lg font-semibold text-slate-800">Employee details</h2>
          <span class="text-xs text-slate-500">Fields marked <span class="text-red-500 font-semibold">*</span> are required</span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">First Name <span class="text-red-500">*</span></label>
            <input
              id="firstname"
              type="text"
              name="firstname"
              required
              autocomplete="given-name"
              placeholder="First name"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Last Name <span class="text-red-500">*</span></label>
            <input
              id="lastname"
              type="text"
              name="lastname"
              required
              autocomplete="family-name"
              placeholder="Last name"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
          </div>

          <div class="sm:col-span-2">
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Email <span class="text-red-500">*</span></label>
            <input
              id="email"
              type="email"
              name="email"
              required
              autocomplete="email"
              placeholder="email@example.com"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
          </div>

          <div >
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Phone Number<span class="text-red-500">*</span></label>
            <input
              id="phonenumber"
              type="tel"
              name="phonenumber"
              required
              inputmode="numeric"
              autocomplete="tel"
              placeholder="10 digits"
              maxlength="10"
              pattern="[0-9]{10}"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
            <p class="text-xs text-slate-400 mt-1">Digits only (10). Leave empty if not available.</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Role <span class="text-red-500">*</span></label>
            <select
              name="role"
              id="role"
              required
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
              <option value="">Select Role</option>
              <option value="manager">Manager</option>
              <option value="employee">Employee</option>
            </select>
          </div>

          <div id="designationWrap" class="hidden sm:col-span-2">
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Designation <span class="text-red-500">*</span></label>
            <select
              name="designation"
              id="designation"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
              <option value="">Select Designation</option>
              <% for (String d : designations) { %>
                <option value="<%= h(d) %>"><%= h(d) %></option>
              <% } %>
            </select>
            <p class="text-xs text-slate-400 mt-1">Shown only when role is Employee</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Status <span class="text-red-500">*</span></label>
            <select
              name="status"
              id="status"
              required
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
              <option value="">Select Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="pending">Pending</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Joined Date <span class="text-slate-400 font-normal">(optional)</span></label>
            <input
              id="joinedDate"
              type="date"
              name="joinedDate"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
          </div>
        </div>

        <div class="border-t border-slate-200 pt-5">
          <h3 class="text-sm font-semibold text-slate-800 mb-3">Security</h3>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1.5">Password <span class="text-red-500">*</span></label>
              <input
                type="password"
                name="password"
                id="password"
                required
                autocomplete="new-password"
                placeholder="Set password"
                class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1.5">Confirm Password <span class="text-red-500">*</span></label>
              <input
                type="password"
                name="confirmPassword"
                id="confirmPassword"
                required
                autocomplete="new-password"
                placeholder="Confirm password"
                class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
              >
            </div>
          </div>

          <p class="text-xs text-slate-500 mt-3">
            Tip: Use a strong password (8+ chars with uppercase, lowercase, number, symbol).
          </p>
        </div>

        <div class="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <button
            type="submit"
            class="inline-flex items-center justify-center gap-2 px-6 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-xl font-medium transition-colors w-full sm:w-auto shadow-sm"
          >
            <i class="fa-solid fa-plus"></i> Add Employee
          </button>

          <button
            type="reset"
            class="inline-flex items-center justify-center gap-2 px-6 py-2.5 bg-white hover:bg-slate-50 text-slate-700 rounded-xl font-medium transition-colors border border-slate-200 w-full sm:w-auto"
          >
            <i class="fa-solid fa-rotate-left"></i> Reset
          </button>
        </div>
      </form>
    </div>
  </div>

  <script>
    function showToast(msg, type) {
      var t = document.getElementById('toast');
      if (!t) return;

      t.className =
        'fixed top-4 right-4 z-50 max-w-[92vw] sm:max-w-md px-4 sm:px-6 py-3 sm:py-4 rounded-xl shadow-lg text-sm font-medium break-words';

      t.classList.add(type === 'success' ? 'bg-emerald-500' : 'bg-red-500', 'text-white');
      t.textContent = msg;
      t.classList.remove('hidden');

      clearTimeout(window.__toastTimer);
      window.__toastTimer = setTimeout(function () {
        t.classList.add('hidden');
      }, 2500);
    }

    document.addEventListener('DOMContentLoaded', function () {
      var roleSel = document.getElementById('role');
      var wrap = document.getElementById('designationWrap');
      var desig = document.getElementById('designation');

      function syncDesignation() {
        if (!roleSel || !wrap) return;
        var isEmployee = (roleSel.value || '').toLowerCase() === 'employee';
        wrap.classList.toggle('hidden', !isEmployee);
        if (desig) desig.required = isEmployee;
      }

      var submitBtn = document.querySelector('#addEmployeeForm button[type="submit"]');

      function syncSubmitLabel() {
        if (!roleSel || !submitBtn) return;
        var role = (roleSel.value || '').toLowerCase();
        if (role === 'manager') {
          submitBtn.innerHTML = '<i class="fa-solid fa-plus"></i> Add Manager';
        } else if (role === 'employee') {
          submitBtn.innerHTML = '<i class="fa-solid fa-plus"></i> Add Employee';
        } else {
          submitBtn.innerHTML = '<i class="fa-solid fa-plus"></i> Add Employee';
        }
      }

      if (roleSel) roleSel.addEventListener('change', function() {
        syncDesignation();
        syncSubmitLabel();
      });

      syncDesignation();
      syncSubmitLabel();

      var toast = document.getElementById('toast');
      if (toast) {
        var s = toast.getAttribute('data-success');
        var e = toast.getAttribute('data-error');
        if (s) showToast(s, 'success');
        if (e) showToast(e, 'error');
      }

      var form = document.getElementById('addEmployeeForm');
      if (form) {
        form.addEventListener('submit', function (ev) {
          var pwd = document.getElementById('password').value;
          var confirm = document.getElementById('confirmPassword').value;
          if (pwd !== confirm) {
            ev.preventDefault();
            showToast('Passwords do not match.', 'error');
          }
        });
      }
    });
  </script>
</body>
</html>
