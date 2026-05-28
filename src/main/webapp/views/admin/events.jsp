<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Admin" %>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.model.Event" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        return;
    }

    EventDAO eventDAO = new EventDAO();
    List<Event> list = eventDAO.getAllEvents();
    request.setAttribute("events", list);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="events" />
    </jsp:include>

    <!-- Main Content -->
    <div class="flex-grow-1 p-4" style="background-color: var(--bg-base);">
        <div class="container-fluid">
            
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <c:out value="${sessionScope.errorMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <c:out value="${sessionScope.successMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>

            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="fw-bold mb-1">Manage Events Catalog</h2>
                    <p class="text-muted mb-0">Add new upcoming schedules, modify details or remove concluded events from active display.</p>
                </div>
                
                <a href="${pageContext.request.contextPath}/views/admin/event-form.jsp" class="btn btn-primary px-3 py-2 d-flex align-items-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                    <i class="bi bi-plus-circle-fill"></i>Create New Event
                </a>
            </div>

            <!-- Events Table Card -->
            <div class="card card-glass p-4 border">
                <c:choose>
                    <c:when test="${empty events}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-calendar2-x-fill" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">No active events in catalog</h4>
                            <p class="text-muted mb-0">Get started by creating the first campus event schedule!</p>
                            <a href="${pageContext.request.contextPath}/views/admin/event-form.jsp" class="btn btn-primary rounded-pill px-4 mt-3">Create Event</a>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Poster</th>
                                        <th>Title & Category</th>
                                        <th>Schedule Date</th>
                                        <th>Venue</th>
                                        <th>Seats Capacity</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="evt" items="${events}">
                                        <tr>
                                            <td style="width: 80px;">
                                                <div style="width: 60px; height: 45px; overflow: hidden; border-radius: 6px;" class="border">
                                                    <img src="${evt.posterUrl}" class="w-100 h-100" style="object-fit: cover;">
                                                </div>
                                            </td>
                                            
                                            <td>
                                                <span class="fw-bold text-main"><c:out value="${evt.title}"/></span>
                                                <br><span class="badge bg-secondary-subtle text-secondary py-1" style="font-size: 0.68rem; border-radius: 30px;"><c:out value="${evt.category}"/></span>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <%= dateFormat.format(((Event)pageContext.getAttribute("evt")).getEventDate()) %>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <i class="bi bi-geo-alt-fill text-danger me-1"></i><c:out value="${evt.venue}"/>
                                            </td>
                                            
                                            <td>
                                                <span class="fw-semibold text-main"><c:out value="${evt.availableSeats}"/></span>
                                                <span class="text-muted"> / <c:out value="${evt.seatLimit}"/></span>
                                            </td>
                                            
                                            <td class="text-end">
                                                <div class="d-inline-flex gap-2">
                                                    <!-- Edit Button -->
                                                    <a href="${pageContext.request.contextPath}/views/admin/event-form.jsp?id=${evt.id}" class="btn btn-sm btn-outline-primary d-flex align-items-center justify-content-center" style="width: 35px; height: 35px; border-radius: 8px;" title="Edit Event Details">
                                                        <i class="bi bi-pencil-square"></i>
                                                    </a>
                                                    
                                                    <!-- Delete Button -->
                                                    <a href="${pageContext.request.contextPath}/admin/event/delete?id=${evt.id}" onclick="return confirm('Warning! Are you sure you want to permanently delete this event? All student registrations for this event will be deleted as well.')" class="btn btn-sm btn-outline-danger d-flex align-items-center justify-content-center" style="width: 35px; height: 35px; border-radius: 8px;" title="Delete Event">
                                                        <i class="bi bi-trash3-fill"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
