package com.digitalforensics.controller;

import com.digitalforensics.dao.CaseDAO;
import com.digitalforensics.model.InvestigationCase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.digitalforensics.util.DBConnection;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private final CaseDAO caseDAO = new CaseDAO();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Dashboard");
        try {
            req.setAttribute("caseCount", caseDAO.count());
            req.setAttribute("evidenceCount", count("SELECT COUNT(*) FROM evidence_files"));
            req.setAttribute("indicatorCount", count("SELECT COUNT(*) FROM suspicious_indicators"));
            req.setAttribute("hashMismatchCount", count("SELECT COUNT(*) FROM evidence_files WHERE integrity_status='HASH_MISMATCH'"));
            req.setAttribute("fileCount", count("SELECT COUNT(*) FROM evidence_files"));
            req.setAttribute("recentCases", caseDAO.findAll().stream().limit(5).toList());
            req.setAttribute("dbConnected", true);
        } catch (Exception e) {
            req.setAttribute("caseCount", 0L);
            req.setAttribute("evidenceCount", 0L);
            req.setAttribute("indicatorCount", 0L);
            req.setAttribute("hashMismatchCount", 0L);
            req.setAttribute("fileCount", 0L);
            req.setAttribute("recentCases", java.util.List.of());
            req.setAttribute("dbConnected", false);
        }
        req.getRequestDispatcher("/jsp/dashboard.jsp").forward(req, resp);
    }

    private long count(String sql) throws Exception {
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next(); return rs.getLong(1);
        }
    }
}
