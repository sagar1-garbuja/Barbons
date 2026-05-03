package com.barbers.controller;

import com.barbers.dao.BarberDAO;
import com.barbers.model.Barber;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles CRUD operations for barbers (admin only).
 * URL: /barber
 */
@WebServlet("/barber")
public class BarberServlet extends HttpServlet {

    private final BarberDAO barberDAO = new BarberDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!SessionUtils.isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setAttribute("barbers", barberDAO.getAllBarbers());
        req.getRequestDispatcher("/admin/barbers.jsp").forward(req, res);
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
            String name       = trim(req.getParameter("name"));
            String speciality = trim(req.getParameter("speciality"));
            String bio        = trim(req.getParameter("bio"));
            if (name.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?error=missing");
                return;
            }
            Barber b = new Barber(name, speciality, bio, 1);
            barberDAO.insertBarber(b);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?success=added");

        } else if ("update".equals(action)) {
            int    id         = Integer.parseInt(req.getParameter("barberId"));
            String name       = trim(req.getParameter("name"));
            String speciality = trim(req.getParameter("speciality"));
            String bio        = trim(req.getParameter("bio"));
            Barber b = new Barber(name, speciality, bio, 1);
            b.setBarberId(id);
            barberDAO.updateBarber(b);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp?success=updated");

        } else if ("toggle".equals(action)) {
            int id     = Integer.parseInt(req.getParameter("barberId"));
            int status = Integer.parseInt(req.getParameter("currentStatus"));
            barberDAO.toggleActive(id, status == 1 ? 0 : 1);
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp");
        } else {
            res.sendRedirect(req.getContextPath() + "/admin/barbers.jsp");
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
