package com.barbers.model;

import java.sql.Timestamp;

/**
 * Represents a barbering service offered by the shop.
 */
public class Service {
    private int       serviceId;
    private String    serviceName;
    private String    description;
    private double    price;
    private int       durationMins;
    private int       isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Service() {}

    public Service(String serviceName, String description,
                   double price, int durationMins, int isActive) {
        this.serviceName  = serviceName;
        this.description  = description;
        this.price        = price;
        this.durationMins = durationMins;
        this.isActive     = isActive;
    }

    // ── Getters & Setters ──────────────────────────────────────────────────

    public int       getServiceId()              { return serviceId; }
    public void      setServiceId(int v)         { this.serviceId = v; }

    public String    getServiceName()            { return serviceName; }
    public void      setServiceName(String v)    { this.serviceName = v; }

    public String    getDescription()            { return description; }
    public void      setDescription(String v)    { this.description = v; }

    public double    getPrice()                  { return price; }
    public void      setPrice(double v)          { this.price = v; }

    public int       getDurationMins()           { return durationMins; }
    public void      setDurationMins(int v)      { this.durationMins = v; }

    public int       getIsActive()               { return isActive; }
    public void      setIsActive(int v)          { this.isActive = v; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void      setCreatedAt(Timestamp v)   { this.createdAt = v; }

    public Timestamp getUpdatedAt()              { return updatedAt; }
    public void      setUpdatedAt(Timestamp v)   { this.updatedAt = v; }
}
