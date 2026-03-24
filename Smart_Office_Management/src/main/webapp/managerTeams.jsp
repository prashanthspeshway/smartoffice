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
<title>My Teams</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>body{font-family:'Geist',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">
	<div class="max-w-7xl mx-auto">
		<h2 class="text-2xl font-bold text-slate-800 mb-6">My Teams</h2>

		<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
			<%
			List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
			if (myTeams != null && !myTeams.isEmpty()) {
				for (Team t : myTeams) {
			%>
			<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow">
				<div class="flex items-center gap-3 mb-4">
					<div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
						<i class="fa-solid fa-people-group text-indigo-600 text-xl"></i>
					</div>
					<h3 class="font-semibold text-slate-800 text-lg"><%=t.getName()%></h3>
				</div>

				<div class="space-y-2 text-sm text-slate-600 mb-4">
					<div class="flex items-center gap-2">
						<i class="fa-solid fa-user-tie text-slate-400"></i>
						<span><b>Manager:</b> <%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%></span>
					</div>
					<div class="flex items-center gap-2">
						<i class="fa-solid fa-users text-slate-400"></i>
						<span><b>Members:</b> <%=t.getMembers().size()%></span>
					</div>
				</div>

				<%if (!t.getMembers().isEmpty()) {%>
				<div class="pt-4 border-t border-slate-200">
					<p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">Team Members</p>
					<div class="flex flex-wrap gap-2">
						<%for (User m : t.getMembers()) {%>
						<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200">
							<i class="fa-solid fa-user text-slate-400 mr-1 text-xs"></i>
							<%=m.getFullname() != null ? m.getFullname() : m.getEmail()%>
						</span>
						<%}%>
					</div>
				</div>
				<%}%>
			</div>
			<%
				}
			} else {
			%>
			<div class="col-span-full">
				<div class="bg-white rounded-lg shadow-sm border border-slate-200 p-12 text-center">
					<i class="fa-solid fa-people-group text-slate-300 text-6xl mb-4"></i>
					<h3 class="text-lg font-semibold text-slate-700 mb-2">No Teams Found</h3>
					<p class="text-slate-500">No teams assigned to you yet. Ask admin to create a team and assign you as manager.</p>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</div>

	<script>
	document.addEventListener('contextmenu', e => e.preventDefault());
	document.onkeydown = e => (e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
	</script>
</body>
</html>
