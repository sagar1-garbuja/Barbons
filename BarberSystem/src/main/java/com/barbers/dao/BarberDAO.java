package com.barbers.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

import com.barbers.model.Barber;
import com.barbers.util.DBConnection;

/**
 * Data Access Object for the {@code barbers} table.
 */
public class BarberDAO {

    /**
     * Returns all barbers regardless of active status (admin view).
     *
     * @return list of all {@link Barber} objects
     */
    public List<Barber> getAllBarbers() {
        List<Barber> list = new ArrayList<>();
        String sql = "SELECT * FROM barbers ORDER BY barber_id";
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
     * Returns only active barbers (is_active = 1).
     *
     * @return list of active {@link Barber} objects
     */
    public List<Barber> getAllActiveBarbers() {
        List<Barber> list = new ArrayList<>();
        String sql = "SELECT * FROM barbers WHERE is_active = 1 ORDER BY barber_id";
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
     * Inserts a new barber record.
     *
     * @param b the Barber to insert
     * @return {@code true} on success
     */
    public boolean insertBarber(Barber b) {
        String sql = "INSERT INTO barbers (name, speciality, bio, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getName());
            ps.setString(2, b.getSpeciality());
            ps.setString(3, b.getBio());
            ps.setInt(4, b.getIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates an existing barber's details.
     *
     * @param b the Barber with updated values; barber_id must be set
     * @return {@code true} on success
     */
    public boolean updateBarber(Barber b) {
        String sql = "UPDATE barbers SET name=?, speciality=?, bio=?, updated_at=NOW() WHERE barber_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getName());
            ps.setString(2, b.getSpeciality());
            ps.setString(3, b.getBio());
            ps.setInt(4, b.getBarberId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Permanently deletes a barber by ID.
     *
     * @param id the barber_id to delete
     * @return {@code true} on success
     */
    public boolean deleteBarber(int id) {
        String sql = "DELETE FROM barbers WHERE barber_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Toggles the is_active flag for a barber.
     *
     * @param id     the barber_id
     * @param status 1 to activate, 0 to deactivate
     * @return {@code true} on success
     */
    public boolean toggleActive(int id, int status) {
        String sql = "UPDATE barbers SET is_active=?, updated_at=NOW() WHERE barber_id=?";
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

    /**
     * AUTO-ASSIGN logic: finds the first active barber who has no appointment
     * at the given date and time.
     *
     * @param date the appointment date (java.sql.Date)
     * @param time the appointment time (java.sql.Time)
     * @return the first available {@link Barber}, or {@code null} if none free
     */
    public Barber getFirstAvailableBarber(Date date, Time time) {
        String sql = "SELECT * FROM barbers WHERE is_active = 1 "
                   + "AND barber_id NOT IN ("
                   + "  SELECT barber_id FROM appointments "
                   + "  WHERE appt_date = ? AND appt_time = ? "
                   + "  AND status NOT IN ('cancelled')"
                   + ") ORDER BY barber_id LIMIT 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setTime(2, time);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Private helper ─────────────────────────────────────────────────────

    private Barber mapRow(ResultSet rs) throws SQLException {
        Barber b = new Barber();
        b.setBarberId(rs.getInt("barber_id"));
        b.setName(rs.getString("name"));
        b.setSpeciality(rs.getString("speciality"));
        b.setBio(rs.getString("bio"));
        b.setIsActive(rs.getInt("is_active"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        b.setUpdatedAt(rs.getTimestamp("updated_at"));
        return b;
    }
}
