package com.smartoffice.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Notification implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String recipientEmail;
    private String message;
    private String createdBy;
    private String type;
    private boolean read;
    private Timestamp createdAt;


    public Notification() {}

    public Notification(int id, String recipientEmail, String message,
                        String createdBy, String type, boolean read,
                        Timestamp createdAt) {
        this.id = id;
        this.recipientEmail = recipientEmail;
        this.message = message;
        this.createdBy = createdBy;
        this.type = type;
        this.read = read;
        this.createdAt = createdAt;
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRecipientEmail() {
        return recipientEmail;
    }

    public void setRecipientEmail(String recipientEmail) {
        this.recipientEmail = recipientEmail;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", recipientEmail='" + recipientEmail + '\'' +
                ", message='" + message + '\'' +
                ", createdBy='" + createdBy + '\'' +
                ", type='" + type + '\'' +
                ", read=" + read +
                ", createdAt=" + createdAt +
                '}';
    }
}