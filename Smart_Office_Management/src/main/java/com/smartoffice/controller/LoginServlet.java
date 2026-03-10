package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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

            String sql = "SELECT username,email,password,role,status FROM users WHERE email=? OR username=?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, emailOrUsername);
            ps.setString(2, emailOrUsername);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                String dbPassword = rs.getString("password");
                String role = rs.getString("role");
                String status = rs.getString("status");
                String username = rs.getString("username");
                String email = rs.getString("email");

                // 🔐 BCrypt password verification
                if (!PasswordUtil.checkPassword(password, dbPassword)) {
                    res.sendRedirect("index.html?error=invalid");
                    return;
                }

                if (!"active".equalsIgnoreCase(status)) {
                    res.sendRedirect("index.html?error=inactive");
                    return;
                }

                HttpSession session = req.getSession();
                session.setAttribute("username", username);
                session.setAttribute("email", email);
                session.setAttribute("role", role);

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
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }
}