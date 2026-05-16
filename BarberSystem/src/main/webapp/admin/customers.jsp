<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.UserDAO, com.barbers.model.User, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  UserDAO userDAO  = new UserDAO();
  String searchQ   = request.getParameter("q") != null ? request.getParameter("q").trim() : "";
  List<User> customers = userDAO.getAllCustomers();
  // Filter server-side by name or email
  if (!searchQ.isEmpty()) {
    java.util.Iterator<User> it = customers.iterator();
    while (it.hasNext()) {
      User u = it.next();
      String name  = u.getFullName() != null ? u.getFullName().toLowerCase() : "";
      String email = u.getEmail()    != null ? u.getEmail().toLowerCase()    : "";
      if (!name.contains(searchQ.toLowerCase()) && !email.contains(searchQ.toLowerCase())) {
        it.remove();
      }
    }
  }
  String successParam = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Customers — BARBON'S Admin</title>
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
      margin-bottom: 20px;
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

    /* ── Search bar ── */
    .search-bar-wrap {
      margin-bottom: 24px;
    }

    .search-bar-wrap input {
      width: 340px;
      max-width: 100%;
      padding: 10px 14px;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      color: var(--text);
      font-family: 'DM Sans', sans-serif;
      font-size: .88rem;
      outline: none;
      transition: border-color var(--ease);
    }

    .search-bar-wrap input::placeholder { color: #555; }
    .search-bar-wrap input:focus { border-color: rgba(255,255,255,.3); }

    /* ── Customers table card ── */
    .table-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
    }

    .customers-table {
      width: 100%;
      border-collapse: collapse;
      font-size: .88rem;
    }

    .customers-table thead th {
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

    .customers-table tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background var(--ease);
    }

    .customers-table tbody tr:last-child {
      border-bottom: none;
    }

    .customers-table tbody tr:hover {
      background: rgba(255,255,255,.03);
    }

    .customers-table tbody td {
      padding: 16px 20px;
      vertical-align: middle;
      color: var(--text);
    }

    /* hide rows that don't match search — handled server-side */    .customer-name {
      font-weight: 700;
      font-size: .92rem;
    }

    .customer-email,
    .customer-phone {
      color: var(--muted);
      font-size: .88rem;
    }

    /* ── Responsive ── */
    @media (max-width: 900px) {
      .admin-sidebar { display: none; }
    }

    @media (max-width: 600px) {
      .admin-body   { padding: 20px 16px 40px; }
      .admin-topbar { padding: 0 16px; }
      .search-bar-wrap input { width: 100%; }
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
      <li><a href="${pageContext.request.contextPath}/admin/customers.jsp" class="active">Manage Customers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a></li>
    </ul>
  </aside>

  <!-- ── Main ── -->
  <div class="admin-main">

    <!-- Top bar -->
    <div class="admin-topbar">
      <span class="page-title-bar">Manage Customers</span>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="admin-badge">Admin: <%= adminName %></span>
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>

    <!-- Body -->
    <div class="admin-body">

      <!-- Page heading -->
      <div class="page-heading">
        <h1>Manage Customers</h1>
        <p>View all registered customers and manage their accounts.</p>
      </div>

      <!-- Alert -->
      <% if ("toggled".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Customer status updated.</div>
      <% } %>

      <!-- Search bar — server-side -->
      <div class="search-bar-wrap">
        <form method="get" action="${pageContext.request.contextPath}/admin/customers.jsp"
              style="display:flex;gap:8px;align-items:center;">
          <input type="text" name="q" value="<%= searchQ %>"
                 placeholder="Search by name or email"
                 style="width:340px;max-width:100%;">
          <% if (!searchQ.isEmpty()) { %>
            <a href="${pageContext.request.contextPath}/admin/customers.jsp"
               class="btn btn-outline btn-sm">Clear</a>
          <% } %>
        </form>
      </div>

      <!-- Customers table -->
      <div class="table-card">
        <div class="table-wrap">
          <table class="customers-table">
            <thead>
              <tr>
                <th>Customer Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="customerTableBody">
              <% if (customers.isEmpty()) { %>
                <tr>
                  <td colspan="5" style="text-align:center;color:var(--muted);padding:32px;">
                    <%= searchQ.isEmpty() ? "No customers registered yet." : "No customers match \"" + searchQ + "\"." %>
                  </td>
                </tr>
              <% } %>
              <% for (User u : customers) { %>
                <tr>
                  <td class="customer-name"><%= u.getFullName() %></td>
                  <td class="customer-email"><%= u.getEmail() %></td>
                  <td class="customer-phone">
                    <%= u.getPhone() != null && !u.getPhone().isEmpty() ? u.getPhone() : "—" %>
                  </td>
                  <td>
                    <span class="badge <%= u.getIsActive() == 1 ? "badge-completed" : "badge-cancelled" %>">
                      <%= u.getIsActive() == 1 ? "Active" : "Disabled" %>
                    </span>
                  </td>
                  <td>
                    <form action="${pageContext.request.contextPath}/admin" method="post">
                      <input type="hidden" name="action" value="toggleCustomer">
                      <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                      <input type="hidden" name="currentStatus" value="<%= u.getIsActive() %>">
                      <button type="submit"
                              class="btn btn-sm <%= u.getIsActive() == 1 ? "btn-danger" : "btn-success" %>"
                              onclick="return confirm('<%= u.getIsActive() == 1 ? "Disable" : "Enable" %> this customer?')">
                        <%= u.getIsActive() == 1 ? "Disable" : "Enable" %>
                      </button>
                    </form>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>

    </div><!-- /admin-body -->
  </div><!-- /admin-main -->
</div><!-- /admin-shell -->

</body>
</html>
