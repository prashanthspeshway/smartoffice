package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.smartoffice.utils.DBConnectionUtil;

public class PerformanceDAO {
	
	private String getUsernameFromEmail(String email) {
		String sql = "SELECT username FROM users WHERE email = ?";
		
		try (Connection con = DBConnectionUtil.getConnection();
		     PreparedStatement ps = con.prepareStatement(sql)) {
			
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			
			if (rs.next()) {
				return rs.getString("username");
			} else {
				return email; // fallback
			}
			
		} catch (SQLException e) {
			e.printStackTrace();
			return email; // fallback
		}
	}
	
	public boolean savePerformance(String employeeEmail,
	                               String managerEmail,
	                               String rating,
	                               Date month) {
		
		String employeeUsername = getUsernameFromEmail(employeeEmail);
		String managerUsername = getUsernameFromEmail(managerEmail);
		
		String sql =
			"INSERT INTO employee_performance " +
			"(employee_username, manager_username, rating, performance_month) " +
			"VALUES (?, ?, ?, ?)";
		
		try (Connection con = DBConnectionUtil.getConnection();
		     PreparedStatement ps = con.prepareStatement(sql)) {
			
			ps.setString(1, employeeUsername);
			ps.setString(2, managerUsername);
			ps.setString(3, rating);
			ps.setDate(4, month);
			
			int rowsAffected = ps.executeUpdate();
			return rowsAffected > 0;
			
		} catch (SQLIntegrityConstraintViolationException e) {
			return false;
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean performanceExists(String employeeEmail, Date month) {
		String employeeUsername = getUsernameFromEmail(employeeEmail);
		
		String sql =
			"SELECT 1 FROM employee_performance " +
			"WHERE employee_username = ? AND performance_month = ?";
		
		try (Connection con = DBConnectionUtil.getConnection();
		     PreparedStatement ps = con.prepareStatement(sql)) {
			
			ps.setString(1, employeeUsername);
			ps.setDate(2, month);
			ResultSet rs = ps.executeQuery();
			
			return rs.next();
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
}