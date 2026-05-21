<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.AppointmentDAO, com.barbers.model.Appointment, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  String adminPic  = (String) session.getAttribute("profilePicture");
  AppointmentDAO apptDAO = new AppointmentDAO();

  // Server-side filter via GET params
  String filterStatus = request.getParameter("filterStatus");
  String filterDate   = request.getParameter("filterDate");
  if (filterStatus == null) filterStatus = "";
  if (filterDate   == null) filterDate   = "";

  List<Appointment> appointments = apptDAO.getAllAppointments();
  // Apply filters
  if (!filterStatus.isEmpty()) {
    final String fs = filterStatus;
    appointments = appointments.stream()
        .filter(a -> fs.equals(a.getStatus()))
        .collect(java.util.stream.Collectors.toList());
  }
  if (!filterDate.isEmpty()) {
    final String fd = filterDate;
    appointments = appointments.stream()
        .filter(a -> fd.equals(String.valueOf(a.getApptDate())))
        .collect(java.util.stream.Collectors.toList());
  }

  String successParam = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Appointments — BARBONS BARBER Admin</title>
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
    <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="active">View All Bookings</a>
    <a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a>
    <a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a>
    <a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a>
  </nav>
</div>

<div class="admin-main">
  <div class="admin-header">
    <span class="admin-header-title">Manage Appointments</span>
    <div class="admin-header-right">
      <span class="admin-header-user">Admin</span>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    </div>
  </div>

  <div class="admin-content">
<div class="page-header">
    <h1>Manage Appointments</h1>
    <p>View, confirm, complete, or cancel customer appointments.</p>
  </div>

  <% if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Appointment status updated.</div>
  <% } %>

  <!-- Filters — server-side GET form, no JS needed -->
  <form method="get" action="${pageContext.request.contextPath}/admin/appointments.jsp"
        style="display:flex;gap:12px;align-items:flex-end;margin-bottom:20px;flex-wrap:wrap;">
    <div>
      <label style="display:block;font-size:.75rem;font-weight:700;color:var(--muted);
                    text-transform:uppercase;letter-spacing:.06em;margin-bottom:6px;">Status</label>
      <select name="filterStatus" class="form-control" style="width:160px;">
        <option value="" <%= filterStatus.isEmpty() ? "selected" : "" %>>All Statuses</option>
        <option value="pending"   <%= "pending".equals(filterStatus)   ? "selected" : "" %>>Pending</option>
        <option value="confirmed" <%= "confirmed".equals(filterStatus) ? "selected" : "" %>>Confirmed</option>
        <option value="completed" <%= "completed".equals(filterStatus) ? "selected" : "" %>>Completed</option>
        <option value="cancelled" <%= "cancelled".equals(filterStatus) ? "selected" : "" %>>Cancelled</option>
      </select>
    </div>
    <div>
      <label style="display:block;font-size:.75rem;font-weight:700;color:var(--muted);
                    text-transform:uppercase;letter-spacing:.06em;margin-bottom:6px;">Date</label>
      <input type="date" name="filterDate" class="form-control" style="width:180px;"
             value="<%= filterDate %>">
    </div>
    <button type="submit" class="btn btn-primary btn-sm">Filter</button>
    <% if (!filterStatus.isEmpty() || !filterDate.isEmpty()) { %>
      <a href="${pageContext.request.contextPath}/admin/appointments.jsp"
         class="btn btn-outline btn-sm">Clear</a>
    <% } %>
  </form>

  <div class="section-card">
    <div class="table-wrap">
      <table id="appointmentsTable">
        <thead>
          <tr>
            <th>#</th>
            <th>Customer</th>
            <th>Service</th>
            <th>Barber</th>
            <th>Date</th>
            <th>Time</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% int rowNum = 1; for (Appointment a : appointments) { %>
            <tr data-status="<%= a.getStatus() %>" data-date="<%= a.getApptDate() %>">
              <td style="color:var(--muted);font-size:.8rem;"><%= rowNum++ %></td>
              <td><%= a.getCustomerName() %></td>
              <td><%= a.getServiceName() %><br>
                <span style="font-size:.75rem;color:var(--muted);">Rs. <%= String.format("%.2f", a.getServicePrice()) %></span>
              </td>
              <td><%= a.getBarberName() %></td>
              <td><%= a.getApptDate() %></td>
              <td><%= a.getApptTime().toString().substring(0,5) %></td>
              <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
              <td>
                <div style="display:flex;gap:6px;flex-wrap:wrap;">
                  <% if ("pending".equals(a.getStatus())) { %>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                      <input type="hidden" name="action" value="updateStatus">
                      <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                      <input type="hidden" name="status" value="confirmed">
                      <button type="submit" class="btn btn-info btn-sm">Confirm</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                      <input type="hidden" name="action" value="updateStatus">
                      <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                      <input type="hidden" name="status" value="cancelled">
                      <button type="submit" class="btn btn-danger btn-sm confirm-action"
                              data-confirm="Cancel this appointment?">Cancel</button>
                    </form>
                  <% } else if ("confirmed".equals(a.getStatus())) { %>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                      <input type="hidden" name="action" value="updateStatus">
                      <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                      <input type="hidden" name="status" value="completed">
                      <button type="submit" class="btn btn-success btn-sm">Complete</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display:inline;">
                      <input type="hidden" name="action" value="updateStatus">
                      <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                      <input type="hidden" name="status" value="cancelled">
                      <button type="submit" class="btn btn-danger btn-sm confirm-action"
                              data-confirm="Cancel this appointment?">Cancel</button>
                    </form>
                  <% } else { %>
                    <span style="color:var(--muted);font-size:.8rem;">—</span>
                  <% } %>
                </div>
              </td>
            </tr>
          <% } %>
          <% if (appointments.isEmpty()) { %>
            <tr><td colspan="8" style="text-align:center;color:var(--muted);padding:24px;">No appointments found.</td></tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </div>
</div>
  </div>
</div>
</body>
</html>
