-- ============================================================
-- REMOVE USERNAME: Migrate all tables to use email instead
-- Run this ONCE in MySQL Workbench (Ctrl+Shift+Enter for full script)
-- If FK names differ, run: SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA='smartoffice' AND TABLE_NAME='attendance' AND CONSTRAINT_TYPE='FOREIGN KEY';
-- ============================================================

USE smartoffice;

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- Helper: Drop all FKs on a table (dynamic names)
DROP PROCEDURE IF EXISTS drop_table_fks;
DELIMITER //
CREATE PROCEDURE drop_table_fks(IN tbl VARCHAR(64))
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE fk VARCHAR(64);
  DECLARE cur CURSOR FOR SELECT CONSTRAINT_NAME FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME=tbl;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO fk;
    IF done THEN LEAVE read_loop; END IF;
    SET @s = CONCAT('ALTER TABLE `', tbl, '` DROP FOREIGN KEY `', fk, '`');
    PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
  END LOOP;
  CLOSE cur;
END //
DELIMITER ;

-- 1. Ensure users.email is UNIQUE (skip if already exists)
DROP PROCEDURE IF EXISTS add_uk_email;
DELIMITER //
CREATE PROCEDURE add_uk_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND INDEX_NAME='uk_email') THEN
    ALTER TABLE users ADD UNIQUE KEY uk_email (email);
  END IF;
END //
DELIMITER ;
CALL add_uk_email();
DROP PROCEDURE add_uk_email;

-- 2. ATTENDANCE: username -> email (skip if already migrated)
DROP PROCEDURE IF EXISTS migrate_attendance;
DELIMITER //
CREATE PROCEDURE migrate_attendance()
BEGIN
  -- Part A: Migrate username -> email (only if username column exists)
  IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND COLUMN_NAME='username') THEN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND COLUMN_NAME='user_email') THEN
      ALTER TABLE attendance ADD COLUMN user_email VARCHAR(255) NULL;
    END IF;
    UPDATE attendance a JOIN users u ON a.username = u.username SET a.user_email = u.email;
    DELETE FROM attendance WHERE user_email IS NULL;
    ALTER TABLE attendance MODIFY user_email VARCHAR(255) NOT NULL;
    CALL drop_table_fks('attendance');
    ALTER TABLE attendance DROP COLUMN username;
    ALTER TABLE attendance CHANGE user_email email VARCHAR(255) NOT NULL;
  END IF;

  -- Part B: Fix duplicates and ensure uk_attendance (runs when attendance has email OR username)
  SET @att_user_col = IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND COLUMN_NAME='email'),
      'email', 'username');
  IF @att_user_col IN ('email', 'username') THEN
    -- Drop uk_attendance only if it exists
    IF EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND INDEX_NAME='uk_attendance') THEN
      ALTER TABLE attendance DROP KEY uk_attendance;
    END IF;
    -- Delete duplicates: use temp table with correct column (email or username)
    DROP TEMPORARY TABLE IF EXISTS attendance_ids_to_keep;
    SET @sql1 = CONCAT('CREATE TEMPORARY TABLE attendance_ids_to_keep AS SELECT MIN(id) AS keep_id FROM attendance GROUP BY ', @att_user_col, ', punch_date');
    PREPARE stmt1 FROM @sql1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;
    DELETE FROM attendance WHERE id NOT IN (SELECT keep_id FROM attendance_ids_to_keep);
    DROP TEMPORARY TABLE IF EXISTS attendance_ids_to_keep;
    -- Add unique key if not present
    IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND INDEX_NAME='uk_attendance') THEN
      SET @sql2 = CONCAT('ALTER TABLE attendance ADD UNIQUE KEY uk_attendance (', @att_user_col, ', punch_date)');
      PREPARE stmt2 FROM @sql2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;
    END IF;
    -- Add FK if missing (only when we have email - username FKs reference old schema)
    IF @att_user_col = 'email' AND NOT EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='attendance' AND CONSTRAINT_NAME='attendance_ibfk_1') THEN
      ALTER TABLE attendance ADD CONSTRAINT attendance_ibfk_1 FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE;
    END IF;
  END IF;
END //
DELIMITER ;
CALL migrate_attendance();
DROP PROCEDURE migrate_attendance;

-- 3. TASKS: assigned_to, assigned_by -> email
DROP PROCEDURE IF EXISTS add_tasks_email_cols;
DELIMITER //
CREATE PROCEDURE add_tasks_email_cols()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tasks' AND COLUMN_NAME='assigned_to_email') THEN
    ALTER TABLE tasks ADD COLUMN assigned_to_email VARCHAR(255) NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tasks' AND COLUMN_NAME='assigned_by_email') THEN
    ALTER TABLE tasks ADD COLUMN assigned_by_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_tasks_email_cols();
