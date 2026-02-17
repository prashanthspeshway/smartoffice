package com.smartoffice.controller;

import java.io.IOException;
import java.sql.ResultSet;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;
import com.smartoffice.dao.TaskDAO;
import com.smartoffice.dao.LeaveRequestDAO;
import com.smartoffice.model.LeaveRequest;

@SuppressWarnings("serial")
@WebServlet("/user")
public class UserDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Session validation
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Cleanup old completed tasks
        TaskDAO.deleteOldCompletedTasks();

        String username = (String) session.getAttribute("username");

        try {
            /* ================= ATTENDANCE ================= */
            AttendanceDAO attendanceDAO = new AttendanceDAO();
            ResultSet rs = attendanceDAO.getTodayAttendance(username);

            if (rs.next()) {
                request.setAttribute("punchIn", rs.getTimestamp("punch_in"));
                request.setAttribute("punchOut", rs.getTimestamp("punch_out"));
            }

            /* ================= TASKS ================= */
            request.setAttribute("tasks",
                    TaskDAO.getTasksForEmployee(username));

            /* ================= LEAVE STATUS ================= */
            LeaveRequestDAO leaveDAO = new LeaveRequestDAO();
            List<LeaveRequest> myLeaves =
                    leaveDAO.getLeavesByUsername(username);
            request.setAttribute("myLeaves", myLeaves);

            /* ================= FORWARD ================= */
            request.getRequestDispatcher("user.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading user dashboard", e);
        }
    }
}
