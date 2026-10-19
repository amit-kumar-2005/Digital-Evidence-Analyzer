package com.digitalforensics.controller;

import com.digitalforensics.dao.UserDAO;
import com.digitalforensics.model.User;
import com.digitalforensics.util.PasswordUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/setup")
public class SetupServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        try {
            UserDAO dao = new UserDAO();
            if (dao.existsAnyUser()) {
                resp.getWriter().println("<h2>Setup already completed.</h2><a href='login'>Go to Login</a>");
                return;
            }
            User admin = new User();
            admin.setFullName("System Administrator");
            admin.setEmail("admin@dea.local");
            admin.setPasswordHash(PasswordUtil.hash("Admin@123"));
            admin.setRole("ADMIN");
            dao.create(admin);
            resp.getWriter().println("<h2>Initial administrator created.</h2><p>Email: admin@dea.local</p><p>Password: Admin@123</p><p>Change this password before real deployment.</p><a href='login'>Go to Login</a>");
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().println("<h2>Setup failed</h2><pre>" + escape(e.getMessage()) + "</pre>");
        }
    }
    private String escape(String s) { return s == null ? "Unknown error" : s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"); }
}
