package com.collegeevent.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                LOGGER.severe("Sorry, unable to find db.properties. Falling back to default settings.");
                properties.setProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                properties.setProperty("db.url", "jdbc:mysql://localhost:3306/college_event_db");
                properties.setProperty("db.username", "root");
                properties.setProperty("db.password", "password");
            } else {
                properties.load(input);
                LOGGER.info("db.properties loaded successfully.");
            }
            // Register Driver
            Class.forName(properties.getProperty("db.driver"));
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error initializing database properties or loading JDBC driver", ex);
        }
    }

    /**
     * Gets a connection to the MySQL database.
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(
                properties.getProperty("db.url"),
                properties.getProperty("db.username"),
                properties.getProperty("db.password")
            );
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to connect to database at: " + properties.getProperty("db.url"), e);
            throw e;
        }
    }

    /**
     * Safely closes open JDBC resources.
     */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Statement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }

    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }
}
