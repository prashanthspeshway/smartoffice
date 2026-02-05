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

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        StringBuilder rows = new StringBuilder();

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM users");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rows.append("<tr>")
                    .append("<td>").append(rs.getInt("id")).append("</td>")
                    .append("<td>").append(rs.getString("username")).append("</td>")
                    .append("<td>").append(rs.getString("role")).append("</td>")
                    .append("<td>").append(rs.getString("status")).append("</td>")
                    .append("</tr>");
            }

            req.setAttribute("rows", rows.toString());
            req.getRequestDispatcher("viewUser.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
