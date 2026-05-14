<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contact — BARBER'S</title>
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

    .contact-layout {
      display: grid; grid-template-columns: 1fr 1fr; gap: 48px;
      max-width: 1100px; margin: 60px auto; padding: 0 24px;
      align-items: start;
    }
    .contact-left h1 {
      font-family: 'Playfair Display', serif;
      font-size: 2.2rem; font-weight: 700; color: var(--text); margin-bottom: 14px;
    }
    .contact-left p {
      color: var(--muted); font-size: .95rem; line-height: 1.7; margin-bottom: 32px;
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

    .contact-form { background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 32px; }
    .contact-form h3 {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem; font-weight: 600; color: var(--text); margin-bottom: 24px;
    }
    .map-wrap { margin-top: 28px; border-radius: 10px; overflow: hidden; border: 1px solid var(--border); }
    .map-wrap iframe { display: block; width: 100%; height: 280px; border: none; }

    footer {
      background: var(--surface); border-top: 1px solid var(--border);
      padding: 32px 60px; text-align: center;
      font-size: .82rem; color: var(--muted);
    }

    @media (max-width: 768px) {
      .contact-layout { grid-template-columns: 1fr; }
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
    <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
    <li><a href="${pageContext.request.contextPath}/contact.jsp" class="active">Contact</a></li>
  </ul>
  <div style="display:flex;gap:10px;">
    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline btn-sm">Log In</a>
    <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a>
  </div>
</nav>

<div class="contact-layout">

  <!-- LEFT -->
  <div class="contact-left">
    <h1>CONTACT US</h1>
    <p>Have a question or want to get in touch? Fill out the form and we'll get back to you as soon as possible. You can also visit us in store during opening hours.</p>

    <div class="contact-form">
      <h3>Send a Message</h3>
      <div class="form-group">
        <label class="form-group" style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Name</label>
        <input type="text" class="form-control" placeholder="Your name">
      </div>
      <div class="form-group" style="margin-top:14px;">
        <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Email</label>
        <input type="email" class="form-control" placeholder="you@example.com">
      </div>
      <div class="form-group" style="margin-top:14px;">
        <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Subject</label>
        <input type="text" class="form-control" placeholder="How can we help?">
      </div>
      <div class="form-group" style="margin-top:14px;">
        <label style="display:block;font-size:.8rem;color:var(--muted);margin-bottom:6px;">Message</label>
        <textarea class="form-control" rows="4" placeholder="Your message..."></textarea>
      </div>
      <button class="btn btn-primary" style="width:100%;margin-top:18px;">Send Message</button>
    </div>

    <table class="hours-table" style="margin-top:32px;">
      <thead>
        <tr><th>Day</th><th style="text-align:right;">Hours</th></tr>
      </thead>
      <tbody>
        <tr><td>Monday – Tuesday</td><td>8 AM – 7 PM</td></tr>
        <tr><td>Wednesday</td><td>8 AM – 7 PM</td></tr>
        <tr><td>Thursday</td><td>8 AM – 7 PM</td></tr>
        <tr><td>Friday</td><td>8 AM – 7 PM</td></tr>
        <tr><td>Saturday</td><td>8 AM – 7 PM</td></tr>
        <tr><td>Sunday</td><td style="color:var(--cancelled);">Closed</td></tr>
      </tbody>
    </table>
  </div>

  <!-- RIGHT -->
  <div>
    <div class="map-wrap">
      <iframe
        src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3022.215573291865!2d-73.98784368459418!3d40.75797597932681!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c25855c6480299%3A0x55194ec5a1ae072e!2sTimes%20Square!5e0!3m2!1sen!2sus!4v1620000000000!5m2!1sen!2sus"
        allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"
        title="Shop Location">
      </iframe>
    </div>
    <div style="margin-top:24px;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:24px;">
      <h4 style="font-family:'Playfair Display',serif;font-size:1rem;color:var(--text);margin-bottom:14px;">Find Us</h4>
      <p style="color:var(--muted);font-size:.88rem;line-height:1.7;">
        123 Main Street<br>
        Downtown, City 10001<br><br>
        <a href="tel:+15551234567" style="color:var(--text);">+1 (555) 123-4567</a><br>
        <a href="mailto:hello@barbers.com" style="color:var(--text);">hello@barbers.com</a>
      </p>
    </div>
  </div>

</div>

<footer>&copy; 2026 BARBER'S. All rights reserved.</footer>

</body>
</html>
