package com.smartoffice.controller;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.model.TeamAttendance;

@SuppressWarnings("serial")
@WebServlet("/exportTeamAttendance")
public class ExportTeamAttendanceServlet extends HttpServlet {

    // ── Colour palette (ARGB hex) ──────────────────────────────────────────
    private static final String CLR_HEADER_BG  = "FF3F51B5";
    private static final String CLR_HEADER_FG  = "FFFFFFFF";
    private static final String CLR_EMP_BG     = "FFE8EAF6";
    private static final String CLR_PRESENT_BG = "FFE8F5E9";
    private static final String CLR_PRESENT_FG = "FF1B5E20";
    private static final String CLR_ABSENT_BG  = "FFFCE4EC";
    private static final String CLR_ABSENT_FG  = "FFB71C1C";
    private static final String CLR_WEEKEND_BG = "FFECEFF1";
    private static final String CLR_WEEKEND_FG = "FF546E7A";
    private static final String CLR_LEAVE_BG   = "FFFFF9C4";
    private static final String CLR_LEAVE_FG   = "FFF57F17";
    private static final String CLR_HALFDAY_BG = "FFFFF3E0";
    private static final String CLR_HALFDAY_FG = "FFE65100";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth check ─────────────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String manager = (String) session.getAttribute("username");
        String role    = (String) session.getAttribute("role");
        AttendanceDAO dao = new AttendanceDAO();

        // ── Date range ─────────────────────────────────────────────────────
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
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date. Use YYYY-MM-DD.");
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

        // ── Optional single-employee filter ────────────────────────────────
        String employeeIdParam = request.getParameter("employeeId");
        Integer singleEmployeeId = null;
        if (employeeIdParam != null && !employeeIdParam.isBlank()) {
            try {
                singleEmployeeId = Integer.parseInt(employeeIdParam.trim());
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid employeeId parameter.");
                return;
            }
        }

        // ── Fetch data ─────────────────────────────────────────────────────
        List<TeamAttendance> list;
        try {
            if (singleEmployeeId != null) {
                list = dao.getAttendanceForEmployeeAndDateRange(
                        singleEmployeeId, startDate, endDate);
            } else if ("admin".equalsIgnoreCase(role)) {
                list = dao.getAllAttendanceForDateRange(startDate, endDate);
            } else {
                list = dao.getTeamAttendanceForDateRange(manager, startDate, endDate);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        int DAYS = (int) ChronoUnit.DAYS.between(startDate, endDate) + 1;
        String rangeLabel = startDate + " \u2014 " + endDate;

        // ── Workbook & sheet ───────────────────────────────────────────────
        XSSFWorkbook wb    = new XSSFWorkbook();
        XSSFSheet    sheet = wb.createSheet("Team Attendance");
        sheet.setDefaultColumnWidth(14);
        sheet.createFreezePane(2, 2);

        StyleFactory sf = new StyleFactory(wb);

        // ── Title row (row 0) ──────────────────────────────────────────────
        Row  titleRow  = sheet.createRow(0);
        titleRow.setHeightInPoints(28);
        Cell titleCell = titleRow.createCell(0);

        String titleText = "Attendance Report \u2014 " + rangeLabel;
        if (singleEmployeeId != null && !list.isEmpty()
                && list.get(0).getFullName() != null) {
            titleText = list.get(0).getFullName()
                    + " \u2014 Attendance Report \u2014 " + rangeLabel;
        }
        titleCell.setCellValue(titleText);
        titleCell.setCellStyle(sf.title());
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, DAYS + 1));

        // ── Header row (row 1) ─────────────────────────────────────────────
        Row header = sheet.createRow(1);
        header.setHeightInPoints(22);

        Cell hEmp = header.createCell(0);
        hEmp.setCellValue("Employee Name");
        hEmp.setCellStyle(sf.colHeader());

        Cell hLabel = header.createCell(1);
        hLabel.setCellValue("Punch In / Out");
        hLabel.setCellStyle(sf.colHeader());

