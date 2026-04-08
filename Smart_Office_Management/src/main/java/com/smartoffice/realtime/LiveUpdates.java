package com.smartoffice.realtime;

import java.time.Instant;

/**
 * Small helper for pushing live events to connected users.
 */
public final class LiveUpdates {
	private LiveUpdates() {
	}

	private static String esc(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
	}

	public static void pushNotification(String recipientEmail, String type, String message, String createdBy) {
		if (recipientEmail == null || recipientEmail.trim().isEmpty())
			return;
		String payload = "{"
				+ "\"kind\":\"notification\","
				+ "\"type\":\"" + esc(type) + "\","
				+ "\"message\":\"" + esc(message) + "\","
				+ "\"createdBy\":\"" + esc(createdBy) + "\","
				+ "\"ts\":\"" + Instant.now().toString() + "\""
				+ "}";
		LiveSocketHub.sendTo(recipientEmail, payload);
	}
}

