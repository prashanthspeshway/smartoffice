package com.smartoffice.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import com.smartoffice.dao.AttendanceDAO;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        // ── Step 1: Auto-close missed punch-outs from past days ──────────────────
        // Only runs after 7:30 PM to prevent server restarts during work hours
        // from accidentally closing today's still-open punch records.
        // Today's cleanup is handled by the MySQL scheduled event at 19:30.
        try {
            java.time.LocalTime now = java.time.LocalTime.now();
            if (now.isAfter(java.time.LocalTime.of(19, 30))) {
                new AttendanceDAO().autoCloseMissedPunchOuts();
                System.out.println("[Startup] Missed punch-out cleanup done.");
            } else {
                System.out.println("[Startup] Skipped auto punch-out cleanup — current time is "
                        + now + ", before 19:30. Will be handled by MySQL scheduled event.");
            }
        } catch (Exception e) {
            System.err.println("[Startup] Auto punch-out cleanup failed: " + e.getMessage());
        }

        // ── Step 2: Auto-close missed breaks from past days ──────────────────────
        // If server was down overnight, any open breaks from yesterday won't have
        // been closed. This closes them with end_time = 19:30 of that day.
        try {
            closeOrphanedBreaksFromPastDays();
            System.out.println("[Startup] Orphaned break cleanup done.");
        } catch (Exception e) {
            System.err.println("[Startup] Orphaned break cleanup failed: " + e.getMessage());
        }
    }

    /**
     * Closes any break_logs rows from PAST days that were never ended.
     * Sets end_time = 19:30 of that break_date so duration is calculated properly.
     * Never touches today's records.
     */
    private void closeOrphanedBreaksFromPastDays() throws Exception {
        String sql = "UPDATE break_logs "
                + "SET end_time = TIMESTAMP(break_date, '19:30:00'), "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, TIMESTAMP(break_date, '19:30:00')) "
                + "WHERE end_time IS NULL "
                + "  AND break_date < CURDATE()";   // strictly past days only — never today

        try (java.sql.Connection con = com.smartoffice.utils.DBConnectionUtil.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[Startup] Closed " + rows + " orphaned break(s) from past days.");
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}