package com.collegeevent.filter;

import com.collegeevent.model.Admin;
import com.collegeevent.model.Student;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/views/student/*", "/views/admin/*", "/student/*", "/admin/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        
        // Prevent browser caching of protected pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        httpResponse.setHeader("Pragma", "no-cache"); // HTTP 1.0
        httpResponse.setDateHeader("Expires", 0); // Proxies

        // 1. Admin Authorization check
        if (requestURI.contains("/admin/") || requestURI.contains("/admin")) {
            Admin admin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;
            if (admin == null) {
                // Not logged in as Admin, redirect to Admin Login
                session = httpRequest.getSession(true);
                session.setAttribute("errorMsg", "Access Denied! Please login as an administrator.");
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/admin-login.jsp");
                return;
            }
        }

        // 2. Student Authorization check
        if (requestURI.contains("/student/") || requestURI.contains("/student")) {
            // Allow public receipts and certificates without checking login IF they have a validation token,
            // but for safety let's enforce login unless they are viewing receipts or certificates which is student features.
            // Let's enforce standard student session.
            Student student = (session != null) ? (Student) session.getAttribute("currentStudent") : null;
            if (student == null) {
                // Not logged in as Student, redirect to Student Login
                session = httpRequest.getSession(true);
                session.setAttribute("errorMsg", "Access Denied! Please login to your student account.");
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/login.jsp");
                return;
            }

            // 3. Email Verification check (OTP)
            // If logged in, but not verified, and not already on verify-otp page or processing OTP
            if (!student.isVerified() && 
                !requestURI.contains("verify-otp") && 
                !requestURI.contains("otp") && 
                !requestURI.contains("auth")) {
                
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/verify-otp.jsp");
                return;
            }
        }

        // Proceed to destination
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
