package com.barbers.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.barbers.model.User;
import com.barbers.util.DBConnection;

/**
 * UserDAO — all database operations for the 'users' table.
 */
public class UserDAO {

    /**
     * Saves a new user to the database (called during registration).
     * The password should already be hashed before calling this method.
     */
    public boolean insertUser(User u) {
        String sql = "INSERT INTO users (full_name, email, phone, password, role, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getPassword()); // already MD5-hashed
            ps.setString(5, u.getRole());     // "customer" or "admin"
            ps.setInt(6, u.getIsActive());    // 1 = active
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Finds a user by their email address.
     * Used during login to look up the account before checking the password.
     *
     * @return the User, or null if no account with that email exists
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs); // found — return the user
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // not found
    }

    /**
     * Finds a user by their primary key (user_id).
     * Used by ProfileServlet to load the current user's data.
     *
     * @return the User, or null if not found
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
     * Returns all users with role = "customer" for the admin customers page.
     * Admin accounts are excluded from this list.
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
     * Updates a user's name, email, and phone number.
     * Called from ProfileServlet when the customer saves their profile.
     */
    public boolean updateUser(User u) {
        String sql = "UPDATE users SET full_name=?, email=?, phone=?, updated_at=NOW() WHERE user_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setInt(4, u.getUserId()); // WHERE clause — which user to update
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Replaces a user's stored password hash with a new one.
     * Called from ProfileServlet after the old password has been verified.
     *
     * @param id   the user_id
     * @param hash the new MD5 hash to store
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
     * Enables or disables a customer account.
     * Disabled accounts (is_active = 0) cannot log in.
     *
     * @param id     the user_id
     * @param status 1 = active, 0 = disabled
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
     * Checks if an email address is already registered.
     * Used during registration to prevent duplicate accounts.
     *
     * @return true if the email is taken, false if it is available
     */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next(); // true if any row was found
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks if a phone number is already registered.
     * Used during registration to prevent duplicate accounts.
     *
     * @return true if the phone is taken, false if it is available
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

    /** Converts one ResultSet row into a User object. */
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setPassword(rs.getString("password")); // stored as MD5 hash
        u.setRole(rs.getString("role"));
        u.setIsActive(rs.getInt("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }
}
