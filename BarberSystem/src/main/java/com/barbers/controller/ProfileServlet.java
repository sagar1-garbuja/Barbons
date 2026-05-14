package com.barbers.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.barbers.dao.UserDAO;
import com.barbers.model.User;
import com.barbers.util.PasswordUtils;
import com.barbers.util.SessionUtils;

/**
 * ProfileServlet — lets a logged-in customer update their profile or change their password.
 *
 * POST /profile?action=updateProfile  → save new name, email, phone
 * POST /profile?action=changePassword → change password after verifying the current one
 *
 * URL: /profile
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    // DAO for reading and updating user records
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        // Only logged-in customers can update their profile
        if (!SessionUtils.isCustomer(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Get the logged-in user's ID from the session
        int    userId = (Integer) session.getAttribute("userId");
        String action = req.getParameter("action");

        if ("updateProfile".equals(action)) {
            // ── Update name, email, and phone ──
            String fullName = trim(req.getParameter("fullName"));
            String email    = trim(req.getParameter("email"));
            String phone    = trim(req.getParameter("phone"));

            // All three fields are required
            if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()) {
                req.setAttribute("profileError", "All fields are required.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // Validate email format
            if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                req.setAttribute("profileError", "Invalid email address.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // Phone must be exactly 10 digits
            if (!phone.matches("^\\d{10}$")) {
                req.setAttribute("profileError", "Phone must be exactly 10 digits.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // Build a User object with the new values and save to the database
            User u = new User();
            u.setUserId(userId);
            u.setFullName(fullName);
            u.setEmail(email);
            u.setPhone(phone);

            if (userDAO.updateUser(u)) {
                // Also update the session so the navbar shows the new name immediately
                session.setAttribute("fullName", fullName);
                session.setAttribute("email", email);
                req.setAttribute("profileSuccess", "Profile updated successfully.");
            } else {
                req.setAttribute("profileError", "Update failed. Please try again.");
            }

            // Stay on the profile page and show the result message
            req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);

        } else if ("changePassword".equals(action)) {
            // ── Change the user's password ──
            String currentPwd = req.getParameter("currentPassword");
            String newPwd     = req.getParameter("newPassword");
            String confirmPwd = req.getParameter("confirmPassword");

            // All three password fields must be filled in
            if (currentPwd == null || newPwd == null || confirmPwd == null
                    || currentPwd.isEmpty() || newPwd.isEmpty() || confirmPwd.isEmpty()) {
                req.setAttribute("pwdError", "All password fields are required.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // Load the user from the database to get their stored password hash
            User user = userDAO.getUserById(userId);

            // Verify the current password matches what is stored
            if (!PasswordUtils.verify(currentPwd, user.getPassword())) {
                req.setAttribute("pwdError", "Current password is incorrect.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // New password must be at least 8 characters and contain a number
            if (!newPwd.matches("(?=.*\\d).{8,}")) {
                req.setAttribute("pwdError", "New password must be at least 8 characters with a number.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // The two "new password" fields must match
            if (!newPwd.equals(confirmPwd)) {
                req.setAttribute("pwdError", "New passwords do not match.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            // Hash the new password and save it to the database
            if (userDAO.updatePassword(userId, PasswordUtils.hashMD5(newPwd))) {
                req.setAttribute("pwdSuccess", "Password changed successfully.");
            } else {
                req.setAttribute("pwdError", "Password update failed. Please try again.");
            }

            req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);

        } else {
            // Unknown action — go back to the profile page
            res.sendRedirect(req.getContextPath() + "/customer/profile.jsp");
        }
    }

    // Safely trims a string; returns empty string if the input is null
    private String trim(String s) { return s == null ? "" : s.trim(); }
}
