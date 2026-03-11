package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.LeaveRequestDAO;

@SuppressWarnings("serial")
@WebServlet("/applyLeave")
public class ApplyLeaveServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}

		String sessionValue = (String) session.getAttribute("username");

		String leaveType = request.getParameter("leaveType");
		String fromDate = request.getParameter("fromDate");
		String toDate = request.getParameter("toDate");
		String reason = request.getParameter("reason");

		try {
			LeaveRequestDAO dao = new LeaveRequestDAO();
			dao.applyLeave(sessionValue, leaveType, Date.valueOf(fromDate), Date.valueOf(toDate), reason);
			response.sendRedirect(request.getContextPath() + "/user?tab=leave&success=LeaveApplied");
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/user?tab=leave&error=LeaveFailed");
		}
	}
}
