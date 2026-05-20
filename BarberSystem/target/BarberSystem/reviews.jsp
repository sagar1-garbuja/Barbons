<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ReviewDAO, com.barbers.model.Review, java.util.List" %>
<%
  ReviewDAO reviewDAO = new ReviewDAO();
  List<Review> reviews = reviewDAO.getVisibleReviews();

  // Session state for navbar
  String loggedInName = (String) session.getAttribute("fullName");
  String loggedInRole = (String) session.getAttribute("role");
  String loggedInPic  = (String) session.getAttribute("profilePicture");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reviews — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
  <style>
    body { background: #F5F0E8; }
    .reviews-page { max-width: 1100px; margin: 60px auto; padding: 0 24px; }
    .page-hero { text-align: center; margin-bottom: 56px; }
    .page-hero h1 {
      font-family: 'Playfair Display', serif;
      font-size: clamp(2rem, 4vw, 3rem); font-weight: 700; color: var(--text); margin-bottom: 12px;
    }
    .page-hero p { color: var(--muted); font-size: .95rem; }

    .reviews-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px;
    }
    .review-card {
      background: #FFFFFF; border: 1px solid #D8D0C4;
      border-radius: 10px; padding: 28px; box-shadow: 0 1px 6px rgba(0,0,0,.06);
      transition: border-color .2s, transform .2s;
    }
    .review-card:hover { border-color: rgba(255,255,255,.15); transform: translateY(-2px); }
    .review-stars { color: #C9A84C; font-size: 1.1rem; margin-bottom: 14px; }
    .review-comment {
      font-size: .9rem; color: var(--muted); line-height: 1.7; margin-bottom: 20px;
      font-style: italic;
    }
    .review-
    .review-author { font-size: .88rem; font-weight: 600; color: var(--text); }
    .review-service { font-size: .75rem; color: var(--muted); margin-top: 2px; }
    .review-date { font-size: .75rem; color: var(--muted); }
    @media (max-width: 768px) {
      .navbar { padding: 0 16px; }
      .customer-nav-links { display: none; }
      .reviews-page { margin: 20px auto; }
    }
  </style>
</head>
<body>

<nav class="customer-navbar">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">BARBONS BARBER</a>
  <ul class="customer-nav-links">
    <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
    <% if (loggedInName != null && !"admin".equals(loggedInRole)) { %>
      <li><a href="${pageContext.request.contextPath}/customer/dashboard.jsp">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">My Appointments</a></li>
    <% } else { %>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
    <% } %>
    <li><a href="${pageContext.request.contextPath}/reviews.jsp" class="active">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
  </ul>
  <div class="customer-nav-right">
    <% if (loggedInName != null) { %>
      <div class="customer-nav-avatar">
        <% if (loggedInPic != null && !loggedInPic.isEmpty()) { %>
          <img src="<%= request.getContextPath() %>/uploads/profiles/<%= loggedInPic %>"
               alt="Profile" style="width:32px;height:32px;border-radius:50%;object-fit:cover;display:block;">
        <% } else { %>&#128100;<% } %>
      </div>
      <span class="customer-nav-name"><%= loggedInName %></span>
      <% if ("admin".equals(loggedInRole)) { %>
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline-light btn-sm">Dashboard</a>
      <% } else { %>
        <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="btn btn-outline-light btn-sm">Profile</a>
      <% } %>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    <% } else { %>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-light btn-sm">Log In</a>
      <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a>
    <% } %>
  </div>
</nav>

<div class="reviews-page">
  <div class="page-hero">
    <h1>Client Reviews</h1>
    <p>See what our clients have to say about their experience at BARBONS BARBER.</p>
  </div>

  <% if (reviews.isEmpty()) { %>
    <div style="text-align:center;padding:60px 0;color:var(--muted);">
      <p style="font-size:1.1rem;">No reviews yet. Book an appointment and be the first!</p>
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="btn btn-primary" style="margin-top:20px;display:inline-flex;">Book Now</a>
    </div>
  <% } else { %>
    <div class="reviews-grid">
      <% for (Review r : reviews) { %>
        <div class="review-card">
          <div class="review-stars">
            <% for (int i = 1; i <= 5; i++) { %>
              <%= i <= r.getRating() ? "&#9733;" : "&#9734;" %>
            <% } %>
          </div>
          <p class="review-comment">"<%= r.getComment() != null ? r.getComment() : "" %>"</p>
          <div class="review-footer">
            <div>
              <div class="review-author"><%= r.getCustomerName() %></div>
              <div class="review-service"><%= r.getServiceName() %></div>
            </div>
            <div class="review-date">
              <%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 10) : "" %>
            </div>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

</body>
</html>
