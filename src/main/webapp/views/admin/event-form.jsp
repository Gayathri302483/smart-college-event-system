<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Admin" %>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.model.Event" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        return;
    }

    // Check if we are in EDIT mode
    String idStr = request.getParameter("id");
    Event event = null;
    String formattedDate = "";

    if (idStr != null && !idStr.trim().isEmpty()) {
        try {
            int eventId = Integer.parseInt(idStr.trim());
            EventDAO eventDAO = new EventDAO();
            event = eventDAO.getEventById(eventId);
            
            if (event != null) {
                // Format date to match standard HTML5 datetime-local layout: yyyy-MM-ddTHH:mm
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                formattedDate = sdf.format(event.getEventDate());
            }
        } catch (NumberFormatException e) {
            // ignore and load in create mode
        }
    }

    request.setAttribute("event", event);
    request.setAttribute("formattedDate", formattedDate);
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

            <div class="d-flex justify-content-between align-items-center mb-4">
                <a href="${pageContext.request.contextPath}/views/admin/events.jsp" class="btn btn-outline-secondary py-2 px-3 d-flex align-items-center gap-2" style="border-radius: 10px;">
                    <i class="bi bi-arrow-left"></i>Back to Manager
                </a>
            </div>

            <div class="row g-4 justify-content-center">
                <div class="col-lg-8 col-xl-7">
                    
                    <!-- Form Card -->
                    <div class="card card-glass p-4 border">
                        <div class="d-flex align-items-center gap-2.5 mb-4 border-bottom border-secondary border-opacity-10 pb-3">
                            <i class="bi bi-calendar2-plus text-primary fs-3"></i>
                            <h4 class="fw-bold mb-0">
                                <c:choose>
                                    <c:when test="${not empty event}">Edit Event Details</c:when>
                                    <c:otherwise>Schedule New Campus Event</c:otherwise>
                                </c:choose>
                            </h4>
                        </div>
                        
                        <form action="${pageContext.request.contextPath}/admin/event/${not empty event ? 'update' : 'create'}" method="POST">
                            <c:if test="${not empty event}">
                                <input type="hidden" name="eventId" value="${event.id}">
                            </c:if>
                            
                            <div class="mb-3">
                                <label for="title" class="form-label fw-semibold">Event Title</label>
                                <input type="text" id="title" name="title" class="form-control form-control-glass" placeholder="Inter-College Hackathon 2026" value="<c:out value="${event.title}"/>" required>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="category" class="form-label fw-semibold">Event Category</label>
                                    <select id="category" name="category" class="form-select form-control-glass" required>
                                        <option value="" disabled ${empty event ? 'selected' : ''}>Select Category</option>
                                        <option value="Technical" ${event.category == 'Technical' ? 'selected' : ''}>Technical Event</option>
                                        <option value="Cultural" ${event.category == 'Cultural' ? 'selected' : ''}>Cultural Festival</option>
                                        <option value="Workshop" ${event.category == 'Workshop' ? 'selected' : ''}>Workshop Session</option>
                                        <option value="Seminar" ${event.category == 'Seminar' ? 'selected' : ''}>Educational Seminar</option>
                                        <option value="Hackathon" ${event.category == 'Hackathon' ? 'selected' : ''}>Code Hackathon</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="eventDate" class="form-label fw-semibold">Event Date & Time</label>
                                    <input type="datetime-local" id="eventDate" name="eventDate" class="form-control form-control-glass" value="${formattedDate}" required>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="venue" class="form-label fw-semibold">Venue Location</label>
                                    <input type="text" id="venue" name="venue" class="form-control form-control-glass" placeholder="Main Auditorium" value="<c:out value="${event.venue}"/>" required>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="seatLimit" class="form-label fw-semibold">Maximum Seats Limit</label>
                                    <input type="number" id="seatLimit" name="seatLimit" class="form-control form-control-glass" min="5" max="1000" placeholder="100" value="${not empty event ? event.seatLimit : 100}" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="posterUrl" class="form-label fw-semibold">Event Poster URL (Optional)</label>
                                <input type="url" id="posterUrl" name="posterUrl" class="form-control form-control-glass" placeholder="https://images.unsplash.com/..." value="<c:out value="${event.posterUrl}"/>">
                                <span class="form-text text-muted" style="font-size: 0.75rem;">Provide an image link. If left blank, a beautiful high-quality fallback photo will be set automatically.</span>
                            </div>
                            
                            <div class="mb-4">
                                <label for="description" class="form-label fw-semibold">Event Description</label>
                                <textarea id="description" name="description" class="form-control form-control-glass" rows="4" placeholder="Detail the event highlights, rules, prizes, and outline prerequisites..." required><c:out value="${event.description}"/></textarea>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100 py-2.5 fw-semibold" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                                <c:choose>
                                    <c:when test="${not empty event}">Update Event Catalog</c:when>
                                    <c:otherwise>Publish Campus Event</c:otherwise>
                                </c:choose>
                            </button>
                        </form>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
