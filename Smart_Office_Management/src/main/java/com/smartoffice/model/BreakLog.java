package com.smartoffice.model;

import java.sql.Timestamp;

public class BreakLog {

	private int id;
	private Timestamp startTime;
	private Timestamp endTime;
	private int durationSeconds;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
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

	public int getDurationSeconds() {
		return durationSeconds;
	}

	public void setDurationSeconds(int durationSeconds) {
		this.durationSeconds = durationSeconds;
	}
}

