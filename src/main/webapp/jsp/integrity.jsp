
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.IntegrityServlet.IntegrityRecord" %>

<%
    List<IntegrityRecord> records =
            (List<IntegrityRecord>) request.getAttribute("records");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Integrity - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/integrity.css">
</head>

<body>

<div class="app">

    <aside class="sidebar">

        <div class="brand">
            <span class="brand-mark">DE</span>
            <div>
                <strong>Digital Evidence</strong>
                <small>Analyzer</small>
            </div>
        </div>

        <!-- SIDEBAR NAVIGATION -->

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

            <a href="${pageContext.request.contextPath}/duplicates">
                ◫ Duplicates
            </a>

            <a href="${pageContext.request.contextPath}/indicators">
                ⚠ Indicators
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/integrity">
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


    <main class="content">

        <header>

            <div>

                <p class="eyebrow">
                    EVIDENCE INTEGRITY
                </p>

                <h1>
                    Integrity Verification
                </h1>

                <p class="muted">
                    Compare registered SHA-256 hashes with the current file state.
                </p>

            </div>

        </header>


        <div class="info-box">

            <strong>How integrity verification works</strong>

            <p>
                The system recalculates the SHA-256 hash of every registered
                evidence file and compares it with the hash captured during
                registration.
            </p>

        </div>


        <section class="panel">

            <div class="panel-head">

                <div>
                    <h2>Evidence Integrity Records</h2>
                    <p>
                        Current integrity status of registered evidence.
                    </p>
                </div>

                <span class="record-count">
                    <%= records == null ? 0 : records.size() %> records
                </span>

            </div>


            <div class="table-wrapper">

                <% if (records == null || records.isEmpty()) { %>

                    <div class="empty">

                        <div class="empty-icon">⌁</div>

                        <h3>No evidence registered</h3>

                        <p>
                            Register evidence first to perform integrity verification.
                        </p>

                        <a class="primary button-link"
                           href="${pageContext.request.contextPath}/evidence">
                            Register Evidence
                        </a>

                    </div>

                <% } else { %>

                    <table>

                        <thead>

                        <tr>

                            <th>Evidence ID</th>
                            <th>File Name</th>
                            <th>Registered SHA-256</th>
                            <th>Current SHA-256</th>
                            <th>Status</th>
                            <th>Registered</th>

                        </tr>

                        </thead>

                        <tbody>

                        <% for (IntegrityRecord record : records) { %>

                        <tr>

                            <td>
                                <strong>
                                    <%= record.getEvidenceCode() %>
                                </strong>
                            </td>

                            <td>
                                <%= record.getFileName() %>
                            </td>

                            <td>
                                <code>
                                    <%= record.getRegisteredSha256() %>
                                </code>
                            </td>

                            <td>
                                <code>
                                    <%= record.getCurrentSha256() %>
                                </code>
                            </td>

                            <td>

                                <% if ("VERIFIED".equals(record.getIntegrityStatus())) { %>

                                    <span class="status verified">
                                        VERIFIED
                                    </span>

                                <% } else if ("HASH_MISMATCH".equals(record.getIntegrityStatus())) { %>

                                    <span class="status mismatch">
                                        HASH MISMATCH
                                    </span>

                                <% } else { %>

                                    <span class="status unchecked">
                                        NOT CHECKED
                                    </span>

                                <% } %>

                            </td>

                            <td>
                                <%= record.getRegisteredAt() %>
                            </td>

                        </tr>

                        <% } %>

                        </tbody>

                    </table>

                <% } %>

            </div>

        </section>


        <footer>
            Academic prototype • Technical integrity analysis only •
            Not a legal forensic conclusion
        </footer>

    </main>

</div>

</body>
</html>
