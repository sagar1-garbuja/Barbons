package com.barbers.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.barbers.dao.BarberDAO;
import com.barbers.model.Barber;
import com.barbers.util.SessionUtils;

/**
 * BarberServlet — admin-only CRUD for barbers.
 *
 * GET  /barber              → load the barbers management page
 * POST /barber?action=add    → add a new barber
 * POST /barber?action=update → update an existing barber's details
 * POST /barber?action=toggle → activate or deactivate a barber
 *
 * URL: /barber
 */
@WebServlet("/barber")
public class BarberServlet extends HttpServlet {

    // DAO for barber database operations
    private final BarberDAO barberDAO = new BarberDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Only admins can access this page
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Load all barbers and pass them to the JSP for display
        req.setAttribute("barbers", barberDAO.getAllBarbers());
        req.getRequestDispatcher("/admin/barbers.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Block non-admins
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            // ── Add a new barber ──
            String name       = trim(req.getParameter("name"));
            String speciality = trim(req.getParameter("speciality")); // e.g. "Fades & Tapers"
            String bio        = trim(req.getParameter("bio"));

            // Name is required — reject if empty
            if (name.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?error=missing");
                return;
            }

            // Create the barber object and save it (is_active = 1 means active by default)
            Barber b = new Barber(name, speciality, bio, 1);
            barberDAO.insertBarber(b);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?success=added");

        } else if ("update".equals(action)) {
            // ── Update an existing barber's details ──
            int    id         = Integer.parseInt(req.getParameter("barberId"));
            String name       = trim(req.getParameter("name"));
            String speciality = trim(req.getParameter("speciality"));
            String bio        = trim(req.getParameter("bio"));

            // Build the updated barber object and set its ID so the DAO knows which row to update
            Barber b = new Barber(name, speciality, bio, 1);
            b.setBarberId(id);
            barberDAO.updateBarber(b);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?success=updated");

        } else if ("toggle".equals(action)) {
            // ── Activate or deactivate a barber ──
            int id     = Integer.parseInt(req.getParameter("barberId"));
            int status = Integer.parseInt(req.getParameter("currentStatus")); // 1 = active, 0 = inactive
            // Flip the status: 1 → 0 or 0 → 1
            barberDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp");

        } else {
            // Unknown action — go back to the barbers page
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp");
        }
    }

    // Safely trims a string; returns empty string if the input is null
    private String trim(String s) { return s == null ? "" : s.trim(); }
}
