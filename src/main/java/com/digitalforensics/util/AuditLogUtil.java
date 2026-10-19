package com.digitalforensics.util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public final class AuditLogUtil {

    private AuditLogUtil() {
    }

    /**
     * Creates an audit log entry for an investigation action.
     *
     * @param userId  Logged-in user ID. Can be null for system actions.
     * @param caseId  Related case ID. Can be null if no case is involved.
     * @param action  Short action name such as EVIDENCE_REGISTERED.
     * @param details Human-readable description of the action.
     */
    public static void log(
            Long userId,
            Long caseId,
            String action,
            String details) {

        String sql = """
            INSERT INTO audit_logs
                (user_id, case_id, action, details)
            VALUES
                (?, ?, ?, ?)
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (userId != null) {
                ps.setLong(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.BIGINT);
            }

            if (caseId != null) {
                ps.setLong(2, caseId);
            } else {
                ps.setNull(2, java.sql.Types.BIGINT);
            }

            ps.setString(3, action);
            ps.setString(4, details);

            ps.executeUpdate();

        } catch (Exception e) {

            /*
             * Audit logging failure should not stop the main
             * investigation operation.
             */
            System.err.println(
                    "AUDIT LOG ERROR: "
                    + e.getMessage()
            );
        }
    }
}