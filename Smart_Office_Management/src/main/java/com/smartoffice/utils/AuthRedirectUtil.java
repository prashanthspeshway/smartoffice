package com.smartoffice.utils;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public final class AuthRedirectUtil {

    private AuthRedirectUtil() {}

    public static void sendTopWindowRedirect(HttpServletRequest request, HttpServletResponse response,
            String pathWithOptionalQuery) throws IOException {
        String ctx = request.getContextPath();
        if (ctx == null) {
            ctx = "";
        }
        String path = pathWithOptionalQuery;
        if (path == null || path.isEmpty()) {
            path = "/index.html";
        }
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        String fullUrl = ctx + path;
        response.setContentType("text/html;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        String html = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\">"
                + "<meta http-equiv=\"refresh\" content=\"0;url=" + fullUrl + "\">"
                + "<script>window.top.location.href='" + fullUrl.replace("'", "\\'") + "';</script></head>"
                + "<body><p><a href=\"" + fullUrl.replace("\"", "&quot;") + "\">Continue</a></p></body></html>";
        response.getWriter().write(html);
    }
}
