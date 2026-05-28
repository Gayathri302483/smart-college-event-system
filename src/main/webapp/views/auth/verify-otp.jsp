<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent != null) {
        String testOtp = (String) application.getAttribute("lastSentOTP_" + currentStudent.getId());
        request.setAttribute("simulatedOtp", testOtp);
    }
%>

<div class="container py-5">
    <div class="row justify-content-center align-items-center" style="min-height: 70vh;">
        <div class="col-md-5 col-lg-4">
            
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 12px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>Error:</strong> <c:out value="${sessionScope.errorMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>
            
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 12px;">
                    <i class="bi bi-info-circle-fill me-2"></i>
                    <c:out value="${sessionScope.successMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>
            
            <!-- OTP Verification Form -->
            <div class="card card-glass p-4 border">
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-info-subtle text-info rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-shield-check" style="font-size: 1.8rem;"></i>
                    </div>
                    <h4 class="fw-bold mb-1">Verify Email</h4>
                    <p class="text-muted" style="font-size: 0.9rem;">Enter the 6-digit OTP code sent to <strong><c:out value="${sessionScope.currentStudent.email}"/></strong></p>
                </div>
                
                <form action="${pageContext.request.contextPath}/auth/verify-otp" method="POST">
                    <div class="mb-4 text-center">
                        <label for="otp" class="form-label fw-semibold mb-2">Enter Verification Code</label>
                        <input type="text" id="otp" name="otp" class="form-control form-control-glass text-center fw-bold fs-4" placeholder="000000" maxlength="6" pattern="\d{6}" required autocomplete="off" style="letter-spacing: 8px;">
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100 py-2.5 mb-2 fw-semibold" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                        Verify Verification Code
                    </button>
                    
                    <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-outline-secondary w-100 py-2" style="border-radius: 12px; font-weight: 500;">
                        <i class="bi bi-box-arrow-left me-1"></i>Cancel & Sign Out
                    </a>
                </form>
            </div>
            
            <!-- Developer Testing Helper Widget -->
            <c:if test="${not empty simulatedOtp}">
                <div class="card card-glass border border-info p-3 mt-4 text-center" style="border-style: dashed !important; background: rgba(6, 182, 212, 0.03);">
                    <div class="d-flex align-items-center justify-content-center gap-2 mb-1 text-info fw-bold" style="font-size: 0.85rem;">
                        <i class="bi bi-bug-fill"></i>
                        <span>DEVELOPER TEST HELPER</span>
                    </div>
                    <p class="text-muted mb-2" style="font-size: 0.8rem;">To simulate checking your external email client, copy the generated code below:</p>
                    <div class="bg-dark text-white rounded py-2 px-3 fw-bold font-monospace fs-5 border border-secondary" style="letter-spacing: 2px;">
                        <c:out value="${simulatedOtp}"/>
                    </div>
                </div>
            </c:if>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
