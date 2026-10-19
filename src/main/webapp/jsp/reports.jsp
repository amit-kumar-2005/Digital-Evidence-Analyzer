<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.ReportServlet.ReportRecord" %>

<%
    List<ReportRecord> reports =
        (List<ReportRecord>) request.getAttribute("reports");

    Boolean dbConnected =
        (Boolean) request.getAttribute("dbConnected");

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    int totalCases = reports == null ? 0 : reports.size();
    int totalEvidence = 0;
    int totalVerified = 0;
    int totalMismatches = 0;

    if (reports != null) {
        for (ReportRecord r : reports) {
            totalEvidence += r.getEvidenceCount();
            totalVerified += r.getVerifiedCount();
            totalMismatches += r.getMismatchCount();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - Digital Evidence Analyzer</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/reports.css">
</head>
<body>

<div class="app-shell">

    <aside class="sidebar">
        <div class="brand">
            <div class="brand-icon">DE</div>
            <div>
                <div class="brand-title">Digital Evidence</div>
                <div class="brand-subtitle">Analyzer</div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard">▣ Dashboard</a>
            <a href="${pageContext.request.contextPath}/cases">◈ Cases</a>
            <a href="${pageContext.request.contextPath}/evidence">◇ Evidence</a>
            <a href="${pageContext.request.contextPath}/analysis">◌ Analysis</a>
            <a href="${pageContext.request.contextPath}/timeline">◷ Timeline</a>
            <a href="${pageContext.request.contextPath}/duplicates">◫ Duplicates</a>
            <a href="${pageContext.request.contextPath}/indicators">⚠ Indicators</a>
            <a href="${pageContext.request.contextPath}/integrity">⌑ Integrity</a>
            <a href="${pageContext.request.contextPath}/relationships">⚯ Relationships</a>
            <a href="${pageContext.request.contextPath}/findings">≡ Findings</a>
            <a href="${pageContext.request.contextPath}/audit-log">≣ Audit Log</a>
            <a class="active" href="${pageContext.request.contextPath}/reports">▤ Reports</a>
            <a href="${pageContext.request.contextPath}/settings">⚙ Settings</a>
        </nav>

        <div class="sidebar-bottom">
            <a href="${pageContext.request.contextPath}/logout">↪ Sign out</a>
        </div>
    </aside>

    <main class="main-content">

        <header class="page-header">
            <div>
                <div class="breadcrumb">INVESTIGATION / REPORTS</div>
                <h1>Investigation Reports</h1>
                <p>Review case summaries and evidence integrity results.</p>
            </div>

            <button class="primary-button" onclick="window.print()">
                Print Report
            </button>
        </header>

        <% if (Boolean.TRUE.equals(dbConnected)) { %>
            <div class="success-message">
                ✓ Investigation report data loaded successfully.
            </div>
        <% } else { %>
            <div class="error-message">
                ✕ <%= errorMessage != null ? errorMessage :
                    "Unable to connect to the database." %>
            </div>
        <% } %>

        <section class="info-card">
            <div class="info-icon">R</div>
            <div>
                <h3>Investigation Summary</h3>
                <p>
                    This report summarizes registered cases, associated
                    evidence records and their latest stored integrity status.
                    It presents technical information and does not make
                    legal conclusions.
                </p>
            </div>
        </section>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">TOTAL CASES</div>
                <div class="stat-value"><%= totalCases %></div>
                <div class="stat-description">Investigation records</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">EVIDENCE ITEMS</div>
                <div class="stat-value"><%= totalEvidence %></div>
                <div class="stat-description">Registered evidence files</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">VERIFIED ITEMS</div>
                <div class="stat-value"><%= totalVerified %></div>
                <div class="stat-description">Latest stored status is verified</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">HASH MISMATCHES</div>
                <div class="stat-value"><%= totalMismatches %></div>
                <div class="stat-description">Require investigation</div>
            </div>
        </section>

        <section class="report-section">
            <div class="section-header">
                <div>
                    <h2>Case Report Summary</h2>
                    <p>Choose a case to review its investigation summary.</p>
                </div>
                <span class="record-count"><%= totalCases %> cases</span>
            </div>

            <% if (reports != null && !reports.isEmpty()) { %>

                <div class="table-wrapper">
                    <table>
                        <thead>
                        <tr>
                            <th>CASE ID</th>
                            <th>CASE NAME</th>
                            <th>STATUS</th>
                            <th>EVIDENCE</th>
                            <th>VERIFIED</th>
                            <th>MISMATCH</th>
                            <th>CREATED</th>
                            <th>REPORT</th>
                        </tr>
                        </thead>

                        <tbody>
                        <% for (ReportRecord r : reports) { %>
                            <tr>
                                <td>
                                    <strong><%= r.getCaseCode() %></strong>
                                </td>
                                <td>
                                    <strong><%= r.getCaseName() %></strong>
                                    <small>
                                        <%= r.getDescription() == null ||
                                            r.getDescription().isBlank()
                                            ? "No description provided"
                                            : r.getDescription() %>
                                    </small>
                                </td>
                                <td>
                                    <span class="status-badge">
                                        <%= r.getStatus() %>
                                    </span>
                                </td>
                                <td><%= r.getEvidenceCount() %></td>
                                <td>
                                    <span class="verified-number">
                                        <%= r.getVerifiedCount() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="mismatch-number">
                                        <%= r.getMismatchCount() %>
                                    </span>
                                </td>
                                <td><%= r.getCreatedAt() %></td>
                                <td>
                                    <button class="small-button"
                                            onclick="window.print()">
                                        Print
                                    </button>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } else { %>

                <div class="empty-state">
                    <div class="empty-icon">R</div>
                    <h3>No Case Reports Available</h3>
                    <p>Create an investigation case to generate a summary.</p>
                </div>

            <% } %>
        </section>

        <div class="report-note">
            <strong>Report limitations:</strong>
            Counts reflect the latest stored database status. Review the
            Integrity and Findings modules before using these details in an
            investigation summary. This page currently supports browser
            printing; PDF export can be added separately.
        </div>

    </main>
</div>

</body>
</html>
