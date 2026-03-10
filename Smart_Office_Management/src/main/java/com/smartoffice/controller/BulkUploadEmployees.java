package com.smartoffice.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;

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

@SuppressWarnings("serial")
@WebServlet("/bulkUploadEmployees")
@MultipartConfig
public class BulkUploadEmployees extends HttpServlet {

	private boolean isValidPassword(String password) {

		String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";

		return password != null && password.matches(regex);
	}

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		Connection con = null;
		PreparedStatement ps = null;

		try {

			Part filePart = req.getPart("excelFile");
			String fileName = filePart.getSubmittedFileName();
			InputStream inputStream = filePart.getInputStream();

			con = DBConnectionUtil.getConnection();

			String sql = "INSERT INTO users "
					+ "(username,password,role,status,email,fullname,joinedDate,manager,phone) "
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

						String username = formatter.formatCellValue(row.getCell(0));
						String password = formatter.formatCellValue(row.getCell(1));

						// password validation
						if (!isValidPassword(password)) {
							continue;
						}
						insertedCount++;
						String role = formatter.formatCellValue(row.getCell(2));
						String status = formatter.formatCellValue(row.getCell(3));
						String email = formatter.formatCellValue(row.getCell(4));
						String fullname = formatter.formatCellValue(row.getCell(5));

						Cell dateCell = row.getCell(6);
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
											java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(
													"yyyy-MM-dd");
											java.util.Date utilDate = sdf.parse(dateStr);
											sqlDate = new java.sql.Date(utilDate.getTime());
										} catch (Exception ex) {
											sqlDate = null;
										}
									}

								}

							}
						}

						// skip row if date invalid
						if (sqlDate == null) {
							continue;
						}

						String manager = formatter.formatCellValue(row.getCell(7));
						String phone = formatter.formatCellValue(row.getCell(8));

						ps.setString(1, username);
						String hashedPassword = PasswordUtil.hashPassword(password);
						ps.setString(2, hashedPassword);
						ps.setString(3, role);
						ps.setString(4, status);
						ps.setString(5, email);
						ps.setString(6, fullname);
						ps.setDate(7, sqlDate);
						ps.setString(8, manager);
						ps.setString(9, phone);

						ps.addBatch();
					}

					if (insertedCount > 0) {
					    ps.executeBatch();
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

					String[] data = line.split(",");

					ps.setString(1, data[0]);
					ps.setString(2, data[1]);
					ps.setString(3, data[2]);
					ps.setString(4, data[3]);
					ps.setString(5, data[4]);
					ps.setString(6, data[5]);
					java.sql.Date sqlDate = null;

					try {
						sqlDate = java.sql.Date.valueOf(data[6]); // yyyy-MM-dd
					} catch (Exception e) {

						try {
							java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
							java.util.Date utilDate = sdf.parse(data[6]);
							sqlDate = new java.sql.Date(utilDate.getTime());
						} catch (Exception ex) {
							sqlDate = null;
						}

					}

					ps.setDate(7, sqlDate);
					ps.setString(8, data[7]);
					ps.setString(9, data[8]);

					ps.addBatch();
				}

				ps.executeBatch();
			}

			if (insertedCount > 0) {
			    req.getSession().setAttribute("successMsg", insertedCount + " employees uploaded successfully!");
			} else {
			    req.getSession().setAttribute("errorMsg", "No employees were uploaded. Please check password format.");
			}
			res.sendRedirect("addUser");

		} catch (Exception e) {

			e.printStackTrace();
			req.getSession().setAttribute("errorMsg", "Bulk upload failed!");
			res.sendRedirect("addUser");

		} finally {

			try {
				if (ps != null)
					ps.close();
				if (con != null)
					con.close();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}
}