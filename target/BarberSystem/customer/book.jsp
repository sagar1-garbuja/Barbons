<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.barbers.dao.ServiceDAO, com.barbers.dao.BarberDAO, com.barbers.dao.AppointmentDAO" %>
<%@ page import="com.barbers.model.Service, com.barbers.model.Barber" %>
<%@ page import="java.util.List, java.util.Arrays, java.sql.Date, java.sql.Time" %>
<%@ page import="java.time.LocalDate, java.time.YearMonth, java.time.format.TextStyle, java.util.Locale" %>
<%
  if (session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String fullName = (String) session.getAttribute("fullName");
  String _pic     = (String) session.getAttribute("profilePicture");

  // ── Step state from request params ──
  String step       = request.getParameter("step");
  if (step == null) step = "1";

  String selServiceId = request.getParameter("serviceId");
  String selDate      = request.getParameter("apptDate");
  String selTime      = request.getParameter("apptTime");
  String selBarberId  = request.getParameter("barberId");
  String selPayment   = request.getParameter("paymentMethod");
  String notes        = request.getParameter("notes");
  String errorMsg     = (String) request.getAttribute("errorMsg");
  if (selPayment == null) selPayment = "";

  // ── Load data ──
  ServiceDAO     svcDAO    = new ServiceDAO();
  BarberDAO      barberDAO = new BarberDAO();
  AppointmentDAO apptDAO   = new AppointmentDAO();

  // Service search — filter by name server-side
  String searchQuery = request.getParameter("serviceSearch");
  if (searchQuery == null) searchQuery = "";
  String searchTrim = searchQuery.trim().toLowerCase();

  List<Service> allServices = svcDAO.getAllActiveServices();
  List<Service> services = new java.util.ArrayList<>();
  for (Service s : allServices) {
    if (searchTrim.isEmpty() || s.getServiceName().toLowerCase().contains(searchTrim)) {
      services.add(s);
    }
  }

  // Calendar: month navigation
  String monthParam = request.getParameter("calMonth"); // YYYY-MM
  LocalDate today   = LocalDate.now();
  YearMonth ym;
  try { ym = (monthParam != null) ? YearMonth.parse(monthParam) : YearMonth.now(); }
  catch (Exception e) { ym = YearMonth.now(); }
  if (ym.isBefore(YearMonth.now())) ym = YearMonth.now();

  YearMonth prevYm = ym.minusMonths(1);
  YearMonth nextYm = ym.plusMonths(1);
  boolean   canPrev = ym.isAfter(YearMonth.now());

  // Time slots
  String[] ALL_SLOTS = {"09:00","09:30","10:00","10:30","11:00","11:30",
                        "12:00","12:30","13:00","13:30","14:00","14:30",
                        "15:00","15:30","16:00","16:30","17:00"};

  // Booked times for selected date
  List<String> bookedTimes = new java.util.ArrayList<>();
  if (selDate != null && !selDate.isEmpty()) {
    try { bookedTimes = apptDAO.getBookedTimesForDate(Date.valueOf(selDate)); }
    catch (Exception ignored) {}
  }

  // Available barbers for selected date+time — ALL shown, booked ones disabled
  List<Barber> availableBarbers = new java.util.ArrayList<>();
  if (selDate != null && !selDate.isEmpty() && selTime != null && !selTime.isEmpty()) {
    try {
      availableBarbers = barberDAO.getAllBarbersWithAvailability(
          Date.valueOf(selDate), Time.valueOf(selTime + ":00"));
    } catch (Exception ignored) {}
  }

  // Resolve selected service name/price for summary
  String selServiceName  = "—";
  String selServicePrice = "—";
  if (selServiceId != null && !selServiceId.isEmpty()) {
    for (Service s : services) {
      if (String.valueOf(s.getServiceId()).equals(selServiceId)) {
        selServiceName  = s.getServiceName();
        selServicePrice = "Rs. " + String.format("%.2f", s.getPrice());
        break;
      }
    }
  }
  String selBarberName = "—";
  if (selBarberId != null && !selBarberId.isEmpty()) {
    for (Barber b : availableBarbers) {
      if (String.valueOf(b.getBarberId()).equals(selBarberId)) {
        selBarberName = b.getName(); break;
      }
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Appointment — BARBONS BARBER</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css">
  <style>
    .barber-cards { display:grid; grid-template-columns:repeat(auto-fill,minmax(150px,1fr)); gap:12px; }
    .barber-card-option { position:relative; }
    .barber-card-option input[type="radio"] { position:absolute; opacity:0; width:0; height:0; }
    .barber-card-option label {
      display:flex; flex-direction:column; align-items:center; gap:8px;
      padding:18px 12px; border:1.5px solid var(--border);
      border-radius:var(--radius); cursor:pointer; text-align:center;
      background:var(--surface);
      transition:border-color .2s, background .2s;
    }
    .barber-card-option input:checked + label { border-color:var(--accent); background:var(--accent-light); }
    .barber-card-option label:hover { border-color:var(--accent); }
    .barber-avatar {
      width:52px; height:52px; border-radius:50%;
      background:var(--surface2); border:1px solid var(--border);
      display:flex; align-items:center; justify-content:center;
      font-size:1.4rem; color:var(--muted);
    }
    .barber-name { font-size:.88rem; font-weight:600; color:var(--text); }
    .barber-spec { font-size:.75rem; color:var(--muted); }

    /* Service search */
    .service-search-wrap {
      display:flex; gap:10px; align-items:center;
      margin-bottom:20px;
    }
    .service-search-input {
      flex:1; padding:10px 14px;
      background:var(--surface); border:1.5px solid var(--border);
      border-radius:var(--radius-sm); color:var(--text);
      font-family:'DM Sans',sans-serif; font-size:.9rem;
      outline:none; transition:border-color .2s;
    }
    .service-search-input:focus { border-color:var(--accent); }
    .service-search-input::placeholder { color:#B8B0A4; }
    .service-search-btn {
      padding:10px 18px; background:var(--nav-bg); color:#fff;
      border:none; border-radius:var(--radius-sm);
      font-family:'DM Sans',sans-serif; font-size:.88rem; font-weight:600;
      cursor:pointer; white-space:nowrap;
      transition:background .2s;
    }
    .service-search-btn:hover { background:#2A2A2A; }
    .service-search-clear {
      padding:10px 14px; background:transparent; color:var(--muted);
      border:1.5px solid var(--border); border-radius:var(--radius-sm);
      font-family:'DM Sans',sans-serif; font-size:.88rem;
      cursor:pointer; text-decoration:none;
      display:inline-flex; align-items:center;
      transition:border-color .2s, color .2s;
    }
    .service-search-clear:hover { border-color:var(--accent); color:var(--accent); }
    /* Calendar */
    .cal-grid { display:grid; grid-template-columns:repeat(7,1fr); background:var(--surface); }
    .cal-day-name {
      text-align:center; padding:10px 0; font-size:.7rem; font-weight:700;
      color:var(--muted); letter-spacing:.06em; text-transform:uppercase;
      border-bottom:1px solid var(--border);
    }
    .cal-day {
      text-align:center; padding:10px 4px; font-size:.85rem; color:var(--muted);
      border-radius:4px; margin:2px;
    }
    .cal-day.available { cursor:pointer; }
    .cal-day.available:hover { background:var(--accent-light); color:var(--text); }
    .cal-day.selected  { background:var(--nav-bg); color:var(--accent); font-weight:700; border-radius:6px; }
    .cal-day.today     { border:1.5px solid var(--accent); color:var(--text); font-weight:600; }
    .cal-day.past      { color:var(--border); }
    .cal-day.empty     { }
    /* Time slots */
    .time-slots { display:grid; grid-template-columns:repeat(auto-fill,minmax(90px,1fr)); gap:8px; margin-top:12px; }
    .time-slot {
      padding:9px 6px; text-align:center; border:1.5px solid var(--border);
      border-radius:var(--radius-sm); font-size:.82rem; color:var(--muted);
      background:var(--surface);
    }
    .time-slot.available { cursor:pointer; }
    .time-slot.available:hover { border-color:var(--accent); color:var(--text); background:var(--accent-light); }
    .time-slot.selected  { background:var(--nav-bg); color:var(--accent); font-weight:600; border-color:var(--nav-bg); }
    .time-slot.booked    { background:var(--surface2); color:var(--border); text-decoration:line-through; }
    /* Step indicator */
    .step-indicator { display:flex; gap:0; margin-bottom:28px; }
    .step-ind-item {
      flex:1; text-align:center; padding:10px 6px; font-size:.75rem; font-weight:600;
      color:var(--muted); background:var(--surface); border:1px solid var(--border);
      border-right:none; text-transform:uppercase; letter-spacing:.04em;
    }
    .step-ind-item:first-child { border-radius:var(--radius-sm) 0 0 var(--radius-sm); }
    .step-ind-item:last-child  { border-radius:0 var(--radius-sm) var(--radius-sm) 0; border-right:1px solid var(--border); }
    .step-ind-item.active { background:var(--nav-bg); color:var(--accent); border-color:var(--nav-bg); }
    .step-ind-item.done   { background:var(--accent-light); color:var(--text); border-color:var(--accent); }

    /* Payment options */
    .payment-options { display:flex; flex-direction:column; gap:12px; }
    .payment-option  { position:relative; }
    .payment-option input[type="radio"] { position:absolute; opacity:0; width:0; height:0; }
    .payment-option label {
      display:flex; align-items:center; gap:16px;
      padding:16px 20px; border:2px solid var(--border);
      border-radius:var(--radius); cursor:pointer;
      background:var(--surface);
      transition:border-color .2s, background .2s;
    }
    .payment-option input:checked + label {
      border-color:var(--accent); background:var(--accent-light);
    }
    .payment-option label:hover { border-color:var(--accent); }
    .payment-icon {
      width:44px; height:44px; border-radius:8px;
      display:flex; align-items:center; justify-content:center;
      font-size:1.4rem; flex-shrink:0;
    }
    .payment-icon.cash    { background:#E6F4EC; }
    .payment-icon.esewa   { background:#E8F5E9; }
    .payment-icon.fonepay { background:#E3F2FD; }
    .payment-label { flex:1; }
    .payment-label strong { display:block; font-size:.92rem; color:var(--text); font-weight:700; }
    .payment-label span   { font-size:.8rem; color:var(--muted); }
    .payment-badge {
      font-size:.7rem; font-weight:700; padding:3px 8px;
      border-radius:20px; text-transform:uppercase; letter-spacing:.04em;
    }
    .payment-badge.free    { background:#E6F4EC; color:#2A7A4B; }
    .payment-badge.advance { background:#FEF3E2; color:#D4860A; }

    /* Sub-options (eSewa / FonePay) */
    .advance-sub {
      margin-top:12px; margin-left:20px;
      padding:16px; background:var(--surface2);
      border:1px solid var(--border); border-radius:var(--radius);
      display:none;
    }
    .advance-sub.show { display:block; }
    .sub-options { display:flex; gap:12px; flex-wrap:wrap; }
    .sub-option  { position:relative; }
    .sub-option input[type="radio"] { position:absolute; opacity:0; width:0; height:0; }
    .sub-option label {
      display:flex; align-items:center; gap:10px;
      padding:12px 18px; border:2px solid var(--border);
      border-radius:var(--radius); cursor:pointer;
      background:var(--surface); min-width:140px;
      transition:border-color .2s, background .2s;
    }
    .sub-option input:checked + label { border-color:var(--accent); background:var(--accent-light); }
    .sub-option label:hover { border-color:var(--accent); }
    .sub-logo { font-size:1.2rem; }
    .sub-name  { font-size:.88rem; font-weight:700; color:var(--text); }
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
      <li><a href="${pageContext.request.contextPath}/customer/book.jsp" class="active">Book Appointment</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/my-appointments.jsp">My Appointments</a></li>
      <li><a href="${pageContext.request.contextPath}/reviews.jsp">Reviews</a></li>
      <li><a href="${pageContext.request.contextPath}/customer/contact.jsp">Contact</a></li>
    </ul>
    <div class="customer-nav-right">
      <div class="customer-nav-avatar">
        <% if (_pic != null && !_pic.isEmpty()) { %>
          <img src="<%= request.getContextPath() %>/uploads/profiles/<%= _pic %>"
               alt="Profile" style="width:34px;height:34px;border-radius:50%;object-fit:cover;display:block;">
        <% } else { %>&#128100;<% } %>
      </div>
      <span class="customer-nav-name"><%= fullName %></span>
      <a href="${pageContext.request.contextPath}/customer/profile.jsp" class="btn btn-outline-light btn-sm">Profile</a>
      <a href="${pageContext.request.contextPath}/logout-confirm.jsp" class="btn btn-primary btn-sm">Logout</a>
    </div>
  </nav>

  <main class="main-content">
    <div class="page-header">
      <h1>Book an Appointment</h1>
      <p>Complete each step to confirm your booking.</p>
    </div>

    <% if (errorMsg != null) { %>
      <div class="alert alert-error">&#9888; <%= errorMsg %></div>
    <% } %>

    <!-- Step indicator -->
    <div class="step-indicator">
      <div class="step-ind-item <%= "1".equals(step) ? "active" : (selServiceId!=null&&!selServiceId.isEmpty()?"done":"") %>">1. Service</div>
      <div class="step-ind-item <%= "2".equals(step) ? "active" : (selDate!=null&&selTime!=null&&!selDate.isEmpty()&&!selTime.isEmpty()?"done":"") %>">2. Date &amp; Time</div>
      <div class="step-ind-item <%= "3".equals(step) ? "active" : (selBarberId!=null&&!selBarberId.isEmpty()?"done":"") %>">3. Barber</div>
      <div class="step-ind-item <%= "4".equals(step) ? "active" : (selPayment!=null&&!selPayment.isEmpty()?"done":"") %>">4. Payment</div>
      <div class="step-ind-item <%= "5".equals(step) ? "active" : "" %>">5. Confirm</div>
    </div>

    <div class="booking-layout">
      <div>

      <%-- ══════════════ STEP 1: SERVICE ══════════════ --%>
      <% if ("1".equals(step)) { %>
        <div class="booking-step">
          <h3><span class="step-number">1</span> Select a Service</h3>

          <%-- Search box — GET form so it reloads step 1 with filtered results --%>
          <form method="get" action="${pageContext.request.contextPath}/customer/book.jsp"
                class="service-search-wrap">
            <input type="hidden" name="step" value="1">
            <input type="text" name="serviceSearch" class="service-search-input"
                   placeholder="&#128269; Search services..."
                   value="<%= searchQuery %>">
            <button type="submit" class="service-search-btn">Search</button>
            <% if (!searchTrim.isEmpty()) { %>
              <a href="?step=1" class="service-search-clear">&#10005; Clear</a>
            <% } %>
          </form>

          <% if (!searchTrim.isEmpty()) { %>
            <p style="font-size:.82rem;color:var(--muted);margin-bottom:14px;">
              <%= services.isEmpty() ? "No services found for" : services.size() + " result(s) for" %>
              &ldquo;<strong style="color:var(--text);"><%= searchQuery %></strong>&rdquo;
            </p>
          <% } %>

          <form method="get" action="${pageContext.request.contextPath}/customer/book.jsp">
            <input type="hidden" name="step" value="2">
            <% if (!searchTrim.isEmpty()) { %>
              <input type="hidden" name="serviceSearch" value="<%= searchQuery %>">
            <% } %>
            <div class="service-cards">
              <% for (Service s : services) { %>
                <div class="service-card-option">
                  <input type="radio" name="serviceId" id="svc-<%= s.getServiceId() %>"
                         value="<%= s.getServiceId() %>"
                         <%= (String.valueOf(s.getServiceId()).equals(selServiceId)) ? "checked" : "" %>
                         required>
                  <label for="svc-<%= s.getServiceId() %>">
                    <span class="svc-name"><%= s.getServiceName() %></span>
                    <span class="svc-price">Rs. <%= String.format("%.2f", s.getPrice()) %></span>
                    <span class="svc-duration"><%= s.getDurationMins() %> min</span>
                  </label>
                </div>
              <% } %>
              <% if (services.isEmpty()) { %>
                <p style="color:var(--muted);">No services available.</p>
              <% } %>
            </div>
            <div style="margin-top:20px;">
              <button type="submit" class="btn btn-primary">Next: Pick Date &amp; Time &rarr;</button>
            </div>
          </form>
        </div>

      <%-- ══════════════ STEP 2: DATE + TIME ══════════════ --%>
      <% } else if ("2".equals(step)) { %>
        <div class="booking-step">
          <h3><span class="step-number">2</span> Pick a Date &amp; Time</h3>

          <%-- Calendar --%>
          <div class="calendar-wrap" style="margin-bottom:24px;">
            <div class="cal-header">
              <% if (canPrev) { %>
                <a href="?step=2&serviceId=<%= selServiceId %>&calMonth=<%= prevYm %>"
                   class="cal-nav-btn" style="text-decoration:none;">&#8249;</a>
              <% } else { %>
                <span class="cal-nav-btn" style="opacity:.3;">&#8249;</span>
              <% } %>
              <h4><%= ym.getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH) %> <%= ym.getYear() %></h4>
              <a href="?step=2&serviceId=<%= selServiceId %>&calMonth=<%= nextYm %>"
                 class="cal-nav-btn" style="text-decoration:none;">&#8250;</a>
            </div>
            <div class="cal-grid">
              <% String[] dayNames = {"Su","Mo","Tu","We","Th","Fr","Sa"};
                 for (String dn : dayNames) { %>
                <div class="cal-day-name"><%= dn %></div>
              <% } %>
              <%
                int firstDow = ym.atDay(1).getDayOfWeek().getValue() % 7; // Sun=0
                int daysInMonth = ym.lengthOfMonth();
                for (int e = 0; e < firstDow; e++) { %>
                  <div class="cal-day empty"></div>
              <% }
                 for (int d = 1; d <= daysInMonth; d++) {
                   LocalDate cellDate = ym.atDay(d);
                   String ds = cellDate.toString();
                   boolean isPast    = !cellDate.isAfter(today);
                   boolean isToday   = cellDate.equals(today);
                   boolean isSelected = ds.equals(selDate);
                   String cls = isPast ? "past" : "available";
                   if (isToday)    cls += " today";
                   if (isSelected) cls += " selected";
              %>
                  <% if (!isPast) { %>
                    <a href="?step=2&serviceId=<%= selServiceId %>&calMonth=<%= ym %>&apptDate=<%= ds %>"
                       class="cal-day <%= cls %>" style="text-decoration:none;display:block;"><%= d %></a>
                  <% } else { %>
                    <div class="cal-day <%= cls %>"><%= d %></div>
                  <% } %>
              <% } %>
            </div>
          </div>

          <%-- Time slots (only show if date selected) --%>
          <% if (selDate != null && !selDate.isEmpty()) { %>
            <h4 style="font-family:'Playfair Display',serif;font-size:.95rem;margin-bottom:12px;color:var(--text);">
              Available times for <%= selDate %>
            </h4>
            <form method="get" action="${pageContext.request.contextPath}/customer/book.jsp">
              <input type="hidden" name="step"      value="3">
              <input type="hidden" name="serviceId" value="<%= selServiceId %>">
              <input type="hidden" name="apptDate"  value="<%= selDate %>">
              <div class="time-slots">
                <% for (String slot : ALL_SLOTS) {
                     boolean isBooked   = bookedTimes.contains(slot);
                     boolean isSelTime  = slot.equals(selTime);
                     String tCls = isBooked ? "booked" : (isSelTime ? "selected available" : "available");
                     // Format display: 09:00 → 9:00 AM
                     int hh = Integer.parseInt(slot.split(":")[0]);
                     String mm = slot.split(":")[1];
                     String ampm = hh >= 12 ? "PM" : "AM";
                     int h12 = hh % 12; if (h12 == 0) h12 = 12;
                     String display = h12 + ":" + mm + " " + ampm;
                %>
                  <% if (!isBooked) { %>
                    <button type="submit" name="apptTime" value="<%= slot %>"
                            class="time-slot <%= tCls %>" style="border:none;cursor:pointer;">
                      <%= display %>
                    </button>
                  <% } else { %>
                    <div class="time-slot booked" title="Fully booked"><%= display %></div>
                  <% } %>
                <% } %>
              </div>
            </form>
          <% } else { %>
            <p style="color:var(--muted);font-size:.88rem;">Please select a date above to see available times.</p>
          <% } %>

          <div style="margin-top:20px;">
            <a href="?step=1" class="btn btn-outline btn-sm">&larr; Back</a>
          </div>
        </div>

      <%-- ══════════════ STEP 3: BARBER ══════════════ --%>
      <% } else if ("3".equals(step)) { %>
        <div class="booking-step">
          <h3><span class="step-number">3</span> Choose Your Barber</h3>
          <% if (availableBarbers.isEmpty()) { %>
            <div class="alert alert-error">
              &#9888; No barbers available for this slot. Please
              <a href="?step=2&serviceId=<%= selServiceId %>" style="text-decoration:underline;">choose a different time</a>.
            </div>
          <% } else { %>
            <form method="get" action="${pageContext.request.contextPath}/customer/book.jsp">
              <input type="hidden" name="step"      value="4">
              <input type="hidden" name="serviceId" value="<%= selServiceId %>">
              <input type="hidden" name="apptDate"  value="<%= selDate %>">
              <input type="hidden" name="apptTime"  value="<%= selTime %>">
              <div class="barber-cards" style="margin-bottom:20px;">
                <% for (Barber b : availableBarbers) {
                     boolean isBooked = b.isBooked();
                %>
                  <div class="barber-card-option">
                    <input type="radio" name="barberId" id="barber-<%= b.getBarberId() %>"
                           value="<%= b.getBarberId() %>"
                           <%= (String.valueOf(b.getBarberId()).equals(selBarberId)) ? "checked" : "" %>
                           <%= isBooked ? "disabled" : "" %>
                           <%= isBooked ? "" : "required" %>>
                    <label for="barber-<%= b.getBarberId() %>"
                           style="<%= isBooked ? "opacity:.5;cursor:not-allowed;background:#f5f5f5;" : "" %>">
                      <div class="barber-avatar" style="position:relative;">
                        &#9986;
                        <% if (isBooked) { %>
                          <span style="position:absolute;top:-4px;right:-4px;
                                       background:#B03A2E;color:#fff;font-size:.55rem;
                                       font-weight:700;padding:2px 5px;border-radius:10px;
                                       text-transform:uppercase;letter-spacing:.04em;">Booked</span>
                        <% } %>
                      </div>
                      <div class="barber-name"><%= b.getName() %></div>
                      <% if (b.getSpeciality() != null && !b.getSpeciality().isEmpty()) { %>
                        <div class="barber-spec"><%= b.getSpeciality() %></div>
                      <% } %>
                      <% if (isBooked) { %>
                        <div style="font-size:.7rem;color:#B03A2E;font-weight:600;margin-top:2px;">
                          Not available
                        </div>
                      <% } %>
                    </label>
                  </div>
                <% } %>
              </div>
              <button type="submit" class="btn btn-primary">Next: Payment &rarr;</button>
            </form>
          <% } %>
          <div style="margin-top:12px;">
            <a href="?step=2&serviceId=<%= selServiceId %>&apptDate=<%= selDate %>" class="btn btn-outline btn-sm">&larr; Back</a>
          </div>
        </div>

      <%-- ══════════════ STEP 4: PAYMENT ══════════════ --%>
      <% } else if ("4".equals(step)) { %>
        <div class="booking-step">
          <h3><span class="step-number">4</span> Choose Payment Method</h3>
          <p style="color:var(--muted);font-size:.88rem;margin-bottom:20px;">
            How would you like to pay for your appointment?
          </p>

          <form method="get" action="${pageContext.request.contextPath}/customer/book.jsp">
            <input type="hidden" name="step"      value="5">
            <input type="hidden" name="serviceId" value="<%= selServiceId %>">
            <input type="hidden" name="apptDate"  value="<%= selDate %>">
            <input type="hidden" name="apptTime"  value="<%= selTime %>">
            <input type="hidden" name="barberId"  value="<%= selBarberId %>">

            <div class="payment-options">

              <%-- Cash after haircut only --%>
              <div class="payment-option">
                <input type="radio" name="paymentMethod" id="pay-cash" value="cash" checked required>
                <label for="pay-cash">
                  <div class="payment-icon cash">&#128181;</div>
                  <div class="payment-label">
                    <strong>Cash After Haircut</strong>
                    <span>Pay in cash when your service is complete</span>
                  </div>
                </label>
              </div>

            </div>

            <div style="margin-top:20px;">
              <button type="submit" class="btn btn-primary">Next: Confirm &rarr;</button>
            </div>
          </form>

          <div style="margin-top:12px;">
            <a href="?step=3&serviceId=<%= selServiceId %>&apptDate=<%= selDate %>&apptTime=<%= selTime %>"
               class="btn btn-outline btn-sm">&larr; Back</a>
          </div>
        </div>

      <%-- ══════════════ STEP 5: CONFIRM ══════════════ --%>
      <% } else if ("5".equals(step)) { %>
        <div class="booking-step">
          <h3><span class="step-number">5</span> Confirm Your Booking</h3>

          <%-- eSewa Payment Portal --%>
          <% if ("esewa".equals(selPayment)) { %>
            <div style="max-width:400px;margin:0 auto 24px;">
              <!-- eSewa Portal Header -->
              <div style="background:#60BB46;border-radius:12px 12px 0 0;padding:20px 24px;
                          display:flex;align-items:center;gap:14px;">
                <div style="width:48px;height:48px;background:#fff;border-radius:50%;
                            display:flex;align-items:center;justify-content:center;">
                  <span style="font-size:1.1rem;font-weight:900;color:#60BB46;">e</span>
                </div>
                <div>
                  <div style="font-size:1.1rem;font-weight:800;color:#fff;letter-spacing:.02em;">eSewa</div>
                  <div style="font-size:.78rem;color:rgba(255,255,255,.85);">Digital Wallet Payment</div>
                </div>
                <div style="margin-left:auto;text-align:right;">
                  <div style="font-size:.72rem;color:rgba(255,255,255,.8);">Amount</div>
                  <div style="font-size:1.2rem;font-weight:800;color:#fff;"><%= selServicePrice %></div>
                </div>
              </div>
              <!-- eSewa Portal Body -->
              <div style="background:#fff;border:1px solid #D0ECC8;border-top:none;
                          border-radius:0 0 12px 12px;padding:24px;">
                <p style="font-size:.82rem;color:#555;margin-bottom:18px;text-align:center;">
                  Enter your eSewa credentials to complete payment
                </p>
                <form action="${pageContext.request.contextPath}/appointment" method="post">
                  <input type="hidden" name="action"        value="book">
                  <input type="hidden" name="serviceId"     value="<%= selServiceId %>">
                  <input type="hidden" name="apptDate"      value="<%= selDate %>">
                  <input type="hidden" name="apptTime"      value="<%= selTime %>">
                  <input type="hidden" name="barberId"      value="<%= selBarberId %>">
                  <input type="hidden" name="paymentMethod" value="esewa">
                  <input type="hidden" name="notes"         value="<%= notes != null ? notes : "" %>">

                  <div style="margin-bottom:14px;">
                    <label style="display:block;font-size:.78rem;font-weight:700;color:#444;
                                  margin-bottom:6px;text-transform:uppercase;letter-spacing:.04em;">
                      eSewa ID / Mobile Number
                    </label>
                    <input type="tel" name="esewaPhone" class="form-control"
                           placeholder="98XXXXXXXX" maxlength="10" required
                           style="border-color:#60BB46;font-size:.95rem;">
                  </div>

                  <div style="margin-bottom:20px;">
                    <label style="display:block;font-size:.78rem;font-weight:700;color:#444;
                                  margin-bottom:6px;text-transform:uppercase;letter-spacing:.04em;">
                      MPIN
                    </label>
                    <input type="password" name="esewaMpin" class="form-control"
                           placeholder="Enter your MPIN" maxlength="6" required
                           style="border-color:#60BB46;font-size:.95rem;letter-spacing:.2em;">
                    <p style="font-size:.72rem;color:#888;margin-top:4px;">
                      &#128274; Your credentials are secure and encrypted
                    </p>
                  </div>

                  <button type="submit" style="width:100%;padding:14px;background:#60BB46;
                          color:#fff;border:none;border-radius:8px;font-size:.95rem;
                          font-weight:700;cursor:pointer;letter-spacing:.02em;">
                    Pay <%= selServicePrice %>
                  </button>
                </form>

                <div style="margin-top:16px;text-align:center;">
                  <a href="?step=4&serviceId=<%= selServiceId %>&apptDate=<%= selDate %>&apptTime=<%= selTime %>&barberId=<%= selBarberId %>"
                     style="font-size:.82rem;color:#888;text-decoration:underline;">
                    &larr; Change payment method
                  </a>
                </div>
              </div>
            </div>

          <%-- FonePay Payment Portal --%>
          <% } else if ("fonepay".equals(selPayment)) { %>
            <div style="max-width:380px;margin:0 auto 24px;">
              <!-- Phone mockup wrapper -->
              <div style="background:#f0f2f5;border-radius:16px;padding:28px 24px;
                          border:1px solid #E0E0E0;box-shadow:0 4px 20px rgba(0,0,0,.1);">

                <!-- FonePay Logo -->
                <div style="text-align:center;margin-bottom:32px;">
                  <div style="display:inline-flex;align-items:center;gap:0;">
                    <div style="background:#E31E24;border-radius:6px 0 0 6px;
                                padding:6px 10px;display:inline-block;">
                      <span style="font-size:1rem;font-weight:900;color:#fff;letter-spacing:-.02em;">fone</span>
                    </div>
                    <div style="background:#fff;border:2px solid #E31E24;border-left:none;
                                border-radius:0 6px 6px 0;padding:6px 10px;display:inline-block;">
                      <span style="font-size:1rem;font-weight:700;color:#222;">pay</span>
                    </div>
                    <span style="font-size:.9rem;font-weight:500;color:#444;margin-left:8px;">Merchant</span>
                  </div>
                  <p style="font-size:.78rem;color:#888;margin-top:10px;">
                    Amount: <strong style="color:#E31E24;"><%= selServicePrice %></strong>
                  </p>
                </div>

                <form action="${pageContext.request.contextPath}/appointment" method="post">
                  <input type="hidden" name="action"        value="book">
                  <input type="hidden" name="serviceId"     value="<%= selServiceId %>">
                  <input type="hidden" name="apptDate"      value="<%= selDate %>">
                  <input type="hidden" name="apptTime"      value="<%= selTime %>">
                  <input type="hidden" name="barberId"      value="<%= selBarberId %>">
                  <input type="hidden" name="paymentMethod" value="fonepay">
                  <input type="hidden" name="notes"         value="<%= notes != null ? notes : "" %>">

                  <!-- Mobile Number field -->
                  <div style="background:#fff;border-radius:8px;border:1px solid #E0E0E0;
                              display:flex;align-items:center;gap:10px;
                              padding:12px 14px;margin-bottom:14px;">
                    <span style="font-size:1rem;color:#aaa;">&#128222;</span>
                    <div style="flex:1;">
                      <div style="font-size:.7rem;color:#aaa;margin-bottom:2px;">Mobile number</div>
                      <input type="tel" name="fonepayPhone"
                             placeholder="98XXXXXXXX" maxlength="10" required
                             style="border:none;outline:none;width:100%;font-size:.95rem;
                                    color:#222;background:transparent;font-family:'DM Sans',sans-serif;">
                    </div>
                  </div>

                  <!-- Password field -->
                  <div style="background:#fff;border-radius:8px;border:1px solid #E0E0E0;
                              display:flex;align-items:center;gap:10px;
                              padding:12px 14px;margin-bottom:24px;">
                    <span style="font-size:1rem;color:#aaa;">&#128274;</span>
                    <div style="flex:1;">
                      <div style="font-size:.7rem;color:#aaa;margin-bottom:2px;">Password</div>
                      <input type="password" name="fonepayPin"
                             placeholder="••••••••" maxlength="20" required
                             style="border:none;outline:none;width:100%;font-size:.95rem;
                                    color:#222;background:transparent;font-family:'DM Sans',sans-serif;
                                    letter-spacing:.15em;">
                    </div>
                  </div>

                  <!-- Login button -->
                  <button type="submit"
                          style="width:100%;padding:14px;background:#E31E24;color:#fff;
                                 border:none;border-radius:8px;font-size:1rem;font-weight:700;
                                 cursor:pointer;letter-spacing:.04em;margin-bottom:16px;">
                    Login
                  </button>
                </form>

                <!-- Secondary options -->
                <div style="text-align:center;">
                  <div style="display:flex;align-items:center;justify-content:center;
                              gap:8px;color:#555;font-size:.83rem;margin-bottom:12px;">
                    <span style="font-size:1rem;">&#128400;</span> Login with biometrics
                  </div>
                  <p style="font-size:.82rem;color:#888;margin-bottom:12px;">Forgot password?</p>
                  <p style="font-size:.82rem;color:#888;margin-bottom:12px;">Don't have an account yet?</p>
                  <div style="border:1.5px solid #E31E24;border-radius:8px;padding:10px;">
                    <span style="color:#E31E24;font-size:.88rem;font-weight:600;">Register</span>
                  </div>
                </div>

                <div style="margin-top:20px;text-align:center;">
                  <a href="?step=4&serviceId=<%= selServiceId %>&apptDate=<%= selDate %>&apptTime=<%= selTime %>&barberId=<%= selBarberId %>"
                     style="font-size:.78rem;color:#aaa;text-decoration:underline;">
                    &larr; Change payment method
                  </a>
                </div>
              </div>
            </div>

          <%-- Cash — simple confirm --%>
          <% } else { %>
            <div style="background:#FEF3E2;border:1px solid #F5C97A;border-radius:var(--radius);
                        padding:14px 18px;margin-bottom:20px;display:flex;align-items:center;gap:12px;">
              <span style="font-size:1.2rem;">&#128181;</span>
              <div>
                <strong style="color:#7B4F00;font-size:.9rem;">Paying Cash After Haircut</strong>
                <p style="color:#D4860A;font-size:.8rem;margin:0;">No advance required — pay when service is done.</p>
              </div>
            </div>

            <form action="${pageContext.request.contextPath}/appointment" method="post">
              <input type="hidden" name="action"        value="book">
              <input type="hidden" name="serviceId"     value="<%= selServiceId %>">
              <input type="hidden" name="apptDate"      value="<%= selDate %>">
              <input type="hidden" name="apptTime"      value="<%= selTime %>">
              <input type="hidden" name="barberId"      value="<%= selBarberId %>">
              <input type="hidden" name="paymentMethod" value="cash">

              <div class="form-group">
                <label>Additional Notes <span style="font-weight:400;text-transform:none;">(optional)</span></label>
                <textarea name="notes" class="form-control" rows="3"
                          placeholder="Any special requests for your barber..."><%= notes != null ? notes : "" %></textarea>
              </div>
              <button type="submit" class="btn btn-primary btn-full">&#10003; Confirm Booking</button>
            </form>

            <div style="margin-top:12px;">
              <a href="?step=4&serviceId=<%= selServiceId %>&apptDate=<%= selDate %>&apptTime=<%= selTime %>&barberId=<%= selBarberId %>"
                 class="btn btn-outline btn-sm">&larr; Back</a>
            </div>
          <% } %>
        </div>
      <% } %>

      </div>

      <!-- RIGHT: Summary -->
      <div>
        <div class="summary-card">
          <h3>Booking Summary</h3>
          <div class="summary-row">
            <span class="label">Service</span>
            <span class="value"><%= selServiceName %></span>
          </div>
          <div class="summary-row">
            <span class="label">Price</span>
            <span class="value"><%= selServicePrice %></span>
          </div>
          <hr style="border-color:#2A2A2A;">
          <div class="summary-row">
            <span class="label">Date</span>
            <span class="value"><%= selDate != null && !selDate.isEmpty() ? selDate : "—" %></span>
          </div>
          <div class="summary-row">
            <span class="label">Time</span>
            <span class="value"><%= selTime != null && !selTime.isEmpty() ? selTime : "—" %></span>
          </div>
          <hr style="border-color:#2A2A2A;">
          <div class="summary-row">
            <span class="label">Barber</span>
            <span class="value"><%= selBarberName %></span>
          </div>
          <% if (!selPayment.isEmpty()) { %>
          <hr style="border-color:#2A2A2A;">
          <div class="summary-row">
            <span class="label">Payment</span>
            <span class="value">
              <% if ("esewa".equals(selPayment)) { %>&#128994; eSewa
              <% } else if ("fonepay".equals(selPayment)) { %>&#128998; FonePay
              <% } else { %>&#128181; Cash after haircut
              <% } %>
            </span>
          </div>
          <% } %>
        </div>
      </div>
    </div>
  </main>

<!-- -- MOBILE BOTTOM NAV -- -->
</div>
</body>
</html>

