package com.smartoffice.utils;

/**
 * Normalizes user status and role for case-insensitive handling.
 * Use when saving to DB so "active"/"Active"/"ACTIVE" and "user"/"User"/"employee"/"Employee" are stored consistently.
 */
public final class UserFieldUtil {

    private UserFieldUtil() {}

    /** Normalizes status to lowercase: "active", "inactive", or "pending". Default "active" if empty. */
    public static String normalizeStatus(String status) {
        if (status == null || status.trim().isEmpty()) return "active";
        String s = status.trim().toLowerCase();
        if ("inactive".equals(s) || "inacti".equals(s)) return "inactive"; // handle truncation
        if ("pending".equals(s)) return "pending";
        return "active";
    }

    /** Normalizes role: "user" -> "employee", others to lowercase. Default "employee" if empty. */
    public static String normalizeRole(String role) {
        if (role == null || role.trim().isEmpty()) return "employee";
        String r = role.trim().toLowerCase();
        if ("user".equals(r)) return "employee";
        if ("employee".equals(r)) return "employee";
        if ("manager".equals(r)) return "manager";
        if ("security".equals(r)) return "security";
        return "employee"; // default for unknown
    }
}
