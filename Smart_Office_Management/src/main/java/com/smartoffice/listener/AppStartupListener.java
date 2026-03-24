package com.smartoffice.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import com.smartoffice.dao.AttendanceDAO;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        // ── Step 1: Auto-close missed punch-outs from PAST days ─────────────────
        // Runs unconditionally on every startup — past days are always safe to fix.
        // The SQL in autoCloseMissedPunchOuts() uses punch_date < CURDATE() so it
        // NEVER touches today's still-open records.
        // Today's 19:30 auto-close is handled by the MySQL scheduled event.
        try {
            new AttendanceDAO().autoCloseMissedPunchOuts();
            System.out.println("[Startup] Missed punch-out cleanup done (past days).");
        } catch (Exception e) {
            System.err.println("[Startup] Auto punch-out cleanup failed: " + e.getMessage());
        }

        // ── Step 2: Auto-close orphaned breaks from PAST days ───────────────────
        try {
            closeOrphanedBreaksFromPastDays();
            System.out.println("[Startup] Orphaned break cleanup done.");
        } catch (Exception e) {
            System.err.println("[Startup] Orphaned break cleanup failed: " + e.getMessage());
        }

        // ── Step 3: Ensure MySQL scheduled event exists ─────────────────────────
        // Creates the event if it was never set up — idempotent, safe to run every time.
        try {
            ensureMySQLScheduledEvent();
            System.out.println("[Startup] MySQL scheduled event verified/created.");
        } catch (Exception e) {
            System.err.println("[Startup] MySQL scheduled event setup failed: " + e.getMessage());
        }
    }

    /**
     * Closes any break_logs rows from PAST days that were never ended.
     * Sets end_time = 19:30 of that break_date.
     * Never touches today's records.
     */
    private void closeOrphanedBreaksFromPastDays() throws Exception {
        String sql = "UPDATE break_logs "
                + "SET end_time = TIMESTAMP(break_date, '19:30:00'), "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, TIMESTAMP(break_date, '19:30:00')) "
                + "WHERE end_time IS NULL "
                + "  AND break_date < CURDATE()";  // strictly past days only
        try (java.sql.Connection con = com.smartoffice.utils.DBConnectionUtil.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[Startup] Closed " + rows + " orphaned break(s) from past days.");
            }
        }
    }

    /**
     * Creates (or replaces) a MySQL EVENT that fires every day at 19:30 to:
     *  1. Auto punch-out anyone still punched in today
     *  2. Mark Half Day if they worked < 4 hours
     *  3. Close any open breaks at punch-out time
     *
     * Requires the DB user to have EVENT privilege.
     * If you prefer to manage this in MySQL Workbench manually, you can remove this method.
     */
    private void ensureMySQLScheduledEvent() throws Exception {
        // First enable the event scheduler (safe no-op if already on)
        String enableScheduler = "SET GLOBAL event_scheduler = ON";

        String createEvent =
            "CREATE EVENT IF NOT EXISTS auto_punchout_1930 " +
            "ON SCHEDULE EVERY 1 DAY " +
            "STARTS (CURDATE() + INTERVAL '19:30' HOUR_MINUTE) " +
            "DO BEGIN " +
            "  -- 1. Close open breaks at 19:30 " +
            "  UPDATE break_logs " +
            "  SET end_time = TIMESTAMP(break_date, '19:30:00'), " +
            "      duration_seconds = TIMESTAMPDIFF(SECOND, start_time, TIMESTAMP(break_date, '19:30:00')) " +
            "  WHERE end_time IS NULL AND break_date = CURDATE(); " +
            "  -- 2. Auto punch-out anyone still punched in today " +
            "  UPDATE attendance " +
            "  SET punch_out = TIMESTAMP(CURDATE(), '19:30:00'), " +
            "      status = CASE " +
            "        WHEN TIMESTAMPDIFF(HOUR, punch_in, TIMESTAMP(CURDATE(), '19:30:00')) < 4 THEN 'Half Day' " +
            "        ELSE 'Present' " +
            "      END " +
            "  WHERE punch_in IS NOT NULL " +
            "    AND punch_out IS NULL " +
            "    AND punch_date = CURDATE() " +
            "    AND status NOT IN ('On Leave'); " +
            "END";

        try (java.sql.Connection con = com.smartoffice.utils.DBConnectionUtil.getConnection()) {
            try (java.sql.PreparedStatement ps = con.prepareStatement(enableScheduler)) {
                ps.executeUpdate();
            }
            try (java.sql.PreparedStatement ps = con.prepareStatement(createEvent)) {
                ps.executeUpdate();
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}