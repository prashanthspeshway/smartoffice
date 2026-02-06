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
            }
 
        } catch (Exception e) {
            e.printStackTrace();
        }
 
        req.getRequestDispatcher("editUser.jsp").forward(req, res);
    }
}