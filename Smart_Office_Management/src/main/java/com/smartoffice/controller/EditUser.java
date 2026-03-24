package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.DesignationDAO;
import com.smartoffice.utils.DBConnectionUtil;
import com.smartoffice.utils.PasswordUtil;
import com.smartoffice.utils.UserFieldUtil;

@SuppressWarnings("serial")
@WebServlet("/editUser")
public class EditUser extends HttpServlet {

    private static boolean isStrongPassword(String password) {
        if (password == null) {
            return false;
        }
        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$");
    }

    // =========================
    // LOAD USER (GET)
    // =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection con = DBConnectionUtil.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id, email, firstname, lastname, designation, role, status, phone, joinedDate FROM users WHERE id=?")) {
                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String roleVal = rs.getString("role");
                    String statusVal = rs.getString("status");
                    req.setAttribute("id", id);
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("role", ("user".equalsIgnoreCase(roleVal != null ? roleVal.trim() : "") ? "employee" : roleVal));
                    req.setAttribute("status", (statusVal != null && statusVal.trim().equalsIgnoreCase("active")) ? "active" : "inactive");
                    req.setAttribute("firstname", rs.getString("firstname"));
                    req.setAttribute("lastname", rs.getString("lastname"));
                    req.setAttribute("designation", rs.getString("designation"));
                    req.setAttribute("phone", rs.getString("phone"));
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("joinedDate", rs.getDate("joinedDate"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            req.setAttribute("designations", new DesignationDAO().getActiveDesignations());
        } catch (Exception ignored) {}

        req.getRequestDispatcher("editUser.jsp").forward(req, res);
    }

    // =========================
    // UPDATE USER (POST)
    // =========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        int id = Integer.parseInt(req.getParameter("id"));
        String role = UserFieldUtil.normalizeRole(req.getParameter("role"));
        String status = UserFieldUtil.normalizeStatus(req.getParameter("status"));
        String firstname = req.getParameter("firstname");
        String lastname = req.getParameter("lastname");
        String designation = req.getParameter("designation");
        String phone = req.getParameter("number");
        if (phone != null) {
            phone = phone.replaceAll("[^0-9]", "").trim();
            if (phone.length() > 10) phone = phone.substring(0, 10);
        }
        String email = req.getParameter("email");
        String joinedDateStr = req.getParameter("joinedDate");
        String newPassword = req.getParameter("newPassword");
        String confirmNewPassword = req.getParameter("confirmNewPassword");

        Date joinedDate = null;
        if (joinedDateStr != null && !joinedDateStr.isEmpty()) {
            joinedDate = Date.valueOf(joinedDateStr);
        }

        // Username = firstname + lastname (fallback to email if empty)

        try (Connection con = DBConnectionUtil.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE users SET role=?, status=?, firstname=?, lastname=?, designation=?, email=?, joinedDate=?, phone=? WHERE id=?")) {
            ps.setString(1, role);
            ps.setString(2, status);
            ps.setString(3, firstname);
            ps.setString(4, lastname);
            ps.setString(5, designation);
            ps.setString(6, email);
            ps.setDate(7, joinedDate);
            ps.setString(8, phone);
            ps.setInt(9, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("editUserError", "Could not save employee details.");
            res.sendRedirect(req.getContextPath() + "/editUser?id=" + id);
            return;
        }

        // Optional: admin sets a new password (employees and managers)
        if (newPassword != null && !newPassword.isBlank()) {
            if (confirmNewPassword == null || !newPassword.equals(confirmNewPassword)) {
                req.getSession().setAttribute("editUserError", "New password and confirmation do not match.");
                res.sendRedirect(req.getContextPath() + "/editUser?id=" + id);
                return;
            }
            if (!isStrongPassword(newPassword)) {
                req.getSession().setAttribute("editUserError",
                        "Password must be at least 8 characters with uppercase, lowercase, number, and symbol (@$!%*?&).");
                res.sendRedirect(req.getContextPath() + "/editUser?id=" + id);
                return;
            }
            try (Connection con = DBConnectionUtil.getConnection();
                    PreparedStatement ps = con.prepareStatement("UPDATE users SET password=? WHERE id=?")) {
                ps.setString(1, PasswordUtil.hashPassword(newPassword));
                ps.setInt(2, id);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("editUserError", "Could not update password.");
                res.sendRedirect(req.getContextPath() + "/editUser?id=" + id);
                return;
            }
        }

        res.sendRedirect(req.getContextPath() + "/viewUser?msg=updated");
    }
}