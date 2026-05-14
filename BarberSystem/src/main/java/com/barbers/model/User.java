package com.barbers.model;

import java.sql.Timestamp;

/**
 * User — represents anyone who has an account in the system.
 * Maps to the 'users' table in the database.
 *
 * Role can be "customer" (books appointments) or "admin" (manages the system).
 */
public class User {

    // ── Database columns ──────────────────────────────────────────────────

    private int       userId;    // primary key
    private String    fullName;  // display name
    private String    email;     // used as the login username
    private String    phone;     // 10-digit phone number
    private String    password;  // MD5 hash — never stored as plain text
    private String    role;      // "customer" or "admin"
    private int       isActive;  // 1 = can log in, 0 = account disabled by admin
    private Timestamp createdAt; // when the account was registered
    private Timestamp updatedAt; // when the account was last changed

    // Default constructor (used by the DAO)
    public User() {}

    // Convenience constructor used during registration
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

    public Timestamp getCreatedAt()           { return createdAt; }
    public void      setCreatedAt(Timestamp v){ this.createdAt = v; }

    public Timestamp getUpdatedAt()           { return updatedAt; }
    public void      setUpdatedAt(Timestamp v){ this.updatedAt = v; }
}
