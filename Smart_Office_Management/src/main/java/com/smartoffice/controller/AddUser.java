package com.smartoffice.controller;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/addUser")
public class AddUser extends HttpServlet{
	
	public void doPost(HttpServletRequest req, HttpServletResponse res) {

		String username = req.getParameter("username");
		String password = req.getParameter("password");
		String role = req.getParameter("role");
		String status = req.getParameter("status");
		String email = req.getParameter("email");
		String fullname = req.getParameter("fullname");
		Date joinedDate = Date.valueOf(req.getParameter("joinedDate"));
		
		try {
			Connection con = DBConnectionUtil.getConnection();
			
			String qry = "INSERT INTO users (username, password, role, status, email, fullname, joinedDate) VALUES (?, ?, ?, ?, ?, ?, ?)";
			
			PreparedStatement ps = con.prepareStatement(qry);
			
			ps.setString(1,  username);
			ps.setString(2,  password);
			ps.setString(3,  role);
			ps.setString(4,  status);
			ps.setString(5,  email);
			ps.setString(6,  fullname);
			ps.setDate(7,  joinedDate);
			
			ps.executeUpdate();
			System.out.println("User added successfully");
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
	}
	
}
