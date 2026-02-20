package com.smartoffice.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.PerformanceDAO;

@SuppressWarnings("serial")
@WebServlet("/submitPerformance")
public class PerformanceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String employee = req.getParameter("employee");
        String rating = req.getParameter("rating");

        HttpSession session = req.getSession();
        String manager = (String) session.getAttribute("username");

        // Validation
        if (employee == null || rating == null) {
            resp.sendRedirect("manager?tab=performance&error=Invalid");
            return;
        }

        PerformanceDAO dao = new PerformanceDAO();
        boolean saved = dao.savePerformance(employee, manager, rating);

        if (saved) {
            resp.sendRedirect("manager?tab=performance&success=PerformanceSaved");
        } else {
            resp.sendRedirect("manager?tab=performance&error=DBError");
        }
    }
}