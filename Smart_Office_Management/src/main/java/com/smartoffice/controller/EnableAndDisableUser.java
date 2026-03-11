package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/enableanddisable")
public class EnableAndDisableUser extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String status = req.getParameter("status");

        boolean updated = false;
        try {
            Connection con = DBConnectionUtil.getConnection();
            String sql = "UPDATE users SET status = ? WHERE email = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, email);

            int rows = ps.executeUpdate();
            updated = rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ✅ Redirect with message for toast popup
        if (updated) {
            res.sendRedirect(
                req.getContextPath() +
                "/toggleUserStatus.jsp?msg=User_" + status
            );
        } else {
            res.sendRedirect(
                req.getContextPath() +
                "/toggleUserStatus.jsp?error=UpdateFailed"
            );
        }
    }
}
