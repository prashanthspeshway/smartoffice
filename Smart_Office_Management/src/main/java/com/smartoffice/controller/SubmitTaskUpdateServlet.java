package com.smartoffice.controller;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.smartoffice.utils.DBConnectionUtil;

@SuppressWarnings("serial")
@WebServlet("/submitTaskUpdate")
@MultipartConfig
public class SubmitTaskUpdateServlet extends HttpServlet {

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) {

		try {

			int taskId = Integer.parseInt(req.getParameter("taskId"));
			String status = req.getParameter("status");
			String comment = req.getParameter("comment");

			Part filePart = req.getPart("employeeFile");

			String fileName = null;
			InputStream fileData = null;

			if (filePart != null && filePart.getSize() > 0) {
				fileName = filePart.getSubmittedFileName();
				fileData = filePart.getInputStream();
			}

			String sql = """
					 UPDATE tasks
					 SET status=?,
					     employee_attachment=?,
					     employee_attachment_name=?,
					     employee_comment=?,
					     submitted_at=NOW()
					 WHERE id=?
					""";

			try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

				ps.setString(1, status);

				if (fileData != null) {
					ps.setBlob(2, fileData);
					ps.setString(3, fileName);
				} else {
					ps.setNull(2, java.sql.Types.BLOB);
					ps.setNull(3, java.sql.Types.VARCHAR);
				}

				ps.setString(4, comment);
				ps.setInt(5, taskId);

				ps.executeUpdate();
			}

			resp.sendRedirect("user?tab=tasks");

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}