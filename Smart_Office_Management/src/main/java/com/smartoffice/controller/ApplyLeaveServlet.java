package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/applyLeave")
public class ApplyLeaveServlet extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendRedirect(request.getContextPath() + "/index.html");
			return;
		}

		String username = (String) session.getAttribute("username");

		String leaveType = request.getParameter("leaveType");
		String fromDate = request.getParameter("fromDate");
		String toDate = request.getParameter("toDate");
		String reason = request.getParameter("reason");

		try (Connection con = DBConnectionUtil.getConnection()) {

			String sql = "INSERT INTO leave_requests " + "(username, leave_type, from_date, to_date, reason, status) "
					+ "VALUES (?, ?, ?, ?, ?, 'PENDING')";

			PreparedStatement ps = con.prepareStatement(sql);
			ps.setString(1, username);
			ps.setString(2, leaveType);
			ps.setDate(3, Date.valueOf(fromDate));
			ps.setDate(4, Date.valueOf(toDate));
			ps.setString(5, reason);

			ps.executeUpdate();

			// redirect back to SAME page
			response.sendRedirect(request.getContextPath() + "/user?tab=leave&success=LeaveApplied");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect(request.getContextPath() + "/user?tab=leave&error=LeaveFailed");
		}
	}
}
