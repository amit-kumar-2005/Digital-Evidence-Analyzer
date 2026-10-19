package com.digitalforensics.controller;

import com.digitalforensics.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/analysis")
public class AnalysisServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<AnalysisRecord> records = new ArrayList<>();

        String sql = """
                SELECT
                    ef.id,
                    ef.evidence_code,
                    c.case_code,
                    c.case_name,
                    ef.file_name,
                    ef.file_path,
                    ef.file_type,
                    ef.file_size,
                    ef.created_time,
                    ef.modified_time,
                    ef.accessed_time,
                    ef.md5,
                    ef.registered_sha256,
                    ef.current_sha256,
                    ef.integrity_status,
                    ef.registered_at
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                ORDER BY ef.registered_at DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                AnalysisRecord record = new AnalysisRecord();

                record.id = rs.getLong("id");
                record.evidenceCode = rs.getString("evidence_code");
                record.caseCode = rs.getString("case_code");
                record.caseName = rs.getString("case_name");
                record.fileName = rs.getString("file_name");
                record.filePath = rs.getString("file_path");
                record.fileType = rs.getString("file_type");
                record.fileSize = rs.getLong("file_size");

                record.createdTime = rs.getTimestamp("created_time");
                record.modifiedTime = rs.getTimestamp("modified_time");
                record.accessedTime = rs.getTimestamp("accessed_time");

                record.md5 = rs.getString("md5");
                record.registeredSha256 = rs.getString("registered_sha256");
                record.currentSha256 = rs.getString("current_sha256");
                record.integrityStatus = rs.getString("integrity_status");
                record.registeredAt = rs.getTimestamp("registered_at");

                records.add(record);
            }

        } catch (Exception e) {
            throw new ServletException("Unable to load analysis data.", e);
        }

        req.setAttribute("analysisRecords", records);
        req.getRequestDispatcher("/jsp/analysis.jsp").forward(req, resp);
    }

    public static class AnalysisRecord {

        private long id;
        private String evidenceCode;
        private String caseCode;
        private String caseName;
        private String fileName;
        private String filePath;
        private String fileType;
        private long fileSize;

        private Timestamp createdTime;
        private Timestamp modifiedTime;
        private Timestamp accessedTime;

        private String md5;
        private String registeredSha256;
        private String currentSha256;
        private String integrityStatus;
        private Timestamp registeredAt;

        public long getId() {
            return id;
        }

        public String getEvidenceCode() {
            return evidenceCode;
        }

        public String getCaseCode() {
            return caseCode;
        }

        public String getCaseName() {
            return caseName;
        }

        public String getFileName() {
            return fileName;
        }

        public String getFilePath() {
            return filePath;
        }

        public String getFileType() {
            return fileType;
        }

        public long getFileSize() {
            return fileSize;
        }

        public Timestamp getCreatedTime() {
            return createdTime;
        }

        public Timestamp getModifiedTime() {
            return modifiedTime;
        }

        public Timestamp getAccessedTime() {
            return accessedTime;
        }

        public String getMd5() {
            return md5;
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

        public String getFormattedSize() {

            if (fileSize < 1024) {
                return fileSize + " B";
            }

            if (fileSize < 1024 * 1024) {
                return String.format("%.2f KB", fileSize / 1024.0);
            }

            if (fileSize < 1024L * 1024L * 1024L) {
                return String.format("%.2f MB",
                        fileSize / (1024.0 * 1024.0));
            }

            return String.format("%.2f GB",
                    fileSize / (1024.0 * 1024.0 * 1024.0));
        }

        public String getShortHash(String hash) {

            if (hash == null || hash.isBlank()) {
                return "—";
            }

            if (hash.length() <= 24) {
                return hash;
            }

            return hash.substring(0, 24) + "...";
        }
    }
}