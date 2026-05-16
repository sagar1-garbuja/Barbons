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

  // For edit mode — pre-fill form if editId is passed
  String editIdParam = request.getParameter("editId");
  Service editService = null;
  if (editIdParam != null) {
    try {
      int editId = Integer.parseInt(editIdParam);
      for (Service s : services) {
        if (s.getServiceId() == editId) { editService = s; break; }
      }
    } catch (NumberFormatException ignored) {}
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Services — BARBON'S Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
  <style>
    /* ── Sidebar layout ── */
    .admin-shell {
      display: flex;
      min-height: 100vh;
    }

    .admin-sidebar {
      width: 240px;
      flex-shrink: 0;
      background: var(--surface);
      border-right: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      padding: 28px 0 24px;
      position: sticky;
      top: 0;
      height: 100vh;
      overflow-y: auto;
    }

    .sidebar-brand {
      font-family: 'Playfair Display', serif;
      font-size: 1.25rem;
      font-weight: 700;
      color: var(--text);
      padding: 0 24px 28px;
      border-bottom: 1px solid var(--border);
      letter-spacing: .04em;
    }

    .sidebar-nav {
      list-style: none;
      margin-top: 16px;
      flex: 1;
    }

    .sidebar-nav li a {
      display: block;
      padding: 12px 24px;
      font-size: .88rem;
      font-weight: 500;
      color: var(--muted);
      text-decoration: none;
      transition: color var(--ease), background var(--ease);
      border-left: 3px solid transparent;
    }

    .sidebar-nav li a:hover {
      color: var(--text);
      background: rgba(255,255,255,.04);
    }

    .sidebar-nav li a.active {
      color: var(--text);
      background: rgba(255,255,255,.07);
      border-left-color: var(--accent);
      font-weight: 600;
    }

    /* ── Main area ── */
    .admin-main {
      flex: 1;
      display: flex;
      flex-direction: column;
      min-width: 0;
    }

    .admin-topbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 36px;
      height: 60px;
      border-bottom: 1px solid var(--border);
      background: var(--surface);
      position: sticky;
      top: 0;
      z-index: 50;
    }

    .admin-topbar .page-title-bar {
      font-family: 'Playfair Display', serif;
      font-size: 1.1rem;
      font-weight: 600;
      color: var(--text);
    }

    .admin-body {
      padding: 32px 36px 60px;
      flex: 1;
    }

    /* ── Page heading ── */
    .page-heading {
      margin-bottom: 24px;
    }

    .page-heading h1 {
      font-family: 'Playfair Display', serif;
      font-size: 1.9rem;
      font-weight: 700;
      color: var(--text);
      margin-bottom: 4px;
    }

    .page-heading p {
      font-size: .88rem;
      color: var(--muted);
    }

    /* ── Form card ── */
    .form-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 28px 32px;
      margin-bottom: 28px;
    }

    .form-card-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.05rem;
      font-weight: 600;
      color: var(--text);
      margin-bottom: 22px;
    }

    .form-grid-top {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 0;
    }

    .form-grid-top .form-group {
      margin-bottom: 0;
    }

    .form-full {
      margin-top: 20px;
    }

    .form-full .form-group {
      margin-bottom: 0;
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-top: 22px;
    }

    /* ── Services table card ── */
    .table-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
    }

    .services-table {
      width: 100%;
      border-collapse: collapse;
      font-size: .88rem;
    }

    .services-table thead th {
      background: var(--surface2);
      color: var(--muted);
      font-size: .75rem;
      font-weight: 700;
      letter-spacing: .07em;
      text-transform: uppercase;
      padding: 13px 20px;
      text-align: left;
      border-bottom: 1px solid var(--border);
    }

    .services-table tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background var(--ease);
    }

    .services-table tbody tr:last-child {
      border-bottom: none;
    }

    .services-table tbody tr:hover {
      background: rgba(255,255,255,.03);
    }

    .services-table tbody td {
      padding: 16px 20px;
      vertical-align: middle;
      color: var(--text);
    }

    .svc-name {
      font-weight: 700;
      font-size: .92rem;
      color: var(--text);
    }

    .svc-price {
      color: var(--muted);
      font-size: .88rem;
    }

    .svc-duration {
      color: var(--muted);
      font-size: .88rem;
    }

    .svc-desc {
      color: var(--muted);
      font-size: .85rem;
      max-width: 260px;
      line-height: 1.5;
    }

    .svc-actions {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }

    /* ── Responsive ── */
    @media (max-width: 900px) {
      .admin-sidebar { display: none; }
      .form-grid-top { grid-template-columns: 1fr; }
    }

    @media (max-width: 600px) {
      .admin-body { padding: 20px 16px 40px; }
      .admin-topbar { padding: 0 16px; }
      .form-card { padding: 20px 16px; }
    }
  </style>
</head>
<body>

