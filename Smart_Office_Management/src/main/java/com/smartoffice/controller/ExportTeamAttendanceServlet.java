package com.smartoffice.controller;

import java.io.IOException;
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
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.model.TeamAttendance;

@SuppressWarnings("serial")
@WebServlet("/exportTeamAttendance")
public class ExportTeamAttendanceServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String manager = (String) session.getAttribute("username");
		AttendanceDAO dao = new AttendanceDAO();

		List<TeamAttendance> list;
		try {
			// ⚠️ IMPORTANT: this method should return MONTH data
			list = dao.getTeamAttendanceForMonth(manager);
		} catch (Exception e) {
			throw new ServletException(e);
		}

		// ---------------- EXCEL SETUP ----------------
		Workbook workbook = new XSSFWorkbook();
		Sheet sheet = workbook.createSheet("Team Attendance");

		CellStyle headerStyle = workbook.createCellStyle();
		Font headerFont = workbook.createFont();
		headerFont.setBold(true);
		headerStyle.setFont(headerFont);
		headerStyle.setAlignment(HorizontalAlignment.CENTER);

		// ---------------- MONTH CONFIG ----------------
		LocalDate startDate = LocalDate.now().withDayOfMonth(1);
		int DAYS = startDate.lengthOfMonth();

		// ---------------- HEADER ROW ----------------
		Row header = sheet.createRow(0);
		header.createCell(0).setCellValue("employee name");
		header.createCell(1).setCellValue("punch-in / punch-out");

		header.getCell(0).setCellStyle(headerStyle);
		header.getCell(1).setCellStyle(headerStyle);

		for (int i = 0; i < DAYS; i++) {
			Cell c = header.createCell(i + 2);
			c.setCellValue(startDate.plusDays(i).toString());
			c.setCellStyle(headerStyle);
		}

		// ---------------- GROUP BY EMPLOYEE + DATE ----------------
		Map<String, Map<LocalDate, TeamAttendance>> map = new LinkedHashMap<>();

		for (TeamAttendance ta : list) {

		    map.putIfAbsent(ta.getFullName(), new LinkedHashMap<>());

		    // 🚑 VERY IMPORTANT NULL CHECK
		    if (ta.getAttendanceDate() != null) {
		        map.get(ta.getFullName())
		           .put(ta.getAttendanceDate().toLocalDate(), ta);
		    }
		}

		// ---------------- DATA ROWS ----------------
		int rowNum = 1;

		for (String employee : map.keySet()) {

			Row inRow = sheet.createRow(rowNum++);
			inRow.createCell(0).setCellValue(employee);
			inRow.createCell(1).setCellValue("punch-in");

			Row outRow = sheet.createRow(rowNum++);
			outRow.createCell(1).setCellValue("punch-out");

			for (int i = 0; i < DAYS; i++) {
				LocalDate d = startDate.plusDays(i);
				TeamAttendance ta = map.get(employee).get(d);

				if (ta != null) {
					if (ta.getPunchIn() != null) {
						inRow.createCell(i + 2)
								.setCellValue(ta.getPunchIn().toLocalDateTime().toLocalTime().toString());
					}

					if (ta.getPunchOut() != null) {
						outRow.createCell(i + 2)
								.setCellValue(ta.getPunchOut().toLocalDateTime().toLocalTime().toString());
					}
				}
			}
		}

		// Auto-size columns
		for (int i = 0; i < DAYS + 2; i++) {
			sheet.autoSizeColumn(i);
		}

		// ---------------- RESPONSE ----------------
		response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
		response.setHeader("Content-Disposition", "attachment; filename=team_attendance_month.xlsx");

		workbook.write(response.getOutputStream());
		workbook.close();
	}
}