package com.smartoffice.controller;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
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
    private static final String CLR_HEADER_BG   = "FF3F51B5"; // deep indigo
    private static final String CLR_HEADER_FG   = "FFFFFFFF"; // white
    private static final String CLR_EMP_BG      = "FFE8EAF6"; // soft indigo tint
    private static final String CLR_PRESENT_BG  = "FFE8F5E9"; // light green
    private static final String CLR_PRESENT_FG  = "FF1B5E20";
    private static final String CLR_ABSENT_BG   = "FFFCE4EC"; // light red
    private static final String CLR_ABSENT_FG   = "FFB71C1C";
    private static final String CLR_WEEKEND_BG  = "FFECEFF1"; // light grey
    private static final String CLR_WEEKEND_FG  = "FF546E7A";
    private static final String CLR_LEAVE_BG    = "FFFFF9C4"; // light yellow
    private static final String CLR_LEAVE_FG    = "FFF57F17";
    private static final String CLR_HALFDAY_BG  = "FFFFF3E0"; // light orange
    private static final String CLR_HALFDAY_FG  = "FFE65100";
    private static final String CLR_TIME_FG     = "FF1A237E"; // dark indigo for times

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String manager = (String) session.getAttribute("username");
        String role    = (String) session.getAttribute("role");
        AttendanceDAO dao = new AttendanceDAO();

        List<TeamAttendance> list;
        try {
            // Admin sees all employees; manager sees their team
            if ("admin".equalsIgnoreCase(role)) {
                list = dao.getAllAttendanceForMonth();
            } else {
                list = dao.getTeamAttendanceForMonth(manager);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        // ── Month config ───────────────────────────────────────────────────
        LocalDate startDate = LocalDate.now().withDayOfMonth(1);
        int DAYS = startDate.lengthOfMonth();
        String monthLabel = startDate.getMonth().getDisplayName(
            java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH)
            + " " + startDate.getYear();

        // ── Workbook & sheet ───────────────────────────────────────────────
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet  = wb.createSheet("Team Attendance");
        sheet.setDefaultColumnWidth(14);
        sheet.createFreezePane(2, 2); // freeze employee + label columns, header row

        // ── Style factory ──────────────────────────────────────────────────
        StyleFactory sf = new StyleFactory(wb);

        // ── Title row (row 0) ──────────────────────────────────────────────
        Row titleRow = sheet.createRow(0);
        titleRow.setHeightInPoints(28);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Attendance Report — " + monthLabel);
        titleCell.setCellStyle(sf.title());
        // Merge across all columns: employee + label + days
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
            LocalDate d = startDate.plusDays(i);
            Cell c = header.createCell(i + 2);
            c.setCellValue(d.toString());
            // Weekend dates get a slightly different header shade
            boolean wknd = (d.getDayOfWeek() == DayOfWeek.SATURDAY || d.getDayOfWeek() == DayOfWeek.SUNDAY);
            c.setCellStyle(wknd ? sf.weekendHeader() : sf.colHeader());
        }

        // ── Group by employee ──────────────────────────────────────────────
        // Map: fullName → (date → TeamAttendance)
        Map<String, Map<LocalDate, TeamAttendance>> map = new LinkedHashMap<>();
        for (TeamAttendance ta : list) {
            map.putIfAbsent(ta.getFullName(), new LinkedHashMap<>());
            if (ta.getAttendanceDate() != null) {
                map.get(ta.getFullName()).put(ta.getAttendanceDate().toLocalDate(), ta);
            }
        }

        // ── Data rows ──────────────────────────────────────────────────────
        int rowNum = 2;
        boolean shade = false; // alternating employee band

        for (String employee : map.keySet()) {
            shade = !shade;

            Row inRow  = sheet.createRow(rowNum++);
            Row outRow = sheet.createRow(rowNum++);
            inRow.setHeightInPoints(18);
            outRow.setHeightInPoints(18);

            // Employee name cell — spans two rows via content (no merge needed)
            Cell empCell = inRow.createCell(0);
            empCell.setCellValue(employee);
            empCell.setCellStyle(sf.empName(shade));

            // Blank below employee name
            Cell empCell2 = outRow.createCell(0);
            empCell2.setCellStyle(sf.empName(shade));

            // Label cells
            Cell inLabel = inRow.createCell(1);
            inLabel.setCellValue("Punch In");
            inLabel.setCellStyle(sf.labelIn());

            Cell outLabel = outRow.createCell(1);
            outLabel.setCellValue("Punch Out");
            outLabel.setCellStyle(sf.labelOut());

            // Fill each day
            for (int i = 0; i < DAYS; i++) {
                LocalDate d = startDate.plusDays(i);
                boolean isWeekend = (d.getDayOfWeek() == DayOfWeek.SATURDAY
                        || d.getDayOfWeek() == DayOfWeek.SUNDAY);

                TeamAttendance ta = map.get(employee).get(d);

                if (isWeekend && (ta == null || !"On Leave".equalsIgnoreCase(
                        ta.getStatus()))) {
                    // Weekend — no data expected
                    Cell wIn  = inRow.createCell(i + 2);
                    Cell wOut = outRow.createCell(i + 2);
                    wIn.setCellValue("Weekend");
                    wOut.setCellValue("Weekend");
                    wIn.setCellStyle(sf.weekend());
                    wOut.setCellStyle(sf.weekend());
                    continue;
                }

                if (ta == null) {
                    // Absent — no record
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

                if (ta.getPunchIn() == null) {
                    // Has a record but no punch — treat as Absent
                    Cell aIn  = inRow.createCell(i + 2);
                    Cell aOut = outRow.createCell(i + 2);
                    aIn.setCellValue("Absent");
                    aOut.setCellValue("Absent");
                    aIn.setCellStyle(sf.absent());
                    aOut.setCellStyle(sf.absent());
                    continue;
                }

                // Present or Half Day
                boolean halfDay = "Half Day".equalsIgnoreCase(status);
                CellStyle presentInStyle  = halfDay ? sf.halfDay() : sf.presentTime();
                CellStyle presentOutStyle = halfDay ? sf.halfDay() : sf.presentTime();

                String inTime  = ta.getPunchIn()  != null
                        ? ta.getPunchIn().toLocalDateTime().toLocalTime()
                                .toString().substring(0, 5) : "";
                String outTime = ta.getPunchOut() != null
                        ? ta.getPunchOut().toLocalDateTime().toLocalTime()
                                .toString().substring(0, 5) : "—";

                Cell cIn  = inRow.createCell(i + 2);
                Cell cOut = outRow.createCell(i + 2);
                cIn.setCellValue(inTime);
                cOut.setCellValue(ta.getPunchOut() != null ? outTime : (halfDay ? "Half Day" : "—"));
                cIn.setCellStyle(presentInStyle);
                cOut.setCellStyle(presentOutStyle);
            }
        }

        // ── Column widths ──────────────────────────────────────────────────
        sheet.setColumnWidth(0, 6000); // Employee name
        sheet.setColumnWidth(1, 3200); // Label
        for (int i = 0; i < DAYS; i++) {
            sheet.setColumnWidth(i + 2, 2800);
        }

        // ── Legend sheet ───────────────────────────────────────────────────
        XSSFSheet legend = wb.createSheet("Legend");
        legend.setColumnWidth(0, 4000);
        legend.setColumnWidth(1, 8000);
        String[][] items = {
            { "Present",  "Employee punched in ≥ 4 hrs" },
            { "Half Day", "Employee worked < 4 hrs"     },
            { "Absent",   "No attendance record"        },
            { "On Leave", "Approved leave"              },
            { "Weekend",  "Saturday or Sunday"          },
            { "—",        "Punch-out not recorded yet"  },
        };
        CellStyle[] legendStyles = {
            sf.presentTime(), sf.halfDay(), sf.absent(), sf.onLeave(), sf.weekend(), sf.presentTime()
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
            Cell lm = lr.createCell(1);
            lm.setCellValue(items[i][1]);
        }

        // ── Response ───────────────────────────────────────────────────────
        response.setContentType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=team_attendance_month.xlsx");
        wb.write(response.getOutputStream());
        wb.close();
    }

    // ══════════════════════════════════════════════════════════════════════
    // Inner style factory — keeps all POI style creation in one place
    // ══════════════════════════════════════════════════════════════════════
    private static class StyleFactory {

        private final XSSFWorkbook wb;

        StyleFactory(XSSFWorkbook wb) { this.wb = wb; }

        // ── Helpers ───────────────────────────────────────────────────────
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

        // ── Public styles ─────────────────────────────────────────────────

        XSSFCellStyle title() {
            XSSFCellStyle s = wb.createCellStyle();
            fill(s, CLR_HEADER_BG);
            s.setAlignment(HorizontalAlignment.CENTER);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            XSSFFont f = font(CLR_HEADER_FG, 14, true);
            s.setFont(f);
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
            fill(s, "FF90A4AE"); // steel blue-grey
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
    }
}