package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.Performance;
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
                                   Date weekStart) {
        String employeeUsername = getUsernameFromEmail(employeeEmail);
        String managerUsername  = getUsernameFromEmail(managerEmail);

        String sql =
            "INSERT INTO employee_performance " +
            "(employee_username, manager_username, rating, performance_month) " +
            "VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, employeeUsername);
            ps.setString(2, managerUsername);
            ps.setString(3, rating);
            ps.setDate(4, weekStart);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns true if a rating already exists for the given employee
     * within the same ISO week (Monday–Sunday) as the provided weekStart date.
     */
    public boolean performanceExists(String employeeEmail, Date weekStart) {
        String employeeUsername = getUsernameFromEmail(employeeEmail);

        String sql =
            "SELECT 1 FROM employee_performance " +
            "WHERE employee_username = ? " +
            "  AND performance_month >= ? " +
            "  AND performance_month < DATE_ADD(?, INTERVAL 7 DAY)";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, employeeUsername);
            ps.setDate(2, weekStart);
            ps.setDate(3, weekStart);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all performance records from the database.
     * Used by AdminTasksServlet to pass to the JSP for display.
     */
    public List<Performance> getAllPerformances() {
        List<Performance> list = new ArrayList<>();
        String sql =
            "SELECT id, employee_username, manager_username, rating, " +
            "       performance_month, created_at " +
            "FROM employee_performance " +
            "ORDER BY performance_month ASC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Performance p = new Performance();
                p.setId(rs.getInt("id"));
                p.setEmployeeUsername(rs.getString("employee_username"));
                p.setManagerUsername(rs.getString("manager_username"));
                p.setRating(rs.getString("rating"));
                p.setPerformanceMonth(rs.getDate("performance_month"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}