package com.smartoffice.dao;

import com.smartoffice.model.Notification;
import com.smartoffice.utils.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for reading and marking notifications.
 * Works with the updated notifications table that has recipient_email + is_read columns.
 */
public class NotificationReadsDAO {

    // ─────────────────────────────────────────────────────────────
    // Get all unread notifications for a recipient (by email)
    // ─────────────────────────────────────────────────────────────
    public List<Notification> getUnreadNotifications(String recipientEmail) throws Exception {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT id, recipient_email, message, created_by, type, is_read, created_at " +
                     "FROM notifications " +
                     "WHERE recipient_email = ? AND is_read = 0 " +
                     "ORDER BY created_at DESC";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, recipientEmail);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setRecipientEmail(rs.getString("recipient_email"));
                n.setMessage(rs.getString("message"));
                n.setCreatedBy(rs.getString("created_by"));
                n.setType(rs.getString("type"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // Get unread count (for badge polling)
    // ─────────────────────────────────────────────────────────────
    public int getUnreadCount(String recipientEmail) throws Exception {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_email = ? AND is_read = 0";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, recipientEmail);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────
    // Mark a single notification as read
    // ─────────────────────────────────────────────────────────────
    public void markAsRead(int notificationId, String recipientEmail) throws Exception {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND recipient_email = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setString(2, recipientEmail);
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mark ALL notifications as read for a recipient
    // ─────────────────────────────────────────────────────────────
    public void markAllAsRead(String recipientEmail) throws Exception {
        String sql = "UPDATE notifications SET is_read = 1 WHERE recipient_email = ? AND is_read = 0";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, recipientEmail);
            ps.executeUpdate();
        }
    }
}