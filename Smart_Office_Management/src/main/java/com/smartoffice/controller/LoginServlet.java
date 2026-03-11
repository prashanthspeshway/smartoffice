package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;
import com.smartoffice.utils.PasswordUtil;

@SuppressWarnings("serial")
@WebServlet("/Login")
public class LoginServlet extends HttpServlet {

    private boolean isStrongPassword(String password) {
        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
        return password != null && password.matches(regex);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String emailOrUsername = req.getParameter("email");
        String password = req.getParameter("password");

        if (!isStrongPassword(password)) {
            res.sendRedirect("index.html?error=weakPassword");
            return;
        }

        try (Connection con = DBConnectionUtil.getConnection()) {

            String sql = "SELECT email,password,role,status,firstname,lastname FROM users WHERE email=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, emailOrUsername);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dbPassword = rs.getString("password");
                String role = rs.getString("role");
                String status = rs.getString("status");
                String email = rs.getString("email");

                if (!PasswordUtil.checkPassword(password, dbPassword)) {
                    res.sendRedirect("index.html?error=invalid");
                    return;
                }

                if (!"active".equalsIgnoreCase(status)) {
                    res.sendRedirect("index.html?error=inactive");
                    return;
                }

                String first = rs.getString("firstname");
                String last = rs.getString("lastname");
                String fullName = ((first != null ? first.trim() : "") + " " + (last != null ? last.trim() : "")).trim();
                if (fullName.isEmpty()) fullName = email;

                // Invalidate any existing session so only one login is active per browser
                HttpSession existingSession = req.getSession(false);
                if (existingSession != null) {
                    existingSession.invalidate();
                }

                HttpSession session = req.getSession(true);
                session.setAttribute("username", email);
                session.setAttribute("email", email);
                session.setAttribute("fullName", fullName);
                session.setAttribute("role", role);
                session.setAttribute("sessionToken", UUID.randomUUID().toString());

                switch (role.toLowerCase()) {
                    case "user":
                    case "employee":
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
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }
}