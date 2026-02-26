<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Overview</title>

<style>
body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: #c3cfe2;
    margin: 0;
}

/* ===== SAME CONTAINER STYLE AS ADD USER ===== */
.container {
    width: 100%;
}

/* ===== SAME FIELDSET STYLE ===== */
fieldset {
    max-width: 1000px;
    margin: 30px auto;
    height: 440px;
    padding: 10px 15px;
    border-radius: 14px;
    border: none;
    background: #c3cfe2;
    box-shadow: 0 10px 30px rgba(0,0,0,0.12);
}

/* ===== LEGEND SAME STYLE ===== */
legend {
    padding: 8px 18px;
    font-size: 18px;
    font-weight: bold;
    color: #fff;
    background: grey;
    border-radius: 8px;
}

/* ===== DASHBOARD GRID ===== */
.dashboard {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 22px;
    margin-top: 20px;
}

/* ===== CARD BASE ===== */
.card {
    padding: 22px 18px;
    border-radius: 14px;
    text-align: center;
    color: #ffffff;
    transition: 0.3s ease;
    box-shadow: 0 8px 18px rgba(0, 0, 0, 0.25);
}

.card:hover {
    transform: translateY(-6px);
}

/* ===== COLORS (UNCHANGED) ===== */
.managers  { background: linear-gradient(135deg, #2563eb, #1e40af); }
.employees { background: linear-gradient(135deg, #22c55e, #15803d); }
.total     { background: linear-gradient(135deg, #7c3aed, #5b21b6); }
.present   { background: linear-gradient(135deg, #f59e0b, #d97706); }
.absent    { background: linear-gradient(135deg, #ef4444, #b91c1c); }
.holidays  { background: linear-gradient(135deg, #14b8a6, #0f766e); }

/* ===== HOLIDAYS FULL WIDTH ===== */
.holidays {
    grid-column: 1 / -1;
}

/* ===== TEXT ===== */
.card h3 {
    margin-bottom: 18px;
    font-size: 15px;
    font-weight: 600;
}

.card span {
    font-size: 16px;
    font-weight: bold;
}

/* ===== LIST STYLE ===== */
.card-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.card-list li {
    background: rgba(255, 255, 255, 0.18);
    margin-bottom: 10px;
    padding: 14px 12px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: 0.25s ease;
}

.card-list li:last-child {
    margin-bottom: 0;
}

.card-list li:hover {
    background: rgba(255, 255, 255, 0.28);
    transform: scale(0.98);
}

/* ===== DARK MODE (SAME STYLE LOGIC) ===== */
body.dark-theme {
    background: #121212 !important;
}

body.dark-theme fieldset {
    background: #1e1e1e !important;
}

body.dark-theme legend {
    background: #2c2c2c !important;
    color: white !important;
}

body.dark-theme .card {
    background: #2c2c2c !important;
    color: white !important;
}

body.dark-theme .card-list li {
    background: rgba(255,255,255,0.08) !important;
}
</style>
</head>

<body>

<div class="container">
    <fieldset>
        <legend>📊 Admin Overview</legend>

        <div class="dashboard">

            <div class="card managers">
                <h3>Managers</h3>
                <ul class="card-list">
                    <li>${managers}</li>
                </ul>
            </div>

            <div class="card employees">
                <h3>Employees</h3>
                <ul class="card-list">
                    <li>${employees}</li>
                </ul>
            </div>

            <div class="card total">
                <h3>Total Staff</h3>
                <ul class="card-list">
                    <li>${totalStaff}</li>
                </ul>
            </div>

            <div class="card present">
                <h3>Present Today</h3>
                <ul class="card-list">
                    <li>${presentToday}</li>
                </ul>
            </div>

            <div class="card absent">
                <h3>Absent Today</h3>
                <ul class="card-list">
                    <li>${absentToday}</li>
                </ul>
            </div>

            <div class="card holidays">
                <h3>Upcoming Holiday</h3>
                <ul class="card-list">
                    <c:choose>
                        <c:when test="${not empty holidays}">
                            <c:forEach var="h" items="${holidays}">
                                <li>${h}</li>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <li>No upcoming holidays</li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>

        </div>

    </fieldset>
</div>

<script>
window.onload = function() {
    if (window.parent && window.parent.document.body.classList.contains("dark-theme")) {
        document.body.classList.add("dark-theme");
    }
};
</script>

</body>
</html>