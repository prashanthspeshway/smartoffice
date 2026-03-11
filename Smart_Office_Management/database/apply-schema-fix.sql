-- ============================================================
-- APPLY SCHEMA FIX: Match form structure (firstname, lastname)
-- Run this in MySQL Workbench to fix "Failed to add employee"
-- ============================================================

USE smartoffice;

-- 1. Add lastname column if missing (INSERT fails without it)
DROP PROCEDURE IF EXISTS add_lastname_if_missing;
DELIMITER //
CREATE PROCEDURE add_lastname_if_missing()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='lastname') THEN
    ALTER TABLE users ADD COLUMN lastname VARCHAR(100) NULL AFTER firstname;
  END IF;
END //
DELIMITER ;
CALL add_lastname_if_missing();
DROP PROCEDURE add_lastname_if_missing;

-- 2. Add firstname if missing
DROP PROCEDURE IF EXISTS add_firstname_if_missing;
DELIMITER //
CREATE PROCEDURE add_firstname_if_missing()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='firstname') THEN
    ALTER TABLE users ADD COLUMN firstname VARCHAR(100) NULL AFTER fullname;
  END IF;
END //
DELIMITER ;
CALL add_firstname_if_missing();
DROP PROCEDURE add_firstname_if_missing;

-- 3. Phone: up to 10 digits only
UPDATE users SET phone = LEFT(phone, 10) WHERE phone IS NOT NULL AND LENGTH(phone) > 10;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(10) NULL;
