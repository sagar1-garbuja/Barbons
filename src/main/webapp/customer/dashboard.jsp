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
  <title>Dashboard — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
</head>
<body>
<div class="customer-layout">

  <!-- ── TOP NAVBAR ── -->
  <nav class="customer-navbar">
    <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="nav-logo">BARBONS BARBER</a>
    <ul class="customer-nav-links">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="active">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">My Appointments</a></li>
      <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/contact.jsp">Contact</a></li>
    </ul>
    <div class="customer-nav-right">
      <div class="customer-nav-avatar">
        <%
          String _pic = (String) session.getAttribute("profilePicture");
          if (_pic != null && !_pic.isEmpty()) { %>
          <img src="<%= request.getContextPath() %>/uploads/profiles/<%= _pic %>"
               alt="Profile" style="width:34px;height:34px;border-radius:50%;object-fit:cover;display:block;">
        <% } else { %>&#128100;<% } %>
      </div>
      <span class="customer-nav-name"><%= fullName %></span>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="btn btn-outline-light btn-sm">Profile</a>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    </div>
  </nav>

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
                      <% if ("pending".equals(a.getStatus())) { %>
                      <form action="${pageContext.request.contextPath}/appointment" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%= a.getAppointmentId() %>">
                        <button type="submit" class="btn btn-danger btn-sm"
                                onclick="return confirm('Cancel this appointment?')">Cancel</button>
                      </form>
                      <% } else { %>
                        <span style="font-size:.78rem;color:var(--confirmed);font-weight:600;">&#10003; Accepted</span>
                      <% } %>
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


<!-- -- MOBILE BOTTOM NAV -- -->
</div>
</body>
</html>

