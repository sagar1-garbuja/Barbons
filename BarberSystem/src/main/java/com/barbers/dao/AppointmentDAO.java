package com.barbers.dao;

import com.barbers.model.Appointment;
import com.barbers.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the {@code appointments} table.
 */
public class AppointmentDAO {

    /**
     * Inserts a new appointment row.
     *
     * @param a the Appointment to insert (barberId must already be set by auto-assign)
     * @return {@code true} on success
     */
    public boolean insertAppointment(Appointment a) {
        // Ensure payment columns exist (auto-migrate)
        try (Connection c = DBConnection.getConnection()) {
            try (PreparedStatement ps = c.prepareStatement(
                    "ALTER TABLE appointments ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20) DEFAULT 'cash'")) {
                ps.executeUpdate();
            } catch (SQLException ignored) {}
            try (PreparedStatement ps = c.prepareStatement(
                    "ALTER TABLE appointments ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'unpaid'")) {
                ps.executeUpdate();
            } catch (SQLException ignored) {}
        } catch (SQLException ignored) {}

        String sql = "INSERT INTO appointments "
                   + "(user_id, barber_id, service_id, appt_date, appt_time, status, notes, "
                   + "payment_method, payment_status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, a.getUserId());
            ps.setInt(2, a.getBarberId());
            ps.setInt(3, a.getServiceId());
            ps.setDate(4, a.getApptDate());
            ps.setTime(5, a.getApptTime());
            ps.setString(6, a.getNotes());
            ps.setString(7, a.getPaymentMethod() != null ? a.getPaymentMethod() : "cash");
            ps.setString(8, "esewa".equals(a.getPaymentMethod()) || "fonepay".equals(a.getPaymentMethod())
                            ? "paid" : "unpaid");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all appointments for a specific customer, newest first.
     *
     * @param userId the customer's user_id
     * @return list of {@link Appointment} objects with joined service/barber names
     */
    public List<Appointment> getAppointmentsByUser(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS customer_name, "
                   + "s.service_name, s.price AS service_price, b.name AS barber_name "
                   + "FROM appointments a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "JOIN barbers b ON a.barber_id = b.barber_id "
                   + "WHERE a.user_id = ? ORDER BY a.appt_date DESC, a.appt_time DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns all appointments in the system (admin view), newest first.
     *
     * @return list of all {@link Appointment} objects with joined names
     */
    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS customer_name, "
                   + "s.service_name, s.price AS service_price, b.name AS barber_name "
                   + "FROM appointments a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "JOIN barbers b ON a.barber_id = b.barber_id "
                   + "ORDER BY a.appt_date DESC, a.appt_time DESC";
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
     * Returns all appointments for a specific date (admin/barber view).
     *
     * @param d the date to filter by
     * @return list of {@link Appointment} objects
     */
    public List<Appointment> getAppointmentsByDate(Date d) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS customer_name, "
                   + "s.service_name, s.price AS service_price, b.name AS barber_name "
                   + "FROM appointments a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "JOIN barbers b ON a.barber_id = b.barber_id "
                   + "WHERE a.appt_date = ? ORDER BY a.appt_time";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, d);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns a list of booked time strings ("HH:MM") for a given date.
     * A slot is considered booked if ALL active barbers are taken at that time.
     * Used by the booking page AJAX to disable fully-booked slots.
     *
     * @param d the date to check
     * @return list of time strings in "HH:MM" format
     */
    public List<String> getBookedTimesForDate(Date d) {
        List<String> times = new ArrayList<>();
        // A slot is fully booked when the number of distinct barbers booked
        // equals the total number of active barbers.
        String sql = "SELECT TIME_FORMAT(appt_time, '%H:%i') AS t "
                   + "FROM appointments "
                   + "WHERE appt_date = ? AND status IN ('pending', 'confirmed') "
                   + "GROUP BY appt_time "
                   + "HAVING COUNT(DISTINCT barber_id) >= ("
                   + "  SELECT COUNT(*) FROM barbers WHERE is_active = 1"
                   + ")";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, d);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) times.add(rs.getString("t"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return times;
    }

    /**
     * Updates the status of an appointment (admin action).
     *
     * @param id     the appointment_id
     * @param status the new status string
     * @return {@code true} on success
     */
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE appointments SET status=?, updated_at=NOW() WHERE appointment_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cancels an appointment only if it belongs to the given user
     * and is in a cancellable state (pending or confirmed).
     *
     * @param id     the appointment_id
     * @param userId the requesting user's id (ownership check)
     * @return {@code true} on success
     */
    public boolean cancelByUser(int id, int userId) {
        // Only allow cancellation of PENDING appointments.
        // Once admin confirms (status = 'confirmed'), customer cannot cancel.
        String sql = "UPDATE appointments SET status='cancelled', updated_at=NOW() "
                   + "WHERE appointment_id=? AND user_id=? AND status = 'pending'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks whether a review already exists for a given appointment.
     *
     * @param appointmentId the appointment to check
     * @return {@code true} if a review row exists
     */
    public boolean hasReview(int appointmentId) {
        String sql = "SELECT 1 FROM reviews WHERE appointment_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all completed appointments for a user (used to determine
     * which ones are eligible for a review).
     *
     * @param userId the customer's user_id
     * @return list of completed {@link Appointment} objects
     */
    public List<Appointment> getCompletedByUser(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS customer_name, "
                   + "s.service_name, s.price AS service_price, b.name AS barber_name "
                   + "FROM appointments a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "JOIN barbers b ON a.barber_id = b.barber_id "
                   + "WHERE a.user_id = ? AND a.status = 'completed'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns the count of today's appointments (admin dashboard stat).
     *
     * @return integer count
     */
    public int getTodayCount() {
        String sql = "SELECT COUNT(*) FROM appointments WHERE appt_date = CURDATE()";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Returns the count of pending appointments (admin dashboard stat).
     *
     * @return integer count
     */
    public int getPendingCount() {
        String sql = "SELECT COUNT(*) FROM appointments WHERE status = 'pending'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Returns the total revenue from all completed appointments
     * (sum of the associated service prices).
     *
     * @return total revenue as a double
     */
    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(s.price), 0) "
                   + "FROM appointments a JOIN services s ON a.service_id = s.service_id "
                   + "WHERE a.status = 'completed'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // ── Private helper ─────────────────────────────────────────────────────

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setAppointmentId(rs.getInt("appointment_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setBarberId(rs.getInt("barber_id"));
        a.setServiceId(rs.getInt("service_id"));
        a.setApptDate(rs.getDate("appt_date"));
        a.setApptTime(rs.getTime("appt_time"));
        a.setStatus(rs.getString("status"));
        a.setNotes(rs.getString("notes"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        // joined columns (may be null if not joined)
        try { a.setCustomerName(rs.getString("customer_name")); } catch (SQLException ignored) {}
        try { a.setServiceName(rs.getString("service_name")); }   catch (SQLException ignored) {}
        try { a.setServicePrice(rs.getDouble("service_price")); }  catch (SQLException ignored) {}
        try { a.setBarberName(rs.getString("barber_name")); }      catch (SQLException ignored) {}
        try { a.setPaymentMethod(rs.getString("payment_method")); } catch (SQLException ignored) {}
        try { a.setPaymentStatus(rs.getString("payment_status")); } catch (SQLException ignored) {}
        return a;
    }
}
