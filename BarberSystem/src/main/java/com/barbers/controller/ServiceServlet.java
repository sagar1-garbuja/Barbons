package com.barbers.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.barbers.dao.ServiceDAO;
import com.barbers.model.Service;
import com.barbers.util.SessionUtils;

/**
 * ServiceServlet — admin-only CRUD for barbering services.
 *
 * GET  /service              → load the services management page
 * POST /service?action=add    → add a new service
 * POST /service?action=update → update an existing service's details
 * POST /service?action=toggle → show or hide a service on the booking page
 *
 * URL: /service
 */
@WebServlet("/service")
public class ServiceServlet extends HttpServlet {

    // DAO for service database operations
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Only admins can access this page
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Load all services and pass them to the JSP for display
        req.setAttribute("services", serviceDAO.getAllServices());
        req.getRequestDispatcher("/admin/services.jsp").forward(req, res);
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
            // ── Add a new service ──
            String name     = trim(req.getParameter("serviceName"));
            String desc     = trim(req.getParameter("description")); // optional
            String priceStr = trim(req.getParameter("price"));
            String durStr   = trim(req.getParameter("duration"));    // in minutes

            // Name, price, and duration are all required
            if (name.isEmpty() || priceStr.isEmpty() || durStr.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/admin/services.jsp?error=missing");
                return;
            }

            double price    = Double.parseDouble(priceStr);
            int    duration = Integer.parseInt(durStr);

            // Price and duration must be positive numbers
            if (price <= 0 || duration <= 0) {
                res.sendRedirect(req.getContextPath() + "/admin/services.jsp?error=invalid");
                return;
            }

            // Create the service (is_active = 1 means visible on the booking page by default)
            Service s = new Service(name, desc, price, duration, 1);
            serviceDAO.insertService(s);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp?success=added");

        } else if ("update".equals(action)) {
            // ── Update an existing service ──
            int    id       = Integer.parseInt(req.getParameter("serviceId"));
            String name     = trim(req.getParameter("serviceName"));
            String desc     = trim(req.getParameter("description"));
            double price    = Double.parseDouble(req.getParameter("price"));
            int    duration = Integer.parseInt(req.getParameter("duration"));

            // Build the updated service object and set its ID so the DAO knows which row to update
            Service s = new Service(name, desc, price, duration, 1);
            s.setServiceId(id);
            serviceDAO.updateService(s);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp?success=updated");

        } else if ("toggle".equals(action)) {
            // ── Show or hide a service on the booking page ──
            int id     = Integer.parseInt(req.getParameter("serviceId"));
            int status = Integer.parseInt(req.getParameter("currentStatus")); // 1 = visible, 0 = hidden
            // Flip the status: 1 → 0 or 0 → 1
            serviceDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp");

        } else {
            // Unknown action — go back to the services page
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp");
        }
    }

    // Safely trims a string; returns empty string if the input is null
    private String trim(String s) { return s == null ? "" : s.trim(); }
}
