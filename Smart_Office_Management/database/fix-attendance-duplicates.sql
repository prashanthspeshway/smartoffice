-- ============================================================
-- FIX ATTENDANCE DUPLICATES (works with both username and email columns)
-- Run in MySQL Workbench when you get: Duplicate entry for key 'attendance.uk_attendance'
-- ============================================================

USE smartoffice;

SET FOREIGN_KEY_CHECKS = 0;

-- Detect which column attendance uses (email or username)
SET @user_col = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS 
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'attendance' AND COLUMN_NAME = 'email') > 0,
  'email', 'username'
);

-- 1. Drop unique key if it exists
SET @drop_sql = IF(
  (SELECT COUNT(*) FROM information_schema.STATISTICS 
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'attendance' AND INDEX_NAME = 'uk_attendance') > 0,
  'ALTER TABLE attendance DROP KEY uk_attendance',
  'SELECT 1'
);
PREPARE stmt FROM @drop_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Delete duplicates (keep row with smallest id per user,punch_date)
DROP TEMPORARY TABLE IF EXISTS attendance_ids_to_keep;
SET @create_sql = CONCAT(
  'CREATE TEMPORARY TABLE attendance_ids_to_keep AS ',
  'SELECT MIN(id) AS keep_id FROM attendance GROUP BY ', @user_col, ', punch_date'
);
PREPARE stmt2 FROM @create_sql;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

DELETE FROM attendance WHERE id NOT IN (SELECT keep_id FROM attendance_ids_to_keep);

DROP TEMPORARY TABLE IF EXISTS attendance_ids_to_keep;

-- 3. Add unique key if not present
SET @add_sql = IF(
  (SELECT COUNT(*) FROM information_schema.STATISTICS 
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'attendance' AND INDEX_NAME = 'uk_attendance') = 0,
  CONCAT('ALTER TABLE attendance ADD UNIQUE KEY uk_attendance (', @user_col, ', punch_date)'),
  'SELECT 1'
);
PREPARE stmt3 FROM @add_sql;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

SET FOREIGN_KEY_CHECKS = 1;

SELECT CONCAT('Attendance duplicates fixed. Using column: ', @user_col) AS result;
