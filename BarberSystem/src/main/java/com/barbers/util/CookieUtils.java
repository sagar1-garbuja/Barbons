package com.barbers.util;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Utility for managing the "Remember Me" cookie.
 */
public class CookieUtils {

    private static final String COOKIE_NAME = "barbers_remember";
    private static final int    MAX_AGE     = 7 * 24 * 60 * 60; // 7 days in seconds

    /**
     * Sets a persistent cookie containing the user's email for 7 days.
     *
     * @param response the HttpServletResponse to add the cookie to
     * @param email    the email address to store
     */
    public static void setRememberMe(HttpServletResponse response, String email) {
        Cookie cookie = new Cookie(COOKIE_NAME, email);
        cookie.setMaxAge(MAX_AGE);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        response.addCookie(cookie);
    }

    /**
     * Reads the remembered email from the request cookies.
     *
     * @param request the HttpServletRequest to read cookies from
     * @return the stored email string, or {@code null} if the cookie is absent
     */
    public static String getRememberMe(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (COOKIE_NAME.equals(c.getName())) return c.getValue();
        }
        return null;
    }

    /**
     * Clears the remember-me cookie by setting its max age to 0.
     *
     * @param response the HttpServletResponse to add the expired cookie to
     */
    public static void clearRememberMe(HttpServletResponse response) {
        Cookie cookie = new Cookie(COOKIE_NAME, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
    }
}
