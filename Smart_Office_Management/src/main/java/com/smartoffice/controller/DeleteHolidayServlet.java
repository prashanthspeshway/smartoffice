package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@WebServlet("/deleteHoliday")
public class DeleteHolidayServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
    	String date = request.getParameter("date");
    	java.sql.Date sqlDate = java.sql.Date.valueOf(date);

    	java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
    	if (sqlDate.compareTo(today) < 0) {
    	    response.getWriter().write("Cannot delete past holiday");
    	    return;
    	}


        try(Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM holidays WHERE holiday_date=?")) {

            ps.setDate(1, java.sql.Date.valueOf(date));

            ps.executeUpdate();
            response.setContentType("text/plain");
            response.getWriter().write("Holiday Deleted");

        } catch(Exception e){
            e.printStackTrace();
            
           

        }
    }
}
