<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.AuditLogServlet.AuditRecord" %>

<%
    List<AuditRecord> auditLogs =
            (List<AuditRecord>) request.getAttribute("auditLogs");

    Integer totalLogs =
            (Integer) request.getAttribute("totalLogs");

    Integer caseActions =
            (Integer) request.getAttribute("caseActions");

    Integer evidenceActions =
            (Integer) request.getAttribute("evidenceActions");

    Integer integrityActions =
            (Integer) request.getAttribute("integrityActions");

    Boolean dbConnected =
            (Boolean) request.getAttribute("dbConnected");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    if (totalLogs == null) totalLogs = 0;
    if (caseActions == null) caseActions = 0;
    if (evidenceActions == null) evidenceActions = 0;
    if (integrityActions == null) integrityActions = 0;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Audit Log - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/audit-log.css">

</head>

<body>

<div class="app-shell">

    <!-- ================= SIDEBAR ================= -->

    <aside class="sidebar">

        <div class="brand">

            <div class="brand-icon">
                DE
            </div>

            <div>
                <div class="brand-title">
                    Digital Evidence
                </div>

                <div class="brand-subtitle">
                    Analyzer
                </div>
            </div>

        </div>


        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/dashboard">
                ▣ Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/cases">
                ◈ Cases
            </a>

            <a href="${pageContext.request.contextPath}/evidence">
                ◇ Evidence
            </a>

            <a href="${pageContext.request.contextPath}/analysis">
                ◌ Analysis
            </a>

            <a href="${pageContext.request.contextPath}/timeline">
                ◷ Timeline
            </a>

            <a href="${pageContext.request.contextPath}/duplicates">
                ◫ Duplicates
            </a>

            <a href="${pageContext.request.contextPath}/indicators">
                ⚠ Indicators
            </a>

            <a href="${pageContext.request.contextPath}/integrity">
                ⌑ Integrity
            </a>

            <a href="${pageContext.request.contextPath}/relationships">
                ⚯ Relationships
            </a>

            <a href="${pageContext.request.contextPath}/findings">
                ≡ Findings
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/audit-log">
                ≣ Audit Log
            </a>

            <a href="${pageContext.request.contextPath}/reports">
                ▤ Reports
            </a>

            <a href="${pageContext.request.contextPath}/settings">
                ⚙ Settings
            </a>

        </nav>


        <div class="sidebar-bottom">

            <a href="${pageContext.request.contextPath}/logout">
                ↪ Sign out
            </a>

        </div>

    </aside>


    <!-- ================= MAIN ================= -->

    <main class="main-content">

        <div class="page-header">

            <div>

                <div class="breadcrumb">
                    INVESTIGATION / AUDIT LOG
                </div>

                <h1>
                    Audit Log
                </h1>

                <p>
                    Track important investigation activities and system actions.
                </p>

            </div>

        </div>


        <!-- ================= STATUS ================= -->

        <%
            if (Boolean.TRUE.equals(dbConnected)) {
        %>

            <div class="success-message">
                ✓ Audit log records loaded successfully.
            </div>

        <%
            } else {
        %>

            <div class="error-message">
                ✕
                <%= errorMessage != null
                        ? errorMessage
                        : "Unable to connect to the database." %>
            </div>

        <%
            }
        %>


        <!-- ================= INFO CARD ================= -->

        <section class="info-card">

            <div class="info-icon">
                ≣
            </div>

            <div>

                <h3>
                    Investigation Activity History
                </h3>

                <p>
                    The audit log provides a chronological record of
                    important application activities associated with
                    cases, evidence and integrity analysis.
                </p>

            </div>

        </section>


        <!-- ================= STATISTICS ================= -->

        <section class="stats-grid">

            <div class="stat-card">

                <div class="stat-label">
                    TOTAL LOGS
                </div>

                <div class="stat-value">
                    <%= totalLogs %>
                </div>

                <div class="stat-description">
                    Recorded activities
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    CASE ACTIONS
                </div>

                <div class="stat-value">
                    <%= caseActions %>
                </div>

                <div class="stat-description">
                    Case-related events
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    EVIDENCE ACTIONS
                </div>

                <div class="stat-value">
                    <%= evidenceActions %>
                </div>

                <div class="stat-description">
                    Evidence activities
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    INTEGRITY ACTIONS
                </div>

                <div class="stat-value">
                    <%= integrityActions %>
                </div>

                <div class="stat-description">
                    Hash / integrity events
                </div>

            </div>

        </section>


        <!-- ================= AUDIT LOG ================= -->

        <section class="audit-section">

            <div class="section-header">

                <div>

                    <h2>
                        Activity History
                    </h2>

                    <p>
                        Latest investigation and system activities
                    </p>

                </div>

                <div class="record-count">
                    <%= totalLogs %> records
                </div>

            </div>


            <%
                if (auditLogs != null && !auditLogs.isEmpty()) {
            %>

                <div class="audit-list">

                    <%
                        for (AuditRecord log : auditLogs) {
                    %>

                        <div class="audit-item">

                            <div class="audit-marker">
                                <span></span>
                            </div>


                            <div class="audit-main">

                                <div class="audit-top">

                                    <div>

                                        <span class="audit-action">
                                            <%= log.getAction() != null
                                                    ? log.getAction()
                                                    : "SYSTEM ACTION" %>
                                        </span>

                                    </div>

                                    <div class="audit-time">
                                        <%= log.getCreatedAt() != null
                                                ? log.getCreatedAt()
                                                : "N/A" %>
                                    </div>

                                </div>


                                <div class="audit-details">

                                    <%= log.getDetails() != null
                                            ? log.getDetails()
                                            : "No additional details available." %>

                                </div>


                                <div class="audit-meta">

                                    <div class="meta-box">

                                        <span class="meta-label">
                                            USER
                                        </span>

                                        <strong>
                                            <%= log.getUserName() %>
                                        </strong>

                                        <small>
                                            <%= log.getRole() %>
                                        </small>

                                    </div>


                                    <div class="meta-box">

                                        <span class="meta-label">
                                            CASE
                                        </span>

                                        <strong>
                                            <%= log.getCaseCode() %>
                                        </strong>

                                        <small>
                                            <%= log.getCaseName() %>
                                        </small>

                                    </div>


                                    <div class="meta-box">

                                        <span class="meta-label">
                                            RECORD ID
                                        </span>

                                        <strong>
                                            #<%= log.getId() %>
                                        </strong>

                                        <small>
                                            Audit record
                                        </small>

                                    </div>

                                </div>

                            </div>

                        </div>

                    <%
                        }
                    %>

                </div>

            <%
                } else {
            %>

                <div class="empty-state">

                    <div class="empty-icon">
                        ≣
                    </div>

                    <h3>
                        No Audit Records Found
                    </h3>

                    <p>
                        No investigation activities have been
                        recorded in the audit log yet.
                    </p>

                </div>

            <%
                }
            %>

        </section>


        <!-- ================= DISCLAIMER ================= -->

        <div class="audit-note">

            <strong>Audit Log</strong>

            <span>
                This academic audit log records application-level
                activities for investigation tracking. It is not
                intended to replace a professional legal chain-of-custody
                system or institutional forensic logging system.
            </span>

        </div>


    </main>

</div>

</body>
</html>