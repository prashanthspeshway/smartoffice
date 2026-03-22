package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/exportUsers")
public class ExportUsersServlet extends HttpServlet {

    private static final String CLR_HEADER_BG   = "FF3F51B5";
    private static final String CLR_HEADER_FG   = "FFFFFFFF";
    private static final String CLR_ROW_A       = "FFF8F9FF";
    private static final String CLR_ROW_B       = "FFFFFFFF";
    private static final String CLR_ACTIVE_BG   = "FFE8F5E9";
    private static final String CLR_ACTIVE_FG   = "FF1B5E20";
    private static final String CLR_INACTIVE_BG = "FFFCE4EC";
    private static final String CLR_INACTIVE_FG = "FFB71C1C";
    private static final String CLR_ADMIN_BG    = "FFE8EAF6";
    private static final String CLR_ADMIN_FG    = "FF1A237E";
    private static final String CLR_MGR_BG      = "FFFFF3E0";
    private static final String CLR_MGR_FG      = "FFE65100";
    private static final String CLR_EMP_BG      = "FFF3F4FF";
    private static final String CLR_EMP_FG      = "FF283593";
    private static final String CLR_TEXT        = "FF37474F";

    private static final String[] HEADERS = {
        "Username", "Email", "Role", "Status",
        "First Name", "Last Name", "Designation", "Joined Date", "Phone"
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect("index.html");
            return;
        }

        List<User> users = UserDao.getAllUsers();

        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet("Employees");
        sheet.createFreezePane(0, 2);

        StyleFactory sf = new StyleFactory(wb);

