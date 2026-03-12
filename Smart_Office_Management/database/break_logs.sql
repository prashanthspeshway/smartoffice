-- Break logs table for employee and manager dashboards
-- Run this once on the smartoffice database.

CREATE TABLE IF NOT EXISTS break_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  break_date DATE NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NULL,
  duration_seconds INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_break_email_date (email, break_date),
  CONSTRAINT fk_break_user_email FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

