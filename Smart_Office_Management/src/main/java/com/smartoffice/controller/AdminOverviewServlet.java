package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.smartoffice.dao.AdminDAO;

@SuppressWarnings("serial")
@WebServlet("/adminOverview")
public class AdminOverviewServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			AdminDAO dao = new AdminDAO();

			int managers = dao.getManagerCount();
			int employees = dao.getEmployeeCount();
			int totalStaff = managers + employees;
			int presentToday = dao.getPresentTodayCount();
			int absentToday = dao.getAbsentTodayCount();

			request.setAttribute("managers", managers);
			request.setAttribute("employees", employees);
			request.setAttribute("totalStaff", totalStaff);
			request.setAttribute("presentToday", presentToday);
			request.setAttribute("absentToday", absentToday);

			request.setAttribute("attendanceRate", dao.getAttendanceRate());
			request.setAttribute("tasksCompleted", dao.getTasksCompletedThisMonth());
			request.setAttribute("leavesPending", dao.getLeavesPending());
			request.setAttribute("activeTeams", dao.getActiveTeams());

			request.setAttribute("weekPresent", dao.getWeekPresent());
			request.setAttribute("weekAbsent", dao.getWeekAbsent());

			request.setAttribute("attendanceTrend", dao.getAttendanceTrend());

			request.setAttribute("punchData", dao.getPunchInDistribution());

			request.setAttribute("taskCompleted", dao.getTaskCountByStatus("COMPLETED"));
			request.setAttribute("taskAssigned", dao.getTaskCountByStatus("ASSIGNED"));
			request.setAttribute("taskDocVerify", dao.getTaskCountByStatus("DOCUMENT_VERIFICATION"));
			request.setAttribute("taskErrorsRaised", dao.getTaskCountByStatus("ERRORS_RAISED"));

			request.setAttribute("leaveSick", dao.getLeaveCountByType("SICK"));
			request.setAttribute("leaveAnnual", dao.getLeaveCountByType("ANNUAL"));
			request.setAttribute("leavePersonal", dao.getLeaveCountByType("PERSONAL"));
			request.setAttribute("leaveMaternity", dao.getLeaveCountByType("MATERNITY"));
			request.setAttribute("leaveUnpaid", dao.getLeaveCountByType("UNPAID"));

			request.setAttribute("holidays", dao.getUpcomingHolidays());

			request.getRequestDispatcher("adminOverview.jsp").forward(request, response);

		} catch (Exception e) {
			throw new ServletException("Error loading admin overview", e);
		}
	}
}