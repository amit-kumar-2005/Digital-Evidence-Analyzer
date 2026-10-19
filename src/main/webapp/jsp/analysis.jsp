
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.AnalysisServlet.AnalysisRecord" %>

<%
    List<AnalysisRecord> records =
            (List<AnalysisRecord>) request.getAttribute("analysisRecords");
%>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>Analysis - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/analysis.css">

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

            <a class="active"
               href="${pageContext.request.contextPath}/analysis">
                ⌕ Analysis <span>›</span>
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
                    TECHNICAL EVIDENCE ANALYSIS
                </p>

                <h1>
                    Analysis
                </h1>

                <p class="muted">
                    Inspect technical properties and calculated evidence hashes.
                </p>

            </div>

        </header>


        <!-- INFORMATION PANEL -->

        <section class="analysis-info">

            <div class="info-icon">
                ⌕
            </div>

            <div>

                <h3>
                    Automated Technical Analysis
                </h3>

                <p>
                    Registered evidence is analyzed using file metadata,
                    file type information, timestamps and cryptographic hashes.
                    The analysis provides technical observations only.
                </p>

            </div>

        </section>


        <!-- SUMMARY -->

        <section class="cards analysis-cards">

            <div class="card">

                <span>REGISTERED EVIDENCE</span>

                <strong>
                    <%= records == null ? 0 : records.size() %>
                </strong>

                <small>
                    Evidence available for analysis
                </small>

            </div>


            <div class="card">

                <span>SHA-256</span>

                <strong>
                    <%= records == null ? 0 : records.size() %>
                </strong>

                <small>
                    Cryptographic hash records
                </small>

            </div>


            <div class="card">

                <span>MD5</span>

                <strong>
                    <%= records == null ? 0 : records.size() %>
                </strong>

                <small>
                    Hash values available
                </small>

            </div>


            <div class="card">

                <span>INTEGRITY</span>

                <strong>
                    <%= records == null ? 0 : records.size() %>
                </strong>

                <small>
                    Evidence integrity records
                </small>

            </div>

        </section>


        <!-- ANALYSIS RECORDS -->

        <section class="panel analysis-panel">

            <div class="panel-head">

                <div>

                    <h2>
                        Evidence Analysis Records
                    </h2>

                    <p class="panel-subtitle">
                        Detailed technical information for registered evidence.
                    </p>

                </div>

                <span class="record-count">
                    <%= records == null ? 0 : records.size() %> records
                </span>

            </div>


            <% if (records == null || records.isEmpty()) { %>

                <div class="empty">

                    <div class="empty-icon">
                        ⌁
                    </div>

                    <h3>
                        No evidence available
                    </h3>

                    <p>
                        Register evidence first to perform technical analysis.
                    </p>

                    <a class="primary button-link"
                       href="${pageContext.request.contextPath}/evidence">
                        Register Evidence
                    </a>

                </div>

            <% } else { %>


                <div class="analysis-list">

                    <% for (AnalysisRecord r : records) { %>

                    <article class="analysis-record">


                        <!-- RECORD HEADER -->

                        <div class="analysis-record-header">

                            <div>

                                <span class="evidence-id">
                                    <%= r.getEvidenceCode() %>
                                </span>

                                <h3>
                                    <%= r.getFileName() %>
                                </h3>

                                <p>
                                    Case:
                                    <strong>
                                        <%= r.getCaseCode() %>
                                    </strong>

                                    —
                                    <%= r.getCaseName() %>
                                </p>

                            </div>


                            <div>

                                <span class="status verified">
                                    ANALYSIS COMPLETE
                                </span>

                            </div>

                        </div>


                        <!-- FILE INFORMATION -->

                        <div class="analysis-section">

                            <h4>
                                File Information
                            </h4>

                            <div class="detail-grid">

                                <div>
                                    <label>File Name</label>
                                    <span>
                                        <%= r.getFileName() %>
                                    </span>
                                </div>

                                <div>
                                    <label>File Type</label>
                                    <span>
                                        <%= r.getFileType() == null
                                                ? "—"
                                                : r.getFileType() %>
                                    </span>
                                </div>

                                <div>
                                    <label>File Size</label>
                                    <span>
                                        <%= r.getFormattedSize() %>
                                    </span>
                                </div>

                                <div class="wide">

                                    <label>File Path</label>

                                    <span class="path-value">
                                        <%= r.getFilePath() %>
                                    </span>

                                </div>

                            </div>

                        </div>


                        <!-- TIMESTAMP INFORMATION -->

                        <div class="analysis-section">

                            <h4>
                                File Timestamps
                            </h4>

                            <div class="detail-grid">

                                <div>

                                    <label>Created</label>

                                    <span>
                                        <%= r.getCreatedTime() == null
                                                ? "—"
                                                : r.getCreatedTime() %>
                                    </span>

                                </div>

                                <div>

                                    <label>Modified</label>

                                    <span>
                                        <%= r.getModifiedTime() == null
                                                ? "—"
                                                : r.getModifiedTime() %>
                                    </span>

                                </div>

                                <div>

                                    <label>Accessed</label>

                                    <span>
                                        <%= r.getAccessedTime() == null
                                                ? "—"
                                                : r.getAccessedTime() %>
                                    </span>

                                </div>

                                <div>

                                    <label>Registered</label>

                                    <span>
                                        <%= r.getRegisteredAt() == null
                                                ? "—"
                                                : r.getRegisteredAt() %>
                                    </span>

                                </div>

                            </div>

                        </div>


                        <!-- HASH INFORMATION -->

                        <div class="analysis-section">

                            <h4>
                                Cryptographic Hashes
                            </h4>

                            <div class="hash-grid">

                                <div class="hash-box">

                                    <label>
                                        MD5
                                    </label>

                                    <code>
                                        <%= r.getMd5() == null
                                                ? "Not available"
                                                : r.getMd5() %>
                                    </code>

                                </div>


                                <div class="hash-box">

                                    <label>
                                        Registered SHA-256
                                    </label>

                                    <code title="<%= r.getRegisteredSha256() %>">
                                        <%= r.getShortHash(
                                                r.getRegisteredSha256()) %>
                                    </code>

                                </div>


                                <div class="hash-box">

                                    <label>
                                        Current SHA-256
                                    </label>

                                    <code title="<%= r.getCurrentSha256() %>">
                                        <%= r.getShortHash(
                                                r.getCurrentSha256()) %>
                                    </code>

                                </div>

                            </div>

                        </div>


                        <!-- INTEGRITY -->

                        <div class="analysis-integrity">

                            <span>
                                Integrity Status
                            </span>

                            <strong class="status verified">

                                <%= r.getIntegrityStatus() == null
                                        ? "NOT CHECKED"
                                        : r.getIntegrityStatus().replace('_', ' ') %>

                            </strong>

                            <a href="${pageContext.request.contextPath}/integrity">
                                View Integrity Details →
                            </a>

                        </div>


                    </article>

                    <% } %>

                </div>

            <% } %>

        </section>


        <footer>
            Academic prototype • Technical analysis only • Not a legal forensic conclusion
        </footer>

    </main>

</div>

</body>
</html>
