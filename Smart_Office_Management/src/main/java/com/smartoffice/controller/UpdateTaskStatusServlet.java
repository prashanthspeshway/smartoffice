package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;

@SuppressWarnings("serial")
@WebServlet("/updateTaskStatus")
public class UpdateTaskStatusServlet extends HttpServlet {

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		HttpSession session = req.getSession(false);
		if (session == null) {
			resp.sendRedirect("login.jsp");
			return;
		}

		int taskId = Integer.parseInt(req.getParameter("taskId"));
		String status = req.getParameter("status");

		TaskDAO.updateStatus(taskId, status);

		// user updates → go back to user dashboard
		resp.sendRedirect("user?tab=tasks");

	}
}
