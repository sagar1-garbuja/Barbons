<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.UserDAO, com.barbers.model.User" %>
<%
  // ── Session guard ──
  if (session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  int    userId   = (Integer) session.getAttribute("userId");
  String fullName = (String)  session.getAttribute("fullName");

  UserDAO userDAO = new UserDAO();
  User user = userDAO.getUserById(userId);

  String profileSuccess = (String) request.getAttribute("profileSuccess");
  String profileError   = (String) request.getAttribute("profileError");
  String pwdSuccess     = (String) request.getAttribute("pwdSuccess");
  String pwdError       = (String) request.getAttribute("pwdError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
</head>
<body>
<div class="customer-layout">

  <!-- ── SIDEBAR ── -->
  <aside class="sidebar">
    <div class="sidebar-brand"><span class="logo">BARBER'S</span></div>
    <div class="sidebar-user">
      <div class="user-avatar">&#128100;</div>
      <div class="user-name"><%= fullName %></div>
      <div class="user-role">Customer</div>
    </div>
    <nav class="sidebar-nav">
      <a href="${pageContext.request.contextPath}/customer/dashboard.jsp">&#9632; Dashboard</a>
      <a href="${pageContext.request.contextPath}/customer/book.jsp">&#43; Book Appointment</a>
      <a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">&#128197; My Appointments</a>
      <a href="${pageContext.request.contextPath}/reviews.jsp">&#9733; Reviews</a>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="active">&#9881; Profile</a>
    </nav>
    <div class="sidebar-footer">
      <a href="${pageContext.request.contextPath}/auth?action=logout">&#8594; Logout</a>
    </div>
  </aside>

  <!-- ── MAIN ── -->
  <main class="main-content">
    <div class="page-header">
      <h1>My Profile</h1>
      <p>Update your personal information and password.</p>
    </div>

    <div class="profile-grid">

      <!-- Edit Profile -->
      <div class="section-card">
        <h3>Edit Profile</h3>
        <% if (profileSuccess != null) { %>
          <div class="alert alert-success">&#10003; <%= profileSuccess %></div>
        <% } %>
        <% if (profileError != null) { %>
          <div class="alert alert-error">&#9888; <%= profileError %></div>
        <% } %>
        <form action="${pageContext.request.contextPath}/profile" method="post">
          <input type="hidden" name="action" value="updateProfile">
          <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="fullName" class="form-control"
                   value="<%= user != null ? user.getFullName() : "" %>" required>
          </div>
          <div class="form-group">
            <label>Email Address</label>
            <input type="email" name="email" class="form-control"
                   value="<%= user != null ? user.getEmail() : "" %>" required>
          </div>
          <div class="form-group">
            <label>Phone Number</label>
            <input type="tel" name="phone" class="form-control"
                   value="<%= user != null ? user.getPhone() : "" %>" required>
          </div>
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </form>
      </div>

      <!-- Change Password -->
      <div class="section-card">
        <h3>Change Password</h3>
        <% if (pwdSuccess != null) { %>
          <div class="alert alert-success">&#10003; <%= pwdSuccess %></div>
        <% } %>
        <% if (pwdError != null) { %>
          <div class="alert alert-error">&#9888; <%= pwdError %></div>
        <% } %>
        <form action="${pageContext.request.contextPath}/profile" method="post">
          <input type="hidden" name="action" value="changePassword">
          <div class="form-group">
            <label>Current Password</label>
            <input type="password" name="currentPassword" class="form-control"
                   placeholder="Enter current password" required>
          </div>
          <div class="form-group">
            <label>New Password</label>
            <input type="password" name="newPassword" class="form-control"
                   placeholder="Min 8 chars, 1 number" required>
          </div>
          <div class="form-group">
            <label>Confirm New Password</label>
            <input type="password" name="confirmPassword" class="form-control"
                   placeholder="Repeat new password" required>
          </div>
          <button type="submit" class="btn btn-primary">Update Password</button>
        </form>
      </div>

    </div>
  </main>

</div>
</body>
</html>
