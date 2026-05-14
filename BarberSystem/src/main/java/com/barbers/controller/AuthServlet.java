package com.barbers.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.barbers.dao.UserDAO;
import com.barbers.model.User;
import com.barbers.util.CookieUtils;
import com.barbers.util.PasswordUtils;
import com.barbers.util.SessionUtils;

/**
 * AuthServlet — handles user registration, login, and logout.
 *
 * POST /auth?action=register → create a new customer account
 * POST /auth?action=login    → log in with email + password
 * GET  /auth?action=logout   → log out and clear the session
 *
 * URL: /auth
 */
@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    // DAO for reading and writing user records
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        // Route to the correct handler based on the action value
        if ("register".equals(action)) {
            handleRegister(req, res);
        } else if ("login".equals(action)) {
            handleLogin(req, res);
        } else if ("logout".equals(action)) {
            handleLogout(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Logout can also be triggered via a plain link (GET request)
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            handleLogout(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    // ── Register ──────────────────────────────────────────────────────────

    private void handleRegister(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Read and trim all form fields
        String fullName        = trim(req.getParameter("fullName"));
        String email           = trim(req.getParameter("email"));
        String phone           = trim(req.getParameter("phone"));
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Put the values back as request attributes so the form can re-fill them on error
        req.setAttribute("fullName", fullName);
        req.setAttribute("email",    email);
        req.setAttribute("phone",    phone);

        // ── Validation checks (server-side) ──

        // Check that no field is empty
        if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()
                || password == null || password.isEmpty() || confirmPassword == null) {
            req.setAttribute("errorMsg", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Check email format (must contain @ and a dot)
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            req.setAttribute("errorMsg", "Invalid email address.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Phone must be exactly 10 digits
        if (!phone.matches("^\\d{10}$")) {
            req.setAttribute("errorMsg", "Phone must be exactly 10 digits.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Password must be at least 8 characters and contain at least one number
        if (!password.matches("(?=.*\\d).{8,}")) {
            req.setAttribute("errorMsg", "Password must be at least 8 characters and contain a number.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Both password fields must match
        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Check the database — email must not already be registered
        if (userDAO.emailExists(email)) {
            req.setAttribute("errorMsg", "Email is already registered.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Check the database — phone must not already be registered
        if (userDAO.phoneExists(phone)) {
            req.setAttribute("errorMsg", "Phone number is already registered.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // All checks passed — create the user with a hashed password and role "customer"
        User u = new User(fullName, email, phone, PasswordUtils.hashMD5(password), "customer", 1);

        if (userDAO.insertUser(u)) {
            // Registration successful — send to login page with a success message
            req.setAttribute("successMsg", "Account created! Please sign in.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
        } else {
            req.setAttribute("errorMsg", "Registration failed. Please try again.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────

    private void handleLogin(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email      = trim(req.getParameter("email"));
        String password   = req.getParameter("password");
        String rememberMe = req.getParameter("rememberMe"); // checkbox value

        // Keep the email in the form if we need to show an error
        req.setAttribute("email", email);

        // Both fields are required
        if (email.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        // Look up the user by email in the database
        User user = userDAO.getUserByEmail(email);

        // If no user found, or the password hash doesn't match → wrong credentials
        if (user == null || !PasswordUtils.verify(password, user.getPassword())) {
            req.setAttribute("errorMsg", "Invalid email or password.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        // Check if the account has been disabled by an admin
        if (user.getIsActive() == 0) {
            req.setAttribute("errorMsg", "Your account has been disabled. Contact support.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        // All good — store user info in the session
        SessionUtils.createSession(req.getSession(), user);

        // Handle the "Remember Me" checkbox
        if ("on".equals(rememberMe) || "true".equals(rememberMe)) {
            CookieUtils.setRememberMe(res, email); // save email in a 7-day cookie
        } else {
            CookieUtils.clearRememberMe(res); // remove any existing remember-me cookie
        }

        // Redirect to the correct dashboard based on the user's role
        if ("admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        } else {
            res.sendRedirect(req.getContextPath() + "/customer/dashboard.jsp");
        }
    }

    // ── Logout ────────────────────────────────────────────────────────────

    private void handleLogout(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        // Destroy the session so the user is no longer recognised
        SessionUtils.destroySession(req.getSession(false));
        // Also clear the remember-me cookie
        CookieUtils.clearRememberMe(res);
        // Send back to the login page
        res.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    // ── Helper ────────────────────────────────────────────────────────────

    // Safely trims a string; returns empty string if the input is null
    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
