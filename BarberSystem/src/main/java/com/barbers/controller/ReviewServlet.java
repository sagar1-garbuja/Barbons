package com.barbers.controller;

import com.barbers.dao.AppointmentDAO;
import com.barbers.dao.ReviewDAO;
import com.barbers.model.Appointment;
import com.barbers.model.Review;
import com.barbers.util.SessionUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Handles review submission by customers.
 * URL: /review
 */
@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO      reviewDAO = new ReviewDAO();
    private final AppointmentDAO apptDAO   = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (!SessionUtils.isCustomer(session)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (!"submit".equals(action)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp");
            return;
        }

        int    userId        = (Integer) session.getAttribute("userId");
        String apptIdStr     = req.getParameter("appointmentId");
        String ratingStr     = req.getParameter("rating");
        String comment       = trim(req.getParameter("comment"));

        if (apptIdStr == null || ratingStr == null || apptIdStr.isEmpty() || ratingStr.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=missing");
            return;
        }

        int appointmentId = Integer.parseInt(apptIdStr);
        int rating        = Integer.parseInt(ratingStr);

        // Verify appointment belongs to this user and is completed
        List<Appointment> completed = apptDAO.getCompletedByUser(userId);
        boolean eligible = completed.stream()
                .anyMatch(a -> a.getAppointmentId() == appointmentId);

        if (!eligible) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=noteligible");
            return;
        }

        // Verify no review exists yet
        if (apptDAO.hasReview(appointmentId)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=alreadyreviewed");
            return;
        }

        Review r = new Review();
        r.setAppointmentId(appointmentId);
        r.setUserId(userId);
        r.setRating(rating);
        r.setComment(comment);

        if (reviewDAO.insertReview(r)) {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?success=reviewed");
        } else {
            res.sendRedirect(req.getContextPath() + "/customer/my-appointments.jsp?error=failed");
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
