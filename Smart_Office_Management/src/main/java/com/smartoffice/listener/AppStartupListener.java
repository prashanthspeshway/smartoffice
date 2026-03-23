package com.smartoffice.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import com.smartoffice.dao.AttendanceDAO;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            java.time.LocalTime now = java.time.LocalTime.now();
            // Only run auto punch-out cleanup after 7:30 PM
            // This prevents server restarts during work hours from closing today's records
            if (now.isAfter(java.time.LocalTime.of(19, 30))) {
                new AttendanceDAO().autoCloseMissedPunchOuts();
                System.out.println("[Startup] Missed punch-out cleanup done.");
            } else {
                System.out.println("[Startup] Skipped auto punch-out cleanup — current time is "
                        + now + ", before 19:30. Will be handled by MySQL event.");
            }
        } catch (Exception e) {
            System.err.println("[Startup] Auto punch-out cleanup failed: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}