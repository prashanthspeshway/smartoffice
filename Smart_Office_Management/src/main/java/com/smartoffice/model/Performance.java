package com.smartoffice.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Performance {

	private int id;
	private String employeeUsername;
	private String managerUsername;
	private String rating;
	private Date performanceMonth;
	private Timestamp createdAt;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getEmployeeUsername() {
		return employeeUsername;
	}

	public void setEmployeeUsername(String employeeUsername) {
		this.employeeUsername = employeeUsername;
	}

	public String getManagerUsername() {
		return managerUsername;
	}

	public void setManagerUsername(String managerUsername) {
		this.managerUsername = managerUsername;
	}

	public String getRating() {
		return rating;
	}

	public void setRating(String rating) {
		this.rating = rating;
	}

	public Date getPerformanceMonth() {
		return performanceMonth;
	}

	public void setPerformanceMonth(Date performanceMonth) {
		this.performanceMonth = performanceMonth;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}
}