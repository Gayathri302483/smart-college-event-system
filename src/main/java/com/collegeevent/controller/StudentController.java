package com.collegeevent.controller;

import com.collegeevent.dao.EventDAO;
import com.collegeevent.dao.NotificationDAO;
import com.collegeevent.dao.RegistrationDAO;
import com.collegeevent.dao.StudentDAO;
import com.collegeevent.model.Event;
import com.collegeevent.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/student/*")
public class StudentController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final StudentDAO studentDAO = new StudentDAO();
    private final EventDAO eventDAO = new EventDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if ("/notifications/readall".equals(pathInfo)) {
            handleReadAllNotifications(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/views/student/dashboard.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if ("/profile/update".equals(pathInfo)) {
            handleProfileUpdate(request, response);
        } else if ("/event/register".equals(pathInfo)) {
            handleEventRegistration(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/views/student/dashboard.jsp");
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Student currentStudent = (session != null) ? (Student) session.getAttribute("currentStudent") : null;

        if (currentStudent == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String fullName = request.getParameter("fullName");
        String rollNumber = request.getParameter("rollNumber");
        String department = request.getParameter("department");
        String phone = request.getParameter("phone");

        if (fullName == null || rollNumber == null || department == null || fullName.trim().isEmpty() || rollNumber.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Name, Roll Number, and Department are required fields.");
            response.sendRedirect(request.getContextPath() + "/views/student/profile.jsp");
            return;
        }

        currentStudent.setFullName(fullName.trim());
        currentStudent.setRollNumber(rollNumber.trim().toUpperCase());
        currentStudent.setDepartment(department.trim());
        currentStudent.setPhone(phone != null ? phone.trim() : "");

        boolean isUpdated = studentDAO.updateStudentProfile(currentStudent);

        if (isUpdated) {
            // Re-fetch updated profile from DB to keep session fully synchronised
            Student updatedStudent = studentDAO.getStudentById(currentStudent.getId());
            session.setAttribute("currentStudent", updatedStudent);
            
            notificationDAO.addNotification(updatedStudent.getId(), "Your profile details have been updated successfully.");
            session.setAttribute("successMsg", "Profile updated successfully!");
        } else {
            session.setAttribute("errorMsg", "Profile update failed. Ensure Roll Number is unique.");
        }
        response.sendRedirect(request.getContextPath() + "/views/student/profile.jsp");
    }

    private void handleEventRegistration(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Student currentStudent = (session != null) ? (Student) session.getAttribute("currentStudent") : null;

        if (currentStudent == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr == null || eventIdStr.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Invalid event reference.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
            return;
        }

        int eventId;
        try {
            eventId = Integer.parseInt(eventIdStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Invalid event ID format.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
            return;
        }

        Event event = eventDAO.getEventById(eventId);
        if (event == null) {
            session.setAttribute("errorMsg", "Event does not exist.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
            return;
        }

        // Check if student is already registered for this event
        if (registrationDAO.isRegistered(currentStudent.getId(), eventId)) {
            session.setAttribute("errorMsg", "You have already registered for this event! Check your dashboard.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
            return;
        }

        // Check seat capacity
        if (event.getAvailableSeats() <= 0) {
            session.setAttribute("errorMsg", "Sorry! Registration closed as all seats are fully booked.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
            return;
        }

        // Generate a beautiful unique QR Token
        String uniqueToken = "REG-" + currentStudent.getRollNumber().replace("/", "-") + "-" + eventId + "-" + UUID.randomUUID().toString().substring(0, 5).toUpperCase();

        boolean registered = registrationDAO.registerForEvent(currentStudent.getId(), eventId, uniqueToken);

        if (registered) {
            notificationDAO.addNotification(currentStudent.getId(), 
                "You registered for \"" + event.getTitle() + "\". Your registration is pending approval.");
            
            session.setAttribute("successMsg", "Successfully registered for \"" + event.getTitle() + "\"! Registration is pending coordinator approval.");
            response.sendRedirect(request.getContextPath() + "/views/student/registered-events.jsp");
        } else {
            session.setAttribute("errorMsg", "Registration failed. Please make sure seats are still available and try again.");
            response.sendRedirect(request.getContextPath() + "/views/student/events.jsp");
        }
    }

    private void handleReadAllNotifications(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Student currentStudent = (session != null) ? (Student) session.getAttribute("currentStudent") : null;

        if (currentStudent != null) {
            notificationDAO.markAllAsRead(currentStudent.getId());
        }
        
        response.sendRedirect(request.getContextPath() + "/views/student/notifications.jsp");
    }
}
