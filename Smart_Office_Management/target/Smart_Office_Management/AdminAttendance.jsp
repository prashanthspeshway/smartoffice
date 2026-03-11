<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
 
<%@ page import="java.sql.*, com.smartoffice.dao.AttendanceDAO" %>
 
<%
String username = (String) session.getAttribute("username");
String role = (String) session.getAttribute("role");
 
// Session Validation
if (username == null || role == null || !"Admin".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}
 
AttendanceDAO dao = new AttendanceDAO();
 
Timestamp punchIn = null;
Timestamp punchOut = null;
String status = "Not Punched In";
 
ResultSet rs = null;
 
try {
    rs = dao.getTodayAttendance(username);
 
    if (rs != null && rs.next()) {
        punchIn = rs.getTimestamp("punch_in");
        punchOut = rs.getTimestamp("punch_out");
 
        if (punchIn != null && punchOut == null) {
            status = "Punched In";
        } else if (punchOut != null) {
            status = "Punched Out";
        }
    }
 
} catch (Exception e) {
    e.printStackTrace();  // check console for exact error
} finally {
    if (rs != null) {
        try { rs.close(); } catch (Exception e) {}
    }
}
%>
 
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Attendance</title>
 
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
 
<style>
body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6f8;
}
 
/* Card */
.box {
    max-width: 620px;
    margin: 30px auto;
    background: white;
    padding: 28px;
    border-radius: 14px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}
 
/* Status Badge */
.status-badge {
    display: inline-block;
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: bold;
    margin: 14px 0;
}
 
.status-badge.in {
    background: #dcfce7;
    color: #166534;
}
 
.status-badge.out {
    background: #fee2e2;
    color: #7f1d1d;
}
 
.status-badge.none {
    background: #e5e7eb;
    color: #374151;
}
 
/* Time Card */
.time-card {
    display: flex;
    gap: 12px;
    background: #f1f5f9;
    padding: 14px;
    border-radius: 8px;
    margin-bottom: 12px;
}
 
/* Buttons */
.punch-actions {
    display: flex;
    justify-content: center;
    gap: 16px;
    margin-top: 20px;
}
 
button {
    padding: 10px 18px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    color: white;
    font-weight: 600;
}
 
.punch-in-btn {
    background: #16a34a;
}
 
.punch-out-btn {
    background: #dc2626;
}
 
button:disabled {
    background: #9ca3af;
    cursor: not-allowed;
}
</style>
</head>
 
<body>
 
<div class="box">
    <h3><i class="fa-solid fa-clock"></i> My Attendance</h3>
 
    <!-- Status -->
    <div class="status-badge
        <%=status.equals("Punched In") ? "in" : status.equals("Punched Out") ? "out" : "none"%>">
        <%=status%>
    </div>
 
    <!-- Times -->
    <div class="time-card">
        Punch In: <b><%=punchIn != null ? punchIn : "--"%></b>
    </div>
 
    <div class="time-card">
        Punch Out: <b><%=punchOut != null ? punchOut : "--"%></b>
    </div>
 
    <!-- Actions -->
    <div class="punch-actions">
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="punchin">
            <button class="punch-in-btn"
                <%=punchIn != null ? "disabled" : ""%>>
                Punch In
            </button>
        </form>
 
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="punchout">
            <button class="punch-out-btn"
                <%=(punchIn == null || punchOut != null) ? "disabled" : ""%>>
                Punch Out
            </button>
        </form>
    </div>
</div>

<script>

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;

</script>
 
</body>
</html>
 
 