package com.barbers.dao;

import com.barbers.model.User;
import com.barbers.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the {@code users} table.
 */
public class UserDAO {

    /**
     * Inserts a new user (registration).
     *
     * @param u the User to insert (role, isActive must be set by caller)
     * @return {@code true} if the row was inserted successfully
     */
    public boolean insertUser(User u) {
        String sql = "INSERT INTO users (full_name, email, phone, password, role, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getPassword());
            ps.setString(5, u.getRole());
            ps.setInt(6, u.getIsActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Looks up a user by email address (used during login).
     *
     * @param email the email to search for
     * @return the matching {@link User}, or {@code null} if not found
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Retrieves a user by their primary key.
     *
     * @param id the user_id
     * @return the matching {@link User}, or {@code null} if not found
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Returns all users with role = 'customer' (admin management view).
     *
     * @return list of customer {@link User} objects
     */
    public List<User> getAllCustomers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'customer' ORDER BY created_at DESC";
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
     * Updates a user's profile picture filename.
     * Automatically adds the column if it doesn't exist yet.
     *
     * @param id       the user_id
     * @param filename the saved filename (e.g. "42_1716800000000.jpg")
     * @return {@code true} on success
     */
    public boolean updateProfilePicture(int id, String filename) {
        // Ensure column exists — safe to run every time, ignored if already present
        String addCol = "ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_picture VARCHAR(255) DEFAULT NULL";
        String sql    = "UPDATE users SET profile_picture=?, updated_at=NOW() WHERE user_id=?";
        try (Connection c = DBConnection.getConnection()) {
            // Add column if missing (MySQL 8+ supports IF NOT EXISTS)
            try (PreparedStatement ps = c.prepareStatement(addCol)) {
                ps.executeUpdate();
            } catch (SQLException ignored) {
                // Older MySQL may not support IF NOT EXISTS — try plain ALTER
                try (PreparedStatement ps = c.prepareStatement(
                        "ALTER TABLE users ADD COLUMN profile_picture VARCHAR(255) DEFAULT NULL")) {
                    ps.executeUpdate();
                } catch (SQLException alreadyExists) {
                    // Column already exists — that's fine, continue
                }
            }
            // Now update
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, filename);
                ps.setInt(2, id);
                int rows = ps.executeUpdate();
                System.out.println("[ProfilePicture] Updated user_id=" + id + " filename=" + filename + " rows=" + rows);
                return rows > 0;
            }
        } catch (SQLException e) {
            System.err.println("[ProfilePicture] ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates a user's profile fields (full_name, email, phone).
     *
     * @param u the User with updated values; user_id must be set
     * @return {@code true} on success
     */
    public boolean updateUser(User u) {
        String sql = "UPDATE users SET full_name=?, email=?, phone=?, updated_at=NOW() WHERE user_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setInt(4, u.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates a user's password hash.
     *
     * @param id   the user_id
     * @param hash the new MD5 hash
     * @return {@code true} on success
     */
    public boolean updatePassword(int id, String hash) {
        String sql = "UPDATE users SET password=?, updated_at=NOW() WHERE user_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, hash);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Toggles the is_active flag for a user (admin enable/disable).
     *
     * @param id     the user_id
     * @param status 1 to activate, 0 to deactivate
     * @return {@code true} on success
     */
    public boolean toggleActive(int id, int status) {
        String sql = "UPDATE users SET is_active=?, updated_at=NOW() WHERE user_id=?";
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
     * Checks whether an email address is already registered.
     *
     * @param email the email to check
     * @return {@code true} if the email exists
     */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks whether a phone number is already registered.
     *
     * @param phone the phone number to check
     * @return {@code true} if the phone exists
     */
    public boolean phoneExists(String phone) {
        String sql = "SELECT 1 FROM users WHERE phone = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Private helper ─────────────────────────────────────────────────────

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setIsActive(rs.getInt("is_active"));
        // profile_picture column may not exist in older DB schemas — handle gracefully
        try { u.setProfilePicture(rs.getString("profile_picture")); }
        catch (SQLException ignored) { u.setProfilePicture(null); }
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }
}
