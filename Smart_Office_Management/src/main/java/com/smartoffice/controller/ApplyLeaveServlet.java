package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/applyLeave")
public class ApplyLeaveServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}

		String applicantEmail = (String) session.getAttribute("username");
		String applicantName = getDisplayName(session);
		String role = (String) session.getAttribute("role");
		boolean isManager = "Manager".equalsIgnoreCase(role);

		String leaveType = request.getParameter("leaveType");
		String fromDate = request.getParameter("fromDate");
		String toDate = request.getParameter("toDate");
		String reason = request.getParameter("reason");

		String successRedirect = isManager ? request.getContextPath() + "/managerLeave?success=LeaveApplied"
				: request.getContextPath() + "/userLeave?success=LeaveApplied";
		String errorRedirect = isManager ? request.getContextPath() + "/managerLeave?error=MissingFields"
				: request.getContextPath() + "/userLeave?error=MissingFields";

		if (leaveType == null || leaveType.isEmpty() || fromDate == null || fromDate.isEmpty() || toDate == null
				|| toDate.isEmpty()) {
			response.sendRedirect(errorRedirect);
			return;
		}

		try {
			new LeaveRequestDAO().applyLeave(applicantEmail, leaveType, java.sql.Date.valueOf(fromDate),
					java.sql.Date.valueOf(toDate), reason);

			// ── NOTIFICATIONS ─
			String msg = "🏖️ " + applicantName + " applied for " + leaveType + " from " + fromDate + " to " + toDate
					+ (reason != null && !reason.isEmpty() ? ". Reason: " + reason : "");

			if (isManager) {
				NotificationService.notifyAllAdmins(applicantEmail, NotificationService.TYPE_LEAVE, msg);
			} else {
				NotificationService.notifyManagerOf(applicantEmail, applicantEmail, NotificationService.TYPE_LEAVE,
						msg);

				NotificationService.notifyAllAdmins(applicantEmail, NotificationService.TYPE_LEAVE, msg);
			}
			
			response.sendRedirect(successRedirect);

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(isManager ? request.getContextPath() + "/managerLeave?error=ServerError"
					: request.getContextPath() + "/userLeave?error=ServerError");
		}
	}

	private String getDisplayName(HttpSession session) {
		String fn = (String) session.getAttribute("fullName");
		return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
	}
}