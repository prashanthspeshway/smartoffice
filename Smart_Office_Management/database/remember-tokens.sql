-- Remember-me tokens for persistent login (survives server restarts)
USE smartoffice;

CREATE TABLE IF NOT EXISTS remember_tokens (
    token VARCHAR(64) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE,
    INDEX idx_email (email),
    INDEX idx_expires (expires_at)
);
