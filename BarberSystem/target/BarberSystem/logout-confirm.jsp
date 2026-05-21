<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String role    = (String) session.getAttribute("role");
  String name    = (String) session.getAttribute("fullName");
  String pic     = (String) session.getAttribute("profilePicture");
  String backUrl = "admin".equals(role)
      ? request.getContextPath() + "/admin/dashboard.jsp"
      : request.getContextPath() + "/customer/dashboard.jsp";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Logout — BARBONS BARBER</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      /* Warm cream background matching the app */
      background: rgba(245, 240, 232, 0.92);
      backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
    }

    .modal {
      background: #0D0D0D;
      border: 1px solid #2A2A2A;
      border-radius: 20px;
      padding: 0;
      width: 90%;
      max-width: 400px;
      overflow: hidden;
      box-shadow: 0 20px 60px rgba(0,0,0,.4), 0 4px 16px rgba(0,0,0,.2);
      animation: slideUp .25s ease;
    }

    @keyframes slideUp {
      from { opacity: 0; transform: translateY(20px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* Top accent bar */
    .modal-accent {
      height: 4px;
      background: linear-gradient(90deg, #C9A84C, #B8943A);
    }

    .modal-body {
      padding: 40px 36px 36px;
      text-align: center;
    }

    /* Avatar */
    .modal-avatar {
      width: 72px; height: 72px; border-radius: 50%;
      margin: 0 auto 20px;
      border: 3px solid #2A2A2A;
      overflow: hidden;
      display: flex; align-items: center; justify-content: center;
      background: #1A1A1A; font-size: 2rem; color: #666;
    }
    .modal-avatar img {
      width: 100%; height: 100%; object-fit: cover; display: block;
    }

    .modal-name {
      font-size: .82rem; color: #C9A84C;
      font-weight: 600; letter-spacing: .06em;
      text-transform: uppercase; margin-bottom: 16px;
    }

    .modal-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.6rem; font-weight: 700;
      color: #FFFFFF; margin-bottom: 10px;
    }

    .modal-text {
      font-size: .88rem; color: #888;
      line-height: 1.6; margin-bottom: 32px;
    }

    .modal-actions {
      display: flex; gap: 12px;
    }

    .btn-logout {
      flex: 1; padding: 14px 0;
      background: #B03A2E; color: #fff;
      border: none; border-radius: 10px;
      font-family: 'DM Sans', sans-serif;
      font-size: .92rem; font-weight: 700;
      cursor: pointer; text-decoration: none;
      display: inline-flex; align-items: center;
      justify-content: center; gap: 8px;
      transition: background .2s, transform .15s;
    }
    .btn-logout:hover { background: #922E24; transform: translateY(-1px); }
    .btn-logout:active { transform: translateY(0); }

    .btn-stay {
      flex: 1; padding: 14px 0;
      background: #1A1A1A; color: #FFFFFF;
      border: 1.5px solid #333; border-radius: 10px;
      font-family: 'DM Sans', sans-serif;
      font-size: .92rem; font-weight: 600;
      cursor: pointer; text-decoration: none;
      display: inline-flex; align-items: center;
      justify-content: center; gap: 8px;
      transition: border-color .2s, background .2s;
    }
    .btn-stay:hover { border-color: #C9A84C; color: #C9A84C; background: rgba(201,168,76,.06); }

    .modal-footer {
      padding: 16px 36px;
      border-top: 1px solid #1E1E1E;
      text-align: center;
      font-size: .75rem; color: #444;
    }
  </style>
</head>
<body>
  <div class="modal">
    <div class="modal-accent"></div>
    <div class="modal-body">

      <!-- User avatar -->
      <div class="modal-avatar">
        <% if (pic != null && !pic.isEmpty()) { %>
          <img src="<%= request.getContextPath() %>/uploads/profiles/<%= pic %>" alt="Profile">
        <% } else { %>
          &#128100;
        <% } %>
      </div>

      <div class="modal-name"><%= name != null ? name : "User" %></div>

      <h2 class="modal-title">Logging Out?</h2>
      <p class="modal-text">
        You are about to sign out of your BARBONS BARBER account.<br>
        Any unsaved changes will be lost.
      </p>

      <div class="modal-actions">
        <!-- YES — calls auth?action=logout which destroys session and redirects to login -->
        <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn-logout">
          &#8594; Yes, Logout
        </a>
        <!-- NO — go back -->
        <a href="<%= backUrl %>" class="btn-stay">
          &#8592; No, Stay
        </a>
      </div>
    </div>
    <div class="modal-footer">
      BARBONS BARBER &nbsp;·&nbsp; Pokhara, Nepal
    </div>
  </div>
</body>
</html>
