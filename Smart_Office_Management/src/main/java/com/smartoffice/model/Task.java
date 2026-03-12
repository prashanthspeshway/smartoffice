package com.smartoffice.model;

import java.sql.Timestamp;
import java.sql.Date;
 
public class Task {
 
	private int id;
	private String title;
	private String description;
	private String attachmentName;
	private String assignedTo;
	private String assignedBy;
	private String status;
	private Timestamp assignedDate;
	private Date deadline;
	private String priority;
 
	public int getId() {
		return id;
	}
 
	public void setId(int id) {
		this.id = id;
	}
 
	public String getTitle() {
		return title;
	}
 
	public void setTitle(String title) {
		this.title = title;
	}
 
	public String getDescription() {
		return description;
	}
 
	public void setDescription(String description) {
		this.description = description;
	}
 
	public String getAttachmentName() {
		return attachmentName;
	}

	public void setAttachmentName(String attachmentName) {
		this.attachmentName = attachmentName;
	}
 
	public String getAssignedTo() {
		return assignedTo;
	}
 
	public void setAssignedTo(String assignedTo) {
		this.assignedTo = assignedTo;
	}
 
	public String getAssignedBy() {
		return assignedBy;
	}
 
	public void setAssignedBy(String assignedBy) {
		this.assignedBy = assignedBy;
	}
 
	public String getStatus() {
		return status;
	}
 
	public void setStatus(String status) {
		this.status = status;
	}
 
	public Timestamp getAssignedDate() {
		return assignedDate;
	}
 
	public void setAssignedDate(Timestamp assignedDate) {
		this.assignedDate = assignedDate;
	}

	public Date getDeadline() {
		return deadline;
	}

	public void setDeadline(Date deadline) {
		this.deadline = deadline;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}
 
	public void setCreatedAt(Timestamp timestamp) {
		// TODO Auto-generated method stub
		
	}
}
 
 
