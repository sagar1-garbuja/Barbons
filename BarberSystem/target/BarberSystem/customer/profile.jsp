<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.UserDAO, com.barbers.model.User" %>
<%
  if (session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  int    userId   = (Integer) session.getAttribute("userId");
  String fullName = (String)  session.getAttribute("fullName");

  UserDAO userDAO = new UserDAO();
  User user = userDAO.getUserById(userId);

  // Sync profile picture into session so sidebar stays current
  String picFile = (user != null && user.getProfilePicture() != null)
                   ? user.getProfilePicture() : null;
  if (picFile != null) session.setAttribute("profilePicture", picFile);

  String picUrl = (picFile != null)
      ? request.getContextPath() + "/uploads/profiles/" + picFile
      : null;

  String picSuccess     = (String) request.getAttribute("picSuccess");
  String picError       = (String) request.getAttribute("picError");
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
  <title>Profile — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
  <style>
    /* ── Profile picture card ── */
    .pic-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 32px 24px;
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      gap: 32px;
    }
    .pic-preview-wrap { flex-shrink: 0; }
    .pic-preview {
      width: 110px; height: 110px;
      border-radius: 50%;
      object-fit: cover;
      border: 3px solid var(--border);
      display: block;
    }
    .pic-placeholder {
      width: 110px; height: 110px;
      border-radius: 50%;
      background: var(--surface2);
      border: 3px solid var(--border);
      display: flex; align-items: center; justify-content: center;
      font-size: 2.8rem; color: var(--muted);
    }
    .pic-info { flex: 1; }
    .pic-info h3 {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; font-weight: 700;
      color: var(--text); margin-bottom: 4px;
    }
    .pic-info p { font-size: .85rem; color: var(--muted); margin-bottom: 16px; }
    .pic-upload-row {
      display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
    }
    /* Style the native file input to look like a button */
    input[type="file"].pic-file-input {
      font-family: 'DM Sans', sans-serif;
      font-size: .85rem; color: var(--muted);
      background: var(--surface2);
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm);
      padding: 8px 14px;
      cursor: pointer;
      max-width: 260px;
    }
    input[type="file"].pic-file-input::-webkit-file-upload-button {
      background: var(--nav-bg); color: #fff;
      border: none; border-radius: 4px;
      padding: 6px 12px; font-size: .82rem;
      cursor: pointer; margin-right: 10px;
    }
  </style>
</head>
<body>
<div class="customer-layout">

  <!-- ── TOP NAVBAR ── -->
  <nav class="customer-navbar">
    <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="nav-logo">BARBONS BARBER</a>
    <ul class="customer-nav-links">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/dashboard.jsp">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">My Appointments</a></li>
      <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
      <li><a href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
    </ul>
    <div class="customer-nav-right">
      <div class="customer-nav-avatar">
        <% if (picUrl != null) { %>
          <img src="<%= picUrl %>" alt="Profile"
               style="width:34px;height:34px;border-radius:50%;object-fit:cover;display:block;">
        <% } else { %>&#128100;<% } %>
      </div>
      <span class="customer-nav-name"><%= fullName %></span>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="btn btn-outline-light btn-sm active">Profile</a>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    </div>
  </nav>

  <!-- ── MAIN ── -->
  <main class="main-content">
    <div class="page-header">
      <h1>My Profile</h1>
      <p>Update your photo, personal information, and password.</p>
    </div>

    <!-- ── PROFILE PICTURE CARD ── -->
    <div class="pic-card">
      <div class="pic-preview-wrap">
        <% if (picUrl != null) { %>
          <img src="<%= picUrl %>" alt="Profile picture" class="pic-preview">
        <% } else { %>
          <div class="pic-placeholder">&#128100;</div>
        <% } %>
      </div>

      <div class="pic-info">
        <h3><%= fullName %></h3>
        <p>JPG, PNG, GIF or WEBP &nbsp;·&nbsp; Max 3 MB</p>

        <% if (picSuccess != null) { %>
          <div class="alert alert-success" style="margin-bottom:12px;">&#10003; <%= picSuccess %></div>
        <% } %>
        <% if (picError != null) { %>
          <div class="alert alert-error" style="margin-bottom:12px;">&#9888; <%= picError %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/profile"
              method="post" enctype="multipart/form-data">
          <input type="hidden" name="action" value="uploadPicture">
          <div class="pic-upload-row">
            <input type="file" name="profilePicture" class="pic-file-input"
                   accept="image/jpeg,image/png,image/gif,image/webp" required>
            <button type="submit" class="btn btn-primary btn-sm">Save Photo</button>
          </div>
        </form>
      </div>
    </div>

    <!-- ── EDIT PROFILE + CHANGE PASSWORD ── -->
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


<!-- -- MOBILE BOTTOM NAV -- -->
</div>
</body>
</html>
