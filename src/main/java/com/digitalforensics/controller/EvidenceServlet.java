
package com.digitalforensics.controller;

import com.digitalforensics.model.User;
import com.digitalforensics.util.AuditLogUtil;
import com.digitalforensics.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/evidence")
public class EvidenceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null
                || session.getAttribute("currentUser") == null) {

            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            loadCases(req);
            loadEvidence(req);

            req.getRequestDispatcher("/jsp/evidence.jsp")
                    .forward(req, resp);

        } catch (Exception e) {
            getServletContext().log(
                    "Unable to load evidence page.", e);

            throw new ServletException(
                    "Unable to load evidence page.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // 1. Authentication check
        if (session == null
                || session.getAttribute("currentUser") == null) {

            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        // 2. Authorization check
        // Only ADMIN and INVESTIGATOR can register evidence.
        String role = user.getRole();

        if (!"ADMIN".equalsIgnoreCase(role)
                && !"INVESTIGATOR".equalsIgnoreCase(role)) {

            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to register evidence."
            );
            return;
        }

        // 3. Read form parameters
        String caseId = req.getParameter("caseId");
        String filePath = req.getParameter("filePath");

        if (caseId == null || caseId.isBlank()
                || filePath == null || filePath.isBlank()) {

            redirectWithError(
                    req,
                    resp,
                    "Please select a case and enter a file path"
            );
            return;
        }

        try {
            // 4. Validate the selected file path
            Path path = Paths.get(filePath.trim())
                    .toAbsolutePath()
                    .normalize();

            if (!Files.exists(path)) {
                redirectWithError(req, resp, "File does not exist");
                return;
            }

            if (!Files.isRegularFile(path)
                    || !Files.isReadable(path)) {

                redirectWithError(
                        req,
                        resp,
                        "Selected path is not a readable regular file"
                );
                return;
            }

            // 5. Read file metadata
            BasicFileAttributes attributes =
                    Files.readAttributes(
                            path,
                            BasicFileAttributes.class
                    );

            // 6. Calculate cryptographic hashes
            String sha256 = calculateHash(path, "SHA-256");
            String md5 = calculateHash(path, "MD5");

            String fileType = detectFileType(path);
            long fileSize = attributes.size();

            Timestamp createdTime =
                    new Timestamp(
                            attributes.creationTime().toMillis()
                    );

            Timestamp modifiedTime =
                    new Timestamp(
                            attributes.lastModifiedTime().toMillis()
                    );

            Timestamp accessedTime =
                    new Timestamp(
                            attributes.lastAccessTime().toMillis()
                    );

            long numericCaseId = Long.parseLong(caseId);

            // 7. Confirm that the selected case exists and is open
            if (!isValidOpenCase(numericCaseId)) {
                redirectWithError(
                        req,
                        resp,
                        "Selected case does not exist or is closed"
                );
                return;
            }

            String evidenceCode;

            // 8. Insert evidence into the database
            try (Connection con = DBConnection.getConnection()) {

                evidenceCode = generateEvidenceCode(con);

                String sql = """
                        INSERT INTO evidence_files
                        (
                            case_id,
                            evidence_code,
                            file_name,
                            file_path,
                            file_type,
                            file_size,
                            created_time,
                            modified_time,
                            accessed_time,
                            registered_sha256,
                            current_sha256,
                            md5,
                            integrity_status
                        )
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """;

                try (PreparedStatement ps =
                             con.prepareStatement(sql)) {

                    ps.setLong(1, numericCaseId);
                    ps.setString(2, evidenceCode);
                    ps.setString(3, path.getFileName().toString());
                    ps.setString(4, path.toString());
                    ps.setString(5, fileType);
                    ps.setLong(6, fileSize);
                    ps.setTimestamp(7, createdTime);
                    ps.setTimestamp(8, modifiedTime);
                    ps.setTimestamp(9, accessedTime);
                    ps.setString(10, sha256);
                    ps.setString(11, sha256);
                    ps.setString(12, md5);
                    ps.setString(13, "VERIFIED");

                    ps.executeUpdate();
                }
            }

            // 9. Record the successful operation in the audit log
            Long userId = getCurrentUserId(session);

            String auditDetails =
                    "Evidence " + evidenceCode
                    + " registered successfully. "
                    + "File: " + path.getFileName()
                    + ", Type: " + fileType
                    + ", Size: " + fileSize + " bytes."
                    + " Initial SHA-256 integrity status: VERIFIED.";

            AuditLogUtil.log(
                    userId,
                    numericCaseId,
                    "EVIDENCE_REGISTERED",
                    auditDetails
            );

            resp.sendRedirect(
                    req.getContextPath()
                    + "/evidence?success=Evidence+registered+successfully"
            );

        } catch (Exception e) {
            getServletContext().log(
                    "Evidence registration failed.", e);

            redirectWithError(
                    req,
                    resp,
                    "Registration failed. Check the file path, database connection and server log."
            );
        }
    }

    private void redirectWithError(
            HttpServletRequest req,
            HttpServletResponse resp,
            String message) throws IOException {

        resp.sendRedirect(
                req.getContextPath()
                + "/evidence?error="
                + URLEncoder.encode(
                        message,
                        StandardCharsets.UTF_8
                )
        );
    }

    private boolean isValidOpenCase(long caseId)
            throws Exception {

        String sql = """
                SELECT id
                FROM cases
                WHERE id = ?
                  AND status <> 'CLOSED'
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, caseId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Long getCurrentUserId(HttpSession session) {

        Object currentUser = session.getAttribute("currentUser");

        if (currentUser instanceof User) {
            return ((User) currentUser).getId();
        }

        return null;
    }

    private void loadCases(HttpServletRequest req)
            throws Exception {

        List<CaseOption> cases = new ArrayList<>();

        String sql = """
                SELECT id, case_code, case_name
                FROM cases
                WHERE status <> 'CLOSED'
                ORDER BY created_at DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                cases.add(
                        new CaseOption(
                                rs.getLong("id"),
                                rs.getString("case_code"),
                                rs.getString("case_name")
                        )
                );
            }
        }

        req.setAttribute("cases", cases);
    }

    private void loadEvidence(HttpServletRequest req)
            throws Exception {

        List<EvidenceRecord> evidenceList = new ArrayList<>();

        String sql = """
                SELECT
                    e.evidence_code,
                    e.file_name,
                    e.file_type,
                    e.file_size,
                    e.integrity_status,
                    e.registered_sha256,
                    e.md5,
                    e.registered_at,
                    c.case_code
                FROM evidence_files e
                INNER JOIN cases c ON e.case_id = c.id
                ORDER BY e.registered_at DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EvidenceRecord record = new EvidenceRecord();

                record.evidenceCode =
                        rs.getString("evidence_code");

                record.fileName =
                        rs.getString("file_name");

                record.fileType =
                        rs.getString("file_type");

                record.fileSize =
                        rs.getLong("file_size");

                record.integrityStatus =
                        rs.getString("integrity_status");

                record.sha256 =
                        rs.getString("registered_sha256");

                record.md5 =
                        rs.getString("md5");

                record.registeredAt =
                        rs.getTimestamp("registered_at");

                record.caseCode =
                        rs.getString("case_code");

                evidenceList.add(record);
            }
        }

        req.setAttribute("evidenceList", evidenceList);
    }

    private String generateEvidenceCode(Connection con)
            throws Exception {

        String sql = """
                SELECT COALESCE(
                    MAX(CAST(SUBSTRING(evidence_code, 4) AS UNSIGNED)),
                    0
                ) + 1 AS next_number
                FROM evidence_files
                """;

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            rs.next();

            long nextNumber = rs.getLong("next_number");

            return String.format("EV-%04d", nextNumber);
        }
    }

    private String calculateHash(Path path, String algorithm)
            throws Exception {

        MessageDigest digest =
                MessageDigest.getInstance(algorithm);

        try (InputStream inputStream = Files.newInputStream(path)) {
            byte[] buffer = new byte[8192];
            int bytesRead;

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                digest.update(buffer, 0, bytesRead);
            }
        }

        byte[] hashBytes = digest.digest();
        StringBuilder result = new StringBuilder();

        for (byte b : hashBytes) {
            result.append(String.format("%02x", b));
        }

        return result.toString();
    }

    private String detectFileType(Path path) {

        try {
            String detectedType = Files.probeContentType(path);

            if (detectedType != null) {
                return detectedType;
            }
        } catch (Exception ignored) {
            // Fall back to the file extension.
        }

        String fileName = path.getFileName().toString();
        int dotIndex = fileName.lastIndexOf('.');

        if (dotIndex > 0 && dotIndex < fileName.length() - 1) {
            return fileName.substring(dotIndex + 1).toUpperCase();
        }

        return "UNKNOWN";
    }

    public static class CaseOption {

        private final long id;
        private final String caseCode;
        private final String caseName;

        public CaseOption(long id, String caseCode, String caseName) {
            this.id = id;
            this.caseCode = caseCode;
            this.caseName = caseName;
        }

        public long getId() {
            return id;
        }

        public String getCaseCode() {
            return caseCode;
        }

        public String getCaseName() {
            return caseName;
        }
    }

    public static class EvidenceRecord {

        String evidenceCode;
        String fileName;
        String fileType;
        long fileSize;
        String integrityStatus;
        String sha256;
        String md5;
        Timestamp registeredAt;
        String caseCode;

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getFileName() {
            return fileName;
        }

        public String getFileType() {
            return fileType;
        }

        public long getFileSize() {
            return fileSize;
        }

        public String getIntegrityStatus() {
            return integrityStatus;
        }

        public String getSha256() {
            return sha256;
        }

        public String getMd5() {
            return md5;
        }

        public Timestamp getRegisteredAt() {
            return registeredAt;
        }

        public String getCaseCode() {
            return caseCode;
        }
    }
}
