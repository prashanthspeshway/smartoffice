<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.LeaveRequest"%>
<%
if (session.getAttribute("username") == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}
String leaveSuccess = request.getParameter("success");
List<LeaveRequest> allLeaves = (List<LeaveRequest>) request.getAttribute("allLeaves");
long pendingCount      = request.getAttribute("pendingCount")      != null ? (Long) request.getAttribute("pendingCount")      : 0;
long approvedCount     = request.getAttribute("approvedCount")     != null ? (Long) request.getAttribute("approvedCount")     : 0;
long onLeaveTodayCount = request.getAttribute("onLeaveTodayCount") != null ? (Long) request.getAttribute("onLeaveTodayCount") : 0;
long rejectedCount     = request.getAttribute("rejectedCount")     != null ? (Long) request.getAttribute("rejectedCount")     : 0;
if (allLeaves == null) allLeaves = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Leave Management • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
body { font-family: 'Geist', system-ui, sans-serif; }
.tab-btn { padding: 10px 16px; border-radius: 8px; font-weight: 500; transition: all 0.2s; }
.tab-btn.active { background: #4f46e5; color: white; }
.tab-btn:not(.active) { background: #f1f5f9; color: #64748b; }
.tab-btn:not(.active):hover { background: #e2e8f0; color: #334155; }
.leave-card { transition: all 0.2s; }
.leave-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.06); }

/* ── Reject Modal ── */
#rejectModal {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(15, 20, 40, 0.55);
    backdrop-filter: blur(4px);
    z-index: 9999;
    align-items: center;
    justify-content: center;
    padding: 20px;
}
#rejectModal.show { display: flex; }
#rejectModalBox {
    background: #fff;
    border-radius: 18px;
    box-shadow: 0 24px 60px rgba(0,0,0,.18);
    max-width: 460px;
    width: 100%;
    animation: popIn .2s cubic-bezier(.34,1.56,.64,1) both;
}
@keyframes popIn {
    from { transform: scale(.88); opacity: 0; }
    to   { transform: scale(1);  opacity: 1; }
}
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-5xl mx-auto">

    <!-- Header -->
    <div class="flex flex-wrap justify-between items-center gap-4 mb-6">
        <div>
            <h2 class="text-2xl font-semibold text-slate-800">Leave Management</h2>
            <p class="text-slate-500 text-sm mt-0.5">Manage employee leave requests</p>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-amber-100 flex items-center justify-center text-amber-600"><i class="fa-solid fa-clock"></i></div>
                <div>
                    <div class="text-2xl font-bold text-slate-800"><%= pendingCount %></div>
                    <div class="text-sm text-slate-500">Pending</div>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-emerald-100 flex items-center justify-center text-emerald-600"><i class="fa-solid fa-check"></i></div>
                <div>
                    <div class="text-2xl font-bold text-slate-800"><%= approvedCount %></div>
                    <div class="text-sm text-slate-500">Approved</div>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600"><i class="fa-solid fa-plane-departure"></i></div>
                <div>
                    <div class="text-2xl font-bold text-slate-800"><%= onLeaveTodayCount %></div>
                    <div class="text-sm text-slate-500">On Leave Today</div>
                </div>
            </div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-red-100 flex items-center justify-center text-red-600"><i class="fa-solid fa-times"></i></div>
                <div>
                    <div class="text-2xl font-bold text-slate-800"><%= rejectedCount %></div>
                    <div class="text-sm text-slate-500">Rejected</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs -->
    <div class="flex flex-wrap gap-2 mb-4">
        <button type="button" class="tab-btn active" data-tab="pending"  onclick="setTab('pending')">Pending (<%= pendingCount %>)</button>
        <button type="button" class="tab-btn"         data-tab="approved" onclick="setTab('approved')">Approved</button>
        <button type="button" class="tab-btn"         data-tab="rejected" onclick="setTab('rejected')">Rejected</button>
    </div>

    <!-- Leave List -->
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">

        <!-- ── PENDING ── -->
        <div id="pendingList" class="tab-content p-4 space-y-3">
            <%
            long pCount = 0;
            for (LeaveRequest lr : allLeaves) {
                if (!"PENDING".equalsIgnoreCase(lr.getStatus())) continue;
                pCount++;
                String initials = getInitials(lr);
            %>
            <div class="leave-card flex flex-wrap items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
                <div class="w-12 h-12 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-semibold text-sm shrink-0">
                    <%= initials %>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
                    <div class="text-sm text-slate-500"><%= lr.getLeaveType() %> &bull; <%= lr.getFromDate() %> &rarr; <%= lr.getToDate() %></div>
                    <div class="text-xs text-slate-400 mt-0.5">Applied: <%= lr.getAppliedAt() != null ? lr.getAppliedAt().toString().substring(0,10) : "--" %></div>
                    <% if (lr.getReason() != null && !lr.getReason().isEmpty()) { %>
                    <div class="text-xs text-slate-500 mt-1 italic">&ldquo;<%= lr.getReason() %>&rdquo;</div>
                    <% } %>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-700 shrink-0">Pending</span>
                <div class="flex gap-2 shrink-0">
                    <!-- Approve — direct form submit -->
                    <form action="adminLeave" method="post" class="inline">
                        <input type="hidden" name="leaveId" value="<%= lr.getId() %>">
                        <input type="hidden" name="action"  value="approve">
                        <button type="submit" class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white rounded-lg text-sm font-medium">
                            <i class="fa-solid fa-check mr-1"></i> Approve
                        </button>
                    </form>
                    <!-- ✅ Reject — opens modal to optionally add reason -->
                    <button type="button"
                            onclick="openRejectModal(<%= lr.getId() %>, '<%= escapeJs(lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername()) %>')"
                            class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg text-sm font-medium">
                        <i class="fa-solid fa-times mr-1"></i> Reject
                    </button>
                </div>
            </div>
            <%
            }
            if (pCount == 0) {
            %>
            <div class="text-center py-12 text-slate-500">
                <i class="fa-solid fa-check-circle text-4xl mb-2 block"></i>
                <p>No pending leave requests</p>
            </div>
            <% } %>
        </div>

        <!-- ── APPROVED ── -->
        <div id="approvedList" class="tab-content p-4 space-y-3 hidden">
            <%
            boolean hasApproved = false;
            for (LeaveRequest lr : allLeaves) {
                if (!"APPROVED".equalsIgnoreCase(lr.getStatus())) continue;
                hasApproved = true;
                String initials = getInitials(lr);
            %>
            <div class="leave-card flex items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
                <div class="w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-semibold text-sm shrink-0">
                    <%= initials %>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
                    <div class="text-sm text-slate-500"><%= lr.getLeaveType() %> &bull; <%= lr.getFromDate() %> &rarr; <%= lr.getToDate() %></div>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-700 shrink-0">Approved</span>
            </div>
            <% } %>
            <% if (!hasApproved) { %>
            <div class="text-center py-12 text-slate-500"><p>No approved requests</p></div>
            <% } %>
        </div>

        <!-- ── REJECTED ── -->
        <div id="rejectedList" class="tab-content p-4 space-y-3 hidden">
            <%
            boolean hasRejected = false;
            for (LeaveRequest lr : allLeaves) {
                if (!"REJECTED".equalsIgnoreCase(lr.getStatus())) continue;
                hasRejected = true;
                String initials = getInitials(lr);
            %>
            <div class="leave-card flex items-center gap-4 p-4 rounded-lg border border-slate-100 bg-slate-50/50">
                <div class="w-12 h-12 rounded-full bg-red-100 text-red-700 flex items-center justify-center font-semibold text-sm shrink-0">
                    <%= initials %>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="font-medium text-slate-800"><%= lr.getDisplayName() != null ? lr.getDisplayName() : lr.getUsername() %></div>
                    <div class="text-sm text-slate-500"><%= lr.getLeaveType() %> &bull; <%= lr.getFromDate() %> &rarr; <%= lr.getToDate() %></div>
                    <!-- ✅ Show rejection reason if present -->
                    <% if (lr.getRejectionReason() != null && !lr.getRejectionReason().isEmpty()) { %>
                    <div class="flex items-start gap-1.5 mt-1.5 text-xs text-red-600 bg-red-50 border border-red-100 rounded-lg px-3 py-2">
                        <i class="fa-solid fa-comment-slash mt-0.5 flex-shrink-0"></i>
                        <span><strong>Reason:</strong> <%= lr.getRejectionReason() %></span>
                    </div>
                    <% } %>
                </div>
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700 shrink-0">Rejected</span>
            </div>
            <% } %>
            <% if (!hasRejected) { %>
            <div class="text-center py-12 text-slate-500"><p>No rejected requests</p></div>
            <% } %>
        </div>

    </div>
