package com.barbers.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Appointment — represents one booking made by a customer.
 *
 * Most fields map directly to columns in the 'appointments' table.
 * The last four fields (customerName, serviceName, servicePrice, barberName)
 * are NOT stored in the table — they are filled in by the DAO when it
 * joins with other tables, so the JSP doesn't need to do extra lookups.
 */
public class Appointment {

    // ── Database columns ──────────────────────────────────────────────────

    private int       appointmentId; // primary key
    private int       userId;        // which customer made the booking
    private int       barberId;      // which barber is assigned
    private int       serviceId;     // which service was chosen
    private Date      apptDate;      // date of the appointment (YYYY-MM-DD)
    private Time      apptTime;      // time of the appointment (HH:MM:SS)
    private String    status;        // pending | confirmed | completed | cancelled
    private String    notes;         // optional notes from the customer
    private Timestamp createdAt;     // when the booking was made
    private Timestamp updatedAt;     // when the booking was last changed

    // ── Joined / display fields (not in the DB column) ────────────────────

    private String customerName;  // from users.full_name
    private String serviceName;   // from services.service_name
    private double servicePrice;  // from services.price
    private String barberName;    // from barbers.name

    // Default constructor (required by the DAO when building objects from ResultSet)
    public Appointment() {}

    // ── Getters & Setters ──────────────────────────────────────────────────

    public int       getAppointmentId()              { return appointmentId; }
    public void      setAppointmentId(int v)         { this.appointmentId = v; }

    public int       getUserId()                     { return userId; }
    public void      setUserId(int v)                { this.userId = v; }

    public int       getBarberId()                   { return barberId; }
    public void      setBarberId(int v)              { this.barberId = v; }

    public int       getServiceId()                  { return serviceId; }
    public void      setServiceId(int v)             { this.serviceId = v; }

    public Date      getApptDate()                   { return apptDate; }
    public void      setApptDate(Date v)             { this.apptDate = v; }

    public Time      getApptTime()                   { return apptTime; }
    public void      setApptTime(Time v)             { this.apptTime = v; }

    public String    getStatus()                     { return status; }
    public void      setStatus(String v)             { this.status = v; }

    public String    getNotes()                      { return notes; }
    public void      setNotes(String v)              { this.notes = v; }

    public Timestamp getCreatedAt()                  { return createdAt; }
    public void      setCreatedAt(Timestamp v)       { this.createdAt = v; }

    public Timestamp getUpdatedAt()                  { return updatedAt; }
    public void      setUpdatedAt(Timestamp v)       { this.updatedAt = v; }

    // Joined fields
    public String    getCustomerName()               { return customerName; }
    public void      setCustomerName(String v)       { this.customerName = v; }

    public String    getServiceName()                { return serviceName; }
    public void      setServiceName(String v)        { this.serviceName = v; }

    public double    getServicePrice()               { return servicePrice; }
    public void      setServicePrice(double v)       { this.servicePrice = v; }

    public String    getBarberName()                 { return barberName; }
    public void      setBarberName(String v)         { this.barberName = v; }
}
