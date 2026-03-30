package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.LeaveRequest;
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/leave-approval")
public class LeaveApprovalServlet extends HttpServlet {

    private LeaveRequestDAO dao = new LeaveRequestDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        String role     = (String) session.getAttribute("role");
        String approver = (String) session.getAttribute("username");

        boolean isAdmin   = "admin".equalsIgnoreCase(role);
        boolean isManager = "manager".equalsIgnoreCase(role);

        if (!isAdmin && !isManager) {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        try {
            int     leaveId  = Integer.parseInt(req.getParameter("leaveId"));
            String  action   = req.getParameter("action");
            boolean approved = "approve".equalsIgnoreCase(action);
            String  status   = approved ? "APPROVED" : "REJECTED";

            // Fetch leave BEFORE updating so we have employee email + dates
            LeaveRequest leave = dao.getLeaveById(leaveId);

            dao.updateLeaveStatus(leaveId, status);

            // ✅ If approved, mark attendance as 'On Leave' for each day in the range
            if (approved && leave != null
                    && leave.getFromDate() != null && leave.getToDate() != null) {
                try {
                    new AttendanceDAO().markLeaveInAttendance(
                            leave.getUsername(), leave.getFromDate(), leave.getToDate());
                } catch (Exception attEx) {
                    System.err.println("[LeaveApprovalServlet] Failed to mark attendance On Leave: "
                            + attEx.getMessage());
                }
            }

            // ── NOTIFICATIONS (recipient = users.email; leave row may store username) ──
            if (leave != null) {
                String notifyEmail = UserDao.resolveEmailForNotifications(leave.getAppliedBy());
                String approverName  = getDisplayName(session);

                String emoji = approved ? "✅" : "❌";
                String label = approved ? "Approved" : "Rejected";

                String msgForEmployee = emoji + " Your leave request ("
                        + leave.getFromDate() + " → " + leave.getToDate()
                        + ") has been " + label + " by " + approverName + ".";

                if (notifyEmail != null) {
                    NotificationService.notify(
                            notifyEmail, approver,
                            NotificationService.TYPE_LEAVE, msgForEmployee);
                }

                if (isManager) {
                    String msgForAdmin = emoji + " Manager " + approverName
                            + " has " + label.toLowerCase() + " leave for "
                            + (notifyEmail != null ? notifyEmail : leave.getAppliedBy())
                            + " (" + leave.getFromDate() + " → " + leave.getToDate() + ").";
                    NotificationService.notifyAllAdmins(
                            approver, NotificationService.TYPE_LEAVE, msgForAdmin);
                }
            }

            String redirectPage = isManager ? "managerLeave" : "adminLeave";
            resp.sendRedirect(req.getContextPath() + "/" + redirectPage
                    + "?success=" + (approved ? "Approved" : "Rejected"));

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}