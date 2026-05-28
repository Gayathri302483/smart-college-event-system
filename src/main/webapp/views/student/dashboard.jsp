<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="com.collegeevent.model.Registration" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.model.Event" %>
<%@ page import="com.collegeevent.dao.NotificationDAO" %>
<%@ page import="com.collegeevent.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    RegistrationDAO registrationDAO = new RegistrationDAO();
    EventDAO eventDAO = new EventDAO();
    NotificationDAO notificationDAO = new NotificationDAO();

    List<Registration> studentRegs = registrationDAO.getRegistrationsByStudent(currentStudent.getId());
    List<Event> upcomingEvents = eventDAO.getUpcomingEvents(3);
    List<Notification> unreadNotifs = notificationDAO.getNotificationsForStudent(currentStudent.getId());

    // Calculate aggregate metrics
    int totalRegs = studentRegs.size();
    int pendingRegs = 0;
    int approvedRegs = 0;
    int certificatesUnlocked = 0;

    for (Registration reg : studentRegs) {
        if (reg.getStatus().equalsIgnoreCase("PENDING")) {
            pendingRegs++;
        } else if (reg.getStatus().equalsIgnoreCase("APPROVED")) {
            approvedRegs++;
            if (reg.getAttendance().equalsIgnoreCase("PRESENT")) {
                certificatesUnlocked++;
            }
        }
    }

    request.setAttribute("totalRegs", totalRegs);
    request.setAttribute("pendingRegs", pendingRegs);
    request.setAttribute("approvedRegs", approvedRegs);
    request.setAttribute("certificatesUnlocked", certificatesUnlocked);
    request.setAttribute("studentRegs", studentRegs);
    request.setAttribute("upcomingEvents", upcomingEvents);
    
    // Filter unread notifications limit to 3 for quick previews
    int unreadCount = 0;
    for (Notification n : unreadNotifs) {
        if (!n.isRead()) unreadCount++;
    }
    request.setAttribute("unreadCount", unreadCount);
    request.setAttribute("previewNotifications", unreadNotifs.subList(0, Math.min(unreadNotifs.size(), 3)));

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <!-- Include Sidebar Navigation -->
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="dashboard" />
    </jsp:include>

    <!-- Main Content Area -->
    <div class="flex-grow-1 p-4" style="background-color: var(--bg-base);">
        <div class="container-fluid">
            
            <!-- Welcome Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="fw-bold mb-1">Hello, <c:out value="${sessionScope.currentStudent.fullName}"/>!</h2>
                    <p class="text-muted mb-0"><c:out value="${sessionScope.currentStudent.rollNumber}"/> &bull; <c:out value="${sessionScope.currentStudent.department}"/> Department</p>
                </div>
                
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/views/student/events.jsp" class="btn btn-primary px-3 py-2 d-flex align-items-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                        <i class="bi bi-calendar-event"></i>Explore Calendar
                    </a>
                </div>
            </div>

            <!-- Stats Counters -->
            <div class="row g-4 mb-4">
                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-primary-subtle text-primary">
                            <i class="bi bi-ticket-detailed-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${totalRegs}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Registrations</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-warning-subtle text-warning">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${pendingRegs}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Pending Approval</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-success-subtle text-success">
                            <i class="bi bi-check-circle-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${approvedRegs}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Approved Entries</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-info-subtle text-info">
                            <i class="bi bi-award-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${certificatesUnlocked}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Certificates Earned</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Dashboard Layout split -->
            <div class="row g-4">
                
                <!-- Registered Events Summary -->
                <div class="col-lg-8">
                    <div class="card card-glass p-4 h-100 border">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0">My Recent Registrations</h5>
                            <a href="${pageContext.request.contextPath}/views/student/registered-events.jsp" class="text-decoration-none text-primary fw-semibold" style="font-size: 0.9rem;">View All</a>
                        </div>

                        <c:choose>
                            <c:when test="${empty studentRegs}">
                                <div class="text-center py-5 text-muted">
                                    <i class="bi bi-journal-x" style="font-size: 2.5rem;"></i>
                                    <p class="mt-3 mb-2">No registrations found.</p>
                                    <a href="${pageContext.request.contextPath}/views/student/events.jsp" class="btn btn-sm btn-outline-primary rounded-pill px-3">Browse Events</a>
                                </div>
                            </c:when>
                            
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle">
                                        <thead>
                                            <tr>
                                                <th>Event Title</th>
                                                <th>Event Date</th>
                                                <th>Status</th>
                                                <th class="text-end">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="reg" items="${studentRegs}" varStatus="loop">
                                                <c:if test="${loop.index < 4}">
                                                    <tr>
                                                        <td>
                                                            <span class="fw-bold"><c:out value="${reg.eventTitle}"/></span>
                                                            <br><span class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-geo-alt"></i> <c:out value="${reg.eventVenue}"/></span>
                                                        </td>
                                                        <td>
                                                            <%= dateFormat.format(((Registration)pageContext.getAttribute("reg")).getEventDate()) %>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${reg.status == 'APPROVED'}">
                                                                    <span class="badge bg-success-subtle text-success py-1.5 px-3" style="border-radius: 30px;">Approved</span>
                                                                </c:when>
                                                                <c:when test="${reg.status == 'PENDING'}">
                                                                    <span class="badge bg-warning-subtle text-warning py-1.5 px-3" style="border-radius: 30px;">Pending</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-danger-subtle text-danger py-1.5 px-3" style="border-radius: 30px;">Rejected</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/views/student/receipt.jsp?id=${reg.id}" class="btn btn-sm btn-outline-secondary" title="View Ticket/Receipt" style="border-radius: 8px;">
                                                                <i class="bi bi-qr-code"></i>
                                                            </a>
                                                            <c:if test="${reg.status == 'APPROVED' && reg.attendance == 'PRESENT'}">
                                                                <a href="${pageContext.request.contextPath}/views/student/certificate.jsp?id=${reg.id}" class="btn btn-sm btn-success" title="Download Certificate" style="border-radius: 8px;">
                                                                    <i class="bi bi-award-fill"></i>
                                                                </a>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Notifications & Upcoming list -->
                <div class="col-lg-4">
                    <div class="d-flex flex-column gap-4">
                        
                        <!-- Notifications widget -->
                        <div class="card card-glass p-4 border">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="d-flex align-items-center gap-2">
                                    <h5 class="fw-bold mb-0">Notifications</h5>
                                    <c:if test="${unreadCount > 0}">
                                        <span class="badge bg-danger rounded-pill"><c:out value="${unreadCount}"/></span>
                                    </c:if>
                                </div>
                                <a href="${pageContext.request.contextPath}/views/student/notifications.jsp" class="text-decoration-none text-primary fw-semibold" style="font-size: 0.85rem;">All Alerts</a>
                            </div>

                            <c:choose>
                                <c:when test="${empty previewNotifications}">
                                    <div class="text-center py-4 text-muted">
                                        <i class="bi bi-bell-slash" style="font-size: 1.8rem;"></i>
                                        <p class="mt-2 mb-0" style="font-size: 0.85rem;">No new notifications.</p>
                                    </div>
                                </c:when>
                                
                                <c:otherwise>
                                    <div class="d-flex flex-column gap-3">
                                        <c:forEach var="notif" items="${previewNotifications}">
                                            <div class="p-2.5 rounded border border-opacity-10 d-flex flex-column gap-1" style="background: rgba(255,255,255,0.03); border-radius: 8px; border-color: var(--border-color) !important;">
                                                <p class="mb-0 text-main" style="font-size: 0.85rem; line-height: 1.4;"><c:out value="${notif.message}"/></p>
                                                <span class="text-muted" style="font-size: 0.72rem;"><i class="bi bi-clock me-1"></i><%= dateFormat.format(((Notification)pageContext.getAttribute("notif")).getCreatedAt()) %></span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Upcoming events sidebar -->
                        <div class="card card-glass p-4 border">
                            <h5 class="fw-bold mb-3">Featured Events</h5>
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="evt" items="${upcomingEvents}">
                                    <a href="${pageContext.request.contextPath}/views/student/events.jsp?search=<c:out value="${evt.title}"/>" class="text-decoration-none text-reset p-2 rounded d-flex gap-3 hover-glass border border-transparent" style="background: rgba(255,255,255,0.02); transition: all 0.2s;">
                                        <div style="width: 50px; height: 50px; overflow: hidden; border-radius: 8px;">
                                            <img src="${evt.posterUrl}" class="w-100 h-100" style="object-fit: cover;">
                                        </div>
                                        <div class="flex-grow-1 min-w-0">
                                            <h6 class="mb-1 fw-bold text-truncate" style="font-size: 0.85rem;"><c:out value="${evt.title}"/></h6>
                                            <span class="badge bg-secondary-subtle text-secondary mb-0" style="font-size: 0.65rem;"><c:out value="${evt.category}"/></span>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>

                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
