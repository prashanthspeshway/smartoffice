package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
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

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/exportTeamPerformance")
public class ExportTeamPerformanceServlet extends HttpServlet {

	private static final String CLR_HEADER_BG = "FF3F51B5"; // deep indigo
	private static final String CLR_HEADER_FG = "FFFFFFFF";
	private static final String CLR_ROW_A = "FFF8F9FF";
	private static final String CLR_ROW_B = "FFFFFFFF";
	private static final String CLR_TEXT = "FF37474F";

	private static final String CLR_EXCELLENCE_BG = "FFE8F5E9"; // green
	private static final String CLR_EXCELLENCE_FG = "FF1B5E20";
	private static final String CLR_GOOD_BG = "FFE3F2FD"; // blue
	private static final String CLR_GOOD_FG = "FF0D47A1";
	private static final String CLR_AVERAGE_BG = "FFFFF3E0"; // orange
	private static final String CLR_AVERAGE_FG = "FFE65100";
	private static final String CLR_POOR_BG = "FFFCE4EC"; // red
	private static final String CLR_POOR_FG = "FFB71C1C";
	private static final String CLR_DEFAULT_BG = "FFF3F4FF"; // lavender
	private static final String CLR_DEFAULT_FG = "FF283593";

	private static class PerfRow {
		String employee, manager, rating, month, createdAt;
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			resp.sendRedirect("index.html");
			return;
		}

		String managerUsername = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");

