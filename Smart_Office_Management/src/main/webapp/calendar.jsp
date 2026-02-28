<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Company Calendar</title>

<style>


body {
    font-family: "Segoe UI";
    background: #c3cfe2;
    margin: 0;          /* ✅ removes outer space */
    padding: 0;
}

.calendar-box {
    width: 100%;
    height: 100%;
    margin: 0;                 /* ✅ no outer spacing */
    padding: 6px;             /* 🔹 optional: reduce padding */
    background: #c0d1eb;
    border-radius: 0;          /* optional if inside panel */
    box-shadow: none;          /* optional if parent already has shadow */
}

.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 1px;
}

.header h3 {
    font-size: 22px;
    font-weight: 600;
    color: #1f2937;
}

.header button {
	border: none;
	background: #e2ebf0;
	color: black;
	font-size: 16px;
    padding: 8px 14px;
	border-radius: 6px;
	cursor: pointer;
}

table {
    width: 100%;
    height: calc(100vh - 80px); /* header height compensation */
    border-collapse: collapse;
}

th, td {
    width: 14%;
    height: auto;              /* ⬆ taller cells */
    text-align: center;         /* center horizontally */
    vertical-align: middle;     /* center vertically */
    border: 1px solid #cbd5e1;
    border-radius: 5px;
    font-size: 16px;            /* ⬆ bigger date numbers */
    font-weight: 500;
    padding: 8px;
}

td {
    background: #ffffff;
    transition: background 0.3s ease, transform 0.3s ease;
}

td:hover {
    background: #c3cfe2;
    transform: scale(1.03);
    cursor: pointer;
}

td div {
    font-size: 13px;           /* ⬆ holiday name size */
    margin-top: 6px;
    color: #991b1b;
    font-weight: 600;
}

th {
    background: #e5e7eb;
    font-size: 15px;
    font-weight: 600;
    color: #374151;
    height: 50px;
}

.holiday {
	background: #fee2e2;
	color: #7f1d1d;
	font-weight: bold;
}

.today {
    background: #dbeafe;
    border: 2px solid #3b82f6;
    font-weight: 700;
}

/* ===== MODAL OVERLAY ===== */
#holidayModal {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.45);
	z-index: 999;
}

/* ===== MODAL BOX ===== */
#holidayModal > div {
	background: #ffffff;
	width: 320px;
	padding: 20px;
	border-radius: 10px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	font-family: "Segoe UI";
}

/* ===== MODAL TITLE ===== */
#holidayModal h3 {
	margin: 0 0 12px;
	font-size: 18px;
	color: #1f2937;
}

/* ===== INPUT ===== */
#holidayNameInput {
	width: 100%;
	padding: 8px 10px;
	font-size: 14px;
	border-radius: 6px;
	border: 1px solid #d1d5db;
	outline: none;
	box-sizing: border-box;
}

#holidayNameInput:focus {
	border-color: #3b82f6;
}

/* ===== BUTTON ROW ===== */
#holidayModal .button-row {
	display: flex;
	justify-content: flex-end;
	gap: 8px;
	margin-top: 16px;
}

/* ===== COMMON BUTTON ===== */
#holidayModal button {
	padding: 6px 14px;
	border-radius: 6px;
	border: none;
	font-size: 13px;
	cursor: pointer;
}

/* Cancel */
#holidayModal button:first-child {
	background: #e5e7eb;
	color: #111827;
}

#holidayModal button:first-child:hover {
	background: #d1d5db;
}

/* Save */
#holidayModal button:last-child {
	background: #16a34a;
	color: white;
}

#holidayModal button:last-child:hover {
	background: #15803d;
}

/* Delete */
#deleteBtn {
	background: #dc2626;
	color: white;
}

#deleteBtn:hover {
	background: #b91c1c;
}

