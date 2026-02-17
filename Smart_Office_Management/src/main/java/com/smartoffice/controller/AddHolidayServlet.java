package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@WebServlet("/addHoliday")
public class AddHolidayServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String date = request.getParameter("date");
        String name = request.getParameter("name");

        if(date == null || date.isEmpty()){
            response.getWriter().write("Date missing");
            return;
        }

        java.sql.Date sqlDate = java.sql.Date.valueOf(date);
      
     //  Blocking past dates
     java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
     if (sqlDate.compareTo(today) < 0) {
         response.getWriter().write("Past date not allowed");
         return;
     }

       
        // Preventing  past dates
        if(sqlDate.before(today)){
            response.getWriter().write("Cannot add past holiday");
            return;
        }

        try(Connection con = DBConnectionUtil.getConnection()) {

            //  Prevent duplicate
            PreparedStatement check = con.prepareStatement(
                    "SELECT 1 FROM holidays WHERE holiday_date=?");
            check.setDate(1, sqlDate);
            ResultSet rs = check.executeQuery();

            if(rs.next()){
                response.getWriter().write("Holiday already exists");
                return;
            }

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