        // ── Title row ──────────────────────────────────────────────────────
        Row titleRow = sheet.createRow(0);
        titleRow.setHeightInPoints(30);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Employee Directory — Smart Office HRMS");
        titleCell.setCellStyle(sf.title());
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, HEADERS.length - 1));

        // ── Header row ─────────────────────────────────────────────────────
        Row header = sheet.createRow(1);
        header.setHeightInPoints(22);
        for (int i = 0; i < HEADERS.length; i++) {
            Cell c = header.createCell(i);
            c.setCellValue(HEADERS[i]);
            c.setCellStyle(sf.colHeader());
        }

        // ── Data rows ──────────────────────────────────────────────────────
        int rowNum = 2;
        for (User u : users) {
            Row row = sheet.createRow(rowNum);
            row.setHeightInPoints(18);
            boolean odd = (rowNum % 2 == 0);

            String role   = u.getRole()   != null ? u.getRole()   : "";
            String status = u.getStatus() != null ? u.getStatus() : "";

            cell(row, 0, u.getUsername(),   sf.text(odd));
            cell(row, 1, u.getEmail(),      sf.text(odd));

            Cell roleCell = row.createCell(2);
            roleCell.setCellValue(capitalize(role));
            roleCell.setCellStyle(sf.role(role, odd));

            Cell statusCell = row.createCell(3);
            statusCell.setCellValue(capitalize(status));
            statusCell.setCellStyle(sf.status(status, odd));

            cell(row, 4, u.getFirstname(),  sf.text(odd));
            cell(row, 5, u.getLastname(),   sf.text(odd));
            cell(row, 6, u.getDesignation(),sf.text(odd));
            cell(row, 7, u.getJoinedDate() != null ? u.getJoinedDate().toString() : "", sf.text(odd));
            cell(row, 8, u.getPhone(),      sf.text(odd));
            rowNum++;
        }

        // ── Summary row ────────────────────────────────────────────────────
        Row sumRow = sheet.createRow(rowNum);
        sumRow.setHeightInPoints(20);
        Cell sumCell = sumRow.createCell(0);
        sumCell.setCellValue("Total Employees: " + users.size());
        sumCell.setCellStyle(sf.summary());
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, HEADERS.length - 1));

        // ── Column widths ──────────────────────────────────────────────────
        int[] widths = { 5000, 7000, 3200, 3000, 3500, 3500, 6000, 3500, 3500 };
        for (int i = 0; i < widths.length; i++) sheet.setColumnWidth(i, widths[i]);

        // ── Summary sheet ──────────────────────────────────────────────────
        XSSFSheet stats = wb.createSheet("Summary");
        stats.setColumnWidth(0, 5000);
        stats.setColumnWidth(1, 3000);

        long admins    = users.stream().filter(u -> "admin".equalsIgnoreCase(u.getRole())).count();
        long managers  = users.stream().filter(u -> "manager".equalsIgnoreCase(u.getRole())).count();
        long employees = users.stream().filter(u -> "employee".equalsIgnoreCase(u.getRole())).count();
        long active    = users.stream().filter(u -> "active".equalsIgnoreCase(u.getStatus())).count();
        long inactive  = users.stream().filter(u -> !"active".equalsIgnoreCase(u.getStatus())).count();

        Row sTitle = stats.createRow(0);
        sTitle.setHeightInPoints(28);
        Cell sTitleCell = sTitle.createCell(0);
        sTitleCell.setCellValue("Employee Summary");
        sTitleCell.setCellStyle(sf.title());
        stats.addMergedRegion(new CellRangeAddress(0, 0, 0, 1));

        String[][] summaryData = {
            { "Total Employees", String.valueOf(users.size()) },
            { "Admins",          String.valueOf(admins)       },
            { "Managers",        String.valueOf(managers)     },
            { "Employees",       String.valueOf(employees)    },
            { "Active",          String.valueOf(active)       },
            { "Inactive",        String.valueOf(inactive)     },
        };
        for (int i = 0; i < summaryData.length; i++) {
            Row sr = stats.createRow(i + 1);
            sr.setHeightInPoints(18);
            Cell lbl = sr.createCell(0);
            lbl.setCellValue(summaryData[i][0]);
            lbl.setCellStyle(sf.colHeader());
            Cell val = sr.createCell(1);
            val.setCellValue(summaryData[i][1]);
            val.setCellStyle(sf.text(i % 2 == 0));
        }

        // ── Response ───────────────────────────────────────────────────────
        resp.setContentType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=employees.xlsx");
        wb.write(resp.getOutputStream());
        wb.close();
    }

    private void cell(Row row, int col, String val, CellStyle style) {
        Cell c = row.createCell(col);
        c.setCellValue(val != null ? val : "");
        c.setCellStyle(style);
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty()) return "";
        return Character.toUpperCase(s.charAt(0)) + s.substring(1).toLowerCase();
    }

    // ══════════════════════════════════════════════════════════════════════
    private static class StyleFactory {

        private final XSSFWorkbook wb;
        StyleFactory(XSSFWorkbook wb) { this.wb = wb; }

        private XSSFColor rgb(String argb) {
            return new XSSFColor(new java.awt.Color(
                Integer.parseInt(argb.substring(2, 4), 16),
                Integer.parseInt(argb.substring(4, 6), 16),
                Integer.parseInt(argb.substring(6, 8), 16)), null);
        }

        private XSSFCellStyle base() {
            XSSFCellStyle s = wb.createCellStyle();
            s.setAlignment(HorizontalAlignment.LEFT);
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
            s.setAlignment(HorizontalAlignment.CENTER);
            return s;
        }

        XSSFCellStyle text(boolean odd) {
            XSSFCellStyle s = base();
            fill(s, odd ? CLR_ROW_A : CLR_ROW_B);
            s.setFont(font(CLR_TEXT, 10, false));
            return s;
        }

        XSSFCellStyle role(String role, boolean odd) {
            XSSFCellStyle s = base();
            s.setAlignment(HorizontalAlignment.CENTER);
            if ("admin".equalsIgnoreCase(role)) {
                fill(s, CLR_ADMIN_BG);
                s.setFont(font(CLR_ADMIN_FG, 10, true));
            } else if ("manager".equalsIgnoreCase(role)) {
                fill(s, CLR_MGR_BG);
                s.setFont(font(CLR_MGR_FG, 10, true));
            } else {
                fill(s, CLR_EMP_BG);
                s.setFont(font(CLR_EMP_FG, 10, false));
            }
            return s;
        }

        XSSFCellStyle status(String status, boolean odd) {
            XSSFCellStyle s = base();
            s.setAlignment(HorizontalAlignment.CENTER);
            if ("active".equalsIgnoreCase(status)) {
                fill(s, CLR_ACTIVE_BG);
                s.setFont(font(CLR_ACTIVE_FG, 10, true));
            } else {
                fill(s, CLR_INACTIVE_BG);
                s.setFont(font(CLR_INACTIVE_FG, 10, true));
            }
            return s;
        }

        XSSFCellStyle summary() {
            XSSFCellStyle s = base();
            fill(s, "FFE8EAF6");
            s.setAlignment(HorizontalAlignment.CENTER);
            s.setFont(font("FF1A237E", 11, true));
            return s;
        }
    }
}