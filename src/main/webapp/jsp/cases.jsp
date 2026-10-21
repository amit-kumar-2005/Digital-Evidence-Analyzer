
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.model.InvestigationCase" %>
<%@ page import="com.digitalforensics.model.User" %>
<%
    List<InvestigationCase> cases =
            (List<InvestigationCase>) request.getAttribute("cases");

    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser == null ? "" : currentUser.getRole();

    boolean canCreateCase =
            "ADMIN".equalsIgnoreCase(role)
            || "INVESTIGATOR".equalsIgnoreCase(role);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cases - Digital Evidence Analyzer</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">
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
            <a href="${pageContext.request.contextPath}/dashboard">&#9635; Dashboard</a>
            <a class="active" href="${pageContext.request.contextPath}/cases">&#9635; Cases</a>
            <a href="${pageContext.request.contextPath}/evidence">&#9634; Evidence</a>
            <a href="${pageContext.request.contextPath}/analysis">&#9881; Analysis</a>
            <a href="${pageContext.request.contextPath}/timeline">&#9719; Timeline</a>
            <a href="${pageContext.request.contextPath}/duplicates">&#9678; Duplicates</a>
            <a href="${pageContext.request.contextPath}/indicators">&#9888; Indicators</a>
            <a href="${pageContext.request.contextPath}/integrity">&#9878; Integrity</a>
            <a href="${pageContext.request.contextPath}/relationships">&#8644; Relationships</a>
            <a href="${pageContext.request.contextPath}/findings">&#10003; Findings</a>
            <a href="${pageContext.request.contextPath}/audit-log">&#9776; Audit Log</a>
            <a href="${pageContext.request.contextPath}/reports">&#9638; Reports</a>
            <a href="${pageContext.request.contextPath}/settings">&#9881; Settings</a>
        </nav>
    </aside>

    <main class="content">
        <header>
            <div>
                <p class="eyebrow">INVESTIGATION MANAGEMENT</p>
                <h1>Cases</h1>
                <p class="muted">Create and manage investigation cases.</p>
            </div>

            <% if (canCreateCase) { %>
                <a class="primary button-link"
                   href="#new-case">+ New Case</a>
            <% } %>
        </header>

        <% if (request.getParameter("created") != null) { %>
            <div class="alert success">
                Investigation case created successfully.
            </div>
        <% } %>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert error">
                <%= request.getParameter("error") %>
            </div>
        <% } %>

        <% if (canCreateCase) { %>
            <section class="panel form-panel" id="new-case">
                <div class="panel-head">
                    <h2>Create Investigation Case</h2>
                </div>

                <form class="case-form"
                      method="post"
                      action="${pageContext.request.contextPath}/cases">

                    <label>
                        Case Name
                        <input name="caseName"
                               maxlength="180"
                               placeholder="e.g. Laptop Evidence Review"
                               required>
                    </label>

                    <label>
                        Description
                        <textarea name="description"
                                  rows="4"
                                  maxlength="2000"
                                  placeholder="Purpose and scope of this investigation..."></textarea>
                    </label>

                    <button class="primary" type="submit">
                        Create Case
                    </button>
                </form>
            </section>
        <% } else { %>
            <div class="alert">
                Read-only access: only Admin and Investigator can create cases.
            </div>
        <% } %>

        <section class="panel table-panel">
            <div class="panel-head">
                <h2>Investigation Cases</h2>
                <span class="muted">
                    <%= cases == null ? 0 : cases.size() %> records
                </span>
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
                                <td colspan="5" class="table-empty">
                                    No investigation cases found.
                                </td>
                            </tr>
                        <% } else {
                            for (InvestigationCase c : cases) { %>
                                <tr>
                                    <td>
                                        <strong><%= c.getCaseCode() %></strong>
                                    </td>
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

        <footer>
            Academic prototype &#8226; Technical indicators only &#8226; Not a legal forensic conclusion
        </footer>
    </main>
</div>
</body>
</html>
