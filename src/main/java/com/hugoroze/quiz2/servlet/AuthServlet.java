package com.hugoroze.quiz2.servlet;

import com.hugoroze.quiz2.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

@WebServlet(urlPatterns = {"/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if ("/register".equals(path)) {
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        if ("/register".equals(path)) {
            handleRegister(req, resp);
        } else if ("/login".equals(path)) {
            handleLogin(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm_password");

        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() || password == null || password.length() < 6) {
            req.setAttribute("error", "Please fill all fields (password must be at least 6 characters).");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        String hashed = BCrypt.hashpw(password, BCrypt.gensalt(12));

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO users (name, email, password, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())",
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, hashed);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("userId", keys.getLong(1));
                    session.setAttribute("userName", name.trim());
                    session.setAttribute("userEmail", email.trim().toLowerCase());
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                    return;
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Registration failed: email may already be in use.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name, email, password FROM users WHERE email = ?")) {
            ps.setString(1, email != null ? email.trim().toLowerCase() : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    String normalized = storedHash.startsWith("$2y$") ? "$2a$" + storedHash.substring(4) : storedHash;
                    if (password != null && BCrypt.checkpw(password, normalized)) {
                        HttpSession session = req.getSession(true);
                        session.setAttribute("userId", rs.getLong("id"));
                        session.setAttribute("userName", rs.getString("name"));
                        session.setAttribute("userEmail", rs.getString("email"));
                        resp.sendRedirect(req.getContextPath() + "/dashboard");
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Database connection error: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("error", "Invalid email or password.");
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
}