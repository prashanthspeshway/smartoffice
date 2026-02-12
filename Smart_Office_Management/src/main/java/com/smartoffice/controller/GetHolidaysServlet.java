package com.smartoffice.controller;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@WebServlet("/getHolidays")
public class GetHolidaysServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        try {
            Connection con = DBConnectionUtil.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "SELECT holiday_date, holiday_name FROM holidays");

            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            while(rs.next()){
                if(!first) json.append(",");
                json.append("{");
                json.append("\"date\":\"").append(rs.getDate("holiday_date")).append("\",");
                json.append("\"name\":\"").append(rs.getString("holiday_name")).append("\"");
                json.append("}");
                first = false;
            }
            json.append("]");

            response.getWriter().write(json.toString());

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}
