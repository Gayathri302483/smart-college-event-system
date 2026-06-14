<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="container py-5">
    <div class="row justify-content-center align-items-center" style="min-height: 75vh;">
        <div class="col-md-6 col-lg-5">
            
            <!-- Alert Notifications mapping -->
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 8px;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>Error:</strong> <c:out value="${sessionScope.errorMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>
            
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 8px;">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <strong>Success!</strong> <c:out value="${sessionScope.successMsg}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>
            
            <!-- Login Card -->
            <div class="card card-glass border-0 shadow-sm p-4" style="background: #ffffff; border-radius: 12px !important;">
                <div class="text-center mb-4">
                    <!-- College Logo Area -->
                    <div class="mb-3">
                        <span class="d-inline-flex align-items-center justify-content-center bg-primary text-white rounded-circle shadow-sm" style="width: 70px; height: 70px;">
                            <i class="bi bi-mortarboard-fill" style="font-size: 2.2rem;"></i>
                        </span>
                        <h4 class="fw-bold mt-3 mb-1 text-primary">State University</h4>
                        <p class="text-muted small">Event Management & Student ERP Portal</p>
                    </div>
                </div>

                <!-- Tabs navigation -->
                <ul class="nav nav-pills nav-fill mb-4 p-1 bg-light rounded-pill" id="loginTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active rounded-pill fw-semibold" id="student-tab" data-bs-toggle="pill" data-bs-target="#student-login" type="button" role="tab" aria-controls="student-login" aria-selected="true">
                            <i class="bi bi-person-fill me-1"></i> Student Login
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link rounded-pill fw-semibold" id="admin-tab" data-bs-toggle="pill" data-bs-target="#admin-login" type="button" role="tab" aria-controls="admin-login" aria-selected="false">
                            <i class="bi bi-shield-lock-fill me-1"></i> Admin Login
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="loginTabsContent">
                    <!-- Student Login Tab -->
                    <div class="tab-pane fade show active" id="student-login" role="tabpanel" aria-labelledby="student-tab">
                        <form action="${pageContext.request.contextPath}/auth/login" method="POST">
                            <div class="mb-3">
                                <label for="email" class="form-label fw-semibold text-muted small">Email Address</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0 text-muted"><i class="bi bi-envelope-fill"></i></span>
                                    <input type="email" id="email" name="email" class="form-control form-control-glass border-start-0 ps-0" placeholder="name@student.edu" required autocomplete="email">
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <div class="d-flex justify-content-between mb-2">
                                    <label for="password" class="form-label fw-semibold text-muted small mb-0">Password</label>
                                    <a href="${pageContext.request.contextPath}/views/auth/forgot-password.jsp" class="text-decoration-none text-primary fw-semibold" style="font-size: 0.85rem;">Forgot Password?</a>
                                </div>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0 text-muted"><i class="bi bi-shield-lock-fill"></i></span>
                                    <input type="password" id="password" name="password" class="form-control form-control-glass border-start-0 ps-0" placeholder="••••••••" required>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100 py-2.5 mb-3" style="border-radius: 8px; font-weight: 600;">
                                Sign In
                            </button>
                            
                            <div class="text-center mt-3" style="font-size: 0.9rem;">
                                <span class="text-muted">New student? </span>
                                <a href="${pageContext.request.contextPath}/views/auth/register.jsp" class="text-decoration-none text-primary fw-semibold">Create Account</a>
                            </div>
                        </form>
                    </div>

                    <!-- Admin Login Tab -->
                    <div class="tab-pane fade" id="admin-login" role="tabpanel" aria-labelledby="admin-tab">
                        <form action="${pageContext.request.contextPath}/auth/admin-login" method="POST">
                            <div class="mb-3">
                                <label for="username" class="form-label fw-semibold text-muted small">Username</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0 text-muted"><i class="bi bi-person-badge-fill"></i></span>
                                    <input type="text" id="username" name="username" class="form-control form-control-glass border-start-0 ps-0" placeholder="Admin username" required>
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <label for="admin-password" class="form-label fw-semibold text-muted small">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0 text-muted"><i class="bi bi-shield-lock-fill"></i></span>
                                    <input type="password" id="admin-password" name="password" class="form-control form-control-glass border-start-0 ps-0" placeholder="••••••••" required>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100 py-2.5" style="border-radius: 8px; font-weight: 600;">
                                Administrator Sign In
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