<div class="admin-shell">

  <!-- ── Sidebar ── -->
  <aside class="admin-sidebar">
    <div class="sidebar-brand">Barbon's Barber</div>
    <ul class="sidebar-nav">
      <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">View All Bookings</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/services.jsp" class="active">Manage Services</a></li>
    </ul>
  </aside>

  <!-- ── Main ── -->
  <div class="admin-main">

    <!-- Top bar -->
    <div class="admin-topbar">
      <span class="page-title-bar">Manage Services</span>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="admin-badge">Admin: <%= adminName %></span>
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>

    <!-- Body -->
    <div class="admin-body">

      <!-- Page heading -->
      <div class="page-heading">
        <h1>Manage Services</h1>
        <p>Add, edit or remove services</p>
      </div>

      <!-- Alerts -->
      <% if ("added".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Service added successfully.</div>
      <% } else if ("updated".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Service updated successfully.</div>
      <% } else if ("deleted".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Service deleted.</div>
      <% } else if ("missing".equals(errorParam) || "invalid".equals(errorParam)) { %>
        <div class="alert alert-error">&#9888; Please fill in all required fields with valid values.</div>
      <% } %>

      <!-- ── Add / Edit Form Card ── -->
      <div class="form-card">
        <div class="form-card-title">
          <%= editService != null ? "Edit Service" : "Add and Edit Service" %>
        </div>

        <form action="${pageContext.request.contextPath}/service" method="post">
          <% if (editService != null) { %>
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="serviceId" value="<%= editService.getServiceId() %>">
          <% } else { %>
            <input type="hidden" name="action" value="add">
          <% } %>

          <!-- Row 1: Name + Price -->
          <div class="form-grid-top">
            <div class="form-group">
              <label>Service Name</label>
              <input type="text" name="serviceName" class="form-control"
                     placeholder="Name of service"
                     value="<%= editService != null ? editService.getServiceName() : "" %>"
                     required>
            </div>
            <div class="form-group">
              <label>Price (Rs.)</label>
              <input type="number" name="price" class="form-control"
                     placeholder="Price Rs."
                     value="<%= editService != null ? editService.getPrice() : "" %>"
                     step="0.01" min="0.01" required>
            </div>
          </div>

          <!-- Row 2: Duration -->
          <div class="form-full">
            <div class="form-group">
              <label>Duration (Min.)</label>
              <input type="number" name="duration" class="form-control"
                     placeholder="Enter time (Mins.)"
                     value="<%= editService != null ? editService.getDurationMins() : "" %>"
                     min="1" required style="max-width: 50%;">
            </div>
          </div>

          <!-- Row 3: Description -->
          <div class="form-full">
            <div class="form-group">
              <label>Description</label>
              <textarea name="description" class="form-control" rows="4"
                        placeholder="Brief description of the service..."><%= editService != null && editService.getDescription() != null ? editService.getDescription() : "" %></textarea>
            </div>
          </div>

          <!-- Actions -->
          <div class="form-actions">
            <% if (editService != null) { %>
              <a href="${pageContext.request.contextPath}/admin/services.jsp" class="btn btn-outline btn-sm">Cancel</a>
            <% } %>
            <button type="submit" class="btn btn-primary btn-sm">
              <%= editService != null ? "Save Changes" : "Confirm" %>
            </button>
          </div>
        </form>
      </div>

      <!-- ── Services Table Card ── -->
      <div class="table-card">
        <div class="table-wrap">
          <table class="services-table">
            <thead>
              <tr>
                <th>Services</th>
                <th>Price</th>
                <th>Duration (Mins)</th>
                <th>Description</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% if (services.isEmpty()) { %>
                <tr>
                  <td colspan="5" style="text-align:center;color:var(--muted);padding:32px;">
                    No services found. Add one above.
                  </td>
                </tr>
              <% } %>
              <% for (Service s : services) { %>
                <tr>
                  <td class="svc-name"><%= s.getServiceName() %></td>
                  <td class="svc-price">Rs. <%= String.format("%.0f", s.getPrice()) %></td>
                  <td class="svc-duration"><%= s.getDurationMins() %> Mins</td>
                  <td class="svc-desc">
                    <%= s.getDescription() != null && !s.getDescription().isEmpty()
                        ? s.getDescription() : "<span style='color:#555;'>—</span>" %>
                  </td>
                  <td>
                    <div class="svc-actions">
                      <a href="${pageContext.request.contextPath}/admin/services.jsp?editId=<%= s.getServiceId() %>"
                         class="btn btn-outline btn-sm">Edit</a>
                      <form action="${pageContext.request.contextPath}/service" method="post"
                            onsubmit="return confirm('Delete this service?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                      </form>
                    </div>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

    </div><!-- /admin-body -->
  </div><!-- /admin-main -->
</div><!-- /admin-shell -->

</body>
</html>
