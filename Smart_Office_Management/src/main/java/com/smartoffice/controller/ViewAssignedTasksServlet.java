package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.model.Task;

@SuppressWarnings("serial")
@WebServlet("/viewAssignedTasks")
public class ViewAssignedTasksServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}

		TaskDAO.deleteOldCompletedTasks();

		String manager = (String) session.getAttribute("username");
		String employeeUsername = request.getParameter("employeeUsername");

		List<Task> tasks = TaskDAO.getTasksAssignedByManager(manager, employeeUsername);

		// ✅ View module attributes
		request.setAttribute("viewEmployee", employeeUsername);
		request.setAttribute("viewTasks", tasks);

		// ✅ Load team list (required by JSP)
		request.setAttribute("teamList", TaskDAO.getEmployeesUnderManager(manager));

		// ✅ Correct tab
		response.sendRedirect(request.getContextPath() + "/manager?tab=assignTask&viewEmployee=" + employeeUsername);
	}
}
