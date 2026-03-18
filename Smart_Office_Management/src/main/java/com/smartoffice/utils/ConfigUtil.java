package com.smartoffice.utils;
 
import java.io.InputStream;
import java.util.Properties;
 
public class ConfigUtil {
	
	    private static Properties props = new Properties();
 
	    static {
	        try {
	            InputStream input = ConfigUtil.class
	                    .getClassLoader()
	                    .getResourceAsStream("config.properties");
 
	            props.load(input);
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }
 
	    public static String getProperty(String key) {
	        return props.getProperty(key);
	    }
	}
 
 
 
 