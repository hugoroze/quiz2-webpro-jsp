<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — TaskFlow Pro (JSP)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Plus Jakarta Sans', sans-serif; }</style>
</head>
<body class="min-h-screen bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 flex items-center justify-center p-4">
    <div class="w-full max-w-md bg-white/95 backdrop-blur-xl rounded-2xl shadow-2xl border border-white/20 p-8">
        <div class="flex flex-col items-center mb-6">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-tr from-indigo-600 to-violet-500 flex items-center justify-center text-white shadow-lg mb-3">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                </svg>
            </div>
            <h1 class="text-2xl font-bold text-slate-900">Create Account</h1>
            <p class="text-sm text-slate-500 mt-1">Start organizing your projects and tasks</p>
        </div>

        <c:if test="${not empty error}">
            <div class="mb-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-medium">
                ${error}
            </div>
        </c:if>

        <form method="POST" action="${pageContext.request.contextPath}/register" class="space-y-4">
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-slate-600 mb-1.5">Full Name</label>
                <input type="text" name="name" required placeholder="Hugo Roze"
                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition">
            </div>
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-slate-600 mb-1.5">Email Address</label>
                <input type="email" name="email" required placeholder="hugo@example.com"
                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition">
            </div>
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-slate-600 mb-1.5">Password</label>
                <input type="password" name="password" required minlength="6" placeholder="Min. 6 characters"
                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition">
            </div>
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-slate-600 mb-1.5">Confirm Password</label>
                <input type="password" name="confirm_password" required minlength="6" placeholder="Repeat password"
                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition">
            </div>
            <button type="submit"
                    class="w-full py-3 rounded-xl bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 text-white font-semibold shadow-lg shadow-indigo-500/30 transition">
                Create Account
            </button>
        </form>

        <p class="text-center text-sm text-slate-500 mt-6">
            Already registered?
            <a href="${pageContext.request.contextPath}/login" class="font-semibold text-indigo-600 hover:text-indigo-700">Sign in</a>
        </p>
    </div>
</body>
</html>