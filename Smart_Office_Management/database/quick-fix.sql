-- ============================================================
-- QUICK FIX: Sync firstname/lastname with fullname
-- Copy-paste into MySQL Workbench and run (Ctrl+Shift+Enter)
-- ============================================================

USE smartoffice;
SET SQL_SAFE_UPDATES = 0;

-- If lastname column is missing, run: ALTER TABLE users ADD COLUMN lastname VARCHAR(100) NULL AFTER firstname;

-- 1. Populate firstname/lastname from fullname
UPDATE users u
JOIN (SELECT id, fullname FROM users WHERE fullname IS NOT NULL AND fullname != '') t ON u.id = t.id
SET
  u.firstname = TRIM(SUBSTRING_INDEX(t.fullname, ' ', 1)),
  u.lastname = CASE
    WHEN LOCATE(' ', TRIM(t.fullname)) = 0 THEN NULL
    ELSE TRIM(SUBSTRING(t.fullname, LOCATE(' ', TRIM(t.fullname)) + 1))
  END;

-- 2. Keep fullname in sync (for backward compatibility)
UPDATE users u
SET u.fullname = TRIM(CONCAT(COALESCE(u.firstname,''), ' ', COALESCE(u.lastname,'')))
WHERE u.firstname IS NOT NULL OR u.lastname IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;
