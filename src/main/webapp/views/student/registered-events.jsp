<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="com.collegeevent.model.Registration" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
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
    List<Registration> list = registrationDAO.getRegistrationsByStudent(currentStudent.getId());
    request.setAttribute("regs", list);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
    request.setAttribute("timeFormatter", timeFormat);
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
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">My Registered Events</h2>
                    <p class="text-muted mb-0">View registration statuses, download ticket slips, and claim participation certificates.</p>
                </div>
            </div>

            <!-- Registrations List Card -->
            <div class="card card-glass p-4 border">
                <c:choose>
                    <c:when test="${empty regs}">
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-journal-x" style="font-size: 3rem;"></i>
                            <h4 class="fw-bold mt-3">No registrations found</h4>
                            <p class="text-muted">You haven't registered for any events yet. Head over to the catalog to register!</p>
                            <a href="${pageContext.request.contextPath}/views/student/events.jsp" class="btn btn-primary rounded-pill px-4 mt-2" style="background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">Explore Event Calendar</a>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Event Details</th>
                                        <th>Registration Date</th>
                                        <th>Status</th>
                                        <th>Attendance</th>
                                        <th class="text-end">Ticket & Certificate</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${regs}">
                                        <tr>
                                            <td>
                                                <h6 class="fw-bold mb-1"><c:out value="${r.eventTitle}"/></h6>
                                                <div class="d-flex gap-3 text-muted flex-wrap" style="font-size: 0.8rem;">
                                                    <span><i class="bi bi-calendar-event me-1"></i><%= dateFormat.format(((Registration)pageContext.getAttribute("r")).getEventDate()) %></span>
                                                    <span><i class="bi bi-clock me-1"></i><%= timeFormat.format(((Registration)pageContext.getAttribute("r")).getEventDate()) %></span>
                                                    <span><i class="bi bi-geo-alt-fill me-1"></i><c:out value="${r.eventVenue}"/></span>
                                                </div>
                                            </td>
                                            
                                            <td style="font-size: 0.9rem;">
                                                <%= dateFormat.format(((Registration)pageContext.getAttribute("r")).getRegistrationDate()) %>
                                            </td>
                                            
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.status == 'APPROVED'}">
                                                        <span class="badge bg-success-subtle text-success py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Approved</span>
                                                    </c:when>
                                                    <c:when test="${r.status == 'PENDING'}">
                                                        <span class="badge bg-warning-subtle text-warning py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Pending Approval</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger-subtle text-danger py-1.5 px-3" style="border-radius: 30px; font-weight: 600;">Rejected</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.attendance == 'PRESENT'}">
                                                        <span class="badge bg-success text-white py-1.5 px-2.5" style="border-radius: 8px; font-size: 0.72rem;"><i class="bi bi-person-check-fill me-1"></i>Present</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary-subtle text-secondary py-1.5 px-2.5" style="border-radius: 8px; font-size: 0.72rem;"><i class="bi bi-person-x-fill me-1"></i>Absent</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            
                                            <td class="text-end">
                                                <div class="d-inline-flex gap-2">
                                                    <!-- Download ticket/receipt -->
                                                    <a href="${pageContext.request.contextPath}/views/student/receipt.jsp?id=${r.id}" class="btn btn-sm btn-outline-secondary d-flex align-items-center gap-1.5 px-3 py-2" title="Print Participation Ticket" style="border-radius: 10px;">
                                                        <i class="bi bi-qr-code"></i>
                                                        <span class="d-none d-lg-inline">Ticket Slip</span>
                                                    </a>
                                                    
                                                    <!-- Dynamic Certificate Claims -->
                                                    <c:choose>
                                                        <c:when test="${r.status == 'APPROVED' && r.attendance == 'PRESENT'}">
                                                            <a href="${pageContext.request.contextPath}/views/student/certificate.jsp?id=${r.id}" class="btn btn-sm btn-success d-flex align-items-center gap-1.5 px-3 py-2" title="Claim Certificate" style="border-radius: 10px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none;">
                                                                <i class="bi bi-award-fill"></i>
                                                                <span>Certificate</span>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-sm btn-secondary d-flex align-items-center gap-1.5 px-3 py-2 disabled" title="Certificate locks until event attendance is marked as present" style="border-radius: 10px; opacity: 0.5;">
                                                                <i class="bi bi-award-fill"></i>
                                                                <span>Certificate</span>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
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
