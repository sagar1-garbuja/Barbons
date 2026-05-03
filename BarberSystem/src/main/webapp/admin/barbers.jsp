<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.BarberDAO, com.barbers.model.Barber, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
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
  <title>Barbers — BARBER'S Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<nav class="admin-navbar">
  <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-logo">BARBER'S</a>
  <ul class="admin-nav-links">
    <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Dashboard</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">Appointments</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp" class="active">Barbers</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Customers</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Services</a></li>
  </ul>
  <div class="admin-nav-right">
    <span class="admin-badge">Admin: <%= adminName %></span>
    <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
  </div>
</nav>

<div class="admin-content">
  <div class="page-header">
    <h1>Manage Barbers</h1>
    <p>Add new barbers and manage existing ones.</p>
  </div>

  <% if ("added".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Barber added successfully.</div>
  <% } else if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Barber updated.</div>
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
          <input type="text" name="name" class="form-control" placeholder="Barber's full name" required>
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
                <button type="button" class="btn btn-outline btn-sm edit-toggle-btn"
                        data-target="edit-barber-<%= b.getBarberId() %>">Edit</button>
                <form action="${pageContext.request.contextPath}/barber" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
                  <input type="hidden" name="currentStatus" value="<%= b.getIsActive() %>">
                  <button type="submit" class="btn btn-sm <%= b.getIsActive() == 1 ? "btn-danger" : "btn-success" %>">
                    <%= b.getIsActive() == 1 ? "Deactivate" : "Activate" %>
                  </button>
                </form>
              </div>
            </div>
            <!-- Inline edit form -->
            <div class="inline-edit-form" id="edit-barber-<%= b.getBarberId() %>">
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
                <button type="submit" class="btn btn-primary btn-sm">Save</button>
              </form>
            </div>
          </div>
        <% } %>
      </div>
    </div>

  </div>
</div>

<script src="${pageContext.request.contextPath}/js/admin.js"></script>
</body>
</html>
