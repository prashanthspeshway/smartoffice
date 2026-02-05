package com.smartoffice.controller;

import java.io.IOException;
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
@WebServlet("/editUserDetails")
public class EditUserDetails extends HttpServlet{
	
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
		
		String role = req.getParameter("role");
		String fullname = req.getParameter("fullname");
		String email = req.getParameter("email");
		Date joinedDate = Date.valueOf(req.getParameter("joinedDate"));
		
		try {
			
			Connection con = DBConnectionUtil.getConnection();
			
			String qry = "UPDATE users SET role = ?, fullname = ?, email = ?, joinedDate = ? WHERE username = ?";
			
			PreparedStatement ps = con.prepareStatement(qry);
			
			ps.setString(1,  role);
			ps.setString(2,  fullname);
			ps.setString(3,  email);
			ps.setDate(4,  joinedDate);
			ps.setString(5,  req.getParameter("username"));
			
			ps.executeUpdate();
			System.out.println("User details updated successfully");
			
			con.close();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
				
	}
}
