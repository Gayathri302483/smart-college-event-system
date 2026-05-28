# Smart College Event Management System 🎓

An ultra-modern, full-stack, enterprise-grade Java JEE web application built following the **Model-View-Controller (MVC)** architecture. This portal allows college students to browse, search, and register for various events (hackathons, workshops, seminars, technical fests), verify their accounts via OTP, track their attendance, and claim dynamically generated verification certificates.

---

## 🛠️ Tech Stack & Key Features
- **Backend Core**: Java JEE Servlets (Controllers) & JSPs (Views) with JSTL standard tags.
- **Database Connection**: Safe JDBC API connectivity with connection resource pools.
- **Role-Based Access Control (RBAC)**: Servlet Filters protecting student and admin routes.
- **Modern Responsive UI**: Clean glassmorphism styling utilizing custom CSS variables, Bootstrap 5.3, and custom transition micro-animations.
- **Dark Mode**: Integrated visual toggles persisting settings across sessions using local storage.
- **Dynamic Chart Analytics**: Admin dashboard visualizing active registrations using Chart.js.
- **QR Code & Dynamic Tickets**: Printable ticket receipts embedding unique scan codes generated via client JS matrix engines.
- **Interactive AI Chatbot**: Floating client chat drawer answering database queries dynamically via an offline Java-backed text parser.
- **Dynamic PDF Certificates**: Elegant print-friendly landscape completion certificates that students can directly save as PDFs via browser printing actions.

---

## 📂 Project Directory Structure
```
smart-college-event-system/
├── pom.xml                        # Maven configuration dependencies
├── schema.sql                     # Normalized MySQL database schema & seeding data
├── README.md                      # Setup and deployment manual
└── src/
    └── main/
        ├── java/
        │   └── com/
        │       └── collegeevent/
        │           ├── controller/
        │           │   ├── AuthController.java     # Manages registers, logins, OTP matching
        │           │   ├── StudentController.java  # Manages student updates & event bookings
        │           │   ├── AdminController.java    # Manages event CRUD & approvals
        │           │   ├── ChatbotServlet.java     # Offline rule-based chatbot AI
        │           │   └── EventApiServlet.java    # REST API endpoints returning JSON
        │           ├── dao/
        │           │   ├── StudentDAO.java         # JDBC queries for students
        │           │   ├── AdminDAO.java           # JDBC queries for admins
        │           │   ├── EventDAO.java           # JDBC queries for events & stats
        │           │   └── RegistrationDAO.java    # Safe transactional registrations & seat counts
        │           ├── filter/
        │           │   └── AuthFilter.java         # RBAC session security filter
        │           ├── model/
        │           │   ├── Student.java            # Student POJO
        │           │   ├── Admin.java              # Admin POJO
        │           │   ├── Event.java              # Event POJO
        │           │   └── Registration.java       # Registration POJO
        │           └── util/
        │               └── DBConnection.java       # Thread-safe JDBC connections loader
        ├── resources/
        │   └── db.properties              # Database credentials configuration
        └── webapp/
            ├── WEB-INF/
            │   └── web.xml                # Deployment descriptor configuration
            ├── static/
            │   ├── css/
            │   │   └── style.css          # Glassmorphic responsive dark theme stylesheets
            │   └── js/
            │       ├── app.js             # General theme toggling & common validation helpers
            │       └── chatbot.js         # Chatbot drawers & AJAX fetches
            ├── views/
            │   ├── common/
            │   │   ├── header.jsp         # Header inclusions
            │   │   ├── navbar.jsp         # Contextual header navigation
            │   │   ├── sidebar.jsp        # Dashboard left navigation drawer
            │   │   └── footer.jsp         # Persistent chatbot layout and footer
            │   ├── auth/
            │   │   ├── login.jsp          # Student login
            │   │   ├── register.jsp       # Enrollment signups
            │   │   ├── admin-login.jsp    # Administrator panel entry
            │   │   ├── forgot-password.jsp# Password recovery form
            │   │   └── verify-otp.jsp     # OTP verification panel with developer testing widget
            │   ├── student/
            │   │   ├── dashboard.jsp      # Student overview stats counters
            │   │   ├── events.jsp         # Paginated catalog search and category filters
            │   │   ├── registered-events.jsp# Registrations list & certificate locks
            │   │   ├── profile.jsp        # Account settings update
            │   │   ├── notifications.jsp  # Notification alerts list
            │   │   ├── receipt.jsp        # Printable tickets with dynamic QR codes
            │   │   └── certificate.jsp    # Completion certificate
            │   └── admin/
            │       ├── dashboard.jsp      # Analytical Chart.js charts overview
            │       ├── events.jsp         # Catalog event records manager table
            │       ├── event-form.jsp     # Dual-purpose Create / Edit form
            │       ├── registrations.jsp  # Seat validation approvals & attendance toggles
            │       └── students.jsp       # Students records database
            └── index.jsp                  # Search-optimized landing home page
```

