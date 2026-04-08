package com.smartoffice.realtime;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import javax.websocket.Session;

/**
 * Thread-safe registry of WebSocket sessions per user key (email/username).
 */
public final class LiveSocketHub {
	private LiveSocketHub() {
	}

	private static final ConcurrentHashMap<String, Set<Session>> SESSIONS = new ConcurrentHashMap<>();

	public static void add(String userKey, Session session) {
		if (userKey == null || userKey.trim().isEmpty() || session == null)
			return;
		String key = userKey.trim().toLowerCase();
		SESSIONS.computeIfAbsent(key, k -> ConcurrentHashMap.newKeySet()).add(session);
	}

	public static void remove(String userKey, Session session) {
		if (userKey == null || userKey.trim().isEmpty() || session == null)
			return;
		String key = userKey.trim().toLowerCase();
		Set<Session> set = SESSIONS.get(key);
		if (set == null)
			return;
		set.remove(session);
		if (set.isEmpty())
			SESSIONS.remove(key);
	}

	public static void sendTo(String userKey, String message) {
		if (userKey == null || userKey.trim().isEmpty() || message == null)
			return;
		String key = userKey.trim().toLowerCase();
		Set<Session> set = SESSIONS.get(key);
		if (set == null || set.isEmpty())
			return;
		for (Session s : set) {
			try {
				if (s.isOpen()) {
					s.getAsyncRemote().sendText(message);
				}
			} catch (Exception ignored) {
			}
		}
	}
}

