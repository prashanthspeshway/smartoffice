package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.TokenData;
import com.smartoffice.utils.PasswordUtil;

@SuppressWarnings("serial")
@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String token = req.getParameter("token");
		String newPassword = req.getParameter("password");
		String confirmPassword = req.getParameter("confirmPassword");

		if (!newPassword.equals(confirmPassword)) {
			req.setAttribute("errorMessage", "Passwords do not match!");
			req.setAttribute("token", token);
			req.getRequestDispatcher("resetPassword.jsp").forward(req, res);
			return;
		}
		if (!LoginServlet.isStrongPassword(newPassword)) {
			req.setAttribute("errorMessage",
					"Password must contain uppercase, lowercase, number, special character, min 8 chars!");
			req.setAttribute("token", token);
			req.getRequestDispatcher("resetPassword.jsp").forward(req, res);
			return;
		}
		try {
			TokenData data = UserDao.getResetToken(token);

			if (data != null) {
				long currentTime = System.currentTimeMillis();

				if (currentTime > data.getExpiryTime()) {
					res.getWriter().println("Token expired!");
					return;
				}

				UserDao.updatePassword(data.getEmail(), PasswordUtil.hashPassword(newPassword));

				UserDao.deleteResetToken(token);

				res.getWriter().println("Password updated successfully!");
				res.sendRedirect("index.html?success=Password updated successfully");
			} else {
				res.getWriter().println("Invalid token!");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
