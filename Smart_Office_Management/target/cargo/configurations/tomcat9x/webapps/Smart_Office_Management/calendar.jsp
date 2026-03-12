<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session.getAttribute("username") == null) {
	response.sendRedirect(request.getContextPath() + "/index.html");
	return;
}
String role = (String) session.getAttribute("role");
boolean isAdmin = role != null && "admin".equalsIgnoreCase(role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Company Calendar • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }
.cal-day { min-height: 80px; padding: 8px; }
.cal-day:hover:not(.holiday-blocked):not(.other-month) { background: #f1f5f9; }
.cal-day.holiday-blocked { background: #dbeafe; color: #1e40af; cursor: default; }
.cal-day.holiday-blocked { background: linear-gradient(135deg, #dbeafe 0%, #e0e7ff 100%); }
.cal-day.today { background: #eef2ff; border: 2px solid #6366f1; font-weight: 700; }
.cal-day.other-month { color: #cbd5e1; }
.toast { position: fixed; top: 24px; right: 24px; padding: 14px 20px; border-radius: 8px; z-index: 9999; display: none; font-size: 14px; font-weight: 500; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
.toast.success { background: #10b981; color: white; }
.toast.error { background: #ef4444; color: white; }
</style>
</head>
<body class="bg-slate-100 min-h-screen">

<div id="toast" class="toast"></div>

<div class="max-w-7xl mx-auto p-6">
  <header class="mb-8">
    <h1 class="text-2xl font-semibold text-slate-800 flex items-center gap-2 mb-2"><i class="fa-solid fa-calendar-days text-indigo-500"></i> Company Calendar</h1>
    <p class="text-slate-500 text-sm">Manage holidays, events, and attendance lockouts. Holiday days are blocked automatically.</p>
  </header>

  <div class="flex flex-col lg:flex-row gap-6">
    <!-- Main Calendar -->
    <div class="flex-1 bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
      <div class="p-4 border-b border-slate-200 flex flex-wrap items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <button type="button" onclick="changeMonth(-1)" class="w-10 h-10 rounded-lg border border-slate-300 hover:bg-slate-50 flex items-center justify-center text-slate-600"><i class="fa-solid fa-chevron-left"></i></button>
          <button type="button" onclick="goToday()" class="px-4 py-2 rounded-lg border border-slate-300 hover:bg-slate-50 text-slate-700 text-sm font-medium">Today</button>
          <button type="button" onclick="changeMonth(1)" class="w-10 h-10 rounded-lg border border-slate-300 hover:bg-slate-50 flex items-center justify-center text-slate-600"><i class="fa-solid fa-chevron-right"></i></button>
        </div>
        <h2 id="monthYear" class="text-lg font-semibold text-slate-800"></h2>
        <% if (isAdmin) { %>
        <button type="button" onclick="openAddModal()" class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm"><i class="fa-solid fa-plus"></i> Add Holiday</button>
        <% } %>
      </div>
      <div class="p-4 overflow-x-auto">
        <table class="w-full border-collapse" id="calendar">
          <thead>
            <tr class="text-slate-500 text-xs font-semibold uppercase tracking-wider">
              <th class="p-2 text-center">Sun</th>
              <th class="p-2 text-center">Mon</th>
              <th class="p-2 text-center">Tue</th>
              <th class="p-2 text-center">Wed</th>
              <th class="p-2 text-center">Thu</th>
              <th class="p-2 text-center">Fri</th>
              <th class="p-2 text-center">Sat</th>
            </tr>
          </thead>
          <tbody id="calBody"></tbody>
        </table>
      </div>
    </div>

    <!-- Upcoming Holidays -->
    <div class="w-full lg:w-80 shrink-0">
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
        <h3 class="text-lg font-semibold text-slate-800 mb-4">Upcoming Holidays</h3>
        <div id="upcomingList" class="space-y-3"></div>
        <a href="#" onclick="loadUpcoming(); return false;" class="block mt-4 text-sm text-indigo-500 hover:text-indigo-600 font-medium">View Full List</a>
      </div>
    </div>
  </div>
</div>

<!-- Add Holiday Modal -->
<div id="holidayModal" class="fixed inset-0 bg-black/40 z-[9999] items-center justify-center hidden" onclick="if(event.target===this)closeModal()">
  <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4 p-6" onclick="event.stopPropagation()">
    <div class="flex justify-between items-center mb-5">
      <h3 id="modalTitle" class="text-lg font-semibold text-slate-800">Add New Holiday</h3>
      <button type="button" onclick="closeModal()" class="text-slate-400 hover:text-slate-600"><i class="fa-solid fa-xmark text-xl"></i></button>
    </div>
    <form id="holidayForm" onsubmit="saveHoliday(event)">
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1.5">Date</label>
          <input type="date" id="holidayDate" name="date" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1.5">Holiday Name</label>
          <input type="text" id="holidayName" name="name" placeholder="e.g. Independence Day" required class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1.5">Type</label>
          <select id="holidayType" name="type" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
            <option value="Public">Public Holiday</option>
            <option value="Optional">Optional</option>
            <option value="Company">Company Holiday</option>
          </select>
        </div>
      </div>
      <div class="flex gap-3 mt-6 pt-4 border-t border-slate-200">
        <button type="button" onclick="closeModal()" class="flex-1 px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 font-medium hover:bg-slate-50">Cancel</button>
        <button type="button" id="deleteBtn" onclick="deleteHoliday()" class="px-4 py-2.5 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium hidden" style="display:none;">Delete</button>
        <button type="submit" class="flex-1 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium">Save Changes</button>
      </div>
    </form>
  </div>
</div>

<script>
let today = new Date();
let currentMonth = today.getMonth();
let currentYear = today.getFullYear();
let selectedDate = "";
let editMode = false;
let holidayMap = {};

const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];

function pad(n) { return n.toString().padStart(2,'0'); }
function formatDate(d) { return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate()); }

function loadCalendar() {
  document.getElementById("monthYear").textContent = months[currentMonth] + " " + currentYear;
  fetch("getHolidays?t=" + Date.now())
    .then(r => r.json())
    .then(holidays => {
      holidayMap = {};
      holidays.forEach(h => { holidayMap[h.date] = { name: h.name }; });
      renderCalendar();
    })
    .catch(() => renderCalendar());
}

function renderCalendar() {
  const tbody = document.getElementById("calBody");
  tbody.innerHTML = "";
  const firstDay = new Date(currentYear, currentMonth, 1).getDay();
  const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
  const todayStr = formatDate(today);

  let row = document.createElement("tr");
  for (let i = 0; i < firstDay; i++) {
    const cell = document.createElement("td");
    cell.className = "cal-day other-month border border-slate-200";
    const prevMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const prevYear = currentMonth === 0 ? currentYear - 1 : currentYear;
    const prevDays = new Date(prevYear, prevMonth + 1, 0).getDate();
    cell.innerHTML = prevDays - firstDay + i + 1;
    row.appendChild(cell);
  }

  for (let d = 1; d <= daysInMonth; d++) {
    if (row.children.length === 7) {
      tbody.appendChild(row);
      row = document.createElement("tr");
    }
    const fullDate = currentYear + "-" + pad(currentMonth + 1) + "-" + pad(d);
    const cell = document.createElement("td");
    cell.className = "cal-day border border-slate-200 text-center text-slate-800";
    const isHoliday = holidayMap[fullDate];
    const isToday = fullDate === todayStr;

    if (isHoliday) {
      cell.classList.add("holiday-blocked");
      cell.innerHTML = "<div class=\"font-semibold\">" + d + "</div><div class=\"text-xs mt-1 truncate\" title=\"" + (isHoliday.name || "") + "\">" + (isHoliday.name || "Holiday") + "</div>";
    } else {
      cell.innerHTML = "<div class=\"font-medium\">" + d + "</div>";
    }
    if (isToday) cell.classList.add("today");
    if (<%= isAdmin %>) {
      cell.style.cursor = "pointer";
      cell.onclick = () => openForDate(fullDate);
    }
    row.appendChild(cell);
  }

  const remaining = 7 - row.children.length;
  if (remaining < 7) {
    for (let i = 0; i < remaining; i++) {
      const cell = document.createElement("td");
      cell.className = "cal-day other-month border border-slate-200";
      cell.innerHTML = i + 1;
      row.appendChild(cell);
    }
  }
  tbody.appendChild(row);
}

function changeMonth(step) {
  currentMonth += step;
  if (currentMonth < 0) { currentMonth = 11; currentYear--; }
  if (currentMonth > 11) { currentMonth = 0; currentYear++; }
  loadCalendar();
}

function goToday() {
  currentMonth = today.getMonth();
  currentYear = today.getFullYear();
  loadCalendar();
}

function openAddModal() {
  editMode = false;
  selectedDate = "";
  document.getElementById("modalTitle").textContent = "Add New Holiday";
  document.getElementById("holidayDate").value = formatDate(new Date());
  document.getElementById("holidayDate").disabled = false;
  document.getElementById("holidayName").value = "";
  document.getElementById("holidayType").value = "Public";
  document.getElementById("deleteBtn").style.display = "none";
  document.getElementById("holidayModal").classList.remove("hidden");
  document.getElementById("holidayModal").classList.add("flex");
}

function openForDate(dateStr) {
  const todayStr = formatDate(new Date());
  if (dateStr < todayStr) {
    showToast("Cannot add holiday for past date", "error");
    return;
  }
  fetch("getHolidayByDate?date=" + dateStr)
    .then(r => r.json())
    .then(data => {
      editMode = data.exists;
      selectedDate = dateStr;
      document.getElementById("modalTitle").textContent = editMode ? "Edit Holiday" : "Add New Holiday";
      document.getElementById("holidayDate").value = dateStr;
      document.getElementById("holidayDate").disabled = editMode;
      document.getElementById("holidayName").value = data.name || "";
      document.getElementById("holidayType").value = "Public";
      document.getElementById("deleteBtn").style.display = editMode ? "block" : "none";
      document.getElementById("holidayModal").classList.remove("hidden");
      document.getElementById("holidayModal").classList.add("flex");
    });
}

function closeModal() {
  document.getElementById("holidayModal").classList.add("hidden");
  document.getElementById("holidayModal").classList.remove("flex");
}

function saveHoliday(ev) {
  ev.preventDefault();
  const date = document.getElementById("holidayDate").value;
  const name = document.getElementById("holidayName").value.trim();
  if (!name) { showToast("Enter holiday name", "error"); return; }
  const todayStr = formatDate(new Date());
  if (date < todayStr) { showToast("Cannot add holiday for past date", "error"); return; }
  const url = editMode ? "updateHoliday" : "addHoliday";
  const body = editMode
    ? "date=" + encodeURIComponent(selectedDate) + "&name=" + encodeURIComponent(name)
    : "date=" + encodeURIComponent(date) + "&name=" + encodeURIComponent(name);
  fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body
  })
    .then(r => r.text())
    .then(msg => {
      showToast(msg || "Saved");
      closeModal();
      loadCalendar();
      loadUpcoming();
    })
    .catch(() => showToast("Operation failed", "error"));
}

function deleteHoliday() {
  if (!confirm("Delete this holiday?")) return;
  fetch("deleteHoliday?date=" + encodeURIComponent(selectedDate))
    .then(r => r.text())
    .then(msg => {
      showToast(msg || "Deleted");
      closeModal();
      loadCalendar();
      loadUpcoming();
    })
    .catch(() => showToast("Delete failed", "error"));
}

function loadUpcoming() {
  fetch("getHolidays?t=" + Date.now())
    .then(r => r.json())
    .then(holidays => {
      const todayStr = formatDate(new Date());
      const upcoming = holidays.filter(h => h.date >= todayStr).slice(0, 8);
      const container = document.getElementById("upcomingList");
      if (upcoming.length === 0) {
        container.innerHTML = "<p class=\"text-slate-500 text-sm\">No upcoming holidays</p>";
        return;
      }
      container.innerHTML = upcoming.map(h => {
        const d = new Date(h.date);
        const mon = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"][d.getMonth()];
        const day = d.getDate();
        return "<div class=\"flex gap-3 items-start p-3 rounded-lg bg-slate-50 border border-slate-100\"><div class=\"shrink-0 w-12 h-12 rounded-lg bg-emerald-100 text-emerald-700 flex flex-col items-center justify-center text-xs font-bold\"><span>" + mon + "</span><span>" + day + "</span></div><div><div class=\"font-medium text-slate-800\">" + (h.name || "Holiday") + "</div><div class=\"text-xs text-slate-500\">Public Holiday</div></div></div>";
      }).join("");
    })
    .catch(() => { document.getElementById("upcomingList").innerHTML = "<p class=\"text-slate-500 text-sm\">Unable to load</p>"; });
}

function showToast(msg, type) {
  const t = document.getElementById("toast");
  t.className = "toast " + (type || "success");
  t.textContent = msg;
  t.style.display = "block";
  setTimeout(() => { t.style.display = "none"; }, 2500);
}

window.onload = function() {
  loadCalendar();
  loadUpcoming();
  setInterval(function() {
    fetch("getHolidays?t=" + Date.now())
      .then(r => r.json())
      .then(holidays => {
        const next = {};
        holidays.forEach(h => { next[h.date] = { name: h.name }; });
        const changed = JSON.stringify(next) !== JSON.stringify(holidayMap);
        if (changed) {
          holidayMap = next;
          renderCalendar();
          loadUpcoming();
        }
      });
  }, 60000);
};

document.addEventListener("contextmenu", e => e.preventDefault());
</script>
</body>
</html>
