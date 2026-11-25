package com.hugoroze.quiz2.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {
    private static boolean initialized = false;

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }

        String host = getEnv("DB_HOST", "127.0.0.1");
        String port = getEnv("DB_PORT", "3306");
        String db   = getEnv("DB_NAME", "midterm_db");
        String user = getEnv("DB_USER", "root");
        String pass = getEnv("DB_PASS", "");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + db
                + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";

        Connection conn = DriverManager.getConnection(url, user, pass);

        if (!initialized) {
            initSchema(conn);
            initialized = true;
        }
        return conn;
    }

    private static String getEnv(String key, String defaultValue) {
        String val = System.getenv(key);
        return (val != null && !val.trim().isEmpty()) ? val.trim() : defaultValue;
    }

    private static void initSchema(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, " +
                "name VARCHAR(255) NOT NULL, " +
                "email VARCHAR(255) NOT NULL UNIQUE, " +
                "password VARCHAR(255) NOT NULL, " +
                "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)"
            );
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS categories (" +
                "id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, " +
                "name VARCHAR(255) NOT NULL, " +
                "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)"
            );
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS tasks (" +
                "id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, " +
                "user_id BIGINT UNSIGNED NOT NULL, " +
                "category_id BIGINT UNSIGNED NOT NULL, " +
                "title VARCHAR(255) NOT NULL, " +
                "description TEXT NULL, " +
                "due_date DATE NULL, " +
                "is_completed TINYINT(1) NOT NULL DEFAULT 0, " +
                "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, " +
                "FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE)"
            );
        } catch (SQLException ignored) {
        }
    }
}