---

## ⚡ Setup & Execution Manual

### 1. Database Initialization
1. Make sure you have **MySQL Server** installed and running on your system.
2. Log into the MySQL command line:
   ```bash
   mysql -u root -p
   ```
3. Run the database schema initialization script:
   ```sql
   source C:/Users/gayat/.gemini/antigravity/scratch/smart-college-event-system/schema.sql;
   ```
   *(This creates the `college_event_db` database, sets up all normalized indexes, and seeds pre-loaded events, admins, and verified/unverified test student accounts).*

4. Open the `src/main/resources/db.properties` file and customize the database credentials if your local username/password differs:
   ```properties
   db.username=root
   db.password=password   # Change this to match your local MySQL root password
   ```

---

### 2. Compile and Package with Maven
1. Open your terminal at the root folder of the project (`C:\Users\gayat\.gemini\antigravity\scratch\smart-college-event-system`).
2. Compile, validate, and package the JEE project into a `.war` file:
   ```bash
   mvn clean package
   ```
3. Once completed successfully, a file named `smart-college-event-system.war` will be compiled inside the `target/` directory.

---

### 3. Deploying to Apache Tomcat
1. Download and extract **Apache Tomcat 9** (or Tomcat 10) on your local system.
2. Copy the compiled `.war` file:
   - Copy `target/smart-college-event-system.war`
   - Paste it inside the `webapps/` folder of your Apache Tomcat installation path.
3. Start the Apache Tomcat server:
   - Open a shell in the Tomcat directory and execute:
     - Windows: `bin/startup.bat`
     - macOS/Linux: `bin/startup.sh`
4. Access the web application in your browser:
   ```url
   http://localhost:8080/smart-college-event-system/
   ```

---

## 🔑 Test Credentials & Verification Simulation

For immediate manual verification and demonstration, you can log in using these pre-seeded credentials:

### 1. Administrator Console
- **Login Page**: Click "Admin Login" in the navbar or go directly to `/views/auth/admin-login.jsp`
- **Username**: `admin`
- **Password**: `admin123`
*Allows creating/updating/deleting events, reviewing student applications, toggling attendance logs, and viewing analytical statistics.*

### 2. Pre-Verified Student (Instant Ticket & Certificate Demo)
- **Email**: `amit.sharma@student.edu`
- **Password**: `password123`
*Amit Sharma is pre-registered for the "Inter-College Hackathon 2026" with registration APPROVED and attendance marked as PRESENT. Logging in as Amit allows you to immediately open "My Registrations" and download his gorgeous dynamic receipt ticket and claim his official certificate!*

### 3. Unverified Student (OTP Signup Flow Demo)
- **Email**: `sneha.sen@student.edu`
- **Password**: `password123`
- **Simulation Helper**: When logging in as Sneha, the system intercepts the request and routes her to the OTP verification page. Since Sneha's email client is simulated, a **Developer Test Helper widget** will appear on her screen displaying her live generated verification code. Simply copy-paste it into the field to instantly unlock her account!
