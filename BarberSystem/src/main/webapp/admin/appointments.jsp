<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.AppointmentDAO, com.barbers.model.Appointment, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  AppointmentDAO apptDAO = new AppointmentDAO();
  List<Appointment> appointments = apptDAO.getAllAppointments();
  String successParam = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Appointments — BARBON'S Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
  <style>
    /* ── - Sidebar layout - ── */
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

    /* ── Table card ── */
    .table-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
    }

    .appts-table {
      width: 100%;
      border-collapse: collapse;
      font-size: .88rem;
    }

    .appts-table thead th {
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

    .appts-table tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background var(--ease);
    }

    .appts-table tbody tr:last-child {
      border-bottom: none;
    }

    .appts-table tbody tr:hover {
      background: rgba(255,255,255,.03);
    }

    .appts-table tbody td {
      padding: 16px 20px;
      vertical-align: middle;
      color: var(--text);
    }

    .appts-table tbody tr.hidden-row {
      display: none;
    }

    .customer-name {
      font-weight: 700;
      font-size: .92rem;
    }

    .datetime-cell {
      color: var(--muted);
      font-size: .85rem;
      line-height: 1.6;
    }

    .service-cell {
      color: var(--muted);
      font-size: .88rem;
    }

    .status-cell .badge {
      font-size: .78rem;
    }

    .action-cell {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }

    /* ── Responsive ── */
    @media (max-width: 900px) {
      .admin-sidebar { display: none; }
    }

    @media (max-width: 600px) {
      .admin-body   { padding: 20px 16px 40px; }
      .admin-topbar { padding: 0 16px; }
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
      <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="active">View All Bookings</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a></li>
    </ul>
  </aside>

  <!-- ── Main ── -->
  <div class="admin-main">

    <!-- Top bar -->
    <div class="admin-topbar">
      <span class="page-title-bar">Manage Appointments</span>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="admin-badge">Admin: <%= adminName %></span>
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>

    <!-- Body -->
    <div class="admin-body">

      <!-- Page heading -->
      <div class="page-heading">
        <h1>Manage Appointment</h1>
        <p>View, confirm or cancel bookings</p>
      </div>

      <!-- Alert -->
      <% if ("updated".equals(successParam)) { %>
        <div class="alert alert-success">&#10003; Appointment status updated.</div>
      <% } %>

      <!-- Appointments table -->
      <div class="table-card">
        <div class="table-wrap">
          <table class="appts-table" id="appointmentsTable">
            <thead>
              <tr>
                <th>Customer Name</th>
                <th>Date &amp; Time</th>
                <th>Service</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% if (appointments.isEmpty()) { %>
                <tr>
                  <td colspan="5" style="text-align:center;color:var(--muted);padding:32px;">
                    No appointments found.
                  </td>
                </tr>
              <% } %>
              <% for (Appointment a : appointments) { %>
                <tr data-status="<%= a.getStatus() %>" data-date="<%= a.getApptDate() %>">

                  <!-- Customer Name -->
                  <td class="customer-name"><%= a.getCustomerName() %></td>

                  <!-- Date & Time -->
                  <td class="datetime-cell">
                    <%= a.getApptDate() %><br>
                    <%= a.getApptTime().toString().substring(0, 5) %>
                  </td>

                  <!-- Services -->
                  <td class="service-cell"><%= a.getServiceName() %></td>

                  <!-- Status badge -->
                  <td class="status-cell">
                    <span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span>
                  </td>

                  <!-- Actions -->
                  <td>
                    <div class="action-cell">
                      <% if ("pending".equals(a.getStatus())) { %>
                        <form action="${pageContext.request.contextPath}/admin" method="post">
                          <input type="hidden" name="action" value="updateStatus">
                          <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                          <input type="hidden" name="status" value="confirmed">
                          <button type="submit" class="btn btn-info btn-sm">Confirm</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin" method="post">
                          <input type="hidden" name="action" value="updateStatus">
                          <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                          <input type="hidden" name="status" value="cancelled">
                          <button type="submit" class="btn btn-danger btn-sm"
                                  onclick="return confirm('Cancel this appointment?')">Cancel</button>
                        </form>
                      <% } else if ("confirmed".equals(a.getStatus())) { %>
                        <form action="${pageContext.request.contextPath}/admin" method="post">
                          <input type="hidden" name="action" value="updateStatus">
                          <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                          <input type="hidden" name="status" value="completed">
                          <button type="submit" class="btn btn-success btn-sm">Complete</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin" method="post">
                          <input type="hidden" name="action" value="updateStatus">
                          <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                          <input type="hidden" name="status" value="cancelled">
                          <button type="submit" class="btn btn-danger btn-sm"
                                  onclick="return confirm('Cancel this appointment?')">Cancel</button>
                        </form>
                      <% } else { %>
                        <span style="color:var(--muted);font-size:.8rem;">—</span>
                      <% } %>
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
