package com.smartoffice.service;

import com.smartoffice.utils.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class NotificationService {

	public static final String TYPE_TASK = "TASK";
	public static final String TYPE_MEETING = "MEETING";
	public static final String TYPE_LEAVE = "LEAVE";
	public static final String TYPE_GENERAL = "GENERAL";

	public static void notify(String recipientEmail, String createdBy, String type, String message) {
		if (recipientEmail == null || recipientEmail.trim().isEmpty())
			return;
		String sql = "INSERT INTO notifications (recipient_email, message, created_by, type, is_read) VALUES (?, ?, ?, ?, 0)";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, recipientEmail.trim());
			ps.setString(2, message);
			ps.setString(3, createdBy);
			ps.setString(4, type);
			ps.executeUpdate();
		} catch (Exception e) {
			System.err.println("[NotificationService] Failed to notify " + recipientEmail + ": " + e.getMessage());
		}
	}

	public static void notifyMany(List<String> recipientEmails, String createdBy, String type, String message) {
		if (recipientEmails == null || recipientEmails.isEmpty())
			return;
		String sql = "INSERT INTO notifications (recipient_email, message, created_by, type, is_read) VALUES (?, ?, ?, ?, 0)";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			for (String email : recipientEmails) {
				if (email == null || email.trim().isEmpty())
					continue;
				if (email.trim().equalsIgnoreCase(createdBy))
					continue;
				ps.setString(1, email.trim());
				ps.setString(2, message);
				ps.setString(3, createdBy);
				ps.setString(4, type);
				ps.addBatch();
			}
			ps.executeBatch();
		} catch (Exception e) {
			System.err.println("[NotificationService] Failed batch notify: " + e.getMessage());
		}
	}

	public static void notifyAllManagers(String createdBy, String type, String message) {
		List<String> managerEmails = getUserEmailsByRole("Manager");
		notifyMany(managerEmails, createdBy, type, message);
	}

	public static void notifyAllAdmins(String createdBy, String type, String message) {
		List<String> adminEmails = getUserEmailsByRole("admin");
		notifyMany(adminEmails, createdBy, type, message);
	}

	public static void notifyManagerOf(String employeeEmail, String createdBy, String type, String message) {
		String managerEmail = getManagerEmailOf(employeeEmail);
		if (managerEmail != null && !managerEmail.isEmpty()) {
			notify(managerEmail, createdBy, type, message);
		}
		notifyAllAdmins(createdBy, type, message);
	}

	public static int getUnreadCount(String recipientEmail) {
		String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_email = ? AND is_read = 0";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, recipientEmail);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				return rs.getInt(1);
		} catch (Exception e) {
			System.err.println("[NotificationService] getUnreadCount error: " + e.getMessage());
		}
		return 0;
	}

	private static List<String> getUserEmailsByRole(String role) {
		List<String> emails = new ArrayList<>();
		String sql = "SELECT email FROM users WHERE role = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, role);
			ResultSet rs = ps.executeQuery();
			while (rs.next())
				emails.add(rs.getString("email"));
		} catch (Exception e) {
			System.err.println("[NotificationService] getUserEmailsByRole error: " + e.getMessage());
		}
		return emails;
	}

	private static String getManagerEmailOf(String employeeEmail) {
		String sql = "SELECT manager_email FROM users WHERE email = ?";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, employeeEmail);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				return rs.getString("manager_email");
		} catch (Exception e) {
			System.err.println("[NotificationService] getManagerEmailOf error: " + e.getMessage());
		}
		return null;
	}
}