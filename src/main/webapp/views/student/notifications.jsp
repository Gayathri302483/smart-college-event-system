<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="com.collegeevent.model.Notification" %>
<%@ page import="com.collegeevent.dao.NotificationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> list = notificationDAO.getNotificationsForStudent(currentStudent.getId());
    request.setAttribute("notifications", list);

    // Calculate unread alerts
    int unreads = 0;
    for (Notification n : list) {
        if (!n.isRead()) unreads++;
    }
    request.setAttribute("unreads", unreads);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="notifications" />
    </jsp:include>

    <!-- Main Content -->
    <div class="flex-grow-1 p-4" style="background-color: var(--bg-base);">
        <div class="container-fluid">
            
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="fw-bold mb-1">Notifications</h2>
                    <p class="text-muted mb-0">Stay updated on your registration approvals, warnings, and unlocked certificates.</p>
                </div>
                
                <c:if test="${unreads > 0}">
                    <a href="${pageContext.request.contextPath}/student/notifications/readall" class="btn btn-outline-primary py-2 px-3 d-flex align-items-center gap-2" style="border-radius: 10px; font-weight: 600;">
                        <i class="bi bi-envelope-open-fill"></i>Mark All as Read
                    </a>
                </c:if>
            </div>

            <!-- Notifications Card -->
            <div class="card card-glass p-4 border">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-bell-slash" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">All caught up!</h4>
                            <p class="text-muted mb-0">You have no event notifications in your record.</p>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="n" items="${notifications}">
                                <div class="p-3 border rounded-3 position-relative d-flex flex-column gap-1.5" style="border-color: var(--border-color) !important; background: ${n.read ? 'rgba(255,255,255,0.02)' : 'rgba(79, 70, 229, 0.04)'}; border-left: 4px solid ${n.read ? 'transparent' : 'var(--primary)'} !important; border-radius: 10px !important;">
                                    
                                    <div class="d-flex justify-content-between align-items-start">
                                        <p class="mb-0 text-main fw-semibold" style="font-size: 0.95rem; line-height: 1.5; padding-right: 20px;">
                                            <c:out value="${n.message}"/>
                                        </p>
                                        
                                        <c:if test="${not n.read}">
                                            <span class="position-absolute top-3 end-3 p-1 bg-danger border border-light rounded-circle" title="Unread Alert"></span>
                                        </c:if>
                                    </div>
                                    
                                    <div class="d-flex align-items-center text-muted" style="font-size: 0.75rem;">
                                        <i class="bi bi-clock me-1.5"></i>
                                        <span><%= dateFormat.format(((Notification)pageContext.getAttribute("n")).getCreatedAt()) %></span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
