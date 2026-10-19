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

@WebServlet("/relationships")
public class RelationshipServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        List<RelationshipRecord> relationships = new ArrayList<>();

        int sameCaseCount = 0;
        int sameHashCount = 0;
        int duplicateCount = 0;
        int timestampCount = 0;

        try (Connection conn = DBConnection.getConnection()) {

            String sql = """
                SELECT
                    e1.evidence_code AS evidence1,
                    e1.file_name AS file1,
                    e2.evidence_code AS evidence2,
                    e2.file_name AS file2,

                    CASE
                        WHEN e1.current_sha256 IS NOT NULL
                             AND e1.current_sha256 = e2.current_sha256
                            THEN 'SAME HASH'

                        WHEN e1.case_id = e2.case_id
                            THEN 'SAME CASE'

                        WHEN e1.created_time IS NOT NULL
                             AND e2.created_time IS NOT NULL
                             AND ABS(
                                 TIMESTAMPDIFF(
                                     MINUTE,
                                     e1.created_time,
                                     e2.created_time
                                 )
                             ) <= 5
                            THEN 'RELATED TIMESTAMP'

                        ELSE 'RELATED'
                    END AS relationship_type

                FROM evidence_files e1

                INNER JOIN evidence_files e2
                    ON e1.id < e2.id

                WHERE
                    e1.case_id = e2.case_id

                    OR (
                        e1.current_sha256 IS NOT NULL
                        AND e1.current_sha256 <> ''
                        AND e1.current_sha256 = e2.current_sha256
                    )

                    OR (
                        e1.created_time IS NOT NULL
                        AND e2.created_time IS NOT NULL
                        AND ABS(
                            TIMESTAMPDIFF(
                                MINUTE,
                                e1.created_time,
                                e2.created_time
                            )
                        ) <= 5
                    )

                ORDER BY e1.id, e2.id
                """;

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    String evidence1 =
                            rs.getString("evidence1");

                    String file1 =
                            rs.getString("file1");

                    String evidence2 =
                            rs.getString("evidence2");

                    String file2 =
                            rs.getString("file2");

                    String relationshipType =
                            rs.getString("relationship_type");

                    relationships.add(
                            new RelationshipRecord(
                                    evidence1,
                                    file1,
                                    evidence2,
                                    file2,
                                    relationshipType
                            )
                    );

                    if ("SAME CASE".equals(relationshipType)) {
                        sameCaseCount++;
                    }

                    if ("SAME HASH".equals(relationshipType)) {
                        sameHashCount++;
                    }

                    if ("SAME HASH".equals(relationshipType)) {
                        duplicateCount++;
                    }

                    if ("RELATED TIMESTAMP".equals(relationshipType)) {
                        timestampCount++;
                    }
                }
            }

            request.setAttribute("relationships", relationships);
            request.setAttribute("sameCaseCount", sameCaseCount);
            request.setAttribute("sameHashCount", sameHashCount);
            request.setAttribute("duplicateCount", duplicateCount);
            request.setAttribute("timestampCount", timestampCount);
            request.setAttribute("dbConnected", true);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("dbConnected", false);

            request.setAttribute(
                    "errorMessage",
                    "Unable to load evidence relationships."
            );
        }

        request.getRequestDispatcher("/jsp/relationships.jsp")
                .forward(request, response);
    }

    public static class RelationshipRecord {

        private final String evidence1;
        private final String file1;
        private final String evidence2;
        private final String file2;
        private final String relationshipType;

        public RelationshipRecord(
                String evidence1,
                String file1,
                String evidence2,
                String file2,
                String relationshipType) {

            this.evidence1 = evidence1;
            this.file1 = file1;
            this.evidence2 = evidence2;
            this.file2 = file2;
            this.relationshipType = relationshipType;
        }

        public String getEvidence1() {
            return evidence1;
        }

        public String getFile1() {
            return file1;
        }

        public String getEvidence2() {
            return evidence2;
        }

        public String getFile2() {
            return file2;
        }

        public String getRelationshipType() {
            return relationshipType;
        }
    }
}