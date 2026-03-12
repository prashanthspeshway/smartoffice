package com.smartoffice.model;

import java.sql.Date;
import java.sql.Timestamp;

public class LeaveRequest {

    private int id;
    private String username;
    private String leaveType;
    private Date fromDate;
    private Date toDate;
    public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	/** Email (stored in username field for compatibility). */
	public String getEmail() {
		return username;
	}
	public void setEmail(String email) {
		this.username = email;
	}
	public String getLeaveType() {
		return leaveType;
	}
	public void setLeaveType(String leaveType) {
		this.leaveType = leaveType;
	}
	public Date getFromDate() {
		return fromDate;
	}
	public void setFromDate(Date fromDate) {
		this.fromDate = fromDate;
	}
	public Date getToDate() {
		return toDate;
	}
	public void setToDate(Date toDate) {
		this.toDate = toDate;
	}
	public String getReason() {
		return reason;
	}
	public void setReason(String reason) {
		this.reason = reason;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public Timestamp getAppliedAt() {
		return appliedAt;
	}
	public void setAppliedAt(Timestamp appliedAt) {
		this.appliedAt = appliedAt;
	}
    private String reason;
    private String status;
    private Timestamp appliedAt;
    private String displayName;

    public String getDisplayName() {
        return displayName != null ? displayName : username;
    }
    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

}
