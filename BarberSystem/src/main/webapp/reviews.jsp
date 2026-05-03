<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ReviewDAO, com.barbers.model.Review, java.util.List" %>
<%
  ReviewDAO reviewDAO = new ReviewDAO();
  List<Review> reviews = reviewDAO.getVisibleReviews();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reviews — BARBER'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <style>
    body { background: var(--bg); }
    .navbar {
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 60px; height: 64px;
      background: var(--surface); border-bottom: 1px solid var(--border);
    }
    .nav-logo {
      font-family: 'Playfair Display', serif; font-size: 1.2rem; font-weight: 700;
      letter-spacing: .12em; text-transform: uppercase; color: var(--text); text-decoration: none;
    }
    .nav-links { display: flex; gap: 8px; list-style: none; }
    .nav-links a {
      padding: 8px 14px; font-size: .85rem; color: var(--muted);
      text-decoration: none; border-radius: 6px; transition: color .2s, background .2s;
    }
    .nav-links a:hover, .nav-links a.active { color: var(--text); background: rgba(255,255,255,.06); }

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
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 10px; padding: 28px;
      transition: border-color .2s, transform .2s;
    }
    .review-card:hover { border-color: rgba(255,255,255,.15); transform: translateY(-2px); }
    .review-stars { color: #f39c12; font-size: 1.1rem; margin-bottom: 14px; }
    .review-comment {
      font-size: .9rem; color: var(--muted); line-height: 1.7; margin-bottom: 20px;
      font-style: italic;
    }
    .review-footer { display: flex; justify-content: space-between; align-items: flex-end; }
    .review-author { font-size: .88rem; font-weight: 600; color: var(--text); }
    .review-service { font-size: .75rem; color: var(--muted); margin-top: 2px; }
    .review-date { font-size: .75rem; color: var(--muted); }

    footer {
      background: var(--surface); border-top: 1px solid var(--border);
      padding: 32px 60px; text-align: center; font-size: .82rem; color: var(--muted);
      margin-top: 80px;
    }
    @media (max-width: 768px) {
      .navbar { padding: 0 20px; }
      .nav-links { display: none; }
    }
  </style>
</head>
<body>

<nav class="navbar">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">BARBER'S</a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
    <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
    <li><a href="${pageContext.request.contextPath}/reviews.jsp" class="active">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
  </ul>
  <div style="display:flex;gap:10px;">
    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline btn-sm">Log In</a>
    <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a>
  </div>
</nav>

<div class="reviews-page">
  <div class="page-hero">
    <h1>Client Reviews</h1>
    <p>See what our clients have to say about their experience at BARBER'S.</p>
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

<footer>&copy; 2026 BARBER'S. All rights reserved.</footer>

</body>
</html>
