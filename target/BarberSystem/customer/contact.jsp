<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Session state for navbar
  String loggedInName = (String) session.getAttribute("fullName");
  String loggedInRole = (String) session.getAttribute("role");
  String loggedInPic  = (String) session.getAttribute("profilePicture");

  // Message sent flag
  boolean messageSent = "1".equals(request.getParameter("sent"));

  // Pre-fill name/email if logged in
  String prefillName  = loggedInName != null ? loggedInName : "";
  String prefillEmail = session.getAttribute("email") != null
      ? (String) session.getAttribute("email") : "";
%>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contact — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
  <style>
    body { background: #F5F0E8; }

    /* ── Layout ── */
    .contact-layout {
      display: grid; grid-template-columns: 1fr 1fr; gap: 40px;
      max-width: 1100px; margin: 40px auto 60px; padding: 0 24px;
      align-items: start;
    }
    .contact-left h1 {
      font-family: 'Playfair Display', serif;
      font-size: 2rem; font-weight: 700; color: var(--text); margin-bottom: 12px;
    }
    .contact-left p {
      color: var(--muted); font-size: .92rem; line-height: 1.7; margin-bottom: 28px;
    }
    .hours-table { width: 100%; border-collapse: collapse; margin-top: 24px; }
    .hours-table th {
      text-align: left; font-size: .75rem; font-weight: 700;
      color: var(--muted); text-transform: uppercase; letter-spacing: .06em;
      padding: 8px 0; border-bottom: 1px solid var(--border);
    }
    .hours-table td {
      padding: 10px 0; font-size: .88rem; color: var(--text);
      border-bottom: 1px solid var(--border);
    }
    .hours-table td:last-child { color: var(--muted); text-align: right; }
    .hours-table tr:last-child td { border-bottom: none; }

    .contact-form {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 10px; padding: 28px;
    }
    .contact-form h3 {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; font-weight: 600; color: var(--text); margin-bottom: 20px;
    }
    .map-wrap {
      border-radius: 10px; overflow: hidden;
      border: 1px solid var(--border);
    }
    .map-wrap iframe { display: block; width: 100%; height: 300px; border: none; }

    footer {
      background: #0D0D0D; border-top: 1px solid #1E1E1E;
      padding: 28px 24px; text-align: center;
      font-size: .82rem; color: #A0A0A0;
    }

    /* ── Mobile ── */
    @media (max-width: 768px) {
      .contact-layout {
        grid-template-columns: 1fr;
        margin: 20px auto 40px;
        padding: 0 14px;
        gap: 24px;
      }
      .contact-left h1 { font-size: 1.5rem; }
      .contact-form { padding: 18px; }
      .map-wrap iframe { height: 220px; }
      footer { padding: 20px 14px; }
    }
    @media (max-width: 480px) {
      .contact-left h1 { font-size: 1.3rem; }
    }

    /* ── Success popup ── */
    .success-popup {
      display: none;
      position: fixed; inset: 0;
      background: rgba(245,240,232,.92);
      backdrop-filter: blur(4px);
      z-index: 500;
      align-items: center; justify-content: center;
    }
    .success-popup.show { display: flex; }
    .success-box {
      background: #FFFFFF;
      border: 1px solid #D8D0C4;
      border-radius: 16px;
      padding: 48px 40px;
      text-align: center;
      max-width: 380px; width: 90%;
      box-shadow: 0 8px 40px rgba(0,0,0,.12);
      animation: popIn .3s ease;
    }
    @keyframes popIn {
      from { opacity:0; transform: scale(.9) translateY(10px); }
      to   { opacity:1; transform: scale(1) translateY(0); }
    }
    .success-icon {
      width: 72px; height: 72px; border-radius: 50%;
      background: #E6F4EC; border: 2px solid #8ECBA8;
      display: flex; align-items: center; justify-content: center;
      font-size: 2rem; margin: 0 auto 20px;
    }
    .success-box h2 {
      font-family: 'Playfair Display', serif;
      font-size: 1.5rem; font-weight: 700;
      color: #1A1A1A; margin-bottom: 10px;
    }
    .success-box p {
      font-size: .88rem; color: #7A7060;
      line-height: 1.6; margin-bottom: 28px;
    }
    .success-box a {
      display: inline-block; padding: 12px 32px;
      background: #0D0D0D; color: #FFFFFF;
      border-radius: 8px; font-weight: 600;
      font-size: .9rem; text-decoration: none;
      transition: background .2s;
    }
    .success-box a:hover { background: #2A2A2A; }
  </style>
</head>
<body>

<!-- ── SUCCESS POPUP ── -->
<div class="success-popup <%= messageSent ? "show" : "" %>">
  <div class="success-box">
    <div class="success-icon">&#10003;</div>
    <h2>Message Sent!</h2>
    <p>
      Thank you for reaching out.<br>
      We'll get back to you as soon as possible.
    </p>
    <a href="${pageContext.request.contextPath}/customer/contact.jsp">Back to Contact</a>
  </div>
</div>

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
    <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/customer/contact.jsp" class="active">Contact</a></li>
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

<div class="contact-layout">

  <!-- LEFT -->
  <div class="contact-left">
    <h1>CONTACT US</h1>
    <p>Have a question or want to get in touch? Fill out the form and we'll get back to you as soon as possible. You can also visit us in store during opening hours.</p>

    <div class="contact-form">
      <h3>Send a Message</h3>
      <form method="get" action="${pageContext.request.contextPath}/customer/contact.jsp">
        <input type="hidden" name="sent" value="1">
        <div class="form-group">
          <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Name</label>
          <input type="text" name="cname" class="form-control"
                 placeholder="Your name" value="<%= prefillName %>" required>
        </div>
        <div class="form-group" style="margin-top:14px;">
          <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Email</label>
          <input type="email" name="cemail" class="form-control"
                 placeholder="you@example.com" value="<%= prefillEmail %>" required>
        </div>
        <div class="form-group" style="margin-top:14px;">
          <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Subject</label>
          <input type="text" name="csubject" class="form-control"
                 placeholder="How can we help?" required>
        </div>
        <div class="form-group" style="margin-top:14px;">
          <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Message</label>
          <textarea name="cmessage" class="form-control" rows="4"
                    placeholder="Your message..." required></textarea>
        </div>
        <button type="submit" class="btn btn-primary" style="width:100%;margin-top:18px;">
          &#9993; Send Message
        </button>
      </form>
    </div>

    <table class="hours-table" style="margin-top:32px;">
      <thead>
        <tr><th>Day</th><th style="text-align:right;">Hours</th></tr>
      </thead>
      <tbody>
        <tr><td>Sunday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Monday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Tuesday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Wednesday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Thursday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Friday</td><td>9 AM – 5 PM</td></tr>
        <tr><td>Saturday</td><td>9 AM – 5 PM</td></tr>
      </tbody>
    </table>
  </div>

  <!-- RIGHT -->
  <div>
    <div class="map-wrap">
      <iframe
        src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3516.1!2d83.9856!3d28.2096!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3995937bbf0376ff%3A0x5d7f4e8f8b8b8b8b!2sInformatics%20College%20Pokhara!5e0!3m2!1sen!2snp!4v1716800000000!5m2!1sen!2snp"
        allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"
        title="Informatics College Pokhara">
      </iframe>
    </div>
    <div style="margin-top:24px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:24px;">
      <h4 style="font-family:'Playfair Display',serif;font-size:1rem;color:var(--text);margin-bottom:14px;">Find Us</h4>
      <p style="color:var(--muted);font-size:.88rem;line-height:1.7;">
        Informatics College Pokhara<br>
        Matepani, Pokhara, Nepal<br><br>
        <a href="tel:+9779800000000" style="color:var(--text);">+977 9800000000</a><br>
        <a href="mailto:hello@barbers.com" style="color:var(--text);">hello@barbers.com</a>
      </p>
    </div>
  </div>

</div>

<footer>&copy; 2026 BARBONS BARBER. All rights reserved.</footer>

</body>
</html>
