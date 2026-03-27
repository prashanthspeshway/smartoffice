package com.smartoffice.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.smartoffice.utils.DBConnectionUtil;

public class AdminDAO {

	public int getManagerCount() throws Exception {
		return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) = 'manager'");
	}

	public int getEmployeeCount() throws Exception {
		return getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('user', 'employee')");
	}

	public int getPresentTodayCount() throws Exception {
		String userCol = hasAttendanceUserColumn();
		String sql = "SELECT COUNT(DISTINCT " + userCol + ") FROM attendance "
				+ "WHERE punch_date = CURDATE() AND punch_in IS NOT NULL";
		return getCount(sql);
	}

	/** Returns 'email' or 'username' depending on attendance table schema. */
	private String hasAttendanceUserColumn() throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement("SELECT 1 FROM information_schema.COLUMNS "
						+ "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'attendance' AND COLUMN_NAME = 'email'");
				ResultSet rs = ps.executeQuery()) {
			return rs.next() ? "email" : "username";
		}
	}

	public int getAbsentTodayCount() throws Exception {
		int total = getCount("SELECT COUNT(*) FROM users WHERE LOWER(TRIM(role)) IN ('manager', 'user', 'employee')");
		int present = getPresentTodayCount();
		return total - present;
	}

	/** Reusable single-value COUNT helper. */
	private int getCount(String sql) throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			return rs.next() ? rs.getInt(1) : 0;
		}
	}

	public List<String> getUpcomingHolidays() throws Exception {
		List<String> list = new ArrayList<>();
		String sql = """
				    SELECT holiday_name
				    FROM holidays
				    WHERE holiday_date >= CURDATE()
				    ORDER BY holiday_date
				    LIMIT 5
				""";
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				list.add(rs.getString("holiday_name"));
			}
		}
		return list;
	}
	
	public int getAttendanceRate() throws Exception {
		String sql = "SELECT ROUND( " + "  COUNT(*) * 100.0 / " + "  ( (SELECT COUNT(*) FROM users "
				+ "     WHERE LOWER(TRIM(role)) IN ('manager','user','employee')) "
				+ "    * COUNT(DISTINCT punch_date) " + "  ), 0) AS rate " + "FROM attendance "
				+ "WHERE YEAR(punch_date)  = YEAR(CURDATE()) " + "  AND MONTH(punch_date) = MONTH(CURDATE()) "
				+ "  AND punch_in IS NOT NULL";
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			return rs.next() ? rs.getInt("rate") : 0;
		}
	}

	public int getTasksCompletedThisMonth() throws Exception {
		return getCount("SELECT COUNT(*) FROM tasks " + "WHERE UPPER(TRIM(status)) = 'COMPLETED' "
				+ "  AND YEAR(submitted_at)  = YEAR(CURDATE()) " + "  AND MONTH(submitted_at) = MONTH(CURDATE())");
	}

	public int getLeavesPending() throws Exception {
		return getCount("SELECT COUNT(*) FROM leave_requests " + "WHERE UPPER(TRIM(status)) = 'PENDING'");
	}

	public int getActiveTeams() throws Exception {
		return getCount("SELECT COUNT(*) FROM teams");
	}

	public String getWeekPresent() throws Exception {
		return buildWeekSeries("present");
	}

	public String getWeekAbsent() throws Exception {
		return buildWeekSeries("absent");
	}

	private String buildWeekSeries(String type) throws Exception {
		String userCol = hasAttendanceUserColumn();
		String sql = "SELECT d.day_date, " + "       COALESCE(a.present_count, 0) AS present_count, "
				+ "       (SELECT COUNT(*) FROM users "
				+ "        WHERE LOWER(TRIM(role)) IN ('manager','user','employee')) "
				+ "       - COALESCE(a.present_count, 0) AS absent_count " + "FROM ( "
				+ "  SELECT CURDATE() - INTERVAL (6 - seq) DAY AS day_date "
				+ "  FROM (SELECT 0 seq UNION SELECT 1 UNION SELECT 2 UNION "
				+ "               SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) n " + ") d " + "LEFT JOIN ( "
				+ "  SELECT punch_date, COUNT(DISTINCT " + userCol + ") AS present_count " + "  FROM attendance "
				+ "  WHERE punch_date >= CURDATE() - INTERVAL 6 DAY " + "    AND punch_in IS NOT NULL "
				+ "  GROUP BY punch_date " + ") a ON d.day_date = a.punch_date " + "ORDER BY d.day_date";

		StringBuilder sb = new StringBuilder();
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			boolean first = true;
			while (rs.next()) {
				if (!first)
					sb.append(",");
				sb.append(rs.getInt(type.equals("present") ? "present_count" : "absent_count"));
				first = false;
			}
		}
		return sb.length() > 0 ? sb.toString() : "0,0,0,0,0,0,0";
	}

	public String getAttendanceTrend() throws Exception {
		String userCol = hasAttendanceUserColumn();
		String sql = "SELECT d.day_date, " + "       COALESCE(ROUND(a.present_count * 100.0 / "
				+ "         (SELECT COUNT(*) FROM users "
				+ "          WHERE LOWER(TRIM(role)) IN ('manager','user','employee')), 0), 0) AS pct " + "FROM ( "
				+ "  SELECT CURDATE() - INTERVAL (29 - seq) DAY AS day_date "
				+ "  FROM (SELECT 0 seq  UNION SELECT 1  UNION SELECT 2  UNION SELECT 3  UNION "
				+ "               SELECT 4  UNION SELECT 5  UNION SELECT 6  UNION SELECT 7  UNION "
				+ "               SELECT 8  UNION SELECT 9  UNION SELECT 10 UNION SELECT 11 UNION "
				+ "               SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION "
				+ "               SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION "
				+ "               SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION "
				+ "               SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION "
				+ "               SELECT 28 UNION SELECT 29) n " + ") d " + "LEFT JOIN ( "
				+ "  SELECT punch_date, COUNT(DISTINCT " + userCol + ") AS present_count " + "  FROM attendance "
				+ "  WHERE punch_date >= CURDATE() - INTERVAL 29 DAY " + "    AND punch_in IS NOT NULL "
				+ "  GROUP BY punch_date " + ") a ON d.day_date = a.punch_date " + "ORDER BY d.day_date";

		StringBuilder sb = new StringBuilder();
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			boolean first = true;
			while (rs.next()) {
				if (!first)
					sb.append(",");
				sb.append(rs.getInt("pct"));
				first = false;
			}
		}
		return sb.length() > 0 ? sb.toString() : "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
	}

	public String getPunchInDistribution() throws Exception {
		int[] buckets = new int[5];
		String sql = "SELECT HOUR(punch_in) AS hr, COUNT(*) AS cnt " + "FROM attendance "
				+ "WHERE punch_date >= CURDATE() - INTERVAL 6 DAY " + "  AND punch_in IS NOT NULL "
				+ "GROUP BY HOUR(punch_in)";

		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				int hr = rs.getInt("hr");
				int cnt = rs.getInt("cnt");
				if (hr < 8)
					buckets[0] += cnt;
				else if (hr == 8)
					buckets[1] += cnt;
				else if (hr == 9)
					buckets[2] += cnt;
				else if (hr == 10)
					buckets[3] += cnt;
				else
					buckets[4] += cnt;
			}
		}
		return buckets[0] + "," + buckets[1] + "," + buckets[2] + "," + buckets[3] + "," + buckets[4];
	}

	public int getTaskCountByStatus(String status) throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con
						.prepareStatement("SELECT COUNT(*) FROM tasks WHERE UPPER(TRIM(status)) = ?")) {
			ps.setString(1, status.toUpperCase().trim());
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	public int getLeaveCountByType(String type) throws Exception {
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con
						.prepareStatement("SELECT COUNT(*) FROM leave_requests WHERE UPPER(TRIM(leave_type)) = ?")) {
			ps.setString(1, type.toUpperCase().trim());
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getInt(1) : 0;
			}
		}
	}

	public List<String> getDistinctLeaveTypes() throws Exception {
		List<String> types = new ArrayList<>();
		String sql = "SELECT DISTINCT TRIM(leave_type) FROM leave_requests ORDER BY leave_type";
		try (Connection con = DBConnectionUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next())
				types.add(rs.getString(1));
		}
		return types;
	}
}