-- Optional migration script to add attachment support to tasks
-- Run this once against your Smart Office database.

-- Add attachment_name column if it does not exist
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'attachment_name'
);

SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE tasks ADD COLUMN attachment_name VARCHAR(255) NULL AFTER title',
  'SELECT 1'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add attachment column if it does not exist
SET @col_exists2 := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'attachment'
);

SET @sql2 := IF(
  @col_exists2 = 0,
  'ALTER TABLE tasks ADD COLUMN attachment LONGBLOB NULL AFTER attachment_name',
  'SELECT 1'
);

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