</div>

<!-- ✅ Reject Reason Modal -->
<div id="rejectModal" onclick="if(event.target===this)closeRejectModal()">
    <div id="rejectModalBox" onclick="event.stopPropagation()">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-5 border-b border-slate-100">
            <div>
                <h3 class="text-lg font-bold text-slate-800 flex items-center gap-2">
                    <i class="fa-solid fa-times-circle text-red-500"></i> Reject Leave Request
                </h3>
                <p class="text-sm text-slate-500 mt-0.5" id="rejectModalSubtitle">Employee name</p>
            </div>
            <button onclick="closeRejectModal()"
                    class="w-8 h-8 rounded-lg bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-500 transition-colors">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- Body -->
        <form id="rejectForm" action="adminLeave" method="post">
            <input type="hidden" name="action"  value="reject">
            <input type="hidden" name="leaveId" id="rejectLeaveId" value="">

            <div class="px-6 py-5">
                <label class="block text-sm font-semibold text-slate-700 mb-2">
                    Rejection Reason
                    <span class="font-normal text-slate-400 ml-1">(optional)</span>
                </label>
                <textarea id="rejectReasonInput"
                          name="rejectionReason"
                          rows="4"
                          placeholder="e.g. Insufficient leave balance, critical project deadline, team understaffed…"
                          class="w-full px-4 py-3 border border-slate-200 rounded-xl text-sm resize-none focus:outline-none focus:ring-2 focus:ring-red-300 focus:border-red-400 transition-all"
                          maxlength="500"></textarea>
                <div class="flex justify-between mt-1">
                    <p class="text-xs text-slate-400">Leave blank if no specific reason to share.</p>
                    <span class="text-xs text-slate-400" id="charCount">0 / 500</span>
                </div>
            </div>

            <!-- Footer -->
            <div class="flex gap-3 px-6 pb-6">
                <button type="button" onclick="closeRejectModal()"
                        class="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-semibold text-sm transition-colors">
                    Cancel
                </button>
                <button type="submit"
                        class="flex-1 py-2.5 bg-red-500 hover:bg-red-600 text-white rounded-xl font-semibold text-sm transition-colors flex items-center justify-center gap-2">
                    <i class="fa-solid fa-times"></i> Confirm Reject
                </button>
            </div>
        </form>
    </div>
