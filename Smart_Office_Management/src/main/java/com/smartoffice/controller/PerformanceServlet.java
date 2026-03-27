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

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			resp.sendRedirect("index.html");
			return;
		}

		String manager = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");

		if (!"Manager".equalsIgnoreCase(role)) {
			resp.sendRedirect("index.html?error=accessDenied");
			return;
		}

		String employee = req.getParameter("employee");
		String rating = req.getParameter("rating");

		if (employee == null || employee.trim().isEmpty() || rating == null || rating.trim().isEmpty()
				|| manager == null) {
			resp.sendRedirect(req.getContextPath() + "/managerPerformance?error=Invalid");
			return;
		}

		if (!rating.equals("EXCELLENCE") && !rating.equals("GOOD") && !rating.equals("AVERAGE")
				&& !rating.equals("BELOW_AVERAGE")) {
			resp.sendRedirect(req.getContextPath() + "/managerPerformance?error=InvalidRating");
			return;
		}

		try {
			java.sql.Date performanceMonth = java.sql.Date.valueOf(java.time.LocalDate.now().withDayOfMonth(1));

			PerformanceDAO dao = new PerformanceDAO();

			if (dao.performanceExists(employee, performanceMonth)) {
				resp.sendRedirect(req.getContextPath() + "/managerPerformance?error=AlreadyRated");
				return;
			}

			boolean saved = dao.savePerformance(employee, manager, rating, performanceMonth);

			if (saved) {
				resp.sendRedirect(req.getContextPath() + "/managerPerformance?success=PerformanceSaved");
			} else {
				resp.sendRedirect(req.getContextPath() + "/managerPerformance?error=SaveFailed");
			}

		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/managerPerformance?error=SaveFailed");
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doPost(req, resp);
	}
}