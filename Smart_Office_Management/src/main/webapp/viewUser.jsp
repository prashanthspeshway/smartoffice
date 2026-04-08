<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%
String successMsg = (String) session.getAttribute("successMsg");
String errorMsg = (String) session.getAttribute("errorMsg");
session.removeAttribute("successMsg");
session.removeAttribute("errorMsg");
int totalUsers = request.getAttribute("totalUsers") != null ? (int) request.getAttribute("totalUsers") : 0;
String search = request.getAttribute("search") != null ? (String) request.getAttribute("search") : "";
String roleFilter = request.getAttribute("roleFilter") != null ? (String) request.getAttribute("roleFilter") : "";
String statusFilter = request.getAttribute("statusFilter") != null ? (String) request.getAttribute("statusFilter") : "";
String dateFrom = request.getAttribute("dateFrom") != null ? (String) request.getAttribute("dateFrom") : "";
String dateTo = request.getAttribute("dateTo") != null ? (String) request.getAttribute("dateTo") : "";
String designationFilter = request.getAttribute("designationFilter") != null
		? (String) request.getAttribute("designationFilter")
		: "";
List<String> designationOptions = (List<String>) request.getAttribute("designationOptions");
if (designationOptions == null)
	designationOptions = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>View Employees • Smart Office HRMS</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap"
	rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>
body {
	font-family: 'Geist', system-ui, sans-serif;
}

.search-input-wrap {
	position: relative;
	display: inline-block;
}

.search-input-wrap input {
	padding-right: 32px;
	padding-left: 40px;
}

.search-icon {
	position: absolute;
	left: 12px;
	top: 50%;
	transform: translateY(-50%);
	color: #94a3b8;
	pointer-events: none;
	font-size: 14px;
}

.search-clear {
	position: absolute;
	right: 8px;
	top: 50%;
	transform: translateY(-50%);
	background: none;
	border: none;
	color: #64748b;
	cursor: pointer;
	padding: 4px;
	display: none;
}

.search-clear:hover {
	color: #4f46e5;
}

.search-input-wrap.has-text .search-clear {
	display: block;
}

.badge {
	padding: 4px 10px;
	border-radius: 9999px;
	font-size: 12px;
	font-weight: 600;
}

.badge.active {
	background: #d1fae5;
	color: #065f46;
}

.badge.inactive {
	background: #f1f5f9;
	color: #64748b;
}

.icon-btn {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 32px;
	height: 32px;
	border-radius: 6px;
	text-decoration: none;
	font-size: 14px;
	margin-right: 6px;
	transition: all 0.2s;
}

.icon-btn.edit {
	background: #dbeafe;
	color: #1e40af;
}

.icon-btn.edit:hover {
	background: #bfdbfe;
}

.icon-btn.delete {
	background: #fee2e2;
	color: #b91c1c;
}

.icon-btn.delete:hover {
	background: #fecaca;
}

.pagination {
	margin-top: 20px;
	display: flex;
	flex-wrap: wrap;
	justify-content: center;
	align-items: center;
	gap: 4px;
}

.pagination a, .pagination span {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	min-width: 36px;
	height: 36px;
	padding: 0 10px;
	border-radius: 6px;
	text-decoration: none;
	background: #fff;
	color: #334155;
	border: 1px solid #e2e8f0;
	font-size: 14px;
}

.pagination a:hover:not(.disabled) {
	background: #f8fafc;
	border-color: #cbd5e1;
}

.pagination a.active {
	background: #4f46e5;
	color: white;
	border-color: #4f46e5;
}

.pagination a.disabled {
	opacity: 0.5;
	cursor: not-allowed;
	pointer-events: none;
}

.pagination span.ellipsis {
	border: none;
	background: transparent;
	cursor: default;
}

#filtersPanel {
	display: none;
}

#filtersPanel.show {
	display: block;
}

#deleteModal {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.4);
	z-index: 9998;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

#deleteModal.show {
	display: flex;
}

#importModal {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.4);
	z-index: 9999;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

#importModal.show {
	display: flex;
}

.grid-card {
	transition: all 0.2s;
}

.grid-card:hover {
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* Mobile alignment for Employees table (same pattern as attendance) */
#listView {
	overflow-x: auto;
	overflow-y: hidden;
	-webkit-overflow-scrolling: touch;
}

