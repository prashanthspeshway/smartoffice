<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Schedule Meeting • Smart Office HRMS</title>

<!-- Tailwind -->
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

<!-- FontAwesome -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<!-- Google Font -->
<link
	href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
	rel="stylesheet">

<style>
body {
	font-family: 'Inter', system-ui, sans-serif;
}
</style>

</head>


<body class="bg-slate-100 min-h-screen">

	<div class="max-w-4xl mx-auto p-6">

		<!-- Header -->
		<header class="mb-8">

			<h1
				class="text-2xl font-semibold text-slate-800 flex items-center gap-2 mb-2">
				<i class="fa-solid fa-video text-indigo-500"></i> Schedule Meeting
			</h1>

			<p class="text-slate-500 text-sm">Create and schedule meetings
				for employees and managers</p>

		</header>


		<!-- Meeting Card -->
		<div class="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">

			<form action="schedulemeeting" method="post" class="space-y-5">


				<!-- Title -->
				<div>

					<label class="block text-sm font-medium text-slate-700 mb-2">
						Meeting Title </label> <input type="text" name="title" required
						placeholder="e.g. Weekly Standup Meeting"
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">

				</div>



				<!-- Description -->
				<div>

					<label class="block text-sm font-medium text-slate-700 mb-2">
						Description </label>

					<textarea name="description" rows="3"
						placeholder="Enter meeting description..."
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg text-slate-700 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"></textarea>

				</div>



				<!-- Time Row -->
				<div class="grid grid-cols-1 md:grid-cols-2 gap-4">

					<div>

						<label class="block text-sm font-medium text-slate-700 mb-2">
							Start Time </label> <input type="datetime-local" name="startTime"
							required
							class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">

					</div>


					<div>

						<label class="block text-sm font-medium text-slate-700 mb-2">
							End Time </label> <input type="datetime-local" name="endTime" required
							class="w-full px-4 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">

					</div>

				</div>



				<!-- Meeting Link -->
				<div>

					<label class="block text-sm font-medium text-slate-700 mb-2">
						Meeting Link </label> <input type="text" name="meetingLink"
						placeholder="https://meet.google.com/..."
						class="w-full px-4 py-2.5 border border-slate-300 rounded-lg placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">

				</div>



				<!-- Participant Filter -->
				<div>

					<label class="block text-sm font-medium text-slate-700 mb-2">
						Select Participants </label>

					<!-- Tabs -->
					<div class="flex gap-3 mb-3">

						<button type="button" onclick="showDropdown('employees',this)"
							class="tabBtn px-3 py-1 bg-indigo-500 text-white rounded-md text-sm">
							Employees</button>

						<button type="button" onclick="showDropdown('managers',this)"
							class="tabBtn px-3 py-1 bg-slate-200 rounded-md text-sm">
							Managers</button>

						<button type="button" onclick="showDropdown('teams',this)"
							class="tabBtn px-3 py-1 bg-slate-200 rounded-md text-sm">
							Teams</button>

						<button type="button" onclick="showDropdown('individual',this)"
							class="tabBtn px-3 py-1 bg-slate-200 rounded-md text-sm">
							Individual</button>

					</div>


					<!-- Employees Dropdown -->
					<select id="employees" name="participants" multiple
						class="participantDropdown w-full border rounded-lg p-2">

						<c:forEach var="u" items="${employees}">
							<option value="${u.email}">${u.firstname} ${u.lastname}
							</option>
						</c:forEach>

					</select>


					<!-- Managers Dropdown -->
					<select id="managers" name="participants" multiple
						class="participantDropdown w-full border rounded-lg p-2 hidden">

						<c:forEach var="u" items="${managers}">
							<option value="${u.email}">${u.firstname} ${u.lastname}
							</option>
						</c:forEach>

					</select>


					<!-- Teams Dropdown -->
					<select id="teams" name="teamParticipants" multiple
						class="participantDropdown w-full border rounded-lg p-2 hidden">

						<c:forEach var="t" items="${teams}">
							<option value="${t.id}">${t.name}</option>
						</c:forEach>

					</select>


					<!-- Individual Dropdown -->
					<select id="individual" name="participants" multiple
						class="participantDropdown w-full border rounded-lg p-2 hidden">

						<c:forEach var="u" items="${users}">
							<option value="${u.email}">${u.firstname} ${u.lastname}
							</option>
						</c:forEach>

					</select>

				</div>



				<!-- Submit -->
				<div class="pt-4 border-t border-slate-200">

					<button type="submit"
						class="inline-flex items-center gap-2 px-6 py-2.5 bg-indigo-500 hover:bg-indigo-600 text-white rounded-lg font-medium text-sm transition-colors">

						<i class="fa-solid fa-calendar-plus"></i> Schedule Meeting

					</button>

				</div>


			</form>

		</div>

	</div>

</body>
<script>
function showDropdown(type, element){

    const dropdowns = document.querySelectorAll('.participantDropdown');

    dropdowns.forEach(el=>{
        el.style.display = "none";
        el.disabled = true;
    });

    const active = document.getElementById(type);
    active.style.display = "block";
    active.disabled = false;

    document.querySelectorAll('.tabBtn').forEach(btn=>{
        btn.classList.remove('bg-indigo-500','text-white');
        btn.classList.add('bg-slate-200');
    });

    element.classList.remove('bg-slate-200');
    element.classList.add('bg-indigo-500','text-white');
}
</script>

</html>