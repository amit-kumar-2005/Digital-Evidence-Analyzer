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

@WebServlet("/timeline")
public class TimelineServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        List<TimelineEvent> events = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    c.case_code,
                    c.case_name,
                    'CREATED' AS event_type,
                    ef.created_time AS event_time
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                WHERE ef.created_time IS NOT NULL

                UNION ALL

                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    c.case_code,
                    c.case_name,
                    'MODIFIED' AS event_type,
                    ef.modified_time AS event_time
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                WHERE ef.modified_time IS NOT NULL

                UNION ALL

                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    c.case_code,
                    c.case_name,
                    'ACCESSED' AS event_type,
                    ef.accessed_time AS event_time
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                WHERE ef.accessed_time IS NOT NULL

                UNION ALL

                SELECT
                    ef.evidence_code,
                    ef.file_name,
                    c.case_code,
                    c.case_name,
                    'REGISTERED' AS event_type,
                    ef.registered_at AS event_time
                FROM evidence_files ef
                INNER JOIN cases c ON c.id = ef.case_id
                WHERE ef.registered_at IS NOT NULL

                ORDER BY event_time ASC
                """;

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    events.add(new TimelineEvent(
                            rs.getString("evidence_code"),
                            rs.getString("file_name"),
                            rs.getString("case_code"),
                            rs.getString("case_name"),
                            rs.getString("event_type"),
                            rs.getTimestamp("event_time")
                    ));
                }
            }

            request.setAttribute("events", events);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("dbConnected", false);
            request.setAttribute(
                    "errorMessage",
                    "Unable to load timeline data."
            );
        }

        request.getRequestDispatcher("/jsp/timeline.jsp")
                .forward(request, response);
    }

    public static class TimelineEvent {

        private final String evidenceCode;
        private final String fileName;
        private final String caseCode;
        private final String caseName;
        private final String eventType;
        private final java.sql.Timestamp eventTime;

        public TimelineEvent(
                String evidenceCode,
                String fileName,
                String caseCode,
                String caseName,
                String eventType,
                java.sql.Timestamp eventTime) {

            this.evidenceCode = evidenceCode;
            this.fileName = fileName;
            this.caseCode = caseCode;
            this.caseName = caseName;
            this.eventType = eventType;
            this.eventTime = eventTime;
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

        public String getEventType() {
            return eventType;
        }

        public java.sql.Timestamp getEventTime() {
            return eventTime;
        }
    }
}