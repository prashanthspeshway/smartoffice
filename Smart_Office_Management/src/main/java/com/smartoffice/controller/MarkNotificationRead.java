package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/markNotificationRead")
public class MarkNotificationRead extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}

		int notificationId = Integer.parseInt(req.getParameter("id"));
		String username = (String) session.getAttribute("username");

		String sql = """
				    INSERT IGNORE INTO notification_reads (notification_id, username)
				    VALUES (?, ?)
				""";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, notificationId);
			ps.setString(2, username);
			ps.executeUpdate();

			res.setStatus(HttpServletResponse.SC_OK);

		} catch (Exception e) {
			e.printStackTrace();
			res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}