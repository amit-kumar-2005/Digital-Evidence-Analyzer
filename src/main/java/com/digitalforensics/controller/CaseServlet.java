
package com.digitalforensics.controller;

import com.digitalforensics.dao.CaseDAO;
import com.digitalforensics.model.InvestigationCase;
import com.digitalforensics.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

@WebServlet("/cases")
public class CaseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CaseDAO caseDAO = new CaseDAO();

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("cases", caseDAO.findAll());
            req.getRequestDispatcher("/jsp/cases.jsp")
                    .forward(req, resp);

        } catch (Exception e) {
            getServletContext().log("Unable to load cases.", e);

            req.setAttribute(
                    "error",
                    "Unable to load cases. Please try again."
            );

            req.getRequestDispatcher("/jsp/cases.jsp")
                    .forward(req, resp);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        // Check the logged-in user.
        HttpSession session = req.getSession(false);

        User user = session == null
                ? null
                : (User) session.getAttribute("currentUser");

        if (user == null) {
            resp.sendRedirect(
                    req.getContextPath() + "/login"
            );
            return;
        }

        // Only ADMIN and INVESTIGATOR can create cases.
        String role = user.getRole();

        if (!"ADMIN".equalsIgnoreCase(role)
                && !"INVESTIGATOR".equalsIgnoreCase(role)) {

            resp.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create cases."
            );
            return;
        }

        String name = req.getParameter("caseName");
        String description = req.getParameter("description");

        if (name == null || name.isBlank()) {
            resp.sendRedirect(
                    req.getContextPath()
                    + "/cases?error=Case+name+is+required"
            );
            return;
        }

        try {
            InvestigationCase investigationCase =
                    new InvestigationCase();

            investigationCase.setCaseCode(generateCode());
            investigationCase.setCaseName(name.trim());

            investigationCase.setDescription(
                    description == null
                            ? ""
                            : description.trim()
            );

            investigationCase.setStatus("OPEN");
            investigationCase.setCreatedBy(user.getId());

            caseDAO.create(investigationCase);

            resp.sendRedirect(
                    req.getContextPath() + "/cases?created=1"
            );

        } catch (Exception e) {
            getServletContext().log("Unable to create case.", e);

            resp.sendRedirect(
                    req.getContextPath()
                    + "/cases?error=Unable+to+create+case"
            );
        }
    }

    private String generateCode() {
        return "DEA-"
                + java.time.Year.now()
                + "-"
                + UUID.randomUUID()
                        .toString()
                        .substring(0, 6)
                        .toUpperCase();
    }
}
