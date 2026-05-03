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
  <title>Appointments — BARBER'S Admin</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<nav class="admin-navbar">
  <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-logo">BARBER'S</a>
  <ul class="admin-nav-links">
    <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Dashboard</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="active">Appointments</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Barbers</a></li>
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
    <h1>Manage Appointments</h1>
    <p>View, confirm, complete, or cancel customer appointments.</p>
  </div>

  <% if ("updated".equals(successParam)) { %>
    <div class="alert alert-success">&#10003; Appointment status updated.</div>
  <% } %>

  <!-- Filters -->
  <div class="filter-row">
    <select id="filterStatus">
      <option value="">All Statuses</option>
      <option value="pending">Pending</option>
      <option value="confirmed">Confirmed</option>
      <option value="completed">Completed</option>
      <option value="cancelled">Cancelled</option>
    </select>
    <input type="date" id="filterDate" placeholder="Filter by date">
  </div>

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
          <% for (Appointment a : appointments) { %>
            <tr data-status="<%= a.getStatus() %>" data-date="<%= a.getApptDate() %>">
              <td style="color:var(--muted);font-size:.8rem;">#<%= a.getAppointmentId() %></td>
              <td><%= a.getCustomerName() %></td>
              <td><%= a.getServiceName() %><br>
                <span style="font-size:.75rem;color:var(--muted);">$<%= String.format("%.2f", a.getServicePrice()) %></span>
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

<script src="${pageContext.request.contextPath}/js/admin.js"></script>
</body>
</html>
