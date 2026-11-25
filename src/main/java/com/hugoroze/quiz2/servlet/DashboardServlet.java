package com.hugoroze.quiz2.servlet;

import com.hugoroze.quiz2.util.DBConnection;

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
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/dashboard", "/tasks/edit"})
@SuppressWarnings({"unchecked", "rawtypes"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        long userId = (Long) session.getAttribute("userId");
        String path = req.getServletPath();

        try (Connection conn = DBConnection.getConnection()) {
            List categories = new ArrayList();
            String catSql = "SELECT c.id, c.name, COUNT(t.id) AS task_count " +
                            "FROM categories c LEFT JOIN tasks t ON t.category_id = c.id AND t.user_id = ? " +
                            "GROUP BY c.id, c.name ORDER BY c.name ASC";
            try (PreparedStatement ps = conn.prepareStatement(catSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map c = new HashMap();
                        c.put("id", rs.getLong("id"));
                        c.put("name", rs.getString("name"));
                        c.put("taskCount", rs.getInt("task_count"));
                        categories.add(c);
                    }
                }
            }
            req.setAttribute("categories", categories);

            if ("/tasks/edit".equals(path)) {
                long taskId = Long.parseLong(req.getParameter("id"));
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id, category_id, title, description, due_date, is_completed FROM tasks WHERE id = ? AND user_id = ?")) {
                    ps.setLong(1, taskId);
                    ps.setLong(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Map task = new HashMap();
                            task.put("id", rs.getLong("id"));
                            task.put("categoryId", rs.getLong("category_id"));
                            task.put("title", rs.getString("title"));
                            task.put("description", rs.getString("description"));
                            task.put("dueDate", rs.getDate("due_date") != null ? rs.getDate("due_date").toString() : "");
                            task.put("isCompleted", rs.getBoolean("is_completed"));
                            req.setAttribute("task", task);
                            req.getRequestDispatcher("/edit.jsp").forward(req, resp);
                            return;
                        }
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }

            int totalTasks = 0;
            int completedTasks = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS total, COALESCE(SUM(is_completed), 0) AS done FROM tasks WHERE user_id = ?")) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalTasks = rs.getInt("total");
                        completedTasks = rs.getInt("done");
                    }
                }
            }
            int pendingTasks = totalTasks - completedTasks;
            int completionRate = totalTasks != 0 ? (int) Math.round((completedTasks * 100.0) / totalTasks) : 0;

            req.setAttribute("totalTasks", totalTasks);
            req.setAttribute("completedTasks", completedTasks);
            req.setAttribute("pendingTasks", pendingTasks);
            req.setAttribute("completionRate", completionRate);
            req.setAttribute("totalCategories", categories.size());

            String search = req.getParameter("search");
            String filterCat = req.getParameter("category");
            String filterStatus = req.getParameter("status");

            StringBuilder taskSql = new StringBuilder(
                "SELECT t.id, t.title, t.description, t.due_date, t.is_completed, c.name AS category_name " +
                "FROM tasks t JOIN categories c ON t.category_id = c.id WHERE t.user_id = ?"
            );
            List params = new ArrayList();
            params.add(userId);

            if (search != null && !search.trim().isEmpty()) {
                taskSql.append(" AND (t.title LIKE ? OR t.description LIKE ?)");
                String pattern = "%" + search.trim() + "%";
                params.add(pattern);
                params.add(pattern);
            }
            if (filterCat != null && !filterCat.isEmpty()) {
                taskSql.append(" AND t.category_id = ?");
                params.add(Long.parseLong(filterCat));
            }
            if ("completed".equals(filterStatus)) {
                taskSql.append(" AND t.is_completed = 1");
            } else if ("pending".equals(filterStatus)) {
                taskSql.append(" AND t.is_completed = 0");
            }
            taskSql.append(" ORDER BY t.is_completed ASC, t.due_date ASC, t.id DESC");

            List tasks = new ArrayList();
            try (PreparedStatement ps = conn.prepareStatement(taskSql.toString())) {
                for (int i = 0; i != params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map t = new HashMap();
                        t.put("id", rs.getLong("id"));
                        t.put("title", rs.getString("title"));
                        t.put("description", rs.getString("description"));
                        t.put("dueDate", rs.getDate("due_date") != null ? rs.getDate("due_date").toString() : null);
                        t.put("isCompleted", rs.getBoolean("is_completed"));
                        t.put("categoryName", rs.getString("category_name"));
                        tasks.add(t);
                    }
                }
            }
            req.setAttribute("tasks", tasks);

            if (session.getAttribute("flash") != null) {
                req.setAttribute("flash", session.getAttribute("flash"));
                session.removeAttribute("flash");
            }

            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        long userId = (Long) session.getAttribute("userId");
        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            switch (action != null ? action : "") {
                case "createCategory": {
                    String name = req.getParameter("name");
                    if (name != null && !name.trim().isEmpty()) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO categories (name, created_at, updated_at) VALUES (?, NOW(), NOW())")) {
                            ps.setString(1, name.trim());
                            ps.executeUpdate();
                            session.setAttribute("flash", "Category created successfully.");
                        }
                    }
                    break;
                }
                case "updateCategory": {
                    long catId = Long.parseLong(req.getParameter("id"));
                    String name = req.getParameter("name");
                    if (name != null && !name.trim().isEmpty()) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "UPDATE categories SET name = ?, updated_at = NOW() WHERE id = ?")) {
                            ps.setString(1, name.trim());
                            ps.setLong(2, catId);
                            ps.executeUpdate();
                            session.setAttribute("flash", "Category updated successfully.");
                        }
                    }
                    break;
                }
                case "deleteCategory": {
                    long catId = Long.parseLong(req.getParameter("id"));
                    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM categories WHERE id = ?")) {
                        ps.setLong(1, catId);
                        ps.executeUpdate();
                        session.setAttribute("flash", "Category deleted.");
                    }
                    break;
                }
                case "createTask": {
                    String title = req.getParameter("title");
                    long catId = Long.parseLong(req.getParameter("category_id"));
                    String desc = req.getParameter("description");
                    String dueDate = req.getParameter("due_date");

                    if (title != null && !title.trim().isEmpty()) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO tasks (user_id, category_id, title, description, due_date, is_completed, created_at, updated_at) " +
                                "VALUES (?, ?, ?, ?, ?, 0, NOW(), NOW())")) {
                            ps.setLong(1, userId);
                            ps.setLong(2, catId);
                            ps.setString(3, title.trim());
                            ps.setString(4, (desc != null && !desc.trim().isEmpty()) ? desc.trim() : null);
                            if (dueDate != null && !dueDate.isEmpty()) {
                                ps.setDate(5, java.sql.Date.valueOf(dueDate));
                            } else {
                                ps.setNull(5, Types.DATE);
                            }
                            ps.executeUpdate();
                            session.setAttribute("flash", "Task created successfully.");
                        }
                    }
                    break;
                }
                case "updateTask": {
                    long taskId = Long.parseLong(req.getParameter("id"));
                    String title = req.getParameter("title");
                    long catId = Long.parseLong(req.getParameter("category_id"));
                    String desc = req.getParameter("description");
                    String dueDate = req.getParameter("due_date");
                    boolean isCompleted = "1".equals(req.getParameter("is_completed"));

                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE tasks SET title = ?, category_id = ?, description = ?, due_date = ?, is_completed = ?, updated_at = NOW() " +
                            "WHERE id = ? AND user_id = ?")) {
                        ps.setString(1, title.trim());
                        ps.setLong(2, catId);
                        ps.setString(3, (desc != null && !desc.trim().isEmpty()) ? desc.trim() : null);
                        if (dueDate != null && !dueDate.isEmpty()) {
                            ps.setDate(4, java.sql.Date.valueOf(dueDate));
                        } else {
                            ps.setNull(4, Types.DATE);
                        }
                        ps.setBoolean(5, isCompleted);
                        ps.setLong(6, taskId);
                        ps.setLong(7, userId);
                        ps.executeUpdate();
                        session.setAttribute("flash", "Task updated successfully.");
                    }
                    break;
                }
                case "toggleTask": {
                    long taskId = Long.parseLong(req.getParameter("id"));
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE tasks SET is_completed = NOT is_completed, updated_at = NOW() WHERE id = ? AND user_id = ?")) {
                        ps.setLong(1, taskId);
                        ps.setLong(2, userId);
                        ps.executeUpdate();
                        session.setAttribute("flash", "Task status updated.");
                    }
                    break;
                }
                case "deleteTask": {
                    long taskId = Long.parseLong(req.getParameter("id"));
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM tasks WHERE id = ? AND user_id = ?")) {
                        ps.setLong(1, taskId);
                        ps.setLong(2, userId);
                        ps.executeUpdate();
                        session.setAttribute("flash", "Task deleted.");
                    }
                    break;
                }
            }
        } catch (SQLException e) {
            session.setAttribute("flash", "Operation error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }
}