package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.AdminDAO;

@SuppressWarnings("serial")
@WebServlet("/adminOverview")
public class AdminOverviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            AdminDAO dao = new AdminDAO();

            int managers = dao.getManagerCount();
            int employees = dao.getEmployeeCount();
            int totalStaff = managers + employees;
            int presentToday = dao.getPresentTodayCount();
            int absentToday = dao.getAbsentTodayCount();

            request.setAttribute("managers", managers);
            request.setAttribute("employees", employees);
            request.setAttribute("totalStaff", totalStaff);
            request.setAttribute("presentToday", presentToday);
            request.setAttribute("absentToday", absentToday);

            // ✅ FIX: holidays
            request.setAttribute("holidays", dao.getUpcomingHolidays());

            request.getRequestDispatcher("adminOverview.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading admin overview", e);
        }
    }
}