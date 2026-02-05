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
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");

        boolean userExists = false;

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT username FROM users WHERE username = ?"
            );
        ) {
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userExists = true;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect logic
        if (userExists) {
            res.sendRedirect("editUserDetails.jsp?username=" + username);
        } else {
            res.sendRedirect("editUserDetails.jsp?error=UserNotFound");
            System.out.println("User not found: " + username);
        }
    }
}
