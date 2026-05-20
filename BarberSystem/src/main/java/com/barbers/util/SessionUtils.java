package com.barbers.util;

import com.barbers.model.User;

import jakarta.servlet.http.HttpSession;

/**
 * Utility for managing HttpSession lifecycle and user attributes.
 */
public class SessionUtils {

    private static final String KEY_USER_ID   = "userId";
    private static final String KEY_FULL_NAME = "fullName";
    private static final String KEY_EMAIL     = "email";
    private static final String KEY_ROLE      = "role";

    /**
     * Stores user identity attributes in the session after successful login.
     *
     * @param session the current HttpSession
     * @param u       the authenticated User
     */
    public static void createSession(HttpSession session, User u) {
        session.setAttribute(KEY_USER_ID,   u.getUserId());
        session.setAttribute(KEY_FULL_NAME, u.getFullName());
        session.setAttribute(KEY_EMAIL,     u.getEmail());
        session.setAttribute(KEY_ROLE,      u.getRole());
    }

    /**
     * Returns {@code true} if a user is currently logged in.
     *
     * @param session the current HttpSession
     */
    public static boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute(KEY_USER_ID) != null;
    }

    /**
     * Returns {@code true} if the logged-in user has the admin role.
     *
     * @param session the current HttpSession
     */
    public static boolean isAdmin(HttpSession session) {
        return isLoggedIn(session) && "admin".equals(session.getAttribute(KEY_ROLE));
    }

    /**
     * Returns {@code true} if the logged-in user has the customer role.
     *
     * @param session the current HttpSession
     */
    public static boolean isCustomer(HttpSession session) {
        return isLoggedIn(session) && "customer".equals(session.getAttribute(KEY_ROLE));
    }

    /**
     * Reconstructs a lightweight User object from session attributes.
     *
     * @param session the current HttpSession
     * @return a User with id, fullName, email, role set; or {@code null} if not logged in
     */
    public static User getSessionUser(HttpSession session) {
        if (!isLoggedIn(session)) return null;
        User u = new User();
        u.setUserId((Integer) session.getAttribute(KEY_USER_ID));
        u.setFullName((String) session.getAttribute(KEY_FULL_NAME));
        u.setEmail((String) session.getAttribute(KEY_EMAIL));
        u.setRole((String) session.getAttribute(KEY_ROLE));
        return u;
    }

    /**
     * Invalidates the session, logging the user out.
     *
     * @param session the current HttpSession
     */
    public static void destroySession(HttpSession session) {
        if (session != null) session.invalidate();
    }
}