/* ===== TOAST STYLES ===== */
#toast {
	visibility: hidden;
	min-width: 250px;
	background-color: #16a34a; /* green for success */
	color: white;
	text-align: center;
	border-radius: 8px;
	padding: 12px 20px;
	position: fixed;
	top: 20px;
	right: 20px;
	z-index: 1000;
	font-family: 'Segoe UI';
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
	opacity: 0;
	transform: translateY(-20px);
	transition: opacity 0.5s, transform 0.5s;
}

#toast.show {
	visibility: visible;
	opacity: 1;
	transform: translateY(0);
}

body.dark-mode #toast {
    background-color: #48bb78; /* lighter green for dark mode */
}
</style>
</head>

<body>

	<div class="calendar-box">

		<div class="header">
			<button onclick="changeMonth(-1)">◀</button>
			<h3 id="monthYear"></h3>
			<button onclick="changeMonth(1)">▶</button>
		</div>

		<table id="calendar">
			<thead>
				<tr>
					<th>Sun</th>
					<th>Mon</th>
					<th>Tue</th>
					<th>Wed</th>
					<th>Thu</th>
					<th>Fri</th>
					<th>Sat</th>
				</tr>
			</thead>
			<tbody></tbody>
		</table>

	</div>

	<!-- Holiday Modal -->
	<div id="holidayModal"
		style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.4);">

		<div
			style="background: white; width: 320px; padding: 20px; border-radius: 8px; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);">

			<h3 id="modalDate">Add Holiday</h3>

			<input type="text" id="holidayNameInput" placeholder="Holiday Name"
				style="width: 100%; padding: 8px; margin-top: 10px;">

			<div style="margin-top: 15px; text-align: right;">
				<div style="margin-top: 15px; text-align: right;">
					<button onclick="closeModal()">Cancel</button>

					<button type="button" id="deleteBtn" onclick="deleteHoliday()"
						style="background: #dc2626; color: white; border: none; padding: 6px 12px; display: none;">
						Delete</button>


					<button onclick="saveHoliday()"
						style="background: #16a34a; color: white; border: none; padding: 6px 12px;">
						Save</button>
				</div>

			</div>

		</div>
	</div>

	<!-- Toast Notification -->
	<div id="toast"></div>

	<script>
let today = new Date();
let currentMonth = today.getMonth();
let currentYear = today.getFullYear();
let selectedDate = "";

/* ===== LOAD CALENDAR ===== */
function loadCalendar(){

    const monthYear = document.getElementById("monthYear");
    const tbody = document.querySelector("#calendar tbody");
    tbody.innerHTML = "";

    const months = ["January","February","March","April","May","June",
                    "July","August","September","October","November","December"];

    monthYear.innerText = months[currentMonth] + " " + currentYear;

    let firstDay = new Date(currentYear,currentMonth,1).getDay();
    let daysInMonth = new Date(currentYear,currentMonth+1,0).getDate();

    fetch("getHolidays")
    .then(r => r.json())
    .then(holidays => {

        let holidayMap = {};
        holidays.forEach(h => {
            holidayMap[h.date] = h.name;
        });

        let row = document.createElement("tr");

        for(let i=0;i<firstDay;i++){
            row.appendChild(document.createElement("td"));
        }

        for(let d=1; d<=daysInMonth; d++){

            if(row.children.length === 7){
                tbody.appendChild(row);
                row = document.createElement("tr");
            }

            let cell = document.createElement("td");
            cell.innerText = d;

            let dayOfWeek = new Date(currentYear, currentMonth, d).getDay();

            // Weekend Red
            if(dayOfWeek === 0 || dayOfWeek === 6){
                cell.classList.add("holiday");
            }

            // Today
            if(d === today.getDate() &&
               currentMonth === today.getMonth() &&
               currentYear === today.getFullYear()){
                cell.classList.add("today");
            }

            // DB Holiday
            let month = (currentMonth+1).toString().padStart(2,'0');
            let day = d.toString().padStart(2,'0');
            let fullDate = currentYear + "-" + month + "-" + day;

            if(holidayMap[fullDate]){
                cell.classList.add("holiday");

                let div = document.createElement("div");
                div.style.fontSize = "11px";
                div.style.marginTop = "4px";
                div.innerText = holidayMap[fullDate];
                cell.appendChild(div);
            }

            row.appendChild(cell);
        }

        tbody.appendChild(row);
    });
}

