package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.LeaveRequestDAO;

@SuppressWarnings("serial")
@WebServlet("/leave-approval")
public class LeaveApprovalServlet extends HttpServlet {

	private LeaveRequestDAO dao = new LeaveRequestDAO();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		try {
			int leaveId = Integer.parseInt(req.getParameter("leaveId"));
			String action = req.getParameter("action");

			String status = action.equals("approve") ? "APPROVED" : "REJECTED";

			dao.updateLeaveStatus(leaveId, status);

			// 🔁 Redirect BACK to manager dashboard
			resp.sendRedirect(req.getContextPath() + "/manager?tab=leave");

		} catch (Exception e) {
			throw new ServletException(e);
		}
	}
}
