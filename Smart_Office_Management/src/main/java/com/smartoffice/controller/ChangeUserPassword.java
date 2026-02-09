package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/changePassword")
public class ChangeUserPassword extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String username = (String) session.getAttribute("username");

		String oldPassword = request.getParameter("oldPassword");
		String newPassword = request.getParameter("newPassword");
		String confirmPassword = request.getParameter("confirmPassword");

		// Basic validation
		if (!newPassword.equals(confirmPassword)) {
			response.sendRedirect("user.jsp?error=PasswordMismatch");
			return;
		}

		try {
			Connection con =  DBConnectionUtil.getConnection();

			// 1️⃣ Verify old password
			PreparedStatement ps = con.prepareStatement("SELECT password FROM users WHERE username = ?");
			ps.setString(1, username);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				String dbPassword = rs.getString("password");

				if (!dbPassword.equals(oldPassword)) {
					response.sendRedirect("user.jsp?error=WrongOldPassword");
					return;
				}
			} else {
				response.sendRedirect("index.html");
				return;
			}

			// 2️⃣ Update new password
			PreparedStatement updatePs = con.prepareStatement("UPDATE users SET password = ? WHERE username = ?");
			updatePs.setString(1, newPassword);
			updatePs.setString(2, username);

			updatePs.executeUpdate();

			con.close();

			response.sendRedirect("user.jsp?success=PasswordUpdated");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("user.jsp?error=ServerError");
		}
	}
}
