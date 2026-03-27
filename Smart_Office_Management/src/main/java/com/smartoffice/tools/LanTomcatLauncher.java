package com.smartoffice.tools;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.catalina.connector.Connector;
import org.apache.catalina.core.StandardHost;
import org.apache.catalina.startup.Tomcat;

public final class LanTomcatLauncher {

	private LanTomcatLauncher() {
	}

	public static void main(String[] args) throws Exception {
		String portStr = System.getProperty("tomcat.port", "8080");
		int port = Integer.parseInt(portStr.trim());

		Path cwd = Paths.get(System.getProperty("user.dir"));
		Path war = cwd.resolve("target/Smart_Office_Management.war");
		if (!Files.isRegularFile(war)) {
			System.err.println("WAR not found. Run: mvn package");
			System.err.println("Expected: " + war.toAbsolutePath());
			System.exit(1);
		}

		File base = cwd.resolve("target/catalina-base").toFile();
		base.mkdirs();
		Files.createDirectories(cwd.resolve("target/catalina-base/webapps"));
		Files.createDirectories(cwd.resolve("target/catalina-base/work"));

		Tomcat tomcat = new Tomcat();
		tomcat.setBaseDir(base.getAbsolutePath());
		tomcat.setPort(port);

		ClassLoader appCl = LanTomcatLauncher.class.getClassLoader();
		if (tomcat.getHost() instanceof StandardHost) {
			((StandardHost) tomcat.getHost()).setParentClassLoader(appCl);
		}

		Connector connector = tomcat.getConnector();
		connector.setProperty("address", "0.0.0.0");
		connector.setURIEncoding("UTF-8");

		String ctxPath = "/Smart_Office_Management";
		tomcat.addWebapp(ctxPath, war.toAbsolutePath().toString());

		tomcat.start();

		System.out.println();
		System.out.println("Smart Office Management is running.");
		System.out.println("  Local:  http://localhost:" + port + ctxPath + "/");
		System.out.println("  LAN:    http://<this-PC-IPv4>:" + port + ctxPath + "/");
		System.out.println("Press Ctrl+C to stop.");
		System.out.println();

		Runtime.getRuntime().addShutdownHook(new Thread(() -> {
			try {
				tomcat.stop();
				tomcat.destroy();
			} catch (Exception ignored) {
			}
		}));

		tomcat.getServer().await();
	}
}
