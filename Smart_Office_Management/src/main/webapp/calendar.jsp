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
.cal-day:hover:not(.holiday-blocked):not(.weekend-blocked):not(.other-month) { background: #f1f5f9; }
.cal-day.holiday-blocked { background: linear-gradient(135deg, #dbeafe 0%, #e0e7ff 100%); color: #1e40af; cursor: default; }
.cal-day.weekend-blocked { background: linear-gradient(135deg, #ffe4e6 0%, #fff1f2 100%); color: #9f1239; cursor: not-allowed; }
.cal-day.today { background: #eef2ff; border: 2px solid #6366f1; font-weight: 700; }
.cal-day.other-month { color: #cbd5e1; }
.toast { position: fixed; top: 24px; right: 24px; padding: 14px 20px; border-radius: 8px; z-index: 9999; display: none; font-size: 14px; font-weight: 500; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
.toast.success { background: #10b981; color: white; }
.toast.error { background: #ef4444; color: white; }

/* Delete Confirm Modal Animation */
@keyframes popIn {
  0%   { opacity: 0; transform: scale(0.88) translateY(12px); }
  70%  { transform: scale(1.02) translateY(-2px); }
  100% { opacity: 1; transform: scale(1) translateY(0); }
}
.delete-modal-box {
  animation: popIn 0.25s ease forwards;
}
</style>
</head>
<body class="bg-slate-100 min-h-screen">

<div id="toast" class="toast"></div>

<div class="max-w-7xl mx-auto p-6">
  <header class="mb-8">
    <h1 class="text-2xl font-semibold text-slate-800 flex items-center gap-2 mb-2">
      <i class="fa-solid fa-calendar-days text-indigo-500"></i> Company Calendar
    </h1>
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
        <button type="button" onclick="openAddModal()" class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm">
          <i class="fa-solid fa-plus"></i> Add Holiday
        </button>
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

<!-- ═══════════════════════════════════════════════
     ADD / EDIT HOLIDAY MODAL
════════════════════════════════════════════════ -->
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
        <button type="button" id="deleteBtn" onclick="confirmDeleteHoliday()" class="px-4 py-2.5 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium hidden" style="display:none;">
          <i class="fa-solid fa-trash mr-1.5"></i>Delete
        </button>
        <button type="submit" class="flex-1 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium">Save Changes</button>
      </div>
    </form>
  </div>
</div>

<!-- ═══════════════════════════════════════════════
     DELETE CONFIRMATION POPUP MODAL
════════════════════════════════════════════════ -->
<div id="deleteConfirmModal" class="fixed inset-0 bg-black/50 z-[10000] items-center justify-center hidden" onclick="if(event.target===this)closeDeleteConfirm()">
  <div class="delete-modal-box bg-white rounded-2xl shadow-2xl max-w-sm w-full mx-4 overflow-hidden" onclick="event.stopPropagation()">

    <!-- Red header banner -->
    <div class="bg-red-500 px-6 py-5 flex items-center gap-3">
      <div class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center shrink-0">
        <i class="fa-solid fa-triangle-exclamation text-white text-lg"></i>
      </div>
      <div>
        <h3 class="text-white font-semibold text-lg leading-tight">Delete Holiday</h3>
<!--         <p class="text-red-100 text-xs mt-0.5">This action cannot be undone</p> -->
      </div>
    </div>

    <!-- Body -->
    <div class="px-6 py-5">
      <p class="text-slate-600 text-sm leading-relaxed">
        Are you sure you want to delete the holiday
        <span class="font-semibold text-slate-800" id="deleteHolidayName">"—"</span>
        on
        <span class="font-semibold text-slate-800" id="deleteHolidayDate">—</span>?
      </p>
<!--       <p class="text-slate-400 text-xs mt-2">Employees will no longer see this as a blocked day on the calendar.</p> -->
    </div>

    <!-- Footer buttons -->
    <div class="px-6 pb-5 flex gap-3">
      <button type="button" onclick="closeDeleteConfirm()" class="flex-1 px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 font-medium text-sm hover:bg-slate-50 transition-colors">
        <i class="fa-solid fa-xmark mr-1.5"></i>Cancel
      </button>
      <button type="button" id="confirmDeleteBtn" onclick="executeDelete()" class="flex-1 px-4 py-2.5 bg-red-500 hover:bg-red-600 active:bg-red-700 text-white rounded-lg font-medium text-sm transition-colors flex items-center justify-center gap-2">
        <i class="fa-solid fa-trash"></i>Yes, Delete
      </button>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════
     FULL LIST MODAL
════════════════════════════════════════════════ -->
<div id="fullListModal" class="fixed inset-0 bg-black/40 z-[9999] items-center justify-center hidden" onclick="if(event.target===this)closeFullListModal()">
  <div class="bg-white rounded-xl shadow-xl max-w-3xl w-full mx-4 p-6" onclick="event.stopPropagation()">
    <div class="flex justify-between items-center mb-4">
      <div>
        <h3 class="text-lg font-semibold text-slate-800">Holiday List</h3>
        <p class="text-xs text-slate-500 mt-0.5">Search, filter, and manage holidays.</p>
      </div>
      <button type="button" onclick="closeFullListModal()" class="text-slate-400 hover:text-slate-600" aria-label="Close">
        <i class="fa-solid fa-xmark text-xl"></i>
      </button>
    </div>

    <div class="flex flex-col sm:flex-row gap-3 mb-3">
      <div class="flex-1">
        <label class="block text-xs font-semibold text-slate-600 mb-1">Search</label>
        <input id="fullListSearch" type="text" placeholder="Search by name or date (YYYY-MM-DD)" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
      </div>
      <div class="sm:w-44">
        <label class="block text-xs font-semibold text-slate-600 mb-1">Filter</label>
        <select id="fullListFilter" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
          <option value="all">All</option>
          <option value="upcoming">Upcoming</option>
          <option value="past">Past</option>
        </select>
      </div>
      <div class="sm:w-44">
        <label class="block text-xs font-semibold text-slate-600 mb-1">Sort</label>
        <select id="fullListSort" class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
          <option value="asc">Date ↑</option>
          <option value="desc">Date ↓</option>
        </select>
      </div>
    </div>

    <div id="fullListMeta" class="text-xs text-slate-500 mb-3"></div>

    <div class="border border-slate-200 rounded-lg overflow-hidden">
      <div class="max-h-[60vh] overflow-auto">
        <table class="w-full text-sm">
          <thead class="bg-slate-50 sticky top-0 z-10">
            <tr class="text-slate-600 text-xs font-semibold uppercase tracking-wider">
              <th class="p-3 text-left">Date</th>
              <th class="p-3 text-left">Holiday</th>
              <th class="p-3 text-left">Type</th>
              <% if (isAdmin) { %>
              <th class="p-3 text-right">Actions</th>
              <% } %>
            </tr>
          </thead>
          <tbody id="fullListBody"></tbody>
        </table>
      </div>
    </div>

    <div class="flex justify-end gap-3 mt-4">
      <button type="button" onclick="closeFullListModal()" class="px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 font-medium hover:bg-slate-50">Close</button>
    </div>
  </div>
</div>

<script>
let today = new Date();
let currentMonth = today.getMonth();
let currentYear = today.getFullYear();
let selectedDate = "";
let editMode = false;
let holidayMap = {};
let fullListData = [];

// Tracks what we're about to delete (set before opening confirm modal)
let pendingDeleteDate = "";
let pendingDeleteName = "";

const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
const dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
const isAdminClient = <%= isAdmin %>;

function pad(n) { return n.toString().padStart(2,'0'); }
function formatDate(d) { return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate()); }
function isWeekendDateStr(dateStr) {
  const dt = new Date(dateStr + "T00:00:00");
  const dow = dt.getDay();
  return dow === 0 || dow === 6;
}
function prettyDate(dateStr) {
  const d = new Date(dateStr + "T00:00:00");
  if (isNaN(d.getTime())) return dateStr;
  return dateStr + " (" + dayNames[d.getDay()] + ")";
}
function typeLabel(typeRaw) {
  const t = (typeRaw || "").toString().trim().toLowerCase();
  if (!t) return "Public Holiday";
  if (t === "public") return "Public Holiday";
  if (t === "optional") return "Optional Holiday";
  if (t === "company") return "Company Holiday";
  return typeRaw;
}

/* ── Calendar ── */
function loadCalendar() {
  document.getElementById("monthYear").textContent = months[currentMonth] + " " + currentYear;
  fetch("getHolidays?t=" + Date.now())
    .then(r => r.json())
    .then(holidays => {
      holidayMap = {};
      holidays.forEach(h => { holidayMap[h.date] = { name: h.name, type: h.type }; });
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
    const prevYear  = currentMonth === 0 ? currentYear - 1 : currentYear;
    const prevDays  = new Date(prevYear, prevMonth + 1, 0).getDate();
    cell.innerHTML  = prevDays - firstDay + i + 1;
    row.appendChild(cell);
  }

  for (let d = 1; d <= daysInMonth; d++) {
    if (row.children.length === 7) { tbody.appendChild(row); row = document.createElement("tr"); }
    const fullDate  = currentYear + "-" + pad(currentMonth + 1) + "-" + pad(d);
    const cell      = document.createElement("td");
    cell.className  = "cal-day border border-slate-200 text-center text-slate-800";
    const isHoliday = holidayMap[fullDate];
    const isToday   = fullDate === todayStr;
    const dow       = new Date(currentYear, currentMonth, d).getDay();
    const isWeekend = (dow === 0 || dow === 6);

    if (isHoliday) {
      cell.classList.add("holiday-blocked");
      cell.innerHTML = "<div class=\"font-semibold\">" + d + "</div><div class=\"text-xs mt-1 truncate\" title=\"" + (isHoliday.name || "") + "\">" + (isHoliday.name || "Holiday") + "</div>";
    } else if (isWeekend) {
      cell.classList.add("weekend-blocked");
      cell.innerHTML = "<div class=\"font-semibold\">" + d + "</div><div class=\"text-xs mt-1\">Weekend</div>";
    } else {
      cell.innerHTML = "<div class=\"font-medium\">" + d + "</div>";
    }

    if (isToday) cell.classList.add("today");

    if (isAdminClient && (!isWeekend || isHoliday)) {
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
  if (currentMonth < 0)  { currentMonth = 11; currentYear--; }
  if (currentMonth > 11) { currentMonth = 0;  currentYear++; }
  loadCalendar();
}

function goToday() {
  currentMonth = today.getMonth();
  currentYear  = today.getFullYear();
  loadCalendar();
}

/* ── Add / Edit Modal ── */
function openAddModal() {
  editMode = false;
  selectedDate = "";
  document.getElementById("modalTitle").textContent = "Add New Holiday";

  let d = new Date();
  while (d.getDay() === 0 || d.getDay() === 6) d.setDate(d.getDate() + 1);

  document.getElementById("holidayDate").value    = formatDate(d);
  document.getElementById("holidayDate").disabled = false;
  document.getElementById("holidayName").value    = "";
  document.getElementById("holidayType").value    = "Public";
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

  fetch("getHolidayByDate?date=" + encodeURIComponent(dateStr))
    .then(r => r.json())
    .then(data => {
      const weekend = isWeekendDateStr(dateStr);
      const exists  = !!(data && data.exists);

      if (weekend && !exists) {
        showToast("Saturday and Sunday are blocked", "error");
        return;
      }

      editMode     = exists;
      selectedDate = dateStr;
      document.getElementById("modalTitle").textContent      = editMode ? "Edit Holiday" : "Add New Holiday";
      document.getElementById("holidayDate").value           = dateStr;
      document.getElementById("holidayDate").disabled        = editMode;
      document.getElementById("holidayName").value           = data.name  || "";
      document.getElementById("holidayType").value           = data.type  || "Public";
      document.getElementById("deleteBtn").style.display     = editMode ? "block" : "none";
      document.getElementById("holidayModal").classList.remove("hidden");
      document.getElementById("holidayModal").classList.add("flex");
    })
    .catch(() => showToast("Unable to load holiday", "error"));
}

function closeModal() {
  document.getElementById("holidayModal").classList.add("hidden");
  document.getElementById("holidayModal").classList.remove("flex");
}

function saveHoliday(ev) {
  ev.preventDefault();
  const date = document.getElementById("holidayDate").value;
  const name = document.getElementById("holidayName").value.trim();
  const type = document.getElementById("holidayType").value;

  if (!name) { showToast("Enter holiday name", "error"); return; }

  const todayStr = formatDate(new Date());
  if (date < todayStr) { showToast("Cannot add holiday for past date", "error"); return; }

  const effectiveDate = editMode ? selectedDate : date;
  if (!editMode && isWeekendDateStr(effectiveDate)) { showToast("Saturday and Sunday are blocked", "error"); return; }

  const url  = editMode ? "updateHoliday" : "addHoliday";
  const body = editMode
    ? "date=" + encodeURIComponent(selectedDate) + "&name=" + encodeURIComponent(name) + "&type=" + encodeURIComponent(type)
    : "date=" + encodeURIComponent(date)         + "&name=" + encodeURIComponent(name) + "&type=" + encodeURIComponent(type);

  fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body
  })
    .then(r => r.text().then(t => ({ ok: r.ok, status: r.status, text: t })))
    .then(res => {
      if (!res.ok) throw new Error(res.text || ("HTTP " + res.status));
      showToast(res.text || "Saved", "success");
      closeModal();
      loadCalendar();
      loadUpcoming();
      if (!document.getElementById("fullListModal").classList.contains("hidden")) loadFullHolidayList();
    })
    .catch(e => showToast(e && e.message ? e.message : "Operation failed", "error"));
}

/* ── Delete Flow ── */

/**
 * Called from the Edit modal's Delete button.
 * Shows the custom confirmation popup instead of browser confirm().
 */
function confirmDeleteHoliday() {
  if (!selectedDate) { showToast("No holiday selected", "error"); return; }

  // Populate the confirm modal with the holiday details
  pendingDeleteDate = selectedDate;
  pendingDeleteName = document.getElementById("holidayName").value.trim() || "this holiday";

  document.getElementById("deleteHolidayName").textContent = '"' + pendingDeleteName + '"';
  document.getElementById("deleteHolidayDate").textContent = prettyDate(pendingDeleteDate);

  // Close edit modal, show confirm modal
  closeModal();
  document.getElementById("deleteConfirmModal").classList.remove("hidden");
  document.getElementById("deleteConfirmModal").classList.add("flex");
}

/**
 * Called from the Full List table's Delete button.
 * Shows the custom confirmation popup.
 */
function confirmDeleteFromList(dateStr, nameStr) {
  pendingDeleteDate = dateStr;
  pendingDeleteName = nameStr || "this holiday";

  document.getElementById("deleteHolidayName").textContent = '"' + pendingDeleteName + '"';
  document.getElementById("deleteHolidayDate").textContent = prettyDate(pendingDeleteDate);

  document.getElementById("deleteConfirmModal").classList.remove("hidden");
  document.getElementById("deleteConfirmModal").classList.add("flex");
}

function closeDeleteConfirm() {
  document.getElementById("deleteConfirmModal").classList.add("hidden");
  document.getElementById("deleteConfirmModal").classList.remove("flex");
  pendingDeleteDate = "";
  pendingDeleteName = "";
}

/**
 * Actually fires the DELETE request after user confirms.
 */
function executeDelete() {
  if (!pendingDeleteDate) { showToast("No holiday selected", "error"); return; }

  // Show a loading state on the button
  const btn = document.getElementById("confirmDeleteBtn");
  btn.disabled = true;
  btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Deleting…';

  const dateToDelete = pendingDeleteDate;

  fetch("deleteHoliday", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "date=" + encodeURIComponent(dateToDelete)
  })
    .then(r => {
      if (r.status === 405) return fetch("deleteHoliday?date=" + encodeURIComponent(dateToDelete));
      return r;
    })
    .then(r => r.text().then(t => ({ ok: r.ok, status: r.status, text: t })))
    .then(res => {
      // Reset button state
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-trash"></i> Yes, Delete';

      if (!res.ok) throw new Error(res.text || ("Delete failed (HTTP " + res.status + ")"));

      closeDeleteConfirm();
      showToast(res.text || "Holiday deleted successfully", "success");
      loadCalendar();
      loadUpcoming();
      if (!document.getElementById("fullListModal").classList.contains("hidden")) loadFullHolidayList();
    })
    .catch(e => {
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-trash"></i> Yes, Delete';
      closeDeleteConfirm();
      showToast(e && e.message ? e.message : "Delete failed", "error");
    });
}

/* ── Upcoming ── */
function loadUpcoming() {
  fetch("getHolidays?t=" + Date.now())
    .then(r => r.json())
    .then(holidays => {
      const todayStr  = formatDate(new Date());
      const upcoming  = holidays.filter(h => h.date >= todayStr).slice(0, 8);
      const container = document.getElementById("upcomingList");
      if (upcoming.length === 0) {
        container.innerHTML = "<p class=\"text-slate-500 text-sm\">No upcoming holidays</p>";
        return;
      }
      container.innerHTML = upcoming.map(h => {
        const d   = new Date(h.date + "T00:00:00");
        const mon = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"][d.getMonth()];
        const day = d.getDate();
        const t   = typeLabel(h.type || "Public");
        return "<div class=\"flex gap-3 items-start p-3 rounded-lg bg-slate-50 border border-slate-100\"><div class=\"shrink-0 w-12 h-12 rounded-lg bg-emerald-100 text-emerald-700 flex flex-col items-center justify-center text-xs font-bold\"><span>" + mon + "</span><span>" + day + "</span></div><div><div class=\"font-medium text-slate-800\">" + (h.name || "Holiday") + "</div><div class=\"text-xs text-slate-500\">" + t + "</div></div></div>";
      }).join("");
    })
    .catch(() => { document.getElementById("upcomingList").innerHTML = "<p class=\"text-slate-500 text-sm\">Unable to load</p>"; });
}

/* ── Toast ── */
function showToast(msg, type) {
  const t = document.getElementById("toast");
  t.className = "toast " + (type || "success");
  t.textContent = msg;
  t.style.display = "block";
  setTimeout(() => { t.style.display = "none"; }, 2500);
}

/* ── Full List ── */
function openFullListModal() {
  document.getElementById("fullListModal").classList.remove("hidden");
  document.getElementById("fullListModal").classList.add("flex");
  loadFullHolidayList();
  setTimeout(() => { const s = document.getElementById("fullListSearch"); if (s) s.focus(); }, 50);
}

function closeFullListModal() {
  document.getElementById("fullListModal").classList.add("hidden");
  document.getElementById("fullListModal").classList.remove("flex");
}

function loadFullHolidayList() {
  fetch("getHolidays?t=" + Date.now())
    .then(r => r.json())
    .then(holidays => {
      fullListData = Array.isArray(holidays) ? holidays.slice() : [];
      renderFullHolidayList();
    })
    .catch(() => { fullListData = []; renderFullHolidayList(); });
}

function renderFullHolidayList() {
  const tbody   = document.getElementById("fullListBody");
  const meta    = document.getElementById("fullListMeta");
  const q       = (document.getElementById("fullListSearch").value || "").trim().toLowerCase();
  const filter  = document.getElementById("fullListFilter").value;
  const sortDir = document.getElementById("fullListSort").value;
  const todayStr = formatDate(new Date());

  let items = fullListData.slice().filter(h => {
    const date = (h && h.date) ? String(h.date) : "";
    const name = (h && h.name) ? String(h.name) : "";
    const type = (h && h.type) ? String(h.type) : "";
    if (filter === "upcoming" && date < todayStr) return false;
    if (filter === "past"     && date >= todayStr) return false;
    if (!q) return true;
    return date.toLowerCase().includes(q) || name.toLowerCase().includes(q) || type.toLowerCase().includes(q);
  });

  items.sort((a, b) => {
    const da = (a && a.date) ? String(a.date) : "";
    const db = (b && b.date) ? String(b.date) : "";
    if (da === db) return 0;
    if (sortDir === "desc") return da < db ? 1 : -1;
    return da < db ? -1 : 1;
  });

  meta.textContent = items.length + " holiday(s) shown" + (q ? " (search: " + q + ")" : "");
  tbody.innerHTML = "";

  if (items.length === 0) {
    const tr = document.createElement("tr");
    const td = document.createElement("td");
    td.colSpan = isAdminClient ? 4 : 3;
    td.className = "p-4 text-slate-500 text-sm";
    td.textContent = "No holidays found.";
    tr.appendChild(td);
    tbody.appendChild(tr);
    return;
  }

  items.forEach(h => {
    const dateStr  = (h && h.date) ? String(h.date) : "";
    const nameStr  = (h && h.name) ? String(h.name) : "Holiday";
    const rawType  = (h && h.type) ? String(h.type) : "Public";
    const tLabel   = typeLabel(rawType);
    const isPast   = dateStr < todayStr;
    const isWeekend = isWeekendDateStr(dateStr);

    const tr = document.createElement("tr");
    tr.className = "border-t border-slate-100 hover:bg-slate-50";

    const tdDate = document.createElement("td");
    tdDate.className = "p-3 whitespace-nowrap";
    tdDate.innerHTML =
      "<div class=\"font-medium text-slate-800\">" + prettyDate(dateStr) + "</div>" +
      "<div class=\"text-xs " + (isPast ? "text-slate-400" : "text-slate-500") + "\">" +
      (isPast ? "Past" : "Upcoming") + (isWeekend ? " • Weekend" : "") + "</div>";

    const tdName = document.createElement("td");
    tdName.className = "p-3";
    tdName.innerHTML =
      "<div class=\"font-medium text-slate-800\"></div>" +
      "<div class=\"text-xs text-slate-500 mt-0.5\"></div>";
    tdName.children[0].textContent = nameStr;
    tdName.children[1].textContent = isWeekend ? (tLabel + " • Weekend") : tLabel;

    const tdType = document.createElement("td");
    tdType.className = "p-3 whitespace-nowrap text-slate-700";
    tdType.textContent = tLabel;

    tr.appendChild(tdDate);
    tr.appendChild(tdName);
    tr.appendChild(tdType);

    if (isAdminClient) {
      const tdAct = document.createElement("td");
      tdAct.className = "p-3 text-right whitespace-nowrap";

      const editBtn = document.createElement("button");
      editBtn.type = "button";
      editBtn.className = "px-3 py-1.5 rounded-lg border border-slate-300 text-slate-700 text-xs font-medium hover:bg-slate-50 mr-2";
      editBtn.innerHTML = "<i class=\"fa-solid fa-pen-to-square mr-1\"></i>Edit";
      editBtn.onclick = function() { closeFullListModal(); openForDate(dateStr); };

      const delBtn = document.createElement("button");
      delBtn.type = "button";
      delBtn.className = "px-3 py-1.5 rounded-lg bg-red-500 hover:bg-red-600 text-white text-xs font-medium";
      delBtn.innerHTML = "<i class=\"fa-solid fa-trash mr-1\"></i>Delete";
      // ↓ Uses the new confirmation popup instead of confirm()
      delBtn.onclick = function() { confirmDeleteFromList(dateStr, nameStr); };

      tdAct.appendChild(editBtn);
      tdAct.appendChild(delBtn);
      tr.appendChild(tdAct);
    }

    tbody.appendChild(tr);
  });
}

/* ── Init / Event Hooks ── */
(function attachListeners() {
  const links    = Array.from(document.querySelectorAll("a"));
  const fullLink = links.find(a => (a.textContent || "").trim().toLowerCase() === "view full list");
  if (fullLink) {
    fullLink.onclick = function(e) { e.preventDefault(); openFullListModal(); return false; };
  }

  const search = document.getElementById("fullListSearch");
  const filter = document.getElementById("fullListFilter");
  const sort   = document.getElementById("fullListSort");
  if (search) search.addEventListener("input",  renderFullHolidayList);
  if (filter) filter.addEventListener("change", renderFullHolidayList);
  if (sort)   sort.addEventListener("change",   renderFullHolidayList);

  document.addEventListener("keydown", function(e) {
    if (e.key === "Escape") {
      if (!document.getElementById("deleteConfirmModal").classList.contains("hidden")) {
        closeDeleteConfirm();
      } else if (!document.getElementById("fullListModal").classList.contains("hidden")) {
        closeFullListModal();
      }
    }
  });
})();

window.onload = function() {
  loadCalendar();
  loadUpcoming();
  setInterval(function() {
    fetch("getHolidays?t=" + Date.now())
      .then(r => r.json())
      .then(holidays => {
        const next = {};
        holidays.forEach(h => { next[h.date] = { name: h.name, type: h.type }; });
        const changed = JSON.stringify(next) !== JSON.stringify(holidayMap);
        if (changed) {
          holidayMap = next;
          renderCalendar();
          loadUpcoming();
          if (!document.getElementById("fullListModal").classList.contains("hidden")) loadFullHolidayList();
        }
      });
  }, 60000);
};

document.addEventListener("contextmenu", e => e.preventDefault());
</script>
</body>
</html>
