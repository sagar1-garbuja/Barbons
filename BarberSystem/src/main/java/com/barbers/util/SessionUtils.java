package com.barbers.util;

import javax.servlet.http.HttpSession;

import com.barbers.model.User;

/**
 * SessionUtils — a central place for all session-related operations.
 *
 * After a successful login, user details are stored in the session so every
 * page can quickly check who is logged in and what their role is, without
 * hitting the database on every request.
 *
 * Session attributes stored:
 *   "userId"   → int    (the user's primary key)
 *   "fullName" → String (shown in the navbar)
 *   "email"    → String
 *   "role"     → String ("customer" or "admin")
 */
public class SessionUtils {

    // Constant keys used to store/read session attributes
    // Using constants avoids typos when the same string is used in many places
    private static final String KEY_USER_ID   = "userId";
    private static final String KEY_FULL_NAME = "fullName";
    private static final String KEY_EMAIL     = "email";
    private static final String KEY_ROLE      = "role";

    /**
     * Saves the logged-in user's details into the session.
     * Called once after a successful login check in AuthServlet.
     *
     * @param session the current HTTP session
     * @param u       the authenticated user from the database
     */
    public static void createSession(HttpSession session, User u) {
        session.setAttribute(KEY_USER_ID,   u.getUserId());
        session.setAttribute(KEY_FULL_NAME, u.getFullName());
        session.setAttribute(KEY_EMAIL,     u.getEmail());
        session.setAttribute(KEY_ROLE,      u.getRole());
    }

    /**
     * Returns true if someone is currently logged in (session has a userId).
     *
     * @param session the current HTTP session (may be null)
     */
    public static boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute(KEY_USER_ID) != null;
    }

    /**
     * Returns true if the logged-in user is an admin.
     * Used at the top of every admin servlet/page to block non-admins.
     *
     * @param session the current HTTP session
     */
    public static boolean isAdmin(HttpSession session) {
        return isLoggedIn(session) && "admin".equals(session.getAttribute(KEY_ROLE));
    }

    /**
     * Returns true if the logged-in user is a customer.
     * Used to protect customer-only actions like booking and reviewing.
     *
     * @param session the current HTTP session
     */
    public static boolean isCustomer(HttpSession session) {
        return isLoggedIn(session) && "customer".equals(session.getAttribute(KEY_ROLE));
    }

    /**
     * Builds a lightweight User object from the session attributes.
     * Useful when you need a User object but don't want to query the database.
     *
     * @param session the current HTTP session
     * @return a User with id, fullName, email, role set; or null if not logged in
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
     * Destroys the session, effectively logging the user out.
     * After this, isLoggedIn() will return false.
     *
     * @param session the current HTTP session (safe to call with null)
     */
    public static void destroySession(HttpSession session) {
        if (session != null) session.invalidate();
    }
}
