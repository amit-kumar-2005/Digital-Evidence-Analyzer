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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/duplicates")
public class DuplicateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<DuplicateGroup> groups = new ArrayList<>();

        String groupSql = """
                SELECT
                    current_sha256,
                    COUNT(*) AS duplicate_count,
                    MIN(file_size) AS file_size
                FROM evidence_files
                WHERE current_sha256 IS NOT NULL
                  AND current_sha256 <> ''
                GROUP BY current_sha256
                HAVING COUNT(*) > 1
                ORDER BY duplicate_count DESC
                """;

        String evidenceSql = """
                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    ef.file_path,
                    ef.file_size,
                    c.case_code,
                    c.case_name,
                    ef.integrity_status
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                WHERE ef.current_sha256 = ?
                ORDER BY ef.registered_at ASC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement groupPs = con.prepareStatement(groupSql);
             ResultSet groupRs = groupPs.executeQuery()) {

            while (groupRs.next()) {

                String sha256 = groupRs.getString("current_sha256");

                DuplicateGroup group = new DuplicateGroup();

                group.sha256 = sha256;
                group.duplicateCount = groupRs.getInt("duplicate_count");

                try (PreparedStatement evidencePs =
                             con.prepareStatement(evidenceSql)) {

                    evidencePs.setString(1, sha256);

                    try (ResultSet evidenceRs =
                                 evidencePs.executeQuery()) {

                        while (evidenceRs.next()) {

                            EvidenceItem item = new EvidenceItem();

                            item.evidenceCode =
                                    evidenceRs.getString("evidence_code");

                            item.fileName =
                                    evidenceRs.getString("file_name");

                            item.filePath =
                                    evidenceRs.getString("file_path");

                            item.fileSize =
                                    evidenceRs.getLong("file_size");

                            item.caseCode =
                                    evidenceRs.getString("case_code");

                            item.caseName =
                                    evidenceRs.getString("case_name");

                            item.integrityStatus =
                                    evidenceRs.getString("integrity_status");

                            group.evidenceItems.add(item);
                        }
                    }
                }

                groups.add(group);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to load duplicate evidence data.", e);
        }

        req.setAttribute("duplicateGroups", groups);

        req.getRequestDispatcher("/jsp/duplicates.jsp")
                .forward(req, resp);
    }


    public static class DuplicateGroup {

        private String sha256;
        private int duplicateCount;
        private final List<EvidenceItem> evidenceItems =
                new ArrayList<>();

        public String getSha256() {
            return sha256;
        }

        public int getDuplicateCount() {
            return duplicateCount;
        }

        public List<EvidenceItem> getEvidenceItems() {
            return evidenceItems;
        }

        public String getShortHash() {

            if (sha256 == null || sha256.isBlank()) {
                return "—";
            }

            if (sha256.length() <= 32) {
                return sha256;
            }

            return sha256.substring(0, 32) + "...";
        }
    }


    public static class EvidenceItem {

        private String evidenceCode;
        private String fileName;
        private String filePath;
        private long fileSize;
        private String caseCode;
        private String caseName;
        private String integrityStatus;

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getFileName() {
            return fileName;
        }

        public String getFilePath() {
            return filePath;
        }

        public long getFileSize() {
            return fileSize;
        }

        public String getCaseCode() {
            return caseCode;
        }

        public String getCaseName() {
            return caseName;
        }

        public String getIntegrityStatus() {
            return integrityStatus;
        }

        public String getFormattedSize() {

            if (fileSize < 1024) {
                return fileSize + " B";
            }

            if (fileSize < 1024L * 1024L) {
                return String.format(
                        "%.2f KB",
                        fileSize / 1024.0
                );
            }

            if (fileSize < 1024L * 1024L * 1024L) {
                return String.format(
                        "%.2f MB",
                        fileSize / (1024.0 * 1024.0)
                );
            }

            return String.format(
                    "%.2f GB",
                    fileSize / (1024.0 * 1024.0 * 1024.0)
            );
        }
    }
}