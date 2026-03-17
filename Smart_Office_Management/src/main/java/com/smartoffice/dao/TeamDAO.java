package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.smartoffice.model.Team;
import com.smartoffice.model.User;
import com.smartoffice.utils.DBConnectionUtil;

public class TeamDAO {

    public static List<Team> getAllTeams() {
        List<Team> list = new ArrayList<>();
        String sql = "SELECT t.id, t.name, t.manager_username, t.created_by, t.created_at, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS manager_fullname " +
                     "FROM teams t LEFT JOIN users u ON t.manager_username = u.email ORDER BY t.name";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Team team = mapTeam(rs);
                team.setMembers(getTeamMembers(con, team.getId()));
                list.add(team);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public static List<Team> getTeamsByManager(String managerUsername) {
        List<Team> list = new ArrayList<>();
        String sql = "SELECT t.id, t.name, t.manager_username, t.created_by, t.created_at, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS manager_fullname " +
                     "FROM teams t LEFT JOIN users u ON t.manager_username = u.email " +
                     "WHERE t.manager_username = ? ORDER BY t.name";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, managerUsername);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Team team = mapTeam(rs);
                    team.setMembers(getTeamMembers(con, team.getId()));
                    list.add(team);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Teams where a given user is a member (used for employee "My Team")
    public static List<Team> getTeamsForMember(String username) {
        List<Team> list = new ArrayList<>();
        String sql = "SELECT DISTINCT t.id, t.name, t.manager_username, t.created_by, t.created_at, " +
                     "TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS manager_fullname " +
                     "FROM teams t " +
                     "JOIN team_members tm ON tm.team_id = t.id " +
                     "LEFT JOIN users u ON t.manager_username = u.email " +
                     "WHERE tm.username = ? ORDER BY t.name";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Team team = mapTeam(rs);
                    team.setMembers(getTeamMembers(con, team.getId()));
                    list.add(team);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static Team getTeamById(int teamId) {
        Team team = null;
        String sql = "SELECT t.id, t.name, t.manager_username, t.created_by, t.created_at, TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,''))) AS manager_fullname " +
                     "FROM teams t LEFT JOIN users u ON t.manager_username = u.email WHERE t.id = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    team = mapTeam(rs);
                    team.setMembers(getTeamMembers(con, team.getId()));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return team;
    }

    public static boolean createTeam(String name, String managerUsername, String createdBy) {
        String sql = "INSERT INTO teams (name, manager_username, created_by) VALUES (?, ?, ?)";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setString(2, managerUsername);
            ps.setString(3, createdBy);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean addMemberToTeam(int teamId, String username) {
        String insertSql = "INSERT IGNORE INTO team_members (team_id, username) VALUES (?, ?)";
        String managerSql = "SELECT manager_username FROM teams WHERE id = ?";
        String updateUserSql = "UPDATE users SET manager_email = ? WHERE email = ?";

        try (Connection con = DBConnectionUtil.getConnection()) {

            // Step 1: Add member
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, teamId);
                ps.setString(2, username);
                ps.executeUpdate();
            }

            // Step 2: Get manager of that team
            String managerEmail = null;
            try (PreparedStatement ps = con.prepareStatement(managerSql)) {
                ps.setInt(1, teamId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    managerEmail = rs.getString("manager_username");
                }
            }

            // Step 3: Update user's manager
            if (managerEmail != null) {
                try (PreparedStatement ps = con.prepareStatement(updateUserSql)) {
                    ps.setString(1, managerEmail);
                    ps.setString(2, username);
                    ps.executeUpdate();
                }
            }

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean removeMemberFromTeam(int teamId, String username) {

        String deleteSql = "DELETE FROM team_members WHERE team_id = ? AND username = ?";
        String clearManagerSql = "UPDATE users SET manager_email = NULL WHERE email = ?";

        try (Connection con = DBConnectionUtil.getConnection()) {

            // Remove from team
            try (PreparedStatement ps = con.prepareStatement(deleteSql)) {
                ps.setInt(1, teamId);
                ps.setString(2, username);
                ps.executeUpdate();
            }

            // Clear manager
            try (PreparedStatement ps = con.prepareStatement(clearManagerSql)) {
                ps.setString(1, username);
                ps.executeUpdate();
            }

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updateTeamManager(int teamId, String managerUsername) {

        String updateTeamSql = "UPDATE teams SET manager_username = ? WHERE id = ?";
        String updateUsersSql = 
            "UPDATE users SET manager_email = ? WHERE email IN " +
            "(SELECT username FROM team_members WHERE team_id = ?)";

        try (Connection con = DBConnectionUtil.getConnection()) {

            // Step 1: Update team
            try (PreparedStatement ps = con.prepareStatement(updateTeamSql)) {
                ps.setString(1, managerUsername);
                ps.setInt(2, teamId);
                ps.executeUpdate();
            }

            // Step 2: Update all members
            try (PreparedStatement ps = con.prepareStatement(updateUsersSql)) {
                ps.setString(1, managerUsername);
                ps.setInt(2, teamId);
                ps.executeUpdate();
            }

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteTeam(int teamId) {
        String sql = "DELETE FROM teams WHERE id = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static Set<String> getEmailsInAnyTeam() {
        Set<String> set = new HashSet<>();
        String sql = "SELECT username FROM team_members";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                set.add(rs.getString("username"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return set;
    }

    public static boolean teamNameExists(String name) {
        String sql = "SELECT 1 FROM teams WHERE LOWER(TRIM(name)) = LOWER(TRIM(?))";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static Team mapTeam(ResultSet rs) throws Exception {
        Team t = new Team();
        t.setId(rs.getInt("id"));
        t.setName(rs.getString("name"));
        t.setManagerUsername(rs.getString("manager_username"));
        t.setManagerFullname(rs.getString("manager_fullname"));
        t.setCreatedBy(rs.getString("created_by"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }

    private static List<User> getTeamMembers(Connection con, int teamId) throws Exception {
        List<User> members = new ArrayList<>();
        String sql = "SELECT u.id, u.email, u.firstname, u.lastname, u.phone, u.role, u.status " +
                     "FROM team_members tm JOIN users u ON tm.username = u.email WHERE tm.team_id = ? ORDER BY u.firstname, u.lastname";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("email"));
                    u.setFirstname(rs.getString("firstname"));
                    u.setLastname(rs.getString("lastname"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setRole(rs.getString("role"));
                    u.setStatus(rs.getString("status"));
                    members.add(u);
                }
            }
        }
        return members;
    }
}
