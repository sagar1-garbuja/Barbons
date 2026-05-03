<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.AppointmentDAO, com.barbers.dao.UserDAO, com.barbers.dao.ReviewDAO" %>
<%@ page import="com.barbers.model.Appointment, com.barbers.model.Review" %>
<%@ page import="java.util.List" %>
<%
  // ── Session guard ──
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String adminName = (String) session.getAttribute("fullName");

  AppointmentDAO apptDAO   = new AppointmentDAO();
  UserDAO        userDAO   = new UserDAO();
  ReviewDAO      reviewDAO = new ReviewDAO();

  int    totalUsers   = userDAO.getAllCustomers().size();
  int    todayCount   = apptDAO.getTodayCount();
  int    pendingCount = apptDAO.getPendingCount();
  double revenue      = apptDAO.getTotalRevenue();

  List<Appointment> recentAppts = apptDAO.getAllAppointments();
  if (recentAppts.size() > 10) recentAppts = recentAppts.subList(0, 10);

  List<Review> allReviews = reviewDAO.getAllReviews();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<!-- ── NAVBAR ── -->
<nav class="admin-navbar">
  <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-logo">BARBER'S</a>
  <ul class="admin-nav-links">
    <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="active">Dashboard</a></li>
    <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">Appointments</a></li>
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
    <h1>Dashboard</h1>
    <p>Overview of your barbershop operations.</p>
  </div>

  <!-- Stat cards -->
  <div class="stat-grid">
    <div class="stat-card">
      <div class="stat-label">Total Customers</div>
      <div class="stat-value"><%= totalUsers %></div>
      <div class="stat-sub">Registered accounts</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Today's Appointments</div>
      <div class="stat-value" style="color:var(--confirmed);"><%= todayCount %></div>
      <div class="stat-sub">Scheduled for today</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Pending</div>
      <div class="stat-value" style="color:var(--pending);"><%= pendingCount %></div>
      <div class="stat-sub">Awaiting confirmation</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Total Revenue</div>
      <div class="stat-value" style="color:var(--completed);">$<%= String.format("%.0f", revenue) %></div>
      <div class="stat-sub">From completed bookings</div>
    </div>
  </div>

  <!-- Recent bookings -->
  <div class="section-card">
    <div class="section-card-header">
      <h3>Recent Bookings</h3>
      <a href="${pageContext.request.contextPath}/admin/appointments.jsp" style="font-size:.82rem;color:var(--muted);">View all &rarr;</a>
    </div>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Customer</th>
            <th>Service</th>
            <th>Date</th>
            <th>Time</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <% for (Appointment a : recentAppts) { %>
            <tr>
              <td><%= a.getCustomerName() %></td>
              <td><%= a.getServiceName() %></td>
              <td><%= a.getApptDate() %></td>
              <td><%= a.getApptTime().toString().substring(0,5) %></td>
              <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
            </tr>
          <% } %>
          <% if (recentAppts.isEmpty()) { %>
            <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:24px;">No appointments yet.</td></tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Reviews management -->
  <div class="section-card">
    <div class="section-card-header">
      <h3>Reviews</h3>
    </div>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Customer</th>
            <th>Service</th>
            <th>Rating</th>
            <th>Comment</th>
            <th>Visible</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <% for (Review r : allReviews) { %>
            <tr>
              <td><%= r.getCustomerName() %></td>
              <td><%= r.getServiceName() %></td>
              <td>
                <% for (int i = 1; i <= 5; i++) { %>
                  <span style="color:<%= i <= r.getRating() ? "#f39c12" : "#333" %>;">&#9733;</span>
                <% } %>
              </td>
              <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                <%= r.getComment() != null ? r.getComment() : "—" %>
              </td>
              <td>
                <span class="badge <%= r.getIsVisible() == 1 ? "badge-completed" : "badge-cancelled" %>">
                  <%= r.getIsVisible() == 1 ? "Visible" : "Hidden" %>
                </span>
              </td>
              <td>
                <form action="${pageContext.request.contextPath}/admin" method="post">
                  <input type="hidden" name="action" value="toggleReview">
                  <input type="hidden" name="reviewId" value="<%= r.getReviewId() %>">
                  <input type="hidden" name="currentStatus" value="<%= r.getIsVisible() %>">
                  <button type="submit" class="btn btn-sm <%= r.getIsVisible() == 1 ? "btn-danger" : "btn-success" %>">
                    <%= r.getIsVisible() == 1 ? "Hide" : "Show" %>
                  </button>
                </form>
              </td>
            </tr>
          <% } %>
          <% if (allReviews.isEmpty()) { %>
            <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:24px;">No reviews yet.</td></tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/js/admin.js"></script>
</body>
</html>
