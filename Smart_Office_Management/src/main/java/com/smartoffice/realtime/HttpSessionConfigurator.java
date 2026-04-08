package com.smartoffice.realtime;

import java.util.Map;

import javax.servlet.http.HttpSession;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;

/**
 * Allows a WebSocket endpoint to access the HTTP session.
 */
public class HttpSessionConfigurator extends ServerEndpointConfig.Configurator {
	public static final String HTTP_SESSION_KEY = "httpSession";

	@Override
	public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
		Map<String, Object> props = sec.getUserProperties();
		Object httpSession = request.getHttpSession();
		if (httpSession instanceof HttpSession) {
			props.put(HTTP_SESSION_KEY, (HttpSession) httpSession);
		}
	}
}

