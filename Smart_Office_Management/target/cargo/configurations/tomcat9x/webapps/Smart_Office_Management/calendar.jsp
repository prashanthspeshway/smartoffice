<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Company Calendar</title>

<style>


body{
    font-family: "Segoe UI";
    margin:0;
    padding:0;
    background: linear-gradient(135deg,#764ba2,#6366f1);
}

/* CALENDAR BOX */
.calendar-box{
    width:97%;
    margin:auto;
    padding:15px;
    background:#f0ede9;
/*     border-radius:14px; */
    box-shadow:0 15px 35px rgba(0,0,0,0.2);
}

/* HEADER */
.header{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:10px;
}

.header h3{
    font-size:22px;
    font-weight:600;
    color:#6366f1;
}

.header button{
    border:none;
    background:#6366f1;
    color:white;
    font-size:16px;
    padding:8px 16px;
    border-radius:8px;
    cursor:pointer;
    transition:0.3s;
}

.header button:hover{
    background:#764ba2;
}

/* TABLE */
table{
    width:100%;
    height:calc(100vh - 100px);
    border-collapse:collapse;
    table-layout:fixed;
}

/* HEADER DAYS */
th{
    background:#6366f1;
    color:white;
    font-size:14px;
    height:45px;
}

/* CELLS */
td{
    background:white;
    border:1px solid #e5e7eb;
    height:55px;
    text-align:center;
    font-weight:500;
    border-radius:6px;
    transition:0.25s;
}

/* HOVER EFFECT */
td:hover{	
    background:#764ba2;
/*     transform:scale(1.05); */
    cursor:pointer;
}

/* HOLIDAY */
.holiday{
    background:#5b8e92;
    color:#eee;
    font-weight:600;
}
.holiday:hover{
    background:#1aa2ac;
     transform:none;
}


/* TODAY */
.today{
    background:#dbeafe;
    border:2px solid #6366f1;
    font-weight:700;
}

/* HOLIDAY NAME */
td div{
    font-size:13px;
    margin-top:4px;
    color:#eee;
    font-weight:800;
}

/* MODAL */
#holidayModal{
    display:none;
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.45);
    z-index:999;
}

#holidayModal>div{
    background:white;
    width:320px;
    padding:20px;
    border-radius:12px;
    box-shadow:0 15px 35px rgba(0,0,0,0.3);
    position:absolute;
    top:50%;
    left:50%;
    transform:translate(-50%,-50%);
}

#holidayModal h3{
    color:#6366f1;
}

/* INPUT */
#holidayNameInput{
    width:100%;
    padding:9px;
    border-radius:8px;
    border:1px solid #d1d5db;
    margin-top:10px;
}

#holidayNameInput:focus{
    outline:none;
    border-color:#6366f1;
}

/* BUTTONS */
#holidayModal button{
    padding:7px 14px;
    border:none;
    border-radius:7px;
    font-size:13px;
    cursor:pointer;
}

#holidayModal button:first-child{
    background:#e5e7eb;
}

#holidayModal button:last-child{
    background:#10b981;
    color:white;
}

#deleteBtn{
    background:#ef4444;
    color:white;
}

/* TOAST */
.toast{
    position:fixed;
    top:20px;
    right:25px;
    background:#6366f1;
    color:white;
    padding:12px 18px;
    border-radius:10px;
    font-size:14px;
    display:none;
    box-shadow:0 10px 25px rgba(0,0,0,0.25);
}

/* SCROLLBAR */
#calendarBox{
    height:500px;
    overflow-y:auto;
}

#calendarBox::-webkit-scrollbar{
    width:8px;
}

#calendarBox::-webkit-scrollbar-thumb{
    background:#6366f1;
    border-radius:10px;
}
</style>
</head>

<body>

	<div class="calendar-box" id="calendarBox">

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
	<div id="toast" class="toast"></div>

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
function showToast(message, type = "success") {
    const toast = document.getElementById("toast");

    // full reset
    toast.style.display = "none";
    toast.className = "toast";
    toast.offsetHeight; // force reflow

    toast.classList.add(type);
    toast.textContent = message;
    toast.style.display = "block";

    setTimeout(() => {
        toast.classList.add("hide");

        setTimeout(() => {
            toast.style.display = "none";
            toast.className = "toast";
        }, 400);
    }, 2500);
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

document.addEventListener('contextmenu', e => e.preventDefault());
document.onkeydown = e =>
  e.keyCode === 123 || (e.ctrlKey && e.shiftKey && ['I','J','C'].includes(e.key.toUpperCase()))
    ? false
    : true;
</script>
</body>
</html>
