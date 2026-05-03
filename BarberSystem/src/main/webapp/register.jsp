<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── LEFT PANEL ── -->
  <div class="auth-left">
    <div class="auth-logo">BARBER'S</div>

    <div class="auth-left-body">
      <h1>Sharp cuts.<br><em>Sharper</em> booking.</h1>
      <p>Book your next appointment in seconds. No waiting, no hassle — just great haircuts on your schedule.</p>
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
        <strong>500+</strong>
        <span>Happy Clients</span>
      </div>
    </div>
  </div>

  <!-- ── RIGHT PANEL ── -->
  <div class="auth-right">
    <div class="auth-form-header">
      <h2>Create Your Account</h2>
      <p>Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Sign in</a></p>
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

    <form id="registerForm" action="${pageContext.request.contextPath}/auth" method="post" novalidate>
      <input type="hidden" name="action" value="register">

      <!-- Full Name -->
      <div class="form-group">
        <label for="fullName">Full Name</label>
        <input type="text" id="fullName" name="fullName" class="form-control"
               placeholder="John Doe"
               value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>"
               autocomplete="name">
        <div class="field-error" id="err-fullName"></div>
      </div>

      <!-- Email + Phone row -->
      <div class="form-row">
        <div class="form-group">
          <label for="email">Email Address</label>
          <input type="email" id="email" name="email" class="form-control"
                 placeholder="you@example.com"
                 value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                 autocomplete="email">
          <div class="field-error" id="err-email"></div>
        </div>
        <div class="form-group">
          <label for="phone">Phone Number</label>
          <input type="tel" id="phone" name="phone" class="form-control"
                 placeholder="10-digit number"
                 value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>"
                 autocomplete="tel">
          <div class="field-error" id="err-phone"></div>
        </div>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label for="password">Password</label>
        <div class="password-wrap">
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Min 8 chars, 1 number" autocomplete="new-password">
          <button type="button" class="eye-toggle" aria-label="Toggle password visibility">&#128065;</button>
        </div>
        <div class="strength-bar-wrap">
          <div class="strength-bar"><div class="strength-fill"></div></div>
          <span class="strength-label"></span>
        </div>
        <div class="field-error" id="err-password"></div>
      </div>

      <!-- Confirm Password -->
      <div class="form-group">
        <label for="confirmPassword">Confirm Password</label>
        <div class="password-wrap">
          <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                 placeholder="Repeat password" autocomplete="new-password">
          <button type="button" class="eye-toggle" aria-label="Toggle password visibility">&#128065;</button>
        </div>
        <div class="field-error" id="err-confirmPassword"></div>
      </div>

      <div class="auth-divider">or</div>

      <button type="submit" class="btn btn-primary">Create Account</button>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline">Sign In Instead</a>
    </form>
  </div>

</div>

<script src="${pageContext.request.contextPath}/js/auth.js"></script>
</body>
</html>
