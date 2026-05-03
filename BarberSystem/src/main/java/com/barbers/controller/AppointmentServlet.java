package com.barbers.controller;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.BarberDAO;
import com.barbers.model.Appointment;
import com.barbers.model.Barber;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

/**
 * Handles appointment booking, cancellation, and booked-time AJAX queries.
 * URL: /appointment
 */
@WebServlet("/appointment")
public class AppointmentServlet extends HttpServlet {

    private final AppointmentDAO apptDAO   = new AppointmentDAO();
    private final BarberDAO      barberDAO = new BarberDAO();

    // ── GET: return booked times as JSON ──────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("getBookedTimes".equals(action)) {
            String dateStr = req.getParameter("date");
            res.setContentType("application/json");
            res.setCharacterEncoding("UTF-8");
            PrintWriter out = res.getWriter();
            try {
                Date date = Date.valueOf(dateStr); // expects YYYY-MM-DD
                List<String> times = apptDAO.getBookedTimesForDate(date);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < times.size(); i++) {
                    sb.append("\"").append(times.get(i)).append("\"");
                    if (i < times.size() - 1) sb.append(",");
                }
                sb.append("]");
                out.print(sb.toString());
            } catch (Exception e) {
                out.print("[]");
            }
        } else {
            res.sendRedirect(req.getContextPath() + "/customer/book.jsp");
        }
    }

    // ── POST: book or cancel ──────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        // Must be a logged-in customer
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
            res.sendRedirect(req.getContextPath() + "/customer/book.jsp");
        }
    }

    // ── Book ──────────────────────────────────────────────────────────────

    private void handleBook(HttpServletRequest req, HttpServletResponse res, HttpSession session)
            throws ServletException, IOException {

        String serviceIdStr = req.getParameter("serviceId");
        String apptDateStr  = req.getParameter("apptDate");
        String apptTimeStr  = req.getParameter("apptTime");
        String notes        = req.getParameter("notes");

        if (serviceIdStr == null || apptDateStr == null || apptTimeStr == null
                || serviceIdStr.isEmpty() || apptDateStr.isEmpty() || apptTimeStr.isEmpty()) {
            req.setAttribute("errorMsg", "Please fill in all required fields.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        int    serviceId = Integer.parseInt(serviceIdStr);
        Date   apptDate;
        Time   apptTime;

        try {
            apptDate = Date.valueOf(apptDateStr);
            // apptTime comes as "HH:MM" from the form
            apptTime = Time.valueOf(apptTimeStr + ":00");
        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMsg", "Invalid date or time format.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        // Auto-assign barber
        Barber barber = barberDAO.getFirstAvailableBarber(apptDate, apptTime);
        if (barber == null) {
            req.setAttribute("errorMsg", "No barbers available for this slot. Please choose another time.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        Appointment appt = new Appointment();
        appt.setUserId(userId);
        appt.setBarberId(barber.getBarberId());
        appt.setServiceId(serviceId);
        appt.setApptDate(apptDate);
        appt.setApptTime(apptTime);
        appt.setNotes(notes);

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

        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            int userId = (Integer) session.getAttribute("userId");
            apptDAO.cancelByUser(Integer.parseInt(idStr), userId);
        }
        res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?success=cancelled");
    }
}
