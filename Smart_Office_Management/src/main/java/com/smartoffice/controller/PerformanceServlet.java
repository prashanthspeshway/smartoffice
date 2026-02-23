package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.PerformanceDAO;

@SuppressWarnings("serial")
@WebServlet("/submitPerformance")
public class PerformanceServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		String employee = req.getParameter("employee");
		String rating = req.getParameter("rating");

		HttpSession session = req.getSession(false);
		String manager = (String) session.getAttribute("username");

		if (employee == null || rating == null || manager == null) {
			resp.sendRedirect("manager?tab=performance&error=Invalid");
			return;
		}

		// First day of current month
		java.sql.Date performanceMonth = java.sql.Date.valueOf(java.time.LocalDate.now().withDayOfMonth(1));

		PerformanceDAO dao = new PerformanceDAO();

		boolean saved = dao.savePerformance(employee, manager, rating, performanceMonth);

		if (saved) {
			resp.sendRedirect("manager?tab=performance&success=PerformanceSaved");
		} else {
			resp.sendRedirect("manager?tab=performance&error=AlreadyRated");
		}
	}
}