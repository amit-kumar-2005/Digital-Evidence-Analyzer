
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.RelationshipServlet.RelationshipRecord" %>

<%
    List<RelationshipRecord> relationships =
            (List<RelationshipRecord>) request.getAttribute("relationships");

    Boolean dbConnected =
            (Boolean) request.getAttribute("dbConnected");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    if (relationships == null) {
        relationships = java.util.Collections.emptyList();
    }

    int totalRelationships = relationships.size();

    Object sameCaseObj = request.getAttribute("sameCaseCount");
    Object sameHashObj = request.getAttribute("sameHashCount");
    Object duplicateObj = request.getAttribute("duplicateCount");
    Object timestampObj = request.getAttribute("timestampCount");

    int sameCaseCount = sameCaseObj != null
            ? (Integer) sameCaseObj : 0;

    int sameHashCount = sameHashObj != null
            ? (Integer) sameHashObj : 0;

    int duplicateCount = duplicateObj != null
            ? (Integer) duplicateObj : 0;

    int timestampCount = timestampObj != null
            ? (Integer) timestampObj : 0;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Relationships - Digital Evidence Analyzer
    </title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/relationships.css">

</head>

<body>

<div class="app-layout">

    <!-- ================= SIDEBAR ================= -->

    <aside class="sidebar">

        <div class="brand">

            <div class="brand-icon">
                DE
            </div>

            <div class="brand-text">
                <strong>Digital Evidence</strong>
                <span>Analyzer</span>
            </div>

        </div>

        <!-- UPDATED / VERIFIED SIDEBAR NAVIGATION -->

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/dashboard">
                ▣ Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/cases">
                ▫ Cases
                <span>›</span>
            </a>

            <a href="${pageContext.request.contextPath}/evidence">
                ◇ Evidence
                <span>›</span>
            </a>

            <a href="${pageContext.request.contextPath}/analysis">
                ⌕ Analysis
                <span>›</span>
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

            <a class="active"
               href="${pageContext.request.contextPath}/relationships">
                ⛓ Relationships
            </a>

            <a href="${pageContext.request.contextPath}/findings">
                ≡ Findings
            </a>

            <a href="${pageContext.request.contextPath}/audit-log">
                ≡ Audit Log
            </a>

            <a href="${pageContext.request.contextPath}/reports">
                ▥ Reports
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

    <!-- ================= MAIN CONTENT ================= -->

    <main class="main-content">

        <header class="page-header">

            <div>

                <div class="eyebrow">
                    INVESTIGATION / RELATIONSHIPS
                </div>

                <h1>Evidence Relationships</h1>

                <p>
                    Identify technical relationships between
                    registered evidence items.
                </p>

            </div>

        </header>

        <!-- ================= STATUS ================= -->

        <% if (Boolean.TRUE.equals(dbConnected)) { %>

            <div class="success-message">
                ✓ Evidence relationship analysis loaded successfully.
            </div>

        <% } else { %>

            <div class="error-message">

                ⚠

                <%= errorMessage != null
                        ? errorMessage
                        : "Unable to load evidence relationships." %>

            </div>

        <% } %>

        <!-- ================= INFORMATION ================= -->

        <section class="info-card">

            <div class="info-icon">
                ⛓
            </div>

            <div>

                <strong>
                    Technical Relationship Analysis
                </strong>

                <p>
                    Relationships are derived from shared case
                    membership, matching SHA-256 hashes and
                    closely related creation timestamps.
                    These are technical observations only.
                </p>

            </div>

        </section>

        <!-- ================= STATISTICS ================= -->

        <section class="stats-grid">

            <div class="stat-card">

                <span class="stat-label">
                    TOTAL RELATIONSHIPS
                </span>

                <strong>
                    <%= totalRelationships %>
                </strong>

                <small>
                    Identified evidence links
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    SAME CASE
                </span>

                <strong>
                    <%= sameCaseCount %>
                </strong>

                <small>
                    Shared investigation case
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    SAME HASH
                </span>

                <strong>
                    <%= sameHashCount %>
                </strong>

                <small>
                    Matching SHA-256
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    TIMESTAMP LINKS
                </span>

                <strong>
                    <%= timestampCount %>
                </strong>

                <small>
                    Within 5 minutes
                </small>

            </div>

        </section>

        <!-- ================= RELATIONSHIP TABLE ================= -->

        <section class="relationship-card">

            <div class="section-header">

                <div>

                    <h2>
                        Evidence Relationship Map
                    </h2>

                    <p>
                        Technical connections identified between
                        evidence items.
                    </p>

                </div>

                <span class="record-count">
                    <%= totalRelationships %> relationships
                </span>

            </div>

            <% if (relationships.isEmpty()) { %>

                <div class="empty-state">

                    <div class="empty-icon">
                        ⛓
                    </div>

                    <h3>
                        No relationships found
                    </h3>

                    <p>
                        Relationships will appear when multiple
                        evidence items share a case, hash or
                        related timestamp.
                    </p>

                    <a href="${pageContext.request.contextPath}/evidence"
                       class="primary-button">
                        Register More Evidence
                    </a>

                </div>

            <% } else { %>

                <div class="relationship-list">

                    <% for (RelationshipRecord relationship
                            : relationships) {

                        String type =
                                relationship.getRelationshipType();

                        String typeClass =
                                type.toLowerCase()
                                    .replace(" ", "-");

                    %>

                    <div class="relationship-row">

                        <!-- Evidence 1 -->

                        <div class="evidence-box">

                            <span class="box-label">
                                EVIDENCE A
                            </span>

                            <strong>
                                <%= relationship.getEvidence1() %>
                            </strong>

                            <small>
                                <%= relationship.getFile1() %>
                            </small>

                        </div>

                        <!-- Relationship -->

                        <div class="relationship-center">

                            <div class="relationship-icon">
                                ⛓
                            </div>

                            <span class="relationship-type
                                         <%= typeClass %>">

                                <%= type %>

                            </span>

                        </div>

                        <!-- Evidence 2 -->

                        <div class="evidence-box">

                            <span class="box-label">
                                EVIDENCE B
                            </span>

                            <strong>
                                <%= relationship.getEvidence2() %>
                            </strong>

                            <small>
                                <%= relationship.getFile2() %>
                            </small>

                        </div>

                    </div>

                    <% } %>

                </div>

            <% } %>

        </section>

        <!-- ================= RELATIONSHIP LEGEND ================= -->

        <section class="legend-card">

            <h3>
                Relationship Types
            </h3>

            <div class="legend-grid">

                <div class="legend-item">

                    <span class="legend-dot same-case"></span>

                    <div>

                        <strong>
                            Same Case
                        </strong>

                        <small>
                            Evidence belongs to the same case.
                        </small>

                    </div>

                </div>

                <div class="legend-item">

                    <span class="legend-dot same-hash"></span>

                    <div>

                        <strong>
                            Same Hash
                        </strong>

                        <small>
                            Evidence has the same SHA-256 value.
                        </small>

                    </div>

                </div>

                <div class="legend-item">

                    <span class="legend-dot timestamp"></span>

                    <div>

                        <strong>
                            Related Timestamp
                        </strong>

                        <small>
                            Creation timestamps are within
                            five minutes.
                        </small>

                    </div>

                </div>

                <div class="legend-item">

                    <span class="legend-dot duplicate"></span>

                    <div>

                        <strong>
                            Duplicate
                        </strong>

                        <small>
                            Evidence items share the same hash.
                        </small>

                    </div>

                </div>

            </div>

        </section>

        <!-- ================= TECHNICAL NOTE ================= -->

        <div class="technical-note">

            <strong>
                Technical Relationship Analysis
            </strong>

            <span>
                Relationship links are generated from available
                evidence metadata and database records. They are
                intended for academic investigation and do not
                establish legal or forensic conclusions by themselves.
            </span>

        </div>

    </main>

</div>

</body>
</html>
