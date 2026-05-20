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
  List<Appointment> appointments = apptDAO.getAppointmentsByUser(userId);

  String successParam = request.getParameter("success");
  String errorParam   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Appointments — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
  <style>
    .review-modal-overlay {
      display: none; position: fixed; inset: 0;
      background: rgba(0,0,0,.7); z-index: 200;
      align-items: center; justify-content: center;
    }
    .review-modal-overlay.open { display: flex; }
    .review-modal {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 12px; padding: 32px; width: 100%; max-width: 440px;
    }
    .review-modal h3 {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; color: var(--text); margin-bottom: 20px;
    }
    .star-rating { display: flex; gap: 8px; margin-bottom: 16px; }
    .star-rating input { display: none; }
    .star-rating label {
      font-size: 1.8rem; color: #444; cursor: pointer;
      transition: color .15s;
    }
    .star-rating input:checked ~ label,
    .star-rating label:hover,
    .star-rating label:hover ~ label { color: #aaaaaa; }
    .star-rating { flex-direction: row-reverse; }
    .star-rating label:hover,
    .star-rating label:hover ~ label { color: #aaaaaa; }
  </style>
</head>
<body>
<div class="customer-layout">

  <!-- ── TOP NAVBAR ── -->
  <nav class="customer-navbar">
    <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="nav-logo">BARBONS BARBER</a>
    <ul class="customer-nav-links">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/dashboard.jsp">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp" class="active">My Appointments</a></li>
      <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
      <li><a href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
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
      <h1>My Appointments</h1>
      <p>View and manage all your bookings.</p>
    </div>

    <!-- Alerts -->
    <% if ("booked".equals(successParam)) { %>
      <div class="alert alert-success">&#10003; Appointment booked successfully!</div>
    <% } else if ("cancelled".equals(successParam)) { %>
      <div class="alert alert-info">&#9432; Appointment cancelled.</div>
    <% } else if ("reviewed".equals(successParam)) { %>
      <div class="alert alert-success">&#10003; Review submitted. Thank you!</div>
    <% } %>
    <% if ("alreadyreviewed".equals(errorParam)) { %>
      <div class="alert alert-error">&#9888; You have already reviewed this appointment.</div>
    <% } %>

    <div style="margin-bottom:20px;">
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="btn btn-primary btn-sm">&#43; New Booking</a>
    </div>

    <div class="section-card">
      <% if (appointments.isEmpty()) { %>
        <p style="color:var(--muted);font-size:.9rem;text-align:center;padding:40px 0;">
          No appointments yet. <a href="${pageContext.request.contextPath}/customer/book.jsp" style="color:var(--text);text-decoration:underline;">Book your first one!</a>
        </p>
      <% } else { %>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Service</th>
                <th>Barber</th>
                <th>Date</th>
                <th>Time</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% for (Appointment a : appointments) {
                   boolean canCancel = "pending".equals(a.getStatus()); // only pending — confirmed means admin accepted
                   boolean canReview = "completed".equals(a.getStatus()) && !apptDAO.hasReview(a.getAppointmentId());
              %>
                <tr>
                  <td><strong><%= a.getServiceName() %></strong><br>
                    <span style="font-size:.78rem;color:var(--muted);">Rs. <%= String.format("%.2f", a.getServicePrice()) %></span>
                  </td>
                  <td><%= a.getBarberName() %></td>
                  <td><%= a.getApptDate() %></td>
                  <td><%= a.getApptTime().toString().substring(0,5) %></td>
                  <td><span class="badge badge-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                  <td style="display:flex;gap:8px;flex-wrap:wrap;">
                    <% if (canCancel) { %>
                      <form action="${pageContext.request.contextPath}/appointment" method="post">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%= a.getAppointmentId() %>">
                        <button type="submit" class="btn btn-danger btn-sm"
                                onclick="return confirm('Cancel this appointment?')">Cancel</button>
                      </form>
                    <% } else if ("confirmed".equals(a.getStatus())) { %>
                      <span style="font-size:.78rem;color:var(--confirmed);font-weight:600;">&#10003; Accepted</span>
                    <% } %>
                    <% if (canReview) { %>
                      <button type="button" class="btn btn-warning btn-sm"
                              onclick="openReviewModal(<%= a.getAppointmentId() %>)">
                        Write Review
                      </button>
                    <% } %>
                    <% if (!canCancel && !canReview && !"confirmed".equals(a.getStatus())) { %>
                      <span style="color:var(--muted);font-size:.8rem;">—</span>
                    <% } %>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } %>
    </div>
  </main>

</div>

<!-- ── REVIEW MODAL ── -->
<div class="review-modal-overlay" id="reviewModal">
  <div class="review-modal">
    <h3>Write a Review</h3>
    <form action="${pageContext.request.contextPath}/review" method="post">
      <input type="hidden" name="action" value="submit">
      <input type="hidden" name="appointmentId" id="modalApptId">

      <div class="form-group">
        <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:8px;">Rating</label>
        <div class="star-rating">
          <input type="radio" name="rating" id="s5" value="5"><label for="s5">&#9733;</label>
          <input type="radio" name="rating" id="s4" value="4"><label for="s4">&#9733;</label>
          <input type="radio" name="rating" id="s3" value="3"><label for="s3">&#9733;</label>
          <input type="radio" name="rating" id="s2" value="2"><label for="s2">&#9733;</label>
          <input type="radio" name="rating" id="s1" value="1"><label for="s1">&#9733;</label>
        </div>
      </div>

      <div class="form-group" style="margin-top:14px;">
        <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Comment</label>
        <textarea name="comment" class="form-control" rows="4"
                  placeholder="Share your experience..."></textarea>
      </div>

      <div style="display:flex;gap:10px;margin-top:20px;">
        <button type="submit" class="btn btn-primary" style="flex:1;">Submit Review</button>
        <button type="button" class="btn btn-outline" onclick="closeReviewModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openReviewModal(apptId) {
    document.getElementById('modalApptId').value = apptId;
    document.getElementById('reviewModal').classList.add('open');
  }
  function closeReviewModal() {
    document.getElementById('reviewModal').classList.remove('open');
  }
  // Close on overlay click
  document.getElementById('reviewModal').addEventListener('click', function(e) {
    if (e.target === this) closeReviewModal();
  });
</script>
</body>
</html>
