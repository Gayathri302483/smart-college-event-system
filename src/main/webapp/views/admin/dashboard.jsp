<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.collegeevent.model.Admin" %>
<%@ page import="com.collegeevent.dao.EventDAO" %>
<%@ page import="com.collegeevent.dao.StudentDAO" %>
<%@ page import="com.collegeevent.dao.RegistrationDAO" %>
<%@ page import="com.collegeevent.model.Registration" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        return;
    }

    EventDAO eventDAO = new EventDAO();
    StudentDAO studentDAO = new StudentDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    // Aggregates for stat cards
    int totalEvents = eventDAO.getTotalEventsCount("", "all");
    int totalStudents = studentDAO.getAllStudents().size();
    
    List<Registration> allRegs = registrationDAO.getAllRegistrations();
    int totalRegs = allRegs.size();
    int pendingRegs = 0;
    for (Registration r : allRegs) {
        if (r.getStatus().equalsIgnoreCase("PENDING")) pendingRegs++;
    }

    request.setAttribute("totalEvents", totalEvents);
    request.setAttribute("totalStudents", totalStudents);
    request.setAttribute("totalRegs", totalRegs);
    request.setAttribute("pendingRegs", pendingRegs);
    request.setAttribute("recentRegistrations", allRegs.subList(0, Math.min(allRegs.size(), 4)));

    // Fetch dynamic analytics charts data
    Map<String, Integer> categoryDistribution = eventDAO.getCategoryDistribution();
    Map<String, Integer> registrationTrends = eventDAO.getRegistrationTrends();
    Map<String, Integer> departmentStats = registrationDAO.getDepartmentStats();

    request.setAttribute("categoryStats", categoryDistribution);
    request.setAttribute("trendsStats", registrationTrends);
    request.setAttribute("deptStats", departmentStats);

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    request.setAttribute("dateFormatter", dateFormat);
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="app-wrapper">
    <!-- Include Admin Sidebar active layout -->
    <jsp:include page="/views/common/sidebar.jsp">
        <jsp:param name="active" value="dashboard" />
    </jsp:include>

    <!-- Main Admin Content Area -->
    <div class="flex-grow-1 p-4" style="background-color: var(--bg-base);">
        <div class="container-fluid">
            
            <!-- Dashboard Title Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="fw-bold mb-1">Overview Console</h2>
                    <p class="text-muted mb-0">System health statistics, analytics distribution, and recent coordinator logs.</p>
                </div>
                
                <a href="${pageContext.request.contextPath}/views/admin/event-form.jsp" class="btn btn-primary px-3 py-2 d-flex align-items-center gap-2" style="border-radius: 10px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%); border: none; font-weight: 600;">
                    <i class="bi bi-plus-circle-fill"></i>Create New Event
                </a>
            </div>

            <!-- Dashboard Aggregate Cards Grid -->
            <div class="row g-4 mb-4">
                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-primary-subtle text-primary">
                            <i class="bi bi-calendar3"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${totalEvents}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Events Managed</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-success-subtle text-success">
                            <i class="bi bi-mortarboard-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${totalStudents}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Registered Students</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-info-subtle text-info">
                            <i class="bi bi-ticket-detailed-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${totalRegs}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Total Applications</span>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-sm-6">
                    <div class="stat-widget">
                        <div class="stat-icon bg-danger-subtle text-danger">
                            <i class="bi bi-exclamation-octagon-fill"></i>
                        </div>
                        <div>
                            <h3 class="mb-0 fw-bold"><c:out value="${pendingRegs}"/></h3>
                            <span class="text-muted" style="font-size: 0.85rem;">Pending Approvals</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Analytics Visual Charts Row -->
            <div class="row g-4 mb-4">
                <!-- Bar Chart: Registration Trends -->
                <div class="col-lg-8">
                    <div class="card card-glass p-4 h-100 border">
                        <h5 class="fw-bold mb-3"><i class="bi bi-bar-chart-fill text-primary me-2"></i>Registrations by Event</h5>
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="trendsChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Doughnut Chart: Category Distribution -->
                <div class="col-lg-4">
                    <div class="card card-glass p-4 h-100 border">
                        <h5 class="fw-bold mb-3"><i class="bi bi-pie-chart-fill text-accent me-2"></i>Events by Category</h5>
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Pie Chart: Department Distribution -->
                <div class="col-lg-5">
                    <div class="card card-glass p-4 h-100 border">
                        <h5 class="fw-bold mb-3"><i class="bi bi-pie-chart-fill text-success me-2"></i>Participation by Department</h5>
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="deptChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Recent Registrations Summary -->
                <div class="col-lg-7">
                    <div class="card card-glass p-4 h-100 border">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0">Recent Applications Pending Review</h5>
                            <a href="${pageContext.request.contextPath}/views/admin/registrations.jsp" class="text-decoration-none text-primary fw-semibold" style="font-size: 0.9rem;">Review Panel</a>
                        </div>

                        <c:choose>
                            <c:when test="${empty recentRegistrations}">
                                <div class="text-center py-5 text-muted">
                                    <i class="bi bi-check2-all" style="font-size: 2.5rem;"></i>
                                    <p class="mt-3 mb-0">All clear! No recent pending review logs.</p>
                                </div>
                            </c:when>
                            
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle" style="font-size: 0.9rem;">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Applied Event</th>
                                                <th>Status</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="reg" items="${recentRegistrations}">
                                                <tr>
                                                    <td>
                                                        <span class="fw-bold"><c:out value="${reg.studentName}"/></span>
                                                        <br><span class="text-muted" style="font-size: 0.75rem;"><c:out value="${reg.studentRoll}"/> &bull; <c:out value="${reg.studentDepartment}"/></span>
                                                    </td>
                                                    <td>
                                                        <c:out value="${reg.eventTitle}"/>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${reg.status == 'APPROVED'}">
                                                                <span class="badge bg-success-subtle text-success py-1 px-2.5" style="border-radius: 20px;">Approved</span>
                                                            </c:when>
                                                            <c:when test="${reg.status == 'PENDING'}">
                                                                <span class="badge bg-warning-subtle text-warning py-1 px-2.5" style="border-radius: 20px;">Pending</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-danger-subtle text-danger py-1 px-2.5" style="border-radius: 20px;">Rejected</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end">
                                                        <a href="${pageContext.request.contextPath}/views/admin/registrations.jsp" class="btn btn-sm btn-primary rounded-circle" style="width: 32px; height: 32px; padding: 0; line-height: 32px; display: inline-flex; align-items: center; justify-content: center;" title="Review application">
                                                            <i class="bi bi-arrow-right-short fs-5"></i>
                                                        </a>
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
    </div>
