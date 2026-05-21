<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.BarberDAO, com.barbers.model.Barber, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  String adminPic  = (String) session.getAttribute("profilePicture");
  BarberDAO barberDAO = new BarberDAO();
  List<Barber> barbers = barberDAO.getAllBarbers();
  String successParam = request.getParameter("success");
  String errorParam   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Barbers — BARBONS BARBER Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>
<div class="admin-sidebar">
  <div class="admin-sidebar-brand">
    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp">
      Barbon's Barber<span>Admin Panel</span>
    </a>
  </div>
  <nav class="admin-sidebar-nav">
    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/appointments.jsp">View All Bookings</a>
    <a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a>
    <a href="${pageContext.request.contextPath}/admin/barbers.jsp" class="active">Manage Barbers</a>
    <a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a>
  </nav>
</div>

<div class="admin-main">
  <div class="admin-header">
    <span class="admin-header-title">Manage Barbers</span>
    <div class="admin-header-right">
      <span class="admin-header-user">Admin</span>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    </div>
  </div>

  <div class="admin-content">
<div class="page-header">
    <h1>Manage Barbers</h1>
    <p>Add new barbers and manage existing ones.</p>
  </div>

  <% if ("added".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Barber added successfully.</div>
  <% } else if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Barber updated.</div>
  <% } else if ("deleted".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Barber deleted successfully.</div>
  <% } else if ("missing".equals(errorParam)) { %>
    <div class="alert alert-error">&#9888; Barber name is required.</div>
  <% } %>

  <div class="admin-two-col">

    <!-- ADD FORM -->
    <div class="section-card">
      <div class="section-card-header"><h3>Add Barber</h3></div>
      <form action="${pageContext.request.contextPath}/barber" method="post">
        <input type="hidden" name="action" value="add">
        <div class="form-group">
          <label>Name *</label>
          <input type="text" name="name" class="form-control" placeholder="BARBONS BARBER full name" required>
        </div>
        <div class="form-group">
          <label>Speciality</label>
          <input type="text" name="speciality" class="form-control" placeholder="e.g. Fades & Tapers">
        </div>
        <div class="form-group">
          <label>Bio</label>
          <textarea name="bio" class="form-control" rows="3" placeholder="Short bio..."></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Add Barber</button>
      </form>
    </div>

    <!-- MANAGE LIST -->
    <div class="section-card">
      <div class="section-card-header"><h3>Manage Barbers</h3></div>
      <div class="manage-list">
        <% if (barbers.isEmpty()) { %>
          <p style="color:var(--muted);font-size:.9rem;">No barbers yet.</p>
        <% } %>
        <% for (Barber b : barbers) { %>
          <div>
            <div class="manage-item">
              <div class="item-info">
                <div class="item-name"><%= b.getName() %></div>
                <div class="item-sub"><%= b.getSpeciality() != null ? b.getSpeciality() : "" %>
                  &nbsp;·&nbsp;
                  <span class="badge <%= b.getIsActive() == 1 ? "badge-completed" : "badge-cancelled" %>">
                    <%= b.getIsActive() == 1 ? "Active" : "Inactive" %>
                  </span>
                </div>
              </div>
              <div class="item-actions">
                <form action="${pageContext.request.contextPath}/barber" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
                  <input type="hidden" name="currentStatus" value="<%= b.getIsActive() %>">
                  <button type="submit" class="btn btn-sm <%= b.getIsActive() == 1 ? "btn-danger" : "btn-success" %>">
                    <%= b.getIsActive() == 1 ? "Deactivate" : "Activate" %>
                  </button>
                </form>
                <form action="${pageContext.request.contextPath}/barber" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
                  <button type="submit" class="btn btn-danger btn-sm"
                          onclick="return confirm('Permanently delete <%= b.getName().replace("'","&#39;") %>?')">Delete</button>
                </form>
              </div>
            </div>
            <!-- Inline edit — no JS needed, uses HTML details/summary -->
            <details style="margin-top:8px;">
              <summary style="cursor:pointer;font-size:.82rem;font-weight:600;color:var(--accent);
                              padding:8px 0;list-style:none;user-select:none;">&#9998; Edit details</summary>
              <div style="padding:16px;background:var(--surface);border:1px solid var(--border);
                          border-radius:var(--radius);margin-top:6px;">
                <form action="${pageContext.request.contextPath}/barber" method="post">
                  <input type="hidden" name="action" value="update">
                  <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
                  <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" class="form-control" value="<%= b.getName() %>" required>
                  </div>
                  <div class="form-group">
                    <label>Speciality</label>
                    <input type="text" name="speciality" class="form-control"
                           value="<%= b.getSpeciality() != null ? b.getSpeciality() : "" %>">
                  </div>
                  <div class="form-group">
                    <label>Bio</label>
                    <textarea name="bio" class="form-control" rows="2"><%= b.getBio() != null ? b.getBio() : "" %></textarea>
                  </div>
                  <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                </form>
              </div>
            </details>
          </div>
        <% } %>
      </div>
    </div>

  </div>
</div>
  </div>
</div>
</body>
</html>
