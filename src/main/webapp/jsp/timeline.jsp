
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.digitalforensics.controller.TimelineServlet.TimelineEvent" %>

<%
    List<TimelineEvent> events =
            (List<TimelineEvent>) request.getAttribute("events");

    Boolean dbConnected =
            (Boolean) request.getAttribute("dbConnected");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    if (events == null) {
        events = java.util.Collections.emptyList();
    }

    SimpleDateFormat dateFormat =
            new SimpleDateFormat("dd MMM yyyy, hh:mm:ss a");

    int totalEvents = events.size();
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Timeline - Digital Evidence Analyzer</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/timeline.css">
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

        <!-- UPDATED NAVIGATION -->

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

            <a class="active"
               href="${pageContext.request.contextPath}/timeline">
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
                    INVESTIGATION / TIMELINE
                </div>

                <h1>Evidence Timeline</h1>

                <p>
                    Chronological view of important events associated
                    with registered digital evidence.
                </p>

            </div>

        </header>

        <!-- ================= SUCCESS / ERROR ================= -->

        <% if (Boolean.TRUE.equals(dbConnected)) { %>

            <div class="success-message">
                ✓ Timeline analysis loaded successfully.
            </div>

        <% } else { %>

            <div class="error-message">
                ⚠
                <%= errorMessage != null
                        ? errorMessage
                        : "Unable to load timeline data." %>
            </div>

        <% } %>

        <!-- ================= INFORMATION CARD ================= -->

        <section class="info-card">

            <div class="info-icon">
                ◷
            </div>

            <div>

                <strong>Chronological Evidence Events</strong>

                <p>
                    This timeline presents technical timestamps recorded
                    for registered evidence, including creation,
                    modification, access and registration events.
                </p>

            </div>

        </section>

        <!-- ================= STATISTICS ================= -->

        <section class="stats-grid">

            <div class="stat-card">

                <span class="stat-label">
                    TOTAL EVENTS
                </span>

                <strong>
                    <%= totalEvents %>
                </strong>

                <small>
                    Recorded timeline events
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    EVIDENCE ITEMS
                </span>

                <strong>
                    <%
                        java.util.Set<String> evidenceSet =
                                new java.util.HashSet<>();

                        for (TimelineEvent event : events) {
                            evidenceSet.add(event.getEvidenceCode());
                        }

                        out.print(evidenceSet.size());
                    %>
                </strong>

                <small>
                    Evidence represented
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    CREATED
                </span>

                <strong>
                    <%
                        int createdCount = 0;

                        for (TimelineEvent event : events) {
                            if ("CREATED".equals(event.getEventType())) {
                                createdCount++;
                            }
                        }

                        out.print(createdCount);
                    %>
                </strong>

                <small>
                    Creation events
                </small>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    REGISTERED
                </span>

                <strong>
                    <%
                        int registeredCount = 0;

                        for (TimelineEvent event : events) {
                            if ("REGISTERED".equals(event.getEventType())) {
                                registeredCount++;
                            }
                        }

                        out.print(registeredCount);
                    %>
                </strong>

                <small>
                    Registration events
                </small>

            </div>

        </section>

        <!-- ================= TIMELINE ================= -->

        <section class="timeline-card">

            <div class="section-header">

                <div>

                    <h2>Investigation Timeline</h2>

                    <p>
                        Events are ordered from earliest to latest.
                    </p>

                </div>

                <span class="record-count">
                    <%= totalEvents %> events
                </span>

            </div>

            <% if (events.isEmpty()) { %>

                <div class="empty-state">

                    <div class="empty-icon">
                        ◷
                    </div>

                    <h3>No timeline events found</h3>

                    <p>
                        No timestamped events are currently available
                        for registered evidence.
                    </p>

                    <a href="${pageContext.request.contextPath}/evidence"
                       class="primary-button">
                        Register Evidence
                    </a>

                </div>

            <% } else { %>

                <div class="timeline">

                    <% for (TimelineEvent event : events) {

                        String eventClass =
                                event.getEventType()
                                     .toLowerCase();

                    %>

                        <div class="timeline-item">

                            <div class="timeline-line">

                                <div class="timeline-dot <%= eventClass %>">
                                </div>

                            </div>

                            <div class="timeline-content">

                                <div class="timeline-top">

                                    <span class="event-badge <%= eventClass %>">

                                        <%= event.getEventType() %>

                                    </span>

                                    <span class="event-time">

                                        <%= event.getEventTime() != null
                                                ? dateFormat.format(
                                                    event.getEventTime())
                                                : "N/A" %>

                                    </span>

                                </div>

                                <h3>
                                    <%= event.getFileName() %>
                                </h3>

                                <div class="event-details">

                                    <div>

                                        <span>Evidence</span>

                                        <strong>
                                            <%= event.getEvidenceCode() %>
                                        </strong>

                                    </div>

                                    <div>

                                        <span>Case</span>

                                        <strong>
                                            <%= event.getCaseCode() %>
                                        </strong>

                                    </div>

                                    <div>

                                        <span>Case Name</span>

                                        <strong>
                                            <%= event.getCaseName() %>
                                        </strong>

                                    </div>

                                </div>

                            </div>

                        </div>

                    <% } %>

                </div>

            <% } %>

        </section>

        <!-- ================= DISCLAIMER ================= -->

        <div class="technical-note">

            <strong>Technical Timeline</strong>

            <span>
                Timeline values are derived from filesystem metadata
                and evidence registration records. They should be
                interpreted as technical observations and not as
                independent proof of user activity.
            </span>

        </div>

    </main>

</div>

</body>
</html>
