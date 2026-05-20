<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.UserDAO, com.barbers.model.User, java.util.List" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");
  UserDAO userDAO = new UserDAO();
  List<User> customers = userDAO.getAllCustomers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Customers — BARBONS BARBER Admin</title>
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
    <a href="${pageContext.request.contextPath}/admin/customers.jsp" class="active">Manage Customers</a>
    <a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a>
    <a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a>
  </nav>
</div>

<div class="admin-main">
  <div class="admin-header">
    <span class="admin-header-title">Manage Customers</span>
    <div class="admin-header-right">
      <span class="admin-header-user">Admin: <strong><%= adminName %></strong></span>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-outline-light btn-sm">Logout</a>
    </div>
  </div>

  <div class="admin-content">
<div class="page-header">
    <h1>Customers</h1>
    <p>View and manage all registered customers.</p>
  </div>

  <div class="section-card">
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Joined</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% int rowNum = 1; for (User u : customers) { %>
            <tr>
              <td style="color:var(--muted);font-size:.8rem;"><%= rowNum++ %></td>
              <td><strong><%= u.getFullName() %></strong></td>
              <td><%= u.getEmail() %></td>
              <td><%= u.getPhone() %></td>
              <td style="font-size:.8rem;color:var(--muted);">
                <%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0,10) : "—" %>
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
                          onclick="return confirm('<%= u.getIsActive() == 1 ? "Deactivate" : "Activate" %> this customer?')">
                    <%= u.getIsActive() == 1 ? "Deactivate" : "Activate" %>
                  </button>
                </form>
              </td>
            </tr>
          <% } %>
          <% if (customers.isEmpty()) { %>
            <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:24px;">No customers registered yet.</td></tr>
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
