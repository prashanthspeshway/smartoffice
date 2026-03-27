package com.smartoffice.utils;

import java.sql.Connection;

import java.sql.DriverManager;
import java.util.Properties;
import java.io.InputStream;

public class DBConnectionUtil {

	public static Connection getConnection() {

		Connection con = null;

		try {
			Properties props = new Properties();

			InputStream is = DBConnectionUtil.class.getClassLoader().getResourceAsStream("db.properties");

			if (is == null) {
				throw new RuntimeException("db.properties file not found");
			}

			props.load(is);

			String url = props.getProperty("db.url");
			String user = props.getProperty("db.username");
			String pass = props.getProperty("db.password");

			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection(url, user, pass);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return con;
	}
}
