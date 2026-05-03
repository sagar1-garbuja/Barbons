package com.barbers.dao;

import com.barbers.model.Review;
import com.barbers.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the {@code reviews} table.
 */
public class ReviewDAO {

    /**
     * Inserts a new review.
     *
     * @param r the Review to insert
     * @return {@code true} on success
     */
    public boolean insertReview(Review r) {
        String sql = "INSERT INTO reviews (appointment_id, user_id, rating, comment, is_visible, created_at) "
                   + "VALUES (?, ?, ?, ?, 1, NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, r.getAppointmentId());
            ps.setInt(2, r.getUserId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all visible reviews (is_visible = 1) for the public pages.
     *
     * @return list of visible {@link Review} objects with joined customer/service names
     */
    public List<Review> getVisibleReviews() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS customer_name, s.service_name "
                   + "FROM reviews r "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN appointments a ON r.appointment_id = a.appointment_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "WHERE r.is_visible = 1 ORDER BY r.created_at DESC";
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
     * Returns all reviews regardless of visibility (admin view).
     *
     * @return list of all {@link Review} objects
     */
    public List<Review> getAllReviews() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS customer_name, s.service_name "
                   + "FROM reviews r "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN appointments a ON r.appointment_id = a.appointment_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "ORDER BY r.created_at DESC";
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
     * Toggles the is_visible flag for a review (admin show/hide).
     *
     * @param id     the review_id
     * @param status 1 to show, 0 to hide
     * @return {@code true} on success
     */
    public boolean toggleVisibility(int id, int status) {
        String sql = "UPDATE reviews SET is_visible=? WHERE review_id=?";
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

    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setAppointmentId(rs.getInt("appointment_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setIsVisible(rs.getInt("is_visible"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        try { r.setCustomerName(rs.getString("customer_name")); } catch (SQLException ignored) {}
        try { r.setServiceName(rs.getString("service_name")); }   catch (SQLException ignored) {}
        return r;
    }
}
