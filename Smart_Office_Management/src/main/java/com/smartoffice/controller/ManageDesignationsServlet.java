package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.DesignationDAO;

@SuppressWarnings("serial")
@WebServlet("/manageDesignations")
public class ManageDesignationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !"admin".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        resp.setContentType("application/json");
        try {
            DesignationDAO dao = new DesignationDAO();
            List<String> list = dao.getActiveDesignations();
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            for (String d : list) {
                if (!first) json.append(",");
                json.append("\"").append(escapeJson(d)).append("\"");
                first = false;
            }
            json.append("]");
            resp.getWriter().write(json.toString());
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !"admin".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=accessDenied");
            return;
        }

        String action = req.getParameter("action");
        String name = req.getParameter("name");

        try {
            DesignationDAO dao = new DesignationDAO();
            if ("deactivate".equalsIgnoreCase(action)) {
                dao.deactivateDesignation(name);
                resp.sendRedirect(req.getContextPath() + "/adminSettingsPage.jsp?success=DesignationRemoved");
            } else {
                dao.addDesignation(name);
                resp.sendRedirect(req.getContextPath() + "/adminSettingsPage.jsp?success=DesignationAdded");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", e.getMessage() != null ? e.getMessage() : "Failed to update designations");
            resp.sendRedirect(req.getContextPath() + "/adminSettingsPage.jsp?error=DesignationFailed");
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\\\", "\\\\\\\\").replace("\"", "\\\\\"");
    }
}

