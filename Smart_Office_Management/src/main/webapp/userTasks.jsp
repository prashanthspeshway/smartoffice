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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Tasks</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-theme.css">
</head>
<body class="user-iframe-page p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-list-check mr-2 text-indigo-500"></i>Assigned Tasks</h2>
        <p class="text-slate-500 text-sm mt-1">Submit a request with an optional comment or file. Your manager will review it.</p>
    </div>

    <!-- Toast -->
    <div id="toast" class="fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg hidden text-sm font-medium max-w-[min(92vw,24rem)]"></div>

    <%if (tasks == null || tasks.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
        <i class="fa-solid fa-inbox text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">No tasks assigned yet.</p>
    </div>
    <%} else { for (Task t : tasks) {
        String rawSt = t.getStatus() != null ? t.getStatus().trim() : "";
        boolean isCompleted = "COMPLETED".equalsIgnoreCase(rawSt);
        boolean isProcessing = "PROCESSING".equalsIgnoreCase(rawSt) || "SUBMITTED".equalsIgnoreCase(rawSt);
        String priorityCls = "HIGH".equalsIgnoreCase(t.getPriority()) ? "text-red-500"
            : "LOW".equalsIgnoreCase(t.getPriority()) ? "text-emerald-500" : "text-amber-500";
        String statusLabel = isCompleted ? "Completed" : (isProcessing ? "Processing" : "Assigned");
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
                <div class="flex flex-wrap gap-x-4 gap-y-2 text-xs text-slate-500 ml-13">
                    <span><i class="fa-solid fa-calendar mr-1"></i>Deadline: <strong class="text-slate-700"><%=t.getDeadline() != null ? t.getDeadline().toString() : "--"%></strong></span>
                    <span><i class="fa-solid fa-flag mr-1 <%=priorityCls%>"></i>Priority: <strong class="<%=priorityCls%>"><%=t.getPriority() != null ? t.getPriority() : "MEDIUM"%></strong></span>
                    <span><i class="fa-solid fa-user mr-1"></i>By: <strong class="text-slate-700"><%=t.getAssignedBy()%></strong></span>
                </div>
                <div class="mt-3 ml-13 text-sm">
                    <span class="text-slate-500">Status:</span>
                    <span class="font-semibold text-slate-800 ml-1"><%=statusLabel%></span>
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

            <!-- Right: Request form (hidden when completed; read-only when processing) -->
            <div class="w-full md:w-72 flex-shrink-0 space-y-3">
                <% if (isCompleted) { %>
                <p class="text-sm text-slate-500 text-center py-2">This task is completed.</p>
                <% } else if (isProcessing) { %>
                <p class="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 text-center font-medium">
                    <i class="fa-solid fa-hourglass-half mr-1"></i>Processing — waiting for your manager
                </p>
                <button type="button" disabled
                    class="w-full py-2 rounded-lg bg-slate-200 text-slate-500 text-sm font-semibold cursor-not-allowed">
                    <i class="fa-solid fa-spinner mr-1"></i> Processing
                </button>
                <% } else { %>
                <input type="file" id="file-<%=t.getId()%>" accept="*/*" class="w-full text-xs text-slate-500 border border-slate-200 rounded-lg px-3 py-2 bg-white file:mr-2 file:py-1 file:px-2 file:rounded file:border-0 file:text-xs file:bg-indigo-50 file:text-indigo-600 file:font-medium cursor-pointer">
                <textarea id="comment-<%=t.getId()%>" placeholder="Add a comment…" class="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-indigo-300" rows="2"></textarea>
                <button onclick="submitTaskRequest(<%=t.getId()%>, this)" type="button"
                    class="w-full py-2 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold transition-colors disabled:opacity-50">
                    <i class="fa-solid fa-paper-plane mr-1"></i> Submit Request
                </button>
                <% } %>
            </div>
        </div>
    </div>
    <%}}%>
</div>

<script>
function showToast(message, type) {
    const toast = document.getElementById('toast');
    toast.className = 'fixed bottom-6 right-4 z-50 px-6 py-3 rounded-lg shadow-lg text-sm font-medium max-w-[min(92vw,24rem)]';
    if (type === 'success') toast.classList.add('bg-emerald-500', 'text-white');
    else toast.classList.add('bg-red-500', 'text-white');
    toast.textContent = message;
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 2500);
}

function submitTaskRequest(taskId, btn) {
    var commentEl = document.getElementById('comment-' + taskId);
    var fileEl    = document.getElementById('file-'    + taskId);

    var formData = new FormData();
    formData.append('taskId',  taskId);
    formData.append('comment', commentEl ? commentEl.value : '');
    if (fileEl && fileEl.files.length > 0) formData.append('employeeFile', fileEl.files[0]);

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Submitting…';

    fetch('<%=request.getContextPath()%>/submitTaskUpdate', { method: 'POST', body: formData, credentials: 'same-origin' })
    .then(function (res) {
        if (res.ok) {
            btn.innerHTML = '<i class="fa-solid fa-hourglass-half mr-1"></i> Processing';
            btn.classList.remove('bg-indigo-600', 'hover:bg-indigo-700');
            btn.classList.add('bg-slate-200', 'text-slate-600', 'cursor-not-allowed');
            showToast('Request submitted', 'success');
            setTimeout(function () { window.location.reload(); }, 600);
            return;
        }
        return res.text().then(function (t) {
            showToast(t || ('Request failed (' + res.status + ')'), 'error');
        });
    })
    .catch(function () { showToast('Network error. Try again.', 'error'); })
    .finally(function () {
        if (!btn.classList.contains('cursor-not-allowed')) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-paper-plane mr-1"></i> Submit Request';
        }
    });
}
</script>
</body>
</html>