/* ===== MONTH CHANGE ===== */
function changeMonth(step){
    currentMonth += step;
    if(currentMonth < 0){ currentMonth = 11; currentYear--; }
    if(currentMonth > 11){ currentMonth = 0; currentYear++; }
    loadCalendar();
}

/* ===== CLICK DATE → OPEN MODAL ===== */
document.addEventListener("click", function(e){

    let cell = e.target.closest("#calendar td");
    if(!cell) return;

    let day = cell.childNodes[0].nodeValue.trim();
    if(day === "" || isNaN(day)) return;

    const role = "<%=session.getAttribute("role")%>";
    if(!role || role.toLowerCase() !== "admin") return;

    let month = (currentMonth + 1).toString().padStart(2,'0');
    let d = day.toString().padStart(2,'0');

    selectedDate = currentYear + "-" + month + "-" + d;

    /* BLOCK PAST DATE */
    let todayStr = new Date().toISOString().split("T")[0];
    if(selectedDate < todayStr){
        showToast("previous date not allowed","error");
        return;
    }

    //  Check if holiday exists
    fetch("getHolidayByDate?date=" + selectedDate)
    .then(r => r.json())
    .then(data => {

        document.getElementById("holidayModal").style.display = "block";

        if(data.exists){
            editMode = true;
            document.getElementById("modalDate").innerText =
                "Edit Holiday for " + selectedDate;
            document.getElementById("holidayNameInput").value = data.name;
            document.getElementById("deleteBtn").style.display = "inline-block";
        } else {
            editMode = false;
            document.getElementById("modalDate").innerText =
                "Add Holiday for " + selectedDate;
            document.getElementById("holidayNameInput").value = "";
            document.getElementById("deleteBtn").style.display = "none";
        }
    });
});


/* ===== CLOSE MODAL ===== */
function closeModal(){
    document.getElementById("holidayModal").style.display = "none";
}

/* ===== SHOW TOAST ===== */
function showToast(message, type="success"){
    const toast = document.getElementById("toast");
    toast.innerText = message;

    // change color based on type
    if(type === "success") toast.style.backgroundColor = "#16a34a"; // green
    else if(type === "error") toast.style.backgroundColor = "#b91c1c"; // red

    toast.classList.add("show");

    setTimeout(() => {
        toast.classList.remove("show");
    }, 2500); // visible for 2.5s
}

/* ===== SAVE HOLIDAY ===== */
function saveHoliday(){

    let holidayName = document.getElementById("holidayNameInput").value.trim();
    if(holidayName === ""){
        showToast("Enter holiday name", "error");
        return;
    }

    let url = editMode ? "updateHoliday" : "addHoliday";

    fetch(url,{
        method:"POST",
        headers:{ "Content-Type":"application/x-www-form-urlencoded" },
        body:"date=" + encodeURIComponent(selectedDate) +
             "&name=" + encodeURIComponent(holidayName)
    })
    .then(r => r.text())
    .then(msg => {
        showToast(msg);
        closeModal();
        loadCalendar();
    })
    .catch(() => showToast("Operation failed","error"));
}	

/* delete existing holiday */
function deleteHoliday(){

    fetch("deleteHoliday?date=" + encodeURIComponent(selectedDate), {
        method: "GET"
    })
    .then(response => response.text())
    .then(msg => {
        showToast(msg || "Holiday deleted");
        closeModal();
        loadCalendar();
    })
    .catch(() => showToast("Delete failed","error"));
}



/* ===== LOAD ON START ===== */
window.onload = loadCalendar;
</script>
</body>
</html>