        for (int i = 0; i < DAYS; i++) {
            LocalDate d    = startDate.plusDays(i);
            boolean   wknd = (d.getDayOfWeek() == DayOfWeek.SATURDAY
                    || d.getDayOfWeek() == DayOfWeek.SUNDAY);
            Cell c = header.createCell(i + 2);
            c.setCellValue(d.toString());
            c.setCellStyle(wknd ? sf.weekendHeader() : sf.colHeader());
        }

        // ── Group by employee ──────────────────────────────────────────────
        Map<String, Map<LocalDate, TeamAttendance>> map = new LinkedHashMap<>();
        for (TeamAttendance ta : list) {
            map.putIfAbsent(ta.getFullName(), new LinkedHashMap<>());
            if (ta.getAttendanceDate() != null) {
                map.get(ta.getFullName())
                   .put(ta.getAttendanceDate().toLocalDate(), ta);
            }
        }

        // ── Data rows ──────────────────────────────────────────────────────
        int     rowNum = 2;
        boolean shade  = false;

        for (String employee : map.keySet()) {
            shade = !shade;

            Row inRow  = sheet.createRow(rowNum++);
            Row outRow = sheet.createRow(rowNum++);
            inRow.setHeightInPoints(18);
            outRow.setHeightInPoints(18);

            Cell empCell = inRow.createCell(0);
            empCell.setCellValue(employee);
            empCell.setCellStyle(sf.empName(shade));

            Cell empCell2 = outRow.createCell(0);
            empCell2.setCellStyle(sf.empName(shade));

            Cell inLabel = inRow.createCell(1);
            inLabel.setCellValue("Punch In");
            inLabel.setCellStyle(sf.labelIn());

            Cell outLabel = outRow.createCell(1);
            outLabel.setCellValue("Punch Out");
            outLabel.setCellStyle(sf.labelOut());

            for (int i = 0; i < DAYS; i++) {
                LocalDate d         = startDate.plusDays(i);
                boolean   isWeekend = (d.getDayOfWeek() == DayOfWeek.SATURDAY
                        || d.getDayOfWeek() == DayOfWeek.SUNDAY);

                TeamAttendance ta = map.get(employee).get(d);

                // Future dates — leave blank
                if (d.isAfter(today)) {
                    Cell bIn  = inRow.createCell(i + 2);
                    Cell bOut = outRow.createCell(i + 2);
                    bIn.setCellValue("");
                    bOut.setCellValue("");
                    bIn.setCellStyle(sf.neutral());
                    bOut.setCellStyle(sf.neutral());
                    continue;
                }

                // Weekend (unless on leave)
                if (isWeekend && (ta == null
                        || !"On Leave".equalsIgnoreCase(ta.getStatus()))) {
                    Cell wIn  = inRow.createCell(i + 2);
                    Cell wOut = outRow.createCell(i + 2);
                    wIn.setCellValue("Weekend");
                    wOut.setCellValue("Weekend");
                    wIn.setCellStyle(sf.weekend());
                    wOut.setCellStyle(sf.weekend());
                    continue;
                }

                // No record → Absent
                if (ta == null) {
                    Cell aIn  = inRow.createCell(i + 2);
                    Cell aOut = outRow.createCell(i + 2);
                    aIn.setCellValue("Absent");
                    aOut.setCellValue("Absent");
                    aIn.setCellStyle(sf.absent());
                    aOut.setCellStyle(sf.absent());
                    continue;
                }

                String status = ta.getStatus() != null ? ta.getStatus() : "";

                if ("On Leave".equalsIgnoreCase(status)) {
                    Cell lIn  = inRow.createCell(i + 2);
                    Cell lOut = outRow.createCell(i + 2);
                    lIn.setCellValue("On Leave");
                    lOut.setCellValue("On Leave");
                    lIn.setCellStyle(sf.onLeave());
                    lOut.setCellStyle(sf.onLeave());
                    continue;
                }

                // Record exists but no punch-in → Absent
                if (ta.getPunchIn() == null) {
                    Cell aIn  = inRow.createCell(i + 2);
                    Cell aOut = outRow.createCell(i + 2);
                    aIn.setCellValue("Absent");
                    aOut.setCellValue("Absent");
                    aIn.setCellStyle(sf.absent());
                    aOut.setCellStyle(sf.absent());
                    continue;
                }

                // Present / Half Day
                boolean   halfDay   = "Half Day".equalsIgnoreCase(status);
                CellStyle timeStyle = halfDay ? sf.halfDay() : sf.presentTime();

                String inTime = ta.getPunchIn().toLocalDateTime()
                        .toLocalTime().toString().substring(0, 5);
                String outTime = ta.getPunchOut() != null
                        ? ta.getPunchOut().toLocalDateTime()
                                .toLocalTime().toString().substring(0, 5)
                        : (halfDay ? "Half Day" : "\u2014");

                Cell cIn  = inRow.createCell(i + 2);
                Cell cOut = outRow.createCell(i + 2);
                cIn.setCellValue(inTime);
                cOut.setCellValue(outTime);
                cIn.setCellStyle(timeStyle);
                cOut.setCellStyle(timeStyle);
            }
        }

