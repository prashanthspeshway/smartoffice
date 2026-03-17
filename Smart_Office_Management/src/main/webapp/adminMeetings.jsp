<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.List, com.smartoffice.model.*, java.text.SimpleDateFormat" %>
<%
List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");
List<User> users = (List<User>) request.getAttribute("users");
List<Team> teams = (List<Team>) request.getAttribute("teams");
List<MeetingParticipant> participants = (List<MeetingParticipant>) request.getAttribute("participants");
String error = (String) request.getParameter("error");
String success = (String) request.getParameter("success");
SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
SimpleDateFormat displayDf = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Meetings • Smart Office HRMS</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
:root {
	--bg: #f0f2f8;
	--surface: #fff;
	--border: #e4e8f0;
	--text: #1a1d2e;
	--text2: #5a6278;
	--text3: #9aa0b8;
	--blue: #4f6ef7;
	--green: #22c55e;
	--red: #ef4444;
	--amber: #f59e0b;
	--purple: #a855f7;
	--shadow: 0 4px 16px rgba(0, 0, 0, .07);
	--radius: 16px;
}

*, *::before, *::after {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

body {
	font-family: 'DM Sans', system-ui, sans-serif;
	background: var(--bg);
	color: var(--text);
	min-height: 100vh;
	padding: 32px 20px;
}

.container {
	max-width: 1200px;
	margin: 0 auto;
}

.page-header {
	margin-bottom: 28px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 16px;
}

.page-title {
	font-size: 26px;
	font-weight: 700;
	color: var(--text);
	display: flex;
	align-items: center;
	gap: 10px;
}

.page-title i {
	color: var(--blue);
}

.btn {
	padding: 10px 20px;
	border: none;
	border-radius: 10px;
	font-size: 14px;
	font-weight: 600;
	cursor: pointer;
	transition: all .2s;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	font-family: inherit;
	text-decoration: none;
}

.btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(0, 0, 0, .15);
}

.btn-primary {
	background: var(--blue);
	color: white;
}

.btn-success {
	background: var(--green);
	color: white;
}

.btn-danger {
	background: var(--red);
	color: white;
}

.btn-sm {
	padding: 6px 12px;
	font-size: 13px;
}

.alert {
	padding: 16px 20px;
	border-radius: 12px;
	margin-bottom: 24px;
	font-size: 14px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 10px;
}

.alert.success {
	background: #f0fdf4;
	color: #15803d;
	border: 1px solid #86efac;
}

.alert.error {
	background: #fef2f2;
	color: #b91c1c;
	border: 1px solid #fca5a5;
}

.meetings-grid {
	display: grid;
	gap: 20px;
}

.meeting-card {
	background: var(--surface);
	border: 1px solid var(--border);
	border-radius: var(--radius);
	padding: 24px;
	box-shadow: var(--shadow);
	transition: all .2s;
}

.meeting-card:hover {
	box-shadow: 0 8px 24px rgba(0, 0, 0, .12);
}

.meeting-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 12px;
}

.meeting-title {
	font-size: 18px;
	font-weight: 700;
	color: var(--text);
	margin-bottom: 4px;
}

.meeting-time {
	font-size: 14px;
	color: var(--text2);
	display: flex;
	align-items: center;
	gap: 6px;
	margin-bottom: 12px;
}

.meeting-time i {
	color: var(--blue);
}

.meeting-desc {
	font-size: 14px;
	color: var(--text2);
	line-height: 1.5;
	margin-bottom: 16px;
}

.meeting-meta {
	display: flex;
	align-items: center;
	gap: 16px;
	flex-wrap: wrap;
	margin-bottom: 16px;
}

.meta-item {
	display: flex;
	align-items: center;
	gap: 6px;
	font-size: 13px;
	color: var(--text3);
}

.meta-item i {
	color: var(--blue);
}

.participant-badge {
	background: #eef1fe;
	color: var(--blue);
	padding: 4px 10px;
	border-radius: 6px;
	font-size: 12px;
	font-weight: 600;
}

