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

  // Edit mode — pre-fill form if editId is passed
  String editIdParam = request.getParameter("editId");
  Barber editBarber = null;
  if (editIdParam != null) {
    try {
      int editId = Integer.parseInt(editIdParam);
      for (Barber b : barbers) {
        if (b.getBarberId() == editId) { editBarber = b; break; }
      }
    } catch (NumberFormatException ignored) {}
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Barbers — BARBON'S Admin</title>
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

    /* Name + Specialty in a 2-col row */
    .form-grid-top {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
    }

    .form-grid-top .form-group {
      margin-bottom: 0;
    }

    /* Bio row */
    .form-bio-row {
      margin-top: 20px;
    }

    .form-bio-row .form-group {
      margin-bottom: 0;
    }

    .form-bio-actions {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
      gap: 8px;
      margin-top: 16px;
    }

    /* ── Barbers table card ── */
    .table-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
    }

    .barbers-table {
      width: 100%;
      border-collapse: collapse;
      font-size: .88rem;
    }

    .barbers-table thead th {
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

    .barbers-table tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background var(--ease);
    }

    .barbers-table tbody tr:last-child {
      border-bottom: none;
    }

    .barbers-table tbody tr:hover {
      background: rgba(255,255,255,.03);
    }

    .barbers-table tbody td {
      padding: 16px 20px;
      vertical-align: middle;
      color: var(--text);
    }

    .barber-name {
      font-weight: 700;
      font-size: .92rem;
      color: var(--text);
    }

    .barber-specialty {
      color: var(--muted);
      font-size: .88rem;
    }

    .barber-bio {
      color: var(--muted);
      font-size: .85rem;
      max-width: 240px;
      line-height: 1.5;
    }

    .barber-actions {
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
      .form-bio-row  { grid-template-columns: 1fr; }
    }

    @media (max-width: 600px) {
      .admin-body  { padding: 20px 16px 40px; }
      .admin-topbar { padding: 0 16px; }
      .form-card   { padding: 20px 16px; }
    }
  </style>
</head>
<body>

<div class="admin-shell">

  <!---- ── Sidebar ── ---->
  <aside class="admin-sidebar">
    <div class="sidebar-brand">Barbon's Barber</div>
    <ul class="sidebar-nav">
      <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">View All Bookings</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp" class="active">Manage Barbers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a></li>
    </ul>
  </aside>

  <!-- ── Main ── -->
  <div class="admin-main">

    <!-- Top bar -->
    <div class="admin-topbar">
      <span class="page-title-bar">Manage Barbers</span>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="admin-badge">Admin: <%= adminName %></span>
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>

    <!-- Body -->
    <div class="admin-body">

      <!-- Page heading -->
      <div class="page-heading">
        <h1>Manage Barbers</h1>
        <p>Add new staff or remove existing barber</p>
      </div>

      <!-- Alerts -->
      <% if ("added".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Barber added successfully.</div>
      <% } else if ("updated".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Barber updated successfully.</div>
      <% } else if ("deleted".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Barber deleted.</div>
      <% } else if ("missing".equals(errorParam)) { %>
        <div class="alert alert-error">&#9888; Barber name is required.</div>
      <% } %>

      <!-- ── Add / Edit Form Card ── -->
      <div class="form-card">
        <div class="form-card-title">
          <%= editBarber != null ? "Edit Barber" : "Add and Edit Barber" %>
        </div>

        <form action="${pageContext.request.contextPath}/barber" method="post">
          <% if (editBarber != null) { %>
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="barberId" value="<%= editBarber.getBarberId() %>">
          <% } else { %>
            <input type="hidden" name="action" value="add">
          <% } %>

          <!-- Row 1: Name + Specialty -->
          <div class="form-grid-top">
            <div class="form-group">
              <label>Name</label>
              <input type="text" name="name" class="form-control"
                     placeholder="Name of barber"
                     value="<%= editBarber != null ? editBarber.getName() : "" %>"
                     required>
            </div>
            <div class="form-group">
              <label>Specialty</label>
              <input type="text" name="speciality" class="form-control"
                     placeholder="Specialty"
                     value="<%= editBarber != null && editBarber.getSpeciality() != null ? editBarber.getSpeciality() : "" %>">
            </div>
          </div>

          <!-- Row 2: Bio -->
          <div class="form-bio-row">
            <div class="form-group">
              <label>Bio</label>
              <textarea name="bio" class="form-control" rows="4"
                        placeholder="Short bio or experience summary..."><%= editBarber != null && editBarber.getBio() != null ? editBarber.getBio() : "" %></textarea>
            </div>
          </div>

          <!-- Confirm / Save — bottom right -->
          <div class="form-bio-actions">
            <% if (editBarber != null) { %>
              <a href="${pageContext.request.contextPath}/admin/barbers.jsp" class="btn btn-outline btn-sm">Cancel</a>
            <% } %>
            <button type="submit" class="btn btn-primary btn-sm">
              <%= editBarber != null ? "Save Changes" : "Confirm" %>
            </button>
          </div>
        </form>
      </div>

      <!-- ── Barbers Table Card ── -->
      <div class="table-card">
        <div class="table-wrap">
          <table class="barbers-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Specialty</th>
                <th>Experience Bio</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% if (barbers.isEmpty()) { %>
                <tr>
                  <td colspan="5" style="text-align:center;color:var(--muted);padding:32px;">
                    No barbers found. Add one above.
                  </td>
                </tr>
              <% } %>
              <% for (Barber b : barbers) { %>
                <tr>
                  <td class="barber-name"><%= b.getName() %></td>
                  <td class="barber-specialty">
                    <%= b.getSpeciality() != null && !b.getSpeciality().isEmpty()
                        ? b.getSpeciality() : "<span style='color:#555;'>—</span>" %>
                  </td>
                  <td class="barber-bio">
                    <%= b.getBio() != null && !b.getBio().isEmpty()
                        ? b.getBio() : "<span style='color:#555;'>—</span>" %>
                  </td>
                  <td>
                    <span class="badge <%= b.getIsActive() == 1 ? "badge-completed" : "badge-cancelled" %>">
                      <%= b.getIsActive() == 1 ? "Active" : "Inactive" %>
                    </span>
                  </td>
                  <td>
                    <div class="barber-actions">
                      <!-- Edit -->
                      <a href="${pageContext.request.contextPath}/admin/barbers.jsp?editId=<%= b.getBarberId() %>"
                         class="btn btn-outline btn-sm">Edit</a>

                      <!-- Active / Inactive toggle -->
                      <form action="${pageContext.request.contextPath}/barber" method="post">
                        <input type="hidden" name="action" value="toggle">
                        <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
                        <input type="hidden" name="currentStatus" value="<%= b.getIsActive() %>">
                        <button type="submit"
                                class="btn btn-sm <%= b.getIsActive() == 1 ? "btn-warning" : "btn-success" %>">
                          <%= b.getIsActive() == 1 ? "Deactivate" : "Activate" %>
                        </button>
                      </form>

                      <!-- Delete -->
                      <form action="${pageContext.request.contextPath}/barber" method="post"
                            onsubmit="return confirm('Delete this barber? This cannot be undone.');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="barberId" value="<%= b.getBarberId() %>">
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
