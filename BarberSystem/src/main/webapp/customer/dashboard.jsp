<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.AppointmentDAO, com.barbers.model.Appointment, java.util.List" %>
<%
  // ── Session guard ──
  if (session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  int    userId   = (Integer) session.getAttribute("userId");
  String fullName = (String)  session.getAttribute("fullName");

  AppointmentDAO apptDAO = new AppointmentDAO();
  List<Appointment> allAppts = apptDAO.getAppointmentsByUser(userId);

  long total     = allAppts.size();
  long pending   = allAppts.stream().filter(a -> "pending".equals(a.getStatus())).count();
  long completed = allAppts.stream().filter(a -> "completed".equals(a.getStatus())).count();

  // Last 5
  List<Appointment> recent = allAppts.subList(0, Math.min(5, allAppts.size()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
</head>
<body>
<div class="customer-layout">

  <!-- ── SIDEBAR ── -->
  <aside class="sidebar">
    <div class="sidebar-brand"><span class="logo">BARBER'S</span></div>
    <div class="sidebar-user">
      <div class="user-avatar">&#128100;</div>
      <div class="user-name"><%= fullName %></div>
      <div class="user-role">Customer</div>
    </div>
    <nav class="sidebar-nav">
      <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="active">&#9632; Dashboard</a>
      <a href="${pageContext.request.contextPath}/customer/book.jsp">&#43; Book Appointment</a>
      <a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">&#128197; My Appointments</a>
      <a href="${pageContext.request.contextPath}/reviews.jsp">&#9733; Reviews</a>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp">&#9881; Profile</a>
    </nav>
    <div class="sidebar-footer">
      <a href="${pageContext.request.contextPath}/auth?action=logout">&#8594; Logout</a>
    </div>
  </aside>

  <!-- ── MAIN ── -->
  <main class="main-content">
    <div class="page-header">
      <h1>Welcome back, <%= fullName.split(" ")[0] %></h1>
      <p>Here's an overview of your appointments.</p>
    </div>

    <!-- Stat cards -->
    <div class="stat-grid">
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value"><%= total %></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Pending</div>
        <div class="stat-value" style="color:var(--pending);"><%= pending %></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Completed</div>
        <div class="stat-value" style="color:var(--completed);"><%= completed %></div>
      </div>
    </div>

    <!-- Book CTA -->
    <div style="margin-bottom:28px;">
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="btn btn-primary">
        &#43; Book New Appointment
      </a>
    </div>

    <!-- Recent appointments -->
    <div class="section-card">
      <h3>Recent Appointments</h3>
      <% if (recent.isEmpty()) { %>
        <p style="color:var(--muted);font-size:.9rem;">No appointments yet. <a href="${pageContext.request.contextPath}/customer/book.jsp" style="color:var(--text);text-decoration:underline;">Book one now!</a></p>
      <% } else { %>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Service</th>
                <th>Date</th>
                <th>Time</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <% for (Appointment a : recent) { %>
                <tr>
                  <td><%= a.getServiceName() %></td>
                  <td><%= a.getApptDate() %></td>
                  <td><%= a.getApptTime().toString().substring(0,5) %></td>
                  <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                  <td>
                    <% if ("pending".equals(a.getStatus()) || "confirmed".equals(a.getStatus())) { %>
                      <form action="${pageContext.request.contextPath}/appointment" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%= a.getAppointmentId() %>">
                        <button type="submit" class="btn btn-danger btn-sm"
                                onclick="return confirm('Cancel this appointment?')">Cancel</button>
                      </form>
                    <% } else { %>
                      <span style="color:var(--muted);font-size:.8rem;">—</span>
                    <% } %>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <div style="margin-top:16px;">
          <a href="${pageContext.request.contextPath}/customer/my-appointments.jsp" style="font-size:.85rem;color:var(--muted);text-decoration:underline;">View all appointments &rarr;</a>
        </div>
      <% } %>
    </div>
  </main>

</div>
</body>
</html>
