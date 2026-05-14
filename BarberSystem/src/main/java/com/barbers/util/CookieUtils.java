package com.barbers.util;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CookieUtils — manages the "Remember Me" cookie.
 *
 * When a user ticks "Remember Me" at login, their email is saved in a cookie
 * that lasts 7 days. The next time they visit the login page, the email field
 * is pre-filled using this cookie.
 */
public class CookieUtils {

    private static final String COOKIE_NAME = "barbers_remember";
    private static final int    MAX_AGE     = 7 * 24 * 60 * 60; // 7 days expressed in seconds

    /**
     * Saves the user's email in a persistent cookie for 7 days.
     *
     * @param response the HTTP response to attach the cookie to
     * @param email    the email address to remember
     */
    public static void setRememberMe(HttpServletResponse response, String email) {
        Cookie cookie = new Cookie(COOKIE_NAME, email);
        cookie.setMaxAge(MAX_AGE);   // cookie survives browser restarts for 7 days
        cookie.setPath("/");         // cookie is sent for all pages on this server
        cookie.setHttpOnly(true);    // JavaScript cannot read this cookie (security)
        response.addCookie(cookie);
    }

    /**
     * Reads the remembered email from the incoming request's cookies.
     *
     * @param request the HTTP request that may contain the cookie
     * @return the stored email, or null if the cookie doesn't exist
     */
    public static String getRememberMe(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null; // no cookies at all

        // Search through all cookies for ours
        for (Cookie c : cookies) {
            if (COOKIE_NAME.equals(c.getName())) return c.getValue();
        }
        return null; // cookie not found
    }

    /**
     * Deletes the remember-me cookie by setting its expiry to 0 (immediate expiry).
     * Called on logout or when the user unchecks "Remember Me".
     *
     * @param response the HTTP response to attach the expired cookie to
     */
    public static void clearRememberMe(HttpServletResponse response) {
        Cookie cookie = new Cookie(COOKIE_NAME, "");
        cookie.setMaxAge(0);  // 0 tells the browser to delete the cookie immediately
        cookie.setPath("/");
        response.addCookie(cookie);
    }
}
