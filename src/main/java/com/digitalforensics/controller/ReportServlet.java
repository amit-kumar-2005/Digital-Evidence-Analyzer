
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

@WebServlet("/reports")
public class ReportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        List<ReportRecord> reports = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    c.id,
                    c.case_code,
                    c.case_name,
                    c.description,
                    c.status,
                    c.created_at,
                    COUNT(e.id) AS evidence_count,
                    COALESCE(SUM(
                        CASE WHEN e.integrity_status = 'VERIFIED'
                        THEN 1 ELSE 0 END
                    ), 0) AS verified_count,
                    COALESCE(SUM(
                        CASE WHEN e.integrity_status = 'HASH_MISMATCH'
                        THEN 1 ELSE 0 END
                    ), 0) AS mismatch_count
                FROM cases c
                LEFT JOIN evidence_files e ON e.case_id = c.id
                GROUP BY
                    c.id, c.case_code, c.case_name,
                    c.description, c.status, c.created_at
                ORDER BY c.created_at DESC
                """;

            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    reports.add(new ReportRecord(
                        rs.getLong("id"),
                        rs.getString("case_code"),
                        rs.getString("case_name"),
                        rs.getString("description"),
                        rs.getString("status"),
                        rs.getString("created_at"),
                        rs.getInt("evidence_count"),
                        rs.getInt("verified_count"),
                        rs.getInt("mismatch_count")
                    ));
                }
            }

            req.setAttribute("reports", reports);
            req.setAttribute("dbConnected", true);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("reports", new ArrayList<ReportRecord>());
            req.setAttribute("dbConnected", false);
            req.setAttribute("errorMessage",
                    "Unable to load investigation reports.");
        }

        req.getRequestDispatcher("/jsp/reports.jsp")
           .forward(req, resp);
    }

    public static class ReportRecord {
        private final long id;
        private final String caseCode;
        private final String caseName;
        private final String description;
        private final String status;
        private final String createdAt;
        private final int evidenceCount;
        private final int verifiedCount;
        private final int mismatchCount;

        public ReportRecord(long id, String caseCode,
                String caseName, String description,
                String status, String createdAt,
                int evidenceCount, int verifiedCount,
                int mismatchCount) {
            this.id = id;
            this.caseCode = caseCode;
            this.caseName = caseName;
            this.description = description;
            this.status = status;
            this.createdAt = createdAt;
            this.evidenceCount = evidenceCount;
            this.verifiedCount = verifiedCount;
            this.mismatchCount = mismatchCount;
        }

        public long getId() { return id; }
        public String getCaseCode() { return caseCode; }
        public String getCaseName() { return caseName; }
        public String getDescription() { return description; }
        public String getStatus() { return status; }
        public String getCreatedAt() { return createdAt; }
        public int getEvidenceCount() { return evidenceCount; }
        public int getVerifiedCount() { return verifiedCount; }
        public int getMismatchCount() { return mismatchCount; }
    }
}
