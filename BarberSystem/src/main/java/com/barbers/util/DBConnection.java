package com.barbers.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for obtaining a MySQL database connection.
 * Uses XAMPP defaults: root user, no password, barbers_db database.
 */
public class DBConnection {

    private static final String URL      = "jdbc:mysql://localhost:3307/barbers_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        }
    }

    /**
     * Returns a new Connection to barbers_db.
     * Caller is responsible for closing the connection.
     *
     * @return a live {@link Connection}
     * @throws SQLException if the connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
