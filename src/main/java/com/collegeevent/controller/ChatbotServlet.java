package com.collegeevent.controller;

import com.collegeevent.dao.EventDAO;
import com.collegeevent.model.Event;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/chatbot")
public class ChatbotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final EventDAO eventDAO = new EventDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String query = request.getParameter("query");
        Map<String, Object> jsonResponse = new HashMap<>();

        if (query == null || query.trim().isEmpty()) {
            jsonResponse.put("reply", "Hello! Please ask me a question about college events.");
            writeResponse(response, jsonResponse);
            return;
        }

        String userQuery = query.toLowerCase().trim();
        String replyText;
        boolean hasEvents = false;
        List<Event> matchingEvents = null;

        // 1. Check for Category-Specific Queries
        if (userQuery.contains("hackathon")) {
            matchingEvents = eventDAO.searchAndFilterEvents("", "Hackathon", 5, 0);
            replyText = "Here are the active **Hackathons** in our system:";
            hasEvents = !matchingEvents.isEmpty();
        } else if (userQuery.contains("workshop")) {
            matchingEvents = eventDAO.searchAndFilterEvents("", "Workshop", 5, 0);
            replyText = "Here are the active **Workshops** scheduled:";
            hasEvents = !matchingEvents.isEmpty();
        } else if (userQuery.contains("seminar")) {
            matchingEvents = eventDAO.searchAndFilterEvents("", "Seminar", 5, 0);
            replyText = "Here are the upcoming **Seminars**:";
            hasEvents = !matchingEvents.isEmpty();
        } else if (userQuery.contains("technical") || userQuery.contains("tech")) {
            matchingEvents = eventDAO.searchAndFilterEvents("", "Technical", 5, 0);
            replyText = "Here are our high-impact **Technical Events**:";
            hasEvents = !matchingEvents.isEmpty();
        } else if (userQuery.contains("cultural") || userQuery.contains("cult")) {
            matchingEvents = eventDAO.searchAndFilterEvents("", "Cultural", 5, 0);
            replyText = "Here are our vibrant **Cultural Events**:";
            hasEvents = !matchingEvents.isEmpty();
        } 
        // 2. Check for General Upcoming Events
        else if (userQuery.contains("upcoming") || userQuery.contains("events") || userQuery.contains("show me events") || userQuery.contains("list")) {
            matchingEvents = eventDAO.getUpcomingEvents(5);
            replyText = "Here are the top upcoming events at the college:";
            hasEvents = !matchingEvents.isEmpty();
        } 
        // 3. How to Register
        else if (userQuery.contains("register") || userQuery.contains("how to apply") || userQuery.contains("join")) {
            replyText = "To register for any event, please follow these steps:\n" +
                        "1. **Log in** to your student account.\n" +
                        "2. Head over to the **Events Catalog**.\n" +
                        "3. Find the event card and click **Register Now**.\n" +
                        "4. Your registration will sit under **Pending Approval** until the coordinator approves it. You can check status on your dashboard!";
        } 
        // 4. Certificates Queries
        else if (userQuery.contains("certificate") || userQuery.contains("receipt") || userQuery.contains("download")) {
            replyText = "🎓 **Participation Certificates**:\n" +
                        "Certificates are unlocked dynamically! You can download them from your **Registered Events** list under the following conditions:\n" +
                        "1. Your registration status has been **APPROVED** by the admin.\n" +
                        "2. Your attendance has been marked as **PRESENT** after the event concludes.\n\n" +
                        "🎫 **Receipts** can be printed instantly after registration directly from your registered events tab!";
        } 
        // 5. Help / Support Contacts
        else if (userQuery.contains("help") || userQuery.contains("support") || userQuery.contains("contact") || userQuery.contains("admin")) {
            replyText = "Need support? 📞\n" +
                        "- **Email Support**: admin@college.edu\n" +
                        "- **Office Location**: Academic Block A, Room 102 (Event Management Dept)\n" +
                        "- **Hours**: Mon-Fri, 9:00 AM - 5:00 PM\n" +
                        "Please drop by or email us if you face any issues with registration approvals or seat counts.";
        } 
        // 6. Generic Greeting
        else if (userQuery.contains("hi") || userQuery.contains("hello") || userQuery.contains("hey")) {
            replyText = "Hello! I am your **College Event Assistant**. How can I help you today? You can ask me about:\n" +
                        "- Upcoming events\n" +
                        "- Technical events, Hackathons, or Workshops\n" +
                        "- How to register for an event\n" +
                        "- Downloading certificates";
        } 
        // 7. Default Matcher
        else {
            replyText = "I'm not sure I understand that query. 😅\n\n" +
                        "Try asking me things like:\n" +
                        "👉 *Show upcoming events*\n" +
                        "👉 *List all hackathons*\n" +
                        "👉 *How do I register?*\n" +
                        "👉 *How to download event certificates?*";
        }

        jsonResponse.put("reply", replyText);
        jsonResponse.put("hasEvents", hasEvents);
        if (hasEvents) {
            jsonResponse.put("events", matchingEvents);
        }

        writeResponse(response, jsonResponse);
    }

    private void writeResponse(HttpServletResponse response, Map<String, Object> data) throws IOException {
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }
}
