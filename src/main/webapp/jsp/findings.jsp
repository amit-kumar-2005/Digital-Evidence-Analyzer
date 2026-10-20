<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.FindingServlet.FindingRecord" %>
<%@ page import="com.digitalforensics.model.User" %>

<%
    List<FindingRecord> findings =
            (List<FindingRecord>) request.getAttribute("findings");

    Boolean dbConnected =
            (Boolean) request.getAttribute("dbConnected");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    User currentUser = (User) session.getAttribute("currentUser");

    boolean canReview = currentUser != null
            && ("ADMIN".equalsIgnoreCase(currentUser.getRole())
            || "INVESTIGATOR".equalsIgnoreCase(currentUser.getRole()));

    String reviewMessage = request.getParameter("review");

    if (findings == null) {
        findings = java.util.Collections.emptyList();
    }

    int totalFindings = findings.size();

    int verifiedCount = 0;
    int mismatchCount = 0;
    int observedCount = 0;
    int reviewCount = 0;

    for (FindingRecord finding : findings) {

        if ("VERIFIED".equalsIgnoreCase(
                finding.getTechnicalStatus())) {
            verifiedCount++;
        }

        if ("HASH MISMATCH".equalsIgnoreCase(
                finding.getTechnicalStatus())) {
            mismatchCount++;
        }

        if ("OBSERVED".equalsIgnoreCase(
                finding.getTechnicalStatus())) {
            observedCount++;
        }

        if ("UNDER REVIEW".equalsIgnoreCase(
                finding.getReviewStatus())) {
            reviewCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Findings - Digital Evidence Analyzer
    </title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/findings.css">

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

            <a href="${pageContext.request.contextPath}/relationships">
                ⛓ Relationships
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/findings">
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
                    INVESTIGATION / FINDINGS
                </div>

                <h1>Investigation Findings</h1>

                <p>
                    Review and organize technical observations
                    generated from registered digital evidence.
                </p>

            </div>

        </header>


        <!-- ================= STATUS ================= -->

        <% if (Boolean.TRUE.equals(dbConnected)) { %>

            <div class="success-message">
                ✓ Investigation findings loaded successfully.
            </div>

        <% } else { %>

            <div class="error-message">

                ⚠

                <%= errorMessage != null
                        ? errorMessage
                        : "Unable to load investigation findings." %>

            </div>

        <% } %>

        <% if ("saved".equals(reviewMessage)) { %>
            <div class="success-message">
                ✓ Finding review updated successfully.
            </div>
        <% } %>

        <!-- ================= INFORMATION ================= -->

        <section class="info-card">

            <div class="info-icon">
                ✓
            </div>

            <div>

                <strong>
                    Technical Findings Review
                </strong>

                <p>
                    Findings summarize technical observations
                    from evidence metadata, cryptographic hashes
                    and integrity analysis. Each observation is
                    marked for investigation review.
                </p>

            </div>

        </section>


        <!-- ================= STATISTICS ================= -->

        <section class="stats-grid">

            <div class="stat-card">

                <span class="stat-label">
                    TOTAL FINDINGS
                </span>

                <strong>
                    <%= totalFindings %>
                </strong>

                <small>
                    Technical observations
                </small>

            </div>


            <div class="stat-card">

                <span class="stat-label">
                    VERIFIED
                </span>

                <strong>
                    <%= verifiedCount %>
                </strong>

                <small>
                    Integrity observations
                </small>

            </div>


            <div class="stat-card">

                <span class="stat-label">
                    OBSERVED
                </span>

                <strong>
                    <%= observedCount %>
                </strong>

                <small>
                    Metadata/hash records
                </small>

            </div>


            <div class="stat-card">

                <span class="stat-label">
                    UNDER REVIEW
                </span>

                <strong>
                    <%= reviewCount %>
                </strong>

                <small>
                    Findings requiring review
                </small>

            </div>

        </section>


        <!-- ================= FINDINGS ================= -->

        <section class="findings-card">

            <div class="section-header">

                <div>

                    <h2>
                        Technical Findings
                    </h2>

                    <p>
                        Evidence-linked observations available
                        for investigation review.
                    </p>

                </div>

                <span class="record-count">
                    <%= totalFindings %> findings
                </span>

            </div>


            <% if (findings.isEmpty()) { %>

                <div class="empty-state">

                    <div class="empty-icon">
                        ✓
                    </div>

                    <h3>
                        No findings available
                    </h3>

                    <p>
                        Findings will appear after evidence
                        analysis has generated technical observations.
                    </p>

                    <a href="${pageContext.request.contextPath}/evidence"
                       class="primary-button">
                        Register Evidence
                    </a>

                </div>

            <% } else { %>


                <div class="findings-list">

                    <% for (FindingRecord finding : findings) {

                        String statusClass =
                                finding.getTechnicalStatus()
                                       .toLowerCase()
                                       .replace(" ", "-");

                    %>


                    <article class="finding-item">

                        <div class="finding-header">

                            <div class="finding-title">

                                <span class="finding-id">
                                    <%= finding.getFindingId() %>
                                </span>

                                <h3>
                                    <%= finding.getFindingType() %>
                                </h3>

                            </div>


                            <span class="review-badge">
                                <%= finding.getReviewStatus() %>
                            </span>

                        </div>

                        <% if (canReview) { %>

                            <form method="post"
                                  action="${pageContext.request.contextPath}/findings"
                                  class="finding-review-form">

                                <input type="hidden"
                                       name="evidenceId"
                                       value="<%= finding.getEvidenceId() %>">

                                <input type="hidden"
                                       name="reviewKey"
                                       value="<%= finding.getReviewKey() %>">

                                <label>
                                    Review Status
                                    <select name="reviewStatus" required>
                                        <option value="UNDER REVIEW"
                                            <%= "UNDER REVIEW".equals(finding.getReviewStatus())
                                                    ? "selected" : "" %>>
                                            Under Review
                                        </option>

                                        <option value="VERIFIED"
                                            <%= "VERIFIED".equals(finding.getReviewStatus())
                                                    ? "selected" : "" %>>
                                            Verified
                                        </option>

                                        <option value="REJECTED"
                                            <%= "REJECTED".equals(finding.getReviewStatus())
                                                    ? "selected" : "" %>>
                                            Rejected
                                        </option>
                                    </select>
                                </label>

                                <label>
                                    Review Comment
                                    <textarea name="reviewComment"
                                              maxlength="1000"
                                              rows="2"
                                              placeholder="Enter review remarks"><%= finding.getReviewComment() == null
                                                      ? "" : finding.getReviewComment() %></textarea>
                                </label>

                                <button type="submit" class="primary-button">
                                    Save Review
                                </button>

                            </form>

                        <% } else { %>

                            <p class="review-readonly-note">
                                Read-only access: only Admin and Investigator
                                can update finding reviews.
                            </p>

                        <% } %>

                        <div class="finding-grid">

                            <!-- Evidence -->

                            <div class="detail-box">

                                <span>
                                    EVIDENCE
                                </span>

                                <strong>
                                    <%= finding.getEvidenceCode() %>
                                </strong>

                                <small>
                                    <%= finding.getFileName() %>
                                </small>

                            </div>


                            <!-- Case -->

                            <div class="detail-box">

                                <span>
                                    CASE
                                </span>

                                <strong>
                                    <%= finding.getCaseCode() %>
                                </strong>

                                <small>
                                    <%= finding.getCaseName() %>
                                </small>

                            </div>


                            <!-- Technical Status -->

                            <div class="detail-box">

                                <span>
                                    TECHNICAL STATUS
                                </span>

                                <strong class="status
                                    <%= statusClass %>">

                                    <%= finding.getTechnicalStatus() %>

                                </strong>

                            </div>

                        </div>


                        <!-- Observation -->

                        <div class="observation-box">

                            <span>
                                TECHNICAL OBSERVATION
                            </span>

                            <p>
                                <%= finding.getObservation() %>
                            </p>

                        </div>

                    </article>


                    <% } %>

                </div>

            <% } %>

        </section>


        <!-- ================= REVIEW LEGEND ================= -->

        <section class="legend-card">

            <h3>
                Finding Status
            </h3>

            <div class="legend-grid">

                <div class="legend-item">

                    <span class="legend-dot verified"></span>

                    <div>

                        <strong>
                            Verified
                        </strong>

                        <small>
                            Technical integrity comparison
                            matched.
                        </small>

                    </div>

                </div>


                <div class="legend-item">

                    <span class="legend-dot observed"></span>

                    <div>

                        <strong>
                            Observed
                        </strong>

                        <small>
                            Technical metadata or hash information
                            is available.
                        </small>

                    </div>

                </div>


                <div class="legend-item">

                    <span class="legend-dot mismatch"></span>

                    <div>

                        <strong>
                            Hash Mismatch
                        </strong>

                        <small>
                            Current and registered hashes differ.
                        </small>

                    </div>

                </div>


                <div class="legend-item">

                    <span class="legend-dot review"></span>

                    <div>

                        <strong>
                            Under Review
                        </strong>

                        <small>
                            Finding requires investigator review.
                        </small>

                    </div>

                </div>

            </div>

        </section>


        <!-- ================= TECHNICAL NOTE ================= -->

        <div class="technical-note">

            <strong>
                Technical Findings
            </strong>

            <span>
                Findings represent application-generated technical
                observations. They are not legal conclusions,
                malware verdicts or independent proof of user activity.
            </span>

        </div>

    </main>

</div>

</body>
</html>