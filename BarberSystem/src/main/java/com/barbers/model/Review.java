package com.barbers.model;

import java.sql.Timestamp;

/**
 * Review — represents a customer's rating and comment for a completed appointment.
 * Maps to the 'reviews' table in the database.
 *
 * customerName and serviceName are joined fields filled by the DAO,
 * not actual columns in the reviews table.
 */
public class Review {

    // ── Database columns ──────────────────────────────────────────────────

    private int       reviewId;       // primary key
    private int       appointmentId;  // which appointment this review is for
    private int       userId;         // which customer wrote the review
    private int       rating;         // star rating: 1 (worst) to 5 (best)
    private String    comment;        // optional written feedback
    private int       isVisible;      // 1 = shown on public page, 0 = hidden by admin
    private Timestamp createdAt;

    // ── Joined / display fields (not in the DB column) ────────────────────

    private String customerName; // from users.full_name
    private String serviceName;  // from services.service_name (via appointments join)

    // Default constructor (used by the DAO)
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

    // Joined fields
    public String    getCustomerName()           { return customerName; }
    public void      setCustomerName(String v)   { this.customerName = v; }

    public String    getServiceName()            { return serviceName; }
    public void      setServiceName(String v)    { this.serviceName = v; }
}
