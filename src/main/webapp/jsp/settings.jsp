<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="com.digitalforensics.controller.LoginServlet" %>

<%
    Object currentUser = session.getAttribute("currentUser");

    String userName = "System User";
    String userEmail = "Not available";
    String userRole = "INVESTIGATOR";

    if (currentUser != null) {
        try {
            Object value = currentUser.getClass()
                    .getMethod("getFullName").invoke(currentUser);
            if (value != null) userName = value.toString();
        } catch (Exception ignored) {}

        try {
            Object value = currentUser.getClass()
                    .getMethod("getEmail").invoke(currentUser);
            if (value != null) userEmail = value.toString();
        } catch (Exception ignored) {}

        try {
            Object value = currentUser.getClass()
                    .getMethod("getRole").invoke(currentUser);
            if (value != null) userRole = value.toString();
        } catch (Exception ignored) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Digital Evidence Analyzer</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/settings.css">
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
            <a href="${pageContext.request.contextPath}/reports">▤ Reports</a>
            <a class="active" href="${pageContext.request.contextPath}/settings">⚙ Settings</a>
        </nav>

        <div class="sidebar-bottom">
            <a href="${pageContext.request.contextPath}/logout">↪ Sign out</a>
        </div>
    </aside>

    <main class="main-content">

        <header class="page-header">
            <div>
                <div class="breadcrumb">SYSTEM / SETTINGS</div>
                <h1>Settings</h1>
                <p>View your account information and application status.</p>
            </div>
        </header>

        <section class="info-banner">
            <strong>Account & System Configuration</strong>
            <p>
                Review the signed-in account and the current application
                environment. Account details shown here are read-only.
            </p>
        </section>

        <section class="settings-grid">

            <article class="settings-card">
                <div class="card-heading">
                    <div class="card-icon">U</div>
                    <div>
                        <h2>User Profile</h2>
                        <p>Current signed-in account</p>
                    </div>
                </div>

                <div class="profile-avatar">
                    <%= userName.isBlank() ? "U" :
                        userName.substring(0, 1).toUpperCase() %>
                </div>

                <div class="detail-row">
                    <span>Full Name</span>
                    <strong><%= userName %></strong>
                </div>

                <div class="detail-row">
                    <span>Email Address</span>
                    <strong><%= userEmail %></strong>
                </div>

                <div class="detail-row">
                    <span>Account Role</span>
                    <strong class="role-badge"><%= userRole %></strong>
                </div>

                <div class="readonly-note">
                    Profile information is currently read-only.
                </div>
            </article>

            <article class="settings-card">
                <div class="card-heading">
                    <div class="card-icon">S</div>
                    <div>
                        <h2>Security</h2>
                        <p>Session and access information</p>
                    </div>
                </div>

                <div class="detail-row">
                    <span>Authentication</span>
                    <strong class="healthy">Session Active</strong>
                </div>

                <div class="detail-row">
                    <span>Session Timeout</span>
                    <strong>30 minutes of inactivity</strong>
                </div>

                <div class="detail-row">
                    <span>Password Storage</span>
                    <strong>Stored as password hash</strong>
                </div>

                <div class="readonly-note">
                    Never share your login credentials with others.
                </div>
            </article>

            <article class="settings-card">
                <div class="card-heading">
                    <div class="card-icon">D</div>
                    <div>
                        <h2>Database</h2>
                        <p>Application data connection</p>
                    </div>
                </div>

                <div class="detail-row">
                    <span>Database</span>
                    <strong>MySQL</strong>
                </div>

                <div class="detail-row">
                    <span>Schema</span>
                    <strong>digital_evidence_analyzer</strong>
                </div>

                <div class="detail-row">
                    <span>Connection</span>
                    <strong class="healthy">Configured</strong>
                </div>

                <div class="readonly-note">
                    Connection details are intentionally not displayed.
                </div>
            </article>

            <article class="settings-card">
                <div class="card-heading">
                    <div class="card-icon">A</div>
                    <div>
                        <h2>Application</h2>
                        <p>Runtime environment</p>
                    </div>
                </div>

                <div class="detail-row">
                    <span>Application</span>
                    <strong>Digital Evidence Analyzer</strong>
                </div>

                <div class="detail-row">
                    <span>Java Runtime</span>
                    <strong>Java 21</strong>
                </div>

                <div class="detail-row">
                    <span>Web Server</span>
                    <strong>Apache Tomcat 10.1</strong>
                </div>

                <div class="detail-row">
                    <span>Architecture</span>
                    <strong>Java Servlet / JSP / JDBC</strong>
                </div>
            </article>

        </section>

        <div class="footer-note">
            Digital Evidence Analyzer — Academic project configuration.
            Security and system details are displayed for informational purposes.
        </div>

    </main>
</div>

</body>
</html>
