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
            new AttendanceDAO().autoCloseMissedPunchOuts();
            System.out.println("[Startup] Missed punch-out cleanup done.");
        } catch (Exception e) {
            System.err.println("[Startup] Auto punch-out cleanup failed: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}