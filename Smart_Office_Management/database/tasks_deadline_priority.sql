-- Optional migration script to add deadline and priority to tasks
-- Run this once against your Smart Office database.

-- Add deadline column if it does not exist
SET @col_exists_deadline := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'deadline'
);

SET @sql_deadline := IF(
  @col_exists_deadline = 0,
  'ALTER TABLE tasks ADD COLUMN deadline DATE NULL AFTER assigned_date',
  'SELECT 1'
);

PREPARE stmt_deadline FROM @sql_deadline;
EXECUTE stmt_deadline;
DEALLOCATE PREPARE stmt_deadline;

-- Add priority column if it does not exist
SET @col_exists_priority := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'priority'
);

SET @sql_priority := IF(
  @col_exists_priority = 0,
  'ALTER TABLE tasks ADD COLUMN priority VARCHAR(20) NOT NULL DEFAULT ''MEDIUM'' AFTER deadline',
  'SELECT 1'
);

PREPARE stmt_priority FROM @sql_priority;
EXECUTE stmt_priority;
DEALLOCATE PREPARE stmt_priority;

