package com.smartoffice.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/managerSettings")  // ✅ CHANGED: Different URL than the JSP file
public class ManagerSettingsServlet extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect("index.html");
			return;
		}
		
		String role = (String) session.getAttribute("role");
		if (!"Manager".equalsIgnoreCase(role)) {
			response.sendRedirect("index.html?error=accessDenied");
			return;
		}
		
		String username = (String) session.getAttribute("username");
		
		try {
			// Get user profile information
			User user = UserDao.getUserByEmail(username);
			request.setAttribute("user", user);
			
			// Update session fullName if available
			String fullName = user != null ? user.getFullname() : null;
			if (fullName != null && !fullName.isEmpty()) {
				session.setAttribute("fullName", fullName);
			}
			
		} catch (Exception e) {
			throw new ServletException("Error loading settings data", e);
		}
		
		request.getRequestDispatcher("managerSettingsPage.jsp").forward(request, response);
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}