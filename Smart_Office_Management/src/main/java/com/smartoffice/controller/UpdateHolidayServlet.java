package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/updateHoliday")
public class UpdateHolidayServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

		String date = request.getParameter("date");
		String name = request.getParameter("name");
		String type = request.getParameter("type");

		if (date == null || date.trim().isEmpty()) {
			response.getWriter().write("Date missing");
			return;
		}
		if (name == null || name.trim().isEmpty()) {
			response.getWriter().write("Holiday name missing");
			return;
		}
		if (type == null || type.trim().isEmpty()) {
			type = "Public";
		}

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(
						"UPDATE holidays SET holiday_name = ?, holiday_type = ? WHERE holiday_date = ?")) {

			ps.setString(1, name.trim());
			ps.setString(2, type.trim());
			ps.setDate(3, java.sql.Date.valueOf(date));

			int rows = ps.executeUpdate();
			if (rows > 0) {
				response.getWriter().write("Holiday Updated Successfully");
			} else {
				response.getWriter().write("No holiday found for that date");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().write("Update Failed: " + e.getMessage());
		}
	}
}