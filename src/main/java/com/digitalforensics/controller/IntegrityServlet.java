package com.digitalforensics.controller;

import com.digitalforensics.util.AuditLogUtil;
import com.digitalforensics.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/integrity")
public class IntegrityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        List<IntegrityRecord> records = new ArrayList<>();

        HttpSession session = req.getSession(false);

        Long currentUserId = getCurrentUserId(session);

        try (Connection con = DBConnection.getConnection()) {

            String selectSql = """
                    SELECT id,
                           evidence_code,
                           file_name,
                           file_path,
                           registered_sha256,
                           current_sha256,
                           integrity_status,
                           registered_at
                    FROM evidence_files
                    ORDER BY id DESC
                    """;

            try (PreparedStatement ps = con.prepareStatement(selectSql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    long id = rs.getLong("id");

                    String evidenceCode =
                            rs.getString("evidence_code");

                    String fileName =
                            rs.getString("file_name");

                    String filePath =
                            rs.getString("file_path");

                    String registeredSha256 =
                            rs.getString("registered_sha256");

                    String previousCurrentSha256 =
                            rs.getString("current_sha256");

                    String previousStatus =
                            rs.getString("integrity_status");

                    String currentSha256 =
                            registeredSha256;

                    String integrityStatus =
                            "NOT_CHECKED";

                    boolean integrityChecked = false;

                    try {

                        Path path = Path.of(filePath);

                        if (Files.exists(path)
                                && Files.isRegularFile(path)) {

                            currentSha256 =
                                    calculateSha256(path);

                            if (registeredSha256 != null
                                    && registeredSha256.equalsIgnoreCase(
                                            currentSha256)) {

                                integrityStatus =
                                        "VERIFIED";

                            } else {

                                integrityStatus =
                                        "HASH_MISMATCH";
                            }

                            updateIntegrity(
                                    con,
                                    id,
                                    currentSha256,
                                    integrityStatus
                            );

                            integrityChecked = true;

                        } else {

                            integrityStatus =
                                    "HASH_MISMATCH";

                            updateIntegrity(
                                    con,
                                    id,
                                    currentSha256,
                                    integrityStatus
                            );

                            integrityChecked = true;
                        }

                    } catch (Exception fileException) {

                        integrityStatus =
                                "HASH_MISMATCH";

                        System.err.println(
                                "Integrity check failed for "
                                + evidenceCode
                                + ": "
                                + fileException.getMessage()
                        );
                    }


                    /*
                     * =========================================
                     * AUDIT LOG
                     * =========================================
                     *
                     * Only create a new audit entry when the
                     * integrity result is newly established or
                     * has changed since the previous stored state.
                     */

                    boolean statusChanged =
                            previousStatus == null
                            || !previousStatus.equalsIgnoreCase(
                                    integrityStatus);

                    boolean hashChanged =
                            previousCurrentSha256 == null
                            || !previousCurrentSha256.equalsIgnoreCase(
                                    currentSha256 != null
                                            ? currentSha256
                                            : "");

                    if (integrityChecked
                            && (statusChanged || hashChanged)) {

                        String auditDetails =
                                "Evidence "
                                + evidenceCode
                                + " integrity verification completed. "
                                + "Status: "
                                + integrityStatus
                                + ". Registered SHA-256: "
                                + safeHash(registeredSha256)
                                + ". Current SHA-256: "
                                + safeHash(currentSha256)
                                + ".";

                        AuditLogUtil.log(
                                currentUserId,
                                findCaseId(con, id),
                                "INTEGRITY_CHECKED",
                                auditDetails
                        );
                    }


                    records.add(
                            new IntegrityRecord(
                                    id,
                                    evidenceCode,
                                    fileName,
                                    filePath,
                                    registeredSha256,
                                    currentSha256,
                                    integrityStatus,
                                    rs.getTimestamp(
                                            "registered_at"
                                    )
                            )
                    );
                }
            }

            req.setAttribute(
                    "records",
                    records
            );

            req.getRequestDispatcher(
                    "/jsp/integrity.jsp"
            ).forward(req, resp);

        } catch (Exception e) {

            throw new ServletException(
                    "Unable to load integrity page.",
                    e
            );
        }
    }


    /**
     * Updates the latest integrity result in evidence_files.
     */
    private void updateIntegrity(
            Connection con,
            long evidenceId,
            String currentSha256,
            String status)
            throws SQLException {

        String sql = """
                UPDATE evidence_files
                SET current_sha256 = ?,
                    integrity_status = ?
                WHERE id = ?
                """;

        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setString(
                    1,
                    currentSha256
            );

            ps.setString(
                    2,
                    status
            );

            ps.setLong(
                    3,
                    evidenceId
            );

            ps.executeUpdate();
        }
    }


    /**
     * Gets the case ID associated with an evidence item.
     */
    private Long findCaseId(
            Connection con,
            long evidenceId)
            throws SQLException {

        String sql = """
                SELECT case_id
                FROM evidence_files
                WHERE id = ?
                """;

        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setLong(
                    1,
                    evidenceId
            );

            try (ResultSet rs =
                         ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getLong("case_id");
                }
            }
        }

        return null;
    }


    /**
     * Gets the logged-in user's database ID.
     */
    private Long getCurrentUserId(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object currentUser =
                session.getAttribute("currentUser");

        if (currentUser == null) {
            return null;
        }

        try {

            /*
             * First try getId()
             */
            try {

                Object result =
                        currentUser
                                .getClass()
                                .getMethod("getId")
                                .invoke(currentUser);

                if (result instanceof Number) {

                    return ((Number) result)
                            .longValue();
                }

            } catch (NoSuchMethodException ignored) {
            }


            /*
             * Then try getUserId()
             */
            try {

                Object result =
                        currentUser
                                .getClass()
                                .getMethod("getUserId")
                                .invoke(currentUser);

                if (result instanceof Number) {

                    return ((Number) result)
                            .longValue();
                }

            } catch (NoSuchMethodException ignored) {
            }

        } catch (Exception e) {

            System.err.println(
                    "Unable to determine current user ID "
                    + "for integrity audit log: "
                    + e.getMessage()
            );
        }

        return null;
    }


    /**
     * Calculates SHA-256 for the evidence file.
     */
    private String calculateSha256(
            Path path)
            throws Exception {

        MessageDigest digest =
                MessageDigest.getInstance(
                        "SHA-256"
                );

        try (var inputStream =
                     Files.newInputStream(path)) {

            byte[] buffer =
                    new byte[8192];

            int bytesRead;

            while ((bytesRead =
                    inputStream.read(buffer)) != -1) {

                digest.update(
                        buffer,
                        0,
                        bytesRead
                );
            }
        }

        byte[] hashBytes =
                digest.digest();

        StringBuilder hex =
                new StringBuilder();

        for (byte b : hashBytes) {

            hex.append(
                    String.format(
                            "%02x",
                            b
                    )
            );
        }

        return hex.toString();
    }


    /**
     * Prevents null hash values from appearing
     * as the string "null" in the audit log.
     */
    private String safeHash(
            String hash) {

        if (hash == null
                || hash.isBlank()) {

            return "NOT AVAILABLE";
        }

        return hash;
    }


    public static class IntegrityRecord {

        private final long id;
        private final String evidenceCode;
        private final String fileName;
        private final String filePath;
        private final String registeredSha256;
        private final String currentSha256;
        private final String integrityStatus;
        private final Timestamp registeredAt;

        public IntegrityRecord(
                long id,
                String evidenceCode,
                String fileName,
                String filePath,
                String registeredSha256,
                String currentSha256,
                String integrityStatus,
                Timestamp registeredAt) {

            this.id = id;
            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.filePath = filePath;
            this.registeredSha256 = registeredSha256;
            this.currentSha256 = currentSha256;
            this.integrityStatus = integrityStatus;
            this.registeredAt = registeredAt;
        }

        public long getId() {
            return id;
        }

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getFileName() {
            return fileName;
        }

        public String getFilePath() {
            return filePath;
        }

        public String getRegisteredSha256() {
            return registeredSha256;
        }

        public String getCurrentSha256() {
            return currentSha256;
        }

        public String getIntegrityStatus() {
            return integrityStatus;
        }

        public Timestamp getRegisteredAt() {
            return registeredAt;
        }
    }
}