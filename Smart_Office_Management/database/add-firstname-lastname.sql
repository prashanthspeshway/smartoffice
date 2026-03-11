-- Add firstname and lastname columns to users table
-- Run this if you already have the database

USE smartoffice;

ALTER TABLE users
ADD COLUMN firstname VARCHAR(100) NULL AFTER fullname,
ADD COLUMN lastname VARCHAR(100) NULL AFTER firstname;

-- Migrate existing fullname data: split into first/last
UPDATE users
SET
  firstname = TRIM(SUBSTRING_INDEX(COALESCE(fullname, ''), ' ', 1)),
  lastname = CASE
    WHEN fullname IS NULL OR fullname = '' OR LOCATE(' ', TRIM(fullname)) = 0 THEN NULL
    ELSE TRIM(SUBSTRING(fullname, LOCATE(' ', TRIM(fullname)) + 1))
  END
WHERE fullname IS NOT NULL AND fullname != '';
