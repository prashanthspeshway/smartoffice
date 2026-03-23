<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="java.util.List"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Team</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap" rel="stylesheet">
<style>body{font-family:'DM Sans',system-ui,sans-serif;}</style>
</head>
<body class="bg-slate-100 p-6">

<div class="max-w-5xl mx-auto space-y-6">
    <div>
        <h2 class="text-2xl font-bold text-slate-800"><i class="fa-solid fa-users mr-2 text-indigo-500"></i>My Team</h2>
        <p class="text-slate-500 text-sm mt-1">Teams you are a member of.</p>
    </div>

    <%if (myTeams == null || myTeams.isEmpty()) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-12 text-center">
        <i class="fa-solid fa-people-group text-4xl text-slate-300 mb-3"></i>
        <p class="text-slate-400 font-medium">You are not part of any team yet.</p>
    </div>
    <%} else { for (Team t : myTeams) {%>
    <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
        <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center flex-shrink-0">
                <i class="fa-solid fa-people-group text-indigo-500 text-xl"></i>
            </div>
            <div class="flex-1 min-w-0">
                <h3 class="font-bold text-slate-800 text-lg"><%=t.getName()%></h3>
                <div class="flex flex-wrap gap-4 mt-2 text-sm text-slate-500">
                    <span><i class="fa-solid fa-user-tie mr-1.5 text-indigo-400"></i>Manager: <strong class="text-slate-700"><%=t.getManagerFullname() != null ? t.getManagerFullname() : t.getManagerUsername()%></strong></span>
                    <span><i class="fa-solid fa-users mr-1.5 text-indigo-400"></i>Members: <strong class="text-slate-700"><%=t.getMembers().size()%></strong></span>
                </div>
                <%if (!t.getMembers().isEmpty()) {%>
                <div class="mt-3 flex flex-wrap gap-2">
                    <%for (User m : t.getMembers()) {%>
                    <span class="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-medium px-3 py-1 rounded-full">
                        <i class="fa-solid fa-circle-user text-indigo-400 text-xs"></i>
                        <%=m.getFullname() != null ? m.getFullname() : m.getEmail()%>
                    </span>
                    <%}%>
                </div>
                <%}%>
            </div>
        </div>
    </div>
    <%}}%>
</div>
</body>
</html>
