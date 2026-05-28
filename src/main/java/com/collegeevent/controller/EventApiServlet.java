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

@WebServlet("/api/events")
public class EventApiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final EventDAO eventDAO = new EventDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Enable CORS (Cross-Origin Resource Sharing)
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");

        String search = request.getParameter("search");
        String category = request.getParameter("category");
        
        int limit = 10;
        int offset = 0;

        try {
            String limitParam = request.getParameter("limit");
            if (limitParam != null) {
                limit = Integer.parseInt(limitParam);
            }
        } catch (NumberFormatException e) {
            // keep default
        }

        try {
            String offsetParam = request.getParameter("offset");
            if (offsetParam != null) {
                offset = Integer.parseInt(offsetParam);
            }
        } catch (NumberFormatException e) {
            // keep default
        }

        List<Event> events = eventDAO.searchAndFilterEvents(search, category, limit, offset);
        int totalCount = eventDAO.getTotalEventsCount(search, category);

        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("success", true);
        jsonResponse.put("totalCount", totalCount);
        jsonResponse.put("limit", limit);
        jsonResponse.put("offset", offset);
        jsonResponse.put("events", events);

        PrintWriter out = response.getWriter();
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}
