package com.barbers.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.BarberDAO;
import com.barbers.model.Appointment;
import com.barbers.model.Barber;
import com.barbers.util.SessionUtils;

/**
 * AppointmentServlet — handles booking and cancellation of appointments.
 *
 * GET  /appointment?action=getBookedTimes&date=YYYY-MM-DD
 *      → returns a JSON array of already-booked time slots for that date
 *        (used by the booking page to disable unavailable times)
 *
 * POST /appointment?action=book   → books a new appointment
 * POST /appointment?action=cancel → cancels an existing appointment
 *
 * URL: /appointment
 */
@WebServlet("/appointment")
public class AppointmentServlet extends HttpServlet {

    // DAOs for appointments and barbers
    private final AppointmentDAO apptDAO   = new AppointmentDAO();
    private final BarberDAO      barberDAO = new BarberDAO();

    // ── GET: return booked times as JSON ──────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("getBookedTimes".equals(action)) {
            // The booking page calls this via AJAX to know which time slots are full
            String dateStr = req.getParameter("date"); // expected format: YYYY-MM-DD

            // Tell the browser we are sending back JSON text
            res.setContentType("application/json");
            res.setCharacterEncoding("UTF-8");
            PrintWriter out = res.getWriter();

            try {
                Date date = Date.valueOf(dateStr); // convert the string to a SQL Date
                List<String> times = apptDAO.getBookedTimesForDate(date);

                // Build a JSON array manually, e.g. ["09:00","10:00"]
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < times.size(); i++) {
                    sb.append("\"").append(times.get(i)).append("\"");
                    if (i < times.size() - 1) sb.append(","); // add comma between items
                }
                sb.append("]");
                out.print(sb.toString());

            } catch (Exception e) {
                // If anything goes wrong (bad date format, DB error), return an empty array
                out.print("[]");
            }

        } else {
            // Any other GET request just goes to the booking page
            res.sendRedirect(req.getContextPath() + "/customer/book.jsp");
        }
    }

    // ── POST: book or cancel ──────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        // Only logged-in customers can book or cancel
        if (!SessionUtils.isCustomer(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("book".equals(action)) {
            handleBook(req, res, session);
        } else if ("cancel".equals(action)) {
            handleCancel(req, res, session);
        } else {
            // Unknown action — send back to the booking page
            res.sendRedirect(req.getContextPath() + "/customer/book.jsp");
        }
    }

    // ── Book ──────────────────────────────────────────────────────────────

    private void handleBook(HttpServletRequest req, HttpServletResponse res, HttpSession session)
            throws ServletException, IOException {

        // Read the form fields submitted by the customer
        String serviceIdStr = req.getParameter("serviceId");
        String apptDateStr  = req.getParameter("apptDate");
        String apptTimeStr  = req.getParameter("apptTime");
        String notes        = req.getParameter("notes"); // optional

        // Make sure the required fields are not empty
        if (serviceIdStr == null || apptDateStr == null || apptTimeStr == null
                || serviceIdStr.isEmpty() || apptDateStr.isEmpty() || apptTimeStr.isEmpty()) {
            req.setAttribute("errorMsg", "Please fill in all required fields.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        int  serviceId = Integer.parseInt(serviceIdStr);
        Date apptDate;
        Time apptTime;

        try {
            apptDate = Date.valueOf(apptDateStr);           // "YYYY-MM-DD" → SQL Date
            apptTime = Time.valueOf(apptTimeStr + ":00");   // "HH:MM" → "HH:MM:00" → SQL Time
        } catch (IllegalArgumentException e) {
            // The date or time string was in the wrong format
            req.setAttribute("errorMsg", "Invalid date or time format.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        // Auto-assign: find the first active barber who is free at this date/time
        Barber barber = barberDAO.getFirstAvailableBarber(apptDate, apptTime);
        if (barber == null) {
            // All barbers are busy at this slot — ask the customer to pick another time
            req.setAttribute("errorMsg", "No barbers available for this slot. Please choose another time.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        // Get the logged-in customer's ID from the session
        int userId = (Integer) session.getAttribute("userId");

        // Build the Appointment object with all the collected data
        Appointment appt = new Appointment();
        appt.setUserId(userId);
        appt.setBarberId(barber.getBarberId()); // auto-assigned barber
        appt.setServiceId(serviceId);
        appt.setApptDate(apptDate);
        appt.setApptTime(apptTime);
        appt.setNotes(notes);

        // Save to the database and redirect on success
        if (apptDAO.insertAppointment(appt)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?success=booked");
        } else {
            req.setAttribute("errorMsg", "Booking failed. Please try again.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
        }
    }

    // ── Cancel ────────────────────────────────────────────────────────────

    private void handleCancel(HttpServletRequest req, HttpServletResponse res, HttpSession session)
            throws IOException {

        String idStr = req.getParameter("id"); // the appointment ID to cancel

        if (idStr != null && !idStr.isEmpty()) {
            int userId = (Integer) session.getAttribute("userId");
            // cancelByUser checks that the appointment belongs to this user before cancelling
            apptDAO.cancelByUser(Integer.parseInt(idStr), userId);
        }

        // Redirect back to the appointments list with a success message
        res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?success=cancelled");
    }
}
