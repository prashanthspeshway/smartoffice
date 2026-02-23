package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.smartoffice.utils.DBConnectionUtil;

public class PerformanceDAO {

    public boolean savePerformance(String employeeUsername,
                                   String managerUsername,
                                   String rating,
                                   Date month) {

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

            ps.executeUpdate();
            return true;

        } catch (SQLIntegrityConstraintViolationException e) {
            // Duplicate employee + month → expected business rule
            return false;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean performanceExists(String employeeUsername, Date month) {

        String sql =
            "SELECT 1 FROM employee_performance " +
            "WHERE employee_username = ? AND performance_month = ?";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, employeeUsername);
            ps.setDate(2, month);

            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false; // never block insert on failure
        }
    }
}