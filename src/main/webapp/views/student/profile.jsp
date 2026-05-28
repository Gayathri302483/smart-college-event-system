<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Student" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Student currentStudent = (Student) session.getAttribute("currentStudent");
    if (currentStudent == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="profile" />
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

            <div class="row g-4 justify-content-center">
                <div class="col-lg-6 col-xl-5">
                    
                    <div class="card card-glass p-4 border h-100">
                        <div class="text-center mb-4 border-bottom border-secondary border-opacity-10 pb-3">
                            <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mb-3" style="width: 70px; height: 70px;">
                                <i class="bi bi-person-bounding-box" style="font-size: 2.2rem;"></i>
                            </div>
                            <h4 class="fw-bold mb-1"><c:out value="${sessionScope.currentStudent.fullName}"/></h4>
                            <p class="text-muted mb-0" style="font-size: 0.9rem;">Roll No: <c:out value="${sessionScope.currentStudent.rollNumber}"/> &bull; Student Account</p>
                        </div>
                        
                        <form action="${pageContext.request.contextPath}/student/profile/update" method="POST">
                            <div class="mb-3">
                                <label for="fullName" class="form-label fw-semibold">Full Name</label>
                                <input type="text" id="fullName" name="fullName" class="form-control form-control-glass" value="<c:out value="${sessionScope.currentStudent.fullName}"/>" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" class="form-label fw-semibold">Registered Email Address</label>
                                <input type="email" id="email" class="form-control form-control-glass bg-secondary bg-opacity-10" value="<c:out value="${sessionScope.currentStudent.email}"/>" disabled>
                                <span class="form-text text-muted" style="font-size: 0.75rem;">Email address cannot be changed after registration.</span>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="rollNumber" class="form-label fw-semibold">Roll Number</label>
                                    <input type="text" id="rollNumber" name="rollNumber" class="form-control form-control-glass" value="<c:out value="${sessionScope.currentStudent.rollNumber}"/>" required>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="department" class="form-label fw-semibold">Department</label>
                                    <select id="department" name="department" class="form-select form-control-glass" required>
                                        <option value="Computer Science" ${sessionScope.currentStudent.department == 'Computer Science' ? 'selected' : ''}>Computer Science</option>
                                        <option value="Information Technology" ${sessionScope.currentStudent.department == 'Information Technology' ? 'selected' : ''}>Information Technology</option>
                                        <option value="Electronics" ${sessionScope.currentStudent.department == 'Electronics' ? 'selected' : ''}>Electronics</option>
                                        <option value="Mechanical" ${sessionScope.currentStudent.department == 'Mechanical' ? 'selected' : ''}>Mechanical</option>
                                        <option value="Civil" ${sessionScope.currentStudent.department == 'Civil' ? 'selected' : ''}>Civil</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <label for="phone" class="form-label fw-semibold">Contact Phone</label>
                                <input type="text" id="phone" name="phone" class="form-control form-control-glass" value="<c:out value="${sessionScope.currentStudent.phone}"/>">
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100 py-2.5 fw-semibold" style="border-radius: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none;">
                                Update Account Settings
                            </button>
                        </form>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