		List<PerfRow> rows = new ArrayList<>();
		String sql = "admin".equalsIgnoreCase(role)
				? "SELECT employee_username, manager_username, rating, performance_month, created_at "
						+ "FROM employee_performance ORDER BY performance_month DESC, employee_username ASC"
				: "SELECT ep.employee_username, ep.manager_username, ep.rating, "
						+ "       ep.performance_month, ep.created_at " + "FROM employee_performance ep "
						+ "JOIN users u ON TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) = ep.manager_username "
						+ "WHERE u.email = ? " + "ORDER BY ep.performance_month DESC, ep.employee_username ASC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			if (!"admin".equalsIgnoreCase(role))
				ps.setString(1, managerUsername);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				PerfRow r = new PerfRow();
				r.employee = rs.getString("employee_username");
				r.manager = rs.getString("manager_username");
				r.rating = rs.getString("rating");
				r.month = rs.getDate("performance_month") != null ? rs.getDate("performance_month").toString() : "";
				r.createdAt = rs.getTimestamp("created_at") != null
						? rs.getTimestamp("created_at").toString().substring(0, 10)
						: "";
				rows.add(r);
			}
		} catch (Exception e) {
			throw new ServletException(e);
		}

		XSSFWorkbook wb = new XSSFWorkbook();
		XSSFSheet sheet = wb.createSheet("Performance");
		sheet.createFreezePane(0, 2);

		StyleFactory sf = new StyleFactory(wb);

		Row titleRow = sheet.createRow(0);
		titleRow.setHeightInPoints(30);
		Cell titleCell = titleRow.createCell(0);
		titleCell.setCellValue("Team Performance Report — Smart Office HRMS");
		titleCell.setCellStyle(sf.title());
		sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 4));

		String[] headers = { "Employee", "Manager", "Rating", "Performance Month", "Recorded On" };
		Row header = sheet.createRow(1);
		header.setHeightInPoints(22);
		for (int i = 0; i < headers.length; i++) {
			Cell c = header.createCell(i);
			c.setCellValue(headers[i]);
			c.setCellStyle(sf.colHeader());
		}

		int rowNum = 2;
		for (PerfRow r : rows) {
			Row row = sheet.createRow(rowNum);
			row.setHeightInPoints(20);
			boolean odd = (rowNum % 2 == 0);

			cell(row, 0, r.employee, sf.text(odd));
			cell(row, 1, r.manager, sf.text(odd));

			Cell ratingCell = row.createCell(2);
			ratingCell.setCellValue(r.rating != null ? r.rating : "");
			ratingCell.setCellStyle(sf.rating(r.rating));

			cell(row, 3, r.month, sf.text(odd));
			cell(row, 4, r.createdAt, sf.text(odd));

			rowNum++;
		}

		Row sumRow = sheet.createRow(rowNum);
		sumRow.setHeightInPoints(20);
		Cell sumCell = sumRow.createCell(0);
		sumCell.setCellValue("Total Records: " + rows.size());
		sumCell.setCellStyle(sf.summary());
		sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, 4));

		sheet.setColumnWidth(0, 6500); // Employee
		sheet.setColumnWidth(1, 6500); // Manager
		sheet.setColumnWidth(2, 4000); // Rating
		sheet.setColumnWidth(3, 4500); // Month
		sheet.setColumnWidth(4, 4000); // Recorded On

		XSSFSheet summary = wb.createSheet("Rating Summary");
		summary.setColumnWidth(0, 5000);
		summary.setColumnWidth(1, 3000);
		summary.setColumnWidth(2, 4000);

		Row smTitle = summary.createRow(0);
		smTitle.setHeightInPoints(28);
		Cell smTitleCell = smTitle.createCell(0);
		smTitleCell.setCellValue("Rating Breakdown");
		smTitleCell.setCellStyle(sf.title());
		summary.addMergedRegion(new CellRangeAddress(0, 0, 0, 2));

		Row smHeader = summary.createRow(1);
		smHeader.setHeightInPoints(20);
		String[] smHeaders = { "Rating", "Count", "Employees" };
		for (int i = 0; i < smHeaders.length; i++) {
			Cell c = smHeader.createCell(i);
			c.setCellValue(smHeaders[i]);
			c.setCellStyle(sf.colHeader());
		}

		Map<String, List<String>> ratingMap = new LinkedHashMap<>();
		for (PerfRow r : rows) {
			String key = r.rating != null ? r.rating.toUpperCase() : "UNKNOWN";
			ratingMap.computeIfAbsent(key, k -> new ArrayList<>()).add(r.employee);
		}

		int smRow = 2;
		for (Map.Entry<String, List<String>> entry : ratingMap.entrySet()) {
			Row sr = summary.createRow(smRow++);
			sr.setHeightInPoints(18);

			Cell rCell = sr.createCell(0);
			rCell.setCellValue(entry.getKey());
			rCell.setCellStyle(sf.rating(entry.getKey()));

			Cell cCell = sr.createCell(1);
			cCell.setCellValue(entry.getValue().size());
			cCell.setCellStyle(sf.text(smRow % 2 == 0));

			Cell eCell = sr.createCell(2);
			eCell.setCellValue(String.join(", ", entry.getValue()));
			eCell.setCellStyle(sf.text(smRow % 2 == 0));
		}

		summary.createRow(smRow++); // blank spacer
		Row legTitle = summary.createRow(smRow++);
		Cell legTitleCell = legTitle.createCell(0);
		legTitleCell.setCellValue("Rating Legend");
		legTitleCell.setCellStyle(sf.colHeader());
		summary.addMergedRegion(new CellRangeAddress(smRow - 1, smRow - 1, 0, 2));

		String[][] legend = { { "EXCELLENCE", "Outstanding performance — exceeds all expectations" },
				{ "GOOD", "Solid performance — meets and often exceeds goals" },
				{ "AVERAGE", "Satisfactory — meets basic expectations" },
				{ "POOR", "Below expectations — needs improvement" }, };
		for (String[] leg : legend) {
			Row lr = summary.createRow(smRow++);
			lr.setHeightInPoints(18);
			Cell lc = lr.createCell(0);
			lc.setCellValue(leg[0]);
			lc.setCellStyle(sf.rating(leg[0]));
			Cell lm = lr.createCell(1);
			lm.setCellValue(leg[1]);
			lm.setCellStyle(sf.text(true));
			summary.addMergedRegion(new CellRangeAddress(smRow - 1, smRow - 1, 1, 2));
		}

		resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
		resp.setHeader("Content-Disposition", "attachment; filename=team_performance.xlsx");
		wb.write(resp.getOutputStream());
		wb.close();
	}

	private void cell(Row row, int col, String val, CellStyle style) {
		Cell c = row.createCell(col);
		c.setCellValue(val != null ? val : "");
		c.setCellStyle(style);
	}

	// ══════════════════════════════════════════════════════════════════════
	private static class StyleFactory {

		private final XSSFWorkbook wb;

		StyleFactory(XSSFWorkbook wb) {
			this.wb = wb;
		}

		private XSSFColor rgb(String argb) {
			return new XSSFColor(
					new java.awt.Color(Integer.parseInt(argb.substring(2, 4), 16),
							Integer.parseInt(argb.substring(4, 6), 16), Integer.parseInt(argb.substring(6, 8), 16)),
					null);
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

		XSSFCellStyle rating(String rating) {
			XSSFCellStyle s = base();
			s.setAlignment(HorizontalAlignment.CENTER);
			String r = rating != null ? rating.toUpperCase().trim() : "";
			if (r.contains("EXCEL")) {
				fill(s, CLR_EXCELLENCE_BG);
				s.setFont(font(CLR_EXCELLENCE_FG, 10, true));
			} else if (r.contains("GOOD")) {
				fill(s, CLR_GOOD_BG);
				s.setFont(font(CLR_GOOD_FG, 10, true));
			} else if (r.contains("AVERAGE") || r.contains("AVG")) {
				fill(s, CLR_AVERAGE_BG);
				s.setFont(font(CLR_AVERAGE_FG, 10, true));
			} else if (r.contains("POOR") || r.contains("BAD")) {
				fill(s, CLR_POOR_BG);
				s.setFont(font(CLR_POOR_FG, 10, true));
			} else {
				fill(s, CLR_DEFAULT_BG);
				s.setFont(font(CLR_DEFAULT_FG, 10, false));
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