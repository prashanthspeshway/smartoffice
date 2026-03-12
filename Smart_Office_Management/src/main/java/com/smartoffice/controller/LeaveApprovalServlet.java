package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.LeaveRequestDAO;

@SuppressWarnings("serial")
@WebServlet("/leave-approval")
public class LeaveApprovalServlet extends HttpServlet {

	private LeaveRequestDAO dao = new LeaveRequestDAO();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			resp.sendRedirect(req.getContextPath() + "/index.html");
			return;
		}
		String role = (String) session.getAttribute("role");
		if (role == null || !"admin".equalsIgnoreCase(role)) {
			resp.sendRedirect(req.getContextPath() + "/index.html?error=accessDenied");
			return;
		}

		try {
			int leaveId = Integer.parseInt(req.getParameter("leaveId"));
			String action = req.getParameter("action");

			String status = "approve".equalsIgnoreCase(action) ? "APPROVED" : "REJECTED";

			dao.updateLeaveStatus(leaveId, status);

			resp.sendRedirect(req.getContextPath() + "/adminLeave?success=" + ("approve".equalsIgnoreCase(action) ? "Approved" : "Rejected"));

		} catch (Exception e) {
			throw new ServletException(e);
		}
	}
}
