package com.barbers.model;

import java.sql.Timestamp;

/**
 * Represents a user (customer or admin) in the system.
 */
public class User {
    private int       userId;
    private String    fullName;
    private String    email;
    private String    phone;
    private String    password;        // MD5 hash
    private String    role;            // "customer" | "admin"
    private int       isActive;        // 1 = active, 0 = disabled
    private String    profilePicture;  // filename stored in uploads/profiles/
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {}

    public User(String fullName, String email, String phone,
                String password, String role, int isActive) {
        this.fullName = fullName;
        this.email    = email;
        this.phone    = phone;
        this.password = password;
        this.role     = role;
        this.isActive = isActive;
    }

    // ── Getters & Setters ──────────────────────────────────────────────────

    public int       getUserId()              { return userId; }
    public void      setUserId(int userId)    { this.userId = userId; }

    public String    getFullName()            { return fullName; }
    public void      setFullName(String v)    { this.fullName = v; }

    public String    getEmail()               { return email; }
    public void      setEmail(String v)       { this.email = v; }

    public String    getPhone()               { return phone; }
    public void      setPhone(String v)       { this.phone = v; }

    public String    getPassword()            { return password; }
    public void      setPassword(String v)    { this.password = v; }

    public String    getRole()                { return role; }
    public void      setRole(String v)        { this.role = v; }

    public int       getIsActive()            { return isActive; }
    public void      setIsActive(int v)       { this.isActive = v; }

    public String    getProfilePicture()           { return profilePicture; }
    public void      setProfilePicture(String v)   { this.profilePicture = v; }

    public Timestamp getCreatedAt()           { return createdAt; }
    public void      setCreatedAt(Timestamp v){ this.createdAt = v; }

    public Timestamp getUpdatedAt()           { return updatedAt; }
    public void      setUpdatedAt(Timestamp v){ this.updatedAt = v; }
}
