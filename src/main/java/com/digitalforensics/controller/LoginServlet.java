package com.digitalforensics.controller;

import com.digitalforensics.dao.UserDAO;
import com.digitalforensics.model.User;
import com.digitalforensics.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) != null && req.getSession(false).getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard"); return;
        }
        req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp); return;
        }
        try {
            User user = userDAO.findByEmail(email.trim().toLowerCase());
            if (user != null && PasswordUtil.verify(password, user.getPasswordHash())) {
                HttpSession session = req.getSession(true);
                session.setAttribute("currentUser", user);
                session.setMaxInactiveInterval(30 * 60);
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Database connection failed. Run database/schema.sql and check DB credentials.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }
}
