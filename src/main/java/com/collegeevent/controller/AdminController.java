package com.collegeevent.controller;

import com.collegeevent.dao.AdminDAO;
import com.collegeevent.dao.EventDAO;
import com.collegeevent.dao.NotificationDAO;
import com.collegeevent.dao.RegistrationDAO;
import com.collegeevent.model.Admin;
import com.collegeevent.model.Event;
import com.collegeevent.model.Registration;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/admin/*")
public class AdminController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final EventDAO eventDAO = new EventDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if ("/event/delete".equals(pathInfo)) {
            handleDeleteEvent(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/views/admin/dashboard.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if ("/event/create".equals(pathInfo)) {
            handleCreateEvent(request, response);
        } else if ("/event/update".equals(pathInfo)) {
            handleUpdateEvent(request, response);
        } else if ("/registration/status".equals(pathInfo)) {
            handleRegistrationStatus(request, response);
        } else if ("/registration/attendance".equals(pathInfo)) {
            handleRegistrationAttendance(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/views/admin/dashboard.jsp");
        }
    }

    private void handleCreateEvent(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Admin currentAdmin = (session != null) ? (Admin) session.getAttribute("currentAdmin") : null;

        if (currentAdmin == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String eventDateStr = request.getParameter("eventDate");
        String venue = request.getParameter("venue");
        String seatLimitStr = request.getParameter("seatLimit");
        String posterUrl = request.getParameter("posterUrl");

        if (title == null || category == null || eventDateStr == null || venue == null || seatLimitStr == null || title.trim().isEmpty()) {
            session.setAttribute("errorMsg", "All fields are required to create an event.");
            response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp");
            return;
        }

        int seatLimit = 100;
        try {
            seatLimit = Integer.parseInt(seatLimitStr.trim());
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Seat limit must be a positive number.");
            response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp");
            return;
        }

        Timestamp eventDate;
        try {
            // Support datetime-local format from HTML5 forms: yyyy-MM-dd'T'HH:mm
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(eventDateStr);
            eventDate = new Timestamp(date.getTime());
        } catch (ParseException e) {
            try {
                // Fallback to simple date-time format if customized
                SimpleDateFormat sdfFallback = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                Date date = sdfFallback.parse(eventDateStr);
                eventDate = new Timestamp(date.getTime());
            } catch (ParseException ex) {
                session.setAttribute("errorMsg", "Invalid Event Date format. Please use the date picker.");
                response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp");
                return;
            }
        }

        // Set high-quality generic stock photo fallback if poster URL is empty
        if (posterUrl == null || posterUrl.trim().isEmpty()) {
            posterUrl = "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop&q=60";
        }

        Event event = new Event();
        event.setTitle(title.trim());
        event.setDescription(description != null ? description.trim() : "");
        event.setCategory(category);
        event.setEventDate(eventDate);
        event.setVenue(venue.trim());
        event.setSeatLimit(seatLimit);
        event.setPosterUrl(posterUrl.trim());
        event.setCreatedBy(currentAdmin.getId());

        boolean created = eventDAO.createEvent(event);

        if (created) {
            session.setAttribute("successMsg", "Event created successfully!");
            response.sendRedirect(request.getContextPath() + "/views/admin/events.jsp");
        } else {
            session.setAttribute("errorMsg", "Failed to create event. Please verify inputs.");
            response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp");
        }
    }

    private void handleUpdateEvent(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String eventDateStr = request.getParameter("eventDate");
        String venue = request.getParameter("venue");
        String seatLimitStr = request.getParameter("seatLimit");
        String posterUrl = request.getParameter("posterUrl");

        if (eventIdStr == null || title == null || category == null || eventDateStr == null || venue == null || seatLimitStr == null) {
            session.setAttribute("errorMsg", "All fields are required to update an event.");
            response.sendRedirect(request.getContextPath() + "/views/admin/events.jsp");
            return;
        }

        int eventId = Integer.parseInt(eventIdStr.trim());
        int seatLimit = Integer.parseInt(seatLimitStr.trim());

        Timestamp eventDate;
        try {
            // datetime-local support
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(eventDateStr);
            eventDate = new Timestamp(date.getTime());
        } catch (ParseException e) {
            try {
                SimpleDateFormat sdfFallback = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                Date date = sdfFallback.parse(eventDateStr);
                eventDate = new Timestamp(date.getTime());
            } catch (ParseException ex) {
                session.setAttribute("errorMsg", "Invalid Event Date format.");
                response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp?id=" + eventId);
                return;
            }
        }

        if (posterUrl == null || posterUrl.trim().isEmpty()) {
            posterUrl = "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop&q=60";
        }

        Event event = new Event();
        event.setId(eventId);
        event.setTitle(title.trim());
        event.setDescription(description != null ? description.trim() : "");
        event.setCategory(category);
        event.setEventDate(eventDate);
        event.setVenue(venue.trim());
        event.setSeatLimit(seatLimit);
        event.setPosterUrl(posterUrl.trim());

        boolean updated = eventDAO.updateEvent(event);

        if (updated) {
            session.setAttribute("successMsg", "Event updated successfully!");
            response.sendRedirect(request.getContextPath() + "/views/admin/events.jsp");
        } else {
            session.setAttribute("errorMsg", "Failed to update event.");
            response.sendRedirect(request.getContextPath() + "/views/admin/event-form.jsp?id=" + eventId);
        }
    }

    private void handleDeleteEvent(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        String eventIdStr = request.getParameter("id");
        if (eventIdStr != null) {
            try {
                int eventId = Integer.parseInt(eventIdStr.trim());
                boolean deleted = eventDAO.deleteEvent(eventId);
                if (deleted) {
                    session.setAttribute("successMsg", "Event deleted successfully!");
                } else {
                    session.setAttribute("errorMsg", "Failed to delete event.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMsg", "Invalid event ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/views/admin/events.jsp");
    }

    private void handleRegistrationStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        String regIdStr = request.getParameter("regId");
        String status = request.getParameter("status"); // APPROVED or REJECTED

        if (regIdStr == null || status == null) {
            session.setAttribute("errorMsg", "Incomplete parameters for status update.");
            response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
            return;
        }

        int regId = Integer.parseInt(regIdStr.trim());
        Registration reg = registrationDAO.getRegistrationById(regId);

        if (reg == null) {
            session.setAttribute("errorMsg", "Registration record not found.");
            response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
            return;
        }

        boolean updated = registrationDAO.updateRegistrationStatus(regId, status.toUpperCase());

        if (updated) {
            String msg = status.equalsIgnoreCase("APPROVED") 
                ? "Your registration for \"" + reg.getEventTitle() + "\" has been APPROVED! 🥳 Check details on your dashboard."
                : "Your registration for \"" + reg.getEventTitle() + "\" has been REJECTED by the coordinator.";
            
            notificationDAO.addNotification(reg.getStudentId(), msg);
            session.setAttribute("successMsg", "Registration " + status.toLowerCase() + " successfully!");
        } else {
            session.setAttribute("errorMsg", "Failed to update status. Make sure seats are still available to approve registrations.");
        }
        response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
    }

    private void handleRegistrationAttendance(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/admin-login.jsp");
            return;
        }

        String regIdStr = request.getParameter("regId");
        String attendance = request.getParameter("attendance"); // PRESENT or ABSENT

        if (regIdStr == null || attendance == null) {
            session.setAttribute("errorMsg", "Incomplete parameters for attendance marking.");
            response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
            return;
        }

        int regId = Integer.parseInt(regIdStr.trim());
        Registration reg = registrationDAO.getRegistrationById(regId);

        if (reg == null) {
            session.setAttribute("errorMsg", "Registration record not found.");
            response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
            return;
        }

        boolean updated = registrationDAO.updateAttendance(regId, attendance.toUpperCase());

        if (updated) {
            if (attendance.equalsIgnoreCase("PRESENT")) {
                notificationDAO.addNotification(reg.getStudentId(), 
                    "🎓 Attendance marked: PRESENT for \"" + reg.getEventTitle() + "\". Your participation certificate is now available to download!");
            }
            session.setAttribute("successMsg", "Attendance marked as " + attendance.toLowerCase() + " successfully!");
        } else {
            session.setAttribute("errorMsg", "Failed to update attendance records.");
        }
        response.sendRedirect(request.getContextPath() + "/views/admin/registrations.jsp");
    }
}
