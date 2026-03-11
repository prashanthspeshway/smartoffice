-- ============================================================
-- FIX TEAMS FK: Recreate teams/team_members with users(email)
-- Run this if team creation fails with "Failed to create team"
-- (e.g. when teams was created with teams-migration.sql referencing users(username))
--
-- WARNING: This DROPS teams and team_members. All team data will be LOST.
-- If you have existing teams to preserve, run remove-username-migration.sql instead.
-- ============================================================

USE smartoffice;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS team_members;
DROP TABLE IF EXISTS teams;

CREATE TABLE teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    manager_username VARCHAR(255) NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_name (name),
    FOREIGN KEY (manager_username) REFERENCES users(email) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE
);

CREATE TABLE team_members (
    team_id INT NOT NULL,
    username VARCHAR(255) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (team_id, username),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES users(email) ON DELETE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;