.meeting-actions {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
}

.meeting-link {
	color: var(--blue);
	text-decoration: none;
	font-size: 14px;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 6px;
}

.meeting-link:hover {
	text-decoration: underline;
}

.modal {
	display: none;
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(0, 0, 0, .5);
	z-index: 1000;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.modal.active {
	display: flex;
}

.modal-content {
	background: var(--surface);
	border-radius: var(--radius);
	padding: 32px;
	max-width: 700px;
	width: 100%;
	max-height: 90vh;
	overflow-y: auto;
}

.modal-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
}

.modal-title {
	font-size: 22px;
	font-weight: 700;
	color: var(--text);
}

.close-btn {
	background: none;
	border: none;
	font-size: 24px;
	color: var(--text3);
	cursor: pointer;
	padding: 0;
	width: 32px;
	height: 32px;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 8px;
	transition: all .2s;
}

.close-btn:hover {
	background: var(--bg);
	color: var(--text);
}

.form-group {
	margin-bottom: 20px;
}

.form-label {
	display: block;
	font-size: 13px;
	font-weight: 600;
	color: var(--text2);
	margin-bottom: 8px;
	text-transform: uppercase;
	letter-spacing: .5px;
}

.form-input,
.form-textarea,
.form-select {
	width: 100%;
	padding: 12px 16px;
	border: 1px solid var(--border);
	border-radius: 10px;
	font-size: 14px;
	font-family: inherit;
	transition: all .2s;
}

.form-textarea {
	resize: vertical;
	min-height: 80px;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
	outline: none;
	border-color: var(--blue);
	box-shadow: 0 0 0 3px rgba(79, 110, 247, .1);
}

.checkbox-group {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
	gap: 10px;
	max-height: 200px;
	overflow-y: auto;
	padding: 12px;
	border: 1px solid var(--border);
	border-radius: 10px;
}

.checkbox-item {
	display: flex;
	align-items: center;
	gap: 8px;
}

.checkbox-item input[type="checkbox"] {
	width: 18px;
	height: 18px;
	cursor: pointer;
}

.checkbox-item label {
	font-size: 14px;
	color: var(--text2);
	cursor: pointer;
}

