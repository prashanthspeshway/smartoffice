package com.smartoffice.dao;

import com.smartoffice.model.Notification;
import com.smartoffice.utils.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class NotificationReadsDAO {

	public List<Notification> getUnreadNotifications(String recipientEmail) throws Exception {

		List<Notification> list = new ArrayList<>();

		String sql = "SELECT id, recipient_email, message, created_by, type, is_read, created_at "
				+ "FROM notifications WHERE recipient_email = ? AND is_read = 0 ORDER BY created_at DESC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, recipientEmail);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapRow(rs));
				}
			}
		}

		return list;
	}

	public List<Notification> getReadNotifications(String recipientEmail) throws Exception {

		List<Notification> list = new ArrayList<>();

		String sql = "SELECT id, recipient_email, message, created_by, type, is_read, created_at "
				+ "FROM notifications WHERE recipient_email = ? AND is_read = 1 ORDER BY created_at DESC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, recipientEmail);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapRow(rs));
				}
			}
		}

		return list;
	}

	public int getUnreadCount(String recipientEmail) throws Exception {

		String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_email = ? AND is_read = 0";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, recipientEmail);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		}

		return 0;
	}

	public void markAsRead(int notificationId, String recipientEmail) throws Exception {

		String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND recipient_email = ?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, notificationId);
			ps.setString(2, recipientEmail);

			ps.executeUpdate();
		}
	}

	public void markAllAsRead(String recipientEmail) throws Exception {

		String sql = "UPDATE notifications SET is_read = 1 WHERE recipient_email = ? AND is_read = 0";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, recipientEmail);

			ps.executeUpdate();
		}
	}

	public void deleteNotification(int notificationId, String recipientEmail) throws Exception {

		String sql = "DELETE FROM notifications WHERE id = ? AND recipient_email = ?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, notificationId);
			ps.setString(2, recipientEmail);

			ps.executeUpdate();
		}
	}

	public void deleteAllReadNotifications(String recipientEmail) throws Exception {

		String sql = "DELETE FROM notifications WHERE recipient_email = ? AND is_read = 1";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, recipientEmail);

			ps.executeUpdate();
		}
	}

	private Notification mapRow(ResultSet rs) throws Exception {

		Notification n = new Notification();

		n.setId(rs.getInt("id"));
		n.setRecipientEmail(rs.getString("recipient_email"));
		n.setMessage(rs.getString("message"));
		n.setCreatedBy(rs.getString("created_by"));
		n.setType(rs.getString("type"));
		n.setRead(rs.getBoolean("is_read"));
		n.setCreatedAt(rs.getTimestamp("created_at"));

		return n;
	}
}