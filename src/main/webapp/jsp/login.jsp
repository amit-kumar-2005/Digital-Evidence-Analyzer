<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html><head><title>Login - Digital Evidence Analyzer</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css"></head>
<body class="login-page">
<div class="login-card">
  <div class="brand login-brand"><span class="brand-mark">DE</span><div><strong>Digital Evidence</strong><small>Analyzer</small></div></div>
  <p class="eyebrow">SECURE INVESTIGATION PORTAL</p><h1>Sign in</h1><p class="muted">Access your investigation workspace.</p>
  <% if (request.getAttribute("error") != null) { %><div class="alert error"><%= request.getAttribute("error") %></div><% } %>
  <form method="post" action="${pageContext.request.contextPath}/login">
    <label>Email<input type="email" name="email" placeholder="admin@dea.local" required></label>
    <label>Password<input type="password" name="password" placeholder="••••••••" required></label>
    <button class="primary full" type="submit">Sign In</button>
  </form>
  <div class="setup-note">First run? Open <a href="${pageContext.request.contextPath}/setup">initial setup</a> after importing the database schema.</div>
</div>
</body></html>
