<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ServiceDAO, com.barbers.dao.ReviewDAO" %>
<%@ page import="com.barbers.model.Service, com.barbers.model.Review" %>
<%@ page import="java.util.List" %>
<%
  ServiceDAO serviceDAO = new ServiceDAO();
  ReviewDAO  reviewDAO  = new ReviewDAO();
  List<Service> services = serviceDAO.getAllActiveServices();
  List<Review>  reviews  = reviewDAO.getVisibleReviews();

  String loggedInName = (String) session.getAttribute("fullName");
  String role         = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BARBON'S — Premium Barber Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <style>
    /* ── Navbar ── */
    .navbar {
      position: fixed; top: 0; left: 0; right: 0; z-index: 100;
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 60px; height: 64px;
      background: rgba(10,10,10,.95);
      border-bottom: 1px solid var(--border);
      backdrop-filter: blur(10px);
    }
    .nav-logo {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; font-weight: 700;
      letter-spacing: .12em; text-transform: uppercase;
      color: var(--text); text-decoration: none;
    }
    .nav-links { display: flex; gap: 8px; list-style: none; }
    .nav-links a {
      padding: 8px 14px; font-size: .85rem; font-weight: 500;
      color: var(--muted); text-decoration: none; border-radius: 6px;
      transition: color .2s, background .2s;
    }
    .nav-links a:hover { color: var(--text); background: rgba(255,255,255,.06); }
    .nav-actions { display: flex; gap: 10px; }

    /* ── Hero ── */
    .hero {
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      text-align: center;
      background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
      position: relative; overflow: hidden;
      padding: 80px 24px 60px;
    }
    .hero::before {
      content: '';
      position: absolute; inset: 0;
      background-image:
        linear-gradient(rgba(255,255,255,.02) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,.02) 1px, transparent 1px);
      background-size: 60px 60px;
    }
    .hero-content { position: relative; z-index: 1; max-width: 700px; }
    .hero-eyebrow {
      font-size: .78rem; font-weight: 700; letter-spacing: .2em;
      text-transform: uppercase; color: var(--muted); margin-bottom: 20px;
    }
    .hero h1 {
      font-family: 'Playfair Display', serif;
      font-size: clamp(2.5rem, 6vw, 5rem);
      font-weight: 700; line-height: 1.1;
      color: var(--text); margin-bottom: 20px;
    }
    .hero p {
      font-size: 1.05rem; color: var(--muted);
      max-width: 480px; margin: 0 auto 36px; line-height: 1.7;
    }
    .hero-actions { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }

    /* ── Sections ── */
    section { padding: 80px 0; }
    .section-label {
      font-size: .75rem; font-weight: 700; letter-spacing: .2em;
      text-transform: uppercase; color: var(--muted); margin-bottom: 12px;
    }
    .section-title {
      font-family: 'Playfair Display', serif;
      font-size: clamp(1.8rem, 3vw, 2.5rem);
      font-weight: 700; color: var(--text); margin-bottom: 40px;
    }

    /* ── Services grid ── */
    .services-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 16px;
    }
    .service-card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 10px; padding: 24px;
      transition: border-color .2s, transform .2s;
    }
    .service-card:hover { border-color: rgba(255,255,255,.2); transform: translateY(-3px); }
    .service-card .svc-name {
      font-family: 'Playfair Display', serif;
      font-size: 1.05rem; font-weight: 600; color: var(--text); margin-bottom: 8px;
    }
    .service-card .svc-desc {
      font-size: .83rem; color: var(--muted); margin-bottom: 16px; line-height: 1.5;
    }
    .service-card .svc-meta {
      display: flex; justify-content: space-between; align-items: center;
    }
    .service-card .svc-price {
      font-size: 1.1rem; font-weight: 700; color: var(--text);
    }
    .service-card .svc-dur {
      font-size: .78rem; color: var(--muted);
      background: var(--surface2); padding: 3px 8px; border-radius: 20px;
    }

    /* ── Reviews ── */
    .reviews-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 16px;
    }
    .review-card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 10px; padding: 24px;
    }
    .review-stars { color: #f39c12; font-size: 1rem; margin-bottom: 12px; }
    .review-comment {
      font-size: .88rem; color: var(--muted); line-height: 1.6; margin-bottom: 16px;
    }
    .review-author { font-size: .82rem; font-weight: 600; color: var(--text); }
    .review-service { font-size: .75rem; color: var(--muted); }

    /* ── Footer ── */
    footer {
      background: var(--surface); border-top: 1px solid var(--border);
      padding: 48px 0 24px;
    }
    .footer-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 40px;
      margin-bottom: 32px;
    }
    .footer-col h4 {
      font-family: 'Playfair Display', serif;
      font-size: .95rem; font-weight: 600; color: var(--text);
      margin-bottom: 14px;
    }
    .footer-col p, .footer-col a {
      font-size: .85rem; color: var(--muted); line-height: 1.8;
      text-decoration: none; display: block;
    }
    .footer-col a:hover { color: var(--text); }
    .footer-bottom {
      border-top: 1px solid var(--border); padding-top: 20px;
      text-align: center; font-size: .8rem; color: var(--muted);
    }

    @media (max-width: 768px) {
      .navbar { padding: 0 20px; }
      .nav-links { display: none; }
      .footer-grid { grid-template-columns: 1fr; gap: 24px; }
    }
  </style>
