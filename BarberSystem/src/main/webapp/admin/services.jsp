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
  <title>Services — BARBONS BARBER Admin</title>
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
    <a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a>
    <a href="${pageContext.request.contextPath}/admin/services.jsp" class="active">Manage Services</a>
  </nav>
</div>

<div class="admin-main">
  <div class="admin-header">
    <span class="admin-header-title">Manage Services</span>
    <div class="admin-header-right">
      <span class="admin-header-user">Admin: <strong><%= adminName %></strong></span>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-outline-light btn-sm">Logout</a>
    </div>
  </div>

  <div class="admin-content">
<div class="page-header">
    <h1>Manage Services</h1>
    <p>Add new services and manage existing ones.</p>
  </div>

  <% if ("added".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Service added successfully.</div>
  <% } else if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Service updated.</div>
  <% } else if ("deleted".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Service deleted successfully.</div>
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
            <label>Price (Rs.) *</label>
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
                  Rs. <%= String.format("%.2f", s.getPrice()) %> &nbsp;·&nbsp; <%= s.getDurationMins() %> min
                  &nbsp;·&nbsp;
                  <span class="badge <%= s.getIsActive() == 1 ? "badge-completed" : "badge-cancelled" %>">
                    <%= s.getIsActive() == 1 ? "Active" : "Hidden" %>
                  </span>
                </div>
              </div>
              <div class="item-actions">
                <form action="${pageContext.request.contextPath}/service" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                  <input type="hidden" name="currentStatus" value="<%= s.getIsActive() %>">
                  <button type="submit" class="btn btn-sm <%= s.getIsActive() == 1 ? "btn-warning" : "btn-success" %>">
                    <%= s.getIsActive() == 1 ? "Hide" : "Show" %>
                  </button>
                </form>
                <form action="${pageContext.request.contextPath}/service" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                  <button type="submit" class="btn btn-danger btn-sm"
                          onclick="return confirm('Delete <%= s.getServiceName().replace("'","&#39;") %>?')">Delete</button>
                </form>
              </div>
            </div>
            <!-- Inline edit — HTML details/summary, no JS -->
            <details style="margin-top:8px;">
              <summary style="cursor:pointer;font-size:.82rem;font-weight:600;color:var(--accent);
                              padding:8px 0;list-style:none;user-select:none;">&#9998; Edit details</summary>
              <div style="padding:16px;background:var(--surface);border:1px solid var(--border);
                          border-radius:var(--radius);margin-top:6px;">
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
                      <label>Price (Rs.)</label>
                      <input type="number" name="price" class="form-control" value="<%= s.getPrice() %>" step="0.01" min="0.01" required>
                    </div>
                    <div class="form-group">
                      <label>Duration (mins)</label>
                      <input type="number" name="duration" class="form-control" value="<%= s.getDurationMins() %>" min="1" required>
                    </div>
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
