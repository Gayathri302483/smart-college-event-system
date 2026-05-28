<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="container py-5">
    <div class="row justify-content-center align-items-center" style="min-height: 70vh;">
        <div class="col-md-5 col-lg-4">
            
            <!-- Alert Notifications mapping -->
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
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <strong>Success!</strong> <c:out value="${sessionScope.successMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>
            
            <!-- Login Card -->
            <div class="card card-glass p-4 border">
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-person-fill" style="font-size: 1.8rem;"></i>
                    </div>
                    <h4 class="fw-bold mb-1">Student Portal</h4>
                    <p class="text-muted" style="font-size: 0.9rem;">Log in to access dashboards and events</p>
                </div>
                
                <form action="${pageContext.request.contextPath}/auth/login" method="POST">
                    <div class="mb-3">
                        <label for="email" class="form-label fw-semibold">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-10 text-muted"><i class="bi bi-envelope-fill"></i></span>
                            <input type="email" id="email" name="email" class="form-control form-control-glass border-start-0 ps-0" placeholder="name@student.edu" required autocomplete="email">
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <div class="d-flex justify-content-between mb-2">
                            <label for="password" class="form-label fw-semibold mb-0">Password</label>
                            <a href="${pageContext.request.contextPath}/views/auth/forgot-password.jsp" class="text-decoration-none text-primary fw-semibold" style="font-size: 0.85rem;">Forgot Password?</a>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-10 text-muted"><i class="bi bi-shield-lock-fill"></i></span>
                            <input type="password" id="password" name="password" class="form-control form-control-glass border-start-0 ps-0" placeholder="••••••••" required>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100 py-2.5 mb-3" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                        Sign In Account
                    </button>
                    
                    <div class="text-center" style="font-size: 0.9rem;">
                        <span class="text-muted">Don't have an account? </span>
                        <a href="${pageContext.request.contextPath}/views/auth/register.jsp" class="text-decoration-none text-primary fw-semibold">Register Here</a>
                    </div>
                </form>
            </div>
            
            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/views/auth/admin-login.jsp" class="text-decoration-none text-muted fw-semibold" style="font-size: 0.85rem;">
                    <i class="bi bi-shield-lock-fill me-1 text-warning"></i>Administrators Portal Login
                </a>
            </div>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
