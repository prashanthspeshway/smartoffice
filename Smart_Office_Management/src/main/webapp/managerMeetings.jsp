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
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/smart-office-toast.css">
<script src="<%=request.getContextPath()%>/js/smart-office-toast.js"></script>
<style>body{font-family:'Geist',system-ui,sans-serif;}</style>
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

				<!-- ✅ normal form submission; date+time split so native time min grays past times -->
				<form id="managerScheduleForm" action="<%=request.getContextPath()%>/schedulemeeting" 
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

					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">Start</label>
							<div class="grid grid-cols-2 gap-2">
								<div>
									<span class="block text-xs font-medium text-slate-500 mb-1">Date</span>
									<input type="date" id="meetingStartDate" required
										class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
								</div>
								<div>
									<span class="block text-xs font-medium text-slate-500 mb-1">Time</span>
									<input type="time" id="meetingStartTimeOnly" required step="60"
										class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
								</div>
							</div>
							<input type="hidden" name="startTime" id="meetingStartTimeHidden" value="">
						</div>
						<div>
							<label class="block text-sm font-semibold text-slate-700 mb-2">End</label>
							<div class="grid grid-cols-2 gap-2">
								<div>
									<span class="block text-xs font-medium text-slate-500 mb-1">Date</span>
									<input type="date" id="meetingEndDate" required
										class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
								</div>
								<div>
									<span class="block text-xs font-medium text-slate-500 mb-1">Time</span>
									<input type="time" id="meetingEndTimeOnly" required step="60"
										class="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
								</div>
							</div>
							<input type="hidden" name="endTime" id="meetingEndTimeHidden" value="">
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

	<div id="toast" aria-live="polite"></div>

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

	// showToast: js/smart-office-toast.js

	/* ── Meeting date + time (same behavior as admin meetings) ── */
	function meetingToDateOnly(d) {
		var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
		return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
	}
	function meetingToTimeOnly(d) {
		var pad = function(n) { return n < 10 ? '0' + n : '' + n; };
		return pad(d.getHours()) + ':' + pad(d.getMinutes());
	}
	function meetingParseLocalDatetime(str) {
		if (!str) return null;
		var parts = str.split('T');
		if (parts.length !== 2) return null;
		var da = parts[0].split('-');
		var ti = parts[1].split(':');
		if (da.length < 3 || ti.length < 2) return null;
		return new Date(
			parseInt(da[0], 10),
			parseInt(da[1], 10) - 1,
			parseInt(da[2], 10),
			parseInt(ti[0], 10),
			parseInt(ti[1], 10),
			0,
			0
		);
	}
	function meetingGetStartDateTime() {
		var sd = document.getElementById('meetingStartDate');
		var st = document.getElementById('meetingStartTimeOnly');
		if (!sd || !st || !sd.value || !st.value) return null;
		return meetingParseLocalDatetime(sd.value + 'T' + st.value);
	}
	function meetingGetEndDateTime() {
		var ed = document.getElementById('meetingEndDate');
		var et = document.getElementById('meetingEndTimeOnly');
		if (!ed || !et || !ed.value || !et.value) return null;
		return meetingParseLocalDatetime(ed.value + 'T' + et.value);
	}
	function composeMeetingHiddenFields() {
		var sd = document.getElementById('meetingStartDate');
		var st = document.getElementById('meetingStartTimeOnly');
		var ed = document.getElementById('meetingEndDate');
		var et = document.getElementById('meetingEndTimeOnly');
		var hs = document.getElementById('meetingStartTimeHidden');
		var he = document.getElementById('meetingEndTimeHidden');
		if (!sd || !st || !hs) return;
		hs.value = (sd.value && st.value) ? (sd.value + 'T' + st.value) : '';
		if (ed && et && he) he.value = (ed.value && et.value) ? (ed.value + 'T' + et.value) : '';
	}
	function meetingMinEndDateTime() {
		var startDt = meetingGetStartDateTime();
		if (!startDt) return new Date(Date.now() + 60 * 1000);
		return new Date(startDt.getTime() + 60 * 1000);
	}
	function meetingMinuteTs(d) {
		return new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes()).getTime();
	}
	function meetingSameOrAfterMinute(a, b) {
		return meetingMinuteTs(a) >= meetingMinuteTs(b);
	}
	function meetingAfterMinute(a, b) {
		return meetingMinuteTs(a) > meetingMinuteTs(b);
	}
	function refreshMeetingDatetimeConstraints() {
		var now = new Date();
		var startDateEl = document.getElementById('meetingStartDate');
		var startTimeEl = document.getElementById('meetingStartTimeOnly');
		var endDateEl = document.getElementById('meetingEndDate');
		var endTimeEl = document.getElementById('meetingEndTimeOnly');
		if (!startDateEl || !startTimeEl || !endDateEl || !endTimeEl) return;

		var todayStr = meetingToDateOnly(now);
		var nowTimeStr = meetingToTimeOnly(now);

		startDateEl.min = todayStr;
		if (startDateEl.value && startDateEl.value < todayStr) startDateEl.value = todayStr;

		if (startDateEl.value === todayStr) {
			startTimeEl.min = nowTimeStr;
		} else {
			startTimeEl.removeAttribute('min');
		}
		if (startDateEl.value === todayStr && startTimeEl.value && startTimeEl.min && startTimeEl.value < startTimeEl.min) {
			startTimeEl.value = startTimeEl.min;
		}

		var minEnd = meetingMinEndDateTime();
		var minEndDateStr = meetingToDateOnly(minEnd);
		var minEndTimeStr = meetingToTimeOnly(minEnd);

		endDateEl.min = minEndDateStr;
		if (endDateEl.value && endDateEl.value < minEndDateStr) endDateEl.value = minEndDateStr;

		if (endDateEl.value === minEndDateStr) {
			endTimeEl.min = minEndTimeStr;
		} else {
			endTimeEl.removeAttribute('min');
		}
		if (endDateEl.value && endTimeEl.value && endDateEl.value === minEndDateStr) {
			if (endTimeEl.min && endTimeEl.value < endTimeEl.min) {
				endTimeEl.value = endTimeEl.min;
			}
		}

		composeMeetingHiddenFields();
	}
	function initManagerMeetingDefaults() {
		var now = new Date();
		var sd = document.getElementById('meetingStartDate');
		var st = document.getElementById('meetingStartTimeOnly');
		var ed = document.getElementById('meetingEndDate');
		var et = document.getElementById('meetingEndTimeOnly');
		if (!sd || !st || !ed || !et) return;
		sd.value = meetingToDateOnly(now);
		st.value = meetingToTimeOnly(now);
		var endSuggested = new Date(now.getTime() + 60 * 60 * 1000);
		ed.value = meetingToDateOnly(endSuggested);
		et.value = meetingToTimeOnly(endSuggested);
		refreshMeetingDatetimeConstraints();
	}

	// Check URL parameters for success/error messages
	document.addEventListener('DOMContentLoaded', function() {
		const params = new URLSearchParams(window.location.search);
		
		if (params.get('success') === 'MeetingScheduled') {
			showToast('Meeting scheduled successfully!', 'success');
			window.history.replaceState({}, document.title, window.location.pathname);
		}
		
		if (params.get('error') === 'InvalidInput') {
			showToast('Please fill all required fields', 'error');
		}
		
		if (params.get('error') === 'InvalidTime') {
			showToast('End time must be after start time', 'error');
		}

		if (params.get('error') === 'PastStart') {
			showToast('Start time cannot be in the past', 'error');
		}
		
		if (params.get('error') === 'ServerError') {
			showToast('Server error. Please try again', 'error');
		}

		var sd = document.getElementById('meetingStartDate');
		var st = document.getElementById('meetingStartTimeOnly');
		var ed = document.getElementById('meetingEndDate');
		var et = document.getElementById('meetingEndTimeOnly');
		if (sd && st && ed && et) {
			initManagerMeetingDefaults();
			function bindRefresh(el) {
				el.addEventListener('input', refreshMeetingDatetimeConstraints);
				el.addEventListener('change', refreshMeetingDatetimeConstraints);
				el.addEventListener('focus', refreshMeetingDatetimeConstraints);
			}
			bindRefresh(sd);
			bindRefresh(st);
			bindRefresh(ed);
			bindRefresh(et);

			var form = document.getElementById('managerScheduleForm');
			if (form) {
				form.addEventListener('submit', function(ev) {
					composeMeetingHiddenFields();
					refreshMeetingDatetimeConstraints();
					var now = new Date();
					var sv = meetingGetStartDateTime();
					var evd = meetingGetEndDateTime();
					if (!sv || !evd) return;
					if (!meetingSameOrAfterMinute(sv, now)) {
						ev.preventDefault();
						showToast('Start time must be at or after the current date and time.', 'error');
						return;
					}
					if (!meetingAfterMinute(evd, sv)) {
						ev.preventDefault();
						showToast('End time must be after start time.', 'error');
						return;
					}
				});
			}
		}
	});

	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
