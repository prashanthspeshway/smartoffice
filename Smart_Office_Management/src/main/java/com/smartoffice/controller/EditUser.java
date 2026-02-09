package com.smartoffice.controller;

import java.io.IOException;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/editUser")
public class EditUser extends HttpServlet {

    // =========================
    // LOAD USER (GET)
    // =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT * FROM users WHERE id=?")) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                req.setAttribute("id", id);
                req.setAttribute("username", rs.getString("username"));
                req.setAttribute("role", rs.getString("role"));
                req.setAttribute("status", rs.getString("status"));
                req.setAttribute("fullname", rs.getString("fullname"));
                req.setAttribute("email", rs.getString("email"));
                req.setAttribute("joinedDate", rs.getDate("joinedDate"));
                req.setAttribute("manager", rs.getString("manager"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("editUser.jsp").forward(req, res);
    }

    // =========================
    // UPDATE USER (POST)
    // =========================
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
