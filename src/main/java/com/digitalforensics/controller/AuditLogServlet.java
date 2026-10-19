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

@WebServlet("/audit-log")
public class AuditLogServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        List<AuditRecord> auditLogs = new ArrayList<>();

        int totalLogs = 0;
        int caseActions = 0;
        int evidenceActions = 0;
        int integrityActions = 0;

        try (Connection conn = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    al.id,
                    al.action,
                    al.details,
                    al.created_at,
                    u.full_name,
                    u.email,
                    u.role,
                    c.case_code,
                    c.case_name
                FROM audit_logs al
                LEFT JOIN users u
                    ON u.id = al.user_id
                LEFT JOIN cases c
                    ON c.id = al.case_id
                ORDER BY al.created_at DESC, al.id DESC
                """;

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    long id = rs.getLong("id");

                    String action = rs.getString("action");
                    String details = rs.getString("details");
                    String createdAt = rs.getString("created_at");

                    String userName = rs.getString("full_name");
                    String email = rs.getString("email");
                    String role = rs.getString("role");

                    String caseCode = rs.getString("case_code");
                    String caseName = rs.getString("case_name");

                    if (userName == null || userName.isBlank()) {
                        userName = "System";
                    }

                    if (email == null || email.isBlank()) {
                        email = "N/A";
                    }

                    if (role == null || role.isBlank()) {
                        role = "SYSTEM";
                    }

                    if (caseCode == null || caseCode.isBlank()) {
                        caseCode = "N/A";
                    }

                    if (caseName == null || caseName.isBlank()) {
                        caseName = "No Case Linked";
                    }

                    auditLogs.add(new AuditRecord(
                            id,
                            action,
                            details,
                            createdAt,
                            userName,
                            email,
                            role,
                            caseCode,
                            caseName
                    ));

                    totalLogs++;

                    if (action != null) {

                        String upperAction =
                                action.toUpperCase();

                        if (upperAction.contains("CASE")) {
                            caseActions++;
                        }

                        if (upperAction.contains("EVIDENCE")) {
                            evidenceActions++;
                        }

                        if (upperAction.contains("INTEGRITY")
                                || upperAction.contains("HASH")) {
                            integrityActions++;
                        }
                    }
                }
            }

            request.setAttribute("auditLogs", auditLogs);
            request.setAttribute("totalLogs", totalLogs);
            request.setAttribute("caseActions", caseActions);
            request.setAttribute("evidenceActions", evidenceActions);
            request.setAttribute("integrityActions", integrityActions);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "auditLogs",
                    new ArrayList<AuditRecord>()
            );

            request.setAttribute("totalLogs", 0);
            request.setAttribute("caseActions", 0);
            request.setAttribute("evidenceActions", 0);
            request.setAttribute("integrityActions", 0);

            request.setAttribute("dbConnected", false);

            request.setAttribute(
                    "errorMessage",
                    "Unable to load audit log records."
            );
        }

        request.getRequestDispatcher(
                "/jsp/audit-log.jsp"
        ).forward(request, response);
    }

    public static class AuditRecord {

        private final long id;
        private final String action;
        private final String details;
        private final String createdAt;
        private final String userName;
        private final String email;
        private final String role;
        private final String caseCode;
        private final String caseName;

        public AuditRecord(
                long id,
                String action,
                String details,
                String createdAt,
                String userName,
                String email,
                String role,
                String caseCode,
                String caseName) {

            this.id = id;
            this.action = action;
            this.details = details;
            this.createdAt = createdAt;
            this.userName = userName;
            this.email = email;
            this.role = role;
            this.caseCode = caseCode;
            this.caseName = caseName;
        }

        public long getId() {
            return id;
        }

        public String getAction() {
            return action;
        }

        public String getDetails() {
            return details;
        }

        public String getCreatedAt() {
            return createdAt;
        }

        public String getUserName() {
            return userName;
        }

        public String getEmail() {
            return email;
        }

        public String getRole() {
            return role;
        }

        public String getCaseCode() {
            return caseCode;
        }

        public String getCaseName() {
            return caseName;
        }
    }
}