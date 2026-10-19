
package com.digitalforensics.util;

import java.sql.Connection;
import java.sql.DriverManager;

public final class DBConnection {

    private static final String URL = System.getenv()
            .getOrDefault(
                    "DEA_DB_URL",
                    "jdbc:mysql://localhost:3306/digital_evidence_analyzer?useSSL=false&serverTimezone=Asia/Kolkata"
            );

    private static final String USER = System.getenv()
            .getOrDefault("DEA_DB_USER", "root");

    private static final String PASSWORD = System.getenv("DEA_DB_PASSWORD");

    private DBConnection() {
    }

    public static Connection getConnection() throws Exception {
        if (PASSWORD == null || PASSWORD.isBlank()) {
            throw new IllegalStateException(
                    "Database password is not configured. Set DEA_DB_PASSWORD."
            );
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
