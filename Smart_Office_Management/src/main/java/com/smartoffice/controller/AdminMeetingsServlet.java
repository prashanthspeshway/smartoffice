package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/adminMeetings")
public class AdminMeetingsServlet extends HttpServlet {

 protected void doGet(HttpServletRequest req, HttpServletResponse resp)
 throws ServletException, IOException {

  List<User> users = UserDao.getAllUsers();

  req.setAttribute("users", users);

  req.getRequestDispatcher("adminMeetings.jsp").forward(req, resp);
 }
}