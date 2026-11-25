<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Task — TaskFlow Pro (JSP)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Plus Jakarta Sans', sans-serif; }</style>
</head>
<body class="min-h-screen bg-slate-50 flex items-center justify-center p-4">
    <div class="w-full max-w-xl bg-white rounded-2xl shadow-lg border border-slate-200 p-8">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h1 class="text-xl font-bold text-slate-900">Edit Task</h1>
                <p class="text-xs text-slate-500 mt-0.5">Update task details, category, or completion status</p>
            </div>
            <a href="${pageContext.request.contextPath}/dashboard"
               class="text-xs font-semibold text-slate-500 hover:text-slate-800">← Back to Dashboard</a>
        </div>

        <form method="POST" action="${pageContext.request.contextPath}/dashboard" class="space-y-4">
            <input type="hidden" name="action" value="updateTask">
            <input type="hidden" name="id" value="${task.id}">

            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Task Title *</label>
                <input type="text" name="title" value="${task.title}" required
                       class="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none">
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Category *</label>
                    <select name="category_id" required
                            class="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 bg-white focus:border-indigo-500 outline-none">
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${cat.id == task.categoryId ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Due Date</label>
                    <input type="date" name="due_date" value="${task.dueDate}"
                           class="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 outline-none">
                </div>
            </div>

            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Description</label>
                <textarea name="description" rows="3"
                          class="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 outline-none">${task.description}</textarea>
            </div>

            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Status</label>
                <select name="is_completed"
                        class="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 bg-white focus:border-indigo-500 outline-none">
                    <option value="0" ${!task.isCompleted ? 'selected' : ''}>Pending</option>
                    <option value="1" ${task.isCompleted ? 'selected' : ''}>Completed</option>
                </select>
            </div>

            <div class="flex justify-end gap-3 pt-4">
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="px-4 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-semibold transition">
                    Cancel
                </a>
                <button type="submit"
                        class="px-6 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold shadow-sm transition">
                    Save Changes
                </button>
            </div>
        </form>
    </div>
</body>
</html>