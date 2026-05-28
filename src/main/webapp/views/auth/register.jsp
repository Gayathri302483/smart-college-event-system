<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="container py-5">
    <div class="row justify-content-center align-items-center" style="min-height: 80vh;">
        <div class="col-md-7 col-lg-5">
            
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 12px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>Error:</strong> <c:out value="${sessionScope.errorMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>
            
            <!-- JS Validation alerts container -->
            <div id="validation-errors" class="alert alert-danger d-none border-0 shadow-sm" role="alert" style="border-radius: 12px;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
            </div>
            
            <!-- Registration Card -->
            <div class="card card-glass p-4 border">
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="bi bi-mortarboard-fill" style="font-size: 1.8rem;"></i>
                    </div>
                    <h4 class="fw-bold mb-1">Student Enrollment</h4>
                    <p class="text-muted" style="font-size: 0.9rem;">Join the portal to register and keep track of events</p>
                </div>
                
                <form action="${pageContext.request.contextPath}/auth/register" method="POST" onsubmit="return validateRegistrationForm()">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="fullName" class="form-label fw-semibold">Full Name</label>
                            <input type="text" id="fullName" name="fullName" class="form-control form-control-glass" placeholder="Amit Sharma" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="email" class="form-label fw-semibold">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control form-control-glass" placeholder="amit@student.edu" required>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="rollNumber" class="form-label fw-semibold">Roll Number</label>
                            <input type="text" id="rollNumber" name="rollNumber" class="form-control form-control-glass" placeholder="CS2023001" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="department" class="form-label fw-semibold">Department</label>
                            <select id="department" name="department" class="form-select form-control-glass" required>
                                <option value="" disabled selected>Select Department</option>
                                <option value="Computer Science">Computer Science</option>
                                <option value="Information Technology">Information Technology</option>
                                <option value="Electronics">Electronics</option>
                                <option value="Mechanical">Mechanical</option>
                                <option value="Civil">Civil</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-12 mb-3">
                            <label for="phone" class="form-label fw-semibold">Phone Number (Optional)</label>
                            <input type="tel" id="phone" name="phone" class="form-control form-control-glass" placeholder="9876543210">
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="password" class="form-label fw-semibold">Password</label>
                            <input type="password" id="password" name="password" class="form-control form-control-glass" placeholder="••••••••" required>
                        </div>
                        
                        <div class="col-md-6 mb-4">
                            <label for="confirmPassword" class="form-label fw-semibold">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control form-control-glass" placeholder="••••••••" required>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100 py-2.5 mb-3" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                        Create Free Account
                    </button>
                    
                    <div class="text-center" style="font-size: 0.9rem;">
                        <span class="text-muted">Already have an account? </span>
                        <a href="${pageContext.request.contextPath}/views/auth/login.jsp" class="text-decoration-none text-primary fw-semibold">Log In</a>
                    </div>
                </form>
            </div>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
