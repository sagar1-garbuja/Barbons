<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
  return;
%>
