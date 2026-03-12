package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.utils.DBConnectionUtil;

public class DesignationDAO {

    public List<String> getActiveDesignations() throws Exception {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM designations WHERE is_active=1 ORDER BY name";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString("name"));
        }
        return list;
    }

    public List<String> getAllDesignations() throws Exception {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM designations ORDER BY is_active DESC, name";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString("name"));
        }
        return list;
    }

    public void addDesignation(String name) throws Exception {
        String clean = name != null ? name.trim() : "";
        if (clean.isEmpty()) throw new IllegalArgumentException("Designation name is required");
        String sql = "INSERT INTO designations (name, is_active) VALUES (?, 1)";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, clean);
            ps.executeUpdate();
        }
    }

    public void deactivateDesignation(String name) throws Exception {
        String clean = name != null ? name.trim() : "";
        String sql = "UPDATE designations SET is_active=0 WHERE name=?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, clean);
            ps.executeUpdate();
        }
    }
}

