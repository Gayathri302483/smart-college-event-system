<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Chatbot Floating Drawer UI Widget -->
<div class="chatbot-widget d-print-none">
    <!-- FAB Trigger -->
    <div class="chatbot-btn" id="chat-trigger" title="Ask College Event Assistant">
        <i class="bi bi-chat-dots-fill"></i>
    </div>
    
    <!-- Chatbot Window -->
    <div class="chatbot-window card-glass" id="chat-drawer">
        <div class="chatbot-header">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-robot" style="font-size: 1.2rem;"></i>
                <h6 class="mb-0 fw-bold">Event Assistant</h6>
            </div>
            <button type="button" class="btn-close btn-close-white" id="chat-close" aria-label="Close"></button>
        </div>
        
        <!-- Messages Area -->
        <div class="chatbot-messages" id="chat-pane">
            <div class="bot-msg">
                Hello there! I am your <strong>College Event Assistant</strong>. Ask me anything about upcoming events, workshops, registration guidelines, or certificates!
            </div>
        </div>
        
        <!-- Input Form -->
        <form class="chatbot-input-container" id="chat-form">
            <input type="text" id="chat-input" class="form-control form-control-glass flex-grow-1" placeholder="Type a message..." required autocomplete="off">
            <button type="submit" class="btn btn-primary d-flex align-items-center justify-content-center p-2" style="width: 40px; height: 40px; border-radius: 10px;">
                <i class="bi bi-send-fill"></i>
            </button>
        </form>
    </div>
</div>

<footer class="footer mt-auto py-4 border-top d-print-none" style="background: var(--bg-surface); backdrop-filter: var(--glass-blur); border-color: var(--border-color) !important;">
    <div class="container text-center">
        <p class="mb-1 fw-semibold">&copy; 2026 Smart College Event Management System. All Rights Reserved.</p>
        <span class="text-muted" style="font-size: 0.85rem;">Follow MVC &bull; Secure JDBC &bull; Integrated AI chatbot &bull; Responsive Design</span>
    </div>
</footer>

<!-- Bootstrap JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Global App Script -->
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>

<!-- Chatbot AJAX Assistant Script -->
<script src="${pageContext.request.contextPath}/static/js/chatbot.js"></script>
</body>
</html>
