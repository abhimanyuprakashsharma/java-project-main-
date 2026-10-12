<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%
    Integer status = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (status == null && response.getStatus() != 200) status = response.getStatus();
    String message = (String) request.getAttribute("jakarta.servlet.error.message");
    if (message == null || message.isBlank()) message = "An unexpected error occurred while processing your request. Please try again or return to the main store.";
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%= status != null ? status + " — Trendify Boutique" : "Notice — Trendify Boutique" %></title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/app.css">
    <style>
        body { background: var(--bg); color: var(--text); display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; font-family: var(--sans); }
        .error-card { background: var(--surface); border: 1px solid var(--line); border-radius: 16px; padding: 44px; max-width: 480px; width: 90%; text-align: center; box-shadow: var(--shadow-lg); }
        .error-code { font-family: var(--serif); font-size: 56px; font-weight: 600; color: var(--accent); margin: 10px 0; letter-spacing: 2px; }
        .error-msg { color: var(--muted); font-size: 14px; line-height: 1.6; margin-bottom: 28px; }
    </style>
</head>
<body>
<div class="error-card">
    <span class="eyebrow" style="letter-spacing:2px; font-size:11px; text-transform:uppercase;">TRENDIFY ATELIER</span>
    <h1 class="error-code"><%= status == null ? "Notice" : status %></h1>
    <p class="error-msg"><%= message %></p>
    <div style="display:flex; gap:12px; justify-content:center;">
        <a class="btn" href="<%= ctx %>/products">Browse Collections</a>
        <a class="btn secondary" href="<%= ctx %>/">Home Page</a>
    </div>
</div>
</body>
</html>
