-- ============================================================
-- VERIFY leave_requests TABLE STRUCTURE
-- Run this to see which user column your leave_requests has.
-- ============================================================

USE smartoffice;

-- Show leave_requests columns
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'leave_requests'
ORDER BY ORDINAL_POSITION;
