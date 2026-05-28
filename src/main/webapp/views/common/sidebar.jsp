<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="sidebar-glass d-none d-md-flex">
    <div class="sidebar-header d-flex align-items-center gap-2">
        <i class="bi bi-grid-fill text-primary" style="font-size: 1.4rem;"></i>
        <c:choose>
            <c:when test="${not empty sessionScope.currentAdmin}">
                <h5 class="mb-0 fw-bold text-white">Admin Hub</h5>
            </c:when>
            <c:otherwise>
                <h5 class="mb-0 fw-bold">Student Center</h5>
            </c:otherwise>
        </c:choose>
    </div>
    
    <ul class="sidebar-menu">
        <c:choose>
            <c:when test="${not empty sessionScope.currentAdmin}">
                <!-- Admin Sidebar Options -->
                <li class="sidebar-item ${param.active == 'dashboard' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp">
                        <i class="bi bi-speedometer2"></i>Dashboard
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'events' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/admin/events.jsp">
                        <i class="bi bi-calendar-event"></i>Event Manager
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'registrations' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/admin/registrations.jsp">
                        <i class="bi bi-people"></i>Registrations
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'students' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/admin/students.jsp">
                        <i class="bi bi-mortarboard"></i>Manage Students
                    </a>
                </li>
            </c:when>
            
            <c:otherwise>
                <!-- Student Sidebar Options -->
                <li class="sidebar-item ${param.active == 'dashboard' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/student/dashboard.jsp">
                        <i class="bi bi-speedometer2"></i>My Dashboard
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'explore' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/student/events.jsp">
                        <i class="bi bi-search"></i>Explore Events
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'registrations' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/student/registered-events.jsp">
                        <i class="bi bi-check2-circle"></i>My Registrations
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'profile' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/student/profile.jsp">
                        <i class="bi bi-person-fill-gear"></i>Account Profile
                    </a>
                </li>
                <li class="sidebar-item ${param.active == 'notifications' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/views/student/notifications.jsp">
                        <i class="bi bi-bell-fill"></i>Notifications
                    </a>
                </li>
            </c:otherwise>
        </c:choose>
    </ul>
    
    <div class="p-3 border-top border-secondary border-opacity-10 mt-auto">
        <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-outline-danger w-100 py-2 d-flex align-items-center justify-content-center gap-2" style="border-radius: 10px;">
            <i class="bi bi-box-arrow-right"></i>
            <span>Log Out</span>
        </a>
    </div>
</div>
