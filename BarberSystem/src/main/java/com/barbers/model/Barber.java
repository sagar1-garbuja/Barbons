package com.barbers.model;

import java.sql.Timestamp;

/**
 * Barber — represents a barber who works at the shop.
 * Maps to the 'barbers' table in the database.
 */
public class Barber {

    // ── Database columns ──────────────────────────────────────────────────

    private int       barberId;    // primary key
    private String    name;        // barber's full name
    private String    speciality;  // e.g. "Fades & Tapers"
    private String    bio;         // short description shown on the public page
    private int       isActive;    // 1 = available for bookings, 0 = deactivated
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor (used by the DAO)
    public Barber() {}

    // Convenience constructor used when creating a new barber from the admin form
    public Barber(String name, String speciality, String bio, int isActive) {
        this.name       = name;
        this.speciality = speciality;
        this.bio        = bio;
        this.isActive   = isActive;
    }

    // ── Getters & Setters ──────────────────────────────────────────────────

    public int       getBarberId()              { return barberId; }
    public void      setBarberId(int v)         { this.barberId = v; }

    public String    getName()                  { return name; }
    public void      setName(String v)          { this.name = v; }

    public String    getSpeciality()            { return speciality; }
    public void      setSpeciality(String v)    { this.speciality = v; }

    public String    getBio()                   { return bio; }
    public void      setBio(String v)           { this.bio = v; }

    public int       getIsActive()              { return isActive; }
    public void      setIsActive(int v)         { this.isActive = v; }

    public Timestamp getCreatedAt()             { return createdAt; }
    public void      setCreatedAt(Timestamp v)  { this.createdAt = v; }

    public Timestamp getUpdatedAt()             { return updatedAt; }
    public void      setUpdatedAt(Timestamp v)  { this.updatedAt = v; }
}
