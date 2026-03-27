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

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/UserCheck")
public class UserCheck extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		String email = req.getParameter("email");
		if (email == null)
			email = req.getParameter("username");

		boolean userExists = false;

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT 1 FROM users WHERE email = ?");) {
			ps.setString(1, email);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					userExists = true;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		if (userExists) {
			res.sendRedirect("editUserDetails.jsp?email="
					+ java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8));
		} else {
			res.sendRedirect("editUserDetails.jsp?error=UserNotFound");
			System.out.println("User not found: " + email);
		}
	}
}
