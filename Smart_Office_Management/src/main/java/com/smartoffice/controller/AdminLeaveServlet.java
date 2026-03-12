package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.model.LeaveRequest;

@SuppressWarnings("serial")
@WebServlet("/adminLeave")
public class AdminLeaveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !"admin".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        try {
            LeaveRequestDAO dao = new LeaveRequestDAO();
            List<LeaveRequest> all = dao.getAllLeaveRequests();

            Date today = new Date(System.currentTimeMillis());
            long pending = all.stream().filter(lr -> "PENDING".equalsIgnoreCase(lr.getStatus())).count();
            long approved = all.stream().filter(lr -> "APPROVED".equalsIgnoreCase(lr.getStatus())).count();
            long onLeaveToday = all.stream().filter(lr -> {
                if (!"APPROVED".equalsIgnoreCase(lr.getStatus())) return false;
                Date from = lr.getFromDate();
                Date to = lr.getToDate();
                if (from == null || to == null) return false;
                return !today.before(from) && !today.after(to);
            }).count();
            long rejected = all.stream().filter(lr -> "REJECTED".equalsIgnoreCase(lr.getStatus())).count();

            request.setAttribute("allLeaves", all);
            request.setAttribute("pendingCount", pending);
            request.setAttribute("approvedCount", approved);
            request.setAttribute("onLeaveTodayCount", onLeaveToday);
            request.setAttribute("rejectedCount", rejected);

            request.getRequestDispatcher("adminLeave.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
