package com.digitalforensics.util;

import java.sql.Connection;
import java.sql.DriverManager;

public final class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/digital_evidence_analyzer?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASSWORD = "root"; // Change before deployment.
    private DBConnection() {}
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
