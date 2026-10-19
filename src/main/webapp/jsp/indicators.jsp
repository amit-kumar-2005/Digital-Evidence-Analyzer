
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.controller.IndicatorServlet.IndicatorRecord" %>

<%
    List<IndicatorRecord> indicators =
            (List<IndicatorRecord>) request.getAttribute("indicators");

    if (indicators == null) {
        indicators = java.util.Collections.emptyList();
    }

    int highCount = 0;
    int mediumCount = 0;
    int lowCount = 0;

    for (IndicatorRecord item : indicators) {
        if ("HIGH".equalsIgnoreCase(item.getSeverity())) {
            highCount++;
        } else if ("MEDIUM".equalsIgnoreCase(item.getSeverity())) {
            mediumCount++;
        } else {
            lowCount++;
        }
    }
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>Indicators - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/indicators.css">

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

        <a class="active"
           href="${pageContext.request.contextPath}/indicators">
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
            TECHNICAL INDICATOR ANALYSIS
        </p>

        <h1>
            Suspicious Indicators
        </h1>

        <p class="muted">
            Review predefined technical indicators identified in registered evidence.
        </p>

    </div>

</header>


<% if (Boolean.TRUE.equals(request.getAttribute("dbConnected"))) { %>

<div class="alert success">
    Technical indicator analysis completed successfully.
</div>

<% } else { %>

<div class="alert error">
    Unable to connect to the evidence database.
</div>

<% } %>


<section class="indicator-info">

    <div class="info-icon">
        ⚠
    </div>

    <div>

        <h3>
            Technical Indicators Only
        </h3>

        <p>
            Indicators are predefined technical observations.
            They do not represent malware detection or a legal forensic conclusion.
        </p>

    </div>

</section>


<section class="cards indicator-cards">

    <div class="card">
        <span>TOTAL INDICATORS</span>

        <strong>
            <%= indicators.size() %>
        </strong>

        <small>
            Technical observations
        </small>
    </div>


    <div class="card high-card">
        <span>HIGH</span>

        <strong>
            <%= highCount %>
        </strong>

        <small>
            Requires review
        </small>
    </div>


    <div class="card medium-card">
        <span>MEDIUM</span>

        <strong>
            <%= mediumCount %>
        </strong>

        <small>
            Requires review
        </small>
    </div>


    <div class="card low-card">
        <span>LOW</span>

        <strong>
            <%= lowCount %>
        </strong>

        <small>
            Informational observations
        </small>
    </div>

</section>


<section class="panel indicator-panel">

    <div class="panel-head">

        <div>

            <h2>
                Detected Indicators
            </h2>

            <p>
                Technical observations generated from registered evidence.
            </p>

        </div>

        <span class="record-count">
            <%= indicators.size() %> records
        </span>

    </div>


<% if (indicators.isEmpty()) { %>

    <div class="empty">

        <div class="empty-icon">
            ✓
        </div>

        <h3>
            No technical indicators found
        </h3>

        <p>
            No predefined suspicious indicators were identified
            in the currently registered evidence.
        </p>

        <a class="primary button-link"
           href="${pageContext.request.contextPath}/evidence">
            Register More Evidence
        </a>

    </div>

<% } else { %>


<div class="indicator-list">

<%
    for (IndicatorRecord item : indicators) {
%>

    <article class="indicator-row">

        <div class="indicator-main">

            <div class="indicator-title">

                <strong>
                    <%= item.getIndicatorType() %>
                </strong>

                <span class="severity <%= item.getSeverity().toLowerCase() %>">
                    <%= item.getSeverity() %>
                </span>

            </div>


            <div class="indicator-evidence">

                <span class="evidence-id">
                    <%= item.getEvidenceCode() %>
                </span>

                <strong>
                    <%= item.getFileName() %>
                </strong>

            </div>


            <p>
                <%= item.getDescription() %>
            </p>

        </div>


        <div class="indicator-status">

            <span class="review-status">
                <%= item.getSeverity() %>
            </span>

        </div>

    </article>

<%
    }
%>

</div>


<% } %>

</section>


<footer>
    Academic prototype • Technical indicators only • Not a legal forensic conclusion
</footer>

</main>

</div>

</body>

</html>
