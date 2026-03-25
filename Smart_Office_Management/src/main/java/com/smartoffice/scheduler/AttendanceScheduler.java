package com.smartoffice.scheduler;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Calendar;
import java.util.Date;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.smartoffice.dao.AttendanceDAO;

/**
 * AttendanceScheduler
 *
 * Runs once automatically every day at 11:59 PM by listening to the
 * ServletContext lifecycle (starts when the app deploys, stops when it undeploys).
 *
 * What it does at 11:59 PM every night:
 *   1. Auto-closes any punch-ins that were never punched out (sets 19:30 as punch-out).
 *   2. Writes "On Leave" rows for every employee with an approved leave for today.
 *   3. Writes "Absent" rows for every non-admin who had no attendance today
 *      and was not on leave and today was not a weekend/holiday.
 *   4. Recalculates Half Day / Present for all of today's closed rows.
 *
 * To register this listener, add it to web.xml:
 *
 *   <listener>
 *       <listener-class>com.smartoffice.scheduler.AttendanceScheduler</listener-class>
 *   </listener>
 *
 * Or the @WebListener annotation (already present) handles it automatically
 * if your project uses annotation scanning.
 */
@WebListener
public class AttendanceScheduler implements ServletContextListener {

    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer("AttendanceScheduler", true);

        // Schedule: every 24 hours starting at the next 23:59:00
        Date firstRun = nextRunTime(23, 59, 0);
        long period   = 24 * 60 * 60 * 1000L; // 24 hours in ms

        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                try {
                    System.out.println("[AttendanceScheduler] Running end-of-day job at " + new Date());
                    new AttendanceDAO().runEndOfDayJob();
                    System.out.println("[AttendanceScheduler] End-of-day job completed successfully.");
                } catch (Exception ex) {
                    System.err.println("[AttendanceScheduler] End-of-day job failed: " + ex.getMessage());
                    ex.printStackTrace();
                }
            }
        }, firstRun, period);

        System.out.println("[AttendanceScheduler] Scheduled. First run at: " + firstRun);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            System.out.println("[AttendanceScheduler] Timer cancelled on context destroy.");
        }
    }

    /**
     * Calculate the next occurrence of hh:mm:ss today (or tomorrow if that
     * time has already passed today).
     */
    private Date nextRunTime(int hour, int minute, int second) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, hour);
        cal.set(Calendar.MINUTE, minute);
        cal.set(Calendar.SECOND, second);
        cal.set(Calendar.MILLISECOND, 0);
        if (cal.getTime().before(new Date())) {
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }
        return cal.getTime();
    }
}