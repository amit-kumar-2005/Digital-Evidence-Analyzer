<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalforensics.model.InvestigationCase" %>
<% List<InvestigationCase> recentCases = (List<InvestigationCase>) request.getAttribute("recentCases"); %>
<!DOCTYPE html><html><head><title>Digital Evidence Analyzer - Dashboard</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css"></head>
<body><div class="app"><aside class="sidebar"><div class="brand"><span class="brand-mark">DE</span><div><strong>Digital Evidence</strong><small>Analyzer</small></div></div><nav>
<a class="active" href="${pageContext.request.contextPath}/dashboard">▣ Dashboard</a><a href="${pageContext.request.contextPath}/cases">▣ Cases <span>›</span></a><a href="${pageContext.request.contextPath}/evidence">▤ Evidence <span>›</span></a><a href="${pageContext.request.contextPath}/analysis">
    ⌕ Analysis <span>›</span>
</a><a href="${pageContext.request.contextPath}/timeline">
    ◷ Timeline
</a><a href="${pageContext.request.contextPath}/duplicates">
    ◫ Duplicates
</a><a href="${pageContext.request.contextPath}/indicators">
    ⚠ Indicators
</a><a href="${pageContext.request.contextPath}/integrity">⌑ Integrity</a><a href="${pageContext.request.contextPath}/relationships">
    ⛓ Relationships
</a><a href="${pageContext.request.contextPath}/findings">☷ Findings</a><a href="${pageContext.request.contextPath}/audit-log">≡ Audit Log</a><a href="${pageContext.request.contextPath}/reports">▥ Reports</a><a href="${pageContext.request.contextPath}/settings">⚙ Settings</a></nav><div class="sidebar-bottom"><a href="${pageContext.request.contextPath}/logout">↪ Sign out</a></div></aside>
<main class="content"><header><div><p class="eyebrow">INVESTIGATION OVERVIEW</p><h1>Dashboard</h1><p class="muted">Digital evidence analysis and case monitoring</p></div><a class="primary button-link" href="${pageContext.request.contextPath}/cases#new-case">+ New Case</a></header>
<% if (Boolean.TRUE.equals(request.getAttribute("dbConnected"))) { %><div class="alert success">Database connected • Live investigation data is being displayed.</div><% } else { %><div class="alert error">Database is not connected. Import <code>database/schema.sql</code> and verify MySQL credentials.</div><% } %>
<section class="cards"><div class="card"><span>ACTIVE CASES</span><strong><%= request.getAttribute("caseCount") %></strong><small>Investigation records</small></div><div class="card"><span>EVIDENCE ITEMS</span><strong><%= request.getAttribute("evidenceCount") %></strong><small>Registered evidence</small></div><div class="card"><span>FILES ANALYZED</span><strong><%= request.getAttribute("fileCount") %></strong><small>Across all cases</small></div><div class="card"><span>INDICATORS</span><strong><%= request.getAttribute("indicatorCount") %></strong><small>Technical warnings</small></div><div class="card"><span>HASH MISMATCH</span><strong><%= request.getAttribute("hashMismatchCount") %></strong><small>Integrity events</small></div></section>
<section class="grid"><div class="panel"><div class="panel-head"><h2>Recent Investigation Cases</h2><a href="${pageContext.request.contextPath}/cases">View all</a></div><div class="case-list">
<% if (recentCases == null || recentCases.isEmpty()) { %><div class="empty"><div class="empty-icon">⌁</div><h3>No cases yet</h3><p>Create your first investigation case to begin registering and analyzing evidence.</p><a class="primary button-link" href="${pageContext.request.contextPath}/cases#new-case">Create Investigation</a></div><% } else { for (InvestigationCase c : recentCases) { %><div class="case-row"><div><strong><%= c.getCaseCode() %></strong><span><%= c.getCaseName() %></span></div><span class="status <%= c.getStatus().toLowerCase() %>"><%= c.getStatus().replace('_',' ') %></span></div><% }} %></div></div>
<div class="panel"><div class="panel-head"><h2>System Status</h2></div><div class="activity"><div><b>Core analysis engine</b><span>File scanning, type detection and hashing ready</span></div><div><b>Authentication</b><span>Session-based login with role support</span></div><div><b>Database</b><span><%= Boolean.TRUE.equals(request.getAttribute("dbConnected")) ? "MySQL connection active" : "Connection pending" %></span></div></div></div></section>
<footer>Academic prototype • Technical indicators only • Not a legal forensic conclusion</footer></main></div></body></html>
