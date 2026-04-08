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
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>
body { font-family: 'Geist', system-ui, -apple-system, sans-serif; }
.tasks-wrap { max-width: 980px; }
.tasks-title { font-size: 29px; font-weight: 700; letter-spacing: -.01em; color: #1e293b; }
.tasks-sub { color: #64748b; font-size: 14px; margin-top: 3px; }
.task-card {
    background: linear-gradient(180deg, #ffffff 0%, #fcfdff 100%);
    border: 1px solid #e2e8f0;
    border-radius: 16px;
    box-shadow: 0 8px 24px rgba(15, 23, 42, .06);
    padding: 20px 20px;
    transition: transform .18s ease, box-shadow .18s ease;
}
.task-card:hover { transform: translateY(-1px); box-shadow: 0 12px 28px rgba(15, 23, 42, .10); }
.task-icon {
    width: 38px; height: 38px; border-radius: 10px; flex-shrink: 0;
    background: linear-gradient(135deg,#eef2ff,#ede9fe);
    display: inline-flex; align-items: center; justify-content: center; color: #6366f1;
}
.task-name { font-size: 25px; font-weight: 700; color: #1e293b; line-height: 1.2; }
.task-desc { font-size: 13px; color: #64748b; margin-top: 2px; }
.meta-row { display:flex; flex-wrap:wrap; gap: 10px 14px; margin-top: 9px; color:#64748b; font-size: 12px; }
.meta-badge {
    display:inline-flex; align-items:center; gap:6px; padding:4px 10px; border-radius:999px;
    border:1px solid #e2e8f0; background:#f8fafc; font-weight:600;
}
.status-pill {
    display:inline-flex; align-items:center; gap:6px; font-size:12px; font-weight:700;
    margin-top: 10px; padding: 4px 10px; border-radius: 999px; border:1px solid #dbeafe; background:#eff6ff; color:#1d4ed8;
}
.attach-pill {
    margin-top: 10px; display:inline-flex; align-items:center; gap:7px; padding:5px 11px; border-radius:999px;
    font-size:12px; font-weight:600; color:#4f46e5; background:#eef2ff; border:1px solid #c7d2fe;
}
.action-panel {
    border:1px solid #e2e8f0; border-radius:14px; padding:12px; background:#f8fafc;
}
.soft-input {
    width:100%; border:1px solid #e2e8f0; border-radius:10px; padding:9px 10px; background:#fff; font-size:13px; color:#334155;
}
.soft-input:focus { outline:none; border-color:#a5b4fc; box-shadow:0 0 0 3px rgba(99,102,241,.12); }
</style>
</head>
<body class="user-iframe-page p-6">

<div class="tasks-wrap mx-auto space-y-6">
    <div>
        <h2 class="tasks-title"><i class="fa-solid fa-list-check mr-2 text-indigo-500"></i>Assigned Tasks</h2>
        <p class="tasks-sub">Submit a request with optional comment/file. Manager will review and respond.</p>
    </div>

    <div id="toast" aria-live="polite"></div>

    <%if (tasks == null || tasks.isEmpty()) {%>
    <div class="task-card p-12 text-center">
        <i class="fa-solid fa-inbox text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">No tasks assigned yet.</p>
    </div>
    <%} else { for (Task t : tasks) {
        String rawSt = t.getStatus() != null ? t.getStatus().trim() : "";
        boolean isCompleted  = "COMPLETED".equalsIgnoreCase(rawSt);
        boolean isProcessing = "PROCESSING".equalsIgnoreCase(rawSt) || "SUBMITTED".equalsIgnoreCase(rawSt);
        String priorityCls = "HIGH".equalsIgnoreCase(t.getPriority())  ? "text-red-500"
                           : "LOW".equalsIgnoreCase(t.getPriority())   ? "text-emerald-500"
                           : "text-amber-500";
        String statusLabel = isCompleted ? "Completed" : (isProcessing ? "Processing" : "Assigned");
        // ── safe filename for JS string ──
        String safeAttName = t.getAttachmentName() != null
            ? t.getAttachmentName().replace("\\","\\\\").replace("'","\\'").replace("\"","\\\"")
            : "";
    %>
    <div class="task-card" id="task-card-<%=t.getId()%>">
        <div class="flex flex-col md:flex-row md:items-start gap-6">

            <!-- Left: Task Info -->
            <div class="flex-1 min-w-0">
                <div class="flex items-start gap-3 mb-3">
                    <div class="task-icon">
                        <i class="fa-solid fa-file-lines"></i>
                    </div>
                    <div>
                        <h3 class="task-name"><%=t.getTitle() != null ? t.getTitle() : t.getDescription()%></h3>
                        <p class="task-desc"><%=t.getDescription()%></p>
                    </div>
                </div>

                <div class="meta-row ml-13">
                    <span class="meta-badge"><i class="fa-solid fa-calendar text-slate-400"></i> Deadline: <strong class="text-slate-700"><%=t.getDeadline() != null ? t.getDeadline().toString() : "--"%></strong></span>
                    <span class="meta-badge"><i class="fa-solid fa-flag <%=priorityCls%>"></i> Priority: <strong class="<%=priorityCls%>"><%=t.getPriority() != null ? t.getPriority() : "MEDIUM"%></strong></span>
                    <span class="meta-badge"><i class="fa-solid fa-user text-slate-400"></i> By: <strong class="text-slate-700"><%=t.getAssignedBy()%></strong></span>
                </div>

                <div class="ml-13"><span class="status-pill"><i class="fa-solid fa-circle-check"></i> <%=statusLabel%></span></div>

                <%-- ── Attachment: open in viewer instead of downloading ── --%>
                <%if (t.getAttachmentName() != null && !t.getAttachmentName().isEmpty()) {%>
                <div class="mt-3 ml-13">
                    <a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>"
                       onclick="AttachmentViewer.open(event, this.href, '<%=safeAttName%>'); return false;"
                       class="attach-pill hover:text-indigo-800 transition-colors cursor-pointer">
                        <i class="fa-solid fa-eye"></i> <%=t.getAttachmentName()%>
                    </a>
                </div>
                <%}%>
            </div>

            <!-- Right: Request form -->
            <div class="w-full md:w-72 flex-shrink-0 space-y-3">
                <% if (isCompleted) { %>
                <p class="text-sm text-slate-500 text-center py-2 action-panel">This task is completed.</p>
                <% } else if (isProcessing) { %>
                <p class="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 text-center font-semibold">
                    <i class="fa-solid fa-hourglass-half mr-1"></i>Processing — waiting for your manager
                </p>
                <button type="button" disabled
                    class="w-full py-2 rounded-lg bg-slate-200 text-slate-500 text-sm font-semibold cursor-not-allowed">
                    <i class="fa-solid fa-spinner mr-1"></i> Processing
                </button>
                <% } else { %>
                <div class="action-panel space-y-3">
                <input type="file" id="file-<%=t.getId()%>" accept="*/*"
                    class="soft-input text-xs file:mr-2 file:py-1 file:px-2 file:rounded file:border-0 file:text-xs file:bg-indigo-50 file:text-indigo-600 file:font-medium cursor-pointer">
                <textarea id="comment-<%=t.getId()%>" placeholder="Add a comment…"
                    class="soft-input resize-none" rows="2"></textarea>
                <button onclick="submitTaskRequest(<%=t.getId()%>, this)" type="button"
                    class="w-full py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold transition-colors disabled:opacity-50">
                    <i class="fa-solid fa-paper-plane mr-1"></i> Submit Request
                </button>
                </div>
                <% } %>
            </div>

        </div>
    </div>
    <%}}%>
</div>

<script>
function submitTaskRequest(taskId, btn) {
    var commentEl = document.getElementById('comment-' + taskId);
    var fileEl    = document.getElementById('file-'    + taskId);

    var formData = new FormData();
    formData.append('taskId',  taskId);
    formData.append('comment', commentEl ? commentEl.value : '');
    if (fileEl && fileEl.files.length > 0) formData.append('employeeFile', fileEl.files[0]);

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Submitting…';

    fetch('<%=request.getContextPath()%>/submitTaskUpdate', { method:'POST', body:formData, credentials:'same-origin' })
    .then(function(res) {
        if (res.ok) {
            btn.innerHTML = '<i class="fa-solid fa-hourglass-half mr-1"></i> Processing';
            btn.classList.remove('bg-indigo-600','hover:bg-indigo-700');
            btn.classList.add('bg-slate-200','text-slate-600','cursor-not-allowed');
            showToast('Request submitted','success');
            setTimeout(function(){ window.location.reload(); }, 600);
            return;
        }
        return res.text().then(function(t){ showToast(t||('Request failed (' + res.status + ')'),'error'); });
    })
    .catch(function(){ showToast('Network error. Try again.','error'); })
    .finally(function(){
        if (!btn.classList.contains('cursor-not-allowed')) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-paper-plane mr-1"></i> Submit Request';
        }
    });
}
</script>

<script>var AV_USER_ROLE = '<%= session.getAttribute("role") != null ? session.getAttribute("role").toString().toUpperCase() : "employee" %>';</script>
<script src="<%=request.getContextPath()%>/js/attachment-viewer.js"></script>
</body>
</html>
