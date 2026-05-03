package com.barbers.controller;

import com.barbers.dao.UserDAO;
import com.barbers.model.User;
import com.barbers.util.PasswordUtils;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles customer profile updates and password changes.
 * URL: /profile
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (!SessionUtils.isCustomer(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    userId   = (Integer) session.getAttribute("userId");
        String action   = req.getParameter("action");

        if ("updateProfile".equals(action)) {
            String fullName = trim(req.getParameter("fullName"));
            String email    = trim(req.getParameter("email"));
            String phone    = trim(req.getParameter("phone"));

            if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()) {
                req.setAttribute("profileError", "All fields are required.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }
            if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                req.setAttribute("profileError", "Invalid email address.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }
            if (!phone.matches("^\\d{10}$")) {
                req.setAttribute("profileError", "Phone must be exactly 10 digits.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            User u = new User();
            u.setUserId(userId);
            u.setFullName(fullName);
            u.setEmail(email);
            u.setPhone(phone);

            if (userDAO.updateUser(u)) {
                // Update session name
                session.setAttribute("fullName", fullName);
                session.setAttribute("email", email);
                req.setAttribute("profileSuccess", "Profile updated successfully.");
            } else {
                req.setAttribute("profileError", "Update failed. Please try again.");
            }
            req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);

        } else if ("changePassword".equals(action)) {
            String currentPwd  = req.getParameter("currentPassword");
            String newPwd      = req.getParameter("newPassword");
            String confirmPwd  = req.getParameter("confirmPassword");

            if (currentPwd == null || newPwd == null || confirmPwd == null
                    || currentPwd.isEmpty() || newPwd.isEmpty() || confirmPwd.isEmpty()) {
                req.setAttribute("pwdError", "All password fields are required.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            User user = userDAO.getUserById(userId);
            if (!PasswordUtils.verify(currentPwd, user.getPassword())) {
                req.setAttribute("pwdError", "Current password is incorrect.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }
            if (!newPwd.matches("(?=.*\\d).{8,}")) {
                req.setAttribute("pwdError", "New password must be at least 8 characters with a number.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }
            if (!newPwd.equals(confirmPwd)) {
                req.setAttribute("pwdError", "New passwords do not match.");
                req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);
                return;
            }

            if (userDAO.updatePassword(userId, PasswordUtils.hashMD5(newPwd))) {
                req.setAttribute("pwdSuccess", "Password changed successfully.");
            } else {
                req.setAttribute("pwdError", "Password update failed. Please try again.");
            }
            req.getRequestDispatcher("/customer/profile.jsp").forward(req, res);

        } else {
            res.sendRedirect(req.getContextPath() + "/customer/profile.jsp");
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
