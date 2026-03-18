package com.smartoffice.controller;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;
import com.smartoffice.utils.PasswordUtil;

@SuppressWarnings("serial")
@WebServlet("/Login")
public class LoginServlet extends HttpServlet {

    private static String generateRememberToken() {
        SecureRandom sr = new SecureRandom();
        byte[] bytes = new byte[32];
        sr.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    static boolean isStrongPassword(String password) {
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

                // Remember me: set cookie for persistent login (survives server restarts)
                if ("on".equalsIgnoreCase(req.getParameter("remember")) || "true".equalsIgnoreCase(req.getParameter("remember"))) {
                    try {
                        String token = generateRememberToken();
                        long expiresMs = System.currentTimeMillis() + (7L * 24 * 60 * 60 * 1000); // 7 days
                        java.sql.Timestamp expiresAt = new java.sql.Timestamp(expiresMs);
                        try (PreparedStatement ins = con.prepareStatement("INSERT INTO remember_tokens (token, email, expires_at) VALUES (?, ?, ?)")) {
                            ins.setString(1, token);
                            ins.setString(2, email);
                            ins.setTimestamp(3, expiresAt);
                            ins.executeUpdate();
                        }
                        Cookie c = new Cookie("remember_token", token);
                        c.setMaxAge(7 * 24 * 60 * 60); // 7 days
                        c.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                        c.setHttpOnly(true);
                        res.addCookie(c);
                    } catch (Exception e) {
                        e.printStackTrace(); // remember_tokens table may not exist; continue without
                    }
                }

                switch (role.toLowerCase()) {
                    case "user":
                    case "employee":
                    case "security":
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