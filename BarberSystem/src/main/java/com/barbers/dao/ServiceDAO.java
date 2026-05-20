package com.barbers.dao;

import com.barbers.model.Service;
import com.barbers.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the {@code services} table.
 */
public class ServiceDAO {

    /**
     * Returns all active services (is_active = 1) for the public booking page.
     *
     * @return list of active {@link Service} objects
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
     * Returns all services regardless of active status (admin view).
     *
     * @return list of all {@link Service} objects
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
     * Inserts a new service.
     *
     * @param s the Service to insert
     * @return {@code true} on success
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
     *
     * @param s the Service with updated values; service_id must be set
     * @return {@code true} on success
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
            ps.setInt(5, s.getServiceId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Permanently deletes a service from the database.
     * Nullifies service_id on linked appointments first to avoid FK violation,
     * then hard-deletes the service row.
     *
     * @param id the service_id to delete
     * @return {@code true} on success
     */
    public boolean deleteService(int id) {
        // Delete reviews linked to appointments of this service first
        String deleteReviews = "DELETE FROM reviews WHERE appointment_id IN "
                             + "(SELECT appointment_id FROM appointments WHERE service_id = ?)";
        // Delete appointments linked to this service
        String deleteAppts   = "DELETE FROM appointments WHERE service_id = ?";
        // Delete the service itself
        String deleteSvc     = "DELETE FROM services WHERE service_id = ?";
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement ps = c.prepareStatement(deleteReviews)) {
                    ps.setInt(1, id); ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(deleteAppts)) {
                    ps.setInt(1, id); ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(deleteSvc)) {
                    ps.setInt(1, id);
                    int rows = ps.executeUpdate();
                    c.commit();
                    return rows > 0;
                }
            } catch (SQLException e) {
                c.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Toggles the is_active flag for a service (show/hide).
     *
     * @param id     the service_id
     * @param status 1 to show, 0 to hide
     * @return {@code true} on success
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
