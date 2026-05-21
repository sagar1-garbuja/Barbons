package com.barbers.util;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility for MD5 password hashing.
 */
public class PasswordUtils {

    /**
     * Hashes a plaintext password using MD5.
     *
     * @param plain the plaintext password
     * @return lowercase hex MD5 string (32 chars)
     */
    public static String hashMD5(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(plain.getBytes());
            BigInteger bi = new BigInteger(1, digest);
            String hex = bi.toString(16);
            // Pad to 32 characters
            while (hex.length() < 32) hex = "0" + hex;
            return hex;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 algorithm not available", e);
        }
    }

    /**
     * Verifies a plaintext password against a stored MD5 hash.
     *
     * @param plain the plaintext password to check
     * @param hash  the stored MD5 hash
     * @return {@code true} if the hashes match
     */
    public static boolean verify(String plain, String hash) {
        return hashMD5(plain).equalsIgnoreCase(hash);
    }
}
