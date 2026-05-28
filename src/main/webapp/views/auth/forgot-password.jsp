<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

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
            
            <!-- Forgot Password Card -->
            <div class="card card-glass p-4 border">
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-danger-subtle text-danger rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-lock-fill" style="font-size: 1.8rem;"></i>
                    </div>
                    <h4 class="fw-bold mb-1">Reset Password</h4>
                    <p class="text-muted" style="font-size: 0.9rem;">Reset your password (Mock email sent in backend logs)</p>
                </div>
                
                <form action="${pageContext.request.contextPath}/auth/forgot-password" method="POST">
                    <div class="mb-3">
                        <label for="email" class="form-label fw-semibold">Registered Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-10 text-muted"><i class="bi bi-envelope-fill"></i></span>
                            <input type="email" id="email" name="email" class="form-control form-control-glass border-start-0 ps-0" placeholder="name@student.edu" required>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <label for="password" class="form-label fw-semibold">New Password Choice</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-10 text-muted"><i class="bi bi-shield-lock-fill"></i></span>
                            <input type="password" id="password" name="password" class="form-control form-control-glass border-start-0 ps-0" placeholder="••••••••" required>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-danger w-100 py-2.5 mb-2 fw-semibold" style="border-radius: 12px; background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); border: none;">
                        Recover Account Credentials
                    </button>
                    
                    <a href="${pageContext.request.contextPath}/views/auth/login.jsp" class="btn btn-outline-secondary w-100 py-2" style="border-radius: 12px; font-weight: 500;">
                        <i class="bi bi-arrow-left me-1"></i>Back to Log In
                    </a>
                </form>
            </div>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
