package com.smartoffice.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.smartoffice.model.Meeting;
import com.smartoffice.utils.DBConnectionUtil;

public class MeetingDao {

    public static List<Meeting> getTodayMeetings(String manager) {

        List<Meeting> list = new ArrayList<>();

        String sql =
            "SELECT id, title, description, start_time, end_time, meeting_link " +
            "FROM meetings " +
            "WHERE created_by = ? " +
            "AND DATE(start_time) = CURDATE() " +
            "ORDER BY start_time";

        try (
            Connection con = DBConnectionUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, manager);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Meeting m = new Meeting();
                m.setId(rs.getInt("id"));
                m.setTitle(rs.getString("title"));
                m.setDescription(rs.getString("description"));
                m.setStartTime(rs.getTimestamp("start_time"));
                m.setEndTime(rs.getTimestamp("end_time"));
                m.setMeetingLink(rs.getString("meeting_link"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}