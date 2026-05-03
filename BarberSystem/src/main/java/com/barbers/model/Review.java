package com.barbers.model;

import java.sql.Timestamp;

/**
 * Represents a customer review for a completed appointment.
 */
public class Review {
    private int       reviewId;
    private int       appointmentId;
    private int       userId;
    private int       rating;      // 1–5
    private String    comment;
    private int       isVisible;   // 1 = visible on public pages
    private Timestamp createdAt;

    // Joined fields
    private String    customerName;
    private String    serviceName;

    public Review() {}

    // ── Getters & Setters ──────────────────────────────────────────────────

    public int       getReviewId()               { return reviewId; }
    public void      setReviewId(int v)          { this.reviewId = v; }

    public int       getAppointmentId()          { return appointmentId; }
    public void      setAppointmentId(int v)     { this.appointmentId = v; }

    public int       getUserId()                 { return userId; }
    public void      setUserId(int v)            { this.userId = v; }

    public int       getRating()                 { return rating; }
    public void      setRating(int v)            { this.rating = v; }

    public String    getComment()                { return comment; }
    public void      setComment(String v)        { this.comment = v; }

    public int       getIsVisible()              { return isVisible; }
    public void      setIsVisible(int v)         { this.isVisible = v; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void      setCreatedAt(Timestamp v)   { this.createdAt = v; }

    public String    getCustomerName()           { return customerName; }
    public void      setCustomerName(String v)   { this.customerName = v; }

    public String    getServiceName()            { return serviceName; }
    public void      setServiceName(String v)    { this.serviceName = v; }
}
