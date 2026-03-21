package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.model.LeaveRequest;
import com.smartoffice.service.NotificationService;

@SuppressWarnings("serial")
@WebServlet("/adminLeave")
public class AdminLeaveServlet extends HttpServlet {

    // ─────────────────────────────────────────────────────────────
    // GET — load and show all leave requests
    // ─────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        if (!"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        try {
            loadLeaveData(request);
            request.getRequestDispatcher("adminLeave.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // POST — approve or reject leave
    // ─────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        String action     = request.getParameter("action");
        String adminEmail = (String) session.getAttribute("username");
        String adminName  = getDisplayName(session);

        try {
            if ("approve".equals(action) || "reject".equals(action)) {

                int leaveId      = Integer.parseInt(request.getParameter("leaveId"));
                String newStatus = "approve".equals(action) ? "APPROVED" : "REJECTED";

                LeaveRequestDAO dao = new LeaveRequestDAO();

                // Fetch leave BEFORE updating so we know who applied
                LeaveRequest lr = dao.getLeaveById(leaveId);

                // Update status in DB
                dao.updateLeaveStatus(leaveId, newStatus);

                // ── NOTIFICATION ──────────────────────────────────────
                if (lr != null) {
                    String empEmail = lr.getAppliedBy();  // username = email in your schema
                    String emoji    = "APPROVED".equals(newStatus) ? "✅" : "❌";

                    String empMsg = emoji + " Your " + lr.getLeaveType() + " request (" +
                                   lr.getFromDate() + " → " + lr.getToDate() + ") has been " +
                                   newStatus + " by Admin " + adminName + ".";

                    // Notify the employee who applied
                    NotificationService.notify(empEmail, adminEmail,
                            NotificationService.TYPE_LEAVE, empMsg);

                    // Notify the employee's direct manager
                    NotificationService.notifyManagerOf(empEmail, adminEmail,
                            NotificationService.TYPE_LEAVE,
                            "ℹ️ Leave for " + lr.getDisplayName() +
                            " has been " + newStatus + " by Admin " + adminName + ".");
                }
                // ─────────────────────────────────────────────────────

                response.sendRedirect(request.getContextPath() +
                        "/adminLeave?success=Leave " + newStatus.toLowerCase());
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/adminLeave?error=" + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────
    private void loadLeaveData(HttpServletRequest request) throws Exception {
        LeaveRequestDAO dao = new LeaveRequestDAO();
        List<LeaveRequest> all = dao.getAllLeaveRequests();
        Date today = new Date(System.currentTimeMillis());

        long pending      = all.stream().filter(lr -> "PENDING".equalsIgnoreCase(lr.getStatus())).count();
        long approved     = all.stream().filter(lr -> "APPROVED".equalsIgnoreCase(lr.getStatus())).count();
        long rejected     = all.stream().filter(lr -> "REJECTED".equalsIgnoreCase(lr.getStatus())).count();
        long onLeaveToday = all.stream().filter(lr -> {
            if (!"APPROVED".equalsIgnoreCase(lr.getStatus())) return false;
            Date from = lr.getFromDate(), to = lr.getToDate();
            return from != null && to != null && !today.before(from) && !today.after(to);
        }).count();

        request.setAttribute("allLeaves",        all);
        request.setAttribute("pendingCount",      pending);
        request.setAttribute("approvedCount",     approved);
        request.setAttribute("onLeaveTodayCount", onLeaveToday);
        request.setAttribute("rejectedCount",     rejected);
    }

    private String getDisplayName(HttpSession session) {
        String fn = (String) session.getAttribute("fullName");
        return (fn != null && !fn.isEmpty()) ? fn : (String) session.getAttribute("username");
    }
}