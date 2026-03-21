<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="java.util.List"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
List<Task> tasks = (List<Task>) request.getAttribute("tasks");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Tasks</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>body{font-family:'Inter',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-list-check mr-2 text-indigo-500"></i>Assigned Tasks</h2>
        <p class="text-slate-500 text-sm mt-1">View and update your assigned tasks.</p>
    </div>

    <!-- Toast -->
    <div id="toast" class="fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg hidden text-sm font-medium"></div>

    <%if (tasks == null || tasks.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
        <i class="fa-solid fa-inbox text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">No tasks assigned yet.</p>
    </div>
    <%} else { for (Task t : tasks) {
        String statusCls = "COMPLETED".equals(t.getStatus()) ? "bg-emerald-100 text-emerald-700 border border-emerald-200"
            : "ERRORS_RAISED".equals(t.getStatus()) ? "bg-red-100 text-red-700 border border-red-200"
            : "INCOMPLETE".equals(t.getStatus()) ? "bg-amber-100 text-amber-700 border border-amber-200"
            : "bg-slate-100 text-slate-600 border border-slate-200";
        String priorityCls = "HIGH".equalsIgnoreCase(t.getPriority()) ? "text-red-500"
            : "LOW".equalsIgnoreCase(t.getPriority()) ? "text-emerald-500" : "text-amber-500";
    %>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6" id="task-card-<%=t.getId()%>">
        <div class="flex flex-col md:flex-row md:items-start gap-6">
            <!-- Left: Task Info -->
            <div class="flex-1 min-w-0">
                <div class="flex items-start gap-3 mb-3">
                    <div class="w-10 h-10 rounded-lg bg-indigo-50 flex items-center justify-center flex-shrink-0">
                        <i class="fa-solid fa-file-lines text-indigo-500"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-slate-800 text-base leading-tight"><%=t.getTitle() != null ? t.getTitle() : t.getDescription()%></h3>
                        <p class="text-sm text-slate-500 mt-0.5"><%=t.getDescription()%></p>
                    </div>
                </div>
                <div class="flex flex-wrap gap-3 text-xs text-slate-500 ml-13">
                    <span><i class="fa-solid fa-calendar mr-1"></i>Deadline: <strong class="text-slate-700"><%=t.getDeadline() != null ? t.getDeadline().toString() : "--"%></strong></span>
                    <span><i class="fa-solid fa-flag mr-1 <%=priorityCls%>"></i>Priority: <strong class="<%=priorityCls%>"><%=t.getPriority() != null ? t.getPriority() : "MEDIUM"%></strong></span>
                    <span><i class="fa-solid fa-user mr-1"></i>By: <strong class="text-slate-700"><%=t.getAssignedBy()%></strong></span>
                    <%if (t.getStatus() != null) {%>
                    <span class="px-2 py-0.5 rounded-full text-xs font-semibold <%=statusCls%>"><%=t.getStatus()%></span>
                    <%}%>
                </div>
                <%if (t.getAttachmentName() != null && !t.getAttachmentName().isEmpty()) {%>
                <div class="mt-3 ml-13">
                    <a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>" target="_blank"
                       class="inline-flex items-center gap-1.5 text-xs text-indigo-600 hover:text-indigo-800 font-medium border border-indigo-200 bg-indigo-50 px-3 py-1.5 rounded-lg transition-colors">
                        <i class="fa-solid fa-paperclip"></i> <%=t.getAttachmentName()%>
                    </a>
                </div>
                <%}%>
            </div>

            <!-- Right: Update Form -->
            <div class="w-full md:w-72 flex-shrink-0 space-y-3">
                <select id="status-<%=t.getId()%>" class="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-300">
                    <option value="">Update Status</option>
                    <option value="COMPLETED"            <%="COMPLETED".equals(t.getStatus())?"selected":""%>>Complete</option>
                    <option value="INCOMPLETE"           <%="INCOMPLETE".equals(t.getStatus())?"selected":""%>>Incomplete</option>
                    <option value="ERRORS_RAISED"        <%="ERRORS_RAISED".equals(t.getStatus())?"selected":""%>>Errors Raised</option>
                    <option value="DOCUMENT_VERIFICATION"<%="DOCUMENT_VERIFICATION".equals(t.getStatus())?"selected":""%>>Document Verification</option>
                </select>
                <input type="file" id="file-<%=t.getId()%>" accept="*/*" class="w-full text-xs text-slate-500 border border-slate-200 rounded-lg px-3 py-2 bg-white file:mr-2 file:py-1 file:px-2 file:rounded file:border-0 file:text-xs file:bg-indigo-50 file:text-indigo-600 file:font-medium cursor-pointer">
                <textarea id="comment-<%=t.getId()%>" placeholder="Add a comment…" class="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-indigo-300" rows="2"></textarea>
                <button onclick="submitTaskUpdate(<%=t.getId()%>, this)" type="button"
                    class="w-full py-2 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold transition-colors disabled:opacity-50">
                    <i class="fa-solid fa-paper-plane mr-1"></i> Submit Update
                </button>
            </div>
        </div>
    </div>
    <%}}%>
</div>

<script>
function showToast(message, type) {
    const toast = document.getElementById('toast');
    toast.className = 'fixed top-4 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-sm font-medium';
    if (type === 'success') toast.classList.add('bg-emerald-500', 'text-white');
    else toast.classList.add('bg-red-500', 'text-white');
    toast.textContent = message;
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 2500);
}

function submitTaskUpdate(taskId, btn) {
    var statusEl  = document.getElementById('status-'  + taskId);
    var commentEl = document.getElementById('comment-' + taskId);
    var fileEl    = document.getElementById('file-'    + taskId);

    if (!statusEl.value) { showToast('Please select a status.', 'error'); return; }

    var formData = new FormData();
    formData.append('taskId',  taskId);
    formData.append('status',  statusEl.value);
    formData.append('comment', commentEl ? commentEl.value : '');
    if (fileEl && fileEl.files.length > 0) formData.append('employeeFile', fileEl.files[0]);

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Submitting…';

    fetch('<%=request.getContextPath()%>/submitTaskUpdate', { method: 'POST', body: formData })
    .then(res => {
        if (res.ok || res.redirected) {
            showToast('Task updated successfully ✔', 'success');
            statusEl.value = ''; commentEl.value = ''; fileEl.value = '';
        } else {
            return res.text().then(t => showToast('Update failed: ' + t, 'error'));
        }
    })
    .catch(() => showToast('Network error. Try again.', 'error'))
    .finally(() => { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-paper-plane mr-1"></i> Submit Update'; });
}
</script>
</body>
</html>
