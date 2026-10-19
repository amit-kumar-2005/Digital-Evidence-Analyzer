
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.DuplicateServlet.DuplicateGroup" %>
<%@ page import="com.digitalforensics.controller.DuplicateServlet.EvidenceItem" %>

<%
    List<DuplicateGroup> groups =
            (List<DuplicateGroup>) request.getAttribute("duplicateGroups");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>Duplicates - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/duplicates.css">

</head>

<body>

<div class="app">

    <!-- SIDEBAR -->

    <aside class="sidebar">

        <div class="brand">

            <span class="brand-mark">DE</span>

            <div>

                <strong>Digital Evidence</strong>

                <small>Analyzer</small>

            </div>

        </div>

        <!-- UPDATED SIDEBAR NAVIGATION -->

        <nav>

            <a href="${pageContext.request.contextPath}/dashboard">
                ▣ Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/cases">
                ▣ Cases <span>›</span>
            </a>

            <a href="${pageContext.request.contextPath}/evidence">
                ▤ Evidence <span>›</span>
            </a>

            <a href="${pageContext.request.contextPath}/analysis">
                ⌕ Analysis <span>›</span>
            </a>

            <a href="${pageContext.request.contextPath}/timeline">
                ◷ Timeline
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/duplicates">

                ◫ Duplicates

            </a>

            <a href="${pageContext.request.contextPath}/indicators">
                ⚠ Indicators
            </a>

            <a href="${pageContext.request.contextPath}/integrity">

                ⌑ Integrity

            </a>

            <a href="${pageContext.request.contextPath}/relationships">
                ⌘ Relationships
            </a>

            <a href="${pageContext.request.contextPath}/findings">
                ☷ Findings
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

    <!-- MAIN CONTENT -->

    <main class="content">

        <header>

            <div>

                <p class="eyebrow">
                    DUPLICATE EVIDENCE ANALYSIS
                </p>

                <h1>
                    Duplicate Evidence
                </h1>

                <p class="muted">
                    Identify evidence files having the same SHA-256 hash.
                </p>

            </div>

        </header>

        <!-- INFORMATION -->

        <section class="duplicate-info">

            <div class="info-icon">
                ◫
            </div>

            <div>

                <h3>
                    Hash-Based Duplicate Detection
                </h3>

                <p>
                    Evidence files are grouped using their current SHA-256
                    hash. Files with the same SHA-256 value are displayed
                    together as a potential duplicate group.
                </p>

            </div>

        </section>

        <!-- SUMMARY -->

        <section class="cards duplicate-cards">

            <div class="card">

                <span>DUPLICATE GROUPS</span>

                <strong>
                    <%= groups == null ? 0 : groups.size() %>
                </strong>

                <small>
                    Groups containing matching hashes
                </small>

            </div>

            <div class="card">

                <span>MATCHED EVIDENCE</span>

                <strong>

                    <%
                        int totalEvidence = 0;

                        if (groups != null) {
                            for (DuplicateGroup g : groups) {
                                totalEvidence += g.getDuplicateCount();
                            }
                        }
                    %>

                    <%= totalEvidence %>

                </strong>

                <small>
                    Evidence involved in duplicate groups
                </small>

            </div>

            <div class="card">

                <span>HASH METHOD</span>

                <strong>
                    SHA-256
                </strong>

                <small>
                    Current evidence hash
                </small>

            </div>

            <div class="card">

                <span>DETECTION TYPE</span>

                <strong>
                    EXACT
                </strong>

                <small>
                    Hash-based comparison
                </small>

            </div>

        </section>

        <!-- DUPLICATE GROUPS -->

        <section class="panel duplicate-panel">

            <div class="panel-head">

                <div>

                    <h2>
                        Duplicate Groups
                    </h2>

                    <p class="panel-subtitle">
                        Evidence items sharing the same SHA-256 hash.
                    </p>

                </div>

                <span class="record-count">

                    <%= groups == null ? 0 : groups.size() %>
                    groups

                </span>

            </div>

            <% if (groups == null || groups.isEmpty()) { %>

                <div class="empty">

                    <div class="empty-icon">
                        ◫
                    </div>

                    <h3>
                        No duplicate groups found
                    </h3>

                    <p>
                        No two registered evidence files currently
                        have the same SHA-256 hash.
                    </p>

                    <a class="primary button-link"
                       href="${pageContext.request.contextPath}/evidence">

                        Register More Evidence

                    </a>

                </div>

            <% } else { %>

                <div class="duplicate-list">

                    <% for (DuplicateGroup group : groups) { %>

                    <article class="duplicate-group">

                        <!-- GROUP HEADER -->

                        <div class="duplicate-header">

                            <div>

                                <span class="group-label">
                                    DUPLICATE GROUP
                                </span>

                                <h3>
                                    <%= group.getDuplicateCount() %>
                                    Matching Evidence Files
                                </h3>

                            </div>

                            <span class="duplicate-badge">
                                HASH MATCH
                            </span>

                        </div>

                        <!-- HASH -->

                        <div class="duplicate-hash">

                            <label>
                                SHA-256
                            </label>

                            <code title="<%= group.getSha256() %>">

                                <%= group.getShortHash() %>

                            </code>

                        </div>

                        <!-- EVIDENCE -->

                        <div class="duplicate-items">

                            <% for (EvidenceItem item :
                                    group.getEvidenceItems()) { %>

                            <div class="duplicate-item">

                                <div class="item-main">

                                    <span class="evidence-code">

                                        <%= item.getEvidenceCode() %>

                                    </span>

                                    <strong>

                                        <%= item.getFileName() %>

                                    </strong>

                                    <small>

                                        <%= item.getFilePath() %>

                                    </small>

                                </div>

                                <div class="item-details">

                                    <span>

                                        Case:
                                        <strong>
                                            <%= item.getCaseCode() %>
                                        </strong>

                                    </span>

                                    <span>

                                        Size:
                                        <strong>
                                            <%= item.getFormattedSize() %>
                                        </strong>

                                    </span>

                                    <span>

                                        Integrity:

                                        <b class="integrity-ok">

                                            <%= item.getIntegrityStatus() == null
                                                    ? "NOT CHECKED"
                                                    : item.getIntegrityStatus().replace('_', ' ') %>

                                        </b>

                                    </span>

                                </div>

                            </div>

                            <% } %>

                        </div>

                    </article>

                    <% } %>

                </div>

            <% } %>

        </section>

        <footer>

            Academic prototype • Hash-based technical comparison only
            • Not a legal forensic conclusion

        </footer>

    </main>

</div>

</body>

</html>
