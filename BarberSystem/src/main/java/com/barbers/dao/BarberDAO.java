package com.barbers.dao;

import com.barbers.model.Barber;
import com.barbers.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
     * Permanently deletes a barber from the database.
     * Sets barber_id to NULL on any linked appointments first to avoid FK violation.
     *
     * @param id the barber_id to delete
     * @return {@code true} on success
     */
    public boolean deleteBarber(int id) {
        String nullifyAppts = "UPDATE appointments SET barber_id = NULL WHERE barber_id = ?";
        String deleteSql    = "DELETE FROM barbers WHERE barber_id = ?";
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps1 = c.prepareStatement(nullifyAppts);
                 PreparedStatement ps2 = c.prepareStatement(deleteSql)) {
                ps1.setInt(1, id);
                ps1.executeUpdate();
                ps2.setInt(1, id);
                int rows = ps2.executeUpdate();
                c.commit();
                return rows > 0;
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
     * Returns ALL active barbers for a given slot, each tagged with whether
     * they are already booked. Booked barbers are shown as disabled in the UI
     * instead of disappearing.
     *
     * @param date the appointment date
     * @param time the appointment time
     * @return list of all active {@link Barber} objects, booked ones have isBooked=true
     */
    public List<Barber> getAllBarbersWithAvailability(Date date, Time time) {
        List<Barber> list = new ArrayList<>();
        String sql = "SELECT b.*, "
                   + "  CASE WHEN a.barber_id IS NOT NULL THEN 1 ELSE 0 END AS is_booked "
                   + "FROM barbers b "
                   + "LEFT JOIN appointments a "
                   + "  ON b.barber_id = a.barber_id "
                   + "  AND a.appt_date = ? AND a.appt_time = ? "
                   + "  AND a.status IN ('pending', 'confirmed') "
                   + "WHERE b.is_active = 1 "
                   + "ORDER BY b.name";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setTime(2, time);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Barber b = mapRow(rs);
                b.setBooked(rs.getInt("is_booked") == 1);
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns active barbers who are FREE at the given date and time.
     * Used to populate the barber-selection step on the booking page.
     *
     * @param date the appointment date
     * @param time the appointment time
     * @return list of available {@link Barber} objects
     */
    public List<Barber> getAvailableBarbersForSlot(Date date, Time time) {
        List<Barber> list = new ArrayList<>();
        String sql = "SELECT * FROM barbers WHERE is_active = 1 "
                   + "AND barber_id NOT IN ("
                   + "  SELECT barber_id FROM appointments "
                   + "  WHERE appt_date = ? AND appt_time = ? "
                   + "  AND status IN ('pending', 'confirmed')"
                   + ") ORDER BY name";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setTime(2, time);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
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
                   + "  AND status IN ('pending', 'confirmed')"
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
