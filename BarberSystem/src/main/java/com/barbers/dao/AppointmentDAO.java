package com.barbers.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.barbers.model.Appointment;
import com.barbers.util.DBConnection;

/**
 * AppointmentDAO — all database operations for the 'appointments' table.
 */
public class AppointmentDAO {

    /**
     * Saves a new appointment to the database.
     * Status is always set to "pending" when first created.
     */
    public boolean insertAppointment(Appointment a) {
        String sql = "INSERT INTO appointments "
                   + "(user_id, barber_id, service_id, appt_date, appt_time, status, notes, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, 'pending', ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            // Fill in the ? placeholders in order
            ps.setInt(1, a.getUserId());
            ps.setInt(2, a.getBarberId());
            ps.setInt(3, a.getServiceId());
            ps.setDate(4, a.getApptDate());
            ps.setTime(5, a.getApptTime());
            ps.setString(6, a.getNotes());
            // executeUpdate returns the number of rows affected; > 0 means success
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all appointments for one customer, newest first.
     * Joins with users, services, and barbers so the JSP gets names directly.
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
            // Convert each row into an Appointment object and add to the list
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns every appointment in the system (used by the admin appointments page).
     * Joins with users, services, and barbers for display names.
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
     * Returns all appointments on a specific date (used for daily schedule views).
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
     * Returns a list of time strings ("HH:MM") that are fully booked on a given date.
     *
     * A time slot is "fully booked" when every active barber already has an appointment
     * at that time. The booking page uses this list (via AJAX) to disable those slots.
     */
    public List<String> getBookedTimesForDate(Date d) {
        List<String> times = new ArrayList<>();

        // Count how many distinct barbers are booked per time slot.
        // If that count equals the total number of active barbers, the slot is full.
        String sql = "SELECT TIME_FORMAT(appt_time, '%H:%i') AS t "
                   + "FROM appointments "
                   + "WHERE appt_date = ? AND status NOT IN ('cancelled') "
                   + "GROUP BY appt_time "
                   + "HAVING COUNT(DISTINCT barber_id) >= ("
                   + "  SELECT COUNT(*) FROM barbers WHERE is_active = 1"
                   + ")";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, d);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) times.add(rs.getString("t")); // collect each booked time
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return times;
    }

    /**
     * Changes the status of an appointment (e.g. pending → confirmed).
     * Called by the admin when they confirm, complete, or cancel a booking.
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
     * Cancels an appointment, but only if:
     *   1. The appointment belongs to the given user (ownership check — prevents one
     *      customer from cancelling another customer's appointment).
     *   2. The appointment is still in a cancellable state (pending or confirmed).
     */
    public boolean cancelByUser(int id, int userId) {
        String sql = "UPDATE appointments SET status='cancelled', updated_at=NOW() "
                   + "WHERE appointment_id=? AND user_id=? AND status IN ('pending','confirmed')";
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
     * Checks if a review already exists for a given appointment.
     * Used to prevent a customer from submitting two reviews for the same visit.
     */
    public boolean hasReview(int appointmentId) {
        String sql = "SELECT 1 FROM reviews WHERE appointment_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            return rs.next(); // true if at least one row was found
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all completed appointments for a customer.
     * Used by ReviewServlet to check if the customer is eligible to leave a review.
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
     * Returns the number of appointments scheduled for today.
     * Shown as a stat card on the admin dashboard.
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
     * Returns the number of appointments still waiting to be confirmed.
     * Shown as a stat card on the admin dashboard.
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
     * Returns the total revenue earned from all completed appointments.
     * Calculated by summing the price of the service for each completed booking.
     * COALESCE(..., 0) ensures we get 0 instead of NULL when there are no completed bookings.
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

    /**
     * Converts one row from a ResultSet into an Appointment object.
     * The try/catch blocks around joined fields handle cases where the query
     * didn't include those columns (e.g. a simple query without JOINs).
     */
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

        // These columns only exist when the query uses JOINs — ignore if missing
        try { a.setCustomerName(rs.getString("customer_name")); } catch (SQLException ignored) {}
        try { a.setServiceName(rs.getString("service_name")); }   catch (SQLException ignored) {}
        try { a.setServicePrice(rs.getDouble("service_price")); }  catch (SQLException ignored) {}
        try { a.setBarberName(rs.getString("barber_name")); }      catch (SQLException ignored) {}
        return a;
    }
}
