package com.smartoffice.model;
 
public class TokenData {
	 private String email;
	    private long expiryTime;
 
	    public TokenData(String email, long expiryTime) {
	        this.email = email;
	        this.expiryTime = expiryTime;
	    }
 
	    public String getEmail() { return email; }
	    public long getExpiryTime() { return expiryTime; }
}
 
 