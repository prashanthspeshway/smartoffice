package com.smartoffice.controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

        List<String> managers = new ArrayList<>();

        try (Connection con = DBConnectionUtil.getConnection()) {

            // 🔹 Load user details
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM users WHERE id=?")) {

                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    req.setAttribute("id", id);
                    req.setAttribute("username", rs.getString("username"));
                    req.setAttribute("role", rs.getString("role"));
                    req.setAttribute("status", rs.getString("status"));
                    req.setAttribute("fullname", rs.getString("fullname"));
                    req.setAttribute("password", rs.getString("password"));
                    req.setAttribute("phone", rs.getString("phone"));
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("joinedDate", rs.getDate("joinedDate"));
                    req.setAttribute("manager", rs.getString("manager"));
                }
            }

            // 🔹 Load managers list
            try (PreparedStatement ps2 = con.prepareStatement(
                    "SELECT username FROM users WHERE role='manager' AND status='active'")) {

                ResultSet rs2 = ps2.executeQuery();
                while (rs2.next()) {
                    managers.add(rs2.getString("username"));
                }
            }

            req.setAttribute("managers", managers);

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
        String phone = req.getParameter("number");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String manager = req.getParameter("manager");
        String joinedDateStr = req.getParameter("joinedDate");

        // 🔒 If role is manager, clear manager field

        if ("manager".equalsIgnoreCase(role)) {
            manager = "";
        }

        if (manager == null || manager.trim().isEmpty()) {
            manager = "";
        }

        Date joinedDate = null;
        if (joinedDateStr != null && !joinedDateStr.isEmpty()) {
            joinedDate = Date.valueOf(joinedDateStr);
        }

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE users SET role=?, status=?, fullname=?, email=?, joinedDate=?, manager=?, password=?, phone=? WHERE id=?")) {

            ps.setString(1, role);
            ps.setString(2, status);
            ps.setString(3, fullname);
            ps.setString(4, email);
            ps.setDate(5, joinedDate);
            ps.setString(6, manager);
            ps.setString(7, password);
            ps.setString(8, phone);
            ps.setInt(9, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        res.sendRedirect("viewUser?msg=updated");
    }
}