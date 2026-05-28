package com.collegeevent.dao;

import com.collegeevent.model.Event;
import com.collegeevent.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EventDAO {
    private static final Logger LOGGER = Logger.getLogger(EventDAO.class.getName());

    /**
     * Creates a new event.
     */
    public boolean createEvent(Event event) {
        String sql = "INSERT INTO events (title, description, category, event_date, venue, seat_limit, available_seats, poster_url, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getCategory());
            ps.setTimestamp(4, event.getEventDate());
            ps.setString(5, event.getVenue());
            ps.setInt(6, event.getSeatLimit());
            ps.setInt(7, event.getSeatLimit()); // Available seats initially equals seat limit
            ps.setString(8, event.getPosterUrl());
            ps.setInt(9, event.getCreatedBy());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating event: " + event.getTitle(), e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Updates an existing event.
     */
    public boolean updateEvent(Event event) {
        String sql = "UPDATE events SET title = ?, description = ?, category = ?, event_date = ?, venue = ?, seat_limit = ?, poster_url = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            
            // Adjust available seats based on change in seat limit (or just keep simple sync)
            Event oldEvent = getEventById(event.getId());
            int seatDifference = event.getSeatLimit() - oldEvent.getSeatLimit();
            int newAvailableSeats = oldEvent.getAvailableSeats() + seatDifference;
            if (newAvailableSeats < 0) newAvailableSeats = 0;

            sql = "UPDATE events SET title = ?, description = ?, category = ?, event_date = ?, venue = ?, seat_limit = ?, available_seats = ?, poster_url = ? WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getCategory());
            ps.setTimestamp(4, event.getEventDate());
            ps.setString(5, event.getVenue());
            ps.setInt(6, event.getSeatLimit());
            ps.setInt(7, newAvailableSeats);
            ps.setString(8, event.getPosterUrl());
            ps.setInt(9, event.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating event ID: " + event.getId(), e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Deletes an event.
     */
    public boolean deleteEvent(int id) {
        String sql = "DELETE FROM events WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting event ID: " + id, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Fetches an event by its ID.
     */
    public Event getEventById(int id) {
        String sql = "SELECT * FROM events WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return extractEventFromResultSet(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting event by ID: " + id, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Fetches all events.
     */
    public List<Event> getAllEvents() {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT * FROM events ORDER BY event_date ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(extractEventFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all events", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return list;
    }

    /**
     * Fetches top upcoming events.
     */
    public List<Event> getUpcomingEvents(int limit) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE event_date >= NOW() ORDER BY event_date ASC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(extractEventFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting upcoming events", e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Advanced SQL paginated searching and category-based filtering.
     */
    public List<Event> searchAndFilterEvents(String search, String category, int limit, int offset) {
        List<Event> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM events WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR description LIKE ? OR venue LIKE ?)");
        }
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("all")) {
            sql.append(" AND category = ?");
        }
        sql.append(" ORDER BY event_date ASC LIMIT ? OFFSET ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            
            int index = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }
            if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("all")) {
                ps.setString(index++, category.trim());
            }
            ps.setInt(index++, limit);
            ps.setInt(index++, offset);

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractEventFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error during advanced search and filtering", e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Gets the total event count based on search and category filters.
     */
    public int getTotalEventsCount(String search, String category) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM events WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR description LIKE ? OR venue LIKE ?)");
        }
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("all")) {
            sql.append(" AND category = ?");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            
            int index = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
            }
            if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("all")) {
                ps.setString(index++, category.trim());
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting event count", e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Updates seat availability (+1 when registration rejected/deleted, -1 when registered).
     */
    public synchronized boolean updateAvailableSeats(int eventId, int change) {
        String sql = "UPDATE events SET available_seats = available_seats + ? WHERE id = ? AND available_seats + ? >= 0 AND available_seats + ? <= seat_limit";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, change);
            ps.setInt(2, eventId);
            ps.setInt(3, change);
            ps.setInt(4, change);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating seats for event ID: " + eventId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * ANALYTICS: Gets event counts grouped by category.
     */
    public Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT category, COUNT(*) as count FROM events GROUP BY category";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                stats.put(rs.getString("category"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting category distribution", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return stats;
    }

    /**
     * ANALYTICS: Gets registration counts per event.
     */
    public Map<String, Integer> getRegistrationTrends() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT e.title, COUNT(r.id) as registrations " +
                     "FROM events e LEFT JOIN registrations r ON e.id = r.event_id " +
                     "GROUP BY e.id, e.title";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                stats.put(rs.getString("title"), rs.getInt("registrations"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting registration trends", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return stats;
    }

    private Event extractEventFromResultSet(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setId(rs.getInt("id"));
        event.setTitle(rs.getString("title"));
        event.setDescription(rs.getString("description"));
        event.setCategory(rs.getString("category"));
        event.setEventDate(rs.getTimestamp("event_date"));
        event.setVenue(rs.getString("venue"));
        event.setSeatLimit(rs.getInt("seat_limit"));
        event.setAvailableSeats(rs.getInt("available_seats"));
        event.setPosterUrl(rs.getString("poster_url"));
        event.setCreatedBy(rs.getInt("created_by"));
        event.setCreatedAt(rs.getTimestamp("created_at"));
        return event;
    }
}
