package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.AttendanceDAO;

@SuppressWarnings("serial")
@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		String username = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");
		String action = request.getParameter("action");

		AttendanceDAO dao = new AttendanceDAO();

		try {
			if ("punchin".equalsIgnoreCase(action)) {
				dao.punchIn(username);
			} else if ("punchout".equalsIgnoreCase(action)) {
				dao.punchOut(username);
			}

			// ✅ ROLE-BASED REDIRECT
			if ("admin".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/admin");
			} else if ("manager".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/manager");
			} else {
				response.sendRedirect(request.getContextPath() + "/user");
			}

		} catch (Exception e) {
		    if (e.getMessage() != null && e.getMessage().contains("holiday")) {

		        if ("manager".equalsIgnoreCase(role)) {
		            response.sendRedirect(
		                request.getContextPath() + "/manager?error=HolidayAttendance&tab=selfAttendance"
		            );
		        } else if ("admin".equalsIgnoreCase(role)) {
		            response.sendRedirect(
		                request.getContextPath() + "/admin?error=HolidayAttendance"
		            );
		        } else {
		            response.sendRedirect(
		                request.getContextPath() + "/user?error=HolidayAttendance"
		            );
		        }

		    } else {
		        throw new ServletException(e);
		    }
		}


	}
}
