package com.barbers.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Serves uploaded files (profile pictures) from the persistent upload
 * directory outside the webapp folder.
 *
 * URL pattern: /uploads/profiles/{filename}
 *
 * The base directory is read from the web.xml context-param "upload.dir".
 * Default: C:/barbons_uploads
 */
@WebServlet("/uploads/profiles/*")
public class FileServlet extends HttpServlet {

    private static final Map<String, String> MIME_TYPES = new HashMap<>();
    static {
        MIME_TYPES.put("jpg",  "image/jpeg");
        MIME_TYPES.put("jpeg", "image/jpeg");
        MIME_TYPES.put("png",  "image/png");
        MIME_TYPES.put("gif",  "image/gif");
        MIME_TYPES.put("webp", "image/webp");
    }

    private String uploadDir;

    @Override
    public void init() throws ServletException {
        String baseDir = getServletContext().getInitParameter("upload.dir");
        if (baseDir == null || baseDir.trim().isEmpty()) {
            baseDir = "C:/barbons_uploads";
        }
        uploadDir = baseDir + "/profiles";
        // Create directory if it doesn't exist yet
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Extract filename from path: /uploads/profiles/{filename}
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Strip leading slash and prevent path traversal
        String filename = pathInfo.substring(1).replaceAll("[/\\\\]", "");
        if (filename.isEmpty() || filename.contains("..")) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        File file = new File(uploadDir, filename);
        if (!file.exists() || !file.isFile()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Set correct content type
        String ext = filename.contains(".")
                ? filename.substring(filename.lastIndexOf('.') + 1).toLowerCase()
                : "";
        String mimeType = MIME_TYPES.getOrDefault(ext, "application/octet-stream");
        res.setContentType(mimeType);
        res.setContentLengthLong(file.length());

        // Cache for 7 days
        res.setHeader("Cache-Control", "public, max-age=604800");

        // Stream the file
        try (InputStream in = new FileInputStream(file);
             OutputStream out = res.getOutputStream()) {
            byte[] buf = new byte[8192];
            int    len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
