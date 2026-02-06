package com.smartoffice.controller;
 
import java.io.IOException;

import java.sql.Connection;

import java.sql.Date;

import java.sql.PreparedStatement;
 
import javax.servlet.ServletException;

import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;

import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;
 
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")

@WebServlet("/addUser")

public class AddUser extends HttpServlet {
 
    @Override

    protected void doPost(HttpServletRequest req, HttpServletResponse res)

            throws ServletException, IOException {
 
        try {

            Connection con = DBConnectionUtil.getConnection();
 
            String manager1 = req.getParameter("manager");

            String sql = "INSERT INTO users "

            		
                       + "(username, password, role, status, email, fullname, joinedDate, manager) "

                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
 
            PreparedStatement ps = con.prepareStatement(sql);
 
            ps.setString(1, req.getParameter("username"));

            ps.setString(2, req.getParameter("password"));

            ps.setString(3, req.getParameter("role"));

            ps.setString(4, req.getParameter("status"));

            ps.setString(5, req.getParameter("email"));

            ps.setString(6, req.getParameter("fullname"));

            ps.setDate(7, Date.valueOf(req.getParameter("joinedDate")));

            ps.setString(8, manager1);
            
 
            ps.executeUpdate();
 
            req.getSession().setAttribute("successMsg", "User added successfully!");
 
           // System.out.println(manager1);

            res.sendRedirect("addUser.jsp");
 
        } catch (Exception e) {

            e.printStackTrace();

            req.getSession().setAttribute("errorMsg", "Failed to add user!");

            res.sendRedirect("addUser.jsp");

        }

    }

}

 