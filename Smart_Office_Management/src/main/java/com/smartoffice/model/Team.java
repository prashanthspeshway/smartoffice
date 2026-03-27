package com.smartoffice.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Team {

	private int id;
	private String name;
	private String managerUsername;
	private String managerFullname;
	private String createdBy;
	private Timestamp createdAt;
	private String description;
	private List<User> members = new ArrayList<>();

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getManagerUsername() {
		return managerUsername;
	}

	public void setManagerUsername(String managerUsername) {
		this.managerUsername = managerUsername;
	}

	public String getManagerFullname() {
		return managerFullname;
	}

	public void setManagerFullname(String managerFullname) {
		this.managerFullname = managerFullname;
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

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public List<User> getMembers() {
		return members;
	}

	public void setMembers(List<User> members) {
		this.members = members != null ? members : new ArrayList<>();
	}
}
