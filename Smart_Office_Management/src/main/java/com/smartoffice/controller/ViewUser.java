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

	private static String nullToEmpty(String s) {
		return s != null ? s : "";
	}

	private static String fullName(String first, String last) {
		String f = first != null ? first.trim() : "";
		String l = last != null ? last.trim() : "";
		return (f + " " + l).trim();
	}

	private static String escapeHtml(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		int page = 1;
		int limit = 9;
		String search = req.getParameter("search");
		String roleFilter = req.getParameter("role");
		String sortBy = req.getParameter("sort");
		String sortOrder = req.getParameter("order");

		if (req.getParameter("page") != null) {
			try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (NumberFormatException e) {}
		}
		if (search == null) search = "";
		if (roleFilter == null) roleFilter = "";
		if (sortBy == null || sortBy.isEmpty()) sortBy = "fullname";
		if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "asc";

		// Validate sort column
		String orderColumn = "firstname";
		switch (sortBy.toLowerCase()) {
			case "role": orderColumn = "role"; break;
			case "status": orderColumn = "status"; break;
			case "email": orderColumn = "email"; break;
			case "date":
			case "joineddate": orderColumn = "joinedDate"; break;
			default: orderColumn = "firstname"; break;
		}
		if (!"desc".equalsIgnoreCase(sortOrder)) sortOrder = "asc";

		int offset = (page - 1) * limit;

		StringBuilder rows = new StringBuilder();
		int totalUsers = 0;

		try (Connection con = DBConnectionUtil.getConnection()) {

			StringBuilder where = new StringBuilder(" WHERE LOWER(role) != 'admin' ");
			StringBuilder countWhere = new StringBuilder(" WHERE LOWER(role) != 'admin' ");
			int paramIdx = 1;

			// Role filter
			if (roleFilter != null && !roleFilter.trim().isEmpty()) {
				where.append(" AND LOWER(role) = LOWER(?) ");
				countWhere.append(" AND LOWER(role) = LOWER(?) ");
			}

			// Search (name, email, role, status)
			if (search != null && !search.trim().isEmpty()) {
				String term = "%" + search.trim() + "%";
				where.append(" AND (LOWER(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) LIKE LOWER(?) ")
					.append(" OR LOWER(email) LIKE LOWER(?) OR LOWER(role) LIKE LOWER(?) OR LOWER(status) LIKE LOWER(?)) ");
				countWhere.append(" AND (LOWER(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) LIKE LOWER(?) ")
					.append(" OR LOWER(email) LIKE LOWER(?) OR LOWER(role) LIKE LOWER(?) OR LOWER(status) LIKE LOWER(?)) ");
			}

			String countSql = "SELECT COUNT(*) FROM users " + countWhere;
			try (PreparedStatement countPs = con.prepareStatement(countSql)) {
				int p = 1;
				if (roleFilter != null && !roleFilter.trim().isEmpty()) {
					countPs.setString(p++, roleFilter.trim());
				}
				if (search != null && !search.trim().isEmpty()) {
					String term = "%" + search.trim() + "%";
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
				}
				ResultSet countRs = countPs.executeQuery();
				if (countRs.next()) totalUsers = countRs.getInt(1);
			}

			String sql = "SELECT * FROM users " + where + " ORDER BY " + orderColumn + " " + sortOrder + " LIMIT ? OFFSET ?";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				int p = 1;
				if (roleFilter != null && !roleFilter.trim().isEmpty()) {
					ps.setString(p++, roleFilter.trim());
				}
				if (search != null && !search.trim().isEmpty()) {
					String term = "%" + search.trim() + "%";
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
				}
				ps.setInt(p++, limit);
				ps.setInt(p++, offset);

				ResultSet rs = ps.executeQuery();

				while (rs.next()) {
					int userId = rs.getInt("id");
					String status = rs.getString("status");

					String fullName = fullName(rs.getString("firstname"), rs.getString("lastname"));
					if (fullName.isEmpty()) fullName = rs.getString("email");

					rows.append("<tr>").append("<td>").append(escapeHtml(fullName)).append("</td>").append("<td>")
							.append(escapeHtml(rs.getString("role"))).append("</td>")
							.append("<td>").append("<span class='badge ")
							.append(status != null && status.equalsIgnoreCase("active") ? "active" : "inactive").append("'>").append(escapeHtml(status != null ? status : "")).append("</span>").append("</td>")
							.append("<td>").append(escapeHtml(nullToEmpty(rs.getString("firstname")))).append("</td>")
							.append("<td>").append(escapeHtml(nullToEmpty(rs.getString("lastname")))).append("</td>").append("<td>")
							.append(escapeHtml(nullToEmpty(rs.getString("email")))).append("</td>").append("<td>").append(rs.getDate("joinedDate"))
							.append("</td>")
							.append("<td class='actions'>").append("<a href='editUser?id=").append(userId)
							.append("' class='icon-btn edit'><i class='fa-solid fa-pen'></i></a>")
							.append("<a href='#' class='icon-btn delete' ")
							.append("onclick=\"openDeleteModal(").append(userId).append(")\">")
							.append("<i class='fa-solid fa-trash'></i></a>").append("</td>").append("</tr>");
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		int totalPages = Math.max(1, (int) Math.ceil((double) totalUsers / limit));

		req.setAttribute("rows", rows.toString());
		req.setAttribute("currentPage", page);
		req.setAttribute("totalPages", totalPages);
		req.setAttribute("totalUsers", totalUsers);
		req.setAttribute("search", search != null ? search : "");
		req.setAttribute("roleFilter", roleFilter != null ? roleFilter : "");
		req.setAttribute("sortBy", sortBy);
		req.setAttribute("sortOrder", sortOrder);

		req.getRequestDispatcher("viewUser.jsp").forward(req, res);
	}
}
