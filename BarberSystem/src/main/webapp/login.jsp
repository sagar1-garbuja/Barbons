<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.util.CookieUtils" %>
<%
  // Pre-fill email from remember-me cookie
  String rememberedEmail = CookieUtils.getRememberMe(request);
  String prefillEmail = (request.getAttribute("email") != null)
      ? (String) request.getAttribute("email")
      : (rememberedEmail != null ? rememberedEmail : "");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── LEFT PANEL ── -->
  <div class="auth-left">
    <div class="auth-logo">BARBER'S</div>

    <div class="auth-left-body">
      <h1>Welcome <em>back.</em></h1>
      <p>Manage your bookings, track appointments, and keep your style on point — all in one place.</p>
    </div>

    <div class="auth-stats">
      <div class="auth-stat">
        <strong>5+</strong>
        <span>Barbers</span>
      </div>
      <div class="auth-stat">
        <strong>10+</strong>
        <span>Services</span>
      </div>
      <div class="auth-stat">
        <strong>&#9733; 4.9</strong>
        <span>Rating</span>
      </div>
    </div>
  </div>

  <!-- ── RIGHT PANEL ── -->
  <div class="auth-right">
    <div class="auth-form-header">
      <h2>Welcome Back</h2>
      <p>Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp">Sign up free</a></p>
    </div>

    <!-- Server messages -->
    <% if (request.getAttribute("errorMsg") != null) { %>
      <div class="alert alert-error">
        <span>&#9888;</span> <%= request.getAttribute("errorMsg") %>
      </div>
    <% } %>
    <% if (request.getAttribute("successMsg") != null) { %>
      <div class="alert alert-success">
        <span>&#10003;</span> <%= request.getAttribute("successMsg") %>
      </div>
    <% } %>

    <form id="loginForm" action="${pageContext.request.contextPath}/auth" method="post" novalidate>
      <input type="hidden" name="action" value="login">

      <!-- Email -->
      <div class="form-group">
        <label for="email">Email Address</label>
        <input type="email" id="email" name="email" class="form-control"
               placeholder="you@example.com"
               value="<%= prefillEmail %>"
               autocomplete="email">
        <div class="field-error" id="err-email"></div>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label for="password">Password</label>
        <div class="password-wrap">
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Your password" autocomplete="current-password">
          <button type="button" class="eye-toggle" aria-label="Toggle password visibility">&#128065;</button>
        </div>
        <div class="field-error" id="err-password"></div>
      </div>

      <!-- Remember me -->
      <div class="form-group">
        <label class="checkbox-row">
          <input type="checkbox" name="rememberMe" value="on"
                 <%= rememberedEmail != null ? "checked" : "" %>>
          Remember me for 7 days
        </label>
      </div>

      <div class="auth-divider">or</div>

      <button type="submit" class="btn btn-primary">Sign In</button>
      <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-outline">Create New Account</a>
    </form>
  </div>

</div>

<script src="${pageContext.request.contextPath}/js/auth.js"></script>
</body>
</html>
