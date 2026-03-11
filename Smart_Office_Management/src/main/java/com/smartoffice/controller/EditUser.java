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

        try (Connection con = DBConnectionUtil.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id, email, firstname, lastname, role, status, phone, joinedDate FROM users WHERE id=?")) {
                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    req.setAttribute("id", id);
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("role", rs.getString("role"));
                    req.setAttribute("status", rs.getString("status"));
                    req.setAttribute("firstname", rs.getString("firstname"));
                    req.setAttribute("lastname", rs.getString("lastname"));
                    req.setAttribute("phone", rs.getString("phone"));
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("joinedDate", rs.getDate("joinedDate"));
                }
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
        String firstname = req.getParameter("firstname");
        String lastname = req.getParameter("lastname");
        String phone = req.getParameter("number");
        if (phone != null) {
            phone = phone.replaceAll("[^0-9]", "").trim();
            if (phone.length() > 10) phone = phone.substring(0, 10);
        }
        String email = req.getParameter("email");
        String joinedDateStr = req.getParameter("joinedDate");

        Date joinedDate = null;
        if (joinedDateStr != null && !joinedDateStr.isEmpty()) {
            joinedDate = Date.valueOf(joinedDateStr);
        }

        // Username = firstname + lastname (fallback to email if empty)
        String username = ((firstname != null ? firstname : "") + " " + (lastname != null ? lastname : "")).trim();
        if (username.isEmpty()) username = email;

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE users SET username=?, role=?, status=?, firstname=?, lastname=?, email=?, joinedDate=?, phone=? WHERE id=?")) {
            ps.setString(1, username);
            ps.setString(2, role);
            ps.setString(3, status);
            ps.setString(4, firstname);
            ps.setString(5, lastname);
            ps.setString(6, email);
            ps.setDate(7, joinedDate);
            ps.setString(8, phone);
            ps.setInt(9, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        res.sendRedirect("viewUser?msg=updated");
    }
}