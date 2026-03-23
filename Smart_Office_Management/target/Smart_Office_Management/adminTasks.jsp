<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Task"%>
<%
List<Task> tasks = (List<Task>) request.getAttribute("tasks");
if (tasks == null)
	tasks = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tasks • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
	rel="stylesheet">
<style>
body { font-family: 'Inter', system-ui, sans-serif; }

.badge-status {
	padding: 4px 10px; border-radius: 9999px; font-size: 11px;
	font-weight: 600; display: inline-flex; align-items: center; gap: 4px;
}
.bs-completed   { background: #dcfce7; color: #166534; }
.bs-incomplete  { background: #fef3c7; color: #92400e; }
.bs-docverify   { background: #ede9fe; color: #6d28d9; }
.bs-error       { background: #fee2e2; color: #b91c1c; }

.filter-tab {
	padding: 6px 16px; border-radius: 9999px; font-size: 13px; font-weight: 500;
	cursor: pointer; border: 1.5px solid #e2e8f0; transition: all 0.15s ease;
	display: inline-flex; align-items: center; gap: 6px;
	background: white; color: #64748b;
}
.filter-tab:hover           { border-color: #6366f1; color: #6366f1; }
.filter-tab.active          { background: #6366f1; color: white; border-color: #6366f1; }
.filter-tab.active-completed  { background: #dcfce7; color: #166534; border-color: #86efac; }
.filter-tab.active-incomplete { background: #fef3c7; color: #92400e; border-color: #fcd34d; }
.filter-tab.active-docverify  { background: #ede9fe; color: #6d28d9; border-color: #c4b5fd; }
.filter-tab.active-error      { background: #fee2e2; color: #b91c1c; border-color: #fca5a5; }

.count-pill {
	background: rgba(0,0,0,0.1); border-radius: 9999px;
	padding: 0px 7px; font-size: 11px; font-weight: 600;
}
</style>
</head>
<body class="bg-slate-100 min-h-screen p-6">

<div class="max-w-6xl mx-auto">
	<div class="flex flex-wrap justify-between items-center gap-4 mb-6">
		<div>
			<h2 class="text-2xl font-semibold text-slate-800 flex items-center gap-2">
				<i class="fa-solid fa-list-check text-indigo-500"></i> Tasks
			</h2>
			<p class="text-slate-500 text-sm mt-0.5">Read-only view of all tasks assigned in the system.</p>
		</div>
	</div>

	<!-- Filter Tabs -->
	<div class="flex flex-wrap gap-2 mb-4">
		<button class="filter-tab active" onclick="filterTasks('all', this)">
			<i class="fa-solid fa-border-all text-xs"></i> All
			<span class="count-pill" id="count-all">0</span>
		</button>
		<button class="filter-tab" onclick="filterTasks('COMPLETED', this)">
			<i class="fa-solid fa-circle-check text-xs"></i> Completed
			<span class="count-pill" id="count-completed">0</span>
		</button>
		<button class="filter-tab" onclick="filterTasks('INCOMPLETE', this)">
			<i class="fa-solid fa-clock text-xs"></i> Incompleted
			<span class="count-pill" id="count-incomplete">0</span>
		</button>
		<button class="filter-tab" onclick="filterTasks('DOCUMENT_VERIFICATION', this)">
			<i class="fa-solid fa-file-circle-check text-xs"></i> Document Varification
			<span class="count-pill" id="count-docverify">0</span>
		</button>
		<button class="filter-tab" onclick="filterTasks('ERRORS_RAISED', this)">
			<i class="fa-solid fa-triangle-exclamation text-xs"></i> Errors Raised
			<span class="count-pill" id="count-error">0</span>
		</button>
	</div>

	<!-- Empty state -->
	<div id="empty-filter-msg"
		class="hidden px-4 py-8 text-center text-slate-500 text-sm italic bg-white rounded-xl border border-slate-200 shadow-sm mb-4">
		No tasks match this filter.
	</div>

	<div id="table-wrap"
		class="overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
		<table class="w-full">
			<thead>
				<tr class="bg-slate-50 border-b border-slate-200 text-sm text-slate-600">
					<th class="px-4 py-3 text-left">#</th>
					<th class="px-4 py-3 text-left">Title</th>
					<th class="px-4 py-3 text-left">Status</th>
					<th class="px-4 py-3 text-left">Assigned Date</th>
					<th class="px-4 py-3 text-left">Deadline</th>
					<th class="px-4 py-3 text-left">Attachment</th>
					<th class="px-4 py-3 text-left">Assigned To</th>
					<th class="px-4 py-3 text-left">Assigned By</th>
				</tr>
			</thead>
			<tbody id="task-table-body">
				<%
				if (tasks.isEmpty()) {
				%>
				<tr>
					<td colspan="8" class="px-4 py-8 text-center text-slate-500 text-sm italic">No tasks found.</td>
				</tr>
				<%
				} else {
				for (Task t : tasks) {
					String title      = t.getTitle()      != null ? t.getTitle()      : "";
					String status     = t.getStatus()     != null ? t.getStatus()     : "";
					String assignedTo = t.getAssignedTo() != null ? t.getAssignedTo() : "";
					String assignedBy = t.getAssignedBy() != null ? t.getAssignedBy() : "";
					java.sql.Timestamp ts = t.getAssignedDate();
					String dateStr     = ts != null ? ts.toLocalDateTime().toLocalDate().toString() : "";
					java.sql.Date dl   = t.getDeadline();
					String deadlineStr = dl != null ? dl.toString() : dateStr;

					String stClass   = "bs-incomplete";
					String stText    = "Incompleted";
					String filterKey = "INCOMPLETE";

					if ("COMPLETED".equalsIgnoreCase(status)) {
						stClass = "bs-completed"; stText = "Completed"; filterKey = "COMPLETED";
					} else if ("INCOMPLETE".equalsIgnoreCase(status)) {
						stClass = "bs-incomplete"; stText = "Incompleted"; filterKey = "INCOMPLETE";
					} else if ("DOCUMENT_VERIFICATION".equalsIgnoreCase(status)) {
						stClass = "bs-docverify"; stText = "Document Varification"; filterKey = "DOCUMENT_VERIFICATION";
					} else if ("ERRORS_RAISED".equalsIgnoreCase(status)) {
						stClass = "bs-error"; stText = "Errors Raised"; filterKey = "ERRORS_RAISED";
					}
				%>
				<tr class="task-row border-b border-slate-200 hover:bg-slate-50 text-sm"
					data-status="<%=filterKey%>">
					<td class="px-4 py-3 text-slate-500 row-num"></td>
					<td class="px-4 py-3 text-slate-800"><%=title%></td>
					<td class="px-4 py-3"><span class="badge-status <%=stClass%>"><%=stText%></span></td>
					<td class="px-4 py-3 text-slate-600"><%=dateStr%></td>
					<td class="px-4 py-3 text-slate-600"><%=deadlineStr%></td>
					<td class="px-4 py-3 text-slate-600">
						<%
						String attName = t.getAttachmentName();
						if (attName != null && !attName.isEmpty()) {
						%>
						<a href="<%=request.getContextPath()%>/taskAttachment?id=<%=t.getId()%>"
							class="text-indigo-600 hover:underline" target="_blank"><%=attName%></a>
						<%
						} else {
						%>
						<span class="text-slate-400 text-xs italic">No file</span>
						<%
						}
						%>
					</td>
					<td class="px-4 py-3 text-slate-600"><%=assignedTo%></td>
					<td class="px-4 py-3 text-slate-600"><%=assignedBy%></td>
				</tr>
				<%
				}
				}
				%>
			</tbody>
		</table>
	</div>
</div>

<script>
  const tabActiveClass = {
    'all':                   'active',
    'COMPLETED':             'active-completed',
    'INCOMPLETE':            'active-incomplete',
    'DOCUMENT_VERIFICATION': 'active-docverify',
    'ERRORS_RAISED':         'active-error'
  };

  function filterTasks(status, clickedTab) {
    document.querySelectorAll('.filter-tab').forEach(t =>
      t.classList.remove('active', 'active-completed', 'active-incomplete', 'active-docverify', 'active-error')
    );
    clickedTab.classList.add(tabActiveClass[status]);

    let visible = 0;
    document.querySelectorAll('.task-row').forEach(row => {
      const show = status === 'all' || row.dataset.status === status;
      row.style.display = show ? '' : 'none';
      if (show) visible++;
    });

    let num = 1;
    document.querySelectorAll('.task-row').forEach(row => {
      if (row.style.display !== 'none') row.querySelector('.row-num').textContent = num++;
    });

    document.getElementById('empty-filter-msg').classList.toggle('hidden', visible > 0);
    document.getElementById('table-wrap').style.display = visible === 0 ? 'none' : '';
  }

  function initCounts() {
    let counts = { all: 0, COMPLETED: 0, INCOMPLETE: 0, DOCUMENT_VERIFICATION: 0, ERRORS_RAISED: 0 };
    document.querySelectorAll('.task-row').forEach(r => {
      counts.all++;
      if (counts[r.dataset.status] !== undefined) counts[r.dataset.status]++;
    });
    document.getElementById('count-all').textContent       = counts.all;
    document.getElementById('count-completed').textContent = counts.COMPLETED;
    document.getElementById('count-incomplete').textContent= counts.INCOMPLETE;
    document.getElementById('count-docverify').textContent = counts.DOCUMENT_VERIFICATION;
    document.getElementById('count-error').textContent     = counts.ERRORS_RAISED;
  }

  let n = 1;
  document.querySelectorAll('.task-row').forEach(r => r.querySelector('.row-num').textContent = n++);
  initCounts();
</script>

</body>
</html>