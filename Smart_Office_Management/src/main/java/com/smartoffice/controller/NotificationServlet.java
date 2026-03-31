package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("serial")
@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        PrintWriter out = response.getWriter();

        // Example JSON (replace with DB data)
        String json = "[{\"message\":\"New task assigned\"}]";

        out.print(json);
        out.flush();
    }
}