package com.smartoffice.model;

import java.sql.Timestamp;

/**
 * One row for the admin attendance dashboard: employee + today's punch in/out,
 * break duration, live status.
 */
public class AdminAttendanceRow {

	/** Primary key from users.id — used for single-employee export. */
	private int employeeId;

	private String email;
	private String fullName;
	private String designation;
	private Timestamp punchIn;
	private Timestamp punchOut;
	private String breakDurationFormatted; // e.g. "45m", "1h 10m"
	private String liveStatus; // ON BREAK, PUNCHED IN, PUNCHED OUT, ABSENT
	/**
	 * Raw attendance.status from DB: Present, Half Day, In Progress, Absent, On
	 * Leave
	 */
	private String attendanceStatus;

	public int getEmployeeId() {
		return employeeId;
	}

	public void setEmployeeId(int employeeId) {
		this.employeeId = employeeId;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	public String getDesignation() {
		return designation;
	}

	public void setDesignation(String designation) {
		this.designation = designation;
	}

	public Timestamp getPunchIn() {
		return punchIn;
	}

	public void setPunchIn(Timestamp punchIn) {
		this.punchIn = punchIn;
	}

	public Timestamp getPunchOut() {
		return punchOut;
	}

	public void setPunchOut(Timestamp punchOut) {
		this.punchOut = punchOut;
	}

	public String getBreakDurationFormatted() {
		return breakDurationFormatted;
	}

	public void setBreakDurationFormatted(String v) {
		this.breakDurationFormatted = v;
	}

	public String getLiveStatus() {
		return liveStatus;
	}

	public void setLiveStatus(String liveStatus) {
		this.liveStatus = liveStatus;
	}

	public String getAttendanceStatus() {
		return attendanceStatus;
	}

	public void setAttendanceStatus(String attendanceStatus) {
		this.attendanceStatus = attendanceStatus;
	}
}