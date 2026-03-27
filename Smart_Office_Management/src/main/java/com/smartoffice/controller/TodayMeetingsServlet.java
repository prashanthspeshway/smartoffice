package com.smartoffice.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.MeetingDao;
import com.smartoffice.model.Meeting;

@SuppressWarnings("serial")
@WebServlet("/todayMeetings")
public class TodayMeetingsServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			return;
		}

		String manager = (String) session.getAttribute("username");

		List<Meeting> meetings = MeetingDao.getTodayMeetings(manager);

		req.setAttribute("todayMeetings", meetings);
		req.setAttribute("tab", "schedulemeeting");

		req.getRequestDispatcher("/manager.jsp").forward(req, resp);
	}
}