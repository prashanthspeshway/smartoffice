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
import com.smartoffice.utils.PasswordUtil;

/**
 * One-time setup: Creates default admin user if no users exist.
 * Username: admin, Password: Admin@123
 * Access /initAdmin once after deploying, then remove or disable this servlet.
 */
@WebServlet("/initAdmin")
public class InitAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try (Connection con = DBConnectionUtil.getConnection()) {

            // Check if any user exists
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM users");
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next() && rs.getInt(1) == 0) {

                    String hash = PasswordUtil.hashPassword("Admin@123");
                    String sql = "INSERT INTO users (username, password, firstname, lastname, role, status, email) " +
                                 "VALUES ('System Administrator', ?, 'System', 'Administrator', 'admin', 'active', 'admin@smartoffice.com')";

                    try (PreparedStatement insert = con.prepareStatement(sql)) {
                        insert.setString(1, hash);
                        insert.executeUpdate();
                    }

                    res.getWriter().write("Admin user created. Username: admin, Password: Admin@123. Please change after first login.");
                } else {
                    res.getWriter().write("Admin already exists. No action taken.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.sendError(500, "Setup failed: " + e.getMessage());
        }
    }
}
