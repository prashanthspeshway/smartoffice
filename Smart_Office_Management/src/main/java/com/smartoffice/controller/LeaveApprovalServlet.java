package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.model.LeaveRequest;


@SuppressWarnings("serial")
@WebServlet("/leave-approval")
public class LeaveApprovalServlet extends HttpServlet {

	private LeaveRequestDAO dao = new LeaveRequestDAO();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		try {
			String managerUsername = (String) req.getSession().getAttribute("username");

			List<LeaveRequest> requests = dao.getTeamLeaveRequests(managerUsername);

			req.setAttribute("leaveRequests", requests);
			req.setAttribute("tab", "leave");

			req.getRequestDispatcher("/manager.jsp").forward(req, resp);

		} catch (Exception e) {
			throw new ServletException(e);
		}
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		try {
			int leaveId = Integer.parseInt(req.getParameter("leaveId"));
			String action = req.getParameter("action");

			String status = action.equals("approve") ? "APPROVED" : "REJECTED";

			dao.updateLeaveStatus(leaveId, status);

			// reload leave list
			resp.sendRedirect(req.getContextPath() + "/leave-approval");

		} catch (Exception e) {
			throw new ServletException(e);
		}
	}
}
