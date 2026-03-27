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
@WebServlet("/deleteUser")
public class DeleteUser extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));
        boolean success = false;

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps =
                     con.prepareStatement("DELETE FROM users WHERE id = ?")) {

            ps.setInt(1, id);
            int rows = ps.executeUpdate();

            if (rows > 0) {
                success = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        //  Redirect with toaster message flag
        if (success) {
            res.sendRedirect("viewUser?msg=deleted");
        } else {
            res.sendRedirect("viewUser?msg=error");
        }
    }
}
