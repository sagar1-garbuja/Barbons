<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ServiceDAO, com.barbers.model.Service, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  ServiceDAO serviceDAO = new ServiceDAO();
  List<Service> services = serviceDAO.getAllServices();
  String successParam = request.getParameter("success");
  String errorParam   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Services — BARBER'S Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<nav class="admin-navbar">
  <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-logo">BARBER'S</a>
  <ul class="admin-nav-links">
    <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Dashboard</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">Appointments</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Barbers</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Customers</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/services.jsp" class="active">Services</a></li>
  </ul>
  <div class="admin-nav-right">
    <span class="admin-badge">Admin: <%= adminName %></span>
    <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
  </div>
</nav>

<div class="admin-content">
  <div class="page-header">
    <h1>Manage Services</h1>
    <p>Add new services and manage existing ones.</p>
  </div>

  <% if ("added".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Service added successfully.</div>
  <% } else if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Service updated.</div>
  <% } else if ("missing".equals(errorParam) || "invalid".equals(errorParam)) { %>
    <div class="alert alert-error">&#9888; Please fill in all required fields with valid values.</div>
  <% } %>

  <div class="admin-two-col">

    <!-- ADD FORM -->
    <div class="section-card">
      <div class="section-card-header"><h3>Add Service</h3></div>
      <form action="${pageContext.request.contextPath}/service" method="post">
        <input type="hidden" name="action" value="add">
        <div class="form-group">
          <label>Service Name *</label>
          <input type="text" name="serviceName" class="form-control" placeholder="e.g. Classic Haircut" required>
        </div>
        <div class="form-group">
          <label>Description</label>
          <textarea name="description" class="form-control" rows="3" placeholder="Brief description..."></textarea>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Price ($) *</label>
            <input type="number" name="price" class="form-control" placeholder="0.00" step="0.01" min="0.01" required>
          </div>
          <div class="form-group">
            <label>Duration (mins) *</label>
            <input type="number" name="duration" class="form-control" placeholder="30" min="1" required>
          </div>
        </div>
        <button type="submit" class="btn btn-primary">Add Service</button>
      </form>
    </div>

    <!-- MANAGE LIST -->
    <div class="section-card">
      <div class="section-card-header"><h3>Manage Services</h3></div>
      <div class="manage-list">
        <% if (services.isEmpty()) { %>
          <p style="color:var(--muted);font-size:.9rem;">No services yet.</p>
        <% } %>
        <% for (Service s : services) { %>
          <div>
            <div class="manage-item">
              <div class="item-info">
                <div class="item-name"><%= s.getServiceName() %></div>
                <div class="item-sub">
                  $<%= String.format("%.2f", s.getPrice()) %> &nbsp;·&nbsp; <%= s.getDurationMins() %> min
                  &nbsp;·&nbsp;
                  <span class="badge <%= s.getIsActive() == 1 ? "badge-completed" : "badge-cancelled" %>">
                    <%= s.getIsActive() == 1 ? "Active" : "Hidden" %>
                  </span>
                </div>
              </div>
              <div class="item-actions">
                <button type="button" class="btn btn-outline btn-sm edit-toggle-btn"
                        data-target="edit-svc-<%= s.getServiceId() %>">Edit</button>
                <form action="${pageContext.request.contextPath}/service" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                  <input type="hidden" name="currentStatus" value="<%= s.getIsActive() %>">
                  <button type="submit" class="btn btn-sm <%= s.getIsActive() == 1 ? "btn-warning" : "btn-success" %>">
                    <%= s.getIsActive() == 1 ? "Hide" : "Show" %>
                  </button>
                </form>
              </div>
            </div>
            <!-- Inline edit -->
            <div class="inline-edit-form" id="edit-svc-<%= s.getServiceId() %>">
              <form action="${pageContext.request.contextPath}/service" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                <div class="form-group">
                  <label>Service Name</label>
                  <input type="text" name="serviceName" class="form-control" value="<%= s.getServiceName() %>" required>
                </div>
                <div class="form-group">
                  <label>Description</label>
                  <textarea name="description" class="form-control" rows="2"><%= s.getDescription() != null ? s.getDescription() : "" %></textarea>
                </div>
                <div class="form-row">
                  <div class="form-group">
                    <label>Price ($)</label>
                    <input type="number" name="price" class="form-control" value="<%= s.getPrice() %>" step="0.01" min="0.01" required>
                  </div>
                  <div class="form-group">
                    <label>Duration (mins)</label>
                    <input type="number" name="duration" class="form-control" value="<%= s.getDurationMins() %>" min="1" required>
                  </div>
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
