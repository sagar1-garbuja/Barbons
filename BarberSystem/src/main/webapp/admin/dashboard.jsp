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

  AppointmentDAO apptDAO    = new AppointmentDAO();
  UserDAO        userDAO    = new UserDAO();
  ReviewDAO      reviewDAO  = new ReviewDAO();

  int    totalClients    = userDAO.getAllCustomers().size();
  int    todayCount      = apptDAO.getTodayCount();
  int    pendingCount    = apptDAO.getPendingCount();
  double revenue         = apptDAO.getTotalRevenue();

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
      <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="active">Admin Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/appointments.jsp">View All Bookings</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/customers.jsp">Manage Customers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/barbers.jsp">Manage Barbers</a></li>
      <li><a href="${pageContext.request.contextPath}/admin/services.jsp">Manage Services</a></li>
    </ul>
  </aside>

  <!-- ── Main ── -->
  <div class="admin-main">

    <!-- Top bar -->
    <div class="admin-topbar">
      <span class="page-title-bar">Admin Dashboard</span>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="admin-badge">Admin: <%= adminName %></span>
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>

    <!-- Body -->
    <div class="admin-body">

      <!-- Page heading -->
      <div class="page-header">
        <h1>Dashboard</h1>
        <p>Overview of your barbershop operations.</p>
      </div>

      <!-- ── Stat cards ── -->
      <div class="stat-grid">
        <div class="stat-card">
          <div class="stat-label">Total Customers</div>
          <div class="stat-value"><%= totalClients %></div>
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

      <!-- ── Upcoming Bookings table ── -->
      <div class="section-card">
        <div class="section-card-header">
          <h3>Upcoming Bookings</h3>
          <a href="${pageContext.request.contextPath}/admin/appointments.jsp"
             style="font-size:.82rem;color:var(--muted);">View all &rarr;</a>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Date &amp; Time</th>
                <th>Customer Name</th>
                <th>Service</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <% for (Appointment a : recentAppts) { %>
                <tr>
                  <td style="color:var(--muted);font-size:.85rem;line-height:1.6;">
                    <%= a.getApptDate() %><br>
                    <%= a.getApptTime().toString().substring(0,5) %>
                  </td>
                  <td><strong><%= a.getCustomerName() %></strong></td>
                  <td><%= a.getServiceName() %></td>
                  <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                </tr>
              <% } %>
              <% if (recentAppts.isEmpty()) { %>
                <tr>
                  <td colspan="4" style="text-align:center;color:var(--muted);padding:24px;">
                    No appointments yet.
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ── Reviews management (unchanged) ── -->
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
                      <button type="submit"
                              class="btn btn-sm <%= r.getIsVisible() == 1 ? "btn-danger" : "btn-success" %>">
                        <%= r.getIsVisible() == 1 ? "Hide" : "Show" %>
                      </button>
                    </form>
                  </td>
                </tr>
              <% } %>
              <% if (allReviews.isEmpty()) { %>
                <tr>
                  <td colspan="6" style="text-align:center;color:var(--muted);padding:24px;">
                    No reviews yet.
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
