package com.smartoffice.dao;

import java.sql.*;
//import java.util.ArrayList;
//import java.util.List;
// 
//import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;
 
public class UserDao {
 
    public void getAllUsers() {
 
//        List<User> users = new ArrayList<>();
 
        String sql = "SELECT id, username, role FROM users";
 
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
 
            while (rs.next()) {
//                User u = new User();
                System.out.println(
                		rs.getInt("id")+
                rs.getString("username")+
                rs.getString("role")
                );
//                users.add(u);
            }
 
        } catch (Exception e) {
            e.printStackTrace();
        }
 
//        return users;
    }
}