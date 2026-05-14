package com.barbers.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.ReviewDAO;
import com.barbers.dao.UserDAO;
import com.barbers.util.SessionUtils;

/**
 * AdminServlet — handles admin-only POST actions.
 *
 * Actions:
 *   updateStatus    → change an appointment's status (confirm / complete / cancel)
 *   toggleCustomer  → enable or disable a customer account
 *   toggleReview    → show or hide a customer review on the public page
 *
 * URL: /admin
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    // DAO objects used to talk to the database
    private final AppointmentDAO apptDAO   = new AppointmentDAO();
    private final UserDAO        userDAO   = new UserDAO();
    private final ReviewDAO      reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Make sure text from forms is read as UTF-8 (supports special characters)
        req.setCharacterEncoding("UTF-8");

        // Get the current session (false = don't create a new one if missing)
        HttpSession session = req.getSession(false);

        // Block anyone who is not a logged-in admin
        if (!SessionUtils.isAdmin(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Read which action the form is requesting
        String action = req.getParameter("action");

        if ("updateStatus".equals(action)) {
            // ── Change appointment status (e.g. pending → confirmed) ──
            int    id     = Integer.parseInt(req.getParameter("appointmentId"));
            String status = req.getParameter("status"); // "confirmed", "completed", or "cancelled"
            apptDAO.updateStatus(id, status);
            // Redirect back to appointments page with a success message
            res.sendRedirect(req.getContextPath() + "/admin/appointments.jsp?success=updated");

        } else if ("toggleCustomer".equals(action)) {
            // ── Enable or disable a customer account ──
            int id     = Integer.parseInt(req.getParameter("userId"));
            int status = Integer.parseInt(req.getParameter("currentStatus")); // 1 = active, 0 = disabled
            // Flip the status: if currently active (1) → set to 0, and vice versa
            userDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/customers.jsp");

        } else if ("toggleReview".equals(action)) {
            // ── Show or hide a review on the public page ──
            int id     = Integer.parseInt(req.getParameter("reviewId"));
            int status = Integer.parseInt(req.getParameter("currentStatus")); // 1 = visible, 0 = hidden
            // Flip the visibility
            reviewDAO.toggleVisibility(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");

        } else {
            // Unknown action — just go back to the dashboard
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        }
    }
}
