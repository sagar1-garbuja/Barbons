package com.barbers.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection — provides a single place to get a database connection.
 *
 * Uses XAMPP defaults:
 *   - Host:     localhost:3306
 *   - Database: barbers_db
 *   - User:     root
 *   - Password: (empty)
 *
 * Every DAO calls DBConnection.getConnection() to talk to the database,
 * and is responsible for closing the connection when done (try-with-resources).
 */
public class DBConnection {

    // Full JDBC URL — useSSL=false avoids SSL warnings on local XAMPP
    private static final String URL      = "jdbc:mysql://localhost:3307/barbers_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = ""; // XAMPP default: no password

    // Load the MySQL JDBC driver once when the class is first used
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            // If the driver JAR is missing from the project, throw a clear error
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        }
    }

    /**
     * Opens and returns a new connection to the database.
     * The caller must close it (best done with try-with-resources).
     *
     * @return a live {@link Connection}
     * @throws SQLException if the database is unreachable or credentials are wrong
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
