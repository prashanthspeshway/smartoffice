<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Meeting"%>
<%@ page import="java.text.SimpleDateFormat"%>

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
<title>Meetings</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-7xl mx-auto">
		<div class="flex justify-between items-center mb-6">
			<h2 class="text-2xl font-bold text-slate-800">Meetings</h2>
			<button onclick="openAllMeetings()"
				class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-colors flex items-center gap-2">
				<i class="fa-solid fa-eye"></i> View All
			</button>
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
			<!-- Schedule Meeting Form -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<div class="flex items-center gap-3 mb-6">
					<i class="fa-solid fa-calendar-plus text-indigo-600 text-2xl"></i>
					<h3 class="text-lg font-semibold text-slate-800">Schedule New Meeting</h3>
				</div>

				<!-- ✅ CHANGED: Using normal form submission, not AJAX -->
				<form action="<%=request.getContextPath()%>/schedulemeeting" 
					method="post" 
					class="space-y-4">
					
					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Meeting Title</label>
						<input type="text" name="title" placeholder="e.g. Weekly Standup" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">Description</label>
						<textarea name="description" rows="3" placeholder="Briefly describe the agenda" required
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"></textarea>
					</div>

					<div class="grid grid-cols-2 gap-4">
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">Start Time</label>
							<input type="datetime-local" name="startTime" required
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						</div>
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">End Time</label>
							<input type="datetime-local" name="endTime" required
								class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
						</div>
					</div>

					<div>
						<label class="block text-sm font-semibold text-slate-700 mb-2">
							Meeting Link <span class="text-slate-500 font-normal">(optional)</span>
						</label>
						<input type="text" name="meetingLink" placeholder="Zoom / Google Meet link"
							class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
					</div>

					<button type="submit"
						class="w-full px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors">
						<i class="fa-solid fa-calendar-check mr-2"></i>Schedule Meeting
					</button>
				</form>
			</div>

			<!-- Today's Meetings -->
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
				<div class="flex items-center gap-3 mb-6">
					<i class="fa-solid fa-calendar-check text-indigo-600 text-2xl"></i>
					<h3 class="text-lg font-semibold text-slate-800">Today's Meetings</h3>
				</div>

				<div class="space-y-3 max-h-96 overflow-y-auto">
					<%
					List<Meeting> todayMeetings = (List<Meeting>) request.getAttribute("todayMeetings");
					if (todayMeetings != null && !todayMeetings.isEmpty()) {
						SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
						for (Meeting m : todayMeetings) {
						    boolean isSelf   = m.getCreatedBy() != null && m.getCreatedBy().equalsIgnoreCase(username);
						    String badgeCls  = isSelf ? "bg-indigo-100 text-indigo-700" : "bg-purple-100 text-purple-700";
						    String badgeIcon = isSelf ? "fa-user-tie" : "fa-user-shield";
						    String badgeText = isSelf ? "BY YOU" : "BY ADMIN";
						%>
						<div class="bg-slate-50 rounded-lg p-4 border border-slate-200 hover:shadow-md transition-shadow">
						    <div class="flex items-start justify-between gap-3 mb-2">
						        <div class="flex items-start gap-3">
						            <i class="fa-solid fa-video text-indigo-600 mt-1"></i>
						            <div>
						                <h4 class="font-semibold text-slate-800"><%=m.getTitle()%></h4>
						                <p class="text-sm text-slate-600 mt-1"><%=m.getDescription()%></p>
						            </div>
						        </div>
						        <span class="inline-flex items-center gap-1.5 text-xs font-bold px-2.5 py-1 rounded-full shrink-0 <%=badgeCls%>">
						            <i class="fa-solid <%=badgeIcon%>"></i> <%=badgeText%>
						        </span>
						    </div>
						    <div class="flex items-center gap-4 text-xs text-slate-500 ml-8">
						        <span>
						            <i class="fa-solid fa-clock mr-1"></i>
						            <%=timeFmt.format(m.getStartTime())%> - <%=timeFmt.format(m.getEndTime())%>
						        </span>
						    </div>
						    <%if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) {%>
						    <a href="<%=m.getMeetingLink()%>" target="_blank"
						        class="inline-flex items-center gap-2 mt-3 ml-8 px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold hover:bg-blue-200 transition-colors">
						        <i class="fa-solid fa-video"></i> Join Meeting
						    </a>
						    <%}%>
						</div>
						<%
						    }
					} else {
					%>
					<div class="text-center py-12">
						<i class="fa-solid fa-calendar-xmark text-slate-300 text-5xl mb-3"></i>
						<p class="text-slate-500">No meetings scheduled for today.</p>
					</div>
					<%
					}
					%>
				</div>
			</div>
		</div>
	</div>

	<!-- All Meetings Modal -->
	<div id="allMeetingsModal" 
		class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50"
		onclick="closeAllMeetings()">
		<div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[80vh] overflow-hidden"
			onclick="event.stopPropagation()">
			<div class="bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-4 flex justify-between items-center">
				<h3 class="text-lg font-semibold">All Scheduled Meetings</h3>
				<button onclick="closeAllMeetings()" class="text-white hover:text-gray-200">
					<i class="fa-solid fa-times text-xl"></i>
				</button>
			</div>
			<div id="allMeetingsContent" class="p-6 overflow-y-auto max-h-[calc(80vh-80px)]">
				<div class="flex items-center justify-center py-12">
					<i class="fa-solid fa-spinner fa-spin text-indigo-600 text-3xl"></i>
				</div>
			</div>
		</div>
	</div>

	<!-- Toast Notification -->
	<div id="toast" 
		class="fixed top-4 right-4 px-6 py-4 rounded-lg shadow-lg hidden transform transition-all duration-300">
	</div>

	<script>
	function openAllMeetings() {
		document.getElementById('allMeetingsModal').classList.remove('hidden');
		document.getElementById('allMeetingsModal').classList.add('flex');
		
		fetch('<%=request.getContextPath()%>/allMeetings')
			.then(res => res.text())
			.then(html => {
				document.getElementById('allMeetingsContent').innerHTML = html;
			})
			.catch(() => {
				document.getElementById('allMeetingsContent').innerHTML = 
					'<p class="text-red-600 text-center">Error loading meetings</p>';
			});
	}

	function closeAllMeetings() {
		document.getElementById('allMeetingsModal').classList.add('hidden');
		document.getElementById('allMeetingsModal').classList.remove('flex');
	}

	// ✅ NEW: Toast notification function
	function showToast(message, type = 'success') {
		const toast = document.getElementById('toast');
		toast.className = 'fixed top-4 right-4 px-6 py-4 rounded-lg shadow-lg transform transition-all duration-300';
		
		if (type === 'success') {
			toast.classList.add('bg-emerald-500', 'text-white');
		} else {
			toast.classList.add('bg-red-500', 'text-white');
		}
		
		toast.textContent = message;
		toast.classList.remove('hidden');
		
		setTimeout(() => {
			toast.classList.add('hidden');
		}, 3000);
	}

	// ✅ NEW: Check URL parameters for success/error messages
	document.addEventListener('DOMContentLoaded', function() {
		const params = new URLSearchParams(window.location.search);
		
		if (params.get('success') === 'MeetingScheduled') {
			showToast('Meeting scheduled successfully!', 'success');
			// Clean URL without reloading
			window.history.replaceState({}, document.title, window.location.pathname);
		}
		
		if (params.get('error') === 'InvalidInput') {
			showToast('Please fill all required fields', 'error');
		}
		
		if (params.get('error') === 'InvalidTime') {
			showToast('End time must be after start time', 'error');
		}
		
		if (params.get('error') === 'ServerError') {
			showToast('Server error. Please try again', 'error');
		}
	});

	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
