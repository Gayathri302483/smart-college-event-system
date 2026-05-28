package com.collegeevent.dao;

import com.collegeevent.model.Notification;
import com.collegeevent.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationDAO {
    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    /**
     * Creates an event notification for a student.
     */
    public boolean addNotification(int studentId, String message) {
        String sql = "INSERT INTO notifications (student_id, message, is_read) VALUES (?, ?, 0)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setString(2, message);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification for student ID: " + studentId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Fetches all notifications for a student.
     */
    public List<Notification> getNotificationsForStudent(int studentId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE student_id = ? ORDER BY created_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Notification notif = new Notification();
                notif.setId(rs.getInt("id"));
                notif.setStudentId(rs.getInt("student_id"));
                notif.setMessage(rs.getString("message"));
                notif.setRead(rs.getBoolean("is_read"));
                notif.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(notif);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for student ID: " + studentId, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Marks a specific notification as read.
     */
    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, notificationId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read ID: " + notificationId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Marks all notifications of a student as read.
     */
    public boolean markAllAsRead(int studentId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE student_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for student ID: " + studentId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }
}
