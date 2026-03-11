package com.smartoffice.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/exportUsers")
public class ExportUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("text/csv");
        resp.setHeader(
            "Content-Disposition",
            "attachment; filename=users.csv"
        );

        PrintWriter out = resp.getWriter();
        out.println("ID,Email,Role,Status,Firstname,Lastname");

        List<User> users = UserDao.getAllUsers();

        for (User u : users) {
            out.println(
                u.getId() + "," +
                u.getEmail() + "," +
                u.getRole() + "," +
                u.getStatus() + "," +
                (u.getFirstname() != null ? u.getFirstname() : "") + "," +
                (u.getLastname() != null ? u.getLastname() : "")
            );
        }

        out.flush();
    }
}
