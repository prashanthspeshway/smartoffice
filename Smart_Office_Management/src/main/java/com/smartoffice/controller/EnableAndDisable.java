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
public class EnableAndDisable extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String status = req.getParameter("status"); // active / inactive
        boolean updated = false;

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "UPDATE users SET status = ? WHERE username = ?"
            )
        ) {
            ps.setString(1, status);
            ps.setString(2, username);

            int rows = ps.executeUpdate();
            updated = rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (updated) {
            res.sendRedirect("admin.jsp?msg=User_" + status);
            System.out.println("User " + username + " set to " + status);
        } else {
            res.sendRedirect("editUser.jsp?error=UpdateFailed");
        }
    }
}
