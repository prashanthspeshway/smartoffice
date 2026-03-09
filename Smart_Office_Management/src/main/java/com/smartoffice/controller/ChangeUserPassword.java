package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check session
        if (session == null || session.getAttribute("username") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }

        String username = (String) session.getAttribute("username");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate empty fields
        if (newPassword == null || confirmPassword == null ||
            newPassword.isEmpty() || confirmPassword.isEmpty()) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("MissingFields");
            return;
        }

        // Check password match
        if (!newPassword.equals(confirmPassword)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("PasswordMismatch");
            return;
        }

        // Strong password validation
        if (!isStrongPassword(newPassword)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("WeakPassword");
            return;
        }

        String sql = "UPDATE users SET password = ? WHERE username = ?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword);   // password
            ps.setString(2, username);      // username

            int updated = ps.executeUpdate();

            if (updated == 0) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("UserNotFound");
                return;
            }

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Success");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("ServerError");
        }
    }

    // Strong Password Validation Method
    private boolean isStrongPassword(String password) {

        if (password == null) return false;

        return password.matches(
                "^(?=.*[a-z])" +      // at least one lowercase
                "(?=.*[A-Z])" +       // at least one uppercase
                "(?=.*\\d)" +         // at least one number
                "(?=.*[@$!%*?&])" +   // at least one special character
                ".{8,}$"              // minimum 8 characters
        );
    }
}