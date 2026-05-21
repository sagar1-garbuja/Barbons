package com.barbers.controller;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.BarberDAO;
import com.barbers.model.Appointment;
import com.barbers.model.Barber;
import com.barbers.util.SessionUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
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

    // ── GET: return booked times or available barbers as JSON ─────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        if ("getBookedTimes".equals(action)) {
            String dateStr = req.getParameter("date");
            try {
                Date date = Date.valueOf(dateStr);
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

        } else if ("getAvailableBarbers".equals(action)) {
            String dateStr = req.getParameter("date");
            String timeStr = req.getParameter("time");
            try {
                Date date = Date.valueOf(dateStr);
                Time time = Time.valueOf(timeStr + ":00");
                List<com.barbers.model.Barber> barbers =
                        barberDAO.getAvailableBarbersForSlot(date, time);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < barbers.size(); i++) {
                    com.barbers.model.Barber b = barbers.get(i);
                    sb.append("{")
                      .append("\"id\":").append(b.getBarberId()).append(",")
                      .append("\"name\":\"").append(escapeJson(b.getName())).append("\",")
                      .append("\"speciality\":\"").append(escapeJson(
                              b.getSpeciality() != null ? b.getSpeciality() : "")).append("\"")
                      .append("}");
                    if (i < barbers.size() - 1) sb.append(",");
                }
                sb.append("]");
                out.print(sb.toString());
            } catch (Exception e) {
                out.print("[]");
            }

        } else {
            res.setContentType("text/html");
            res.sendRedirect(req.getContextPath() + "/customer/book.jsp");
        }
    }

    /** Minimal JSON string escaping. */
    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
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
        String barberIdStr  = req.getParameter("barberId");
        String notes        = req.getParameter("notes");
        String paymentMethod = req.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) paymentMethod = "cash";

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
            apptDate = Date.valueOf(apptDateStr);
            apptTime = Time.valueOf(apptTimeStr + ":00");
        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMsg", "Invalid date or time format.");
            req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
            return;
        }

        // Resolve barber — use chosen one if provided, otherwise auto-assign
        int barberId;
        if (barberIdStr != null && !barberIdStr.isEmpty()) {
            barberId = Integer.parseInt(barberIdStr);
            // Verify the chosen barber is still available for this slot
            boolean stillFree = barberDAO.getAvailableBarbersForSlot(apptDate, apptTime)
                    .stream().anyMatch(b -> b.getBarberId() == barberId);
            if (!stillFree) {
                req.setAttribute("errorMsg",
                        "That barber is no longer available for this slot. Please choose another.");
                req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
                return;
            }
        } else {
            // Fallback: auto-assign first available
            com.barbers.model.Barber barber = barberDAO.getFirstAvailableBarber(apptDate, apptTime);
            if (barber == null) {
                req.setAttribute("errorMsg",
                        "No barbers available for this slot. Please choose another time.");
                req.getRequestDispatcher("/customer/book.jsp").forward(req, res);
                return;
            }
            barberId = barber.getBarberId();
        }

        int userId = (Integer) session.getAttribute("userId");

        Appointment appt = new Appointment();
        appt.setUserId(userId);
        appt.setBarberId(barberId);
        appt.setServiceId(serviceId);
        appt.setApptDate(apptDate);
        appt.setApptTime(apptTime);
        appt.setNotes(notes);
        appt.setPaymentMethod(paymentMethod);

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