</div>

<!-- Load Chart.js library -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Inline data population and Chart initialization -->
<script>
document.addEventListener("DOMContentLoaded", () => {
    // 1. Chart Data Extraction from JSP Maps
    const catLabels = [];
    const catData = [];
    <c:forEach var="entry" items="${categoryStats}">
        catLabels.push("${entry.key}");
        catData.push(${entry.value});
    </c:forEach>

    const trendLabels = [];
    const trendData = [];
    <c:forEach var="entry" items="${trendsStats}">
        trendLabels.push("${entry.key}");
        trendData.push(${entry.value});
    </c:forEach>

    const deptLabels = [];
    const deptData = [];
    <c:forEach var="entry" items="${deptStats}">
        deptLabels.push("${entry.key}");
        deptData.push(${entry.value});
    </c:forEach>

    // Fallback if DB data is sparse initially to keep charts pretty
    if(catLabels.length === 0) {
        catLabels.push("Technical", "Cultural", "Workshop", "Seminar", "Hackathon");
        catData.push(1, 1, 1, 1, 1);
    }
    
    // Theme Colors
    const isDark = document.documentElement.getAttribute("data-theme") === "dark";
    const textThemeColor = isDark ? '#e4e4e7' : '#0f172a';
    const gridThemeColor = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)';

    // 2. Render Doughnut Chart: Category Distribution
    const ctxCat = document.getElementById('categoryChart').getContext('2d');
    new Chart(ctxCat, {
        type: 'doughnut',
        data: {
            labels: catLabels,
            datasets: [{
                data: catData,
                backgroundColor: ['#4f46e5', '#ec4899', '#10b981', '#06b6d4', '#f59e0b'],
                borderWidth: isDark ? 2 : 1,
                borderColor: isDark ? '#121218' : '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: textThemeColor, font: { family: 'Outfit' } }
                }
            }
        }
    });

    // 3. Render Bar Chart: Registration Trends
    const ctxTrend = document.getElementById('trendsChart').getContext('2d');
    new Chart(ctxTrend, {
        type: 'bar',
        data: {
            labels: trendLabels,
            datasets: [{
                label: 'Enrolled Seats',
                data: trendData,
                backgroundColor: 'rgba(79, 70, 229, 0.85)',
                hoverBackgroundColor: '#4f46e5',
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    grid: { display: false },
                    ticks: { color: textThemeColor, font: { family: 'Outfit' } }
                },
                y: {
                    grid: { color: gridThemeColor },
                    ticks: { color: textThemeColor, font: { family: 'Outfit' }, stepSize: 1 }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });

    // 4. Render Pie Chart: Department Stats
    const ctxDept = document.getElementById('deptChart').getContext('2d');
    new Chart(ctxDept, {
        type: 'polarArea',
        data: {
            labels: deptLabels.length > 0 ? deptLabels : ["Computer Science", "Information Technology", "Electronics"],
            datasets: [{
                data: deptData.length > 0 ? deptData : [1, 0, 0],
                backgroundColor: ['rgba(79, 70, 229, 0.75)', 'rgba(6, 182, 212, 0.75)', 'rgba(16, 185, 129, 0.75)', 'rgba(236, 72, 153, 0.75)'],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                r: {
                    grid: { color: gridThemeColor },
                    ticks: { display: false }
                }
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: textThemeColor, font: { family: 'Outfit' } }
                }
            }
        }
    });
});
</script>

<jsp:include page="/views/common/footer.jsp" />
