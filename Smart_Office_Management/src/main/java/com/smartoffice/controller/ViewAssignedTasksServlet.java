package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * This servlet handles the "View Tasks" button in managerTasks.jsp
 * It processes the form submission and redirects back to managerTasks with the employee parameter
 */
@SuppressWarnings("serial")
@WebServlet("/viewAssignedTasks")
public class ViewAssignedTasksServlet extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}
		
		String viewEmployee = request.getParameter("employeeUsername");
		
		// Redirect back to managerTasks with the viewEmployee parameter
		// The ManagerTasksServlet will handle loading the tasks
		if (viewEmployee != null && !viewEmployee.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/managerTasks?viewEmployee=" + viewEmployee);
		} else {
			response.sendRedirect(request.getContextPath() + "/managerTasks?error=NoEmployeeSelected");
		}
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}
}