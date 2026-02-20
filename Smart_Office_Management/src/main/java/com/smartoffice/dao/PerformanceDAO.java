package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

import com.smartoffice.utils.DBConnectionUtil;

public class PerformanceDAO {

	public boolean savePerformance(String employeeUsername, String managerUsername, String rating) {

		String sql = "INSERT INTO employee_performance " + "(employee_username, manager_username, rating) "
				+ "VALUES (?, ?, ?)";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, employeeUsername);
			ps.setString(2, managerUsername);
			ps.setString(3, rating);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}