DROP PROCEDURE add_tasks_email_cols;
UPDATE tasks t JOIN users u ON t.assigned_to = u.username SET t.assigned_to_email = u.email;
UPDATE tasks t JOIN users u ON t.assigned_by = u.username SET t.assigned_by_email = u.email;
DELETE FROM tasks WHERE assigned_to_email IS NULL OR assigned_by_email IS NULL;
CALL drop_table_fks('tasks');
ALTER TABLE tasks DROP COLUMN assigned_to;
ALTER TABLE tasks DROP COLUMN assigned_by;
ALTER TABLE tasks CHANGE assigned_to_email assigned_to VARCHAR(255) NOT NULL;
ALTER TABLE tasks CHANGE assigned_by_email assigned_by VARCHAR(255) NOT NULL;
ALTER TABLE tasks ADD CONSTRAINT tasks_ibfk_1 FOREIGN KEY (assigned_to) REFERENCES users(email) ON DELETE CASCADE;
ALTER TABLE tasks ADD CONSTRAINT tasks_ibfk_2 FOREIGN KEY (assigned_by) REFERENCES users(email) ON DELETE CASCADE;

-- 4. MEETINGS: created_by -> email
DROP PROCEDURE IF EXISTS add_meetings_email;
DELIMITER //
CREATE PROCEDURE add_meetings_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='meetings' AND COLUMN_NAME='created_by_email') THEN
    ALTER TABLE meetings ADD COLUMN created_by_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_meetings_email();
DROP PROCEDURE add_meetings_email;
UPDATE meetings m JOIN users u ON m.created_by = u.username SET m.created_by_email = u.email;
DELETE FROM meetings WHERE created_by_email IS NULL;
CALL drop_table_fks('meetings');
ALTER TABLE meetings DROP COLUMN created_by;
ALTER TABLE meetings CHANGE created_by_email created_by VARCHAR(255) NOT NULL;
ALTER TABLE meetings ADD CONSTRAINT meetings_ibfk_1 FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE;

-- 5. NOTIFICATIONS: created_by -> email
DROP PROCEDURE IF EXISTS add_notifications_email;
DELIMITER //
CREATE PROCEDURE add_notifications_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='notifications' AND COLUMN_NAME='created_by_email') THEN
    ALTER TABLE notifications ADD COLUMN created_by_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_notifications_email();
DROP PROCEDURE add_notifications_email;
UPDATE notifications n JOIN users u ON n.created_by = u.username SET n.created_by_email = u.email;
DELETE FROM notifications WHERE created_by_email IS NULL;
CALL drop_table_fks('notifications');
ALTER TABLE notifications DROP COLUMN created_by;
ALTER TABLE notifications CHANGE created_by_email created_by VARCHAR(255) NOT NULL;
ALTER TABLE notifications ADD CONSTRAINT notifications_ibfk_1 FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE;

-- 6. NOTIFICATION_READS: username -> email
DROP PROCEDURE IF EXISTS add_notif_reads_email;
DELIMITER //
CREATE PROCEDURE add_notif_reads_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='notification_reads' AND COLUMN_NAME='user_email') THEN
    ALTER TABLE notification_reads ADD COLUMN user_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_notif_reads_email();
DROP PROCEDURE add_notif_reads_email;
UPDATE notification_reads nr JOIN users u ON nr.username = u.username SET nr.user_email = u.email;
DELETE FROM notification_reads WHERE user_email IS NULL;
ALTER TABLE notification_reads DROP PRIMARY KEY;
CALL drop_table_fks('notification_reads');
ALTER TABLE notification_reads DROP COLUMN username;
ALTER TABLE notification_reads CHANGE user_email email VARCHAR(255) NOT NULL;
ALTER TABLE notification_reads ADD PRIMARY KEY (notification_id, email);
ALTER TABLE notification_reads ADD CONSTRAINT notification_reads_ibfk_2 FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE;

-- 7. LEAVE_REQUESTS: username -> email
DROP PROCEDURE IF EXISTS add_leave_email;
DELIMITER //
CREATE PROCEDURE add_leave_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='leave_requests' AND COLUMN_NAME='user_email') THEN
    ALTER TABLE leave_requests ADD COLUMN user_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_leave_email();
DROP PROCEDURE add_leave_email;
UPDATE leave_requests lr JOIN users u ON lr.username = u.username SET lr.user_email = u.email;
DELETE FROM leave_requests WHERE user_email IS NULL;
CALL drop_table_fks('leave_requests');
ALTER TABLE leave_requests DROP COLUMN username;
ALTER TABLE leave_requests CHANGE user_email email VARCHAR(255) NOT NULL;
ALTER TABLE leave_requests ADD CONSTRAINT leave_requests_ibfk_1 FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE;

