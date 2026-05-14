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
 * BarberDAO — all database operations for the 'barbers' table.
 */
public class BarberDAO {

    /**
     * Returns every barber (active and inactive) for the admin management page.
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
     * Used on the public-facing pages where deactivated barbers should not appear.
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
     * Saves a new barber to the database.
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
     * Updates an existing barber's name, speciality, and bio.
     * The barber_id in the Barber object identifies which row to update.
     */
    public boolean updateBarber(Barber b) {
        String sql = "UPDATE barbers SET name=?, speciality=?, bio=?, updated_at=NOW() WHERE barber_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getName());
            ps.setString(2, b.getSpeciality());
            ps.setString(3, b.getBio());
            ps.setInt(4, b.getBarberId()); // WHERE clause — which barber to update
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Sets a barber's is_active flag to 1 (active) or 0 (inactive).
     * Inactive barbers are not assigned to new bookings.
     */
    public boolean toggleActive(int id, int status) {
        String sql = "UPDATE barbers SET is_active=?, updated_at=NOW() WHERE barber_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, status); // 1 = active, 0 = inactive
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Auto-assign logic: finds the first active barber who has no appointment
     * at the requested date and time.
     *
     * The subquery finds all barber IDs that are already booked at that slot,
     * and the outer query picks the first active barber NOT in that list.
     *
     * Returns null if every active barber is already booked (slot is full).
     */
    public Barber getFirstAvailableBarber(Date date, Time time) {
        String sql = "SELECT * FROM barbers WHERE is_active = 1 "
                   + "AND barber_id NOT IN ("
                   + "  SELECT barber_id FROM appointments "
                   + "  WHERE appt_date = ? AND appt_time = ? "
                   + "  AND status NOT IN ('cancelled')"  // cancelled slots free up the barber
                   + ") ORDER BY barber_id LIMIT 1";      // always pick the same barber first (consistent)
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setTime(2, time);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs); // found an available barber
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // no barber available at this slot
    }

    // ── Private helper ─────────────────────────────────────────────────────

    /** Converts one ResultSet row into a Barber object. */
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
