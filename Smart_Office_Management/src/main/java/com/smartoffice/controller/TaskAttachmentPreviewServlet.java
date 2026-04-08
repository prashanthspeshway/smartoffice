package com.smartoffice.controller;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hwpf.HWPFDocument;
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/taskAttachmentPreview")
public class TaskAttachmentPreviewServlet extends HttpServlet {

	private String resolveDbUsername(String emailOrUsername) {
		if (emailOrUsername == null || emailOrUsername.trim().isEmpty())
			return emailOrUsername;
		String trimmed = emailOrUsername.trim();
		String sql = "SELECT username FROM users WHERE email = ? LIMIT 1";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, trimmed);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String dbUsername = rs.getString("username");
					if (dbUsername != null && !dbUsername.trim().isEmpty())
						return dbUsername.trim();
				}
			}
		} catch (Exception ignored) {
		}
		return trimmed;
	}

	private String esc(String s) {
		if (s == null)
			return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	private String ext(String name) {
		if (name == null)
			return "";
		int idx = name.lastIndexOf('.');
		return idx >= 0 ? name.substring(idx + 1).toLowerCase() : "";
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("username") == null) {
			response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login required");
			return;
		}

		String username = (String) session.getAttribute("username");
		String role = (String) session.getAttribute("role");
		String idParam = request.getParameter("id");
		if (idParam == null) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing task id");
			return;
		}

		int taskId;
		try {
			taskId = Integer.parseInt(idParam);
		} catch (NumberFormatException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task id");
			return;
		}

		String sql = "SELECT attachment, attachment_name, assigned_to, assigned_by FROM tasks WHERE id = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, taskId);
			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) {
					response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
					return;
				}

				byte[] data = rs.getBytes("attachment");
				String fileName = rs.getString("attachment_name");
				String assignedTo = rs.getString("assigned_to");
				String assignedBy = rs.getString("assigned_by");

				if (data == null || fileName == null || fileName.isEmpty()) {
					response.sendError(HttpServletResponse.SC_NOT_FOUND, "No attachment for this task");
					return;
				}

				boolean isAdmin = "admin".equalsIgnoreCase(role);
				String dbUsername = resolveDbUsername(username);
				boolean isOwner = username != null
						&& (username.equalsIgnoreCase(assignedTo) || username.equalsIgnoreCase(assignedBy)
								|| (dbUsername != null && (dbUsername.equalsIgnoreCase(assignedTo)
										|| dbUsername.equalsIgnoreCase(assignedBy))));
				if (!isAdmin && !isOwner) {
					response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not allowed");
					return;
				}

				String extension = ext(fileName);
				String html;
				if ("xlsx".equals(extension) || "xls".equals(extension) || "csv".equals(extension)) {
					html = toSheetHtml(data);
				} else if ("docx".equals(extension) || "doc".equals(extension)) {
					html = toWordHtml(data, extension);
				} else {
					response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "Unsupported preview type");
					return;
				}

				response.setCharacterEncoding("UTF-8");
				response.setContentType("text/html; charset=UTF-8");
				response.getWriter().write(html);
			}
		} catch (Exception e) {
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Preview failed: " + e.getMessage());
		}
	}

	private String toSheetHtml(byte[] data) throws Exception {
		StringBuilder out = new StringBuilder();
		DataFormatter formatter = new DataFormatter();
		try (Workbook wb = WorkbookFactory.create(new ByteArrayInputStream(data))) {
			Sheet sheet = wb.getNumberOfSheets() > 0 ? wb.getSheetAt(0) : null;
			if (sheet == null)
				return "<div style='padding:16px;color:#64748b'>No sheet data.</div>";
			out.append("<div style='overflow:auto'>");
			out.append("<table style='border-collapse:collapse;width:100%;font-size:12px;background:#fff'>");
			Iterator<Row> rows = sheet.rowIterator();
			int r = 0;
			while (rows.hasNext()) {
				Row row = rows.next();
				out.append("<tr>");
				int last = Math.max(1, row.getLastCellNum());
				for (int c = 0; c < last; c++) {
					Cell cell = row.getCell(c);
					String text = esc(formatter.formatCellValue(cell));
					if (r == 0) {
						out.append(
								"<th style='position:sticky;top:0;background:#f1f5f9;color:#475569;border:1px solid #e2e8f0;padding:7px 10px;font-weight:700'>")
								.append(text).append("</th>");
					} else {
						out.append("<td style='border:1px solid #e2e8f0;padding:6px 10px;color:#334155'>").append(text)
								.append("</td>");
					}
				}
				out.append("</tr>");
				r++;
			}
			out.append("</table></div>");
		}
		return out.toString();
	}

	private String toWordHtml(byte[] data, String extension) throws Exception {
		String text;
		if ("docx".equals(extension)) {
			try (XWPFDocument docx = new XWPFDocument(new ByteArrayInputStream(data));
					XWPFWordExtractor ex = new XWPFWordExtractor(docx)) {
				text = ex.getText();
			}
		} else {
			try (HWPFDocument doc = new HWPFDocument(new ByteArrayInputStream(data));
					WordExtractor ex = new WordExtractor(doc)) {
				text = ex.getText();
			}
		}
		if (text == null)
			text = "";
		return "<div style='background:#fff;border-radius:8px;padding:18px 20px;box-shadow:0 2px 16px rgba(0,0,0,.10)'>"
				+ "<pre style='white-space:pre-wrap;word-break:break-word;font-size:13px;line-height:1.6;color:#1e293b;margin:0'>"
				+ esc(text) + "</pre></div>";
	}
}

