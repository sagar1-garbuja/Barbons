package com.barbers.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import com.barbers.dao.UserDAO;
import com.barbers.model.User;
import com.barbers.util.PasswordUtils;
import com.barbers.util.SessionUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 * Handles customer profile updates, password changes, and profile picture upload.
 * URL: /profile
 */
@WebServlet("/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB — buffer before writing to disk
    maxFileSize       = 3 * 1024 * 1024,   // 3 MB max per file
    maxRequestSize    = 5 * 1024 * 1024    // 5 MB max total request
)
public class ProfileServlet extends HttpServlet {

    private static final Set<String> ALLOWED_TYPES = new HashSet<>(
            Arrays.asList("image/jpeg", "image/png", "image/gif", "image/webp"));

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (!SessionUtils.isCustomer(session) && !SessionUtils.isAdmin(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    userId = (Integer) session.getAttribute("userId");
        String action = req.getParameter("action");

        if ("uploadPicture".equals(action)) {
            handleUploadPicture(req, res, session, userId);

        } else if ("updateProfile".equals(action)) {
            handleUpdateProfile(req, res, session, userId);

        } else if ("changePassword".equals(action)) {
            handleChangePassword(req, res, session, userId);

        } else {
            res.sendRedirect(req.getContextPath() + getProfilePage(session));
        }
    }

    private String getProfilePage(HttpSession session) {
        if (session == null) return "/login.jsp";
        String role = (String) session.getAttribute("role");
        return "admin".equals(role) ? "/admin/profile.jsp" : "/customer/profile.jsp";
    }

    // ── Upload profile picture ────────────────────────────────────────────

    private void handleUploadPicture(HttpServletRequest req, HttpServletResponse res,
                                     HttpSession session, int userId)
            throws ServletException, IOException {

        Part filePart = req.getPart("profilePicture");

        String targetPage = getProfilePage(session);
        if (filePart == null || filePart.getSize() == 0) {
            req.setAttribute("picError", "Please select an image file.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        // Validate MIME type
        String contentType = filePart.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType.toLowerCase())) {
            req.setAttribute("picError", "Only JPG, PNG, GIF, or WEBP images are allowed.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        // Validate size (3 MB)
        if (filePart.getSize() > 3 * 1024 * 1024) {
            req.setAttribute("picError", "Image must be smaller than 3 MB.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        // Build safe filename: userId_timestamp.ext
        String ext      = contentType.substring(contentType.lastIndexOf('/') + 1)
                                     .replace("jpeg", "jpg");
        String filename = userId + "_" + System.currentTimeMillis() + "." + ext;

        // ── Save to a persistent folder OUTSIDE the webapp ──────────────
        // Reads upload.dir from web.xml context-param (default: C:/barbons_uploads)
        // This folder survives WAR redeployments unlike getRealPath().
        String baseDir = getServletContext().getInitParameter("upload.dir");
        if (baseDir == null || baseDir.trim().isEmpty()) {
            baseDir = "C:/barbons_uploads";
        }
        String uploadDir = baseDir + "/profiles";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, Paths.get(uploadDir, filename), StandardCopyOption.REPLACE_EXISTING);
        }

        // Delete old picture if it exists
        User existing = userDAO.getUserById(userId);
        if (existing != null && existing.getProfilePicture() != null) {
            File old = new File(uploadDir, existing.getProfilePicture());
            if (old.exists()) old.delete();
        }

        // Persist filename to database
        if (userDAO.updateProfilePicture(userId, filename)) {
            session.setAttribute("profilePicture", filename);
            req.setAttribute("picSuccess", "Profile picture updated successfully.");
        } else {
            req.setAttribute("picError", "Failed to save picture. Please try again.");
        }

        req.getRequestDispatcher(targetPage).forward(req, res);
    }

    // ── Update profile info ───────────────────────────────────────────────

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse res,
                                     HttpSession session, int userId)
            throws ServletException, IOException {

        String fullName = trim(req.getParameter("fullName"));
        String email    = trim(req.getParameter("email"));
        String phone    = trim(req.getParameter("phone"));

        String targetPage = getProfilePage(session);
        if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()) {
            req.setAttribute("profileError", "All fields are required.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            req.setAttribute("profileError", "Invalid email address.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }
        if (!phone.matches("^\\d{10}$")) {
            req.setAttribute("profileError", "Phone must be exactly 10 digits.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        User u = new User();
        u.setUserId(userId);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);

        if (userDAO.updateUser(u)) {
            session.setAttribute("fullName", fullName);
            session.setAttribute("email", email);
            req.setAttribute("profileSuccess", "Profile updated successfully.");
        } else {
            req.setAttribute("profileError", "Update failed. Please try again.");
        }
        req.getRequestDispatcher(targetPage).forward(req, res);
    }

    // ── Change password ───────────────────────────────────────────────────

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse res,
                                      HttpSession session, int userId)
            throws ServletException, IOException {

        String currentPwd = req.getParameter("currentPassword");
        String newPwd     = req.getParameter("newPassword");
        String confirmPwd = req.getParameter("confirmPassword");

        String targetPage = getProfilePage(session);
        if (currentPwd == null || newPwd == null || confirmPwd == null
                || currentPwd.isEmpty() || newPwd.isEmpty() || confirmPwd.isEmpty()) {
            req.setAttribute("pwdError", "All password fields are required.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        User user = userDAO.getUserById(userId);
        if (!PasswordUtils.verify(currentPwd, user.getPassword())) {
            req.setAttribute("pwdError", "Current password is incorrect.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }
        if (!newPwd.matches("(?=.*\\d).{8,}")) {
            req.setAttribute("pwdError", "New password must be at least 8 characters with a number.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }
        if (!newPwd.equals(confirmPwd)) {
            req.setAttribute("pwdError", "New passwords do not match.");
            req.getRequestDispatcher(targetPage).forward(req, res);
            return;
        }

        if (userDAO.updatePassword(userId, PasswordUtils.hashMD5(newPwd))) {
            req.setAttribute("pwdSuccess", "Password changed successfully.");
        } else {
            req.setAttribute("pwdError", "Password update failed. Please try again.");
        }
        req.getRequestDispatcher(targetPage).forward(req, res);
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
