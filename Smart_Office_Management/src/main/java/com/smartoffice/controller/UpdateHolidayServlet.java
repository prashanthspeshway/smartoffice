package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/updateHoliday")
public class UpdateHolidayServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String date = request.getParameter("date");
        String name = request.getParameter("name");

        try(Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                    "UPDATE holidays SET holiday_name=? WHERE holiday_date=?")) {

            ps.setString(1, name);
            ps.setDate(2, java.sql.Date.valueOf(date));

            ps.executeUpdate();

            response.getWriter().write("Holiday Updated");

        } catch(Exception e){
            e.printStackTrace();
            response.getWriter().write("Update Failed");
        }
    }
}
