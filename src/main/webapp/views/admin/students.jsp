<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Admin" %>
<%@ page import="com.collegeevent.dao.StudentDAO" %>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        return;
    }

    StudentDAO studentDAO = new StudentDAO();
    List<Student> list = studentDAO.getAllStudents();
    request.setAttribute("students", list);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="students" />
    </jsp:include>

    <!-- Main Content -->
    <div class="flex-grow-1 p-4" style="background-color: var(--bg-base);">
        <div class="container-fluid">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Enrolled Students Directory</h2>
                    <p class="text-muted mb-0">Review student details, verification statuses, and historical sign-up timestamps.</p>
                </div>
            </div>

            <!-- Students List Table Card -->
            <div class="card card-glass p-4 border">
                <c:choose>
                    <c:when test="${empty students}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-people-fill" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">No students registered yet</h4>
                            <p class="text-muted mb-0">Once students enroll in the portal, their records will populate here!</p>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Attendee Name</th>
                                        <th>Roll Number</th>
                                        <th>Email Address</th>
                                        <th>Department</th>
                                        <th>Contact Phone</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="s" items="${students}">
                                        <tr>
                                            <td>
                                                <span class="fw-bold text-main"><c:out value="${s.fullName}"/></span>
                                            </td>
                                            
                                            <td class="font-monospace fw-semibold" style="font-size: 0.9rem;">
                                                <c:out value="${s.rollNumber}"/>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <c:out value="${s.email}"/>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <c:out value="${s.department}"/>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <c:out value="${not empty s.phone ? s.phone : 'N/A'}"/>
                                            </td>
                                            
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.verified}">
                                                        <span class="badge bg-success-subtle text-success py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">
                                                            <i class="bi bi-shield-check me-1"></i>Verified
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary-subtle text-secondary py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">
                                                            <i class="bi bi-shield-slash me-1"></i>Unverified
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
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
