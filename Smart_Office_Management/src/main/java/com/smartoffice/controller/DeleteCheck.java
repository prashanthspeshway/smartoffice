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
@WebServlet("/deletecheck")
public class DeleteCheck extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        boolean deleted = false;

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM users WHERE username = ?"
            )
        ) {
            ps.setString(1, username);
            int rows = ps.executeUpdate();
            deleted = rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (deleted) {
            res.sendRedirect("deleteUser.jsp?msg=UserDeleted");
        } else {
            res.sendRedirect("deleteUser.jsp?error=DeleteFailed");
        }
    }
}
