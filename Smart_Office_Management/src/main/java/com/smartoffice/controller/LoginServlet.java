package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
public class LoginServlet extends HttpServlet {

	// 🔐 Password validation method
	private boolean isStrongPassword(String password) {
		String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
		return password != null && password.matches(regex);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		String username = req.getParameter("username");
		String password = req.getParameter("password");

		// ❌ Reject weak password immediately
		if (!isStrongPassword(password)) {
			res.sendRedirect("index.html?error=weakPassword");
			return;
		}

		try (Connection con = DBConnectionUtil.getConnection()) {

			String sql = "SELECT role, status FROM users WHERE username = ? AND password = ?";
			PreparedStatement ps = con.prepareStatement(sql);

			ps.setString(1, username);
			ps.setString(2, password);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {

				String role = rs.getString("role");
				String status = rs.getString("status");

				if (!"active".equalsIgnoreCase(status)) {
					res.sendRedirect("index.html?error=inactive");
					return;
				}

				// ✅ Create session
				HttpSession session = req.getSession();
				session.setAttribute("username", username);
				session.setAttribute("role", role);

				// 🔁 Role-based redirect
				switch (role.toLowerCase()) {
				case "user":
					res.sendRedirect("user?success=Login");
					break;
				case "manager":
					res.sendRedirect("manager?success=Login");
					break;
				case "admin":
					res.sendRedirect("admin.jsp?success=Login");
					break;
				default:
					res.sendRedirect("index.html?error=invalidRole");
				}

			} else {
				res.sendRedirect("index.html?error=invalid");
			}

		} catch (Exception e) {
			e.printStackTrace();
			res.sendRedirect("index.html?error=server");
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
}
