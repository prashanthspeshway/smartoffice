package com.smartoffice.model;

import java.sql.Timestamp;

public class Meeting {
	private int id;
	private String title;
	private String description;
	private Timestamp startTime;
	private Timestamp endTime;
	private String meetingLink;
	private String createdBy;
	private Timestamp createdAt;
	private int participantCount;
	
	// ADD THESE NEW FIELDS
	private String creatorName;
	private String creatorRole;

	public Meeting() {
	}

	// ... existing getters and setters ...

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

	public Timestamp getStartTime() {
		return startTime;
	}

	public void setStartTime(Timestamp startTime) {
		this.startTime = startTime;
	}

	public Timestamp getEndTime() {
		return endTime;
	}

	public void setEndTime(Timestamp endTime) {
		this.endTime = endTime;
	}

	public String getMeetingLink() {
		return meetingLink;
	}

	public void setMeetingLink(String meetingLink) {
		this.meetingLink = meetingLink;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public int getParticipantCount() {
		return participantCount;
	}

	public void setParticipantCount(int participantCount) {
		this.participantCount = participantCount;
	}

	// ADD THESE NEW GETTERS AND SETTERS
	public String getCreatorName() {
		return creatorName;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}

	public String getCreatorRole() {
		return creatorRole;
	}

	public void setCreatorRole(String creatorRole) {
		this.creatorRole = creatorRole;
	}
}