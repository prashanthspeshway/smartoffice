package com.smartoffice.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.smartoffice.utils.DBConnectionUtil;
import com.smartoffice.utils.PasswordUtil;
import com.smartoffice.utils.UserFieldUtil;

@SuppressWarnings("serial")
@WebServlet("/bulkUploadEmployees")
@MultipartConfig
public class BulkUploadEmployees extends HttpServlet {

	private boolean isValidPassword(String password) {
		String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
		return password != null && password.matches(regex);
	}

	/** Extracts a user-friendly error message from DB constraint violations. */
	private String extractConstraintError(Throwable t) {
		Throwable cause = t;
		while (cause != null) {
			String msg = cause.getMessage();
			if (msg != null) {
				if (msg.contains("Duplicate entry") && msg.contains("for key")) {
					// e.g. "Duplicate entry '9890011225' for key 'users.phone_UNIQUE'"
					String field = "value";
					if (msg.contains("phone") || msg.contains("phone_UNIQUE")) field = "phone number";
					else if (msg.contains("email")) field = "email";
					return "Bulk upload rejected: " + msg + " No employees were added. Please fix the duplicate " + field + " in your file and try again.";
				}
				if (msg.contains("foreign key") || msg.contains("FOREIGN KEY")) {
					return "Bulk upload failed: " + msg + " No employees were added.";
				}
			}
			cause = cause.getCause();
		}
		return "Bulk upload failed. No employees were added. " + (t.getMessage() != null ? t.getMessage() : "Please check your file format and data.");
	}

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		Connection con = null;
		PreparedStatement ps = null;

		try {

			Part filePart = req.getPart("excelFile");
			String fileName = filePart.getSubmittedFileName();
			InputStream inputStream = filePart.getInputStream();

			con = DBConnectionUtil.getConnection();
			con.setAutoCommit(false);

			String sql = "INSERT INTO users "
					+ "(username,password,role,status,email,firstname,lastname,joinedDate,phone) "
					+ "VALUES (?,?,?,?,?,?,?,?,?)";

			ps = con.prepareStatement(sql);

			// ===== EXCEL FILE (.xlsx) =====
			int insertedCount = 0;
			if (fileName.endsWith(".xlsx")) {
				
				

				try (Workbook workbook = new XSSFWorkbook(inputStream)) {
					Sheet sheet = workbook.getSheetAt(0);

					DataFormatter formatter = new DataFormatter();
					
					

					for (Row row : sheet) {
						if (row.getRowNum() == 0)
							continue;

						// Expected Excel columns: 0=username, 1=password, 2=status, 3=role, 4=firstname, 5=lastname, 6=email, 7=joinedDate, 8=phone
						String username = formatter.formatCellValue(row.getCell(0));
						String password = formatter.formatCellValue(row.getCell(1));
						String status = formatter.formatCellValue(row.getCell(2));
						String role = formatter.formatCellValue(row.getCell(3));
						String firstname = formatter.formatCellValue(row.getCell(4));
						String lastname = formatter.formatCellValue(row.getCell(5));
						String email = formatter.formatCellValue(row.getCell(6));

						if (email == null || email.trim().isEmpty() || !isValidPassword(password)) {
							continue;
						}

						Cell dateCell = row.getCell(7);
						java.sql.Date sqlDate = null;
						if (dateCell != null) {
							if (dateCell.getCellType() == CellType.NUMERIC) {
								java.util.Date utilDate = DateUtil.getJavaDate(dateCell.getNumericCellValue());
								sqlDate = new java.sql.Date(utilDate.getTime());
							} else {
								String dateStr = formatter.formatCellValue(dateCell).trim();
								if (!dateStr.isEmpty()) {
									try {
										java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
										java.util.Date utilDate = sdf.parse(dateStr);
										sqlDate = new java.sql.Date(utilDate.getTime());
									} catch (Exception e) {
										try {
											java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
											java.util.Date utilDate = sdf.parse(dateStr);
											sqlDate = new java.sql.Date(utilDate.getTime());
										} catch (Exception ex) {
											sqlDate = null;
										}
									}
								}
							}
						}
						if (sqlDate == null) {
							continue;
						}

						String phone = formatter.formatCellValue(row.getCell(8));
						if (phone != null) {
							phone = phone.replaceAll("[^0-9]", "").trim();
							if (phone.length() > 10) phone = phone.substring(0, 10);
						}
						if (firstname == null) firstname = "";
						if (lastname == null) lastname = "";
						if (username == null || username.trim().isEmpty()) {
							username = (firstname + " " + lastname).trim();
							if (username.isEmpty()) username = email;
						}
						status = UserFieldUtil.normalizeStatus(status);
						role = UserFieldUtil.normalizeRole(role);

						String hashedPassword = PasswordUtil.hashPassword(password);
						ps.setString(1, username);
						ps.setString(2, hashedPassword);
						ps.setString(3, role);
						ps.setString(4, status);
						ps.setString(5, email);
						ps.setString(6, firstname);
						ps.setString(7, lastname);
						ps.setDate(8, sqlDate);
						ps.setString(9, phone);

						ps.addBatch();
						insertedCount++;
					}

					if (insertedCount > 0) {
						ps.executeBatch();
						con.commit();
					}
				}
			}

			// ===== CSV FILE =====
			else if (fileName.endsWith(".csv")) {

				BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));