@media (max-width: 768px) {
	body {
		padding: 12px;
	}

	#listView table {
		min-width: 860px;
	}

	#listView th, #listView td {
		white-space: nowrap;
		vertical-align: middle;
		padding: 10px 10px !important;
		font-size: 13px !important;
	}

	#listView th:first-child,
	#listView td:first-child {
		position: sticky;
		left: 0;
		z-index: 2;
		background: #fff;
		min-width: 140px;
	}

	#listView thead th:first-child {
		z-index: 3;
		background: #f8fafc;
	}

	#listView th:last-child,
	#listView td:last-child {
		min-width: 96px;
	}
}
</style>
</head>
<body class="bg-slate-100 min-h-screen p-3 md:p-6">

	<div class="max-w-6xl mx-auto">
		<!-- Header: Title + Action Buttons -->
		<div class="flex flex-wrap justify-between items-center gap-4 mb-6">
			<div>
				<h2 class="text-2xl font-semibold text-slate-800">Employees</h2>
				<p class="text-slate-500 text-sm mt-0.5"><%=totalUsers%>
					total employees
				</p>
			</div>
			<div class="flex flex-wrap items-center gap-2">
				<a href="exportUsers" target="_blank"
					class="inline-flex items-center gap-2 px-4 py-2.5 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg text-sm font-medium transition-colors">
					<i class="fa-solid fa-upload"></i> Export
				</a>
				<button type="button" onclick="openImportModal()"
					class="inline-flex items-center gap-2 px-4 py-2.5 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg text-sm font-medium transition-colors">
					<i class="fa-solid fa-download"></i> Import
				</button>
				<button type="button" onclick="loadAddEmployee()"
					class="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg text-sm font-medium transition-colors">
					<i class="fa-solid fa-user-plus"></i> Add Employee
				</button>
			</div>
		</div>

		<!-- Search, Filters, View Toggle -->
		<div class="flex flex-wrap items-center gap-3 mb-4">
			<form method="get" action="viewUser" id="viewUserForm"
				class="flex flex-wrap items-center gap-3 flex-1 min-w-0"
				role="search">
				<div class="search-input-wrap flex-1 min-w-[200px]">
					<i class="fa-solid fa-magnifying-glass search-icon"
						aria-hidden="true"></i> <input type="text" name="search"
						id="searchInput" placeholder="Search by name, email, or role..."
						value="<%=search != null
		? search.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
		: ""%>"
						class="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">

					<button type="button" class="search-clear" id="searchClear"
						title="Clear" aria-label="Clear">
						<i class="fa-solid fa-xmark"></i>
					</button>
				</div>

				<!-- ensures Enter key always submits in all browsers -->
				<button type="submit" class="hidden" aria-hidden="true"
					tabindex="-1">Search</button>

				<button type="button" onclick="toggleFilters()"
					class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 rounded-lg text-sm font-medium">
					<i class="fa-solid fa-filter"></i> Filters
				</button>

				<div id="filtersPanel"
					class="flex flex-wrap items-center gap-3 w-full mt-2 p-3 bg-slate-50 rounded-lg border border-slate-200">
					<select name="role" onchange="this.form.submit()"
						class="px-3 py-2 border border-slate-300 rounded-lg text-sm">
						<option value="">All Roles</option>
						<option value="manager"
							<%="manager".equals(roleFilter) ? "selected" : ""%>>Manager</option>
						<option value="employee"
							<%="employee".equals(roleFilter) ? "selected" : ""%>>Employee</option>
					</select> <select name="designation" onchange="this.form.submit()"
						class="px-3 py-2 border border-slate-300 rounded-lg text-sm">
						<option value="">All Designations</option>
						<%
						for (String d : designationOptions) {
							String esc = d != null ? d.replace("\"", "&quot;").replace("'", "&#39;") : "";
							boolean sel = designationFilter != null && designationFilter.equalsIgnoreCase(d);
						%>
						<option value="<%=esc%>" <%=sel ? "selected" : ""%>><%=d%></option>
						<%
						}
						%>
					</select> <select name="status" onchange="this.form.submit()"
						class="px-3 py-2 border border-slate-300 rounded-lg text-sm">
						<option value="">All Status</option>
						<option value="active"
							<%="active".equals(statusFilter) ? "selected" : ""%>>Active</option>
						<option value="inactive"
							<%="inactive".equals(statusFilter) ? "selected" : ""%>>Inactive</option>
					</select> <input type="hidden" name="sort"
						value="<%=request.getAttribute("sortBy") != null ? request.getAttribute("sortBy") : "fullname"%>">
					<input type="hidden" name="order"
						value="<%=request.getAttribute("sortOrder") != null ? request.getAttribute("sortOrder") : "asc"%>">

					<button type="submit"
						class="px-3 py-2 bg-indigo-500 text-white rounded-lg text-sm font-medium">Apply</button>
					<a href="viewUser"
						class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-lg text-sm font-medium"><i
						class="fa-solid fa-filter-circle-xmark mr-1"></i> Clear</a>
				</div>
			</form>

			<div
				class="flex items-center border border-slate-300 rounded-lg overflow-hidden bg-white">
				<button type="button" id="viewGrid" onclick="setView('grid')"
					class="px-3 py-2 text-slate-500 hover:bg-slate-100">
					<i class="fa-solid fa-grip"></i>
				</button>
				<button type="button" id="viewList" onclick="setView('list')"
					class="px-3 py-2 bg-slate-100 text-slate-700">
					<i class="fa-solid fa-list"></i>
				</button>
			</div>
		</div>

		<!-- List View (Table) -->
		<div id="listView"
			class="overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-sm">
			<table class="w-full">
				<thead>
					<tr class="bg-slate-50 border-b border-slate-200">
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Full
							Name</th>
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Role</th>
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Status</th>
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Designation</th>
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Email</th>
						<th
							class="text-left px-4 py-3 text-sm font-semibold text-slate-700">Actions</th>
					</tr>
				</thead>
				<tbody>
					<%
					String rows = request.getAttribute("rows") != null ? (String) request.getAttribute("rows") : "";
					if (rows == null || rows.trim().isEmpty()) {
					%>
					<tr>
						<td colspan="6" class="px-4 py-16 text-center">
							<div class="flex flex-col items-center gap-3">
								<div
									class="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center">
									<i class="fa-solid fa-user-slash text-2xl text-slate-400"></i>
								</div>
								<div>
									<p class="text-slate-600 font-medium text-sm">No employees
										found</p>
									<p class="text-slate-400 text-xs mt-0.5">Try adjusting your
										search or filters</p>
								</div>
								<a href="viewUser"
									class="mt-1 inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-600 rounded-lg text-xs font-medium transition-colors">
									<i class="fa-solid fa-filter-circle-xmark text-xs"></i> Clear
									all filters
								</a>
							</div>
						</td>
					</tr>
					<%
					} else {
					%>
					<%=rows%>
					<%
					}
					%>
				</tbody>
			</table>
		</div>

		<!-- Grid View -->
		<div id="gridView"
			class="hidden grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
			<%
			String gridRows = request.getAttribute("gridRows") != null ? (String) request.getAttribute("gridRows") : "";
			if (gridRows.trim().isEmpty()) {
			%>
			<div
				class="col-span-3 px-4 py-16 text-center bg-white rounded-xl border border-slate-200">
				<div class="flex flex-col items-center gap-3">
					<div
						class="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center">
						<i class="fa-solid fa-user-slash text-2xl text-slate-400"></i>
					</div>
					<div>
						<p class="text-slate-600 font-medium text-sm">No employees
							found</p>
						<p class="text-slate-400 text-xs mt-0.5">Try adjusting your
							search or filters</p>
					</div>
					<a href="viewUser"
						class="mt-1 inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-600 rounded-lg text-xs font-medium transition-colors">
						<i class="fa-solid fa-filter-circle-xmark text-xs"></i> Clear all
						filters
					</a>
				</div>
			</div>
			<%
			} else {
			%>
			<%=gridRows%>
			<%
			}
			%>
		</div>

		<div class="pagination">
			<%
			int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
			int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
			String sortBy = request.getAttribute("sortBy") != null ? (String) request.getAttribute("sortBy") : "fullname";
			String sortOrder = request.getAttribute("sortOrder") != null ? (String) request.getAttribute("sortOrder") : "asc";
			String baseParams = "search=" + java.net.URLEncoder.encode(search, "UTF-8") + "&role="
					+ java.net.URLEncoder.encode(roleFilter, "UTF-8") + "&designation="
					+ java.net.URLEncoder.encode(designationFilter, "UTF-8") + "&status="
					+ java.net.URLEncoder.encode(statusFilter, "UTF-8") + "&dateFrom="
					+ java.net.URLEncoder.encode(dateFrom, "UTF-8") + "&dateTo=" + java.net.URLEncoder.encode(dateTo, "UTF-8")
					+ "&sort=" + sortBy + "&order=" + sortOrder;
			int totalPagesClamped = Math.max(1, totalPages);
			int startPage = Math.max(1, currentPage - 2);
			int endPage = Math.min(totalPagesClamped, currentPage + 2);
			%>
			<a
				href="viewUser?<%=baseParams%>&page=<%=Math.max(1, currentPage - 1)%>"
				class="<%=currentPage <= 1 ? "disabled" : ""%>">Previous</a>
			<%
			if (startPage > 1) {
			%>
			<a href="viewUser?<%=baseParams%>&page=1">1</a>
			<%
			if (startPage > 2) {
			%><span class="ellipsis">...</span>
			<%
			}
			%>
			<%
			}
			for (int i = startPage; i <= endPage; i++) {
			%>
			<a href="viewUser?<%=baseParams%>&page=<%=i%>"
				class="<%=i == currentPage ? "active" : ""%>"><%=i%></a>
			<%
			}
			if (endPage < totalPagesClamped) {
			%>
			<%
			if (endPage < totalPagesClamped - 1) {
			%><span class="ellipsis">...</span>
			<%
			}
			%>
			<a href="viewUser?<%=baseParams%>&page=<%=totalPagesClamped%>"><%=totalPagesClamped%></a>
			<%
			}
			%>
			<a
				href="viewUser?<%=baseParams%>&page=<%=currentPage < totalPagesClamped ? currentPage + 1 : totalPagesClamped%>"
				class="<%=currentPage >= totalPagesClamped ? "disabled" : ""%>">Next</a>
		</div>
	</div>

	<div id="toast" aria-live="polite"></div>

	<!-- Import Modal -->
	<div id="importModal"
		onclick="if(event.target===this)closeImportModal()">
		<div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6"
			onclick="event.stopPropagation()">
			<div class="flex justify-between items-center mb-4">
				<h3 class="text-lg font-semibold text-slate-800">Import
					Employees</h3>
				<button type="button" onclick="closeImportModal()"
					class="text-slate-400 hover:text-slate-600">
					<i class="fa-solid fa-xmark text-xl"></i>
				</button>
			</div>
			<form action="bulkUploadEmployees" method="post"
				enctype="multipart/form-data" class="space-y-4">
				<input type="hidden" name="redirect" value="viewUser">
				<div>
					<label class="block text-sm font-medium text-slate-700 mb-2">Choose
						file (.xlsx or .csv)</label> <input type="file" name="excelFile"
						accept=".xlsx,.csv" required
						class="w-full text-sm border border-slate-300 rounded-lg px-3 py-2">
				</div>
				<p class="text-sm text-slate-500">Expected columns: username,
					password, status, role, firstname, lastname, email, joinedDate
					(dd-mm-yyyy), phone. Password: 8+ chars, uppercase, lowercase,
					number, symbol.</p>
				<div class="flex gap-3 pt-2">
					<button type="submit"
						class="flex-1 px-4 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium">Upload</button>
					<button type="button" onclick="closeImportModal()"
						class="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg font-medium">Cancel</button>
				</div>
			</form>
		</div>
	</div>

	<div id="deleteModal"
		onclick="if(event.target===this)closeDeleteModal()">
		<div
			class="bg-white rounded-xl shadow-xl max-w-sm mx-4 p-6 text-center"
			onclick="event.stopPropagation()">
			<h3 class="text-lg font-semibold text-slate-800 mb-2">Delete
				Employee</h3>
			<p class="text-slate-500 text-sm mb-4">Are you sure you want to
				delete this employee?</p>
			<div class="flex gap-3 justify-center">
				<button type="button" onclick="closeDeleteModal()"
					class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg font-medium">Cancel</button>
				<button type="button" onclick="confirmDelete()"
					class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium">Delete</button>
			</div>
		</div>
	</div>

	<script>
