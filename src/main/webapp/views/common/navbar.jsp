<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<nav class="navbar navbar-expand-lg navbar-glass sticky-top py-3">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/index.jsp">
            <i class="bi bi-calendar2-event-fill text-primary"></i>
            <span>SmartCollege Event</span>
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link fw-semibold" href="${pageContext.request.contextPath}/index.jsp">Home</a>
                </li>
                
                <c:if test="${not empty sessionScope.currentStudent}">
                    <li class="nav-item">
                        <a class="nav-link fw-semibold" href="${pageContext.request.contextPath}/views/student/events.jsp">Explore Events</a>
                    </li>
                </c:if>
            </ul>
            
            <div class="d-flex align-items-center gap-3">
                <!-- Theme Toggle Button -->
                <button id="theme-toggle" class="btn btn-outline-secondary rounded-circle p-2 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;" title="Toggle Light/Dark Theme">
                    <i class="bi bi-moon-stars-fill"></i>
                </button>
                
                <c:choose>
                    <c:when test="${not empty sessionScope.currentStudent}">
                        <!-- Student Logged In -->
                        <div class="dropdown">
                            <a class="btn btn-glass border d-flex align-items-center gap-2 dropdown-toggle px-3 py-2" href="#" role="button" id="studentDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="border-radius: 30px; background: rgba(255,255,255,0.08);">
                                <i class="bi bi-person-circle text-primary"></i>
                                <span class="fw-semibold"><c:out value="${sessionScope.currentStudent.fullName}"/></span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border mt-2" aria-labelledby="studentDropdown" style="border-radius: 12px;">
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/student/dashboard.jsp"><i class="bi bi-speedometer2 me-2"></i>Dashboard</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/student/profile.jsp"><i class="bi bi-person-fill me-2"></i>My Profile</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/student/registered-events.jsp"><i class="bi bi-check-circle-fill me-2"></i>My Registrations</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/student/notifications.jsp"><i class="bi bi-bell-fill me-2"></i>Notifications</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                            </ul>
                        </div>
                    </c:when>
                    
                    <c:when test="${not empty sessionScope.currentAdmin}">
                        <!-- Admin Logged In -->
                        <div class="dropdown">
                            <a class="btn btn-dark d-flex align-items-center gap-2 dropdown-toggle px-3 py-2" href="#" role="button" id="adminDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="border-radius: 30px; background: #1e1b4b; border: none;">
                                <i class="bi bi-shield-lock-fill text-warning"></i>
                                <span class="fw-semibold text-white">Admin Console</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border mt-2" aria-labelledby="adminDropdown" style="border-radius: 12px;">
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/admin/dashboard.jsp"><i class="bi bi-grid-1x2-fill me-2"></i>Overview Panel</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/admin/events.jsp"><i class="bi bi-calendar-check-fill me-2"></i>Event Manager</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/admin/registrations.jsp"><i class="bi bi-people-fill me-2"></i>Registrations</a></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/views/admin/students.jsp"><i class="bi bi-mortarboard-fill me-2"></i>Manage Students</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                            </ul>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <!-- Not Logged In -->
                        <a href="${pageContext.request.contextPath}/views/auth/login.jsp" class="btn btn-outline-primary px-4 py-2" style="border-radius: 30px; font-weight: 600;">Student Portal</a>
                        <a href="${pageContext.request.contextPath}/views/auth/admin-login.jsp" class="btn btn-primary px-4 py-2" style="border-radius: 30px; font-weight: 600; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">Admin Login</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
