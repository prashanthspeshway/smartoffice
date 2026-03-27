package com.smartoffice.utils;

public final class UserFieldUtil {

	private UserFieldUtil() {
	}

	public static String normalizeStatus(String status) {
		if (status == null || status.trim().isEmpty())
			return "active";
		String s = status.trim().toLowerCase();
		if ("inactive".equals(s) || "inacti".equals(s))
			return "inactive";
		if ("pending".equals(s))
			return "pending";
		return "active";
	}

	public static String normalizeRole(String role) {
		if (role == null || role.trim().isEmpty())
			return "employee";
		String r = role.trim().toLowerCase();
		if ("user".equals(r))
			return "employee";
		if ("employee".equals(r))
			return "employee";
		if ("manager".equals(r))
			return "manager";
		if ("security".equals(r))
			return "security";
		return "employee";
	}
}
