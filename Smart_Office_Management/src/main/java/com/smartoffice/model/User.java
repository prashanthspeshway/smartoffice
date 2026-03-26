package com.smartoffice.model;

public class User {

	private int id;
	private String username; // email used as username
	private String email;
	private String firstname;
	private String lastname;
	private String teamName;
	private String role;
	private String status;
	private String phone;
	private String designation;
	private java.sql.Date joinedDate;

	public String getDesignation() {
		return designation;
	}

	public void setDesignation(String designation) {
		this.designation = designation;
	}

	public java.sql.Date getJoinedDate() {
		return joinedDate;
	}

	public String getTeamName() {
		return teamName;
	}

	public void setTeamName(String teamName) {
		this.teamName = teamName;
	}

	public void setJoinedDate(java.sql.Date joinedDate) {
		this.joinedDate = joinedDate;
	}

	// getters & setters
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	/** Returns email (session stores it as "username" for compatibility). */
	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getFullname() {
		if (firstname != null || lastname != null) {
			return ((firstname != null ? firstname : "") + " " + (lastname != null ? lastname : "")).trim();
		}
		return null;
	}

	public void setFullname(String fullname) {
		// Kept for compatibility; value is derived from firstname+lastname
	}

	public String getFirstname() {
		return firstname;
	}

	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}

	public String getLastname() {
		return lastname;
	}

	public void setLastname(String lastname) {
		this.lastname = lastname;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}
}
