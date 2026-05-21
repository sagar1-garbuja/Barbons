<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ServiceDAO, com.barbers.dao.ReviewDAO" %>
<%@ page import="com.barbers.model.Service, com.barbers.model.Review" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%
  List<Service> services = new ArrayList<>();
  List<Review> reviews = new ArrayList<>();
  String dbError = null;
  
  try {
    ServiceDAO serviceDAO = new ServiceDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    services = serviceDAO.getAllActiveServices();
    reviews = reviewDAO.getVisibleReviews();
  } catch (Exception e) {
    dbError = "Database connection failed: " + e.getMessage();
    e.printStackTrace();
  }

  String loggedInName = (String) session.getAttribute("fullName");
  String role         = (String) session.getAttribute("role");
  String loggedInPic  = (String) session.getAttribute("profilePicture");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BARBONS BARBER — Premium Barber Experience</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <style>
    /* ── Navbar ── */
    .navbar {
      position: fixed; top: 0; left: 0; right: 0; z-index: 100;
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 60px; height: 64px;
      background: #0D0D0D;
      border-bottom: 1px solid #1E1E1E;
      box-shadow: 0 2px 12px rgba(0,0,0,.3);
    }
    .nav-logo {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; font-weight: 700;
      letter-spacing: .12em; text-transform: uppercase;
      color: #FFFFFF; text-decoration: none;
    }
    .nav-links { display: flex; gap: 8px; list-style: none; }
    .nav-links a {
      padding: 8px 14px; font-size: .85rem; font-weight: 500;
      color: #A0A0A0; text-decoration: none; border-radius: 6px;
      transition: color .2s, background .2s;
    }
    .nav-links a:hover { color: #FFFFFF; background: rgba(255,255,255,.08); }
    .nav-actions { display: flex; gap: 10px; align-items: center; }
    .nav-user-avatar {
      width: 30px; height: 30px; border-radius: 50%;
      background: #1A1A1A; border: 2px solid #444;
      display: flex; align-items: center; justify-content: center;
      font-size: .85rem; color: #888; overflow: hidden; flex-shrink: 0;
    }
    .nav-user-name {
      font-size: .83rem; font-weight: 600; color: #FFFFFF;
      max-width: 110px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }

    /* logged-in user area */
    .nav-user-avatar {
      width: 32px; height: 32px; border-radius: 50%;
      background: #1A1A1A; border: 2px solid #333;
      display: flex; align-items: center; justify-content: center;
      font-size: .9rem; color: #888; overflow: hidden; flex-shrink: 0;
    }
    .nav-user-name {
      font-size: .83rem; font-weight: 600; color: #FFFFFF;
      max-width: 120px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }

    /* ── Hero ── */
    .hero {
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      text-align: center;
      background:
        linear-gradient(rgba(0,0,0,.62), rgba(0,0,0,.55)),
        url('images/hero.jpg') center center / cover no-repeat;
      position: relative; overflow: hidden;
      padding: 80px 24px 60px;
    }
    .hero::before {
      content: '';
      position: absolute; inset: 0;
      background-image:
        linear-gradient(rgba(201,168,76,.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(201,168,76,.04) 1px, transparent 1px);
      background-size: 60px 60px;
    }
    .hero-content { position: relative; z-index: 1; max-width: 700px; }
    .hero-eyebrow {
      font-size: .78rem; font-weight: 700; letter-spacing: .2em;
      text-transform: uppercase; color: #C9A84C; margin-bottom: 20px;
    }
    .hero h1 {
      font-family: 'Playfair Display', serif;
      font-size: clamp(2.5rem, 6vw, 5rem);
      font-weight: 700; line-height: 1.1;
      color: #FFFFFF; margin-bottom: 20px;
    }
    .hero p {
      font-size: 1.05rem; color: #A0A0A0;
      max-width: 480px; margin: 0 auto 36px; line-height: 1.7;
    }
    .hero-actions { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }

    /* ── Sections ── */
    section { padding: 80px 0; }
    .section-label {
      font-size: .75rem; font-weight: 700; letter-spacing: .2em;
      text-transform: uppercase; color: #C9A84C; margin-bottom: 12px;
    }
    .section-title {
      font-family: 'Playfair Display', serif;
      font-size: clamp(1.8rem, 3vw, 2.5rem);
      font-weight: 700; color: #1A1A1A; margin-bottom: 40px;
    }

    /* ── Services grid ── */
    .services-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 16px;
    }
    .service-card {
      background: #FFFFFF; border: 1px solid #D8D0C4;
      border-radius: 10px; padding: 24px;
      box-shadow: 0 1px 6px rgba(0,0,0,.06);
      transition: border-color .2s, transform .2s, box-shadow .2s;
    }
    .service-card:hover { border-color: #C9A84C; transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,.1); }
    .service-card .svc-name {
      font-family: 'Playfair Display', serif;
      font-size: 1.05rem; font-weight: 600; color: #1A1A1A; margin-bottom: 8px;
    }
    .service-card .svc-desc {
      font-size: .83rem; color: #7A7060; margin-bottom: 16px; line-height: 1.5;
    }
    .service-card .svc-meta {
      display: flex; justify-content: space-between; align-items: center;
    }
    .service-card .svc-price {
      font-size: 1.1rem; font-weight: 700; color: #C9A84C;
    }
    .service-card .svc-dur {
      font-size: .78rem; color: #7A7060;
      background: #EDE8DF; padding: 3px 8px; border-radius: 20px;
    }

    /* ── Reviews ── */
    .reviews-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 16px;
    }
    .review-card {
      background: #FFFFFF; border: 1px solid #D8D0C4;
      border-radius: 10px; padding: 24px;
      box-shadow: 0 1px 6px rgba(0,0,0,.06);
    }
    .review-stars { color: #C9A84C; font-size: 1rem; margin-bottom: 12px; }
    .review-comment {
      font-size: .88rem; color: #7A7060; line-height: 1.6; margin-bottom: 16px;
      font-style: italic;
    }
    .review-author { font-size: .82rem; font-weight: 600; color: #1A1A1A; }
    .review-service { font-size: .75rem; color: #7A7060; }

    /* ── Footer ── */
    footer {
      background: #0D0D0D; border-top: 1px solid #1E1E1E;
      padding: 48px 0 24px;
    }
    .footer-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 40px;
      margin-bottom: 32px;
    }
    .footer-col h4 {
      font-family: 'Playfair Display', serif;
      font-size: .95rem; font-weight: 600; color: #FFFFFF;
      margin-bottom: 14px;
    }
    .footer-col p, .footer-col a {
      font-size: .85rem; color: #A0A0A0; line-height: 1.8;
      text-decoration: none; display: block;
    }
    .footer-col a:hover { color: #C9A84C; }
    .footer-bottom {
      border-top: 1px solid #2A2A2A; padding-top: 20px;
      text-align: center; font-size: .8rem; color: #666;
    }

    @media (max-width: 768px) {
      .navbar { padding: 0 14px; height: 56px; }
      .nav-links { display: none; }
      .nav-user-name { display: none; }
      .nav-actions .btn { padding: 6px 10px; font-size: .78rem; }
      .footer-grid { grid-template-columns: 1fr; gap: 20px; }
      footer { padding: 32px 16px 20px; }
      .hero { padding: 80px 16px 48px; }
      .hero h1 { font-size: clamp(1.8rem, 7vw, 3rem); }
      .hero p { font-size: .9rem; }
      .hero-actions { flex-direction: column; align-items: center; gap: 10px; }
      .hero-actions .btn { width: 100%; max-width: 280px; }
      section { padding: 48px 0; }
      .section-title { font-size: 1.6rem; margin-bottom: 24px; }
    }
    @media (max-width: 480px) {
      .services-grid { grid-template-columns: 1fr; }
      .reviews-grid  { grid-template-columns: 1fr; }
      .nav-logo { font-size: .85rem; letter-spacing: .06em; }
    }
  </style>
</head>
<body>

<!-- ── NAVBAR ── -->
<nav class="navbar">
  <a href="${pageContext.request.contextPath}/index.jsp" class="nav-logo">BARBONS BARBER</a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/index.jsp" class="active">Home</a></li>
    <% if (loggedInName != null && !"admin".equals(role)) { %>
      <li><a href="${pageContext.request.contextPath}/customer/dashboard.jsp">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">My Appointments</a></li>
    <% } else { %>
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp">Book Appointment</a></li>
    <% } %>
    <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/customer/contact.jsp">Contact</a></li>
  </ul>
  <div class="nav-actions">
    <% if (loggedInName != null) { %>
      <div class="nav-user-avatar">
        <% if (loggedInPic != null && !loggedInPic.isEmpty()) { %>
          <img src="<%= request.getContextPath() %>/uploads/profiles/<%= loggedInPic %>"
               alt="Profile" style="width:30px;height:30px;border-radius:50%;object-fit:cover;display:block;">
        <% } else { %>&#128100;<% } %>
      </div>
      <span class="nav-user-name"><%= loggedInName %></span>
      <% if ("admin".equals(role)) { %>
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

<!-- ── HERO ── -->
<section class="hero">
  <div class="hero-content">
    <p class="hero-eyebrow">Premium Grooming Experience</p>
    <h1>Premium Barber Experience</h1>
    <p>Expert cuts, classic shaves, and modern styles — all in one place. Book your appointment in seconds.</p>
    <div class="hero-actions">
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="btn btn-primary">Book Now</a>
      <a href="${pageContext.request.contextPath}/reviews.jsp" class="btn btn-outline-light">See Reviews</a>
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
            <span class="svc-price">Rs. <%= String.format("%.2f", s.getPrice()) %></span>
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
<section style="background: #0D0D0D; border-top: 1px solid #1E1E1E; border-bottom: 1px solid var(--border);">
  <div class="container">
    <p class="section-label">Client Feedback</p>
    <h2 class="section-title" style="color:#FFFFFF;">What Our Clients Say</h2>
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
        <h4>BARBONS BARBER</h4>
        <p>Pokhara, Nepal</p>
        <p style="margin-top:8px">Mon–Sun: 8 AM – 7 PM</p>
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
        <a href="tel:+9779800000000">+977 9800000000</a>
        <a href="${pageContext.request.contextPath}/customer/contact.jsp">Send a Message</a>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; 2026 BARBONS BARBER. All rights reserved.
    </div>
  </div>
</footer>

</body>
</html>

