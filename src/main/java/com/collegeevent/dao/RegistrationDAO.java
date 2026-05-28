package com.collegeevent.dao;

import com.collegeevent.model.Registration;
import com.collegeevent.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RegistrationDAO {
    private static final Logger LOGGER = Logger.getLogger(RegistrationDAO.class.getName());

    /**
     * Registers a student for an event using a Transaction block to safely manage seats.
     */
    public boolean registerForEvent(int studentId, int eventId, String qrCodeToken) {
        String checkSeatsSql = "SELECT available_seats FROM events WHERE id = ? FOR UPDATE";
        String decSeatsSql = "UPDATE events SET available_seats = available_seats - 1 WHERE id = ? AND available_seats > 0";
        String insertRegSql = "INSERT INTO registrations (student_id, event_id, status, attendance, qr_code_token) VALUES (?, ?, 'PENDING', 'ABSENT', ?)";

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psDec = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Check Seat Availability
            psCheck = conn.prepareStatement(checkSeatsSql);
            psCheck.setInt(1, eventId);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                int available = rs.getInt("available_seats");
                if (available <= 0) {
                    conn.rollback();
                    return false; // No seats available
                }
            } else {
                conn.rollback();
                return false;
            }

            // 2. Decrement Seats
            psDec = conn.prepareStatement(decSeatsSql);
            psDec.setInt(1, eventId);
            int seatsUpdated = psDec.executeUpdate();

            if (seatsUpdated <= 0) {
                conn.rollback();
                return false;
            }

            // 3. Insert Registration Record
            psInsert = conn.prepareStatement(insertRegSql);
            psInsert.setInt(1, studentId);
            psInsert.setInt(2, eventId);
            psInsert.setString(3, qrCodeToken);
            int inserted = psInsert.executeUpdate();

            if (inserted > 0) {
                conn.commit(); // Success
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction failed for student ID: " + studentId + " registering for event ID: " + eventId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
                }
            }
            return false;
        } finally {
            DBConnection.close(null, psCheck, rs);
            DBConnection.close(null, psDec);
            DBConnection.close(conn, psInsert);
        }
    }

    /**
     * Checks if a student is already registered for an event.
     */
    public boolean isRegistered(int studentId, int eventId) {
        String sql = "SELECT id FROM registrations WHERE student_id = ? AND event_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setInt(2, eventId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking registration state", e);
            return false;
        } finally {
            DBConnection.close(conn, ps, rs);
        }
    }

    /**
     * Gets a registration by ID (with join details).
     */
    public Registration getRegistrationById(int id) {
        String sql = "SELECT r.*, s.full_name AS student_name, s.roll_number AS student_roll, s.department AS student_department, " +
                     "e.title AS event_title, e.event_date AS event_date, e.venue AS event_venue " +
                     "FROM registrations r " +
                     "JOIN students s ON r.student_id = s.id " +
                     "JOIN events e ON r.event_id = e.id " +
                     "WHERE r.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return extractRegistrationFromResultSet(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting registration ID: " + id, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Fetches all registrations for a student.
     */
    public List<Registration> getRegistrationsByStudent(int studentId) {
        List<Registration> list = new ArrayList<>();
        String sql = "SELECT r.*, s.full_name AS student_name, s.roll_number AS student_roll, s.department AS student_department, " +
                     "e.title AS event_title, e.event_date AS event_date, e.venue AS event_venue " +
                     "FROM registrations r " +
                     "JOIN students s ON r.student_id = s.id " +
                     "JOIN events e ON r.event_id = e.id " +
                     "WHERE r.student_id = ? " +
                     "ORDER BY r.registration_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(extractRegistrationFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting registrations for student ID: " + studentId, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Fetches all registrations for the admin panel.
     */
    public List<Registration> getAllRegistrations() {
        List<Registration> list = new ArrayList<>();
        String sql = "SELECT r.*, s.full_name AS student_name, s.roll_number AS student_roll, s.department AS student_department, " +
                     "e.title AS event_title, e.event_date AS event_date, e.venue AS event_venue " +
                     "FROM registrations r " +
                     "JOIN students s ON r.student_id = s.id " +
                     "JOIN events e ON r.event_id = e.id " +
                     "ORDER BY r.registration_date DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(extractRegistrationFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all registrations", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return list;
    }

    /**
     * Updates registration status (APPROVED/REJECTED). Releasing seats if rejected.
     */
    public boolean updateRegistrationStatus(int regId, String status) {
        String getRegSql = "SELECT event_id, status FROM registrations WHERE id = ?";
        String updateStatusSql = "UPDATE registrations SET status = ? WHERE id = ?";
        
        Connection conn = null;
        PreparedStatement psGet = null;
        PreparedStatement psUpdate = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Get current registration details
            psGet = conn.prepareStatement(getRegSql);
            psGet.setInt(1, regId);
            rs = psGet.executeQuery();

            if (rs.next()) {
                int eventId = rs.getInt("event_id");
                String oldStatus = rs.getString("status");

                // 2. Perform Status Update
                psUpdate = conn.prepareStatement(updateStatusSql);
                psUpdate.setString(1, status);
                psUpdate.setInt(2, regId);
                int updated = psUpdate.executeUpdate();

                if (updated <= 0) {
                    conn.rollback();
                    return false;
                }

                // 3. Seat Inventory adjustment
                // If moving from APPROVED/PENDING to REJECTED, release 1 seat
                if (status.equalsIgnoreCase("REJECTED") && !oldStatus.equalsIgnoreCase("REJECTED")) {
                    EventDAO eventDAO = new EventDAO();
                    // We must pass the active connection to preserve transaction context, 
                    // but for simplicity, running local query works if we manage it here.
                    String releaseSeatSql = "UPDATE events SET available_seats = available_seats + 1 WHERE id = ? AND available_seats < seat_limit";
                    PreparedStatement psRelease = conn.prepareStatement(releaseSeatSql);
                    psRelease.setInt(1, eventId);
                    psRelease.executeUpdate();
                    psRelease.close();
                } 
                // If moving from REJECTED back to APPROVED/PENDING, deduct 1 seat
                else if (oldStatus.equalsIgnoreCase("REJECTED") && !status.equalsIgnoreCase("REJECTED")) {
                    String deductSeatSql = "UPDATE events SET available_seats = available_seats - 1 WHERE id = ? AND available_seats > 0";
                    PreparedStatement psDeduct = conn.prepareStatement(deductSeatSql);
                    psDeduct.setInt(1, eventId);
                    int deducted = psDeduct.executeUpdate();
                    psDeduct.close();
                    if (deducted <= 0) {
                        conn.rollback(); // Failed to secure seat
                        return false;
                    }
                }

                conn.commit();
                return true;
            }
            conn.rollback();
            return false;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction failed for updating registration status ID: " + regId, e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            return false;
        } finally {
            DBConnection.close(null, psGet, rs);
            DBConnection.close(conn, psUpdate);
        }
    }

    /**
     * Marks student attendance (PRESENT / ABSENT).
     */
    public boolean updateAttendance(int regId, String attendance) {
        String sql = "UPDATE registrations SET attendance = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, attendance);
            ps.setInt(2, regId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating attendance for registration ID: " + regId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * ANALYTICS: Gets registration distribution per department.
     */
    public Map<String, Integer> getDepartmentStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT s.department, COUNT(r.id) as registrations " +
                     "FROM registrations r JOIN students s ON r.student_id = s.id " +
                     "GROUP BY s.department";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                stats.put(rs.getString("department"), rs.getInt("registrations"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting department registration stats", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return stats;
    }

    private Registration extractRegistrationFromResultSet(ResultSet rs) throws SQLException {
        Registration reg = new Registration();
        reg.setId(rs.getInt("id"));
        reg.setStudentId(rs.getInt("student_id"));
        reg.setEventId(rs.getInt("event_id"));
        reg.setRegistrationDate(rs.getTimestamp("registration_date"));
        reg.setStatus(rs.getString("status"));
        reg.setAttendance(rs.getString("attendance"));
        reg.setQrCodeToken(rs.getString("qr_code_token"));

        // Join fields (might be missing if query is simple, so wrap in safe checks)
        try { reg.setStudentName(rs.getString("student_name")); } catch (SQLException e) { /* ignored */ }
        try { reg.setStudentRoll(rs.getString("student_roll")); } catch (SQLException e) { /* ignored */ }
        try { reg.setStudentDepartment(rs.getString("student_department")); } catch (SQLException e) { /* ignored */ }
        try { reg.setEventTitle(rs.getString("event_title")); } catch (SQLException e) { /* ignored */ }
        try { reg.setEventDate(rs.getTimestamp("event_date")); } catch (SQLException e) { /* ignored */ }
        try { reg.setEventVenue(rs.getString("event_venue")); } catch (SQLException e) { /* ignored */ }

        return reg;
    }
}
