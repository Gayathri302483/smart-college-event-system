package com.collegeevent.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Event implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String title;
    private String description;
    private String category;
    private Timestamp eventDate;
    private String venue;
    private int seatLimit;
    private int availableSeats;
    private String posterUrl;
    private int createdBy;
    private Timestamp createdAt;

    public Event() {}

    public Event(int id, String title, String description, String category, Timestamp eventDate, String venue, int seatLimit, int availableSeats, String posterUrl, int createdBy) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.category = category;
        this.eventDate = eventDate;
        this.venue = venue;
        this.seatLimit = seatLimit;
        this.availableSeats = availableSeats;
        this.posterUrl = posterUrl;
        this.createdBy = createdBy;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Timestamp getEventDate() { return eventDate; }
    public void setEventDate(Timestamp eventDate) { this.eventDate = eventDate; }

    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }

    public int getSeatLimit() { return seatLimit; }
    public void setSeatLimit(int seatLimit) { this.seatLimit = seatLimit; }

    public int getAvailableSeats() { return availableSeats; }
    public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }

    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
