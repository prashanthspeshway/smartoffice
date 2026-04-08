package com.smartoffice.realtime;

import javax.servlet.http.HttpSession;
import javax.websocket.CloseReason;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

/**
 * WebSocket endpoint used for live updates across modules.
 *
 * Client connects to: ws(s)://host:port/<context>/ws/live
 * The server identifies the user from the existing HTTP session.
 */
@ServerEndpoint(value = "/ws/live", configurator = HttpSessionConfigurator.class)
public class LiveUpdatesEndpoint {

	private static String resolveUserKey(Session wsSession) {
		try {
			Object hsObj = wsSession.getUserProperties().get(HttpSessionConfigurator.HTTP_SESSION_KEY);
			if (hsObj instanceof HttpSession) {
				HttpSession hs = (HttpSession) hsObj;
				Object u = hs.getAttribute("username"); // this app stores email/display-name here depending on login
				Object e = hs.getAttribute("email");
				if (e instanceof String && !((String) e).trim().isEmpty())
					return ((String) e).trim();
				if (u instanceof String && !((String) u).trim().isEmpty())
					return ((String) u).trim();
			}
		} catch (Exception ignored) {
		}
		return null;
	}

	@OnOpen
	public void onOpen(Session session) {
		String userKey = resolveUserKey(session);
		if (userKey != null) {
			session.getUserProperties().put("userKey", userKey);
			LiveSocketHub.add(userKey, session);
		}
	}

	@OnClose
	public void onClose(Session session, CloseReason reason) {
		Object key = session.getUserProperties().get("userKey");
		if (key instanceof String) {
			LiveSocketHub.remove((String) key, session);
		}
	}

	@OnError
	public void onError(Session session, Throwable t) {
		Object key = session != null ? session.getUserProperties().get("userKey") : null;
		if (key instanceof String) {
			LiveSocketHub.remove((String) key, session);
		}
	}

	@OnMessage
	public String onMessage(String message) {
		// We don't need client->server messages for now.
		return null;
	}
}

