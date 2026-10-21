
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.EvidenceServlet.CaseOption" %>
<%@ page import="com.digitalforensics.controller.EvidenceServlet.EvidenceRecord" %>
<%@ page import="com.digitalforensics.model.User" %>

<%
    List<CaseOption> cases =
            (List<CaseOption>) request.getAttribute("cases");

    List<EvidenceRecord> evidenceList =
            (List<EvidenceRecord>) request.getAttribute("evidenceList");

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser == null ? "" : currentUser.getRole();

    boolean canRegisterEvidence =
            "ADMIN".equalsIgnoreCase(role)
            || "INVESTIGATOR".equalsIgnoreCase(role);
%>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>Evidence - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/evidence.css">

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

        <nav>

            <a href="${pageContext.request.contextPath}/dashboard">
                ▣ Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/cases">
                ▣ Cases <span>›</span>
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/evidence">
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

    <main class="content">

        <header>

            <div>

                <p class="eyebrow">
                    EVIDENCE MANAGEMENT
                </p>

                <h1>Evidence</h1>

                <p class="muted">
                    Register, hash and monitor digital evidence.
                </p>

            </div>

        </header>


        <% if (success != null) { %>

            <div class="alert success">
                <%= success %>
            </div>

        <% } %>


        <% if (error != null) { %>

            <div class="alert error">
                <%= error %>
            </div>

        <% } %>


        <% if (canRegisterEvidence) { %>

        <section class="panel evidence-form-panel">

            <div class="panel-head">

                <div>

                    <h2>Register Evidence</h2>

                    <p class="muted">
                        Register a file against an investigation case.
                    </p>

                </div>

            </div>


            <form method="post"
                  action="${pageContext.request.contextPath}/evidence"
                  class="evidence-form">


                <div class="form-group">

                    <label for="caseId">
                        Investigation Case
                    </label>

                    <select id="caseId"
                            name="caseId"
                            required>

                        <option value="">
                            Select investigation case
                        </option>

                        <% if (cases != null) {
                            for (CaseOption c : cases) { %>

                            <option value="<%= c.getId() %>">
    <%= c.getCaseCode() %> -
    <%= c.getCaseName() %>
</option>

                        <% }
                        } %>

                    </select>

                </div>


                <div class="form-group">

                    <label for="filePath">
                        Evidence File Path
                    </label>

                    <input
                        type="text"
                        id="filePath"
                        name="filePath"
                        placeholder="Example: C:\Evidence\sample.txt"
                        required>

                    <small>
                        Enter the path of a file accessible by the
                        application server.
                    </small>

                </div>


                <div class="info-box">

                    <strong>Automatic Analysis</strong>

                    <p>
                        During registration the system automatically
                        calculates SHA-256 and MD5 hashes and reads
                        basic file metadata.
                    </p>

                </div>


                <button type="submit"
                        class="primary evidence-submit">

                    Register Evidence

                </button>

            </form>

        </section>

        <% } else { %>

            <div class="alert">
                Read-only access: only Admin and Investigator can register evidence.
            </div>

        <% } %>


        <section class="panel">

            <div class="panel-head">

                <h2>Registered Evidence</h2>

                <span class="record-count">
                    <%= evidenceList == null ? 0 : evidenceList.size() %>
                    records
                </span>

            </div>


            <% if (evidenceList == null || evidenceList.isEmpty()) { %>

                <div class="empty">

                    <div class="empty-icon">⌁</div>

                    <h3>No evidence registered</h3>

                    <p>
                        Register your first evidence file to begin
                        digital evidence analysis.
                    </p>

                </div>

            <% } else { %>

                <div class="table-wrapper">

                    <table class="evidence-table">

                        <thead>

                        <tr>

                            <th>Evidence ID</th>
                            <th>Case</th>
                            <th>File Name</th>
                            <th>Type</th>
                            <th>Size</th>
                            <th>Integrity</th>
                            <th>SHA-256</th>
                            <th>Registered</th>

                        </tr>

                        </thead>

                        <tbody>

                        <% for (EvidenceRecord e : evidenceList) { %>

                        <tr>

                            <td>
                                <strong>
                                    <%= e.getEvidenceCode() %>
                                </strong>
                            </td>

                            <td>
                                <%= e.getCaseCode() %>
                            </td>

                            <td>
                                <%= e.getFileName() %>
                            </td>

                            <td>
                                <%= e.getFileType() %>
                            </td>

                            <td>
                                <%= e.getFileSize() %> bytes
                            </td>

                            <td>

                                <span class="integrity verified">
                                    <%= e.getIntegrityStatus() %>
                                </span>

                            </td>

                            <td>

                                <code class="hash">
                                    <%= e.getSha256() %>
                                </code>

                            </td>

                            <td>
                                <%= e.getRegisteredAt() %>
                            </td>

                        </tr>

                        <% } %>

                        </tbody>

                    </table>

                </div>

            <% } %>

        </section>


        <footer>
            Academic prototype • Technical indicators only •
            Not a legal forensic conclusion
        </footer>

    </main>

</div>

</body>
</html>
