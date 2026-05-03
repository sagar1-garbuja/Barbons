package com.barbers.controller;

import com.barbers.dao.UserDAO;
import com.barbers.model.User;
import com.barbers.util.CookieUtils;
import com.barbers.util.PasswordUtils;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles registration, login, and logout.
 * URL: /auth
 */
@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

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

        String fullName        = trim(req.getParameter("fullName"));
        String email           = trim(req.getParameter("email"));
        String phone           = trim(req.getParameter("phone"));
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Repopulate on error
        req.setAttribute("fullName", fullName);
        req.setAttribute("email",    email);
        req.setAttribute("phone",    phone);

        // ── Server-side validation ──
        if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()
                || password == null || password.isEmpty() || confirmPassword == null) {
            req.setAttribute("errorMsg", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            req.setAttribute("errorMsg", "Invalid email address.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (!phone.matches("^\\d{10}$")) {
            req.setAttribute("errorMsg", "Phone must be exactly 10 digits.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (!password.matches("(?=.*\\d).{8,}")) {
            req.setAttribute("errorMsg", "Password must be at least 8 characters and contain a number.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (userDAO.emailExists(email)) {
            req.setAttribute("errorMsg", "Email is already registered.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }
        if (userDAO.phoneExists(phone)) {
            req.setAttribute("errorMsg", "Phone number is already registered.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        User u = new User(fullName, email, phone, PasswordUtils.hashMD5(password), "customer", 1);
        if (userDAO.insertUser(u)) {
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
        String rememberMe = req.getParameter("rememberMe");

        req.setAttribute("email", email);

        if (email.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        User user = userDAO.getUserByEmail(email);
        if (user == null || !PasswordUtils.verify(password, user.getPassword())) {
            req.setAttribute("errorMsg", "Invalid email or password.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }
        if (user.getIsActive() == 0) {
            req.setAttribute("errorMsg", "Your account has been disabled. Contact support.");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
            return;
        }

        SessionUtils.createSession(req.getSession(), user);

        if ("on".equals(rememberMe) || "true".equals(rememberMe)) {
            CookieUtils.setRememberMe(res, email);
        } else {
            CookieUtils.clearRememberMe(res);
        }

        if ("admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        } else {
            res.sendRedirect(req.getContextPath() + "/customer/dashboard.jsp");
        }
    }

    // ── Logout ────────────────────────────────────────────────────────────

    private void handleLogout(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        SessionUtils.destroySession(req.getSession(false));
        CookieUtils.clearRememberMe(res);
        res.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    // ── Helper ────────────────────────────────────────────────────────────

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
