-- Teams feature migration - run this if you already have the database
-- Or it's included in the full schema
-- NOTE: Uses users(email) - schema is email-based (no username column)

USE smartoffice;

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
