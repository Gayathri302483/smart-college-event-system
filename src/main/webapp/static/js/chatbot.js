// Smart College Event Management System - Chatbot UI Script

document.addEventListener("DOMContentLoaded", () => {
    initChatbotDrawer();
});

function initChatbotDrawer() {
    const chatBtn = document.getElementById("chat-trigger");
    const chatWindow = document.getElementById("chat-drawer");
    const closeBtn = document.getElementById("chat-close");
    const chatForm = document.getElementById("chat-form");
    const chatInput = document.getElementById("chat-input");
    const chatMessages = document.getElementById("chat-pane");

    if (!chatBtn || !chatWindow || !chatForm || !chatInput || !chatMessages) return;

    // Toggle Chat Panel
    chatBtn.addEventListener("click", () => {
        chatWindow.classList.toggle("active");
        if (chatWindow.classList.contains("active")) {
            chatInput.focus();
            // Scroll to bottom of messages
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
    });

    if (closeBtn) {
        closeBtn.addEventListener("click", () => {
            chatWindow.classList.remove("active");
        });
    }

    // Submit User Message
    chatForm.addEventListener("submit", (e) => {
        e.preventDefault();
        
        const messageText = chatInput.value.trim();
        if (messageText === "") return;

        // 1. Append User Message
        appendMessage("user", messageText);
        chatInput.value = "";

        // 2. Add Loading Indicator
        const loadingId = appendLoadingIndicator();
        chatMessages.scrollTop = chatMessages.scrollHeight;

        // 3. Post to Chatbot Servlet via AJAX
        // Using form URL encoding standard to match standardgetParameter() in Java
        const params = new URLSearchParams();
        params.append("query", messageText);

        const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2)) || "";

        fetch(`${contextPath}/chatbot`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params
        })
        .then(response => {
            if (!response.ok) {
                throw new Error("Network response error");
            }
            return response.json();
        })
        .then(data => {
            // Remove loading indicator
            removeLoadingIndicator(loadingId);

            // Append Bot Response Text
            // Replace markdown formatting with HTML bold/lists for clean displays
            const formattedReply = formatMarkdownText(data.reply);
            appendMessage("bot", formattedReply);

            // If bot returns live database events matching query, render them as cards
            if (data.hasEvents && data.events) {
                appendEventCards(data.events, contextPath);
            }

            chatMessages.scrollTop = chatMessages.scrollHeight;
        })
        .catch(err => {
            removeLoadingIndicator(loadingId);
            appendMessage("bot", "Oops! I seem to have trouble reaching the college event catalog. Please try again shortly.");
            chatMessages.scrollTop = chatMessages.scrollHeight;
            console.error("Chatbot Fetch Error:", err);
        });
    });

    function appendMessage(sender, text) {
        const msgDiv = document.createElement("div");
        msgDiv.className = sender === "user" ? "user-msg" : "bot-msg";
        msgDiv.innerHTML = text;
        chatMessages.appendChild(msgDiv);
    }

    function appendLoadingIndicator() {
        const loadingId = "loader_" + Date.now();
        const loadingDiv = document.createElement("div");
        loadingDiv.id = loadingId;
        loadingDiv.className = "bot-msg text-muted";
        loadingDiv.innerHTML = '<span class="spinner-grow spinner-grow-sm" role="status"></span> Thinking...';
        chatMessages.appendChild(loadingDiv);
        return loadingId;
    }

    function removeLoadingIndicator(id) {
        const loader = document.getElementById(id);
        if (loader) loader.remove();
    }

    function formatMarkdownText(text) {
        if (!text) return "";
        let html = text;
        
        // Bold formatting
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        
        // List formatting
        html = html.replace(/\n\*\s(.*?)/g, '<br>• $1');
        html = html.replace(/\n-\s(.*?)/g, '<br>• $1');
        
        // Simple linebreaks
        html = html.replace(/\n/g, '<br>');
        
        return html;
    }

    function appendEventCards(events, contextPath) {
        const listDiv = document.createElement("div");
        listDiv.className = "bot-msg card-glass p-2 d-flex flex-column gap-2 border-0 bg-transparent w-100";
        listDiv.style.alignSelf = "flex-start";

        events.forEach(evt => {
            const cardLink = document.createElement("a");
            cardLink.href = `${contextPath}/index.jsp?search=${encodeURIComponent(evt.title)}`;
            cardLink.className = "text-decoration-none text-reset";
            
            cardLink.innerHTML = `
                <div class="card card-glass overflow-hidden" style="max-width: 250px; font-size: 0.8rem;">
                    <div style="height: 80px; overflow: hidden;">
                        <img src="${evt.posterUrl}" class="w-100 h-100" style="object-fit: cover;">
                    </div>
                    <div class="card-body p-2">
                        <span class="badge bg-primary mb-1" style="font-size: 0.6rem;">${evt.category}</span>
                        <h6 class="card-title mb-1 fw-bold" style="font-size: 0.85rem;">${evt.title}</h6>
                        <p class="card-text text-muted mb-0"><i class="bi bi-geo-alt"></i> ${evt.venue}</p>
                    </div>
                </div>
            `;
            listDiv.appendChild(cardLink);
        });

        chatMessages.appendChild(listDiv);
    }
}
