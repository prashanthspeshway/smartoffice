package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TaskDAO;
import com.smartoffice.model.Task;

@SuppressWarnings("serial")
@WebServlet("/adminTasks")
public class AdminTasksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !"admin".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        try {
            List<Task> tasks = TaskDAO.getAllTasks();
            request.setAttribute("tasks", tasks);
        } catch (Exception e) {
            throw new ServletException("Unable to load tasks", e);
        }

        request.getRequestDispatcher("adminTasks.jsp").forward(request, response);
    }
}

