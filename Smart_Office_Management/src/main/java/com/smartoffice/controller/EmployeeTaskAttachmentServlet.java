package com.smartoffice.controller;

import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/employeeTaskAttachment")
public class EmployeeTaskAttachmentServlet extends HttpServlet {

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) {

		try {

			int taskId = Integer.parseInt(req.getParameter("id"));

			String sql = "SELECT employee_attachment, employee_attachment_name FROM tasks WHERE id=?";

			try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

				ps.setInt(1, taskId);

				ResultSet rs = ps.executeQuery();

				if (rs.next()) {

					byte[] data = rs.getBytes("employee_attachment");
					String name = rs.getString("employee_attachment_name");

					if (data == null) {
						resp.sendError(404, "No employee file");
						return;
					}

					resp.setContentType("application/octet-stream");
					resp.setHeader("Content-Disposition", "attachment; filename=\"" + name + "\"");
					resp.setContentLength(data.length);

					OutputStream os = resp.getOutputStream();
					os.write(data);
					os.flush();
				}

			}

		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}