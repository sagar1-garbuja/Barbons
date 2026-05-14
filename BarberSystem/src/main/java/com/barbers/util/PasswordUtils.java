package com.barbers.util;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * PasswordUtils — handles password hashing and verification using MD5.
 *
 * Passwords are never stored as plain text.
 * When a user registers, their password is hashed with hashMD5() before saving.
 * When a user logs in, verify() hashes what they typed and compares it to the stored hash.
 */
public class PasswordUtils {

    /**
     * Converts a plain-text password into a 32-character MD5 hex string.
     *
     * Example: "myPassword1" → "5f4dcc3b5aa765d61d8327deb882cf99"
     *
     * @param plain the password the user typed
     * @return lowercase 32-character hex string
     */
    public static String hashMD5(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(plain.getBytes()); // hash the bytes
            BigInteger bi = new BigInteger(1, digest);   // convert bytes to a big number
            String hex = bi.toString(16);                // convert to hex string

            // MD5 is always 32 hex characters — pad with leading zeros if shorter
            while (hex.length() < 32) hex = "0" + hex;
            return hex;

        } catch (NoSuchAlgorithmException e) {
            // MD5 is built into Java — this should never happen
            throw new RuntimeException("MD5 algorithm not available", e);
        }
    }

    /**
     * Checks whether a plain-text password matches a stored MD5 hash.
     *
     * @param plain the password the user typed at login
     * @param hash  the MD5 hash stored in the database
     * @return true if they match, false otherwise
     */
    public static boolean verify(String plain, String hash) {
        // Hash what the user typed and compare it to the stored hash (case-insensitive)
        return hashMD5(plain).equalsIgnoreCase(hash);
    }
}
