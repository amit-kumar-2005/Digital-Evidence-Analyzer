
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.model.InvestigationCase" %>
<%
    List<InvestigationCase> cases = (List<InvestigationCase>) request.getAttribute("cases");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Cases - Digital Evidence Analyzer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
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
            <a href="${pageContext.request.contextPath}/dashboard">▣ Dashboard</a>
            <a class="active" href="${pageContext.request.contextPath}/cases">▣ Cases</a>
            <a href="${pageContext.request.contextPath}/evidence">▤ Evidence</a>
            <a href="${pageContext.request.contextPath}/analysis">⌕ Analysis</a>
            <a href="${pageContext.request.contextPath}/timeline">◷ Timeline</a>
            <a href="${pageContext.request.contextPath}/duplicates">◫ Duplicates</a>
            <a href="${pageContext.request.contextPath}/indicators">⚠ Indicators</a>
            <a href="${pageContext.request.contextPath}/integrity">⌑ Integrity</a>
            <a href="${pageContext.request.contextPath}/relationships">⌘ Relationships</a>
            <a href="${pageContext.request.contextPath}/findings">☷ Findings</a>
            <a href="${pageContext.request.contextPath}/audit-log">
    ≡ Audit Log
</a>
            <a href="${pageContext.request.contextPath}/reports">▥ Reports</a>
            <a href="${pageContext.request.contextPath}/settings">⚙ Settings</a>
        </nav>
    </aside>

    <main class="content">
        <header>
            <div>
                <p class="eyebrow">INVESTIGATION MANAGEMENT</p>
                <h1>Cases</h1>
                <p class="muted">Create and manage investigation cases.</p>
            </div>
            <a class="primary button-link" href="#new-case">+ New Case</a>
        </header>

        <% if (request.getParameter("created") != null) { %>
            <div class="alert success">Investigation case created successfully.</div>
        <% } %>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert error"><%= request.getParameter("error") %></div>
        <% } %>

        <section class="panel form-panel" id="new-case">
            <div class="panel-head">
                <h2>Create Investigation Case</h2>
            </div>
            <form class="case-form" method="post" action="${pageContext.request.contextPath}/cases">
                <label>
                    Case Name
                    <input name="caseName" maxlength="180" placeholder="e.g. Laptop Evidence Review" required>
                </label>
                <label>
                    Description
                    <textarea name="description" rows="4" maxlength="2000" placeholder="Purpose and scope of this investigation..."></textarea>
                </label>
                <button class="primary" type="submit">Create Case</button>
            </form>
        </section>

        <section class="panel table-panel">
            <div class="panel-head">
                <h2>Investigation Cases</h2>
                <span class="muted"><%= cases == null ? 0 : cases.size() %> records</span>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Case ID</th>
                            <th>Case Name</th>
                            <th>Status</th>
                            <th>Created By</th>
                            <th>Created</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (cases == null || cases.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="table-empty">No investigation cases found.</td>
                            </tr>
                        <% } else {
                            for (InvestigationCase c : cases) { %>
                                <tr>
                                    <td><strong><%= c.getCaseCode() %></strong></td>
                                    <td><%= c.getCaseName() %></td>
                                    <td>
                                        <span class="status <%= c.getStatus().toLowerCase() %>">
                                            <%= c.getStatus().replace('_', ' ') %>
                                        </span>
                                    </td>
                                    <td><%= c.getCreatedByName() %></td>
                                    <td><%= c.getCreatedAt() %></td>
                                </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>
        </section>

        <footer>Academic prototype • Technical indicators only • Not a legal forensic conclusion</footer>
    </main>
</div>
</body>
</html>
