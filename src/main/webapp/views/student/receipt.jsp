<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ page import="com.collegeevent.model.Registration" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/views/student/registered-events.jsp");
        return;
    }

    int regId = Integer.parseInt(idStr.trim());
    RegistrationDAO registrationDAO = new RegistrationDAO();
    Registration reg = registrationDAO.getRegistrationById(regId);

    // Security check: ensure student can only see their own receipt
    if (reg == null || reg.getStudentId() != currentStudent.getId()) {
        response.sendRedirect(request.getContextPath() + "/views/student/registered-events.jsp");
        return;
    }

    request.setAttribute("r", reg);

    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, MMMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    request.setAttribute("dateFormatter", dateFormat);
    request.setAttribute("timeFormatter", timeFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="container py-5 d-print-none">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <a href="${pageContext.request.contextPath}/views/student/registered-events.jsp" class="btn btn-outline-secondary py-2 px-3 d-flex align-items-center gap-2" style="border-radius: 10px;">
                    <i class="bi bi-arrow-left"></i>Back to List
                </a>
                
                <button onclick="window.print()" class="btn btn-primary py-2 px-4 d-flex align-items-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                    <i class="bi bi-printer-fill"></i>Print Ticket Slip
                </button>
            </div>
            
        </div>
    </div>
</div>

<!-- Printable Ticket Layout -->
<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            
            <!-- Ticket Glass Card -->
            <div class="card card-glass p-5 border print-certificate-container" style="border-radius: 24px !important; border-width: 2px !important; background: radial-gradient(circle at 100% 100%, rgba(79, 70, 229, 0.03) 0%, rgba(255, 255, 255, 0.8) 100%);">
                
                <!-- Ticket Header -->
                <div class="d-flex justify-content-between align-items-start border-bottom border-secondary border-opacity-10 pb-4 mb-4">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="bi bi-calendar2-event-fill text-primary fs-3"></i>
                            <h4 class="mb-0 fw-extrabold" style="font-weight: 800; letter-spacing: -0.5px;">CAMPUS EVENT TICKET</h4>
                        </div>
                        <span class="text-muted" style="font-size: 0.85rem;">Smart College Event Management Portal</span>
                    </div>
                    
                    <div class="text-end">
                        <c:choose>
                            <c:when test="${r.status == 'APPROVED'}">
                                <span class="badge bg-success text-white py-2 px-3 fw-bold fs-6" style="border-radius: 30px;">ENTRY VALIDATED</span>
                            </c:when>
                            <c:when test="${r.status == 'PENDING'}">
                                <span class="badge bg-warning text-dark py-2 px-3 fw-bold fs-6" style="border-radius: 30px;">PENDING APPROVAL</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-danger text-white py-2 px-3 fw-bold fs-6" style="border-radius: 30px;">TICKET REJECTED</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <!-- Event Section -->
                <div class="mb-4">
                    <span class="text-primary fw-bold text-uppercase mb-1 d-block" style="font-size: 0.75rem; letter-spacing: 1px;"><c:out value="${r.eventCategory}"/></span>
                    <h3 class="fw-bold mb-3 text-main"><c:out value="${r.eventTitle}"/></h3>
                    
                    <div class="row g-3 p-3 bg-light bg-opacity-50 border rounded-3 mb-4" style="border-radius: 12px; border-color: var(--border-color) !important; background: rgba(0,0,0,0.015);">
                        <div class="col-sm-6">
                            <span class="text-muted d-block mb-0.5" style="font-size: 0.75rem;">EVENT DATE</span>
                            <span class="fw-bold text-main" style="font-size: 0.92rem;"><i class="bi bi-calendar3 text-primary me-2"></i><%= dateFormat.format(((Registration)pageContext.getAttribute("r")).getEventDate()) %></span>
                        </div>
                        
                        <div class="col-sm-6">
                            <span class="text-muted d-block mb-0.5" style="font-size: 0.75rem;">TIME</span>
                            <span class="fw-bold text-main" style="font-size: 0.92rem;"><i class="bi bi-clock-fill text-info me-2"></i><%= timeFormat.format(((Registration)pageContext.getAttribute("r")).getEventDate()) %></span>
                        </div>
                        
                        <div class="col-12 mt-2">
                            <span class="text-muted d-block mb-0.5" style="font-size: 0.75rem;">VENUE LOCATION</span>
                            <span class="fw-bold text-main" style="font-size: 0.92rem;"><i class="bi bi-geo-alt-fill text-danger me-2"></i><c:out value="${r.eventVenue}"/></span>
                        </div>
                    </div>
                </div>
                
                <!-- Student Details Section -->
                <div class="row g-3 mb-4">
                    <div class="col-sm-6">
                        <span class="text-muted d-block mb-0.5" style="font-size: 0.75rem;">ATTENDEE NAME</span>
                        <span class="fw-bold text-main" style="font-size: 0.95rem;"><c:out value="${r.studentName}"/></span>
                    </div>
                    
                    <div class="col-sm-6">
                        <span class="text-muted d-block mb-0.5" style="font-size: 0.75rem;">ROLL NUMBER & DEPT</span>
                        <span class="fw-bold text-main" style="font-size: 0.95rem;"><c:out value="${r.studentRoll}"/> &bull; <c:out value="${r.studentDepartment}"/></span>
                    </div>
                </div>

                <!-- QR Code & Token Row -->
                <div class="border-top border-secondary border-opacity-10 pt-4 d-flex flex-column flex-sm-row justify-content-between align-items-center gap-4">
                    <div class="text-center text-sm-start flex-grow-1">
                        <span class="text-muted d-block mb-1" style="font-size: 0.75rem;">SECURE TICKET ID</span>
                        <span class="font-monospace fw-bold text-main d-block mb-2" style="font-size: 0.85rem;"><c:out value="${r.qrCodeToken}"/></span>
                        <span class="text-muted d-block" style="font-size: 0.72rem;">Please present this ticket QR code at the event gate to mark your attendance.</span>
                    </div>
                    
                    <!-- Dynamic QR Container -->
                    <div class="d-flex flex-column align-items-center justify-content-center p-3 border bg-white shadow-sm" style="border-radius: 16px; border-color: var(--border-color) !important;">
                        <div id="qrcode-container" style="width: 120px; height: 120px;" class="d-flex align-items-center justify-content-center">
                            <!-- JS will inject QR code matrix here -->
                        </div>
                    </div>
                </div>
                
            </div>
            
        </div>
    </div>
</div>

<!-- Load QRCode.js library -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", () => {
        const qrContainer = document.getElementById("qrcode-container");
        const token = "${r.qrCodeToken}";

        if (typeof QRCode !== 'undefined') {
            new QRCode(qrContainer, {
                text: token,
                width: 120,
                height: 120,
                colorDark : "#0f172a",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            });
        } else {
            // Fallback beautiful mockup if CDN fails offline
            qrContainer.innerHTML = `
                <div class="d-flex flex-column align-items-center text-center justify-content-center text-muted" style="width: 100%; height: 100%; border: 2px dashed #cbd5e1; font-size: 0.6rem;">
                    <i class="bi bi-qr-code fs-3 text-secondary mb-1"></i>
                    <span>QR Matrix Mocked</span>
                </div>
            `;
        }
    });
</script>

<jsp:include page="/views/common/footer.jsp" />