var deleteUserId = null;

function openDeleteModal(id) { deleteUserId = id; document.getElementById('deleteModal').classList.add('show'); }
function closeDeleteModal() { deleteUserId = null; document.getElementById('deleteModal').classList.remove('show'); }
function confirmDelete() { if (deleteUserId) window.location.href = 'deleteUser?id=' + deleteUserId; }

function loadAddEmployee() {
	try { window.parent.document.getElementById('contentFrame').src = 'addUser'; }
	catch(e) { window.location.href = 'addUser'; }
}

function openImportModal() { document.getElementById('importModal').classList.add('show'); }
function closeImportModal() { document.getElementById('importModal').classList.remove('show'); }

function toggleFilters() {
	var panel = document.getElementById('filtersPanel');
	if (panel) panel.classList.toggle('show');
}

function setView(v) {
	var list = document.getElementById('listView');
	var grid = document.getElementById('gridView');
	var btnList = document.getElementById('viewList');
	var btnGrid = document.getElementById('viewGrid');

	if (!list || !grid || !btnList || !btnGrid) return;

	if (v === 'grid') {
		list.classList.add('hidden');
		grid.classList.remove('hidden');

		btnGrid.classList.add('bg-slate-100','text-slate-700');
		btnGrid.classList.remove('text-slate-500');

		btnList.classList.remove('bg-slate-100','text-slate-700');
		btnList.classList.add('text-slate-500');
	} else {
		list.classList.remove('hidden');
		grid.classList.add('hidden');

		btnList.classList.add('bg-slate-100','text-slate-700');
		btnList.classList.remove('text-slate-500');

		btnGrid.classList.remove('bg-slate-100','text-slate-700');
		btnGrid.classList.add('text-slate-500');
	}

	try { localStorage.setItem('employees_view_mode', v); } catch(e) {}
}

