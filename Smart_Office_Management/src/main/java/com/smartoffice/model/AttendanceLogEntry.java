package com.smartoffice.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * One row for the employee "Recent Activity Log" (date, punch in/out, break,
 * total, status).
 */
public class AttendanceLogEntry {
	private Date attendanceDate;
	private Timestamp punchIn;
	private Timestamp punchOut;
	private int breakSeconds;
	private String status; // Present, Absent

	public Date getAttendanceDate() {
		return attendanceDate;
	}

	public void setAttendanceDate(Date attendanceDate) {
		this.attendanceDate = attendanceDate;
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

	public int getBreakSeconds() {
		return breakSeconds;
	}

	public void setBreakSeconds(int breakSeconds) {
		this.breakSeconds = breakSeconds;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
}