        // ── Column widths ──────────────────────────────────────────────────
        sheet.setColumnWidth(0, 6000);
        sheet.setColumnWidth(1, 3200);
        for (int i = 0; i < DAYS; i++) sheet.setColumnWidth(i + 2, 2800);

        // ── Legend sheet ───────────────────────────────────────────────────
        XSSFSheet legend = wb.createSheet("Legend");
        legend.setColumnWidth(0, 4000);
        legend.setColumnWidth(1, 8000);
        String[][] items = {
            { "(blank)",  "Future date \u2014 not applicable yet" },
            { "Present",  "Employee punched in \u2265 4 hrs"     },
            { "Half Day", "Employee worked < 4 hrs"              },
            { "Absent",   "No attendance record"                 },
            { "On Leave", "Approved leave"                       },
            { "Weekend",  "Saturday or Sunday"                   },
            { "\u2014",   "Punch-out not recorded yet"           },
        };
        CellStyle[] legendStyles = {
            sf.neutral(), sf.presentTime(), sf.halfDay(),
            sf.absent(),  sf.onLeave(),     sf.weekend(), sf.presentTime()
        };
        Row lHeader = legend.createRow(0);
        lHeader.createCell(0).setCellValue("Status");
        lHeader.createCell(1).setCellValue("Meaning");
        lHeader.getCell(0).setCellStyle(sf.colHeader());
        lHeader.getCell(1).setCellStyle(sf.colHeader());
        for (int i = 0; i < items.length; i++) {
            Row lr = legend.createRow(i + 1);
            lr.setHeightInPoints(18);
            Cell lc = lr.createCell(0);
            lc.setCellValue(items[i][0]);
            lc.setCellStyle(legendStyles[i]);
            lr.createCell(1).setCellValue(items[i][1]);
        }

        // ── HTTP response ──────────────────────────────────────────────────
        response.setContentType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

