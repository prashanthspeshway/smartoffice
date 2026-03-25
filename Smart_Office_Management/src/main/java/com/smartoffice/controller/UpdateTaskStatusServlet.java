package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.utils.AuthRedirectUtil;

@SuppressWarnings("serial")
@WebServlet("/updateTaskStatus")
public class UpdateTaskStatusServlet extends HttpServlet {

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		HttpSession session = req.getSession(false);
		if (session == null) {
			AuthRedirectUtil.sendTopWindowRedirect(req, resp, "/index.html");
			return;
		}

		int taskId = Integer.parseInt(req.getParameter("taskId"));
		String status = req.getParameter("status");
		try {
			TaskDAO.updateStatus(taskId, status);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// Full shell lives at /user; iframe must not navigate here via 302 — break out to top
		AuthRedirectUtil.sendTopWindowRedirect(req, resp, "/user?tab=tasks");

	}
}
