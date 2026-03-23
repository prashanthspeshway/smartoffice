<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Leave</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap" rel="stylesheet">
<style>body{font-family:'DM Sans',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">
    <div class="max-w-7xl mx-auto">
        <h2 class="text-2xl font-bold text-slate-800 mb-6">Leave</h2>

        <!-- Tabs -->
        <div class="flex gap-3 mb-6">
            <button id="applyTab" onclick="showTab('apply')"
                class="px-6 py-3 bg-indigo-600 text-white font-semibold rounded-lg transition-colors">
                Apply Leave
            </button>
            <button id="myLeavesTab" onclick="showTab('myLeaves')"
                class="px-6 py-3 bg-slate-300 text-slate-700 font-semibold rounded-lg transition-colors">
                My Leave Requests
            </button>
        </div>

        <!-- Apply Leave Section -->
        <div id="applySection" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Apply Leave Form -->
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
                <div class="flex items-center gap-3 mb-6">
                    <i class="fa-solid fa-paper-plane text-indigo-600 text-2xl"></i>
                    <h3 class="text-lg font-semibold text-slate-800">Submit Request</h3>
                </div>
                <form action="<%=request.getContextPath()%>/applyLeave" method="post" class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Leave Type</label>
                        <select name="leaveType" required
                            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                            <option value="">Select</option>
                            <option>Casual Leave</option>
                            <option>Sick Leave</option>
                            <option>Earned Leave</option>
                        </select>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-semibold text-slate-700 mb-2">From Date</label>
                            <input type="date" name="fromDate" required
                                class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-slate-700 mb-2">To Date</label>
                            <input type="date" name="toDate" required
                                class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-2">Reason</label>
                        <textarea name="reason" rows="4" placeholder="Briefly describe the reason..." required
                            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
                    </div>
                    <button type="submit"
                        class="w-full px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors">
                        <i class="fa-solid fa-paper-plane mr-2"></i>Submit Request
                    </button>
                </form>
            </div>

            <!-- Leave Policy Info -->
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
                <div class="flex items-center gap-3 mb-6">
                    <i class="fa-solid fa-circle-info text-indigo-600 text-2xl"></i>
                    <h3 class="text-lg font-semibold text-slate-800">Leave Policy</h3>
                </div>
                <div class="space-y-4">
                    <div class="bg-indigo-50 border-l-4 border-indigo-600 rounded-lg p-4">
                        <h4 class="font-semibold text-slate-800 mb-2">Casual Leave</h4>
                        <p class="text-sm text-slate-600">For personal errands or short-notice absences. Typically limited to a set number of days per year.</p>
                    </div>
                    <div class="bg-green-50 border-l-4 border-green-600 rounded-lg p-4">
                        <h4 class="font-semibold text-slate-800 mb-2">Sick Leave</h4>
                        <p class="text-sm text-slate-600">Applicable when you are unwell and unable to attend work. A medical certificate may be required.</p>
                    </div>
                    <div class="bg-yellow-50 border-l-4 border-yellow-600 rounded-lg p-4">
                        <h4 class="font-semibold text-slate-800 mb-2">Earned Leave</h4>
                        <p class="text-sm text-slate-600">Accrued over time based on service. Plan in advance and get approval from HR.</p>
                    </div>
                    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                        <p class="text-sm text-slate-700">
                            <i class="fa-solid fa-triangle-exclamation text-red-600 mr-2"></i>
                            All leave requests are subject to admin approval. Submit at least 2 working days in advance when possible.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- My Leave Requests Section -->
        <div id="myLeavesSection" class="hidden">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <%
                List<LeaveRequest> myLeaves = (List<LeaveRequest>) request.getAttribute("myLeaves");
                if (myLeaves != null && !myLeaves.isEmpty()) {
                    for (LeaveRequest lr : myLeaves) {
                        String statusColor = "APPROVED".equalsIgnoreCase(lr.getStatus())
                            ? "bg-green-100 text-green-800"
                            : "REJECTED".equalsIgnoreCase(lr.getStatus())
                            ? "bg-red-100 text-red-800"
                            : "bg-yellow-100 text-yellow-800";
                        boolean hasRejectionReason = "REJECTED".equalsIgnoreCase(lr.getStatus())
                            && lr.getRejectionReason() != null
                            && !lr.getRejectionReason().trim().isEmpty();
                %>
                <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-4 hover:shadow-md transition-shadow">
                    <div class="flex items-center justify-between mb-3">
                        <div class="flex items-center gap-2">
                            <i class="fa-solid fa-plane-departure text-indigo-600"></i>
                            <span class="font-semibold text-slate-800"><%=lr.getLeaveType()%></span>
                        </div>
                        <span class="px-2 py-1 rounded-full text-xs font-semibold <%=statusColor%>">
                            <%=lr.getStatus()%>
                        </span>
                    </div>
                    <div class="space-y-2 text-sm text-slate-600">
                        <div><b>From:</b> <%=lr.getFromDate()%></div>
                        <div><b>To:</b> <%=lr.getToDate()%></div>
                        <div><b>Reason:</b> <%=lr.getReason()%></div>
                    </div>
                    <%-- ✅ Admin rejection reason — only shown when rejected with a reason --%>
                    <% if (hasRejectionReason) { %>
                    <div class="flex items-start gap-2 mt-3 px-3 py-2.5 bg-red-50 border border-red-100 rounded-lg">
                        <i class="fa-solid fa-comment-slash text-red-400 mt-0.5 flex-shrink-0 text-xs"></i>
                        <span class="text-xs text-red-700"><strong>Admin's reason:</strong> <%=lr.getRejectionReason()%></span>
                    </div>
                    <% } %>
                </div>
                <%
                    }
                } else {
                %>
                <div class="col-span-full">
                    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-12 text-center">
                        <i class="fa-solid fa-calendar-xmark text-slate-300 text-6xl mb-4"></i>
                        <h3 class="text-lg font-semibold text-slate-700 mb-2">No Leave Requests</h3>
                        <p class="text-slate-500">You haven't submitted any leave requests yet.</p>
                    </div>
                </div>
                <%
                }
                %>
            </div>
        </div>
    </div>

    <script>
    function showTab(tab) {
        const applySection    = document.getElementById('applySection');
        const myLeavesSection = document.getElementById('myLeavesSection');
        const applyTab        = document.getElementById('applyTab');
        const myLeavesTab     = document.getElementById('myLeavesTab');

        if (tab === 'apply') {
            applySection.classList.remove('hidden');
            myLeavesSection.classList.add('hidden');
            applyTab.classList.remove('bg-slate-300', 'text-slate-700');
            applyTab.classList.add('bg-indigo-600', 'text-white');
            myLeavesTab.classList.remove('bg-indigo-600', 'text-white');
            myLeavesTab.classList.add('bg-slate-300', 'text-slate-700');
        } else {
            applySection.classList.add('hidden');
            myLeavesSection.classList.remove('hidden');
            myLeavesTab.classList.remove('bg-slate-300', 'text-slate-700');
            myLeavesTab.classList.add('bg-indigo-600', 'text-white');
            applyTab.classList.remove('bg-indigo-600', 'text-white');
            applyTab.classList.add('bg-slate-300', 'text-slate-700');
        }
    }

    document.addEventListener('contextmenu', e => e.preventDefault());
    document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
    </script>
</body>
</html>
