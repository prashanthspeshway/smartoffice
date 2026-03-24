package com.smartoffice.controller;
 
import java.io.IOException;
import java.util.Properties;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.smartoffice.dao.UserDao;
import com.smartoffice.model.User;
import com.smartoffice.utils.ConfigUtil;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
 
@SuppressWarnings("serial")
@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
 
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
 
        res.setContentType("text/plain;charset=UTF-8");

        String email = req.getParameter("email");
        if (email == null || email.isBlank()) {
            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            res.getWriter().println("Email is required.");
            return;
        }
        email = email.trim();

        // Check if user exists
        User user = UserDao.getUserByEmail(email);
        if (user == null) {
            res.getWriter().println("If email exists, reset link sent.");
            return;
        }
 
        // Generate token
        String token = UUID.randomUUID().toString();
        long expiryTime = System.currentTimeMillis() + 20 * 60 * 1000; // 20 minutes
 
        // Save token in DB
        UserDao.saveResetToken(email, token, expiryTime);
 
        String baseUrl = req.getRequestURL().toString().replace(req.getServletPath(), "");
        String link = baseUrl + "/resetPassword.jsp?token=" + token;
 
        // Email credentials from config (required for Jakarta Mail)
        String from = ConfigUtil.getProperty("mail.username");
        String password = ConfigUtil.getProperty("mail.password");
        if (from == null || from.isBlank() || password == null) {
            res.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            res.getWriter().println(
                    "Password reset email is not available: mail is not configured. Set mail.username and mail.password in config.properties.");
            return;
        }
        final String mailFrom = from.trim();
        final String mailPassword = password;

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
 
        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(mailFrom, mailPassword);
            }
        });
 
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(mailFrom));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("Password Reset Request");
            message.setText("Click the link to reset your password:\n" + link);
 
            Transport.send(message);
            res.getWriter().println("Reset link sent to your email!");
 
        } catch (MessagingException e) {
            e.printStackTrace();
            res.getWriter().println("Error sending email.");
        }
    }
}
 