package com.barbers.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.barbers.model.Review;
import com.barbers.util.DBConnection;

/**
 * ReviewDAO — all database operations for the 'reviews' table.
 */
public class ReviewDAO {

    /**
     * Saves a new review to the database.
     * is_visible is set to 1 (visible) by default — admin can hide it later.
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
     * Returns only visible reviews (is_visible = 1) for the public pages.
     * Joins with users and services so the JSP can show the customer name and service.
     */
    public List<Review> getVisibleReviews() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS customer_name, s.service_name "
                   + "FROM reviews r "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN appointments a ON r.appointment_id = a.appointment_id "
                   + "JOIN services s ON a.service_id = s.service_id "
                   + "WHERE r.is_visible = 1 ORDER BY r.created_at DESC"; // newest first
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
     * Returns all reviews regardless of visibility (used by the admin dashboard).
     * Admin can see hidden reviews and choose to show or hide them.
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
     * Shows or hides a review on the public page.
     * Called by the admin when they click "Hide" or "Show" on the dashboard.
     *
     * @param id     the review_id to update
     * @param status 1 = visible, 0 = hidden
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

    /** Converts one ResultSet row into a Review object. */
    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setAppointmentId(rs.getInt("appointment_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setIsVisible(rs.getInt("is_visible"));
        r.setCreatedAt(rs.getTimestamp("created_at"));

        // These columns only exist when the query uses JOINs — ignore if missing
        try { r.setCustomerName(rs.getString("customer_name")); } catch (SQLException ignored) {}
        try { r.setServiceName(rs.getString("service_name")); }   catch (SQLException ignored) {}
        return r;
    }
}
