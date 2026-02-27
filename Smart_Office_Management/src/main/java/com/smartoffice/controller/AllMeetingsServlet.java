package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.model.Meeting;

@SuppressWarnings("serial")
@WebServlet("/allMeetings")
public class AllMeetingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String manager = (String) request.getSession().getAttribute("username");

        MeetingDao dao = new MeetingDao();
        List<Meeting> meetings = dao.getTodayMeetingsForManager(manager);

        request.setAttribute("allMeetings", meetings);
        request.getRequestDispatcher("/allMeetings.jsp")
               .forward(request, response);
    }
}