				String line;
				boolean header = true;

				while ((line = reader.readLine()) != null) {

					if (header) {
						header = false;
						continue;
					}

					String[] data = line.split(",", -1);
					if (data.length < 7) continue;

					String username = data.length > 0 ? data[0].trim() : "";
					String password = data.length > 1 ? data[1].trim() : "";
					String status = UserFieldUtil.normalizeStatus(data.length > 2 ? data[2].trim() : "");
					String role = UserFieldUtil.normalizeRole(data.length > 3 ? data[3].trim() : "");
					String firstname = data.length > 4 ? data[4].trim() : "";
					String lastname = data.length > 5 ? data[5].trim() : "";
					String email = data.length > 6 ? data[6].trim() : "";

					if (email.isEmpty() || !isValidPassword(password)) continue;

					java.sql.Date sqlDate = null;
					String dateStr = data.length > 7 ? data[7].trim() : "";
					if (!dateStr.isEmpty()) {
						try {
							sqlDate = java.sql.Date.valueOf(dateStr);
						} catch (Exception e) {
							try {
								java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
								java.util.Date utilDate = sdf.parse(dateStr);
								sqlDate = new java.sql.Date(utilDate.getTime());
							} catch (Exception ex) {
								try {
									java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
									java.util.Date utilDate = sdf.parse(dateStr);
									sqlDate = new java.sql.Date(utilDate.getTime());
								} catch (Exception ex2) {
									sqlDate = null;
								}
							}
						}
					}
					if (sqlDate == null) continue;

					String phone = data.length > 8 ? data[8].replaceAll("[^0-9]", "").trim() : "";
					if (phone != null && phone.length() > 10) phone = phone.substring(0, 10);

					if (username.isEmpty()) {
						username = (firstname + " " + lastname).trim();
						if (username.isEmpty()) username = email;
					}

					ps.setString(1, username);
					ps.setString(2, PasswordUtil.hashPassword(password));
					ps.setString(3, role);
					ps.setString(4, status);
					ps.setString(5, email);
					ps.setString(6, firstname);
					ps.setString(7, lastname);
					ps.setDate(8, sqlDate);
					ps.setString(9, phone);

					ps.addBatch();
					insertedCount++;
				}

				if (insertedCount > 0) {
					ps.executeBatch();
					con.commit();
				}
			}

			if (insertedCount > 0) {
			    req.getSession().setAttribute("successMsg", insertedCount + " employees uploaded successfully!");
			} else {
			    req.getSession().setAttribute("errorMsg", "No employees were uploaded. Please check password format.");
			}
			String redirect = req.getParameter("redirect");
			res.sendRedirect("viewUser".equals(redirect) ? "viewUser" : "addUser");

		} catch (Exception e) {
			e.printStackTrace();
			try {
				if (con != null) con.rollback();
			} catch (SQLException ex) { ex.printStackTrace(); }
			String errMsg = extractConstraintError(e);
			req.getSession().setAttribute("errorMsg", errMsg);
			String redirect = req.getParameter("redirect");
			res.sendRedirect("viewUser".equals(redirect) ? "viewUser" : "addUser");

		} finally {
			try {
				if (con != null) con.setAutoCommit(true);
				if (ps != null) ps.close();
				if (con != null) con.close();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}
}