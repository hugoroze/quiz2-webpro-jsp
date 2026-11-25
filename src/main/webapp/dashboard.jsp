<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — TaskFlow Pro (JSP)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>body { font-family: 'Plus Jakarta Sans', sans-serif; }</style>
</head>
<body class="min-h-screen bg-slate-50 text-slate-800">

    <nav class="bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 text-white shadow-lg sticky top-0 z-30">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-lg bg-gradient-to-tr from-indigo-500 to-violet-500 flex items-center justify-center shadow">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                </div>
                <div>
                    <span class="font-bold text-lg tracking-tight">TaskFlow Pro</span>
                    <span class="ml-2 text-xs px-2 py-0.5 rounded-full bg-indigo-500/30 border border-indigo-400/30 text-indigo-200">Jakarta / JSP</span>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <span class="text-sm text-slate-300 hidden sm:inline">Welcome, <strong class="text-white">${sessionScope.userName}</strong></span>
                <a href="${pageContext.request.contextPath}/logout"
                   class="px-3.5 py-1.5 rounded-lg bg-white/10 hover:bg-rose-500/80 text-sm font-medium transition">
                    Logout
                </a>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">

        <c:if test="${not empty flash}">
            <div class="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-between shadow-sm">
                <span class="text-sm font-semibold">${flash}</span>
                <button onclick="this.parentElement.remove()" class="text-emerald-600 hover:text-emerald-900 text-xs font-bold">✕</button>
            </div>
        </c:if>

        <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Tasks</span>
                    <span class="p-2 rounded-lg bg-indigo-50 text-indigo-600 font-bold text-xs">ALL</span>
                </div>
                <p class="text-3xl font-extrabold text-slate-900 mt-2">${totalTasks}</p>
                <div class="mt-3 w-full bg-slate-100 rounded-full h-1.5">
                    <div class="bg-indigo-600 h-1.5 rounded-full" style="width: ${completionRate}%"></div>
                </div>
                <p class="text-xs text-slate-500 mt-1">${completionRate}% completion rate</p>
            </div>

            <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Completed</span>
                    <span class="p-2 rounded-lg bg-emerald-50 text-emerald-600 font-bold text-xs">DONE</span>
                </div>
                <p class="text-3xl font-extrabold text-emerald-600 mt-2">${completedTasks}</p>
                <p class="text-xs text-slate-500 mt-4">Finished deliverables</p>
            </div>

            <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Pending</span>
                    <span class="p-2 rounded-lg bg-amber-50 text-amber-600 font-bold text-xs">ACTIVE</span>
                </div>
                <p class="text-3xl font-extrabold text-amber-500 mt-2">${pendingTasks}</p>
                <p class="text-xs text-slate-500 mt-4">In progress or upcoming</p>
            </div>

            <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Categories</span>
                    <span class="p-2 rounded-lg bg-violet-50 text-violet-600 font-bold text-xs">GROUPS</span>
                </div>
                <p class="text-3xl font-extrabold text-violet-600 mt-2">${totalCategories}</p>
                <p class="text-xs text-slate-500 mt-4">Active project folders</p>
            </div>
        </section>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

            <section class="lg:col-span-4 bg-white rounded-2xl border border-slate-200/80 shadow-sm p-6">
                <h2 class="text-base font-bold text-slate-900 mb-1">Categories</h2>
                <p class="text-xs text-slate-500 mb-4">Organize tasks by project or subject</p>

                <form method="POST" action="${pageContext.request.contextPath}/dashboard" class="flex gap-2 mb-5">
                    <input type="hidden" name="action" value="createCategory">
                    <input type="text" name="name" required placeholder="New category name..."
                           class="flex-1 px-3.5 py-2 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none">
                    <button type="submit"
                            class="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold shadow-sm transition">
                        Add
                    </button>
                </form>

                <div class="space-y-2.5">
                    <c:choose>
                        <c:when test="${empty categories}">
                            <p class="text-sm text-slate-400 text-center py-6">No categories yet. Add one above!</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cat" items="${categories}">
                                <div class="p-3 rounded-xl bg-slate-50 border border-slate-200/70 hover:border-indigo-200 transition">
                                    <div class="flex items-center justify-between gap-2">
                                        <div class="flex items-center gap-2 min-w-0">
                                            <span class="w-2.5 h-2.5 rounded-full bg-indigo-500 shrink-0"></span>
                                            <span class="text-sm font-semibold text-slate-800 truncate">${cat.name}</span>
                                            <span class="text-xs px-2 py-0.5 rounded-full bg-slate-200/80 text-slate-600 font-medium">${cat.taskCount}</span>
                                        </div>
                                        <div class="flex items-center gap-1.5 shrink-0">
                                            <button type="button" onclick="toggleCatEdit('${cat.id}')"
                                                    class="px-2 py-1 text-xs font-medium text-indigo-600 hover:bg-indigo-50 rounded-lg transition">
                                                Edit
                                            </button>
                                            <form method="POST" action="${pageContext.request.contextPath}/dashboard"
                                                  onsubmit="return confirm('Delete this category and its tasks?');">
                                                <input type="hidden" name="action" value="deleteCategory">
                                                <input type="hidden" name="id" value="${cat.id}">
                                                <button type="submit"
                                                        class="px-2 py-1 text-xs font-medium text-rose-600 hover:bg-rose-50 rounded-lg transition">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                    <form id="cat-edit-${cat.id}" method="POST" action="${pageContext.request.contextPath}/dashboard"
                                          class="hidden mt-2.5 pt-2.5 border-t border-slate-200 flex gap-2">
                                        <input type="hidden" name="action" value="updateCategory">
                                        <input type="hidden" name="id" value="${cat.id}">
                                        <input type="text" name="name" value="${cat.name}" required
                                               class="flex-1 px-2.5 py-1 text-xs rounded-lg border border-slate-300 focus:border-indigo-500 outline-none">
                                        <button type="submit" class="px-2.5 py-1 bg-emerald-600 text-white text-xs font-semibold rounded-lg">Save</button>
                                    </form>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <div class="lg:col-span-8 space-y-6">

                <section class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-6">
                    <h2 class="text-base font-bold text-slate-900 mb-4">Create New Task</h2>
                    <form method="POST" action="${pageContext.request.contextPath}/dashboard" class="space-y-4">
                        <input type="hidden" name="action" value="createTask">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-semibold text-slate-600 mb-1">Task Title *</label>
                                <input type="text" name="title" required placeholder="e.g., Complete JSP Quiz 2 Report"
                                       class="w-full px-3.5 py-2 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none">
                            </div>
                            <div>
                                <label class="block text-xs font-semibold text-slate-600 mb-1">Category (Foreign Key) *</label>
                                <select name="category_id" required
                                        class="w-full px-3.5 py-2 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none bg-white">
                                    <option value="" disabled selected>Select a category...</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-600 mb-1">Description (Optional)</label>
                            <textarea name="description" rows="2" placeholder="Add details, links, or notes..."
                                      class="w-full px-3.5 py-2 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none"></textarea>
                        </div>
                        <div class="flex flex-wrap items-center justify-between gap-4">
                            <div class="flex items-center gap-2">
                                <label class="text-xs font-semibold text-slate-600">Due Date:</label>
                                <input type="date" name="due_date"
                                       class="px-3 py-1.5 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 outline-none">
                            </div>
                            <button type="submit"
                                    class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white text-sm font-semibold shadow-sm transition">
                                + Create Task
                            </button>
                        </div>
                    </form>
                </section>

                <section class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-4">
                    <form method="GET" action="${pageContext.request.contextPath}/dashboard" class="grid grid-cols-1 sm:grid-cols-12 gap-3">
                        <input type="text" name="search" value="${param.search}" placeholder="Search tasks by keyword..."
                               class="sm:col-span-5 px-3.5 py-2 text-sm rounded-xl border border-slate-200 focus:border-indigo-500 outline-none">
                        <select name="category" class="sm:col-span-3 px-3 py-2 text-sm rounded-xl border border-slate-200 bg-white outline-none">
                            <option value="">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${param.category == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                        <select name="status" class="sm:col-span-2 px-3 py-2 text-sm rounded-xl border border-slate-200 bg-white outline-none">
                            <option value="">All Status</option>
                            <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="completed" ${param.status == 'completed' ? 'selected' : ''}>Completed</option>
                        </select>
                        <div class="sm:col-span-2 flex gap-1.5">
                            <button type="submit" class="flex-1 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold transition">
                                Filter
                            </button>
                            <a href="${pageContext.request.contextPath}/dashboard"
                               class="px-3 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold flex items-center justify-center transition">
                                Reset
                            </a>
                        </div>
                    </form>
                </section>

                <section class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="text-base font-bold text-slate-900">Task List</h2>
                        <span class="text-xs font-medium text-slate-500">${fn:length(tasks)} task(s) shown</span>
                    </div>

                    <div class="space-y-3">
                        <c:choose>
                            <c:when test="${empty tasks}">
                                <div class="text-center py-10 border-2 border-dashed border-slate-200 rounded-xl">
                                    <p class="text-sm font-medium text-slate-500">No tasks found matching your criteria.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="t" items="${tasks}">
                                    <div class="p-4 rounded-xl border ${t.isCompleted ? 'bg-slate-50/80 border-slate-200/60' : 'bg-white border-slate-200 hover:border-indigo-300'} transition flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                                        <div class="space-y-1">
                                            <div class="flex flex-wrap items-center gap-2">
                                                <span class="font-bold text-sm ${t.isCompleted ? 'line-through text-slate-400' : 'text-slate-900'}">
                                                    ${t.title}
                                                </span>
                                                <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-100">
                                                    ${t.categoryName}
                                                </span>
                                                <c:choose>
                                                    <c:when test="${t.isCompleted}">
                                                        <span class="px-2 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Completed</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="px-2 py-0.5 rounded-full text-[11px] font-bold bg-amber-100 text-amber-700">Pending</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <c:if test="${not empty t.description}">
                                                <p class="text-xs text-slate-500">${t.description}</p>
                                            </c:if>
                                            <c:if test="${not empty t.dueDate}">
                                                <p class="text-[11px] font-medium text-slate-400">Due: ${t.dueDate}</p>
                                            </c:if>
                                        </div>

                                        <div class="flex items-center gap-2 shrink-0">
                                            <form method="POST" action="${pageContext.request.contextPath}/dashboard">
                                                <input type="hidden" name="action" value="toggleTask">
                                                <input type="hidden" name="id" value="${t.id}">
                                                <button type="submit"
                                                        class="px-3 py-1.5 rounded-lg text-xs font-semibold transition ${t.isCompleted ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'}">
                                                    ${t.isCompleted ? 'Reopen' : 'Complete'}
                                                </button>
                                            </form>

                                            <a href="${pageContext.request.contextPath}/tasks/edit?id=${t.id}"
                                               class="px-3 py-1.5 rounded-lg bg-indigo-50 hover:bg-indigo-100 text-indigo-700 text-xs font-semibold transition">
                                                Edit
                                            </a>

                                            <form method="POST" action="${pageContext.request.contextPath}/dashboard"
                                                  onsubmit="return confirm('Delete this task?');">
                                                <input type="hidden" name="action" value="deleteTask">
                                                <input type="hidden" name="id" value="${t.id}">
                                                <button type="submit"
                                                        class="px-3 py-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 text-xs font-semibold transition">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </div>
        </div>
    </main>

    <script>
        function toggleCatEdit(id) {
            const form = document.getElementById('cat-edit-' + id);
            form.classList.toggle('hidden');
        }
    </script>
</body>
</html>