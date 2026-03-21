package com.smartoffice.model;

import java.sql.Timestamp;

public class Notification {

    private int id;
    private String recipientEmail;   // NEW — who receives this
    private String message;
    private String createdBy;
    private String type;             // NEW — MEETING, TASK, LEAVE, GENERAL
    private boolean isRead;          // NEW
    private Timestamp createdAt;

    // ── Getters & Setters ──────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRecipientEmail() { return recipientEmail; }
    public void setRecipientEmail(String recipientEmail) { this.recipientEmail = recipientEmail; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}