        String safeName;
        if (singleEmployeeId != null && !list.isEmpty()
                && list.get(0).getFullName() != null) {
            String empName = list.get(0).getFullName()
                    .replaceAll("[^a-zA-Z0-9_\\-]", "_");
            safeName = empName + "_attendance_"
                    + startDate + "_to_" + endDate + ".xlsx";
        } else {
            safeName = "team_attendance_" + startDate + "_to_" + endDate + ".xlsx";
        }
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + safeName + "\"");

        wb.write(response.getOutputStream());
        wb.close();
    }

    // ══════════════════════════════════════════════════════════════════════
    // Inner style factory
    // ══════════════════════════════════════════════════════════════════════
    private static class StyleFactory {

        private final XSSFWorkbook wb;
        StyleFactory(XSSFWorkbook wb) { this.wb = wb; }

        private XSSFColor rgb(String argb) {
            return new XSSFColor(
                new java.awt.Color(
                    Integer.parseInt(argb.substring(2, 4), 16),
                    Integer.parseInt(argb.substring(4, 6), 16),
                    Integer.parseInt(argb.substring(6, 8), 16)
                ), null);
        }

        private XSSFCellStyle base() {
            XSSFCellStyle s = wb.createCellStyle();
            s.setAlignment(HorizontalAlignment.CENTER);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            s.setBorderBottom(BorderStyle.THIN);
            s.setBorderTop(BorderStyle.THIN);
            s.setBorderLeft(BorderStyle.THIN);
            s.setBorderRight(BorderStyle.THIN);
            XSSFColor border = rgb("FFB0BEC5");
            s.setBottomBorderColor(border);
            s.setTopBorderColor(border);
            s.setLeftBorderColor(border);
            s.setRightBorderColor(border);
            return s;
        }

        private XSSFFont font(String argb, int size, boolean bold) {
            XSSFFont f = wb.createFont();
            f.setColor(rgb(argb));
            f.setFontHeightInPoints((short) size);
            f.setBold(bold);
            f.setFontName("Calibri");
            return f;
        }

        private void fill(XSSFCellStyle s, String argb) {
            s.setFillForegroundColor(rgb(argb));
            s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }

        XSSFCellStyle title() {
            XSSFCellStyle s = wb.createCellStyle();
            fill(s, CLR_HEADER_BG);
            s.setAlignment(HorizontalAlignment.CENTER);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            s.setFont(font(CLR_HEADER_FG, 14, true));
            return s;
        }

        XSSFCellStyle colHeader() {
            XSSFCellStyle s = base();
            fill(s, CLR_HEADER_BG);
            s.setFont(font(CLR_HEADER_FG, 10, true));
            return s;
        }

        XSSFCellStyle weekendHeader() {
            XSSFCellStyle s = base();
            fill(s, "FF90A4AE");
            s.setFont(font("FFFFFFFF", 10, true));
            return s;
        }

        XSSFCellStyle empName(boolean shade) {
            XSSFCellStyle s = base();
            fill(s, shade ? CLR_EMP_BG : "FFF3F4FF");
            s.setFont(font("FF1A237E", 10, true));
            s.setAlignment(HorizontalAlignment.LEFT);
            return s;
        }

        XSSFCellStyle labelIn() {
            XSSFCellStyle s = base();
            fill(s, "FFE3F2FD");
            s.setFont(font("FF0D47A1", 9, true));
            return s;
        }

        XSSFCellStyle labelOut() {
            XSSFCellStyle s = base();
            fill(s, "FFF3E5F5");
            s.setFont(font("FF4A148C", 9, true));
            return s;
        }

        XSSFCellStyle presentTime() {
            XSSFCellStyle s = base();
            fill(s, CLR_PRESENT_BG);
            s.setFont(font(CLR_PRESENT_FG, 9, false));
            return s;
        }

        XSSFCellStyle halfDay() {
            XSSFCellStyle s = base();
            fill(s, CLR_HALFDAY_BG);
            s.setFont(font(CLR_HALFDAY_FG, 9, false));
            return s;
        }

        XSSFCellStyle absent() {
            XSSFCellStyle s = base();
            fill(s, CLR_ABSENT_BG);
            s.setFont(font(CLR_ABSENT_FG, 9, true));
            return s;
        }

        XSSFCellStyle weekend() {
            XSSFCellStyle s = base();
            fill(s, CLR_WEEKEND_BG);
            s.setFont(font(CLR_WEEKEND_FG, 9, false));
            return s;
        }

        XSSFCellStyle onLeave() {
            XSSFCellStyle s = base();
            fill(s, CLR_LEAVE_BG);
            s.setFont(font(CLR_LEAVE_FG, 9, true));
            return s;
        }

        XSSFCellStyle neutral() {
            XSSFCellStyle s = base();
            fill(s, "FFF8FAFC");
            s.setFont(font("FF94A3B8", 9, false));
            return s;
        }
    }
}