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

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {

	    HttpSession session = request.getSession(false);
	    if (session == null || session.getAttribute("username") == null) {
	        response.sendRedirect("login.jsp");
	        return;
	    }

	    String username = (String) session.getAttribute("username");
	    String role = (String) session.getAttribute("role"); // 🔥 KEY
	    String action = request.getParameter("action");

	    AttendanceDAO dao = new AttendanceDAO();

	    try {
	        if ("punchin".equals(action)) {
	            dao.punchIn(username);
	        } else if ("punchout".equals(action)) {
	            dao.punchOut(username);
	        }

	        // ✅ ROLE-BASED REDIRECT
	        if ("manager".equalsIgnoreCase(role)) {
	            response.sendRedirect("manager");
	        } else {
	            response.sendRedirect("user");
	        }

	    } catch (Exception e) {
	        throw new ServletException(e);
	    }
	}

}
