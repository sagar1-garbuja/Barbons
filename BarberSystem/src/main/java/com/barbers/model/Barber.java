package com.barbers.model;

import java.sql.Timestamp;

/**
 * Represents a barber employed at the shop.
 */
public class Barber {
    private int       barberId;
    private String    name;
    private String    speciality;
    private String    bio;
    private int       isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Barber() {}

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
