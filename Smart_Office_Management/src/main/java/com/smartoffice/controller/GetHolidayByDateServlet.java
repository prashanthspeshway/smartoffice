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

@SuppressWarnings("serial")
@WebServlet("/getHolidayByDate")
public class GetHolidayByDateServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String date = request.getParameter("date");

        response.setContentType("application/json");

        try(Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                    "SELECT holiday_name FROM holidays WHERE holiday_date=?")) {

            ps.setDate(1, java.sql.Date.valueOf(date));
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                response.getWriter().write(
                        "{\"exists\":true,\"name\":\"" + rs.getString(1) + "\"}");
            } else {
                response.getWriter().write("{\"exists\":false}");
            }

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}
