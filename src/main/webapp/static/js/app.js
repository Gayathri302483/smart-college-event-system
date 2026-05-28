// Smart College Event Management System - Client Applications Logic

document.addEventListener("DOMContentLoaded", () => {
    // 1. Dark Mode State Controller
    initThemeController();

    // 2. Alert auto-dismiss timer
    initAlertDismissals();
});

/**
 * Initializes and manages dark theme preferences.
 */
function initThemeController() {
    const themeToggle = document.getElementById("theme-toggle");
    if (!themeToggle) return;

    // Check saved local preference or system preference
    const savedTheme = localStorage.getItem("theme");
    const systemPrefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    
    if (savedTheme === "dark" || (!savedTheme && systemPrefersDark)) {
        document.documentElement.setAttribute("data-theme", "dark");
        themeToggle.innerHTML = '<i class="bi bi-sun-fill"></i>'; // Sun icon
    } else {
        document.documentElement.removeAttribute("data-theme");
        themeToggle.innerHTML = '<i class="bi bi-moon-stars-fill"></i>'; // Moon icon
    }

    // Toggle Click Event Listener
    themeToggle.addEventListener("click", () => {
        const isDark = document.documentElement.getAttribute("data-theme") === "dark";
        
        if (isDark) {
            document.documentElement.removeAttribute("data-theme");
            localStorage.setItem("theme", "light");
            themeToggle.innerHTML = '<i class="bi bi-moon-stars-fill"></i>';
        } else {
            document.documentElement.setAttribute("data-theme", "dark");
            localStorage.setItem("theme", "dark");
            themeToggle.innerHTML = '<i class="bi bi-sun-fill"></i>';
        }
    });
}

/**
 * Automatically dismisses Bootstrap alerts after 5 seconds.
 */
function initAlertDismissals() {
    const alerts = document.querySelectorAll(".alert-dismissible");
    alerts.forEach(alert => {
        setTimeout(() => {
            // Check if alert still exists and fade it out
            if (alert) {
                alert.classList.remove("show");
                alert.classList.add("fade");
                setTimeout(() => alert.remove(), 150);
            }
        }, 5000);
    });
}

/**
 * Utility to validate form inputs.
 */
function validateRegistrationForm() {
    const password = document.getElementById("password").value;
    const confirm = document.getElementById("confirmPassword").value;
    const errorDiv = document.getElementById("validation-errors");

    if (password !== confirm) {
        if (errorDiv) {
            errorDiv.innerHTML = "Passwords do not match. Please verify.";
            errorDiv.classList.remove("d-none");
        }
        return false;
    }
    return true;
}
