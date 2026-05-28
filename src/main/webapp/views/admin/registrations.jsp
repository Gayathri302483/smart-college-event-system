<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Admin" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
<%@ page import="com.collegeevent.model.Registration" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        return;
    }

    RegistrationDAO registrationDAO = new RegistrationDAO();
    List<Registration> list = registrationDAO.getAllRegistrations();
    request.setAttribute("registrations", list);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="registrations" />
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
                    <h2 class="fw-bold mb-1">Registration Approvals & Attendance</h2>
                    <p class="text-muted mb-0">Approve seats allocation and record event attendance to generate student certificates dynamically.</p>
                </div>
            </div>

            <!-- Registrations Review Table Card -->
            <div class="card card-glass p-4 border">
                <c:choose>
                    <c:when test="${empty registrations}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-ticket-detailed" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">No registrations submitted yet</h4>
                            <p class="text-muted mb-0">Once students enroll for events, their credentials will show up here for validation review!</p>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Student Attendee</th>
                                        <th>Target Event</th>
                                        <th>Application Date</th>
                                        <th>Status Review</th>
                                        <th>Event Attendance</th>
                                        <th class="text-end">Manage Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="reg" items="${registrations}">
                                        <tr>
                                            <td>
                                                <span class="fw-bold text-main"><c:out value="${reg.studentName}"/></span>
                                                <br><span class="text-muted" style="font-size: 0.75rem;"><c:out value="${reg.studentRoll}"/> &bull; <c:out value="${reg.studentDepartment}"/></span>
                                            </td>
                                            
                                            <td>
                                                <span class="fw-bold text-main"><c:out value="${reg.eventTitle}"/></span>
                                                <br><span class="badge bg-secondary-subtle text-secondary py-0.5" style="font-size: 0.65rem; border-radius: 20px;"><c:out value="${reg.eventCategory}"/></span>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <%= dateFormat.format(((Registration)pageContext.getAttribute("reg")).getRegistrationDate()) %>
                                            </td>
                                            
                                            <td>
                                                <c:choose>
                                                    <c:when test="${reg.status == 'APPROVED'}">
                                                        <span class="badge bg-success-subtle text-success py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Approved</span>
                                                    </c:when>
                                                    <c:when test="${reg.status == 'PENDING'}">
                                                        <span class="badge bg-warning-subtle text-warning py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Pending</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger-subtle text-danger py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Rejected</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <td>
                                                <c:choose>
                                                    <c:when test="${reg.attendance == 'PRESENT'}">
                                                        <span class="badge bg-success text-white py-1 px-2" style="border-radius: 6px; font-size: 0.72rem;"><i class="bi bi-person-check-fill me-1"></i>Present</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary-subtle text-secondary py-1 px-2" style="border-radius: 6px; font-size: 0.72rem;"><i class="bi bi-person-x-fill me-1"></i>Absent</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <td class="text-end">
                                                <div class="d-inline-flex gap-2">
                                                    <!-- Approve/Reject forms -->
                                                    <c:if test="${reg.status == 'PENDING' || reg.status == 'REJECTED'}">
                                                        <form action="${pageContext.request.contextPath}/admin/registration/status" method="POST" class="d-inline">
                                                            <input type="hidden" name="regId" value="${reg.id}">
                                                            <input type="hidden" name="status" value="APPROVED">
                                                            <button type="submit" class="btn btn-sm btn-success" title="Approve Registration" style="border-radius: 8px;">
                                                                <i class="bi bi-check-lg"></i>
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                    
                                                    <c:if test="${reg.status == 'PENDING' || reg.status == 'APPROVED'}">
                                                        <form action="${pageContext.request.contextPath}/admin/registration/status" method="POST" class="d-inline">
                                                            <input type="hidden" name="regId" value="${reg.id}">
                                                            <input type="hidden" name="status" value="REJECTED">
                                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Reject & Release Seat" style="border-radius: 8px;">
                                                                <i class="bi bi-x-lg"></i>
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                    
                                                    <!-- Attendance toggles (only if APPROVED) -->
                                                    <c:if test="${reg.status == 'APPROVED'}">
                                                        <span class="border-start mx-1" style="border-color: rgba(0,0,0,0.08) !important;"></span>
                                                        <form action="${pageContext.request.contextPath}/admin/registration/attendance" method="POST" class="d-inline">
                                                            <input type="hidden" name="regId" value="${reg.id}">
                                                            <c:choose>
                                                                <c:when test="${reg.attendance == 'PRESENT'}">
                                                                    <input type="hidden" name="attendance" value="ABSENT">
                                                                    <button type="submit" class="btn btn-sm btn-outline-secondary" title="Mark Absent (Revokes Certificate)" style="border-radius: 8px;">
                                                                        <i class="bi bi-person-x"></i>
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <input type="hidden" name="attendance" value="PRESENT">
                                                                    <button type="submit" class="btn btn-sm btn-outline-success" title="Mark Present (Generates Certificate)" style="border-radius: 8px;">
                                                                        <i class="bi bi-person-check"></i>
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </form>
                                                    </c:if>
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