-- 8. EMPLOYEE_PERFORMANCE: employee_username, manager_username -> email
DROP PROCEDURE IF EXISTS add_perf_email_cols;
DELIMITER //
CREATE PROCEDURE add_perf_email_cols()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='employee_performance' AND COLUMN_NAME='employee_email') THEN
    ALTER TABLE employee_performance ADD COLUMN employee_email VARCHAR(255) NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='employee_performance' AND COLUMN_NAME='manager_email') THEN
    ALTER TABLE employee_performance ADD COLUMN manager_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_perf_email_cols();
DROP PROCEDURE add_perf_email_cols;
UPDATE employee_performance ep JOIN users u ON ep.employee_username = u.username SET ep.employee_email = u.email;
UPDATE employee_performance ep JOIN users u ON ep.manager_username = u.username SET ep.manager_email = u.email;
DELETE FROM employee_performance WHERE employee_email IS NULL OR manager_email IS NULL;
CALL drop_table_fks('employee_performance');
ALTER TABLE employee_performance DROP KEY uk_perf;
ALTER TABLE employee_performance DROP COLUMN employee_username;
ALTER TABLE employee_performance DROP COLUMN manager_username;
ALTER TABLE employee_performance CHANGE employee_email employee_username VARCHAR(255) NOT NULL;
ALTER TABLE employee_performance CHANGE manager_email manager_username VARCHAR(255) NOT NULL;
ALTER TABLE employee_performance ADD UNIQUE KEY uk_perf (employee_username, performance_month);
ALTER TABLE employee_performance ADD CONSTRAINT employee_performance_ibfk_1 FOREIGN KEY (employee_username) REFERENCES users(email) ON DELETE CASCADE;
ALTER TABLE employee_performance ADD CONSTRAINT employee_performance_ibfk_2 FOREIGN KEY (manager_username) REFERENCES users(email) ON DELETE CASCADE;

-- 9. TEAMS: manager_username, created_by -> email
DROP PROCEDURE IF EXISTS add_teams_email_cols;
DELIMITER //
CREATE PROCEDURE add_teams_email_cols()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='teams' AND COLUMN_NAME='manager_email') THEN
    ALTER TABLE teams ADD COLUMN manager_email VARCHAR(255) NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='teams' AND COLUMN_NAME='created_by_email') THEN
    ALTER TABLE teams ADD COLUMN created_by_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_teams_email_cols();
DROP PROCEDURE add_teams_email_cols;
UPDATE teams t JOIN users u ON t.manager_username = u.username SET t.manager_email = u.email;
UPDATE teams t JOIN users u ON t.created_by = u.username SET t.created_by_email = u.email;
DELETE FROM teams WHERE manager_email IS NULL OR created_by_email IS NULL;
CALL drop_table_fks('teams');
ALTER TABLE teams DROP COLUMN manager_username;
ALTER TABLE teams DROP COLUMN created_by;
ALTER TABLE teams CHANGE manager_email manager_username VARCHAR(255) NOT NULL;
ALTER TABLE teams CHANGE created_by_email created_by VARCHAR(255) NOT NULL;
ALTER TABLE teams ADD CONSTRAINT teams_ibfk_1 FOREIGN KEY (manager_username) REFERENCES users(email) ON DELETE CASCADE;
ALTER TABLE teams ADD CONSTRAINT teams_ibfk_2 FOREIGN KEY (created_by) REFERENCES users(email) ON DELETE CASCADE;

-- 10. TEAM_MEMBERS: username -> email
DROP PROCEDURE IF EXISTS add_tm_email;
DELIMITER //
CREATE PROCEDURE add_tm_email()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='team_members' AND COLUMN_NAME='user_email') THEN
    ALTER TABLE team_members ADD COLUMN user_email VARCHAR(255) NULL;
  END IF;
END //
DELIMITER ;
CALL add_tm_email();
DROP PROCEDURE add_tm_email;
UPDATE team_members tm JOIN users u ON tm.username = u.username SET tm.user_email = u.email;
DELETE FROM team_members WHERE user_email IS NULL;
ALTER TABLE team_members DROP PRIMARY KEY;
CALL drop_table_fks('team_members');
ALTER TABLE team_members DROP COLUMN username;
ALTER TABLE team_members CHANGE user_email username VARCHAR(255) NOT NULL;
ALTER TABLE team_members ADD PRIMARY KEY (team_id, username);
ALTER TABLE team_members ADD CONSTRAINT team_members_ibfk_2 FOREIGN KEY (username) REFERENCES users(email) ON DELETE CASCADE;

-- 11. DROP username from USERS (if exists)
DROP PROCEDURE IF EXISTS drop_users_username;
DELIMITER //
CREATE PROCEDURE drop_users_username()
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='username') THEN
    ALTER TABLE users DROP COLUMN username;
  END IF;
END //
DELIMITER ;
CALL drop_users_username();
DROP PROCEDURE drop_users_username;
DROP PROCEDURE IF EXISTS drop_table_fks;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
