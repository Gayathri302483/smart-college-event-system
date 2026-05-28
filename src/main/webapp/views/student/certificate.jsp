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

    // Security: Only allow the student who owns the registration to view the certificate
    // And ensure status = APPROVED and attendance = PRESENT!
    if (reg == null || reg.getStudentId() != currentStudent.getId() || 
        !reg.getStatus().equalsIgnoreCase("APPROVED") || !reg.getAttendance().equalsIgnoreCase("PRESENT")) {
        response.sendRedirect(request.getContextPath() + "/views/student/registered-events.jsp");
        return;
    }

    request.setAttribute("r", reg);

    // Format unique certificate code
    String certCode = "CERT-" + reg.getQrCodeToken().substring(4, 12).toUpperCase() + "-" + regId;
    request.setAttribute("certCode", certCode);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<!-- Google Calligraphy Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@500;700;800&family=Pinyon+Script&display=swap" rel="stylesheet">

<div class="container py-5 d-print-none">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <a href="${pageContext.request.contextPath}/views/student/registered-events.jsp" class="btn btn-outline-secondary py-2 px-3 d-flex align-items-center gap-2" style="border-radius: 10px;">
                    <i class="bi bi-arrow-left"></i>Back to Registrations
                </a>
                
                <button onclick="window.print()" class="btn btn-success py-2 px-4 d-flex align-items-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; font-weight: 600;">
                    <i class="bi bi-printer-fill"></i>Export as PDF / Print
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Certificate Frame Box -->
<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            
            <!-- Landscape Certificate -->
            <div class="card p-5 shadow border print-certificate-container" style="min-height: 580px; border-radius: 8px; border: 12px double #b45309 !important; background: #fffcf2; position: relative; color: #1e293b; overflow: hidden; box-shadow: 0 15px 40px rgba(0,0,0,0.08) !important;">
                
                <!-- Background Calligraphy Seal Decors -->
                <div style="position: absolute; top: -50px; left: -50px; opacity: 0.03; font-size: 15rem; font-family: 'Cinzel'; pointer-events: none;">🎓</div>
                <div style="position: absolute; bottom: -50px; right: -50px; opacity: 0.03; font-size: 15rem; font-family: 'Cinzel'; pointer-events: none;">✨</div>
                
                <!-- Inner Border Frame -->
                <div class="p-4 border border-secondary border-opacity-10 h-100 d-flex flex-column justify-content-between text-center" style="border: 2px solid #d97706 !important;">
                    
                    <!-- Certificate Header -->
                    <div>
                        <span style="font-family: 'Cinzel', serif; letter-spacing: 4px; font-size: 1.1rem; font-weight: 700; color: #b45309;" class="d-block mb-2">CERTIFICATE OF PARTICIPATION</span>
                        <div style="width: 80px; height: 2px; background: #b45309; margin: 0 auto 20px;"></div>
                    </div>
                    
                    <!-- Certification Main Body -->
                    <div class="my-4">
                        <span class="text-muted d-block mb-3" style="font-size: 1rem; font-style: italic;">This is proudly presented to</span>
                        
                        <!-- Student Name in rich Script Calligraphy -->
                        <h1 class="display-3 mb-1" style="font-family: 'Pinyon Script', cursive; color: #1e1b4b; font-weight: 500;"><c:out value="${r.studentName}"/></h1>
                        <span class="text-muted d-block mb-4" style="font-size: 0.9rem;">Roll Number: <c:out value="${r.studentRoll}"/> &bull; <c:out value="${r.studentDepartment}"/> Department</span>
                        
                        <span class="text-muted d-block mb-3" style="font-size: 1rem; font-style: italic;">for successfully participating and completing the campus event</span>
                        
                        <!-- Event Title in heavy block caps -->
                        <h3 class="mb-2" style="font-family: 'Cinzel', serif; font-weight: 800; color: #1e1b4b; letter-spacing: 1px;"><c:out value="${r.eventTitle}"/></h3>
                        <span class="badge bg-secondary-subtle text-secondary py-1.5 px-3 mb-4" style="border-radius: 30px; font-size: 0.75rem; border: 1px solid rgba(0,0,0,0.05);"><c:out value="${r.eventCategory}"/> Event</span>
                    </div>

                    <!-- Footer signatures & Gold Ribbon Seal -->
                    <div class="row align-items-end mt-4">
                        <div class="col-4">
                            <div style="width: 140px; border-bottom: 1.5px solid #64748b; margin: 0 auto 8px;"></div>
                            <span class="text-muted d-block" style="font-size: 0.8rem; font-weight: 500;">Prof. Rajesh Kumar</span>
                            <span class="text-muted d-block" style="font-size: 0.7rem;">Event Organizer & Coordinator</span>
                        </div>
                        
                        <!-- Golden Ribbon Seal decoration -->
                        <div class="col-4 d-flex justify-content-center">
                            <div class="position-relative d-flex align-items-center justify-content-center" style="width: 90px; height: 90px;">
                                <div class="position-absolute bg-warning rounded-circle shadow-sm border border-white" style="width: 76px; height: 76px; background: radial-gradient(circle, #fbbf24 0%, #b45309 100%) !important;"></div>
                                <!-- Ribbon Tails -->
                                <div class="position-absolute bg-warning" style="width: 20px; height: 50px; bottom: -20px; left: 26px; transform: rotate(15deg); clip-path: polygon(0% 0%, 100% 0%, 100% 100%, 50% 80%, 0% 100%); background: #d97706 !important;"></div>
                                <div class="position-absolute bg-warning" style="width: 20px; height: 50px; bottom: -20px; right: 26px; transform: rotate(-15deg); clip-path: polygon(0% 0%, 100% 0%, 100% 100%, 50% 80%, 0% 100%); background: #d97706 !important;"></div>
                                <span class="position-relative text-white fw-bold text-center" style="font-family: 'Cinzel', serif; font-size: 0.65rem; line-height: 1.2; z-index: 2;">OFFICIAL<br>SEAL</span>
                            </div>
                        </div>
                        
                        <div class="col-4">
                            <span class="fw-bold d-block text-main mb-1" style="font-size: 0.85rem;"><%= dateFormat.format(((Registration)pageContext.getAttribute("r")).getEventDate()) %></span>
                            <div style="width: 140px; border-bottom: 1.5px solid #64748b; margin: 0 auto 8px;"></div>
                            <span class="text-muted d-block" style="font-size: 0.8rem; font-weight: 500;">Date of Conclusion</span>
                            <span class="text-muted d-block" style="font-size: 0.7rem;">Issued Electronically</span>
                        </div>
                    </div>
                    
                    <!-- Certificate Credentials Verification tag -->
                    <div class="mt-4 pt-3 border-top border-secondary border-opacity-10 d-flex justify-content-between text-muted" style="font-size: 0.65rem; border-color: rgba(0,0,0,0.04) !important;">
                        <span>Verification ID: <strong class="text-main"><c:out value="${certCode}"/></strong></span>
                        <span>Verify validity at: <strong class="text-main">college.edu/verify</strong></span>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