document.addEventListener('DOMContentLoaded', function() {
	// Toast messages
	var params = new URLSearchParams(window.location.search);
	if (params.get('msg') === 'deleted') showToast('Employee deleted successfully', 'success');
	else if (params.get('msg') === 'error') showToast('Failed to delete employee', 'error');
	else if (params.get('msg') === 'updated') showToast('Employee updated successfully', 'success');
	<%if (successMsg != null && !successMsg.isEmpty()) {%>showToast('<%=successMsg.replace("'", "\\'").replace("\n", " ")%>', 'success');<%}%>
	<%if (errorMsg != null && !errorMsg.isEmpty()) {%>showToast('<%=errorMsg.replace("'", "\\'").replace("\n", " ")%>', 'error');<%}%>
		// Persist view mode
							try {
								var savedView = localStorage
										.getItem('employees_view_mode');
								if (savedView === 'grid'
										|| savedView === 'list')
									setView(savedView);
							} catch (e) {
							}

							// Auto-open filters if any filter is active (optional UX)
							(function autoOpenFiltersIfActive() {
								var panel = document
										.getElementById('filtersPanel');
								if (!panel)
									return;
								var hasAny = !!(params.get('role')
										|| params.get('status')
										|| params.get('designation')
										|| params.get('dateFrom') || params
										.get('dateTo'));
								if (hasAny)
									panel.classList.add('show');
							})();

							// Search behaviors: Enter submit + debounced submit while typing (fast + clean)
							var form = document.getElementById('viewUserForm');
							var wrap = document
									.querySelector('.search-input-wrap');
							var input = document.getElementById('searchInput');
							var clearBtn = document
									.getElementById('searchClear');

							if (form && wrap && input && clearBtn) {
								var debounceTimer = null;
								var DEBOUNCE_MS = 450;

								function toggleClear() {
									wrap.classList.toggle('has-text',
											input.value.trim().length > 0);
								}

								function submitDebounced() {
									clearTimeout(debounceTimer);
									debounceTimer = setTimeout(function() {
										form.submit();
									}, DEBOUNCE_MS);
								}

								toggleClear();

								input.addEventListener('input', function() {
									toggleClear();

									var v = input.value.trim();

									// Submit automatically only when empty (clear) or 2+ chars (avoid too many requests)
									if (v.length === 0 || v.length >= 2) {
										submitDebounced();
									} else {
										clearTimeout(debounceTimer);
									}
								});

								input.addEventListener('keydown', function(e) {
									if (e.key === 'Enter') {
										e.preventDefault();
										clearTimeout(debounceTimer);
										form.submit();
									}
								});

								clearBtn.addEventListener('click', function() {
									clearTimeout(debounceTimer);
									input.value = '';
									toggleClear();
									form.submit();
								});

								form.addEventListener('submit', function() {
									input.value = input.value.trim();
								});
							}
						});
	</script>
	<script src="<%=request.getContextPath()%>/employeeProfile.js?v=so-emp-profile-3"></script>
</body>
</html>
