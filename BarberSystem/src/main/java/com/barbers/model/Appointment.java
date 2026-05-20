package com.barbers.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

/**
 * Represents a booked appointment.
 */
public class Appointment {
    private int       appointmentId;
    private int       userId;
    private int       barberId;
    private int       serviceId;
    private Date      apptDate;
    private Time      apptTime;
    private String    status;          // pending | confirmed | completed | cancelled
    private String    notes;
    private String    paymentMethod;   // cash | esewa | fonepay
    private String    paymentStatus;   // unpaid | paid
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined fields (not in DB column, populated by DAO joins)
    private String    customerName;
    private String    serviceName;
    private double    servicePrice;
    private String    barberName;

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

    public String    getCustomerName()               { return customerName; }
    public void      setCustomerName(String v)       { this.customerName = v; }

    public String    getServiceName()                { return serviceName; }
    public void      setServiceName(String v)        { this.serviceName = v; }

    public double    getServicePrice()               { return servicePrice; }
    public void      setServicePrice(double v)       { this.servicePrice = v; }

    public String    getBarberName()                 { return barberName; }
    public void      setBarberName(String v)         { this.barberName = v; }

    public String    getPaymentMethod()              { return paymentMethod; }
    public void      setPaymentMethod(String v)      { this.paymentMethod = v; }

    public String    getPaymentStatus()              { return paymentStatus; }
    public void      setPaymentStatus(String v)      { this.paymentStatus = v; }
}
