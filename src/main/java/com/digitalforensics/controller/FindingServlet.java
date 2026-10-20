
package com.digitalforensics.controller;

import com.digitalforensics.model.User;
import com.digitalforensics.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@WebServlet("/findings")
public class FindingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Set<String> REVIEW_KEYS = Set.of(
            "INTEGRITY",
            "FILE_METADATA",
            "HASH_RECORD"
    );

    private static final Set<String> REVIEW_STATUSES = Set.of(
            "UNDER REVIEW",
            "VERIFIED",
            "REJECTED"
    );

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        List<FindingRecord> findings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    ef.id AS evidence_id,
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
                INNER JOIN cases c ON c.id = ef.case_id
                ORDER BY ef.id DESC
                """;

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                int findingNumber = 1;

                while (rs.next()) {

                    long evidenceId = rs.getLong("evidence_id");
                    String evidenceCode = rs.getString("evidence_code");
                    String fileName = rs.getString("file_name");
                    String fileType = rs.getString("file_type");
                    long fileSize = rs.getLong("file_size");
                    String registeredHash = rs.getString("registered_sha256");
                    String currentHash = rs.getString("current_sha256");
                    String integrityStatus = rs.getString("integrity_status");
                    String caseCode = rs.getString("case_code");
                    String caseName = rs.getString("case_name");

                    String integrityFindingType;
                    String integrityObservation;
                    String technicalStatus;

                    if ("VERIFIED".equalsIgnoreCase(integrityStatus)) {
                        integrityFindingType = "Integrity Verification";
                        integrityObservation =
                                "Registered SHA-256 matches the current SHA-256 value.";
                        technicalStatus = "VERIFIED";

                    } else if ("HASH_MISMATCH".equalsIgnoreCase(integrityStatus)) {
                        integrityFindingType = "Integrity Mismatch";
                        integrityObservation =
                                "Current SHA-256 does not match the registered SHA-256 value.";
                        technicalStatus = "HASH MISMATCH";

                    } else {
                        integrityFindingType = "Integrity Status";
                        integrityObservation =
                                "Integrity verification has not produced a final verification status.";
                        technicalStatus = "NOT CHECKED";
                    }

                    findings.add(createRecord(
                            conn,
                            findingNumber++,
                            evidenceId,
                            evidenceCode,
                            fileName,
                            caseCode,
                            caseName,
                            integrityFindingType,
                            integrityObservation,
                            technicalStatus,
                            "INTEGRITY"
                    ));

                    String metadataDescription =
                            "Registered file type: "
                            + (fileType != null ? fileType : "Unknown")
                            + ", size: " + fileSize + " bytes.";

                    findings.add(createRecord(
                            conn,
                            findingNumber++,
                            evidenceId,
                            evidenceCode,
                            fileName,
                            caseCode,
                            caseName,
                            "File Metadata Observation",
                            metadataDescription,
                            "OBSERVED",
                            "FILE_METADATA"
                    ));

                    if (registeredHash != null
                            && !registeredHash.isBlank()
                            && currentHash != null
                            && !currentHash.isBlank()) {

                        findings.add(createRecord(
                                conn,
                                findingNumber++,
                                evidenceId,
                                evidenceCode,
                                fileName,
                                caseCode,
                                caseName,
                                "Cryptographic Hash Record",
                                "Registered and current SHA-256 values are available for technical comparison.",
                                "OBSERVED",
                                "HASH_RECORD"
                        ));
                    }
                }
            }

            request.setAttribute("findings", findings);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {

            getServletContext().log("Unable to load findings.", e);

            request.setAttribute("findings", new ArrayList<FindingRecord>());
            request.setAttribute("dbConnected", false);
            request.setAttribute(
                    "errorMessage",
                    "Unable to load investigation findings."
            );
        }

        request.getRequestDispatcher("/jsp/findings.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        Object sessionUser = session == null
                ? null
                : session.getAttribute("currentUser");

        if (!(sessionUser instanceof User)) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Please log in to review findings."
            );
            return;
        }

        User user = (User) sessionUser;
        String role = user.getRole();

        if (!"ADMIN".equals(role) && !"INVESTIGATOR".equals(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to review findings."
            );
            return;
        }

        String evidenceIdValue = request.getParameter("evidenceId");
        String reviewKey = request.getParameter("reviewKey");
        String reviewStatus = request.getParameter("reviewStatus");
        String reviewComment = request.getParameter("reviewComment");

        long evidenceId;

        try {
            evidenceId = Long.parseLong(evidenceIdValue);
            if (evidenceId <= 0) {
                throw new NumberFormatException("Invalid evidence ID");
            }
        } catch (Exception e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid evidence ID."
            );
            return;
        }

        if (!REVIEW_KEYS.contains(reviewKey)
                || !REVIEW_STATUSES.contains(reviewStatus)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid review key or status."
            );
            return;
        }

        if (reviewComment != null) {
            reviewComment = reviewComment.trim();

            if (reviewComment.length() > 1000) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Review comment cannot exceed 1000 characters."
                );
                return;
            }
        }

        Long userId = user.getId();

        try (Connection conn = DBConnection.getConnection()) {

            conn.setAutoCommit(false);

            try {
                Long caseId = findCaseId(conn, evidenceId);

                if (caseId == null
                        || !isValidFinding(conn, evidenceId, reviewKey)) {
                    conn.rollback();
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "The requested finding does not exist."
                    );
                    return;
                }

                String previousStatus =
                        getPreviousReviewStatus(conn, evidenceId, reviewKey);

                String sql = """
                    INSERT INTO finding_reviews
                        (evidence_id, finding_type, review_status,
                         reviewed_by, review_comment)
                    VALUES (?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        review_status = VALUES(review_status),
                        reviewed_by = VALUES(reviewed_by),
                        review_comment = VALUES(review_comment),
                        updated_at = CURRENT_TIMESTAMP
                    """;

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, evidenceId);
                    ps.setString(2, reviewKey);
                    ps.setString(3, reviewStatus);
                    ps.setLong(4, userId);

                    if (reviewComment == null || reviewComment.isBlank()) {
                        ps.setNull(5, java.sql.Types.VARCHAR);
                    } else {
                        ps.setString(5, reviewComment);
                    }

                    ps.executeUpdate();
                }

                String auditSql = """
                    INSERT INTO audit_logs
                        (user_id, case_id, action, details)
                    VALUES (?, ?, ?, ?)
                    """;

                String details =
                        "Finding review updated. Evidence ID: "
                        + evidenceId
                        + ", review key: " + reviewKey
                        + ", previous status: "
                        + (previousStatus != null ? previousStatus : "NONE")
                        + ", new status: " + reviewStatus
                        + ", reviewer: " + user.getEmail()
                        + (reviewComment == null || reviewComment.isBlank()
                                ? ""
                                : ", comment: " + reviewComment);

                try (PreparedStatement ps = conn.prepareStatement(auditSql)) {
                    ps.setLong(1, userId);
                    ps.setLong(2, caseId);
                    ps.setString(3, "FINDING_REVIEW_UPDATED");
                    ps.setString(4, details);
                    ps.executeUpdate();
                }

                conn.commit();

            } catch (Exception e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    e.addSuppressed(rollbackException);
                }
                throw e;
            }

        } catch (Exception e) {
            getServletContext().log("Unable to save finding review.", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to save the review. No changes were committed."
            );
            return;
        }

        response.sendRedirect(
                request.getContextPath() + "/findings?review=saved"
        );
    }

    private FindingRecord createRecord(
            Connection conn,
            int findingNumber,
            long evidenceId,
            String evidenceCode,
            String fileName,
            String caseCode,
            String caseName,
            String findingType,
            String observation,
            String technicalStatus,
            String reviewKey) throws SQLException {

        ReviewData review = getReview(conn, evidenceId, reviewKey);

        return new FindingRecord(
                String.format("FND-%04d", findingNumber),
                evidenceId,
                reviewKey,
                evidenceCode,
                fileName,
                caseCode,
                caseName,
                findingType,
                observation,
                technicalStatus,
                review.status,
                review.comment
        );
    }

    private ReviewData getReview(
            Connection conn,
            long evidenceId,
            String reviewKey) throws SQLException {

        String sql = """
            SELECT review_status, review_comment
            FROM finding_reviews
            WHERE evidence_id = ? AND finding_type = ?
            """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, evidenceId);
            ps.setString(2, reviewKey);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ReviewData(
                            rs.getString("review_status"),
                            rs.getString("review_comment")
                    );
                }
            }
        }

        return new ReviewData("UNDER REVIEW", null);
    }

    private String getPreviousReviewStatus(
            Connection conn,
            long evidenceId,
            String reviewKey) throws SQLException {

        String sql = """
            SELECT review_status
            FROM finding_reviews
            WHERE evidence_id = ? AND finding_type = ?
            FOR UPDATE
            """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, evidenceId);
            ps.setString(2, reviewKey);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("review_status") : null;
            }
        }
    }

    private boolean isValidFinding(
            Connection conn,
            long evidenceId,
            String reviewKey) throws SQLException {

        String sql;

        if ("INTEGRITY".equals(reviewKey)) {
            sql = "SELECT id FROM evidence_files WHERE id = ?";
        } else if ("FILE_METADATA".equals(reviewKey)) {
            sql = "SELECT id FROM evidence_files WHERE id = ?";
        } else if ("HASH_RECORD".equals(reviewKey)) {
            sql = """
                SELECT id FROM evidence_files
                WHERE id = ?
                  AND registered_sha256 IS NOT NULL
                  AND registered_sha256 <> ''
                  AND current_sha256 IS NOT NULL
                  AND current_sha256 <> ''
                """;
        } else {
            return false;
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, evidenceId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Long findCaseId(
            Connection conn,
            long evidenceId) throws SQLException {

        String sql = "SELECT case_id FROM evidence_files WHERE id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, evidenceId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong("case_id") : null;
            }
        }
    }

    private static class ReviewData {
        private final String status;
        private final String comment;

        private ReviewData(String status, String comment) {
            this.status = status;
            this.comment = comment;
        }
    }

    public static class FindingRecord {

        private final String findingId;
        private final long evidenceId;
        private final String reviewKey;
        private final String evidenceCode;
        private final String fileName;
        private final String caseCode;
        private final String caseName;
        private final String findingType;
        private final String observation;
        private final String technicalStatus;
        private final String reviewStatus;
        private final String reviewComment;

        public FindingRecord(
                String findingId,
                long evidenceId,
                String reviewKey,
                String evidenceCode,
                String fileName,
                String caseCode,
                String caseName,
                String findingType,
                String observation,
                String technicalStatus,
                String reviewStatus,
                String reviewComment) {

            this.findingId = findingId;
            this.evidenceId = evidenceId;
            this.reviewKey = reviewKey;
            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.caseCode = caseCode;
            this.caseName = caseName;
            this.findingType = findingType;
            this.observation = observation;
            this.technicalStatus = technicalStatus;
            this.reviewStatus = reviewStatus;
            this.reviewComment = reviewComment;
        }

        public String getFindingId() { return findingId; }
        public long getEvidenceId() { return evidenceId; }
        public String getReviewKey() { return reviewKey; }
        public String getEvidenceCode() { return evidenceCode; }
        public String getFileName() { return fileName; }
        public String getCaseCode() { return caseCode; }
        public String getCaseName() { return caseName; }
        public String getFindingType() { return findingType; }
        public String getObservation() { return observation; }
        public String getTechnicalStatus() { return technicalStatus; }
        public String getReviewStatus() { return reviewStatus; }
        public String getReviewComment() { return reviewComment; }
    }
}
