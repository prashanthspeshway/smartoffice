package com.smartoffice.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.TeamDAO;
import com.smartoffice.model.Task;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/exportTeamTasks")
public class ExportTeamTasksServlet extends HttpServlet {

    // ── Colour palette — identical to ExportTeamAttendanceServlet ──
    private static final String CLR_HEADER_BG   = "FF3F51B5";
    private static final String CLR_HEADER_FG   = "FFFFFFFF";
    private static final String CLR_EMP_BG      = "FFE8EAF6";
    private static final String CLR_EMP_FG      = "FF1A237E";
    private static final String CLR_DONE_BG     = "FFE8F5E9";
    private static final String CLR_DONE_FG     = "FF1B5E20";
    private static final String CLR_OPEN_BG     = "FFFFF9C4";
    private static final String CLR_OPEN_FG     = "FFF57F17";
    private static final String CLR_OVERDUE_BG  = "FFFCE4EC";
    private static final String CLR_OVERDUE_FG  = "FFB71C1C";
    private static final String CLR_REVIEW_BG   = "FFEDE7F6";
    private static final String CLR_REVIEW_FG   = "FF4A148C";
    private static final String CLR_HIGH_BG     = "FFFCE4EC";
    private static final String CLR_HIGH_FG     = "FFB71C1C";
    private static final String CLR_MEDIUM_BG   = "FFFFF9C4";
    private static final String CLR_MEDIUM_FG   = "FFF57F17";
    private static final String CLR_LOW_BG      = "FFE8F5E9";
    private static final String CLR_LOW_FG      = "FF1B5E20";
    private static final String CLR_NEUTRAL_BG  = "FFF8FAFC";
    private static final String CLR_NEUTRAL_FG  = "FF94A3B8";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String manager = (String) session.getAttribute("username");

        // Optional: filter by specific teamId
        String teamIdParam = request.getParameter("teamId");

        List<Team> teams;
        try {
            teams = TeamDAO.getTeamsByManager(manager);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        if (teams == null || teams.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NO_CONTENT, "No teams found.");
            return;
        }

        // Filter to specific team if requested
        if (teamIdParam != null && !teamIdParam.isBlank()) {
            try {
                int teamId = Integer.parseInt(teamIdParam.trim());
                teams = teams.stream()
                    .filter(t -> t.getId() == teamId)
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException ignored) {}
        }

        LocalDate today = LocalDate.now();
        XSSFWorkbook wb = new XSSFWorkbook();
        StyleFactory sf = new StyleFactory(wb);

