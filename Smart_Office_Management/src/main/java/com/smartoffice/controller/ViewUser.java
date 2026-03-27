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
import com.smartoffice.dao.DesignationDAO;

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
		if (s == null)
			return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		int page = 1;
		int limit = 9;
		String search = req.getParameter("search");
		String roleFilter = req.getParameter("role");
		String designationFilter = req.getParameter("designation");
		String statusFilter = req.getParameter("status");
		String dateFrom = req.getParameter("dateFrom");
		String dateTo = req.getParameter("dateTo");
		String sortBy = req.getParameter("sort");
		String sortOrder = req.getParameter("order");

		if (req.getParameter("page") != null) {
			try {
				page = Math.max(1, Integer.parseInt(req.getParameter("page")));
			} catch (NumberFormatException e) {
			}
		}
		if (search == null)
			search = "";
		if (roleFilter == null)
			roleFilter = "";
		if (statusFilter == null)
			statusFilter = "";
		if (designationFilter == null)
			designationFilter = "";
		if (dateFrom == null)
			dateFrom = "";
		if (dateTo == null)
			dateTo = "";
		if (sortBy == null || sortBy.isEmpty())
			sortBy = "fullname";
		if (sortOrder == null || sortOrder.isEmpty())
			sortOrder = "asc";

		String orderColumn = "firstname";
		switch (sortBy.toLowerCase()) {
		case "role":
			orderColumn = "role";
			break;
		case "status":
			orderColumn = "status";
			break;
		case "email":
			orderColumn = "email";
			break;
		case "date":
		case "joineddate":
			orderColumn = "joinedDate";
			break;
		default:
			orderColumn = "firstname";
			break;
		}
		if (!"desc".equalsIgnoreCase(sortOrder))
			sortOrder = "asc";

		int offset = (page - 1) * limit;

		StringBuilder rows = new StringBuilder();
		StringBuilder gridRows = new StringBuilder();
		int totalUsers = 0;

		try (Connection con = DBConnectionUtil.getConnection()) {

			StringBuilder where = new StringBuilder(" WHERE LOWER(role) != 'admin' ");
			StringBuilder countWhere = new StringBuilder(" WHERE LOWER(role) != 'admin' ");
			int paramIdx = 1;

			if (roleFilter != null && !roleFilter.trim().isEmpty()) {
				String r = roleFilter.trim().toLowerCase();
				if ("employee".equals(r) || "user".equals(r)) {
					where.append(" AND LOWER(TRIM(role)) IN ('user', 'employee') ");
					countWhere.append(" AND LOWER(TRIM(role)) IN ('user', 'employee') ");
				} else {
					where.append(" AND LOWER(TRIM(role)) = LOWER(?) ");
					countWhere.append(" AND LOWER(TRIM(role)) = LOWER(?) ");
				}
			}

			if (statusFilter != null && !statusFilter.trim().isEmpty()) {
				String s = statusFilter.trim().toLowerCase();
				if ("active".equals(s)) {
					where.append(" AND LOWER(TRIM(status)) = 'active' ");
					countWhere.append(" AND LOWER(TRIM(status)) = 'active' ");
				} else if ("inactive".equals(s)) {
					where.append(" AND LOWER(TRIM(status)) = 'inactive' ");
					countWhere.append(" AND LOWER(TRIM(status)) = 'inactive' ");
				}
			}

			if (designationFilter != null && !designationFilter.trim().isEmpty()) {
				where.append(" AND LOWER(COALESCE(designation,'')) = LOWER(?) ");
				countWhere.append(" AND LOWER(COALESCE(designation,'')) = LOWER(?) ");
			}

			if (search != null && !search.trim().isEmpty()) {
				String term = "%" + search.trim() + "%";
				where.append(" AND (LOWER(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) LIKE LOWER(?) ")
						.append(" OR LOWER(email) LIKE LOWER(?) OR LOWER(role) LIKE LOWER(?) OR LOWER(status) LIKE LOWER(?) ")
						.append(" OR DATE_FORMAT(joinedDate, '%Y-%m-%d') LIKE ? OR DATE_FORMAT(joinedDate, '%d-%m-%Y') LIKE ?) ");
				countWhere.append(
						" AND (LOWER(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) LIKE LOWER(?) ")
						.append(" OR LOWER(email) LIKE LOWER(?) OR LOWER(role) LIKE LOWER(?) OR LOWER(status) LIKE LOWER(?) ")
						.append(" OR DATE_FORMAT(joinedDate, '%Y-%m-%d') LIKE ? OR DATE_FORMAT(joinedDate, '%d-%m-%Y') LIKE ?) ");
			}

			java.sql.Date dateFromVal = null, dateToVal = null;
			if (dateFrom != null && !dateFrom.trim().isEmpty()) {
				try {
					dateFromVal = java.sql.Date.valueOf(dateFrom.trim());
					where.append(" AND joinedDate >= ? ");
					countWhere.append(" AND joinedDate >= ? ");
				} catch (Exception ignored) {
				}
			}
			if (dateTo != null && !dateTo.trim().isEmpty()) {
				try {
					dateToVal = java.sql.Date.valueOf(dateTo.trim());
					where.append(" AND joinedDate <= ? ");
					countWhere.append(" AND joinedDate <= ? ");
				} catch (Exception ignored) {
				}
			}

			String countSql = "SELECT COUNT(*) FROM users " + countWhere;
			try (PreparedStatement countPs = con.prepareStatement(countSql)) {
				int p = 1;
				if (roleFilter != null && !roleFilter.trim().isEmpty()) {
					String r = roleFilter.trim().toLowerCase();
					if (!"employee".equals(r) && !"user".equals(r)) {
						countPs.setString(p++, roleFilter.trim());
					}
				}
				if (designationFilter != null && !designationFilter.trim().isEmpty()) {
					countPs.setString(p++, designationFilter.trim());
				}
				if (search != null && !search.trim().isEmpty()) {
					String term = "%" + search.trim() + "%";
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
					countPs.setString(p++, term);
				}
				if (dateFromVal != null)
					countPs.setDate(p++, dateFromVal);
				if (dateToVal != null)
					countPs.setDate(p++, dateToVal);
				ResultSet countRs = countPs.executeQuery();
				if (countRs.next())
					totalUsers = countRs.getInt(1);
			}

			String sql = "SELECT * FROM users " + where + " ORDER BY " + orderColumn + " " + sortOrder
					+ " LIMIT ? OFFSET ?";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				int p = 1;
				if (roleFilter != null && !roleFilter.trim().isEmpty()) {
					String r = roleFilter.trim().toLowerCase();
					if (!"employee".equals(r) && !"user".equals(r)) {
						ps.setString(p++, roleFilter.trim());
					}
				}
				if (designationFilter != null && !designationFilter.trim().isEmpty()) {
					ps.setString(p++, designationFilter.trim());
				}
				if (search != null && !search.trim().isEmpty()) {
					String term = "%" + search.trim() + "%";
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
					ps.setString(p++, term);
				}
				if (dateFromVal != null)
					ps.setDate(p++, dateFromVal);
				if (dateToVal != null)
					ps.setDate(p++, dateToVal);
				ps.setInt(p++, limit);
				ps.setInt(p++, offset);

				ResultSet rs = ps.executeQuery();

				while (rs.next()) {
					int userId = rs.getInt("id");
					String status = rs.getString("status");
					String first = nullToEmpty(rs.getString("firstname"));
					String last = nullToEmpty(rs.getString("lastname"));
					String email = nullToEmpty(rs.getString("email"));
					String fullName = fullName(first, last);
					if (fullName.isEmpty())
						fullName = email;
					String roleDisplay = rs.getString("role");
					if (roleDisplay != null && "user".equalsIgnoreCase(roleDisplay.trim()))
						roleDisplay = "employee";
					roleDisplay = roleDisplay != null ? roleDisplay : "";
					String statusClass = status != null && status.trim().equalsIgnoreCase("active") ? "active"
							: "inactive";
					String statusText = status != null && status.trim().equalsIgnoreCase("active") ? "Active"
							: "Inactive";
					java.sql.Date joinedDate = rs.getDate("joinedDate");
					String joinedStr = joinedDate != null ? joinedDate.toString() : "";

					String designation = nullToEmpty(rs.getString("designation"));

					rows.append("<tr class=\"border-b border-slate-200 hover:bg-slate-50\" ")
							.append("data-profile-email=\"").append(escapeHtml(email)).append("\">")
							.append("<td class=\"px-4 py-3 text-sm font-medium text-slate-700 cursor-pointer hover:text-indigo-600\">")
							.append(escapeHtml(fullName)).append("</td>")
							.append("<td class=\"px-4 py-3 text-sm text-slate-700\">").append(escapeHtml(roleDisplay))
							.append("</td>").append("<td class=\"px-4 py-3\"><span class=\"badge ").append(statusClass)
							.append("\">").append(escapeHtml(statusText)).append("</span></td>")
							.append("<td class=\"px-4 py-3 text-sm text-slate-700\">")
							.append(designation.isEmpty() ? "-" : escapeHtml(designation)).append("</td>")
							.append("<td class=\"px-4 py-3 text-sm text-slate-700\">").append(escapeHtml(email))
							.append("</td>").append("<td class=\"px-4 py-3\" onclick=\"event.stopPropagation()\">")
							.append("<a href=\"editUser?id=").append(userId)
							.append("\" class=\"icon-btn edit\"><i class=\"fa-solid fa-pen\"></i></a>")
							.append("<a href=\"#\" class=\"icon-btn delete\" onclick=\"openDeleteModal(").append(userId)
							.append("); return false;\"><i class=\"fa-solid fa-trash\"></i></a>").append("</td>")
							.append("</tr>");

					gridRows.append("<div class=\"grid-card bg-white rounded-xl border border-slate-200 p-4\" ")
							.append("data-profile-email=\"").append(escapeHtml(email)).append("\">")
							.append("<div class=\"font-medium text-slate-800 mb-1 cursor-pointer hover:text-indigo-600\">")
							.append(escapeHtml(fullName)).append("</div>")
							.append("<div class=\"text-sm text-slate-600 mb-1\"><span class=\"font-medium\">Role:</span> ")
							.append(escapeHtml(roleDisplay)).append("</div>")
							.append("<div class=\"text-sm text-slate-600 mb-1\"><span class=\"font-medium\">Status:</span> <span class=\"badge ")
							.append(statusClass).append("\">").append(escapeHtml(statusText)).append("</span></div>")
							.append("<div class=\"text-sm text-slate-600 mb-3\"><span class=\"font-medium\">Designation:</span> ")
							.append(designation.isEmpty() ? "-" : escapeHtml(designation)).append("</div>")
							.append("<div class=\"text-sm text-slate-500 mb-3\">").append(escapeHtml(email))
							.append("</div>").append("<div onclick=\"event.stopPropagation()\">")
							.append("<a href=\"editUser?id=").append(userId)
							.append("\" class=\"icon-btn edit inline-block\"><i class=\"fa-solid fa-pen\"></i></a>")
							.append("<a href=\"#\" class=\"icon-btn delete inline-block\" onclick=\"openDeleteModal(")
							.append(userId).append("); return false;\"><i class=\"fa-solid fa-trash\"></i></a>")
							.append("</div>").append("</div>");
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		int totalPages = Math.max(1, (int) Math.ceil((double) totalUsers / limit));

		req.setAttribute("rows", rows.toString());
		req.setAttribute("gridRows", gridRows.length() > 0 ? gridRows.toString()
				: "<div class=\"col-span-full text-center py-12 text-slate-500 italic\">No employees found</div>");
		req.setAttribute("currentPage", page);
		req.setAttribute("totalPages", totalPages);
		req.setAttribute("totalUsers", totalUsers);
		req.setAttribute("search", search != null ? search : "");
		req.setAttribute("roleFilter", roleFilter != null ? roleFilter : "");
		req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");
		req.setAttribute("designationFilter", designationFilter != null ? designationFilter : "");
		req.setAttribute("dateFrom", dateFrom != null ? dateFrom : "");
		req.setAttribute("dateTo", dateTo != null ? dateTo : "");
		req.setAttribute("sortBy", sortBy);
		req.setAttribute("sortOrder", sortOrder);

		try {
			req.setAttribute("designationOptions", new DesignationDAO().getActiveDesignations());
		} catch (Exception ignored) {
		}

		req.getRequestDispatcher("viewUser.jsp").forward(req, res);
	}
}
