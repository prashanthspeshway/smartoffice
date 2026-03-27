package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.model.Task;

@SuppressWarnings("serial")
@WebServlet("/employeeDashboard")
public class EmployeeDashboardServlet extends HttpServlet {
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		String username = (String) req.getSession().getAttribute("username");
		List<Task> tasks = null;
		try {
			tasks = TaskDAO.getTasksForEmployee(username);
		} catch (Exception e) {
			e.printStackTrace();
		}

		req.setAttribute("tasks", tasks);
		req.getRequestDispatcher("user.jsp").forward(req, resp);
	}
}
