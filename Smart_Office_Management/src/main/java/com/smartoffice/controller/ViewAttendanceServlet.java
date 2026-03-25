package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.format.TextStyle;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.model.TeamAttendance;

/**
 * Opens an attendance report as a styled HTML page in the browser.
 *
 * URL patterns
 * ─────────────────────────────────────────────────────────
 *  All employees  : GET /viewAttendance?start=YYYY-MM-DD&end=YYYY-MM-DD
 *  Single employee: GET /viewAttendance?start=…&end=…&employeeId=42
 */
@SuppressWarnings("serial")
@WebServlet("/viewAttendance")
public class ViewAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ── Auth ───────────────────────────────────────────────────────── */
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String manager = (String) session.getAttribute("username");
        String role    = (String) session.getAttribute("role");

        /* ── Date range ─────────────────────────────────────────────────── */
        LocalDate today = LocalDate.now();
        String startParam = request.getParameter("start");
        String endParam   = request.getParameter("end");

        LocalDate startDate;
        LocalDate endDate;
        try {
            startDate = (startParam != null && !startParam.isBlank())
                    ? LocalDate.parse(startParam) : today.withDayOfMonth(1);
            endDate = (endParam != null && !endParam.isBlank())
                    ? LocalDate.parse(endParam) : today;
        } catch (DateTimeParseException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format. Use YYYY-MM-DD.");
            return;
        }

        if (startDate.isAfter(endDate)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Start date must be on or before end date.");
            return;
        }
        if (ChronoUnit.DAYS.between(startDate, endDate) > 400) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Date range cannot exceed 400 days.");
            return;
        }

        /* ── Optional single-employee filter ────────────────────────────── */
        String empIdParam = request.getParameter("employeeId");
        Integer singleEmpId = null;
        if (empIdParam != null && !empIdParam.isBlank()) {
            try {
                singleEmpId = Integer.parseInt(empIdParam.trim());
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid employeeId.");
                return;
            }
        }

        /* ── Fetch data ──────────────────────────────────────────────────── */
        AttendanceDAO dao = new AttendanceDAO();
        List<TeamAttendance> list;
        try {
            if (singleEmpId != null) {
                list = dao.getAttendanceForEmployeeAndDateRange(singleEmpId, startDate, endDate);
            } else if ("admin".equalsIgnoreCase(role)) {
                list = dao.getAllAttendanceForDateRange(startDate, endDate);
            } else {
                list = dao.getTeamAttendanceForDateRange(manager, startDate, endDate);
            }
        } catch (Exception e) {
            throw new ServletException("Error fetching attendance data", e);
        }

        int totalDays = (int) ChronoUnit.DAYS.between(startDate, endDate) + 1;

        /* ── Group rows by employee name ────────────────────────────────── */
        // employee name → ( date → record )
        Map<String, Map<LocalDate, TeamAttendance>> byEmployee = new LinkedHashMap<>();
        for (TeamAttendance ta : list) {
            String emp = ta.getFullName() != null ? ta.getFullName() : "(Unknown)";
            byEmployee.putIfAbsent(emp, new LinkedHashMap<>());
            if (ta.getAttendanceDate() != null) {
                byEmployee.get(emp).put(ta.getAttendanceDate().toLocalDate(), ta);
            }
        }

        /* ── Page title ─────────────────────────────────────────────────── */
        String pageTitle;
        if (singleEmpId != null && !byEmployee.isEmpty()) {
            pageTitle = byEmployee.keySet().iterator().next()
                    + " — Attendance Report";
        } else {
            pageTitle = "Team Attendance Report";
        }
        String rangeLabel = startDate + " — " + endDate;

        /* ── Compute per-employee summary stats ─────────────────────────── */
        // We'll compute inside the HTML loop; just need the structure.

        /* ── Write HTML ─────────────────────────────────────────────────── */
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width,initial-scale=1'>");
        out.println("<title>" + esc(pageTitle) + " • Smart Office HRMS</title>");
        out.println("<link rel='preconnect' href='https://fonts.googleapis.com'>");
        out.println("<link rel='preconnect' href='https://fonts.gstatic.com' crossorigin>");
        out.println("<link href='https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap' rel='stylesheet'>");
        out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css'>");
        out.println("<style>");
        out.println(CSS);
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");

        /* ── Top bar ── */
        out.println("<div class='topbar'>");
        out.println("  <div class='topbar-inner'>");
        out.println("    <div class='topbar-left'>");
        out.println("      <div class='brand'><i class='fa-solid fa-calendar-check'></i> Smart Office HRMS</div>");
        out.println("      <h1 class='report-title'>" + esc(pageTitle) + "</h1>");
        out.println("      <span class='range-badge'><i class='fa-regular fa-calendar'></i> " + esc(rangeLabel) + "</span>");
        out.println("    </div>");
        out.println("    <div class='topbar-right'>");
        // Build download URL for same params
        String dlParams = "start=" + startDate + "&end=" + endDate
                + (singleEmpId != null ? "&employeeId=" + singleEmpId : "");
        out.println("      <a href='" + request.getContextPath() + "/exportTeamAttendance?" + dlParams
                + "' class='btn-dl'><i class='fa-solid fa-download'></i> Download Excel</a>");
        out.println("      <button onclick='window.print()' class='btn-print'>"
                + "<i class='fa-solid fa-print'></i> Print</button>");
        out.println("    </div>");
        out.println("  </div>");
        out.println("</div>");

        out.println("<div class='page-wrap'>");

        if (byEmployee.isEmpty()) {
            out.println("<div class='empty-state'>");
            out.println("  <i class='fa-regular fa-folder-open'></i>");
            out.println("  <p>No attendance records found for the selected range.</p>");
            out.println("</div>");
        } else {

            /* ── Legend ── */
            out.println("<div class='legend'>");
            out.println("  <span class='leg-title'>Legend:</span>");
            out.println("  <span class='leg present'>Present</span>");
            out.println("  <span class='leg half-day'>Half Day</span>");
            out.println("  <span class='leg absent'>Absent</span>");
            out.println("  <span class='leg on-leave'>On Leave</span>");
            out.println("  <span class='leg weekend'>Weekend</span>");
            out.println("  <span class='leg future'>Future</span>");
            out.println("</div>");

            /* ── One card per employee ── */
            for (Map.Entry<String, Map<LocalDate, TeamAttendance>> empEntry : byEmployee.entrySet()) {
                String empName     = empEntry.getKey();
                Map<LocalDate, TeamAttendance> dayMap = empEntry.getValue();

                // Compute summary
                int presentDays = 0, halfDays = 0, absentDays = 0,
                    leaveDays = 0, weekendDays = 0;

                for (int i = 0; i < totalDays; i++) {
                    LocalDate d = startDate.plusDays(i);
                    if (d.isAfter(today)) continue;
                    boolean isWeekend = (d.getDayOfWeek() == DayOfWeek.SATURDAY
                            || d.getDayOfWeek() == DayOfWeek.SUNDAY);
                    TeamAttendance ta = dayMap.get(d);
                    String status = (ta != null && ta.getStatus() != null)
                            ? ta.getStatus().trim() : "";

                    if ("On Leave".equalsIgnoreCase(status)) {
                        leaveDays++;
                    } else if (isWeekend) {
                        weekendDays++;
                    } else if (ta == null || ta.getPunchIn() == null) {
                        absentDays++;
                    } else if ("Half Day".equalsIgnoreCase(status)) {
                        halfDays++;
                    } else {
                        presentDays++;
                    }
                }

                // Initials
                String[] nameParts = empName.trim().split("\\s+");
                String initials;
                if (nameParts.length >= 2) {
                    initials = ("" + nameParts[0].charAt(0)
                            + nameParts[nameParts.length - 1].charAt(0)).toUpperCase();
                } else {
                    initials = empName.length() >= 2
                            ? empName.substring(0, 2).toUpperCase()
                            : empName.toUpperCase();
                }

                out.println("<div class='emp-card'>");

                /* Card header */
                out.println("  <div class='card-header'>");
                out.println("    <div class='avatar'>" + esc(initials) + "</div>");
                out.println("    <div class='card-header-info'>");
                out.println("      <div class='emp-name'>" + esc(empName) + "</div>");
                out.println("      <div class='summary-chips'>");
                out.println("        <span class='chip c-present'><i class='fa-solid fa-circle-check'></i> " + presentDays + " Present</span>");
                out.println("        <span class='chip c-half'><i class='fa-solid fa-circle-half-stroke'></i> " + halfDays + " Half Day</span>");
                out.println("        <span class='chip c-absent'><i class='fa-solid fa-circle-xmark'></i> " + absentDays + " Absent</span>");
                out.println("        <span class='chip c-leave'><i class='fa-solid fa-umbrella-beach'></i> " + leaveDays + " Leave</span>");
                out.println("      </div>");
                out.println("    </div>");
                out.println("  </div>"); // .card-header

                /* Calendar grid */
                out.println("  <div class='cal-grid'>");

                for (int i = 0; i < totalDays; i++) {
                    LocalDate d     = startDate.plusDays(i);
                    boolean isFuture  = d.isAfter(today);
                    boolean isWeekend = (d.getDayOfWeek() == DayOfWeek.SATURDAY
                            || d.getDayOfWeek() == DayOfWeek.SUNDAY);
                    boolean isToday   = d.equals(today);

                    TeamAttendance ta = dayMap.get(d);
                    String status = (ta != null && ta.getStatus() != null)
                            ? ta.getStatus().trim() : "";

                    // Determine cell class
                    String cellClass;
                    String inTime  = null;
                    String outTime = null;
                    String label   = null;

                    if (isFuture) {
                        cellClass = "day-cell future";
                        label = "—";
                    } else if ("On Leave".equalsIgnoreCase(status)) {
                        cellClass = "day-cell on-leave";
                        label = "On Leave";
                    } else if (isWeekend) {
                        cellClass = "day-cell weekend";
                        label = d.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
                    } else if (ta == null || ta.getPunchIn() == null) {
                        cellClass = "day-cell absent";
                        label = "Absent";
                    } else if ("Half Day".equalsIgnoreCase(status)) {
                        cellClass = "day-cell half-day";
                        inTime  = ta.getPunchIn().toLocalDateTime().toLocalTime()
                                    .toString().substring(0, 5);
                        outTime = ta.getPunchOut() != null
                                ? ta.getPunchOut().toLocalDateTime().toLocalTime()
                                    .toString().substring(0, 5)
                                : "—";
                    } else {
                        cellClass = "day-cell present";
                        inTime  = ta.getPunchIn().toLocalDateTime().toLocalTime()
                                    .toString().substring(0, 5);
                        outTime = ta.getPunchOut() != null
                                ? ta.getPunchOut().toLocalDateTime().toLocalTime()
                                    .toString().substring(0, 5)
                                : "—";
                    }

                    if (isToday) cellClass += " today";

                    out.println("    <div class='" + cellClass + "'>");
                    out.println("      <div class='day-num'>" + d.getDayOfMonth() + "</div>");
                    out.println("      <div class='day-name'>"
                            + d.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH) + "</div>");

                    if (inTime != null) {
                        out.println("      <div class='punch in'><i class='fa-solid fa-arrow-right-to-bracket'></i> " + inTime + "</div>");
                        out.println("      <div class='punch out'><i class='fa-solid fa-arrow-right-from-bracket'></i> " + outTime + "</div>");
                    } else if (label != null) {
                        out.println("      <div class='day-label'>" + esc(label) + "</div>");
                    }

                    out.println("    </div>"); // .day-cell
                }

                out.println("  </div>"); // .cal-grid
                out.println("</div>"); // .emp-card
            }
        }

        out.println("</div>"); // .page-wrap

        /* ── Footer ── */
        out.println("<div class='footer'>Generated by Smart Office HRMS &nbsp;•&nbsp; "
                + java.time.LocalDateTime.now().toString().replace("T", " ").substring(0, 16)
                + "</div>");

        out.println("</body></html>");
    }

    /* ── HTML escaping helper ── */
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    /* ══════════════════════════════════════════════════════════════════════
       Embedded CSS
    ════════════════════════════════════════════════════════════════════════ */
    private static final String CSS =
        "*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }" +
        "body { font-family: 'Geist', system-ui, sans-serif;" +
        "       background: #f1f5f9; color: #334155; min-height: 100vh; }" +

        /* ── Top bar ── */
        ".topbar { background: #3f51b5; color: #fff; padding: 0;" +
        "          box-shadow: 0 2px 8px rgba(0,0,0,.2); position: sticky; top:0; z-index:100; }" +
        ".topbar-inner { max-width: 1400px; margin: 0 auto;" +
        "                display: flex; align-items: center; justify-content: space-between;" +
        "                gap: 16px; padding: 14px 24px; flex-wrap: wrap; }" +
        ".topbar-left  { display: flex; flex-direction: column; gap: 4px; }" +
        ".topbar-right { display: flex; gap: 10px; align-items: center; flex-shrink: 0; }" +
        ".brand { font-size: .75rem; font-weight: 500; opacity: .75; letter-spacing: .5px;" +
        "         text-transform: uppercase; }" +
        ".report-title { font-size: 1.1rem; font-weight: 700; line-height: 1.2; }" +
        ".range-badge { display: inline-flex; align-items: center; gap: 6px;" +
        "               background: rgba(255,255,255,.18); border-radius: 20px;" +
        "               padding: 2px 10px; font-size: .75rem; font-weight: 500; }" +

        ".btn-dl, .btn-print { padding: 9px 16px; border-radius: 8px; font-weight: 600;" +
        "  font-size: .8125rem; cursor: pointer; border: none; text-decoration: none;" +
        "  display: inline-flex; align-items: center; gap: 7px; transition: opacity .15s; }" +
        ".btn-dl    { background: #fff; color: #3f51b5; }" +
        ".btn-print { background: rgba(255,255,255,.18); color: #fff; }" +
        ".btn-dl:hover, .btn-print:hover { opacity: .85; }" +

        /* ── Page wrap ── */
        ".page-wrap { max-width: 1400px; margin: 0 auto; padding: 24px; }" +

        /* ── Legend ── */
        ".legend { display: flex; align-items: center; gap: 10px; flex-wrap: wrap;" +
        "          margin-bottom: 20px; background: #fff; padding: 12px 18px;" +
        "          border-radius: 10px; border: 1px solid #e2e8f0;" +
        "          box-shadow: 0 1px 3px rgba(0,0,0,.05); }" +
        ".leg-title { font-size: .75rem; font-weight: 700; color: #94a3b8;" +
        "             text-transform: uppercase; letter-spacing: .5px; margin-right: 4px; }" +
        ".leg { padding: 3px 12px; border-radius: 20px; font-size: .75rem; font-weight: 600; }" +
        ".leg.present  { background: #dcfce7; color: #166534; }" +
        ".leg.half-day { background: #fef3c7; color: #92400e; }" +
        ".leg.absent   { background: #fee2e2; color: #991b1b; }" +
        ".leg.on-leave { background: #e9d5ff; color: #5b21b6; }" +
        ".leg.weekend  { background: #e2e8f0; color: #475569; }" +
        ".leg.future   { background: #f8fafc; color: #94a3b8; border: 1px dashed #cbd5e1; }" +

        /* ── Employee card ── */
        ".emp-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px;" +
        "            box-shadow: 0 1px 4px rgba(0,0,0,.06); margin-bottom: 24px;" +
        "            overflow: hidden; }" +

        ".card-header { display: flex; align-items: center; gap: 14px;" +
        "               padding: 18px 22px; border-bottom: 1px solid #e2e8f0;" +
        "               background: #f8fafc; }" +
        ".avatar { width: 46px; height: 46px; border-radius: 50%; flex-shrink: 0;" +
        "          background: linear-gradient(135deg,#6366f1,#8b5cf6);" +
        "          color: #fff; display: flex; align-items: center; justify-content: center;" +
        "          font-weight: 700; font-size: 15px; }" +
        ".card-header-info { flex: 1; min-width: 0; }" +
        ".emp-name { font-size: 1rem; font-weight: 700; color: #0f172a; margin-bottom: 6px;" +
        "            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }" +

        ".summary-chips { display: flex; gap: 8px; flex-wrap: wrap; }" +
        ".chip { display: inline-flex; align-items: center; gap: 5px;" +
        "        padding: 3px 10px; border-radius: 20px; font-size: .75rem; font-weight: 600; }" +
        ".c-present { background: #dcfce7; color: #166534; }" +
        ".c-half    { background: #fef3c7; color: #92400e; }" +
        ".c-absent  { background: #fee2e2; color: #991b1b; }" +
        ".c-leave   { background: #e9d5ff; color: #5b21b6; }" +

        /* ── Calendar grid ── */
        ".cal-grid { display: flex; flex-wrap: wrap; gap: 6px; padding: 18px 22px; }" +

        ".day-cell { width: 76px; min-height: 90px; border-radius: 10px;" +
        "            display: flex; flex-direction: column; align-items: center;" +
        "            justify-content: center; gap: 3px; padding: 8px 4px;" +
        "            font-size: .7rem; transition: transform .1s; }" +
        ".day-cell:hover { transform: translateY(-2px); }" +

        ".day-cell.today { outline: 2px solid #6366f1; outline-offset: 1px; }" +

        ".day-cell.present  { background: #f0fdf4; border: 1px solid #86efac; }" +
        ".day-cell.half-day { background: #fffbeb; border: 1px solid #fcd34d; }" +
        ".day-cell.absent   { background: #fff1f2; border: 1px solid #fca5a5; }" +
        ".day-cell.on-leave { background: #f5f3ff; border: 1px solid #c4b5fd; }" +
        ".day-cell.weekend  { background: #f1f5f9; border: 1px solid #cbd5e1; }" +
        ".day-cell.future   { background: #f8fafc; border: 1px dashed #cbd5e1; opacity: .6; }" +

        ".day-num  { font-size: .9rem; font-weight: 700; color: #0f172a; line-height: 1; }" +
        ".day-name { font-size: .65rem; font-weight: 500; color: #94a3b8;" +
        "            text-transform: uppercase; letter-spacing: .4px; margin-bottom: 4px; }" +
        ".day-label { font-size: .68rem; font-weight: 700; text-align: center; padding: 0 2px;" +
        "             color: inherit; }" +

        ".day-cell.present  .day-label," +
        ".day-cell.present  .day-num  { color: #166534; }" +
        ".day-cell.half-day .day-num  { color: #92400e; }" +
        ".day-cell.absent   .day-num  { color: #991b1b; }" +
        ".day-cell.on-leave .day-num  { color: #5b21b6; }" +
        ".day-cell.weekend  .day-num  { color: #64748b; }" +

        ".punch { display: flex; align-items: center; gap: 4px;" +
        "         font-size: .67rem; font-weight: 600; font-family: 'Geist Mono', monospace; }" +
        ".punch.in  { color: #166534; }" +
        ".punch.out { color: #1e40af; }" +

        /* ── Empty state ── */
        ".empty-state { text-align: center; padding: 80px 20px; color: #94a3b8; }" +
        ".empty-state i { font-size: 3rem; margin-bottom: 16px; display: block; }" +
        ".empty-state p { font-size: 1rem; }" +

        /* ── Footer ── */
        ".footer { text-align: center; padding: 20px; font-size: .75rem; color: #94a3b8; }" +

        /* ── Print ── */
        "@media print {" +
        "  .topbar { position: static; }" +
        "  .btn-dl, .btn-print { display: none; }" +
        "  .page-wrap { padding: 12px; }" +
        "  .emp-card { break-inside: avoid; margin-bottom: 16px; }" +
        "}";
}