package com.barbers.controller;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.ReviewDAO;
import com.barbers.dao.UserDAO;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles admin-only actions: update appointment status,
 * toggle customer active state, toggle review visibility.
 * URL: /admin
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final AppointmentDAO apptDAO   = new AppointmentDAO();
    private final UserDAO        userDAO   = new UserDAO();
    private final ReviewDAO      reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (!SessionUtils.isAdmin(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("updateStatus".equals(action)) {
            int    id     = Integer.parseInt(req.getParameter("appointmentId"));
            String status = req.getParameter("status");
            apptDAO.updateStatus(id, status);
            res.sendRedirect(req.getContextPath() + "/admin/appointments.jsp?success=updated");

        } else if ("toggleCustomer".equals(action)) {
            int id     = Integer.parseInt(req.getParameter("userId"));
            int status = Integer.parseInt(req.getParameter("currentStatus"));
            userDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/customers.jsp");

        } else if ("toggleReview".equals(action)) {
            int id     = Integer.parseInt(req.getParameter("reviewId"));
            int status = Integer.parseInt(req.getParameter("currentStatus"));
            reviewDAO.toggleVisibility(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");

        } else {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        }
    }
}
