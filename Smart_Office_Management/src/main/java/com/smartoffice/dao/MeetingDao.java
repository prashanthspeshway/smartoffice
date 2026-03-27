package com.smartoffice.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.smartoffice.model.Meeting;
import com.smartoffice.model.MeetingParticipant;
import com.smartoffice.utils.DBConnectionUtil;

public class MeetingDao {

	public static List<Meeting> getTodayMeetings(String manager) {
		List<Meeting> list = new ArrayList<>();
		String sql = "SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time, m.meeting_link, m.created_by "
				+ "FROM meetings m " + "LEFT JOIN meeting_participants mp ON m.id = mp.meeting_id "
				+ "WHERE (m.created_by = ? OR mp.user_email = ?) " + "AND DATE(m.start_time) = CURDATE() "
				+ "AND m.start_time > NOW() " + "ORDER BY m.start_time ASC " + "LIMIT 3";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, manager);
			ps.setString(2, manager);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by")); // <-- added
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<Meeting> getAllMeetingsForManager(String managerEmail) {
		List<Meeting> list = new ArrayList<>();
		String sql = "SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time, "
				+ "m.meeting_link, m.created_by " + "FROM meetings m "
				+ "LEFT JOIN meeting_participants mp ON m.id = mp.meeting_id "
				+ "WHERE (m.created_by = ? OR mp.user_email = ?) " + "ORDER BY m.start_time DESC";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, managerEmail);
			ps.setString(2, managerEmail);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<Meeting> getAllMeetings() {
		List<Meeting> list = new ArrayList<>();
		String sql = "SELECT m.*, "
				+ "(SELECT COUNT(*) FROM meeting_participants mp WHERE mp.meeting_id = m.id) as participant_count "
				+ "FROM meetings m " + "ORDER BY m.start_time DESC";
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				m.setParticipantCount(rs.getInt("participant_count"));
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<Meeting> getTodayMeetingsForManager(String manager) {
		List<Meeting> list = new ArrayList<>();
		String sql = """
				SELECT id, title, description, start_time, end_time, meeting_link
				FROM meetings
				WHERE created_by = ?
				AND DATE(start_time) = CURDATE()
				ORDER BY start_time
				""";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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

	public List<Meeting> getMeetingsByAdmin(String adminEmail) {
		List<Meeting> list = new ArrayList<>();

		String sql = "SELECT m.*, "
				+ "(SELECT COUNT(*) FROM meeting_participants mp WHERE mp.meeting_id = m.id) as participant_count "
				+ "FROM meetings m " + "WHERE m.created_by = ? " + "ORDER BY m.start_time DESC";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, adminEmail);

			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				m.setParticipantCount(rs.getInt("participant_count"));
				list.add(m);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	public List<Meeting> getTodayMeetingsForEmployee(String userEmail) {
		List<Meeting> list = new ArrayList<>();
		String sql = """
				SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time,
				       m.meeting_link, m.created_by
				FROM meetings m
				INNER JOIN meeting_participants mp ON m.id = mp.meeting_id
				WHERE mp.user_email = ?
				AND DATE(m.start_time) = CURDATE()
				AND m.start_time > NOW()
				ORDER BY m.start_time ASC
				LIMIT 3
				""";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, userEmail);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<Meeting> getUpcomingMeetingsForEmployee(String userEmail) {
		List<Meeting> list = new ArrayList<>();
		String sql = """
				SELECT DISTINCT m.id, m.title, m.description, m.start_time, m.end_time,
				       m.meeting_link, m.created_by
				FROM meetings m
				INNER JOIN meeting_participants mp ON m.id = mp.meeting_id
				WHERE mp.user_email = ?
				AND m.start_time > NOW()
				ORDER BY m.start_time ASC
				""";
		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, userEmail);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Meeting m = new Meeting();
				m.setId(rs.getInt("id"));
				m.setTitle(rs.getString("title"));
				m.setDescription(rs.getString("description"));
				m.setStartTime(rs.getTimestamp("start_time"));
				m.setEndTime(rs.getTimestamp("end_time"));
				m.setMeetingLink(rs.getString("meeting_link"));
				m.setCreatedBy(rs.getString("created_by"));
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public int createMeeting(Meeting meeting) throws Exception {
		String sql = """
				INSERT INTO meetings (title, description, start_time, end_time, meeting_link, created_by)
				VALUES (?, ?, ?, ?, ?, ?)
				""";

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setString(1, meeting.getTitle());
			ps.setString(2, meeting.getDescription());
			ps.setTimestamp(3, meeting.getStartTime());
			ps.setTimestamp(4, meeting.getEndTime());
			ps.setString(5, meeting.getMeetingLink());
			ps.setString(6, meeting.getCreatedBy());

			int rows = ps.executeUpdate();

			if (rows > 0) {
				ResultSet rs = ps.getGeneratedKeys();
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
			throw new Exception("Failed to create meeting");
		}
	}

	public void addParticipants(int meetingId, List<String> userEmails) throws Exception {
		String sql = "INSERT INTO meeting_participants (meeting_id, user_email) VALUES (?, ?)";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			con.setAutoCommit(false);

			for (String email : userEmails) {
				ps.setInt(1, meetingId);
				ps.setString(2, email);
				ps.addBatch();
			}

			ps.executeBatch();
			con.commit();

		} catch (Exception e) {
			throw new Exception("Failed to add participants: " + e.getMessage());
		}
	}

	public List<MeetingParticipant> getMeetingParticipants(int meetingId) {
		List<MeetingParticipant> list = new ArrayList<>();
		String sql = """
				SELECT mp.user_email,
				       TRIM(CONCAT(COALESCE(u.firstname, ''), ' ', COALESCE(u.lastname, ''))) as fullname,
				       u.role,
				       COALESCE(u.designation, '') as designation
				FROM meeting_participants mp
				INNER JOIN users u ON mp.user_email = u.email
				WHERE mp.meeting_id = ?
				ORDER BY u.firstname, u.lastname
				""";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, meetingId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				MeetingParticipant p = new MeetingParticipant();
				p.setUserEmail(rs.getString("user_email"));
				p.setFullName(rs.getString("fullname"));
				p.setRole(rs.getString("role"));
				p.setDesignation(rs.getString("designation"));
				list.add(p);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<String> getTeamMemberEmails(int teamId) {
		List<String> emails = new ArrayList<>();

		String sql = """
				SELECT DISTINCT u.email
				FROM team_members tm
				JOIN users u ON tm.username = u.username
				WHERE tm.team_id = ?
				""";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, teamId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				emails.add(rs.getString("email"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return emails;
	}

	public List<String> getAllManagerEmails() {
		List<String> emails = new ArrayList<>();
		String sql = "SELECT email FROM users WHERE LOWER(TRIM(role)) = 'manager'";

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				emails.add(rs.getString("email"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return emails;
	}

	public List<String> getAllEmployeeEmails() {
		List<String> emails = new ArrayList<>();
		String sql = "SELECT email FROM users WHERE LOWER(TRIM(role)) = 'employee'";

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				emails.add(rs.getString("email"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return emails;
	}

	public void deleteMeeting(int meetingId) throws Exception {
		String sql = "DELETE FROM meetings WHERE id = ?";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, meetingId);
			ps.executeUpdate();
		}
	}

	public void updateMeeting(Meeting meeting) throws Exception {
		String sql = """
				UPDATE meetings
				SET title = ?, description = ?, start_time = ?, end_time = ?, meeting_link = ?
				WHERE id = ?
				""";

		try (Connection con = DBConnectionUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, meeting.getTitle());
			ps.setString(2, meeting.getDescription());
			ps.setTimestamp(3, meeting.getStartTime());
			ps.setTimestamp(4, meeting.getEndTime());
			ps.setString(5, meeting.getMeetingLink());
			ps.setInt(6, meeting.getId());
			ps.executeUpdate();
		}
	}
}