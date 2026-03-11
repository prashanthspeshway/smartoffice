package com.smartoffice.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Ensures only one active session per browser. Validates session token and enforces role-based access.
 * Public paths: index.html, Login, logout, initAdmin, static assets.
 */
@WebFilter(urlPatterns = "/*")
public class SessionAuthFilter implements Filter {

    private static final List<String> PUBLIC_PATHS = Arrays.asList(
        "/", "/index.html", "/Login", "/login", "/logout", "/initAdmin"
    );

    private static boolean isPublicPath(String path) {
        if (path == null) return true;
        String p = path.toLowerCase();
        for (String pub : PUBLIC_PATHS) {
            if (p.equals(pub.toLowerCase()) || p.equals(pub.toLowerCase() + "/")) return true;
        }
        if (p.endsWith("index.html")) return true;
        return p.endsWith(".css") || p.endsWith(".js") || p.endsWith(".png")
            || p.endsWith(".jpg") || p.endsWith(".jpeg") || p.endsWith(".gif")
            || p.endsWith(".ico") || p.endsWith(".svg") || p.endsWith(".woff")
            || p.endsWith(".woff2") || p.endsWith(".ttf");
    }

    private static boolean isAdminPath(String path) {
        if (path == null) return false;
        String p = path.toLowerCase();
        return p.contains("admin") || p.contains("adminoverview") || p.contains("adduser")
            || p.contains("viewuser") || p.contains("/teams") || p.contains("deleteuser")
            || p.contains("edituser") || p.contains("bulkupload") || p.contains("exportusers")
            || p.contains("addholiday") || p.contains("getholidays") || p.contains("deleteholiday")
            || p.contains("updateholiday") || p.contains("getholidaybydate")
            || p.contains("addnotification") || p.contains("enableanddisable")
            || p.contains("adminsettings") || p.contains("sendnotification")
            || p.contains("employeeoverview") || p.contains("usercheck");
    }

    private static boolean isManagerPath(String path) {
        if (path == null) return false;
        String p = path.toLowerCase();
        return (p.contains("/manager") && !p.contains("manager_")) || p.contains("assigntask")
            || p.contains("leave-approval") || p.contains("schedulemeeting")
            || p.contains("todaymeetings") || p.contains("allmeetings")
            || p.contains("viewmeetings") || p.contains("exportteamperformance")
            || p.contains("exportteamattendance") || p.contains("viewassignedtasks")
            || p.contains("submitperformance");
    }

    private static boolean isUserPath(String path) {
        if (path == null) return false;
        String p = path.toLowerCase();
        return p.equals("/user") || p.startsWith("/user?") || p.contains("applyleave");
    }

    private static String getRedirectForRole(String role) {
        if (role == null) return "/index.html";
        switch (role.toLowerCase()) {
            case "admin": return "/admin.jsp";
            case "manager": return "/manager";
            case "user":
            case "employee": return "/user";
            default: return "/index.html";
        }
    }

    /** Redirects the top window (fixes iframe: login form no longer appears inside dashboard). */
    private void redirectTopWindow(HttpServletRequest request, HttpServletResponse response, String url) throws IOException {
        String fullUrl = request.getContextPath() + url;
        response.setContentType("text/html;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        String html = "<!DOCTYPE html><html><head><meta http-equiv=\"refresh\" content=\"0;url=" + fullUrl + "\">"
            + "<script>window.top.location.href='" + fullUrl.replace("'", "\\'") + "';</script></head>"
            + "<body>Session expired. <a href=\"" + fullUrl + "\">Click here to login</a>.</body></html>";
        response.getWriter().write(html);
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI();
        String contextPath = request.getContextPath();
        if (contextPath != null && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }
        if (path.isEmpty()) path = "/";

        if (isPublicPath(path)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            redirectTopWindow(request, response, "/index.html?error=sessionExpired");
            return;
        }

        // Validate session token - sessions without token are legacy/invalid
        if (session.getAttribute("sessionToken") == null) {
            session.invalidate();
            redirectTopWindow(request, response, "/index.html?error=sessionExpired");
            return;
        }

        // Role-based access control - restrict users to their role's pages only
        String role = (String) session.getAttribute("role");
        String base = request.getContextPath();

        if (isAdminPath(path) && !"admin".equalsIgnoreCase(role)) {
            redirectTopWindow(request, response, getRedirectForRole(role) + "?error=accessDenied");
            return;
        }
        if (isManagerPath(path) && !"manager".equalsIgnoreCase(role)) {
            redirectTopWindow(request, response, getRedirectForRole(role) + "?error=accessDenied");
            return;
        }
        if (isUserPath(path) && !"user".equalsIgnoreCase(role) && !"employee".equalsIgnoreCase(role)) {
            redirectTopWindow(request, response, getRedirectForRole(role) + "?error=accessDenied");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}
