-- ============================================================
-- COMPLETE FIX: Remove fullname, manager; phone 10 digits only
-- Run this once in MySQL Workbench
-- ============================================================

USE smartoffice;

SET SQL_SAFE_UPDATES = 0;

-- 1. Add firstname and lastname if missing
DROP PROCEDURE IF EXISTS add_user_columns;
DELIMITER //
CREATE PROCEDURE add_user_columns()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='firstname') THEN
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='fullname') THEN
      ALTER TABLE users ADD COLUMN firstname VARCHAR(100) NULL AFTER fullname;
    ELSE
      ALTER TABLE users ADD COLUMN firstname VARCHAR(100) NULL AFTER role;
    END IF;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='lastname') THEN
    ALTER TABLE users ADD COLUMN lastname VARCHAR(100) NULL AFTER firstname;
  END IF;
END //
DELIMITER ;
CALL add_user_columns();
DROP PROCEDURE add_user_columns;

-- 2. Migrate fullname to firstname/lastname (only if fullname exists)
DROP PROCEDURE IF EXISTS migrate_fullname;
DELIMITER //
CREATE PROCEDURE migrate_fullname()
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='fullname') THEN
    UPDATE users
    SET firstname = TRIM(SUBSTRING_INDEX(COALESCE(fullname, ''), ' ', 1)),
        lastname = CASE WHEN fullname IS NULL OR fullname = '' OR LOCATE(' ', TRIM(fullname)) = 0 THEN NULL
                        ELSE TRIM(SUBSTRING(fullname, LOCATE(' ', TRIM(fullname)) + 1)) END
    WHERE fullname IS NOT NULL AND fullname != '' AND (firstname IS NULL OR firstname = '' OR (lastname IS NULL AND LOCATE(' ', TRIM(fullname)) > 0));
  END IF;
END //
DELIMITER ;
CALL migrate_fullname();
DROP PROCEDURE migrate_fullname;

-- 3. Phone: only up to 10 digits
UPDATE users SET phone = LEFT(phone, 10) WHERE phone IS NOT NULL AND LENGTH(phone) > 10;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(10) NULL;

-- 4. Drop fullname column (if exists)
DROP PROCEDURE IF EXISTS drop_fullname;
DELIMITER //
CREATE PROCEDURE drop_fullname()
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='fullname') THEN
    ALTER TABLE users DROP COLUMN fullname;
  END IF;
END //
DELIMITER ;
CALL drop_fullname();
DROP PROCEDURE drop_fullname;

-- 5. Drop manager column (if exists)
DROP PROCEDURE IF EXISTS drop_manager;
DELIMITER //
CREATE PROCEDURE drop_manager()
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='manager') THEN
    ALTER TABLE users DROP COLUMN manager;
  END IF;
END //
DELIMITER ;
CALL drop_manager();
DROP PROCEDURE drop_manager;

SET SQL_SAFE_UPDATES = 1;
