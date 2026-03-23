package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.BreakDAO;

@WebServlet("/break")
@SuppressWarnings("serial")
public class BreakServlet extends HttpServlet {
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}
		
		String email = (String) session.getAttribute("username");
		String action = request.getParameter("action"); // start | end
		String redirect = request.getParameter("redirect"); // user | manager
		
		try {
			if ("start".equalsIgnoreCase(action)) {
				BreakDAO.startBreak(email);
			} else if ("end".equalsIgnoreCase(action)) {
				BreakDAO.endBreak(email);
			}
		} catch (Exception e) {
			throw new ServletException("Error updating break status", e);
		}
		
		// Redirect to the same view the form was submitted from (iframe content only).
		// Never redirect employees to /user here — that loads the full shell (user.jsp) inside
		// the iframe and causes a duplicated dashboard ("mirroring").
		if ("manager".equalsIgnoreCase(redirect)) {
			response.sendRedirect(request.getContextPath() + "/managerAttendance?success=break" + action);
		} else {
			response.sendRedirect(request.getContextPath() + "/userAttendance?success=break" + action);
		}
	}
}