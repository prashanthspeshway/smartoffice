package com.smartoffice.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.apache.poi.ss.usermodel.*;
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

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;

        try {

            Part filePart = req.getPart("excelFile");
            String fileName = filePart.getSubmittedFileName();
            InputStream inputStream = filePart.getInputStream();

            con = DBConnectionUtil.getConnection();
            con.setAutoCommit(false);

            String sql = "INSERT INTO users "
                    + "(username,password,role,status,email,firstname,lastname,designation,joinedDate,phone) "
                    + "VALUES (?,?,?,?,?,?,?,?,?,?)";

            ps = con.prepareStatement(sql);

            int insertedCount = 0;

            // ================= EXCEL =================
            if (fileName.endsWith(".xlsx")) {

                Workbook workbook = new XSSFWorkbook(inputStream);
                Sheet sheet = workbook.getSheetAt(0);

                DataFormatter formatter = new DataFormatter();

                for (Row row : sheet) {

                    if (row.getRowNum() == 0)
                        continue;

                    String username = formatter.formatCellValue(row.getCell(0));
                    String password = formatter.formatCellValue(row.getCell(1));
                    String status = formatter.formatCellValue(row.getCell(2));
                    String role = formatter.formatCellValue(row.getCell(3));
                    String firstname = formatter.formatCellValue(row.getCell(4));
                    String lastname = formatter.formatCellValue(row.getCell(5));
                    String email = formatter.formatCellValue(row.getCell(6));

                    if (email == null || email.trim().isEmpty() || !isValidPassword(password))
                        continue;

                    Cell dateCell = row.getCell(7);
                    java.sql.Date sqlDate = null;

                    if (dateCell != null) {

                        if (dateCell.getCellType() == CellType.NUMERIC) {

                            java.util.Date utilDate = DateUtil.getJavaDate(dateCell.getNumericCellValue());
                            sqlDate = new java.sql.Date(utilDate.getTime());

                        } else {

                            String dateStr = formatter.formatCellValue(dateCell);

                            try {
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
                                java.util.Date utilDate = sdf.parse(dateStr);
                                sqlDate = new java.sql.Date(utilDate.getTime());
                            } catch (Exception ignored) {
                            }
                        }
                    }

                    if (sqlDate == null)
                        continue;

                    String phone = formatter.formatCellValue(row.getCell(8));
                    if (phone != null) {
                        phone = phone.replaceAll("[^0-9]", "");
                        if (phone.length() > 10)
                            phone = phone.substring(0, 10);
                    }

                    String designation = formatter.formatCellValue(row.getCell(9));

                    if (!"Employee".equalsIgnoreCase(role)) {
                        designation = null;
                    }

                    if (username == null || username.trim().isEmpty()) {
                        username = (firstname + " " + lastname).trim();
                        if (username.isEmpty())
                            username = email;
                    }

                    status = UserFieldUtil.normalizeStatus(status);
                    role = UserFieldUtil.normalizeRole(role);

                    ps.setString(1, username);
                    ps.setString(2, PasswordUtil.hashPassword(password));
                    ps.setString(3, role);
                    ps.setString(4, status);
                    ps.setString(5, email);
                    ps.setString(6, firstname);
                    ps.setString(7, lastname);
                    ps.setString(8, designation);
                    ps.setDate(9, sqlDate);
                    ps.setString(10, phone);

                    ps.addBatch();
                    insertedCount++;
                }

                workbook.close();
            }

            // ================= CSV =================
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

                    if (data.length < 9)
                        continue;

                    String username = data[0];
                    String password = data[1];
                    String status = UserFieldUtil.normalizeStatus(data[2]);
                    String role = UserFieldUtil.normalizeRole(data[3]);
                    String firstname = data[4];
                    String lastname = data[5];
                    String email = data[6];

                    if (email.isEmpty() || !isValidPassword(password))
                        continue;

                    java.sql.Date sqlDate = java.sql.Date.valueOf(data[7]);

                    String phone = data[8];
                    String designation = data.length > 9 ? data[9] : null;

                    if (!"Employee".equalsIgnoreCase(role)) {
                        designation = null;
                    }

                    ps.setString(1, username);
                    ps.setString(2, PasswordUtil.hashPassword(password));
                    ps.setString(3, role);
                    ps.setString(4, status);
                    ps.setString(5, email);
                    ps.setString(6, firstname);
                    ps.setString(7, lastname);
                    ps.setString(8, designation);
                    ps.setDate(9, sqlDate);
                    ps.setString(10, phone);

                    ps.addBatch();
                    insertedCount++;
                }
            }

            if (insertedCount > 0) {

                ps.executeBatch();
                con.commit();

                req.getSession().setAttribute("successMsg",
                        insertedCount + " employees uploaded successfully!");

            } else {

                req.getSession().setAttribute("errorMsg",
                        "No employees were uploaded.");
            }

            res.sendRedirect("addUser");

        }

        catch (Exception e) {

            e.printStackTrace();

            try {
                if (con != null)
                    con.rollback();
            } catch (SQLException ignored) {
            }

            req.getSession().setAttribute("errorMsg", "Bulk upload failed.");
            res.sendRedirect("addUser");
        }

        finally {

            try {
                if (ps != null)
                    ps.close();
                if (con != null)
                    con.close();
            } catch (Exception ignored) {
            }
        }
    }
}