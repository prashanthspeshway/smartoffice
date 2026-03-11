-- ============================================================
-- SYNC USERNAME FROM FIRSTNAME + LASTNAME
-- Run this to update existing users so username = firstname + lastname
-- (Keeps username column, populates from name fields)
-- ============================================================

USE smartoffice;

-- 1. Update users: username = firstname + lastname
UPDATE users 
SET username = TRIM(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,'')))
WHERE TRIM(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) != '';

-- 2. For users with empty firstname+lastname, set username = email
UPDATE users 
SET username = email
WHERE TRIM(CONCAT(COALESCE(firstname,''), ' ', COALESCE(lastname,''))) = ''
   OR username IS NULL
   OR username = '';

SELECT 'Username synced from firstname + lastname.' AS result;
