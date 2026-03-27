<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>

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
<title>Performance Matrix</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
body{font-family:'Geist',system-ui,sans-serif;}
.step-indicator {
	display: flex;
	align-items: center;
	margin-bottom: 2rem;
}

.step {
	display: flex;
	align-items: center;
	gap: 0.5rem;
	color: #94a3b8;
}

.step.active {
	color: #1e293b;
}

.step.done {
	color: #10b981;
}

.step-number {
	width: 2rem;
	height: 2rem;
	border-radius: 50%;
	border: 2px solid #cbd5e1;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 700;
	background: #fff;
}

.step.active .step-number {
	background: #4f46e5;
	color: #fff;
	border-color: #4f46e5;
}

.step.done .step-number {
	background: #10b981;
	color: #fff;
	border-color: #10b981;
}

.step-line {
	flex: 1;
	height: 2px;
	background: #e2e8f0;
	margin: 0 0.75rem;
}

.step-line.done {
	background: #10b981;
}

.member-card {
	cursor: pointer;
	transition: all 0.2s;
}

.member-card:hover {
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.12);
}

.member-card.selected {
	border-color: #4f46e5;
	background: #eef2ff;
}

.panel-locked {
	opacity: 0.5;
	pointer-events: none;
}
</style>
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-7xl mx-auto">
		<h2 class="text-2xl font-bold text-slate-800 mb-6">Performance
			Matrix</h2>

		<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
			<!-- Step Indicator -->
			<div class="step-indicator">
				<div class="step active" id="step1">
					<div class="step-number">1</div>
					<span>Select Team</span>
				</div>
				<div class="step-line" id="line1"></div>
				<div class="step" id="step2">
					<div class="step-number">2</div>
					<span>Select Member</span>
				</div>
				<div class="step-line" id="line2"></div>
				<div class="step" id="step3">
					<div class="step-number">3</div>
					<span>Rate Performance</span>
				</div>
			</div>

			<!-- Three Panel Layout -->
			<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
				<!-- Panel 1: Team Selection -->
				<div class="bg-slate-50 rounded-lg p-6 border border-slate-200"
					id="panel1">
					<h3
						class="font-semibold text-slate-800 mb-4 flex items-center gap-2">
						<i class="fa-solid fa-layer-group text-pink-600"></i> Select Team
					</h3>
					<div class="space-y-3 max-h-96 overflow-y-auto" id="teamList">
						<%
						List<Team> perfTeams = (List<Team>) request.getAttribute("myTeams");
						if (perfTeams != null && !perfTeams.isEmpty()) {
							for (Team t : perfTeams) {
								String tName = t.getName();
								String tInitials = "";
								String[] tParts = tName.trim().split("\\s+");
								for (String tp : tParts) {
							if (!tp.isEmpty())
								tInitials += tp.substring(0, 1).toUpperCase();
								}
								if (tInitials.length() > 2)
							tInitials = tInitials.substring(0, 2);
								int memberCount = t.getMembers() != null ? t.getMembers().size() : 0;
						%>
						<div
							class="member-card bg-white rounded-lg p-4 border-2 border-slate-200"
							data-teamname="<%=tName%>" onclick="selectTeam(this)">
							<div class="flex items-center gap-3">
								<div
									class="w-10 h-10 bg-gradient-to-br from-pink-500 to-red-500 text-white rounded-lg flex items-center justify-center font-bold">
									<%=tInitials%>
								</div>
								<div class="flex-1">
									<div class="font-semibold text-slate-800"><%=tName%></div>
									<div class="text-xs text-slate-500"><%=memberCount%>
										member<%=memberCount != 1 ? "s" : ""%></div>
								</div>
								<div class="check-icon hidden">
									<i class="fa-solid fa-check text-indigo-600"></i>
								</div>
							</div>
						</div>
						<%
						}
						} else {
						%>
						<p class="text-slate-500 text-center py-8">No teams found.</p>
						<%
						}
						%>
					</div>
				</div>

				<!-- Panel 2: Member Selection -->
				<div
					class="bg-slate-50 rounded-lg p-6 border border-slate-200 panel-locked"
					id="panel2">
					<h3
						class="font-semibold text-slate-800 mb-4 flex items-center gap-2">
						<i class="fa-solid fa-users text-indigo-600"></i> Select Member
					</h3>
					<div
						class="bg-indigo-50 rounded-lg p-3 mb-4 text-sm text-slate-600"
						id="selectedTeamBanner">
						<i class="text-slate-400">← Select a team first</i>
					</div>
					<div class="space-y-3 max-h-80 overflow-y-auto" id="memberList">
						<p class="text-slate-500 text-center py-8">No team selected.</p>
					</div>
				</div>

				<!-- Panel 3: Rating -->
				<div
					class="bg-slate-50 rounded-lg p-6 border border-slate-200 panel-locked"
					id="panel3">
					<h3
						class="font-semibold text-slate-800 mb-4 flex items-center gap-2">
						<i class="fa-solid fa-star text-yellow-600"></i> Rate Performance
					</h3>

					<div class="bg-indigo-50 rounded-lg p-4 mb-4"
						id="selectedMemberDisplay">
						<p class="text-sm text-slate-500 italic">← Select a team
							member to rate</p>
					</div>

					<form id="performanceForm"
						action="<%=request.getContextPath()%>/submitPerformance"
						method="post">
						<input type="hidden" id="teamInput" name="team" value="">
						<input type="hidden" id="employeeInput" name="employee" value="">

						<div class="mb-4">
							<p class="text-sm font-semibold text-slate-700 mb-3">Performance
								Rating</p>
							<div class="space-y-2">
								<label
									class="flex items-center gap-3 p-3 bg-white rounded-lg border-2 border-slate-200 cursor-pointer hover:border-indigo-300">
									<input type="radio" name="rating" value="EXCELLENCE" required
									class="text-indigo-600"> <span>⭐ Excellence</span>
								</label> <label
									class="flex items-center gap-3 p-3 bg-white rounded-lg border-2 border-slate-200 cursor-pointer hover:border-indigo-300">
									<input type="radio" name="rating" value="GOOD"
									class="text-indigo-600"> <span>👍 Good</span>
								</label> <label
									class="flex items-center gap-3 p-3 bg-white rounded-lg border-2 border-slate-200 cursor-pointer hover:border-indigo-300">
									<input type="radio" name="rating" value="AVERAGE"
									class="text-indigo-600"> <span>😐 Average</span>
								</label> <label
									class="flex items-center gap-3 p-3 bg-white rounded-lg border-2 border-slate-200 cursor-pointer hover:border-indigo-300">
									<input type="radio" name="rating" value="BELOW_AVERAGE"
									class="text-indigo-600"> <span>📉 Below Average</span>
								</label>
							</div>
						</div>

						<button type="submit" id="submitBtn" disabled
							class="w-full px-6 py-3 bg-indigo-600 text-white font-semibold rounded-lg transition-colors disabled:bg-slate-400 disabled:cursor-not-allowed">
							<i class="fa-solid fa-paper-plane mr-2"></i>Submit Performance
						</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<script>
		// Utility function to get initials
		function getInitials(name) {
			const parts = name.trim().split(/\s+/);
			let ini = parts[0].charAt(0).toUpperCase();
			if (parts.length > 1)
				ini += parts[parts.length - 1].charAt(0).toUpperCase();
			return ini;
		}

		// Team members data
		var teamMembers = {};
	<%if (perfTeams != null && !perfTeams.isEmpty()) {
	out.println("teamMembers = {");
	boolean firstTeam = true;
	for (Team t : perfTeams) {
		if (!firstTeam)
			out.println(",");
		firstTeam = false;
		String tNameJs = t.getName().replace("\"", "\\\"").replace("'", "\\'");
		out.print("  \"" + tNameJs + "\": [");
		boolean firstMember = true;
		if (t.getMembers() != null) {
			for (User m : t.getMembers()) {
				if (!firstMember)
					out.print(",");
				firstMember = false;
				String mName = (m.getFullname() != null ? m.getFullname() : m.getEmail()).replace("\"", "\\\"");
				String mEmail = m.getEmail().replace("\"", "\\\"");
				out.print("{\"name\":\"" + mName + "\",\"email\":\"" + mEmail + "\"}");
			}
		}
		out.print("]");
	}
	out.println("};");
}%>
		function setStep(n) {
			for (let i = 1; i <= 3; i++) {
				const step = document.getElementById('step' + i);
				step.classList.remove('active', 'done');
				if (i < n)
					step.classList.add('done');
				if (i === n)
					step.classList.add('active');
			}
			const line1 = document.getElementById('line1');
			const line2 = document.getElementById('line2');
			if (line1)
				line1.classList.toggle('done', n > 1);
			if (line2)
				line2.classList.toggle('done', n > 2);
		}

		function getInitials(name) {
			var parts = name.trim().split(/\s+/);
			var ini = parts[0].charAt(0).toUpperCase();
			if (parts.length > 1)
				ini += parts[parts.length - 1].charAt(0).toUpperCase();
			return ini;
		}

		function selectTeam(card) {
			// Clear previous selection
			document.querySelectorAll('#teamList .member-card').forEach(
					function(c) {
						c.classList.remove('selected');
						c.querySelector('.check-icon').classList.add('hidden');
					});

			// Select this team
			card.classList.add('selected');
			card.querySelector('.check-icon').classList.remove('hidden');

			var teamName = card.getAttribute('data-teamname');
			document.getElementById('teamInput').value = teamName;

			// Load members
			var members = teamMembers[teamName] || [];
			var list = document.getElementById('memberList');

			if (members.length === 0) {
				list.innerHTML = '<p class="text-slate-500 text-center py-8">No members in this team.</p>';
			} else {
				list.innerHTML = members
						.map(
								function(m) {
									var initials = getInitials(m.name);
									return '<div class="member-card bg-white rounded-lg p-4 border-2 border-slate-200" '
											+ 'data-email="'
											+ m.email
											+ '" data-name="'
											+ m.name
											+ '" onclick="selectMember(this)">'
											+ '<div class="flex items-center gap-3">'
											+ '<div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 text-white rounded-full flex items-center justify-center font-bold text-sm">'
											+ initials
											+ '</div>'
											+ '<div class="flex-1">'
											+ '<div class="font-semibold text-slate-800">'
											+ m.name
											+ '</div>'
											+ '<div class="text-xs text-slate-500">'
											+ m.email
											+ '</div>'
											+ '</div>'
											+ '<div class="check-icon hidden">'
											+ '<i class="fa-solid fa-check text-indigo-600"></i>'
											+ '</div>' + '</div>' + '</div>';
								}).join('');
			}

			document.getElementById('selectedTeamBanner').innerHTML = '<i class="fa-solid fa-layer-group text-pink-600 mr-2"></i>'
					+ '<span class="font-semibold">' + teamName + '</span>';

			document.getElementById('panel2').classList.remove('panel-locked');
			document.getElementById('panel3').classList.add('panel-locked');
			document.getElementById('selectedMemberDisplay').innerHTML = '<p class="text-sm text-slate-500 italic">← Select a team member to rate</p>';
			document.getElementById('employeeInput').value = '';
			document.getElementById('submitBtn').disabled = true;
			document.querySelectorAll('input[name="rating"]').forEach(
					function(r) {
						r.checked = false;
					});

			setStep(2);
		}

		function selectMember(card) {
			// Clear previous selection
			document.querySelectorAll('#memberList .member-card').forEach(
					function(c) {
						c.classList.remove('selected');
						c.querySelector('.check-icon').classList.add('hidden');
					});

			// Select this member
			card.classList.add('selected');
			card.querySelector('.check-icon').classList.remove('hidden');

			var email = card.getAttribute('data-email');
			var name = card.getAttribute('data-name');
			document.getElementById('employeeInput').value = email;

			var initials = getInitials(name);
			document.getElementById('selectedMemberDisplay').innerHTML = '<div class="flex items-center gap-3">'
					+ '<div class="w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-500 text-white rounded-full flex items-center justify-center font-bold">'
					+ initials
					+ '</div>'
					+ '<div>'
					+ '<div class="font-semibold text-slate-800">'
					+ name
					+ '</div>'
					+ '<div class="text-xs text-indigo-600">'
					+ email + '</div>' + '</div>' + '</div>';

			document.getElementById('panel3').classList.remove('panel-locked');
			checkSubmit();
			setStep(3);
		}

		function checkSubmit() {
			var emp = document.getElementById('employeeInput').value;
			var rated = document.querySelector('input[name="rating"]:checked');
			document.getElementById('submitBtn').disabled = !(emp && rated);
		}

		document.querySelectorAll('input[name="rating"]').forEach(function(r) {
			r.addEventListener('change', checkSubmit);
		});

		// Toast notification handler
		function showToast(message, type) {
			type = type || 'success';
			// Try to use parent frame's toast if available
			if (window.parent && window.parent.showToast) {
				window.parent.showToast(message, type);
			} else {
				// Fallback: create inline toast
				var toast = document.createElement('div');
				var bgColor = (type === 'success') ? 'bg-green-500'
						: 'bg-red-500';
				toast.className = 'fixed bottom-6 right-4 px-6 py-3 rounded-lg shadow-lg z-50 max-w-[min(92vw,24rem)] '
						+ bgColor + ' text-white';
				toast.textContent = message;
				document.body.appendChild(toast);
				setTimeout(function() {
					toast.remove();
				}, 3000);
			}
		}

		// Check for URL parameters and show toast
		var urlParams = new URLSearchParams(window.location.search);
		if (urlParams.has('success')) {
			var success = urlParams.get('success');
			if (success === 'PerformanceSaved') {
				showToast('Performance rating saved successfully!', 'success');
			}
		}
		if (urlParams.has('error')) {
			var error = urlParams.get('error');
			var errorMessages = {
				'Invalid' : 'Invalid input. Please try again.',
				'InvalidRating' : 'Invalid rating selected.',
				'AlreadyRated' : 'Performance already rated for this employee this week.',
				'SaveFailed' : 'Failed to save performance rating. Please try again.'
			};
			showToast(errorMessages[error] || 'An error occurred.', 'error');
		}

		document.addEventListener('contextmenu', function(e) {
			e.preventDefault();
		});
		document.onkeydown = function(e) {
			return (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && [ 'I',
					'J', 'C' ].includes(e.key.toUpperCase()))) ? false : true;
		};
	</script>
</body>
</html>
