package com.smartoffice.controller;

import java.io.IOException;
import java.sql.*;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/editUserDetails")
public class EditUserDetails extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        int id = Integer.parseInt(req.getParameter("id"));
        String role = req.getParameter("role");
        String status = req.getParameter("status");
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String manager = req.getParameter("manager");
        String joinedDateStr = req.getParameter("joinedDate");

        Date joinedDate = null;
        if (joinedDateStr != null && !joinedDateStr.isEmpty()) {
            joinedDate = Date.valueOf(joinedDateStr);
        }

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE users SET role=?, status=?, fullname=?, email=?, joinedDate=?, manager=? WHERE id=?")) {

            ps.setString(1, role);
            ps.setString(2, status);
            ps.setString(3, fullname);
            ps.setString(4, email);
            ps.setDate(5, joinedDate);
            ps.setString(6, manager);
            ps.setInt(7, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        res.sendRedirect("viewUser");
    }
}
