package com.barbers.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.barbers.model.Service;
import com.barbers.util.DBConnection;

/**
 * ServiceDAO — all database operations for the 'services' table.
 */
public class ServiceDAO {

    /**
     * Returns only active services (is_active = 1) for the customer booking page.
     * Hidden services are not shown to customers.
     */
    public List<Service> getAllActiveServices() {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT * FROM services WHERE is_active = 1 ORDER BY service_id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns all services (active and hidden) for the admin management page.
     */
    public List<Service> getAllServices() {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT * FROM services ORDER BY service_id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Saves a new service to the database.
     */
    public boolean insertService(Service s) {
        String sql = "INSERT INTO services (service_name, description, price, duration_mins, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getServiceName());
            ps.setString(2, s.getDescription());
            ps.setDouble(3, s.getPrice());
            ps.setInt(4, s.getDurationMins());
            ps.setInt(5, s.getIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates an existing service's details.
     * The service_id in the Service object identifies which row to update.
     */
    public boolean updateService(Service s) {
        String sql = "UPDATE services SET service_name=?, description=?, price=?, duration_mins=?, updated_at=NOW() "
                   + "WHERE service_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getServiceName());
            ps.setString(2, s.getDescription());
            ps.setDouble(3, s.getPrice());
            ps.setInt(4, s.getDurationMins());
            ps.setInt(5, s.getServiceId()); // WHERE clause — which service to update
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Shows or hides a service on the booking page.
     * Hidden services (is_active = 0) are not available for new bookings.
     *
     * @param id     the service_id to update
     * @param status 1 = visible, 0 = hidden
     */
    public boolean toggleActive(int id, int status) {
        String sql = "UPDATE services SET is_active=?, updated_at=NOW() WHERE service_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Private helper ─────────────────────────────────────────────────────

    /** Converts one ResultSet row into a Service object. */
    private Service mapRow(ResultSet rs) throws SQLException {
        Service s = new Service();
        s.setServiceId(rs.getInt("service_id"));
        s.setServiceName(rs.getString("service_name"));
        s.setDescription(rs.getString("description"));
        s.setPrice(rs.getDouble("price"));
        s.setDurationMins(rs.getInt("duration_mins"));
        s.setIsActive(rs.getInt("is_active"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }
}
