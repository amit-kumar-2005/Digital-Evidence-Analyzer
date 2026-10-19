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

@WebServlet("/findings")
public class FindingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        List<FindingRecord> findings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    ef.id,
                    ef.evidence_code,
                    ef.file_name,
                    ef.file_type,
                    ef.file_size,
                    ef.registered_sha256,
                    ef.current_sha256,
                    ef.integrity_status,
                    c.case_code,
                    c.case_name
                FROM evidence_files ef
                INNER JOIN cases c
                    ON c.id = ef.case_id
                ORDER BY ef.id DESC
                """;

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                int findingNumber = 1;

                while (rs.next()) {

                    String evidenceCode =
                            rs.getString("evidence_code");

                    String fileName =
                            rs.getString("file_name");

                    String fileType =
                            rs.getString("file_type");

                    long fileSize =
                            rs.getLong("file_size");

                    String registeredHash =
                            rs.getString("registered_sha256");

                    String currentHash =
                            rs.getString("current_sha256");

                    String integrityStatus =
                            rs.getString("integrity_status");

                    String caseCode =
                            rs.getString("case_code");

                    String caseName =
                            rs.getString("case_name");

                    /*
                     * Finding 1:
                     * Integrity observation
                     */
                    if ("VERIFIED".equalsIgnoreCase(integrityStatus)) {

                        findings.add(new FindingRecord(
                                String.format("FND-%04d", findingNumber++),
                                evidenceCode,
                                fileName,
                                caseCode,
                                caseName,
                                "Integrity Verification",
                                "Registered SHA-256 matches the current SHA-256 value.",
                                "VERIFIED",
                                "UNDER REVIEW"
                        ));

                    } else if ("HASH_MISMATCH"
                            .equalsIgnoreCase(integrityStatus)) {

                        findings.add(new FindingRecord(
                                String.format("FND-%04d", findingNumber++),
                                evidenceCode,
                                fileName,
                                caseCode,
                                caseName,
                                "Integrity Mismatch",
                                "Current SHA-256 does not match the registered SHA-256 value.",
                                "HASH MISMATCH",
                                "UNDER REVIEW"
                        ));

                    } else {

                        findings.add(new FindingRecord(
                                String.format("FND-%04d", findingNumber++),
                                evidenceCode,
                                fileName,
                                caseCode,
                                caseName,
                                "Integrity Status",
                                "Integrity verification has not produced a final verification status.",
                                "NOT CHECKED",
                                "UNDER REVIEW"
                        ));
                    }

                    /*
                     * Finding 2:
                     * File metadata observation
                     */
                    String metadataDescription =
                            "Registered file type: "
                            + (fileType != null ? fileType : "Unknown")
                            + ", size: "
                            + fileSize
                            + " bytes.";

                    findings.add(new FindingRecord(
                            String.format("FND-%04d", findingNumber++),
                            evidenceCode,
                            fileName,
                            caseCode,
                            caseName,
                            "File Metadata Observation",
                            metadataDescription,
                            "OBSERVED",
                            "UNDER REVIEW"
                    ));

                    /*
                     * Finding 3:
                     * Hash availability
                     */
                    if (registeredHash != null
                            && !registeredHash.isBlank()
                            && currentHash != null
                            && !currentHash.isBlank()) {

                        findings.add(new FindingRecord(
                                String.format("FND-%04d", findingNumber++),
                                evidenceCode,
                                fileName,
                                caseCode,
                                caseName,
                                "Cryptographic Hash Record",
                                "Registered and current SHA-256 values are available for technical comparison.",
                                "OBSERVED",
                                "UNDER REVIEW"
                        ));
                    }
                }
            }

            request.setAttribute("findings", findings);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("findings",
                    new ArrayList<FindingRecord>());

            request.setAttribute("dbConnected", false);

            request.setAttribute(
                    "errorMessage",
                    "Unable to load investigation findings."
            );
        }

        request.getRequestDispatcher("/jsp/findings.jsp")
                .forward(request, response);
    }


    public static class FindingRecord {

        private final String findingId;
        private final String evidenceCode;
        private final String fileName;
        private final String caseCode;
        private final String caseName;
        private final String findingType;
        private final String observation;
        private final String technicalStatus;
        private final String reviewStatus;

        public FindingRecord(
                String findingId,
                String evidenceCode,
                String fileName,
                String caseCode,
                String caseName,
                String findingType,
                String observation,
                String technicalStatus,
                String reviewStatus) {

            this.findingId = findingId;
            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.caseCode = caseCode;
            this.caseName = caseName;
            this.findingType = findingType;
            this.observation = observation;
            this.technicalStatus = technicalStatus;
            this.reviewStatus = reviewStatus;
        }

        public String getFindingId() {
            return findingId;
        }

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getFileName() {
            return fileName;
        }

        public String getCaseCode() {
            return caseCode;
        }

        public String getCaseName() {
            return caseName;
        }

        public String getFindingType() {
            return findingType;
        }

        public String getObservation() {
            return observation;
        }

        public String getTechnicalStatus() {
            return technicalStatus;
        }

        public String getReviewStatus() {
            return reviewStatus;
        }
    }
}