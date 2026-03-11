-- Smart Office Management - MySQL Database Schema (email-based, no username)
-- Run this for fresh installs only. For existing DB, run remove-username-migration.sql first.

CREATE DATABASE IF NOT EXISTS smartoffice;
USE smartoffice;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    firstname VARCHAR(100),
    lastname VARCHAR(100),
    role VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(10),
    joinedDate DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ATTENDANCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    punch_date DATE NOT NULL,
    punch_in TIMESTAMP NULL,
    punch_out TIMESTAMP NULL,
    UNIQUE KEY uk_attendance (email, punch_date),
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- HOLIDAYS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_date DATE PRIMARY KEY,
    holiday_name VARCHAR(200) NOT NULL
);

-- ============================================
-- TASKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT NOT NULL,
    title VARCHAR(255) NULL,
    assigned_to VARCHAR(255) NOT NULL,
    assigned_by VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'ASSIGNED',
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- MEETINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS meetings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    meeting_link VARCHAR(500),
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- NOTIFICATION_READS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notification_reads (
    notification_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id, email),
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- LEAVE_REQUESTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS leave_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    leave_type VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'PENDING',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- EMPLOYEE_PERFORMANCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS employee_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_username VARCHAR(255) NOT NULL,
    manager_username VARCHAR(255) NOT NULL,
    rating VARCHAR(50) NOT NULL,
    performance_month DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_perf (employee_username, performance_month),
    FOREIGN KEY (employee_username) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (manager_username) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- TEAMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    manager_username VARCHAR(255) NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_name (name),
    FOREIGN KEY (manager_username) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE
);

-- ============================================
-- TEAM_MEMBERS TABLE (username column stores email)
-- ============================================
CREATE TABLE IF NOT EXISTS team_members (
    team_id INT NOT NULL,
    username VARCHAR(255) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (team_id, username),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES users(email) ON DELETE CASCADE
);
