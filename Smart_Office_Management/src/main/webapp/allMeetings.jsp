<%@ page import="java.util.List" %>
<%@ page import="com.smartoffice.model.Meeting" %>

<%
List<Meeting> meetings = (List<Meeting>) request.getAttribute("allMeetings");
%>

<% if (meetings != null && !meetings.isEmpty()) { %>
    <% for (Meeting m : meetings) { %>
        <div class="employee-card">
            <div class="emp-header">
                <i class="fa-solid fa-video"></i>
                <span class="emp-name"><%=m.getTitle()%></span>
            </div>

            <div class="emp-body">
                <div><b>Start:</b> <%=m.getStartTime()%></div>
                <div><b>End:</b> <%=m.getEndTime()%></div>

                <% if (m.getMeetingLink() != null) { %>
                    <a href="<%=m.getMeetingLink()%>" target="_blank"
                       class="join-meeting-btn">
                        <i class="fa-solid fa-video"></i> Join
                    </a>
                <% } %>
            </div>
        </div>
        
        
    <% } %>
<% } else { %>
    <p>No meetings found.</p>
<% } %>