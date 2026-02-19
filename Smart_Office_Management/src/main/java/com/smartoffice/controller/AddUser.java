package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/addUser")
public class AddUser extends HttpServlet {

    private boolean isStrongPassword(String password) {
        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
        return password != null && password.matches(regex);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String password = req.getParameter("password");
        String role = req.getParameter("role");
        String manager = req.getParameter("manager");

        // 🔐 Password validation
        if (!isStrongPassword(password)) {
            req.getSession().setAttribute(
                "errorMsg",
                "Password must be at least 8 characters with uppercase, lowercase, number, and symbol."
            );
            res.sendRedirect("addUser");
            return;
        }

        // ✅ Business rule validation
        if ("user".equalsIgnoreCase(role) && (manager == null || manager.isEmpty())) {
            req.getSession().setAttribute(
                "errorMsg",
                "Please select a manager for the user."
            );
            res.sendRedirect("addUser");
            return;
        }

        // Managers should not have managers
        if ("manager".equalsIgnoreCase(role)) {
            manager = null;
        }

        try (Connection con = DBConnectionUtil.getConnection()) {

            String sql = "INSERT INTO users " +
                    "(username, password, role, status, email, fullname, joinedDate, manager, phone) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, req.getParameter("username"));
            ps.setString(2, password);
            ps.setString(3, role);
            ps.setString(4, req.getParameter("status"));
            ps.setString(5, req.getParameter("email"));
            ps.setString(6, req.getParameter("fullname"));
            ps.setDate(7, Date.valueOf(req.getParameter("joinedDate")));
            ps.setString(8, manager);
            ps.setString(9, req.getParameter("phonenumber"));

            ps.executeUpdate();

            req.getSession().setAttribute("successMsg", "User added successfully!");
            res.sendRedirect("addUser");

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Failed to add user!");
            res.sendRedirect("addUser");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        try (Connection con = DBConnectionUtil.getConnection()) {

            String sql = "SELECT username FROM users " +
                         "WHERE LOWER(TRIM(role)) = 'manager' " +
                         "AND LOWER(TRIM(status)) = 'active'";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<String> managers = new ArrayList<>();

            while (rs.next()) {
                managers.add(rs.getString("username"));
            }

            req.setAttribute("managers", managers);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ✅ Forward to JSP (NOT servlet)
        req.getRequestDispatcher("addUser.jsp").forward(req, res);
    }
}
