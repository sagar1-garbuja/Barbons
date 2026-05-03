package com.barbers.controller;

import com.barbers.dao.ServiceDAO;
import com.barbers.model.Service;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles CRUD operations for services (admin only).
 * URL: /service
 */
@WebServlet("/service")
public class ServiceServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setAttribute("services", serviceDAO.getAllServices());
        req.getRequestDispatcher("/admin/services.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            String name     = trim(req.getParameter("serviceName"));
            String desc     = trim(req.getParameter("description"));
            String priceStr = trim(req.getParameter("price"));
            String durStr   = trim(req.getParameter("duration"));

            if (name.isEmpty() || priceStr.isEmpty() || durStr.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/admin/services.jsp?error=missing");
                return;
            }
            double price    = Double.parseDouble(priceStr);
            int    duration = Integer.parseInt(durStr);
            if (price <= 0 || duration <= 0) {
                res.sendRedirect(req.getContextPath() + "/admin/services.jsp?error=invalid");
                return;
            }
            Service s = new Service(name, desc, price, duration, 1);
            serviceDAO.insertService(s);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp?success=added");

        } else if ("update".equals(action)) {
            int    id       = Integer.parseInt(req.getParameter("serviceId"));
            String name     = trim(req.getParameter("serviceName"));
            String desc     = trim(req.getParameter("description"));
            double price    = Double.parseDouble(req.getParameter("price"));
            int    duration = Integer.parseInt(req.getParameter("duration"));
            Service s = new Service(name, desc, price, duration, 1);
            s.setServiceId(id);
            serviceDAO.updateService(s);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp?success=updated");

        } else if ("toggle".equals(action)) {
            int id     = Integer.parseInt(req.getParameter("serviceId"));
            int status = Integer.parseInt(req.getParameter("currentStatus"));
            serviceDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp");
        } else {
            res.sendRedirect(req.getContextPath() + "/admin/services.jsp");
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
