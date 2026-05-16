<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ServiceDAO, com.barbers.model.Service, java.util.List" %>
<%
  // ── Session guard ──
  if (session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String fullName = (String) session.getAttribute("fullName");
  ServiceDAO serviceDAO = new ServiceDAO();
  List<Service> services = serviceDAO.getAllActiveServices();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Appointment — BARBON'S</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
</head>
<body>
<div class="customer-layout">

  <!-- ── SIDEBAR ── -->
  <aside class="sidebar">
    <div class="sidebar-brand"><a href="${pageContext.request.contextPath}/" class="logo">BARBON'S</a></div>
    <div class="sidebar-user">
      <div class="user-avatar">&#128100;</div>
      <div class="user-name"><%= fullName %></div>
      <div class="user-role">Customer</div>
    </div>
    <nav class="sidebar-nav">
      <a href="${pageContext.request.contextPath}/customer/dashboard.jsp">&#9632; Dashboard</a>
      <a href="${pageContext.request.contextPath}/customer/book.jsp" class="active">&#43; Book Appointment</a>
      <a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">&#128197; My Appointments</a>
      <a href="${pageContext.request.contextPath}/reviews.jsp">&#9733; Reviews</a>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp">&#9881; Profile</a>
    </nav>
    <div class="sidebar-footer">
      <a href="${pageContext.request.contextPath}/auth?action=logout">&#8594; Logout</a>
    </div>
  </aside>

  <!-- ── MAIN ── -->
  <main class="main-content">
    <div class="page-header">
      <h1>Schedule Barber Appointment</h1>
      <p>Select your service, pick a date and time, and we'll assign you a barber automatically.</p>
    </div>

    <% if (request.getAttribute("errorMsg") != null) { %>
      <div class="alert alert-error">&#9888; <%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <form id="bookingForm" action="${pageContext.request.contextPath}/appointment" method="post">
      <input type="hidden" name="action" value="book">
      <input type="hidden" name="serviceId" id="hiddenServiceId">
      <input type="hidden" name="apptDate"  id="hiddenDate">
      <input type="hidden" name="apptTime"  id="hiddenTime">

      <div class="booking-layout">

        <!-- LEFT: Steps -->
        <div>

          <!-- Step 1: Service -->
          <div class="booking-step">
            <h3><span class="step-number">1</span> Select Service</h3>
            <div class="service-cards">
              <% for (Service s : services) { %>
                <div class="service-card-option">
                  <input type="radio" name="_svcDisplay" id="svc-<%= s.getServiceId() %>"
                         value="<%= s.getServiceId() %>"
                         data-name="<%= s.getServiceName() %>"
                         data-price="<%= s.getPrice() %>">
                  <label for="svc-<%= s.getServiceId() %>">
                    <span class="svc-name"><%= s.getServiceName() %></span>
                    <span class="svc-price">$<%= String.format("%.2f", s.getPrice()) %></span>
                    <span class="svc-duration"><%= s.getDurationMins() %> min</span>
                  </label>
                </div>
              <% } %>
              <% if (services.isEmpty()) { %>
                <p style="color:var(--muted);">No services available.</p>
              <% } %>
            </div>
          </div>

          <!-- Step 2: Calendar -->
          <div class="booking-step">
            <h3><span class="step-number">2</span> Pick a Date</h3>
            <div class="calendar-wrap">
              <div class="cal-header">
                <button type="button" class="cal-nav-btn" id="prevMonth">&#8249;</button>
                <h4 id="calTitle">Loading...</h4>
                <button type="button" class="cal-nav-btn" id="nextMonth">&#8250;</button>
              </div>
              <div class="cal-grid" id="calGrid"></div>
            </div>
          </div>

          <!-- Step 3: Time -->
          <div class="booking-step">
            <h3><span class="step-number">3</span> Pick a Time</h3>
            <p id="timeSlotsMsg" style="color:var(--muted);font-size:.85rem;margin-bottom:12px;">
              Please select a date first.
            </p>
            <div class="time-slots" id="timeSlots"></div>
          </div>

          <!-- Notes -->
          <div class="booking-step">
            <h3><span class="step-number">4</span> Additional Notes <span style="font-size:.8rem;color:var(--muted);font-weight:400;">(optional)</span></h3>
            <textarea name="notes" class="form-control" rows="3"
                      placeholder="Any special requests or notes for your barber..."></textarea>
          </div>

          <button type="submit" id="confirmBtn" class="btn btn-primary btn-full" disabled
                  style="opacity:.5;cursor:not-allowed;">
            Confirm Booking
          </button>
        </div>

        <!-- RIGHT: Summary -->
        <div>
          <div class="summary-card">
            <h3>Booking Summary</h3>
            <div class="summary-row">
              <span class="label">Service</span>
              <span class="value" id="sumService">—</span>
            </div>
            <div class="summary-row">
              <span class="label">Price</span>
              <span class="value" id="sumPrice">—</span>
            </div>
            <hr>
            <div class="summary-row">
              <span class="label">Date</span>
              <span class="value" id="sumDate">—</span>
            </div>
            <div class="summary-row">
              <span class="label">Time</span>
              <span class="value" id="sumTime">—</span>
            </div>
            <hr>
            <div class="summary-row total">
              <span class="label">Barber</span>
              <span class="value" style="color:var(--muted);font-size:.82rem;">Auto-assigned</span>
            </div>
            <div style="margin-top:20px;padding:14px;background:var(--surface2);border-radius:8px;font-size:.82rem;color:var(--muted);line-height:1.6;">
              &#9432; A barber will be automatically assigned based on availability for your chosen slot.
            </div>
          </div>
        </div>

      </div>
    </form>
  </main>

</div>

<script>
  // Pass context path to booking.js
  var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/booking.js"></script>
</body>
</html>
