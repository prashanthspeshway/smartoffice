package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class UserDao {

    public static List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        String sql = "SELECT id, username, role, status, email FROM users";

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setRole(rs.getString("role"));
                u.setStatus(rs.getString("status"));
                u.setEmail(rs.getString("email"));

                users.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return users;
    }
}
