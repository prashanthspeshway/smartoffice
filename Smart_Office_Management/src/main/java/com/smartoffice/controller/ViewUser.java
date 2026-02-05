package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/viewUser")
public class ViewUser extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        StringBuilder rows = new StringBuilder();

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM users");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                int userId = rs.getInt("id");
                String status = rs.getString("status");

                rows.append("<tr>")

                    .append("<td>").append(rs.getString("username")).append("</td>")
                    .append("<td>").append(rs.getString("role")).append("</td>")

                    // Status badge
                    .append("<td>")
                        .append("<span class='badge ")
                        .append(status.equalsIgnoreCase("active") ? "active" : "inactive")
                        .append("'>")
                        .append(status)
                        .append("</span>")
                    .append("</td>")

                    .append("<td>").append(rs.getString("fullname")).append("</td>")
                    .append("<td>").append(rs.getString("email")).append("</td>")
                    .append("<td>").append(rs.getDate("joinedDate")).append("</td>")

                    // ICON ACTIONS
                    .append("<td class='actions'>")

                    	.append("<a href='editUser?id=").append(userId)
                        .append("' class='icon-btn edit' title='Edit User'>")
                        .append("<i class='fa-solid fa-pen'></i></a>")

                        .append("<a href='deleteUser?id=").append(userId)
                        .append("' class='icon-btn delete' title='Delete User' ")
                        .append("onclick=\"return confirm('Are you sure you want to delete this user?');\">")
                        .append("<i class='fa-solid fa-trash'></i></a>")

                    .append("</td>")

                .append("</tr>");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("rows", rows.toString());
        req.getRequestDispatcher("viewUser.jsp").forward(req, res);
    }
}
