package com.smartoffice.model;

import java.sql.Timestamp;

public class TeamAttendance {

    private String username;
    private String fullName;
    private Timestamp punchIn;
    public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getFullName() {
		return fullName;
	}
	public void setFullName(String fullName) {
		this.fullName = fullName;
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
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	private Timestamp punchOut;
    private String status;

}