</div>

<script>
/* ── Tab switching ── */
function setTab(tab) {
    document.querySelectorAll('.tab-btn').forEach(b => {
        b.classList.toggle('active', b.dataset.tab === tab);
    });
    document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
    var el = document.getElementById(tab + 'List');
    if (el) el.classList.remove('hidden');
}

/* ── Reject modal ── */
function openRejectModal(leaveId, employeeName) {
    document.getElementById('rejectLeaveId').value      = leaveId;
    document.getElementById('rejectModalSubtitle').textContent = employeeName;
    document.getElementById('rejectReasonInput').value  = '';
    document.getElementById('charCount').textContent    = '0 / 500';
    document.getElementById('rejectModal').classList.add('show');
    document.getElementById('rejectReasonInput').focus();
}

function closeRejectModal() {
    document.getElementById('rejectModal').classList.remove('show');
}

/* ── Character counter ── */
document.getElementById('rejectReasonInput').addEventListener('input', function() {
    document.getElementById('charCount').textContent = this.value.length + ' / 500';
});

/* ── Close on Escape ── */
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeRejectModal();
});

/* ── Toast on success ── */
document.addEventListener('DOMContentLoaded', function() {
    var s = '<%= leaveSuccess != null ? leaveSuccess : "" %>';
    if (s && typeof window.parent.showToast === 'function') {
        window.parent.showToast('Leave ' + s.toLowerCase() + ' successfully');
        window.history.replaceState({}, document.title, window.location.pathname);
    }
});
</script>

<%!
/* ── Scriptlet helpers ── */
private String getInitials(LeaveRequest lr) {
    String name = lr.getDisplayName();
    if (name == null || name.isEmpty()) name = lr.getUsername();
    if (name == null || name.isEmpty()) return "?";
    String[] parts = name.trim().split("\\s+");
    if (parts.length >= 2) return (parts[0].substring(0,1) + parts[parts.length-1].substring(0,1)).toUpperCase();
    return name.substring(0, Math.min(2, name.length())).toUpperCase();
}

private String escapeJs(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n");
}
%>

</body>
</html>