.radio-group {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.radio-item {
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 10px;
	border: 1px solid var(--border);
	border-radius: 8px;
	cursor: pointer;
	transition: all .2s;
}

.radio-item:hover {
	background: var(--bg);
}

.radio-item input[type="radio"] {
	width: 18px;
	height: 18px;
	cursor: pointer;
}

.radio-item label {
	font-size: 14px;
	color: var(--text2);
	cursor: pointer;
	flex: 1;
}

.form-row {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 16px;
}

.participants-list {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	margin-top: 12px;
}

.participant-chip {
	background: #eef1fe;
	color: var(--blue);
	padding: 6px 12px;
	border-radius: 20px;
	font-size: 13px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 6px;
}

.participant-role {
	font-size: 11px;
	opacity: 0.7;
}

.empty-state {
	text-align: center;
	padding: 60px 20px;
	color: var(--text3);
}

.empty-state i {
	font-size: 48px;
	margin-bottom: 16px;
	opacity: 0.3;
}

.empty-state p {
	font-size: 16px;
	margin-bottom: 24px;
}
</style>
</head>
<body>
	<div class="container">
		<div class="page-header">
			<div class="page-title">
				<i class="fa-solid fa-users-rectangle"></i>
				Meeting Management
			</div>
			<button class="btn btn-primary" onclick="openCreateModal()">
				<i class="fa-solid fa-plus"></i>
				Schedule New Meeting
			</button>
		</div>

		<% if (error != null) { %>
			<div class="alert error">
				<i class="fa-solid fa-circle-xmark"></i>
				<%= error %>
			</div>
		<% } %>

		<% if (success != null) { %>
			<div class="alert success">
				<i class="fa-solid fa-circle-check"></i>
				<%= success %>
			</div>
		<% } %>

		<div class="meetings-grid">
			<% if (meetings != null && !meetings.isEmpty()) { 
				for (Meeting m : meetings) { %>
				<div class="meeting-card">
					<div class="meeting-header">
						<div>
							<div class="meeting-title"><%= m.getTitle() %></div>
							<div class="meeting-time">
								<i class="fa-solid fa-clock"></i>
								<%= displayDf.format(m.getStartTime()) %> - <%= displayDf.format(m.getEndTime()) %>
							</div>
						</div>
					</div>

					<% if (m.getDescription() != null && !m.getDescription().isEmpty()) { %>
						<div class="meeting-desc"><%= m.getDescription() %></div>
					<% } %>

					<div class="meeting-meta">
						<div class="meta-item">
							<i class="fa-solid fa-user"></i>
							Created by: <%= m.getCreatedBy() %>
						</div>
						<div class="participant-badge">
							<i class="fa-solid fa-users"></i>
							<%= m.getParticipantCount() %> Participant<%= m.getParticipantCount() != 1 ? "s" : "" %>
						</div>
					</div>

					<div class="meeting-actions">
						<% if (m.getMeetingLink() != null && !m.getMeetingLink().isEmpty()) { %>
							<a href="<%= m.getMeetingLink() %>" target="_blank" class="meeting-link">
								<i class="fa-solid fa-video"></i>
								Join Meeting
							</a>
						<% } %>
						<button class="btn btn-primary btn-sm" onclick="viewParticipants(<%= m.getId() %>)">
							<i class="fa-solid fa-eye"></i>
							View Participants
						</button>
						<form method="post" action="adminMeetings" style="display:inline;" 
							  onsubmit="return confirm('Delete this meeting?');">
							<input type="hidden" name="action" value="delete">
							<input type="hidden" name="id" value="<%= m.getId() %>">
							<button type="submit" class="btn btn-danger btn-sm">
								<i class="fa-solid fa-trash"></i>
								Delete
							</button>
						</form>
					</div>
				</div>
			<% } 
			} else { %>
				<div class="empty-state">
					<i class="fa-solid fa-calendar-xmark"></i>
					<p>No meetings scheduled yet</p>
					<button class="btn btn-primary" onclick="openCreateModal()">
						<i class="fa-solid fa-plus"></i>
						Schedule Your First Meeting
					</button>
				</div>
			<% } %>
		</div>
	</div>

	<!-- Create Meeting Modal -->
	<div id="createModal" class="modal">
		<div class="modal-content">
			<div class="modal-header">
				<div class="modal-title">Schedule New Meeting</div>
				<button class="close-btn" onclick="closeCreateModal()">
					<i class="fa-solid fa-xmark"></i>
				</button>
			</div>

			<form method="post" action="adminMeetings">
				<input type="hidden" name="action" value="create">

				<div class="form-group">
					<label class="form-label">Meeting Title</label>
					<input type="text" name="title" class="form-input" required placeholder="e.g., Q1 Planning Meeting">
				</div>

				<div class="form-group">
					<label class="form-label">Description</label>
					<textarea name="description" class="form-textarea" placeholder="Meeting agenda and details..."></textarea>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label class="form-label">Start Time</label>
						<input type="datetime-local" name="startTime" class="form-input" required>
					</div>
					<div class="form-group">
						<label class="form-label">End Time</label>
						<input type="datetime-local" name="endTime" class="form-input" required>
					</div>
				</div>

				<div class="form-group">
					<label class="form-label">Meeting Link</label>
					<input type="url" name="meetingLink" class="form-input" placeholder="https://meet.google.com/...">
				</div>

				<div class="form-group">
					<label class="form-label">Participants</label>
					<div class="radio-group">
						<div class="radio-item">
							<input type="radio" id="specific" name="participantType" value="specific" checked onchange="toggleParticipants()">
							<label for="specific">Select Specific Users</label>
						</div>
						<div class="radio-item">
							<input type="radio" id="team" name="participantType" value="team" onchange="toggleParticipants()">
							<label for="team">Entire Team</label>
						</div>
						<div class="radio-item">
							<input type="radio" id="allManagers" name="participantType" value="allManagers" onchange="toggleParticipants()">
							<label for="allManagers">All Managers</label>
						</div>
						<div class="radio-item">
							<input type="radio" id="allEmployees" name="participantType" value="allEmployees" onchange="toggleParticipants()">
							<label for="allEmployees">All Employees</label>
						</div>
						<div class="radio-item">
							<input type="radio" id="everyone" name="participantType" value="everyone" onchange="toggleParticipants()">
							<label for="everyone">Everyone (All Managers + All Employees)</label>
						</div>
					</div>
				</div>

				<div id="specificUsers" class="form-group">
					<label class="form-label">Select Users</label>
					<div class="checkbox-group">
						<% if (users != null) {
							for (User u : users) { 
								if (!"admin".equalsIgnoreCase(u.getRole())) { %>
									<div class="checkbox-item">
										<input type="checkbox" name="participants" value="<%= u.getEmail() %>" id="user_<%= u.getEmail() %>">
										<label for="user_<%= u.getEmail() %>"><%= u.getFirstname() %> <%= u.getLastname() %> (<%= u.getRole() %>)</label>
									</div>
						<%      }
							}
						} %>
					</div>
				</div>

				<div id="teamSelect" class="form-group" style="display:none;">
					<label class="form-label">Select Team</label>
					<select name="teamId" class="form-select">
						<option value="">-- Select Team --</option>
						<% if (teams != null) {
							for (Team t : teams) { %>
								<option value="<%= t.getId() %>"><%= t.getName() %></option>
						<%  }
						} %>
					</select>
				</div>

				<button type="submit" class="btn btn-success" style="width:100%; margin-top:24px;">
					<i class="fa-solid fa-calendar-plus"></i>
					Schedule Meeting
				</button>
			</form>
		</div>
	</div>

	<!-- View Participants Modal -->
	<div id="participantsModal" class="modal">
		<div class="modal-content">
			<div class="modal-header">
				<div class="modal-title">Meeting Participants</div>
				<button class="close-btn" onclick="closeParticipantsModal()">
					<i class="fa-solid fa-xmark"></i>
				</button>
			</div>
			<div id="participantsList"></div>
		</div>
	</div>

	<script>
		function openCreateModal() {
			document.getElementById('createModal').classList.add('active');
		}

		function closeCreateModal() {
			document.getElementById('createModal').classList.remove('active');
		}

		function toggleParticipants() {
			const type = document.querySelector('input[name="participantType"]:checked').value;
			document.getElementById('specificUsers').style.display = type === 'specific' ? 'block' : 'none';
			document.getElementById('teamSelect').style.display = type === 'team' ? 'block' : 'none';
		}

		function viewParticipants(meetingId) {
			window.location.href = 'adminMeetings?action=view&id=' + meetingId;
		}

		function closeParticipantsModal() {
			document.getElementById('participantsModal').classList.remove('active');
		}

		// Auto-dismiss alerts after 5 seconds
		setTimeout(() => {
			const alerts = document.querySelectorAll('.alert');
			alerts.forEach(alert => alert.style.display = 'none');
		}, 5000);

		// Close modals on outside click
		document.querySelectorAll('.modal').forEach(modal => {
			modal.addEventListener('click', function(e) {
				if (e.target === this) {
					this.classList.remove('active');
				}
			});
		});
	</script>

	<% if (participants != null) { %>
		<script>
			document.getElementById('participantsModal').classList.add('active');
			const list = document.getElementById('participantsList');
			list.innerHTML = `
				<div class="participants-list">
					<% for (MeetingParticipant p : participants) { %>
						<div class="participant-chip">
							<i class="fa-solid fa-user"></i>
							<span><%= p.getFullName() %></span>
							<span class="participant-role">(<%= p.getRole() %>)</span>
						</div>
					<% } %>
				</div>
			`;
		</script>
	<% } %>
</body>
</html>
