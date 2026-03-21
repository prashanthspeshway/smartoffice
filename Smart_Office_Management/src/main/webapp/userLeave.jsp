<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%@ page import="java.util.List"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
List<LeaveRequest> myLeaves = (List<LeaveRequest>) request.getAttribute("myLeaves");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Apply Leave</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body{font-family:'Inter',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-calendar-days mr-2 text-indigo-500"></i>Leave</h2>
        <p class="text-slate-500 text-sm mt-1">Apply for leave or view your requests.</p>
    </div>

    <!-- Tabs -->
    <div class="flex gap-2 border-b border-slate-200">
        <button id="applyTabBtn" onclick="showTab('apply')" class="tab-btn px-5 py-3 text-sm font-semibold text-indigo-600 border-b-2 border-indigo-600 -mb-px bg-transparent">
            Apply Leave
        </button>
        <button id="myTabBtn" onclick="showTab('my')" class="tab-btn px-5 py-3 text-sm font-semibold text-slate-500 border-b-2 border-transparent -mb-px hover:text-slate-700 bg-transparent">
            My Requests
        </button>
    </div>

    <!-- Apply Tab -->
    <div id="applyTab">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Form -->
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
                <h4 class="font-bold text-slate-800 mb-5 flex items-center gap-2 text-base">
                    <i class="fa-solid fa-paper-plane text-indigo-500"></i> Submit Request
                </h4>
                <form action="<%=request.getContextPath()%>/applyLeave" method="post" class="space-y-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Leave Type</label>
                        <select name="leaveType" required class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-300">
                            <option value="">Select type</option>
                            <option>Casual Leave</option>
                            <option>Sick Leave</option>
                            <option>Earned Leave</option>
                        </select>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">From Date</label>
                            <input type="date" name="fromDate" required class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-300">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">To Date</label>
                            <input type="date" name="toDate" required class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-300">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Reason</label>
                        <textarea name="reason" required rows="3" placeholder="Briefly describe the reason…" class="w-full px-3 py-2.5 rounded-lg border border-slate-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-indigo-300"></textarea>
                    </div>
                    <button type="submit" class="w-full py-3 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-bold transition-colors flex items-center justify-center gap-2">
                        <i class="fa-solid fa-paper-plane"></i> Submit Request
                    </button>
                </form>
            </div>

            <!-- Policy -->
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
                <h4 class="font-bold text-slate-800 mb-5 flex items-center gap-2 text-base">
                    <i class="fa-solid fa-circle-info text-indigo-500"></i> Leave Policy
                </h4>
                <div class="space-y-3">
                    <div class="border-l-4 border-indigo-500 bg-indigo-50 rounded-r-lg p-4">
                        <p class="text-sm font-bold text-slate-800 mb-1">Casual Leave</p>
                        <p class="text-xs text-slate-500">For personal errands or short-notice absences. Typically limited to a set number of days per year.</p>
                    </div>
                    <div class="border-l-4 border-emerald-500 bg-emerald-50 rounded-r-lg p-4">
                        <p class="text-sm font-bold text-slate-800 mb-1">Sick Leave</p>
                        <p class="text-xs text-slate-500">Applicable when unwell. A medical certificate may be required for extended absences.</p>
                    </div>
                    <div class="border-l-4 border-amber-500 bg-amber-50 rounded-r-lg p-4">
                        <p class="text-sm font-bold text-slate-800 mb-1">Earned Leave</p>
                        <p class="text-xs text-slate-500">Accrued over time based on service. Plan in advance and get approval from HR.</p>
                    </div>
                    <div class="flex gap-2 bg-red-50 border border-red-100 rounded-lg p-3 text-xs text-slate-500">
                        <i class="fa-solid fa-triangle-exclamation text-red-400 mt-0.5 flex-shrink-0"></i>
                        <span>All leave requests are subject to admin approval. Submit at least 2 working days in advance when possible.</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- My Requests Tab -->
    <div id="myTab" class="hidden">
        <%if (myLeaves == null || myLeaves.isEmpty()) {%>
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
            <i class="fa-solid fa-calendar-xmark text-4xl text-slate-300 mb-3"></i>
            <p class="text-slate-400 font-medium">No leave requests found.</p>
        </div>
        <%} else { for (LeaveRequest lr : myLeaves) {
            String st = lr.getStatus();
            String badge = "APPROVED".equalsIgnoreCase(st)
                ? "bg-emerald-100 text-emerald-700 border border-emerald-200"
                : "REJECTED".equalsIgnoreCase(st)
                ? "bg-red-100 text-red-700 border border-red-200"
                : "bg-amber-100 text-amber-700 border border-amber-200";
        %>
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5 flex items-center justify-between mb-3">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-lg bg-indigo-50 flex items-center justify-center">
                    <i class="fa-solid fa-plane-departure text-indigo-500"></i>
                </div>
                <div>
                    <p class="font-semibold text-slate-800 text-sm"><%=lr.getLeaveType()%></p>
                    <p class="text-xs text-slate-400 mt-0.5"><%=lr.getFromDate()%> → <%=lr.getToDate()%></p>
                </div>
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-bold <%=badge%>"><%=st%></span>
        </div>
        <%}}%>
    </div>
</div>

<script>
function showTab(tab) {
    document.getElementById('applyTab').classList.toggle('hidden', tab !== 'apply');
    document.getElementById('myTab').classList.toggle('hidden', tab !== 'my');
    document.getElementById('applyTabBtn').className = tab === 'apply'
        ? 'tab-btn px-5 py-3 text-sm font-semibold text-indigo-600 border-b-2 border-indigo-600 -mb-px bg-transparent'
        : 'tab-btn px-5 py-3 text-sm font-semibold text-slate-500 border-b-2 border-transparent -mb-px hover:text-slate-700 bg-transparent';
    document.getElementById('myTabBtn').className = tab === 'my'
        ? 'tab-btn px-5 py-3 text-sm font-semibold text-indigo-600 border-b-2 border-indigo-600 -mb-px bg-transparent'
        : 'tab-btn px-5 py-3 text-sm font-semibold text-slate-500 border-b-2 border-transparent -mb-px hover:text-slate-700 bg-transparent';
}
// Auto-switch if query param
var params = new URLSearchParams(window.location.search);
if (params.get('sub') === 'myLeaves') showTab('my');
</script>
</body>
</html>
