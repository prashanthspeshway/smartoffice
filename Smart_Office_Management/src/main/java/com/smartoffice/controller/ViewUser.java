package com.smartoffice.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/viewUser")
public class ViewUser extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		int page = 1;
		int limit = 7;

		if (req.getParameter("page") != null) {
			page = Integer.parseInt(req.getParameter("page"));
		}

		int offset = (page - 1) * limit;

		StringBuilder rows = new StringBuilder();
		int totalUsers = 0;

		try (Connection con = DBConnectionUtil.getConnection()) {

			// Get paginated users
			PreparedStatement ps = con.prepareStatement("SELECT * FROM users LIMIT ? OFFSET ?");
			ps.setInt(1, limit);
			ps.setInt(2, offset);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				int userId = rs.getInt("id");
				String status = rs.getString("status");

				rows.append("<tr>").append("<td>").append(rs.getString("username")).append("</td>").append("<td>")
						.append(rs.getString("role")).append("</td>")

						.append("<td>").append("<span class='badge ")
						.append(status.equalsIgnoreCase("active") ? "active" : "inactive").append("'>").append(status)
						.append("</span>").append("</td>")

						.append("<td>").append(rs.getString("fullname")).append("</td>").append("<td>")
						.append(rs.getString("email")).append("</td>").append("<td>").append(rs.getDate("joinedDate"))
						.append("</td>")

						.append("<td class='actions'>").append("<a href='editUser?id=").append(userId)
						.append("' class='icon-btn edit'><i class='fa-solid fa-pen'></i></a>")
						.append("<a href='deleteUser?id=").append(userId).append("' class='icon-btn delete' ")
						.append("onclick=\"return confirm('Delete user?');\">")
						.append("<i class='fa-solid fa-trash'></i></a>").append("</td>").append("</tr>");
			}

			// Total count
			PreparedStatement countPs = con.prepareStatement("SELECT COUNT(*) FROM users");
			ResultSet countRs = countPs.executeQuery();
			if (countRs.next()) {
				totalUsers = countRs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		int totalPages = (int) Math.ceil((double) totalUsers / limit);

		req.setAttribute("rows", rows.toString());
		req.setAttribute("currentPage", page);
		req.setAttribute("totalPages", totalPages);

		req.getRequestDispatcher("viewUser.jsp").forward(req, res);
		return; // 🔥 ALWAYS STOP HERE
	}
}