</head>
<body>

<!-- ── NAVBAR ── -->
<nav class="navbar">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">BARBON'S</a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
    <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
    <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
  </ul>
  <div class="nav-actions">
    <% if (loggedInName != null) { %>
      <% if ("admin".equals(role)) { %>
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline btn-sm">Dashboard</a>
      <% } else { %>
        <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-outline btn-sm">My Account</a>
      <% } %>
      <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-primary btn-sm">Logout</a>
    <% } else { %>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline btn-sm">Log In</a>
      <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a>
    <% } %>
  </div>
</nav>

<!-- ── HERO ── -->
<section class="hero">
  <div class="hero-content">
    <p class="hero-eyebrow">Premium Grooming Experience</p>
    <h1>Premium Barber Experience</h1>
    <p>Expert cuts, classic shaves, and modern styles — all in one place. Book your appointment in seconds.</p>
    <div class="hero-actions">
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="btn btn-primary">Book Now</a>
      <a href="${pageContext.request.contextPath}/reviews.jsp" class="btn btn-outline">See Reviews</a>
    </div>
  </div>
</section>

<!-- ── SERVICES ── -->
<section>
  <div class="container">
    <p class="section-label">What We Offer</p>
    <h2 class="section-title">Our Services</h2>
    <div class="services-grid">
      <% for (Service s : services) { %>
        <div class="service-card">
          <div class="svc-name"><%= s.getServiceName() %></div>
          <div class="svc-desc"><%= s.getDescription() != null ? s.getDescription() : "" %></div>
          <div class="svc-meta">
            <span class="svc-price">$<%= String.format("%.2f", s.getPrice()) %></span>
            <span class="svc-dur"><%= s.getDurationMins() %> min</span>
          </div>
        </div>
      <% } %>
      <% if (services.isEmpty()) { %>
        <p style="color:var(--muted)">No services available at the moment.</p>
      <% } %>
    </div>
  </div>
</section>

<!-- ── REVIEWS ── -->
<section style="background: var(--surface); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
  <div class="container">
    <p class="section-label">Client Feedback</p>
    <h2 class="section-title">What Our Clients Say</h2>
    <div class="reviews-grid">
      <% for (Review r : reviews) { %>
        <div class="review-card">
          <div class="review-stars">
            <% for (int i = 1; i <= 5; i++) { %>
              <%= i <= r.getRating() ? "&#9733;" : "&#9734;" %>
            <% } %>
          </div>
          <p class="review-comment">"<%= r.getComment() != null ? r.getComment() : "" %>"</p>
          <div class="review-author"><%= r.getCustomerName() %></div>
          <div class="review-service"><%= r.getServiceName() %></div>
        </div>
      <% } %>
      <% if (reviews.isEmpty()) { %>
        <p style="color:var(--muted)">No reviews yet. Be the first!</p>
      <% } %>
    </div>
  </div>
</section>

<!-- ── FOOTER ── -->
<footer>
  <div class="container">
    <div class="footer-grid">
      <div class="footer-col">
        <h4>BARBON'S</h4>
        <p>123 Main Street<br>Downtown, City 10001</p>
        <p style="margin-top:8px">Mon–Sat: 8 AM – 7 PM<br>Sun: Closed</p>
      </div>
      <div class="footer-col">
        <h4>Follow Us</h4>
        <a href="#">Instagram</a>
        <a href="#">Facebook</a>
        <a href="#">Twitter / X</a>
      </div>
      <div class="footer-col">
        <h4>Contact</h4>
        <a href="mailto:hello@barbers.com">hello@barbers.com</a>
        <a href="tel:+15551234567">+1 (555) 123-4567</a>
        <a href="${pageContext.request.contextPath}/contact.jsp">Send a Message</a>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; 2026 BARBON'S. All rights reserved.
    </div>
  </div>
</footer>

</body>
</html>
