package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.model.Meeting;
import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/viewMeetings")
public class ViewMeetingsServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		List<Meeting> meetings = new ArrayList<>();

		// logged-in employee username
		String username = (String) request.getSession().getAttribute("username");

		if (username == null) {
			response.sendRedirect("index.html");
			return;
		}

		String sql = """
			    SELECT *
			    FROM meetings
			    WHERE created_by = (
			        SELECT manager
			        FROM users
			        WHERE username = ?
			    )
			    AND start_time >= NOW()
			    ORDER BY start_time
			""";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, username);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));

				meetings.add(m);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		request.setAttribute("meetings", meetings);
		request.getRequestDispatcher("user.jsp").forward(request, response);
	}
}
