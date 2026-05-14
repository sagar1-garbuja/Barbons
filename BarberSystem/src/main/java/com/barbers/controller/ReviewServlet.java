package com.barbers.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.ReviewDAO;
import com.barbers.model.Appointment;
import com.barbers.model.Review;
import com.barbers.util.SessionUtils;

/**
 * ReviewServlet — lets a customer submit a review for a completed appointment.
 *
 * Rules enforced:
 *   1. The appointment must belong to the logged-in customer.
 *   2. The appointment must have status "completed".
 *   3. A review can only be submitted once per appointment.
 *
 * POST /review?action=submit → save the review
 *
 * URL: /review
 */
@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    // DAOs for reviews and appointments
    private final ReviewDAO      reviewDAO = new ReviewDAO();
    private final AppointmentDAO apptDAO   = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        // Only logged-in customers can submit reviews
        if (!SessionUtils.isCustomer(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Only handle the "submit" action
        String action = req.getParameter("action");
        if (!"submit".equals(action)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp");
            return;
        }

        // Get the logged-in customer's ID
        int    userId        = (Integer) session.getAttribute("userId");
        String apptIdStr     = req.getParameter("appointmentId");
        String ratingStr     = req.getParameter("rating");   // 1–5
        String comment       = trim(req.getParameter("comment")); // optional text

        // Both appointmentId and rating are required
        if (apptIdStr == null || ratingStr == null || apptIdStr.isEmpty() || ratingStr.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=missing");
            return;
        }

        int appointmentId = Integer.parseInt(apptIdStr);
        int rating        = Integer.parseInt(ratingStr);

        // ── Security check 1: appointment must belong to this user and be completed ──
        // Load all completed appointments for this customer
        List<Appointment> completed = apptDAO.getCompletedByUser(userId);

        // Check if the submitted appointmentId is in that list
        boolean eligible = completed.stream()
                .anyMatch(a -> a.getAppointmentId() == appointmentId);

        if (!eligible) {
            // The appointment either doesn't belong to this user or isn't completed yet
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=noteligible");
            return;
        }

        // ── Security check 2: a review must not already exist for this appointment ──
        if (apptDAO.hasReview(appointmentId)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=alreadyreviewed");
            return;
        }

        // All checks passed — build and save the review
        Review r = new Review();
        r.setAppointmentId(appointmentId);
        r.setUserId(userId);
        r.setRating(rating);
        r.setComment(comment);
        // is_visible defaults to 1 (visible) in the DAO insert

        if (reviewDAO.insertReview(r)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?success=reviewed");
        } else {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=failed");
        }
    }

    // Safely trims a string; returns empty string if the input is null
    private String trim(String s) { return s == null ? "" : s.trim(); }
}
