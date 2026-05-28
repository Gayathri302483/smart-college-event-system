<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.model.Event" %>
<%@ page import="com.collegeevent.dao.StudentDAO" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<%
    // Instantiate DAOs to dynamically pull database information
    EventDAO eventDAO = new EventDAO();
    StudentDAO studentDAO = new StudentDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();
    
    // Retrieve Search/Filter Parameters
    String search = request.getParameter("search");
    String category = request.getParameter("category");
    
    if (category == null) category = "all";
    if (search == null) search = "";

    // Paginate events or filter
    List<Event> events = eventDAO.searchAndFilterEvents(search, category, 6, 0);
    request.setAttribute("eventsList", events);
    request.setAttribute("currentSearch", search);
    request.setAttribute("currentCategory", category);

    // Fetch dynamic dashboard counter statistics
    int totalEventsCount = eventDAO.getTotalEventsCount("", "all");
    int totalStudentsCount = studentDAO.getAllStudents().size();
    int totalRegCount = registrationDAO.getAllRegistrations().size();
    
    request.setAttribute("statEvents", totalEventsCount);
    request.setAttribute("statStudents", totalStudentsCount);
    request.setAttribute("statRegs", totalRegCount);
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
%>

<!-- Hero Header Section -->
<header class="hero-section text-center">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 mb-3 fw-bold uppercase" style="border-radius: 30px;">
                    🎓 College Event Hub
                </span>
                <h1 class="display-4 fw-extrabold mb-3" style="font-weight: 800; letter-spacing: -1px;">
                    Discover & Register for <br>
                    <span class="text-primary" style="background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Amazing Campus Events</span>
                </h1>
                <p class="lead text-muted mb-4">
                    Welcome to the Smart College Event Management System. Explore hackathons, seminars, workshops, and cultural fests. Stay notified and claim your verification certificates!
                </p>
                
                <!-- Quick Search form -->
                <form action="${pageContext.request.contextPath}/index.jsp" method="GET" class="card-glass p-2 d-flex flex-column flex-sm-row gap-2 border w-100" style="border-radius: 40px !important;">
                    <div class="input-group border-0 flex-grow-1">
                        <span class="input-group-text bg-transparent border-0 text-muted"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control bg-transparent border-0 ps-0 text-main" placeholder="Search events by title, keywords..." value="<c:out value="${currentSearch}"/>">
                    </div>
                    
                    <select name="category" class="form-select bg-transparent border-0 text-muted" style="max-width: 180px; box-shadow: none;">
                        <option value="all" ${currentCategory == 'all' ? 'selected' : ''}>All Categories</option>
                        <option value="Technical" ${currentCategory == 'Technical' ? 'selected' : ''}>Technical</option>
                        <option value="Cultural" ${currentCategory == 'Cultural' ? 'selected' : ''}>Cultural</option>
                        <option value="Workshop" ${currentCategory == 'Workshop' ? 'selected' : ''}>Workshop</option>
                        <option value="Seminar" ${currentCategory == 'Seminar' ? 'selected' : ''}>Seminar</option>
                        <option value="Hackathon" ${currentCategory == 'Hackathon' ? 'selected' : ''}>Hackathon</option>
                    </select>
                    
                    <button type="submit" class="btn btn-primary px-4 py-2 border-0" style="border-radius: 30px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); font-weight: 600;">
                        Search Events
                    </button>
                </form>
            </div>
        </div>
    </div>
</header>

<!-- Counter Statistics Cards -->
<section class="py-5" style="margin-top: -30px;">
    <div class="container">
        <div class="row g-4">
            <div class="col-md-4">
                <div class="stat-widget">
                    <div class="stat-icon bg-primary-subtle text-primary">
                        <i class="bi bi-calendar-event-fill"></i>
                    </div>
                    <div>
                        <h3 class="mb-0 fw-bold"><c:out value="${statEvents}"/></h3>
                        <span class="text-muted" style="font-size: 0.9rem;">Total Active Events</span>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="stat-widget">
                    <div class="stat-icon bg-success-subtle text-success">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div>
                        <h3 class="mb-0 fw-bold"><c:out value="${statStudents}"/></h3>
                        <span class="text-muted" style="font-size: 0.9rem;">Enrolled Students</span>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="stat-widget">
                    <div class="stat-icon bg-info-subtle text-info">
                        <i class="bi bi-ticket-detailed-fill"></i>
                    </div>
                    <div>
                        <h3 class="mb-0 fw-bold"><c:out value="${statRegs}"/></h3>
                        <span class="text-muted" style="font-size: 0.9rem;">Total Registrations</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Event Catalog Section -->
