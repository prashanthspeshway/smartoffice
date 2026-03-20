package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.smartoffice.utils.DBConnectionUtil;

public class PerformanceDAO {
	
	/**
	 * Converts email to username for database operations
	 * The system uses email in sessions/forms but username (full name) in database foreign keys
	 */
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
	
	/**
	 * Save performance rating for an employee
	 * @param employeeEmail - Employee's email address
	 * @param managerEmail - Manager's email address
	 * @param rating - Performance rating (EXCELLENCE, GOOD, AVERAGE, BELOW_AVERAGE)
	 * @param month - Performance month (first day of month)
	 * @return true if saved successfully, false otherwise
	 */
	public boolean savePerformance(String employeeEmail,
	                               String managerEmail,
	                               String rating,
	                               Date month) {
		
		// Convert emails to usernames for database storage
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
			// Duplicate employee + month
			return false;
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * Check if performance rating already exists for employee in given month
	 * @param employeeEmail - Employee's email address
	 * @param month - Performance month
	 * @return true if exists, false otherwise
	 */
	public boolean performanceExists(String employeeEmail, Date month) {
		// Convert email to username
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
			return false; // Don't block insert on error
		}
	}
}