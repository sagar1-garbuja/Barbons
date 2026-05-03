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
  <title>Customers — BARBER'S Admin</title>
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
    <li><a href="${pageContext.request.contextPath}/admin/customers.jsp" class="active">Customers</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Services</a></li>
  </ul>
  <div class="admin-nav-right">
    <span class="admin-badge">Admin: <%= adminName %></span>
    <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
  </div>
</nav>

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
          <% for (User u : customers) { %>
            <tr>
              <td style="color:var(--muted);font-size:.8rem;"><%= u.getUserId() %></td>
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

<script src="${pageContext.request.contextPath}/js/admin.js"></script>
</body>
</html>