<section class="py-4">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h3 class="fw-bold mb-1">Explore Campus Calendar</h3>
                <p class="text-muted mb-0">Browse events, register, and learn new skills.</p>
            </div>
            
            <!-- Category Pills Quick Filter -->
            <div class="d-flex gap-2 flex-wrap">
                <a href="${pageContext.request.contextPath}/index.jsp?category=all&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'all' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">All</a>
                <a href="${pageContext.request.contextPath}/index.jsp?category=Technical&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'Technical' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">Technical</a>
                <a href="${pageContext.request.contextPath}/index.jsp?category=Cultural&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'Cultural' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">Cultural</a>
                <a href="${pageContext.request.contextPath}/index.jsp?category=Workshop&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'Workshop' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">Workshops</a>
                <a href="${pageContext.request.contextPath}/index.jsp?category=Seminar&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'Seminar' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">Seminars</a>
                <a href="${pageContext.request.contextPath}/index.jsp?category=Hackathon&search=<c:out value="${currentSearch}"/>" class="btn btn-sm ${currentCategory == 'Hackathon' ? 'btn-primary' : 'btn-outline-secondary'} rounded-pill px-3">Hackathons</a>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty eventsList}">
                <div class="card-glass text-center p-5 border">
                    <i class="bi bi-calendar-x text-muted" style="font-size: 3rem;"></i>
                    <h4 class="fw-bold mt-3">No Events Found</h4>
                    <p class="text-muted">We couldn't find any events matching your search criteria. Try a different keyword or category filter!</p>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary rounded-pill px-4 mt-2">Clear Filters</a>
                </div>
            </c:when>
            
            <c:otherwise>
                <div class="row g-4">
                    <c:forEach var="event" items="${eventsList}">
                        <div class="col-lg-4 col-md-6">
                            <div class="card card-glass h-100 overflow-hidden">
                                <!-- Poster Container -->
                                <div class="event-poster-container">
                                    <img src="${event.posterUrl}" class="event-poster" alt="${event.title}">
                                    
                                    <!-- Dynamic Badge Color based on category -->
                                    <c:choose>
                                        <c:when test="${event.category == 'Hackathon'}">
                                            <span class="category-badge bg-danger text-white">${event.category}</span>
                                        </c:when>
                                        <c:when test="${event.category == 'Technical'}">
                                            <span class="category-badge bg-primary text-white">${event.category}</span>
                                        </c:when>
                                        <c:when test="${event.category == 'Workshop'}">
                                            <span class="category-badge bg-success text-white">${event.category}</span>
                                        </c:when>
                                        <c:when test="${event.category == 'Seminar'}">
                                            <span class="category-badge bg-info text-dark">${event.category}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="category-badge bg-warning text-dark">${event.category}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <div class="card-body p-4 d-flex flex-column">
                                    <h5 class="card-title fw-bold mb-2"><c:out value="${event.title}"/></h5>
                                    
                                    <p class="card-text text-muted mb-3 flex-grow-1" style="font-size: 0.9rem; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.5;">
                                        <c:out value="${event.description}"/>
                                    </p>
                                    
                                    <div class="border-top border-secondary border-opacity-10 pt-3 mt-auto">
                                        <div class="row g-2 mb-3" style="font-size: 0.85rem;">
                                            <div class="col-6 text-muted">
                                                <i class="bi bi-calendar3 text-primary me-2"></i>
                                                <%= dateFormat.format(((Event)pageContext.getAttribute("event")).getEventDate()) %>
                                            </div>
                                            <div class="col-6 text-muted">
                                                <i class="bi bi-geo-alt-fill text-danger me-2"></i>
                                                <c:out value="${event.venue}"/>
                                            </div>
                                            <div class="col-12 mt-2">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <span class="badge bg-secondary-subtle text-secondary py-2 px-3" style="border-radius: 30px;">
                                                        <i class="bi bi-people-fill me-1"></i>
                                                        <c:out value="${event.availableSeats}"/> / <c:out value="${event.seatLimit}"/> Seats Left
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.currentStudent}">
                                                <!-- Logged student form registration -->
                                                <form action="${pageContext.request.contextPath}/student/event/register" method="POST">
                                                    <input type="hidden" name="eventId" value="${event.id}">
                                                    <c:choose>
                                                        <c:when test="${event.availableSeats <= 0}">
                                                            <button type="button" class="btn btn-secondary w-100 disabled py-2" style="border-radius: 12px;">Fully Booked</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="submit" class="btn btn-primary w-100 py-2 d-flex align-items-center justify-content-center gap-2" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                                                                <i class="bi bi-pencil-square"></i>Register Now
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <!-- Guest redirect to login -->
                                                <a href="${pageContext.request.contextPath}/views/auth/login.jsp" class="btn btn-outline-primary w-100 py-2 d-flex align-items-center justify-content-center gap-2" style="border-radius: 12px;">
                                                    <i class="bi bi-box-arrow-in-right"></i>Login to Register
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/views/common/footer.jsp" />
