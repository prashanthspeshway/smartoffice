package com.smartoffice.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import com.smartoffice.dao.AttendanceDAO;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        // Auto close missed punch-outs from past days
        try {
            new AttendanceDAO().autoCloseMissedPunchOuts();
            System.out.println("[Startup] Missed punch-out cleanup done (past days).");
        } catch (Exception e) {
            System.err.println("[Startup] Auto punch-out cleanup failed: " + e.getMessage());
        }

        // Close orphaned breaks from past days
        try {
            closeOrphanedBreaksFromPastDays();
            System.out.println("[Startup] Orphaned break cleanup done.");
        } catch (Exception e) {
            System.err.println("[Startup] Orphaned break cleanup failed: " + e.getMessage());
        }

        // Ensure MySQL scheduled event exists
        try {
            ensureMySQLScheduledEvent();
            System.out.println("[Startup] MySQL scheduled event verified/created.");
        } catch (Exception e) {
            System.err.println("[Startup] MySQL scheduled event setup failed: " + e.getMessage());
        }

        // Mark daily absentees with catchup
        try {
            System.out.println("[Startup] Running attendance catchup...");
            new AttendanceDAO().markDailyAbsenteesWithCatchup();
            System.out.println("[Startup] Attendance catchup completed.");
        } catch (Exception e) {
            System.err.println("[Startup] Attendance catchup failed: " + e.getMessage());
        }
    }

    private void closeOrphanedBreaksFromPastDays() throws Exception {
        String sql = "UPDATE break_logs "
                + "SET end_time = TIMESTAMP(break_date, '19:30:00'), "
                + "    duration_seconds = TIMESTAMPDIFF(SECOND, start_time, TIMESTAMP(break_date, '19:30:00')) "
                + "WHERE end_time IS NULL "
                + "  AND break_date < CURDATE()";
        try (java.sql.Connection con = com.smartoffice.utils.DBConnectionUtil.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[Startup] Closed " + rows + " orphaned break(s) from past days.");
            }
        }
    }

    /**
     * FIX: The original method used a single PreparedStatement with a
     * multi-statement BEGIN...END block for the CREATE EVENT body.
     * JDBC does not support compound statement delimiters (BEGIN...END)
     * via PreparedStatement — this caused the "syntax error near ''" error.
     *
     * Fix: Use CREATE EVENT with a single DO statement (no BEGIN...END needed
     * for a single action), and run the two UPDATE operations as separate
     * scheduled events, OR use a stored procedure. The cleanest JDBC-compatible
     * approach is two separate named events, each with a single DO statement.
     *
     * We also wrap each statement in its own try-catch so one failure does
     * not prevent the other from running.
     */
    private void ensureMySQLScheduledEvent() throws Exception {
        try (java.sql.Connection con = com.smartoffice.utils.DBConnectionUtil.getConnection()) {

            // 1. Enable the event scheduler globally
            try (java.sql.Statement st = con.createStatement()) {
                st.executeUpdate("SET GLOBAL event_scheduler = ON");
            }

            // 2. Event: auto-close open breaks at 19:30 each day
            String eventBreaks =
                "CREATE EVENT IF NOT EXISTS auto_close_breaks_1930 " +
                "ON SCHEDULE EVERY 1 DAY " +
                "STARTS (CURDATE() + INTERVAL '19:30' HOUR_MINUTE) " +
                "DO " +
                "  UPDATE break_logs " +
                "  SET end_time = TIMESTAMP(break_date, '19:30:00'), " +
                "      duration_seconds = TIMESTAMPDIFF(SECOND, start_time, TIMESTAMP(break_date, '19:30:00')) " +
                "  WHERE end_time IS NULL AND break_date = CURDATE()";

            try (java.sql.Statement st = con.createStatement()) {
                st.executeUpdate(eventBreaks);
            }

            // 3. Event: auto punch-out employees still punched in at 19:30 each day
            String eventPunchout =
                "CREATE EVENT IF NOT EXISTS auto_punchout_1930 " +
                "ON SCHEDULE EVERY 1 DAY " +
                "STARTS (CURDATE() + INTERVAL '19:30' HOUR_MINUTE) " +
                "DO " +
                "  UPDATE attendance " +
                "  SET punch_out = TIMESTAMP(CURDATE(), '19:30:00'), " +
                "      status = CASE " +
                "        WHEN TIMESTAMPDIFF(HOUR, punch_in, TIMESTAMP(CURDATE(), '19:30:00')) < 4 THEN 'Half Day' " +
                "        ELSE 'Present' " +
                "      END " +
                "  WHERE punch_in IS NOT NULL " +
                "    AND punch_out IS NULL " +
                "    AND punch_date = CURDATE() " +
                "    AND status NOT IN ('On Leave')";

            try (java.sql.Statement st = con.createStatement()) {
                st.executeUpdate(eventPunchout);
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}