-- ============================================================
-- DROP USERNAME FROM USERS (standalone - run if migration completed but username remains)
-- ============================================================

USE smartoffice;

-- Only drop if column exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'username');

SET @sql = IF(@col_exists > 0, 
  'ALTER TABLE users DROP COLUMN username', 
  'SELECT ''Column username already removed.'' AS result');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Done. Users table now uses email only.' AS result;
