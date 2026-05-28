<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.model.Event" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    EventDAO eventDAO = new EventDAO();
    
    // Filters
    String search = request.getParameter("search");
    String category = request.getParameter("category");
    if (category == null) category = "all";
    if (search == null) search = "";

    // Optimized Pagination Parameters
    int currentPage = 1;
    String pageStr = request.getParameter("page");
    if (pageStr != null && !pageStr.trim().isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageStr.trim());
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }

    int pageSize = 6;
    int offset = (currentPage - 1) * pageSize;

    List<Event> list = eventDAO.searchAndFilterEvents(search, category, pageSize, offset);
    int totalEvents = eventDAO.getTotalEventsCount(search, category);
    int totalPages = (int) Math.ceil((double) totalEvents / pageSize);
    if (totalPages < 1) totalPages = 1;

    request.setAttribute("events", list);
    request.setAttribute("currentSearch", search);
    request.setAttribute("currentCategory", category);
    request.setAttribute("currentPage", currentPage);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalEvents", totalEvents);

    SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
    request.setAttribute("timeFormatter", timeFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="explore" />
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

            <!-- Search Filters -->
            <div class="card card-glass p-4 mb-4 border">
                <h5 class="fw-bold mb-3"><i class="bi bi-funnel-fill text-primary me-2"></i>Filter Event Catalog</h5>
                <form action="${pageContext.request.contextPath}/views/student/events.jsp" method="GET" class="row g-3">
                    <div class="col-md-5">
                        <label class="form-label fw-semibold">Keywords Search</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-10 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control form-control-glass border-start-0 ps-0" placeholder="Search by title, details..." value="<c:out value="${currentSearch}"/>">
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Event Category</label>
                        <select name="category" class="form-select form-control-glass">
                            <option value="all" ${currentCategory == 'all' ? 'selected' : ''}>All Categories</option>
                            <option value="Technical" ${currentCategory == 'Technical' ? 'selected' : ''}>Technical Events</option>
                            <option value="Cultural" ${currentCategory == 'Cultural' ? 'selected' : ''}>Cultural Festivals</option>
                            <option value="Workshop" ${currentCategory == 'Workshop' ? 'selected' : ''}>Hands-on Workshops</option>
                            <option value="Seminar" ${currentCategory == 'Seminar' ? 'selected' : ''}>Educational Seminars</option>
                            <option value="Hackathon" ${currentCategory == 'Hackathon' ? 'selected' : ''}>Code Hackathons</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary flex-grow-1 py-2.5" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                            Apply Filters
                        </button>
                        <a href="${pageContext.request.contextPath}/views/student/events.jsp" class="btn btn-outline-secondary py-2.5" style="border-radius: 10px;" title="Reset filters">
                            <i class="bi bi-arrow-counterclockwise"></i>
                        </a>
                    </div>
                </form>
            </div>

            <!-- Events Grid -->
            <c:choose>
                <c:when test="${empty events}">
                    <div class="card card-glass text-center p-5 border">
                        <i class="bi bi-calendar-x text-muted" style="font-size: 3rem;"></i>
                        <h4 class="fw-bold mt-3">No matching events found</h4>
                        <p class="text-muted mb-0">Try adjusting your filters or searching with a different term.</p>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <div class="row g-4 mb-4">
                        <c:forEach var="evt" items="${events}">
                            <div class="col-lg-4 col-md-6">
                                <div class="card card-glass h-100 overflow-hidden">
                                    <div class="event-poster-container">
                                        <img src="${evt.posterUrl}" class="event-poster" alt="${evt.title}">
                                        
                                        <c:choose>
                                            <c:when test="${evt.category == 'Hackathon'}">
                                                <span class="category-badge bg-danger text-white">${evt.category}</span>
                                            </c:when>
                                            <c:when test="${evt.category == 'Technical'}">
                                                <span class="category-badge bg-primary text-white">${evt.category}</span>
                                            </c:when>
                                            <c:when test="${evt.category == 'Workshop'}">
                                                <span class="category-badge bg-success text-white">${evt.category}</span>
                                            </c:when>
                                            <c:when test="${evt.category == 'Seminar'}">
                                                <span class="category-badge bg-info text-dark">${evt.category}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="category-badge bg-warning text-dark">${evt.category}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <div class="card-body p-4 d-flex flex-column">
                                        <h5 class="card-title fw-bold mb-2"><c:out value="${evt.title}"/></h5>
                                        <p class="card-text text-muted mb-3 flex-grow-1" style="font-size: 0.9rem; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">
                                            <c:out value="${evt.description}"/>
                                        </p>
                                        
                                        <div class="border-top border-secondary border-opacity-10 pt-3 mt-auto">
                                            <div class="row g-2 mb-3 text-muted" style="font-size: 0.85rem;">
                                                <div class="col-12">
                                                    <i class="bi bi-calendar3 text-primary me-2"></i>
                                                    <%= dateFormat.format(((Event)pageContext.getAttribute("evt")).getEventDate()) %>
                                                </div>
                                                <div class="col-12 mt-1">
                                                    <i class="bi bi-clock-fill text-info me-2"></i>
                                                    <%= timeFormat.format(((Event)pageContext.getAttribute("evt")).getEventDate()) %>
                                                </div>
                                                <div class="col-12 mt-1">
                                                    <i class="bi bi-geo-alt-fill text-danger me-2"></i>
                                                    <c:out value="${evt.venue}"/>
                                                </div>
                                                <div class="col-12 mt-2">
                                                    <span class="badge bg-secondary-subtle text-secondary py-1.5 px-3" style="border-radius: 30px; font-size: 0.75rem;">
                                                        <i class="bi bi-people-fill me-1"></i>
                                                        <c:out value="${evt.availableSeats}"/> / <c:out value="${evt.seatLimit}"/> Available Seats
                                                    </span>
                                                </div>
                                            </div>
                                            
                                            <form action="${pageContext.request.contextPath}/student/event/register" method="POST">
                                                <input type="hidden" name="eventId" value="${evt.id}">
                                                <c:choose>
                                                    <c:when test="${evt.availableSeats <= 0}">
                                                        <button type="button" class="btn btn-secondary w-100 disabled py-2" style="border-radius: 10px;">Event Full</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="submit" class="btn btn-primary w-100 py-2 d-flex align-items-center justify-content-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                                                            <i class="bi bi-pencil-square"></i>Register Event
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Optimized Pagination Navigation -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Events catalog page navigation" class="mt-4">
                            <ul class="pagination justify-content-center">
                                
                                <!-- Previous Button -->
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/views/student/events.jsp?page=${currentPage - 1}&search=<c:out value="${currentSearch}"/>&category=<c:out value="${currentCategory}"/>" aria-label="Previous">
                                        <span aria-hidden="true">&laquo; Prev</span>
                                    </a>
                                </li>
                                
                                <!-- Page numbers -->
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/views/student/events.jsp?page=${i}&search=<c:out value="${currentSearch}"/>&category=<c:out value="${currentCategory}"/>">${i}</a>
                                    </li>
                                </c:forEach>
                                
                                <!-- Next Button -->
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/views/student/events.jsp?page=${currentPage + 1}&search=<c:out value="${currentSearch}"/>&category=<c:out value="${currentCategory}"/>" aria-label="Next">
                                        <span aria-hidden="true">Next &raquo;</span>
                                    </a>
                                </li>
                                
                            </ul>
                        </nav>
                    </c:if>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
