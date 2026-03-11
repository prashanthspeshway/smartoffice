package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;
import com.smartoffice.utils.PasswordUtil;

@SuppressWarnings("serial")
@WebServlet("/addUser")
public class AddUser extends HttpServlet {

    private boolean isStrongPassword(String password) {
        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
        return password != null && password.matches(regex);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String role = req.getParameter("role");

        // Password confirmation
        if (password == null || !password.equals(confirmPassword)) {
            req.getSession().setAttribute("errorMsg", "Passwords do not match.");
            res.sendRedirect("addUser");
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(password);

        // Password strength
        if (!isStrongPassword(password)) {
            req.getSession().setAttribute(
                "errorMsg",
                "Password must be at least 8 characters with uppercase, lowercase, number, and symbol."
            );
            res.sendRedirect("addUser");
            return;
        }

        String firstname = req.getParameter("firstname");
        String lastname = req.getParameter("lastname");
        if (firstname != null) firstname = firstname.trim();
        if (lastname != null) lastname = lastname.trim();

        String phone = req.getParameter("phonenumber");
        if (phone != null) {
            phone = phone.replaceAll("[^0-9]", "").trim();
            if (phone.isEmpty()) phone = null;
            else if (phone.length() > 10) phone = phone.substring(0, 10);
        }

        Date joinedDate = null;
        String joinedDateStr = req.getParameter("joinedDate");
        if (joinedDateStr != null && !joinedDateStr.trim().isEmpty()) {
            try {
                joinedDate = Date.valueOf(joinedDateStr.trim());
            } catch (IllegalArgumentException ignored) {
                // Invalid date format - leave as null
            }
        }

        String email = req.getParameter("email");
        if (email != null) email = email.trim();

        try (Connection con = DBConnectionUtil.getConnection()) {
            try (PreparedStatement checkPs = con.prepareStatement("SELECT 1 FROM users WHERE email = ?")) {
                checkPs.setString(1, email);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        req.getSession().setAttribute("errorMsg", "Email already exists.");
                        res.sendRedirect("addUser");
                        return;
                    }
                }
            }

            String status = req.getParameter("status");
            if (status == null || status.trim().isEmpty()) status = "active";

            // Username = firstname + lastname (fallback to email if empty)
            String username = ((firstname != null ? firstname : "") + " " + (lastname != null ? lastname : "")).trim();
            if (username.isEmpty()) username = email;

            String sql = "INSERT INTO users " +
                    "(username, password, role, status, email, firstname, lastname, joinedDate, phone) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            ps.setString(3, role);
            ps.setString(4, status);
            ps.setString(5, email);
            ps.setString(6, firstname);
            ps.setString(7, lastname);
            ps.setDate(8, joinedDate);
            ps.setString(9, phone);

            ps.executeUpdate();

            req.getSession().setAttribute("successMsg", "Employee added successfully!");
            res.sendRedirect("addUser");

        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null ? e.getMessage() : "Failed to add Employee!";
            if (msg.contains("Unknown column")) msg = "Database schema mismatch. Ensure users table has username column.";
            req.getSession().setAttribute("errorMsg", msg);
            res.sendRedirect("addUser");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("addUser.jsp").forward(req, res);
    }
}
