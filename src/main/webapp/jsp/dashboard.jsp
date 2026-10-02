<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html><head><title>Digital Evidence Analyzer - Dashboard</title><link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css"></head>
<body>
<div class="app">
  <aside class="sidebar">
    <div class="brand"><span class="brand-mark">DE</span><div><strong>Digital Evidence</strong><small>Analyzer</small></div></div>
    <nav>
      <a class="active" href="${pageContext.request.contextPath}/dashboard">▣ Dashboard</a>
      <a href="#">▣ Cases <span>›</span></a><a href="#">▤ Evidence <span>›</span></a><a href="#">⌕ Analysis <span>›</span></a>
      <a href="#">◷ Timeline</a><a href="#">◫ Duplicates</a><a href="#">⚠ Indicators</a><a href="#">⌑ Integrity</a>
      <a href="#">⌘ Relationships</a><a href="#">☷ Findings</a><a href="#">≡ Audit Log</a><a href="#">▥ Reports</a><a href="#">⚙ Settings</a>
    </nav>
  </aside>
  <main class="content">
    <header><div><p class="eyebrow">INVESTIGATION OVERVIEW</p><h1>Dashboard</h1><p class="muted">Digital evidence analysis and case monitoring</p></div><button class="primary">+ New Case</button></header>
    <section class="cards">
      <div class="card"><span>ACTIVE CASES</span><strong>0</strong><small>Ready for investigation</small></div>
      <div class="card"><span>EVIDENCE ITEMS</span><strong>0</strong><small>Registered evidence</small></div>
      <div class="card"><span>FILES ANALYZED</span><strong>0</strong><small>Across all cases</small></div>
      <div class="card"><span>INDICATORS</span><strong>0</strong><small>Technical warnings</small></div>
      <div class="card"><span>HASH MISMATCH</span><strong>0</strong><small>Integrity events</small></div>
    </section>
    <section class="grid">
      <div class="panel"><div class="panel-head"><h2>Recent Investigation Cases</h2><a href="#">View all</a></div><div class="empty"><div class="empty-icon">⌁</div><h3>No cases yet</h3><p>Create your first investigation case to begin registering and analyzing evidence.</p><button class="primary">Create Investigation</button></div></div>
      <div class="panel"><div class="panel-head"><h2>Analysis Activity</h2></div><div class="activity"><div><b>System ready</b><span>Evidence analysis engine initialized</span></div><div><b>Database pending</b><span>Run database/schema.sql to connect MySQL</span></div></div></div>
    </section>
    <footer>Academic prototype • Technical indicators only • Not a legal forensic conclusion</footer>
  </main>
</div>
</body></html>
