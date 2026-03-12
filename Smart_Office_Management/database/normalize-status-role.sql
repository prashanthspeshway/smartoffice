-- ============================================================
-- Normalize status and role for case-insensitivity
-- Run this to fix existing data: "active"/"Active"/"ACTIVE" -> "active",
-- "user"/"User"/"USER" -> "employee"
-- ============================================================

USE smartoffice;

-- Normalize status: active, Active, ACTIVE, activi, etc. -> active
UPDATE users SET status = 'active' WHERE LOWER(TRIM(status)) IN ('active', 'activi');
UPDATE users SET status = 'inactive' WHERE LOWER(TRIM(status)) IN ('inactive', 'inacti');

-- Normalize role: user, User, USER -> employee
UPDATE users SET role = 'employee' WHERE LOWER(TRIM(role)) = 'user';
