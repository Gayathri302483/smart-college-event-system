package com.collegeevent.controller;

import com.collegeevent.dao.AdminDAO;
import com.collegeevent.dao.StudentDAO;
import com.collegeevent.dao.NotificationDAO;
import com.collegeevent.model.Admin;
import com.collegeevent.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Random;
import java.util.logging.Logger;

@WebServlet("/auth/*")
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AuthController.class.getName());
    
    private final StudentDAO studentDAO = new StudentDAO();
    private final AdminDAO adminDAO = new AdminDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession(false);

        if ("/logout".equals(pathInfo)) {
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp?successMsg=Logged out successfully.");
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if ("/login".equals(pathInfo)) {
            handleStudentLogin(request, response);
        } else if ("/admin-login".equals(pathInfo)) {
            handleAdminLogin(request, response);
        } else if ("/register".equals(pathInfo)) {
            handleStudentRegistration(request, response);
        } else if ("/verify-otp".equals(pathInfo)) {
            handleOTPVerification(request, response);
        } else if ("/forgot-password".equals(pathInfo)) {
            handleForgotPassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    private void handleStudentLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        HttpSession session = request.getSession();

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Email and Password are required.");
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        Student student = studentDAO.validateStudent(email.trim(), password.trim());

        if (student != null) {
            session.setAttribute("currentStudent", student);
            
            if (!student.isVerified()) {
                // If not verified, regenerate OTP and send them to verify page
                sendOTPMock(student);
                session.setAttribute("successMsg", "Your account is not verified yet. A new OTP has been sent!");
                response.sendRedirect(request.getContextPath() + "/views/auth/verify-otp.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/views/student/dashboard.jsp");
            }
        } else {
            session.setAttribute("errorMsg", "Invalid Email or Password.");
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        }
    }

    private void handleAdminLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        HttpSession session = request.getSession();

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Username and Password are required.");
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        Admin admin = adminDAO.validateAdmin(username.trim(), password.trim());

        if (admin != null) {
            session.setAttribute("currentAdmin", admin);
            response.sendRedirect(request.getContextPath() + "/views/admin/dashboard.jsp");
        } else {
            session.setAttribute("errorMsg", "Invalid Username or Password.");
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
        }
    }

    private void handleStudentRegistration(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String rollNumber = request.getParameter("rollNumber");
        String department = request.getParameter("department");
        String phone = request.getParameter("phone");

        HttpSession session = request.getSession();

        if (email == null || password == null || fullName == null || rollNumber == null || department == null) {
            session.setAttribute("errorMsg", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/views/auth/register.jsp");
            return;
        }

        if (studentDAO.getStudentByEmail(email.trim()) != null) {
            session.setAttribute("errorMsg", "Email already registered. Try logging in.");
            response.sendRedirect(request.getContextPath() + "/views/auth/register.jsp");
            return;
        }

        Student student = new Student();
        student.setEmail(email.trim());
        student.setPassword(password.trim());
        student.setFullName(fullName.trim());
        student.setRollNumber(rollNumber.trim().toUpperCase());
        student.setDepartment(department);
        student.setPhone(phone != null ? phone.trim() : "");
        student.setVerified(false); // Verification required at registration

        boolean isRegistered = studentDAO.registerStudent(student);

        if (isRegistered) {
            Student registeredStudent = studentDAO.getStudentByEmail(email.trim());
            session.setAttribute("currentStudent", registeredStudent);
            
            // Send Verification Code Mock
            sendOTPMock(registeredStudent);
            
            // Log a welcome notification in system
            notificationDAO.addNotification(registeredStudent.getId(), 
                "Welcome " + registeredStudent.getFullName() + "! Please complete your registration via OTP verification.");

            session.setAttribute("successMsg", "Registration successful! Enter the OTP code sent to your email to verify your account.");
            response.sendRedirect(request.getContextPath() + "/views/auth/verify-otp.jsp");
        } else {
            session.setAttribute("errorMsg", "Registration failed due to database or validation errors. Please check roll number uniqueness.");
            response.sendRedirect(request.getContextPath() + "/views/auth/register.jsp");
        }
    }

    private void handleOTPVerification(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String otp = request.getParameter("otp");
        HttpSession session = request.getSession();
        
        Student student = (Student) session.getAttribute("currentStudent");

        if (student == null) {
            session.setAttribute("errorMsg", "No active session found. Please login first.");
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        if (otp == null || otp.trim().length() != 6) {
            session.setAttribute("errorMsg", "Please enter a valid 6-digit OTP code.");
            response.sendRedirect(request.getContextPath() + "/views/auth/verify-otp.jsp");
            return;
        }

        boolean isVerified = studentDAO.verifyOTP(student.getId(), otp.trim());

        if (isVerified) {
            student.setVerified(true);
            session.setAttribute("currentStudent", student);
            
            notificationDAO.addNotification(student.getId(), 
                "Account verified successfully! You can now explore upcoming events and register.");

            session.setAttribute("successMsg", "Email verified successfully! Welcome to the portal.");
            response.sendRedirect(request.getContextPath() + "/views/student/dashboard.jsp");
        } else {
            session.setAttribute("errorMsg", "Invalid or expired OTP code. Please check and try again.");
            response.sendRedirect(request.getContextPath() + "/views/auth/verify-otp.jsp");
        }
    }

    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String newPassword = request.getParameter("password");
        HttpSession session = request.getSession();

        if (email == null || newPassword == null || email.trim().isEmpty() || newPassword.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Email and New Password are required.");
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp");
            return;
        }

        Student student = studentDAO.getStudentByEmail(email.trim());

        if (student != null) {
            boolean success = studentDAO.resetPassword(email.trim(), newPassword.trim());
            if (success) {
                // Mock an email log for password reset
                LOGGER.info("=========================================");
                LOGGER.info("[MOCK EMAIL SYSTEM - PASSWORD RESET]");
                LOGGER.info("To: " + email);
                LOGGER.info("Message: Your password has been reset successfully to: " + newPassword);
                LOGGER.info("=========================================");

                session.setAttribute("successMsg", "Password reset successfully! Log in with your new credentials.");
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            } else {
                session.setAttribute("errorMsg", "Failed to update database records. Please try again.");
                response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp");
            }
        } else {
            session.setAttribute("errorMsg", "Email address not registered in our records.");
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp");
        }
    }

    private void sendOTPMock(Student student) {
        // Generate a 6-digit random code
        Random rand = new Random();
        int otpVal = 100000 + rand.nextInt(900000);
        String otpCode = String.valueOf(otpVal);
        
        // OTP valid for 5 minutes
        Timestamp expiry = new Timestamp(System.currentTimeMillis() + (5 * 60 * 1000));
        
        studentDAO.updateOTP(student.getId(), otpCode, expiry);

        // Standard mock logging showing clean outputs
        LOGGER.info("=========================================");
        LOGGER.info("[MOCK EMAIL SYSTEM - OTP VERIFICATION]");
        LOGGER.info("To: " + student.getEmail());
        LOGGER.info("Hi " + student.getFullName() + ",");
        LOGGER.info("Use verification code: " + otpCode + " to verify your college event portal account.");
        LOGGER.info("Note: This code expires in 5 minutes.");
        LOGGER.info("=========================================");
        
        // Also save last sent OTP code in system context for user simulation visibility
        getServletContext().setAttribute("lastSentOTP_" + student.getId(), otpCode);
    }
}
