package com.smartoffice.model;

public class User {

	private int id;
	private String email;
	private String firstname;
	private String lastname;
	private String role;
	private String status;
	private String phone;

	// getters & setters
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	/** Returns email (session stores it as "username" for compatibility). */
	public String getUsername() {
		return email;
	}

	public void setUsername(String username) {
		this.email = username;
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
