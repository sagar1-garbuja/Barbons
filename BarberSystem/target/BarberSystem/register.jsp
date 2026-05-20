<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── LEFT PANEL ── -->
  <div class="auth-left">
    <div class="auth-logo">BARBONS BARBER</div>

    <div class="auth-left-body">
      <h1>Sharp cuts.<br><em>Sharper</em> booking.</h1>
      <p>Book your next appointment in seconds. No waiting, no hassle — just great haircuts on your schedule.</p>
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

    <form id="registerForm" action="${pageContext.request.contextPath}/auth" method="post">
      <input type="hidden" name="action" value="register">

      <!-- Full Name -->
      <div class="form-group">
        <label for="fullName">Full Name</label>
        <input type="text" id="fullName" name="fullName" class="form-control"
               placeholder="Full Name"
               value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>"
               autocomplete="name">
      </div>

      <!-- Email + Phone row -->
      <div class="form-row">
        <div class="form-group">
          <label for="email">Email Address</label>
          <input type="email" id="email" name="email" class="form-control"
                 placeholder="Email Address"
                 value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                 autocomplete="email">
        </div>
        <div class="form-group">
          <label for="phone">Phone Number</label>
          <input type="tel" id="phone" name="phone" class="form-control"
                 placeholder="Phone Number"
                 value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>"
                 autocomplete="tel">
        </div>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label for="password">Password</label>
        <div class="password-wrap">
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Min 8 chars, 1 number" autocomplete="new-password">
        </div>
      </div>

      <!-- Confirm Password -->
      <div class="form-group">
        <label for="confirmPassword">Confirm Password</label>
        <div class="password-wrap">
          <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                 placeholder="Repeat password" autocomplete="new-password">
        </div>
      </div>

      <div class="auth-divider">or</div>

      <button type="submit" class="btn btn-primary">Create Account</button>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline">Sign In Instead</a>
    </form>
  </div>

</div>
</body>
</html>
