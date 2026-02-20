package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;

@SuppressWarnings("serial")
@WebServlet("/assignTask")
public class AssignTaskServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String manager = (String) session.getAttribute("username");
		String employee = request.getParameter("employeeUsername");
		String desc = request.getParameter("taskDesc");

		if (employee == null || employee.trim().isEmpty()) {
			request.setAttribute("errorMessage", "Please select an employee.");
		} else if (!TaskDAO.isEmployeeUnderManager(employee, manager)) {
			request.setAttribute("errorMessage", "You cannot assign tasks to this employee.");
		} else if (desc == null || desc.trim().isEmpty()) {
			request.setAttribute("errorMessage", "Task description cannot be empty.");
		} else {
			TaskDAO.assignTask(employee, manager, desc);
			employee = null;
		}

		TaskDAO.assignTask(employee, manager, desc);

		// ✅ Assign module attributes
		request.setAttribute("assignEmployee", employee);
		request.setAttribute("assignTasks", TaskDAO.getTasksAssignedByManager(manager, employee));

		// ✅ Required for dropdowns
		request.setAttribute("teamList", TaskDAO.getEmployeesUnderManager(manager));

		// ✅ Correct tab (ONLY ONE)
		response.sendRedirect(request.getContextPath() + "/manager?tab=assignTask&success=TaskAssigned");
	}
}
