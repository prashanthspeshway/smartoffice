package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/exportTeamPerformance")
public class ExportTeamPerformanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            return;
        }

        String managerUsername = (String) session.getAttribute("username");

        resp.setContentType("text/csv");
        resp.setHeader(
            "Content-Disposition",
            "attachment; filename=team_performance.csv"
        );

        PrintWriter out = resp.getWriter();
        out.println("Employee Email,Rating,Performance Month");

        String sql =
            "SELECT employee_username, rating, performance_month " +
            "FROM employee_performance " +
            "WHERE manager_username = ? " +
            "ORDER BY performance_month DESC";

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, managerUsername);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                out.println(
                    rs.getString("employee_username") + "," +
                    rs.getString("rating") + "," +
                    rs.getDate("performance_month")
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        out.flush();
    }
}