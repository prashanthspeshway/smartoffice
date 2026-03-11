package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.Notification;
import com.smartoffice.utils.DBConnectionUtil;

public class NotificationReadsDAO {

    private String getNrUserColumn() throws Exception {
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='notification_reads' AND COLUMN_NAME='username'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return "username";
        }
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='notification_reads' AND COLUMN_NAME='email'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return "email";
        }
        return "username";
    }

    private String resolveForNr(String sessionValue) throws Exception {
        String col = getNrUserColumn();
        if ("email".equals(col)) return sessionValue;
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, sessionValue);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("username");
        }
        return sessionValue;
    }

    public List<Notification> getUnreadNotifications(String sessionValue) throws Exception {
        List<Notification> list = new ArrayList<>();
        String col = getNrUserColumn();
        String id = resolveForNr(sessionValue);

        String sql = "SELECT n.* FROM notifications n WHERE NOT EXISTS " +
            "(SELECT 1 FROM notification_reads nr WHERE nr.notification_id = n.id AND nr." + col + " = ?) " +
            "ORDER BY n.created_at DESC";

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setMessage(rs.getString("message"));
                n.setCreatedBy(rs.getString("created_by"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        }
        return list;
    }

    public void markAsRead(int notificationId, String sessionValue) throws Exception {
        String col = getNrUserColumn();
        String id = resolveForNr(sessionValue);
        String sql = "INSERT IGNORE INTO notification_reads (notification_id, " + col + ") VALUES (?, ?)";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setString(2, id);
            ps.executeUpdate();
        }
    }
}
