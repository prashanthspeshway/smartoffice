package com.smartoffice.scheduler;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Calendar;
import java.util.Date;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.smartoffice.dao.AttendanceDAO;

@WebListener
public class AttendanceScheduler implements ServletContextListener {

    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer("AttendanceScheduler", true);

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