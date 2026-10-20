package pub;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConnDB {
	public static Connection getConnection() {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection conn=DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/website?characterEncoding=utf8&useSSL=true&serverTimezone=UTC","root","314159");
			return conn;
		}catch(Exception e) {
			System.out.println(e);
			return null;
		} 
	}
}
		