        for (Team team : teams) {
            String sheetName = sanitizeSheetName(team.getName());
            XSSFSheet sheet  = wb.createSheet(sheetName);
            sheet.createFreezePane(0, 2);
            sheet.setDefaultColumnWidth(18);

            // ── Row 0: Title ──
            Row titleRow = sheet.createRow(0);
            titleRow.setHeightInPoints(28);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Task Report — " + team.getName()
                + "   |   Manager: " + (team.getManagerFullname() != null
                    ? team.getManagerFullname() : manager)
                + "   |   Generated: " + today);
            titleCell.setCellStyle(sf.title());
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 13));

            // ── Row 1: Column headers ──
            String[] headers = {
                "#", "Employee", "Email", "Designation",
                "Task Title", "Description", "Status", "Priority",
                "Deadline", "Assigned Date",
                "Total", "Completed", "Open", "Overdue", "Completion %"
            };
            Row headerRow = sheet.createRow(1);
            headerRow.setHeightInPoints(22);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(sf.colHeader());
            }

            // ── Data rows ──
            int rowNum = 2;
            int empIndex = 1;
            boolean shade = false;

            for (User member : team.getMembers()) {
                shade = !shade;
                String email = member.getEmail();
                String fullName = buildFullName(member);
                String desig    = member.getDesignation() != null ? member.getDesignation() : "—";

                List<Task> tasks;
                try {
                    tasks = TaskDAO.getTasksForEmployee(email);
                } catch (Exception e) {
                    tasks = java.util.Collections.emptyList();
                }

                // Compute stats
                int total = tasks.size(), completed = 0, open = 0, overdue = 0;
                for (Task t : tasks) {
                    String st = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "";
                    if ("COMPLETED".equals(st))          completed++;
                    else                                  open++;
                    if (!"COMPLETED".equals(st) && t.getDeadline() != null
                            && t.getDeadline().before(new java.util.Date())) overdue++;
                }
                int compPct = total > 0 ? (completed * 100 / total) : 0;

                if (tasks.isEmpty()) {
                    // One summary row for employees with no tasks
                    Row row = sheet.createRow(rowNum++);
                    row.setHeightInPoints(20);
                    setCellStyled(row, 0,  String.valueOf(empIndex++), sf.empIndex(shade));
                    setCellStyled(row, 1,  fullName,                   sf.empName(shade));
                    setCellStyled(row, 2,  email,                      sf.empMono(shade));
                    setCellStyled(row, 3,  desig,                      sf.neutral());
                    setCellStyled(row, 4,  "No tasks assigned",        sf.neutral());
                    setCellStyled(row, 5,  "",                         sf.neutral());
                    setCellStyled(row, 6,  "",                         sf.neutral());
                    setCellStyled(row, 7,  "",                         sf.neutral());
                    setCellStyled(row, 8,  "",                         sf.neutral());
                    setCellStyled(row, 9,  "",                         sf.neutral());
                    setCellNum   (row, 10, 0,      sf.numDefault());
                    setCellNum   (row, 11, 0,      sf.numGreen());
                    setCellNum   (row, 12, 0,      sf.numAmber());
                    setCellNum   (row, 13, 0,      sf.numNeutral());
                    setCellStyled(row, 14, "0%",   sf.neutral());
                } else {
                    for (int ti = 0; ti < tasks.size(); ti++) {
                        Task t   = tasks.get(ti);
                        boolean first = (ti == 0);

                        String status   = t.getStatus()   != null ? t.getStatus().trim().toUpperCase()   : "ASSIGNED";
                        String priority = t.getPriority() != null ? t.getPriority().trim().toUpperCase() : "MEDIUM";
                        String deadline = t.getDeadline() != null ? t.getDeadline().toString()           : "—";
                        String assigned = t.getAssignedDate() != null
                            ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(t.getAssignedDate()) : "—";
                        String title    = t.getTitle()       != null ? t.getTitle()       : "Untitled";
                        String desc     = t.getDescription() != null ? t.getDescription() : "";

                        boolean isDone    = "COMPLETED".equals(status);
                        boolean isReview  = "SUBMITTED".equals(status) || "PROCESSING".equals(status);
                        boolean isOverdue = !isDone
                            && t.getDeadline() != null
                            && t.getDeadline().before(new java.util.Date());

                        Row row = sheet.createRow(rowNum++);
                        row.setHeightInPoints(20);

                        // Employee info only on first task row
                        setCellStyled(row, 0, first ? String.valueOf(empIndex) : "", sf.empIndex(shade));
                        setCellStyled(row, 1, first ? fullName : "",                 sf.empName(shade));
                        setCellStyled(row, 2, first ? email    : "",                 sf.empMono(shade));
                        setCellStyled(row, 3, first ? desig    : "",                 sf.neutral());

                        // Task columns — coloured by status
                        CellStyle statusStyle   = isDone   ? sf.done()
                                                : isReview ? sf.review()
                                                : isOverdue? sf.overdue()
                                                : sf.openTask();
                        CellStyle priorityStyle = "HIGH".equals(priority) ? sf.prioHigh()
                                                : "LOW".equals(priority)  ? sf.prioLow()
                                                : sf.prioMedium();

                        setCellStyled(row, 4, title,    sf.taskTitle());
                        setCellStyled(row, 5, desc,     sf.taskDesc());
                        setCellStyled(row, 6, status,   statusStyle);
                        setCellStyled(row, 7, priority, priorityStyle);
                        setCellStyled(row, 8, deadline, isOverdue ? sf.overdue() : sf.neutral());
                        setCellStyled(row, 9, assigned, sf.neutral());

                        // Stats only on first task row
                        if (first) {
                            setCellNum(row, 10, total,     sf.numDefault());
                            setCellNum(row, 11, completed, sf.numGreen());
                            setCellNum(row, 12, open,      sf.numAmber());
                            setCellNum(row, 13, overdue,   overdue > 0 ? sf.numRose() : sf.numNeutral());
                            setCellStyled(row, 14, compPct + "%", compPct == 100 ? sf.done() : sf.neutral());
                        } else {
                            for (int col = 10; col <= 14; col++) {
                                Cell c = row.createCell(col);
                                c.setCellStyle(sf.neutral());
                            }
                        }

                        if (first) empIndex++;
                    }
                }

                // Separator row between employees
                Row sep = sheet.createRow(rowNum++);
                sep.setHeightInPoints(4);
                for (int col = 0; col <= 14; col++) {
                    Cell c = sep.createCell(col);
                    c.setCellStyle(sf.separator());
                }
            }

            // Column widths
            sheet.setColumnWidth(0,  1800);  // #
            sheet.setColumnWidth(1,  5500);  // Name
            sheet.setColumnWidth(2,  6500);  // Email
            sheet.setColumnWidth(3,  4000);  // Designation
            sheet.setColumnWidth(4,  7000);  // Task Title
            sheet.setColumnWidth(5,  9000);  // Description
            sheet.setColumnWidth(6,  3800);  // Status
            sheet.setColumnWidth(7,  3000);  // Priority
            sheet.setColumnWidth(8,  3200);  // Deadline
            sheet.setColumnWidth(9,  3200);  // Assigned
            sheet.setColumnWidth(10, 2200);  // Total
            sheet.setColumnWidth(11, 2600);  // Completed
            sheet.setColumnWidth(12, 2200);  // Open
            sheet.setColumnWidth(13, 2400);  // Overdue
            sheet.setColumnWidth(14, 2800);  // Completion%
        }

        // ── Legend sheet ──
        XSSFSheet legend = wb.createSheet("Legend");
        legend.setColumnWidth(0, 5000);
        legend.setColumnWidth(1, 10000);
        Row lhdr = legend.createRow(0);
        lhdr.createCell(0).setCellValue("Colour / Status");
        lhdr.createCell(1).setCellValue("Meaning");
        lhdr.getCell(0).setCellStyle(sf.colHeader());
        lhdr.getCell(1).setCellStyle(sf.colHeader());

        String[][] legendItems = {
            { "COMPLETED",  "Task finished successfully" },
            { "SUBMITTED / PROCESSING", "Submitted by employee — awaiting manager review" },
            { "ASSIGNED (overdue)",     "Past deadline, not yet completed" },
            { "ASSIGNED (on-track)",    "Active task within deadline" },
            { "HIGH priority",          "Urgent — needs immediate attention" },
            { "MEDIUM priority",        "Normal priority" },
            { "LOW priority",           "Low urgency" },
        };
        CellStyle[] legendStyles = {
            sf.done(), sf.review(), sf.overdue(), sf.openTask(),
            sf.prioHigh(), sf.prioMedium(), sf.prioLow()
        };
        for (int i = 0; i < legendItems.length; i++) {
            Row lr = legend.createRow(i + 1);
            lr.setHeightInPoints(18);
            Cell lc = lr.createCell(0);
            lc.setCellValue(legendItems[i][0]);
            lc.setCellStyle(legendStyles[i]);
            lr.createCell(1).setCellValue(legendItems[i][1]);
        }

        // ── Response ──
        String teamLabel = teams.size() == 1
            ? teams.get(0).getName().replaceAll("[^a-zA-Z0-9_\\-]", "_")
            : "all_teams";
        String fileName = teamLabel + "_tasks_" + today + ".xlsx";

        response.setContentType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + fileName + "\"");
        wb.write(response.getOutputStream());
        wb.close();
    }

    // ── Helpers ──
    private static String buildFullName(User m) {
        String fn = "";
        if (m.getFirstname() != null) fn += m.getFirstname().trim();
        if (m.getLastname()  != null) fn += (fn.isEmpty() ? "" : " ") + m.getLastname().trim();
        return fn.isEmpty() ? (m.getEmail() != null ? m.getEmail() : "—") : fn;
    }

    private static String sanitizeSheetName(String name) {
        if (name == null || name.isBlank()) return "Sheet";
        return name.replaceAll("[/\\\\?*\\[\\]:]", "_")
                   .substring(0, Math.min(name.length(), 31));
    }

    private static void setCellStyled(Row row, int col, String val, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(val != null ? val : "");
        c.setCellStyle(style);
    }

    private static void setCellNum(Row row, int col, int val, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(val);
        c.setCellStyle(style);
    }

    // ── Style Factory — mirrors ExportTeamAttendanceServlet.StyleFactory ──
    private static class StyleFactory {
        private final XSSFWorkbook wb;
        StyleFactory(XSSFWorkbook wb) { this.wb = wb; }

        private XSSFColor rgb(String argb) {
            return new XSSFColor(
                new java.awt.Color(
                    Integer.parseInt(argb.substring(2,4), 16),
                    Integer.parseInt(argb.substring(4,6), 16),
                    Integer.parseInt(argb.substring(6,8), 16)),
                null);
        }

        private XSSFCellStyle base() {
            XSSFCellStyle s = wb.createCellStyle();
            s.setAlignment(HorizontalAlignment.CENTER);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            s.setBorderBottom(BorderStyle.THIN); s.setBorderTop(BorderStyle.THIN);
            s.setBorderLeft(BorderStyle.THIN);   s.setBorderRight(BorderStyle.THIN);
            XSSFColor border = rgb("FFB0BEC5");
            s.setBottomBorderColor(border); s.setTopBorderColor(border);
            s.setLeftBorderColor(border);   s.setRightBorderColor(border);
            return s;
        }

        private XSSFFont font(String argb, int size, boolean bold) {
            XSSFFont f = wb.createFont();
            f.setColor(rgb(argb)); f.setFontHeightInPoints((short) size);
            f.setBold(bold); f.setFontName("Calibri");
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
            s.setFont(font(CLR_HEADER_FG, 13, true));
            return s;
        }

        XSSFCellStyle colHeader() {
            XSSFCellStyle s = base();
            fill(s, CLR_HEADER_BG);
            s.setFont(font(CLR_HEADER_FG, 10, true));
            return s;
        }

        XSSFCellStyle empIndex(boolean shade) {
            XSSFCellStyle s = base();
            fill(s, shade ? CLR_EMP_BG : "FFF3F4FF");
            s.setFont(font(CLR_NEUTRAL_FG, 9, false));
            return s;
        }

        XSSFCellStyle empName(boolean shade) {
            XSSFCellStyle s = base();
            fill(s, shade ? CLR_EMP_BG : "FFF3F4FF");
            s.setFont(font(CLR_EMP_FG, 10, true));
            s.setAlignment(HorizontalAlignment.LEFT);
            return s;
        }

        XSSFCellStyle empMono(boolean shade) {
            XSSFCellStyle s = base();
            fill(s, shade ? CLR_EMP_BG : "FFF3F4FF");
            s.setFont(font("FF5A6278", 9, false));
            s.setAlignment(HorizontalAlignment.LEFT);
            return s;
        }

        XSSFCellStyle taskTitle() {
            XSSFCellStyle s = base();
            fill(s, "FFF8FAFF");
            s.setFont(font("FF1A1D2E", 9, true));
            s.setAlignment(HorizontalAlignment.LEFT);
            return s;
        }

        XSSFCellStyle taskDesc() {
            XSSFCellStyle s = base();
            fill(s, CLR_NEUTRAL_BG);
            s.setFont(font("FF5A6278", 9, false));
            s.setAlignment(HorizontalAlignment.LEFT);
            s.setWrapText(false);
            return s;
        }

        XSSFCellStyle done() {
            XSSFCellStyle s = base();
            fill(s, CLR_DONE_BG);
            s.setFont(font(CLR_DONE_FG, 9, true));
            return s;
        }

        XSSFCellStyle openTask() {
            XSSFCellStyle s = base();
            fill(s, CLR_OPEN_BG);
            s.setFont(font(CLR_OPEN_FG, 9, false));
            return s;
        }

        XSSFCellStyle overdue() {
            XSSFCellStyle s = base();
            fill(s, CLR_OVERDUE_BG);
            s.setFont(font(CLR_OVERDUE_FG, 9, true));
            return s;
        }

        XSSFCellStyle review() {
            XSSFCellStyle s = base();
            fill(s, CLR_REVIEW_BG);
            s.setFont(font(CLR_REVIEW_FG, 9, true));
            return s;
        }

        XSSFCellStyle prioHigh() {
            XSSFCellStyle s = base();
            fill(s, CLR_HIGH_BG);
            s.setFont(font(CLR_HIGH_FG, 9, true));
            return s;
        }

        XSSFCellStyle prioMedium() {
            XSSFCellStyle s = base();
            fill(s, CLR_MEDIUM_BG);
            s.setFont(font(CLR_MEDIUM_FG, 9, false));
            return s;
        }

        XSSFCellStyle prioLow() {
            XSSFCellStyle s = base();
            fill(s, CLR_LOW_BG);
            s.setFont(font(CLR_LOW_FG, 9, false));
            return s;
        }

        XSSFCellStyle numDefault() {
            XSSFCellStyle s = base();
            fill(s, CLR_EMP_BG);
            s.setFont(font(CLR_EMP_FG, 10, true));
            return s;
        }

        XSSFCellStyle numGreen() {
            XSSFCellStyle s = base();
            fill(s, CLR_DONE_BG);
            s.setFont(font(CLR_DONE_FG, 10, true));
            return s;
        }

        XSSFCellStyle numAmber() {
            XSSFCellStyle s = base();
            fill(s, CLR_OPEN_BG);
            s.setFont(font(CLR_OPEN_FG, 10, true));
            return s;
        }

        XSSFCellStyle numRose() {
            XSSFCellStyle s = base();
            fill(s, CLR_OVERDUE_BG);
            s.setFont(font(CLR_OVERDUE_FG, 10, true));
            return s;
        }

        XSSFCellStyle numNeutral() {
            XSSFCellStyle s = base();
            fill(s, CLR_NEUTRAL_BG);
            s.setFont(font(CLR_NEUTRAL_FG, 10, false));
            return s;
        }

        XSSFCellStyle neutral() {
            XSSFCellStyle s = base();
            fill(s, CLR_NEUTRAL_BG);
            s.setFont(font(CLR_NEUTRAL_FG, 9, false));
            return s;
        }

        XSSFCellStyle separator() {
            XSSFCellStyle s = wb.createCellStyle();
            fill(s, "FFE8EAF6");
            s.setBorderBottom(BorderStyle.NONE); s.setBorderTop(BorderStyle.NONE);
            s.setBorderLeft(BorderStyle.NONE);   s.setBorderRight(BorderStyle.NONE);
            return s;
        }
    }
}