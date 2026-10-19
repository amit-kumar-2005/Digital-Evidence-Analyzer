
package com.digitalforensics.controller;

import com.digitalforensics.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet("/indicators")
public class IndicatorServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<IndicatorRecord> indicators = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            List<EvidenceSnapshot> evidenceList = new ArrayList<>();

            // Step 1: Read registered evidence from the database.
            String evidenceSql = """
                SELECT id, evidence_code, file_name, file_type,
                       file_size, created_time, modified_time,
                       registered_sha256, current_sha256,
                       integrity_status
                FROM evidence_files
                ORDER BY id DESC
                """;

            try (PreparedStatement ps =
                         conn.prepareStatement(evidenceSql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    evidenceList.add(new EvidenceSnapshot(
                            rs.getLong("id"),
                            rs.getString("evidence_code"),
                            rs.getString("file_name"),
                            rs.getString("file_type"),
                            rs.getLong("file_size"),
                            rs.getTimestamp("created_time"),
                            rs.getTimestamp("modified_time"),
                            rs.getString("registered_sha256"),
                            rs.getString("current_sha256"),
                            rs.getString("integrity_status")
                    ));
                }
            }

            // Step 2: Recalculate and synchronize indicators.
            // Existing indicators for each evidence item are replaced
            // inside one transaction to prevent duplicate records.
            conn.setAutoCommit(false);

            try {
                String deleteSql = """
                    DELETE FROM suspicious_indicators
                    WHERE evidence_id = ?
                    """;

                String insertSql = """
                    INSERT INTO suspicious_indicators
                        (evidence_id, indicator_type, severity, description)
                    VALUES (?, ?, ?, ?)
                    """;

                try (PreparedStatement deletePs =
                             conn.prepareStatement(deleteSql);
                     PreparedStatement insertPs =
                             conn.prepareStatement(insertSql)) {

                    for (EvidenceSnapshot evidence : evidenceList) {

                        List<Detection> detections =
                                detectIndicators(evidence);

                        deletePs.setLong(1, evidence.id);
                        deletePs.executeUpdate();

                        for (Detection detection : detections) {
                            insertPs.setLong(1, evidence.id);
                            insertPs.setString(2, detection.type);
                            insertPs.setString(3, detection.severity);
                            insertPs.setString(4, detection.description);
                            insertPs.addBatch();
                        }

                        insertPs.executeBatch();
                    }
                }

                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

            // Step 3: Display the saved database records.
            String displaySql = """
                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    si.indicator_type,
                    si.severity,
                    si.description
                FROM suspicious_indicators si
                INNER JOIN evidence_files ef
                    ON ef.id = si.evidence_id
                ORDER BY si.id DESC
                """;

            try (PreparedStatement ps =
                         conn.prepareStatement(displaySql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    indicators.add(new IndicatorRecord(
                            rs.getString("evidence_code"),
                            rs.getString("file_name"),
                            rs.getString("indicator_type"),
                            rs.getString("severity"),
                            rs.getString("description")
                    ));
                }
            }

            request.setAttribute("indicators", indicators);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("indicators",
                    new ArrayList<IndicatorRecord>());
            request.setAttribute("dbConnected", false);
            request.setAttribute("errorMessage",
                    "Unable to load or save evidence indicators.");
        }

        request.getRequestDispatcher("/jsp/indicators.jsp")
                .forward(request, response);
    }

    private List<Detection> detectIndicators(EvidenceSnapshot e) {

        List<Detection> results = new ArrayList<>();

        String name = e.fileName == null ? "" : e.fileName;
        String lowerName = name.toLowerCase(Locale.ROOT);
        String lowerType = e.fileType == null
                ? "" : e.fileType.toLowerCase(Locale.ROOT);

        // 1. Hash mismatch
        if ("HASH_MISMATCH".equalsIgnoreCase(e.integrityStatus)) {
            add(results, "HASH MISMATCH", "HIGH",
                    "Current SHA-256 does not match the registered SHA-256.");
        }

        // 2. Double extension
        if (name.matches(".*\\.[^.]+\\.[^.]+$")) {
            add(results, "DOUBLE EXTENSION", "MEDIUM",
                    "File name contains multiple extensions.");
        }

        // 3. Executable or script file
        boolean executable =
                lowerName.endsWith(".exe") ||
                lowerName.endsWith(".dll") ||
                lowerName.endsWith(".bat") ||
                lowerName.endsWith(".cmd") ||
                lowerName.endsWith(".ps1") ||
                lowerName.endsWith(".jar") ||
                lowerType.contains("executable");

        if (executable) {
            add(results, "EXECUTABLE FILE", "MEDIUM",
                    "The evidence item is an executable or script-type file.");
        }

        // 4. Unusual filename
        if (name.contains("..") ||
                name.contains("  ") ||
                name.startsWith(".") ||
                name.length() > 150) {
            add(results, "UNUSUAL FILENAME", "LOW",
                    "The filename contains an unusual naming pattern.");
        }

        // 5. Hidden filename
        if (name.startsWith(".")) {
            add(results, "HIDDEN FILE", "MEDIUM",
                    "The filename starts with a dot and may represent a hidden file.");
        }

        // 6. Timestamp anomaly
        Timestamp created = e.createdTime;
        Timestamp modified = e.modifiedTime;

        if (created != null && modified != null &&
                created.after(modified)) {
            add(results, "TIMESTAMP ANOMALY", "LOW",
                    "Created time is later than modified time.");
        }

        // 7. Current hash unavailable
        if (e.currentHash == null || e.currentHash.isBlank()) {
            add(results, "HASH NOT AVAILABLE", "LOW",
                    "Current SHA-256 hash is not available.");
        }

        return results;
    }

    private void add(List<Detection> list,
                     String type,
                     String severity,
                     String description) {

        list.add(new Detection(type, severity, description));
    }

    private static class EvidenceSnapshot {
        private final long id;
        private final String evidenceCode;
        private final String fileName;
        private final String fileType;
        private final long fileSize;
        private final Timestamp createdTime;
        private final Timestamp modifiedTime;
        private final String registeredHash;
        private final String currentHash;
        private final String integrityStatus;

        private EvidenceSnapshot(
                long id,
                String evidenceCode,
                String fileName,
                String fileType,
                long fileSize,
                Timestamp createdTime,
                Timestamp modifiedTime,
                String registeredHash,
                String currentHash,
                String integrityStatus) {

            this.id = id;
            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.fileType = fileType;
            this.fileSize = fileSize;
            this.createdTime = createdTime;
            this.modifiedTime = modifiedTime;
            this.registeredHash = registeredHash;
            this.currentHash = currentHash;
            this.integrityStatus = integrityStatus;
        }
    }

    private static class Detection {
        private final String type;
        private final String severity;
        private final String description;

        private Detection(String type,
                          String severity,
                          String description) {
            this.type = type;
            this.severity = severity;
            this.description = description;
        }
    }

    public static class IndicatorRecord {
        private final String evidenceCode;
        private final String fileName;
        private final String indicatorType;
        private final String severity;
        private final String description;

        public IndicatorRecord(
                String evidenceCode,
                String fileName,
                String indicatorType,
                String severity,
                String description) {

            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.indicatorType = indicatorType;
            this.severity = severity;
            this.description = description;
        }

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getFileName() {
            return fileName;
        }

        public String getIndicatorType() {
            return indicatorType;
        }

        public String getSeverity() {
            return severity;
        }

        public String getDescription() {
            return description;
        }
    }
}
