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
  <link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
  <script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>

  <style>
    body { font-family: 'Geist', system-ui, sans-serif; }
    /* Searchable designation combobox */
    .desig-combo-panel {
      box-shadow: 0 10px 40px rgba(15, 23, 42, 0.12);
    }
    .desig-combo-item[aria-selected="true"] {
      background: rgb(239 246 255);
      color: rgb(30 64 175);
    }
  </style>
</head>

<body class="min-h-screen bg-gradient-to-br from-indigo-50 via-slate-50 to-emerald-50 px-4 py-6 sm:p-6 lg:p-10">
  <div id="toast" aria-live="polite" data-success="<%= successSafe %>" data-error="<%= errorSafe %>"></div>

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
              pattern="[6-9][0-9]{9}"
              class="w-full px-4 py-2.5 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500/40 focus:border-indigo-500 outline-none bg-white"
            >
            <p class="text-xs text-slate-400 mt-1">Must start with 6, 7, 8, or 9 and be 10 digits.</p>
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

          <div id="designationWrap" class="hidden sm:col-span-2 relative">
            <label class="block text-sm font-medium text-slate-700 mb-1.5" id="designationLabelText">Designation <span class="text-red-500">*</span></label>

            <!-- Native value for form submit (kept in sync by script) -->
            <select name="designation" id="designation" class="hidden" tabindex="-1" aria-hidden="true">
              <option value="">Select Designation</option>
              <% for (String d : designations) { %>
                <option value="<%= h(d) %>"><%= h(d) %></option>
              <% } %>
            </select>

            <div id="designationCombo" class="relative">
              <button
                type="button"
                id="designationComboBtn"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-labelledby="designationLabelText"
                class="flex w-full items-center justify-between gap-2 px-4 py-2.5 text-left border border-slate-300 rounded-xl bg-white text-slate-800 outline-none transition
                  focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500
                  hover:border-slate-400"
              >
                <span id="designationComboDisplay" class="truncate text-slate-500">Select Designation</span>
                <i class="fa-solid fa-chevron-down text-slate-400 text-sm shrink-0 transition-transform" id="designationComboChevron" aria-hidden="true"></i>
              </button>

              <div
                id="designationComboPanel"
                class="desig-combo-panel hidden absolute left-0 right-0 top-full z-50 mt-1 rounded-xl border border-slate-200 bg-white overflow-hidden"
                role="presentation"
              >
                <div class="border-b border-slate-100 p-2 bg-white">
                  <label for="designationSearch" class="sr-only">Search designations</label>
                  <input
                    type="search"
                    id="designationSearch"
                    autocomplete="off"
                    placeholder="Search designations…"
                    class="w-full px-3 py-2 text-sm border border-slate-200 rounded-lg outline-none
                      focus:ring-2 focus:ring-blue-500/40 focus:border-blue-500"
                  />
                </div>
                <ul
                  id="designationComboList"
                  class="max-h-52 overflow-y-auto py-1"
                  role="listbox"
                  aria-labelledby="designationLabelText"
                ></ul>
              </div>
            </div>
            <p class="text-xs text-slate-400 mt-1">Shown only when role is Employee. Type to filter the list.</p>
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
    function initDesignationSearchCombo() {
      var sel = document.getElementById('designation');
      var btn = document.getElementById('designationComboBtn');
      var panel = document.getElementById('designationComboPanel');
      var list = document.getElementById('designationComboList');
      var search = document.getElementById('designationSearch');
      var display = document.getElementById('designationComboDisplay');
      var chevron = document.getElementById('designationComboChevron');
      var comboRoot = document.getElementById('designationCombo');
      if (!sel || !btn || !panel || !list || !search || !display) return null;

      var optionData = [];
      for (var i = 0; i < sel.options.length; i++) {
        var o = sel.options[i];
        if (o.value === '') continue;
        optionData.push({ value: o.value, text: o.textContent.trim() });
      }

      function closePanel() {
        panel.classList.add('hidden');
        btn.setAttribute('aria-expanded', 'false');
        if (chevron) chevron.classList.remove('rotate-180');
      }

      function openPanel() {
        panel.classList.remove('hidden');
        btn.setAttribute('aria-expanded', 'true');
        if (chevron) chevron.classList.add('rotate-180');
        search.value = '';
        renderList('');
        setTimeout(function () { search.focus(); }, 0);
      }

      function syncDisplayFromSelect() {
        var v = sel.value;
        if (v) {
          display.textContent = sel.options[sel.selectedIndex].text;
          display.classList.remove('text-slate-500');
          display.classList.add('text-slate-800');
        } else {
          display.textContent = 'Select Designation';
          display.classList.add('text-slate-500');
          display.classList.remove('text-slate-800');
        }
      }

      function renderList(filter) {
        var q = (filter || '').trim().toLowerCase();
        list.innerHTML = '';
        for (var j = 0; j < optionData.length; j++) {
          var opt = optionData[j];
          if (q && opt.text.toLowerCase().indexOf(q) === -1) continue;
          var li = document.createElement('li');
          li.setAttribute('role', 'option');
          li.setAttribute('data-value', opt.value);
          li.setAttribute('tabindex', '-1');
          li.className =
            'desig-combo-item px-3 py-2.5 text-sm text-slate-600 cursor-pointer hover:bg-slate-50';
          if (sel.value === opt.value) {
            li.setAttribute('aria-selected', 'true');
            li.classList.add('bg-indigo-50', 'text-indigo-800');
          }
          li.textContent = opt.text;
          li.addEventListener('mousedown', function (e) {
            e.preventDefault();
          });
          li.addEventListener('click', function () {
            var val = this.getAttribute('data-value');
            sel.value = val;
            syncDisplayFromSelect();
            closePanel();
            search.value = '';
            renderList('');
          });
          list.appendChild(li);
        }
      }

      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        if (panel.classList.contains('hidden')) openPanel();
        else closePanel();
      });

      search.addEventListener('input', function () {
        renderList(search.value);
      });

      search.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
          e.stopPropagation();
          closePanel();
          btn.focus();
        }
      });

      document.addEventListener('click', function (e) {
        if (comboRoot && !comboRoot.contains(e.target)) closePanel();
      });

      window.__designationComboReset = function () {
        sel.selectedIndex = 0;
        syncDisplayFromSelect();
        closePanel();
        search.value = '';
        renderList('');
      };

      syncDisplayFromSelect();
      renderList('');

      return { closePanel: closePanel };
    }

    document.addEventListener('DOMContentLoaded', function () {
      var roleSel = document.getElementById('role');
      var wrap = document.getElementById('designationWrap');
      var desig = document.getElementById('designation');
      var designationComboApi = initDesignationSearchCombo();

      function syncDesignation() {
        if (!roleSel || !wrap) return;
        var isEmployee = (roleSel.value || '').toLowerCase() === 'employee';
        wrap.classList.toggle('hidden', !isEmployee);
        if (desig) desig.required = isEmployee;
        if (!isEmployee && designationComboApi) designationComboApi.closePanel();
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

      // Phone number: allow only digits, and block first digit if not 6-9
      var phoneInput = document.getElementById('phonenumber');
      if (phoneInput) {
        phoneInput.addEventListener('input', function () {
          // Strip non-digits
          this.value = this.value.replace(/\D/g, '');
          // If first digit is not 6-9, clear the input
          if (this.value.length > 0 && !/^[6-9]/.test(this.value)) {
            this.value = '';
          }
        });

        phoneInput.addEventListener('keypress', function (e) {
          var char = String.fromCharCode(e.which);
          // Allow only digits
          if (!/[0-9]/.test(char)) {
            e.preventDefault();
            return;
          }
          // Block first digit if not 6-9
          if (this.value.length === 0 && !/[6-9]/.test(char)) {
            e.preventDefault();
            showToast('Phone number must start with 6, 7, 8, or 9.', 'error');
          }
        });
      }

      var form = document.getElementById('addEmployeeForm');
      if (form) {
        form.addEventListener('reset', function () {
          setTimeout(function () {
            if (window.__designationComboReset) window.__designationComboReset();
          }, 0);
        });

        form.addEventListener('submit', function (ev) {
          var pwd = document.getElementById('password').value;
          var confirm = document.getElementById('confirmPassword').value;
          if (pwd !== confirm) {
            ev.preventDefault();
            showToast('Passwords do not match.', 'error');
            return;
          }

          var role = (document.getElementById('role').value || '').toLowerCase();
          if (role === 'employee') {
            var des = document.getElementById('designation');
            if (!des || !des.value) {
              ev.preventDefault();
              showToast('Please select a designation.', 'error');
              return;
            }
          }

          // Extra phone validation on submit
          var phone = document.getElementById('phonenumber').value;
          if (phone && !/^[6-9][0-9]{9}$/.test(phone)) {
            ev.preventDefault();
            showToast('Phone number must start with 6, 7, 8, or 9 and be 10 digits.', 'error');
          }
        });
      }
    });
  </script>
</body>
</html>
