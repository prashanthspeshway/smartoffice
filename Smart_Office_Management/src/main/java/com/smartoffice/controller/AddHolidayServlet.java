package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@WebServlet("/addHoliday")
public class AddHolidayServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String date = request.getParameter("date");
        String name = request.getParameter("name");
        if(date == null || date.isEmpty()){
            response.getWriter().write("Date missing");
            return;
        }

        java.sql.Date sqlDate = java.sql.Date.valueOf(date);

        try {
            Connection con = DBConnectionUtil.getConnection();

            PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO holidays (holiday_date, holiday_name) VALUES(?, ?)");

            ps.setDate(1, sqlDate);  

            ps.setString(2, name);

            ps.executeUpdate();

            response.getWriter().write("Holiday Added Successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error adding holiday");
        }
    }
}
