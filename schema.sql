-- Smart College Event Management System Database Schema
-- Compatible with MySQL 5.7+ and 8.0+

CREATE DATABASE IF NOT EXISTS college_event_db;
USE college_event_db;

-- 1. Admins Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Stored as bcrypt hash or simple secure string
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Students Table
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    roll_number VARCHAR(20) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    is_verified TINYINT(1) DEFAULT 0,
    otp_code VARCHAR(6) DEFAULT NULL,
    otp_expiry TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Events Table
CREATE TABLE IF NOT EXISTS events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- Technical, Cultural, Workshop, Seminar, Hackathon
    event_date DATETIME NOT NULL,
    venue VARCHAR(150) NOT NULL,
    seat_limit INT NOT NULL DEFAULT 100,
    available_seats INT NOT NULL,
    poster_url VARCHAR(255) DEFAULT NULL,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL,
    INDEX idx_event_category (category),
    INDEX idx_event_date (event_date)
);

-- 4. Registrations Table
CREATE TABLE IF NOT EXISTS registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    attendance VARCHAR(20) DEFAULT 'ABSENT', -- ABSENT, PRESENT
    qr_code_token VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE KEY uq_student_event (student_id, event_id)
);

-- 5. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- SEED DATA SETUP

-- 1. Default Admin Credentials
-- Plain Password: admin123 (For easy local testing, stored as plaintext/hashed in application checks)
INSERT INTO admins (username, password, full_name, email)
VALUES ('admin', 'admin123', 'Prof. Rajesh Kumar', 'admin@college.edu')
ON DUPLICATE KEY UPDATE id=id;

-- 2. Sample Verified Students
-- Plain Password: password123
INSERT INTO students (email, password, full_name, roll_number, department, phone, is_verified)
VALUES 
('amit.sharma@student.edu', 'password123', 'Amit Sharma', 'CS2023001', 'Computer Science', '9876543210', 1),
('priya.patel@student.edu', 'password123', 'Priya Patel', 'EC2023042', 'Electronics', '9876543211', 1),
('rohan.das@student.edu', 'password123', 'Rohan Das', 'ME2023015', 'Mechanical', '9876543212', 1),
('sneha.sen@student.edu', 'password123', 'Sneha Sen', 'IT2023009', 'Information Technology', '9876543213', 0) -- Unverified student to test OTP
ON DUPLICATE KEY UPDATE id=id;

-- 3. Predefined Event Catalog (across categories)
INSERT INTO events (title, description, category, event_date, venue, seat_limit, available_seats, poster_url, created_by)
VALUES
('Inter-College Hackathon 2026', 'A massive 36-hour hackathon to solve real-world problems in smart cities, healthcare, and education. Cash prizes up to $5,000!', 'Hackathon', '2026-06-15 09:00:00', 'Main Auditorium & CS Labs', 120, 118, 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&auto=format&fit=crop&q=60', 1),

('National Seminar on AI Ethics', 'Join industry pioneers and academic experts discussing the future of AI alignment, ethical safety frameworks, and regulation.', 'Seminar', '2026-06-20 14:00:00', 'Seminar Hall 3', 80, 80, 'https://images.unsplash.com/photo-1591453089816-0fbb971b454c?w=800&auto=format&fit=crop&q=60', 1),

('Web Development Bootcamp', 'Hands-on intensive workshop covering HTML5, CSS Grid/Flexbox, JavaScript ES6+, and modern frontend libraries like React.', 'Workshop', '2026-06-25 10:00:00', 'IT Center, Lab 2', 45, 43, 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&auto=format&fit=crop&q=60', 1),

('Rhythm 2026 - Cultural Festival', 'Annual college cultural evening featuring stellar performances in Indian classical dance, fusion music, battle of bands, and drama.', 'Cultural', '2026-07-02 18:00:00', 'Open Air Theatre', 500, 499, 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=60', 1),

('RoboQuest: Technical Design Challenge', 'Design and program an autonomous rover to complete a complex obstacle track in the minimum amount of time.', 'Technical', '2026-07-10 11:00:00', 'Robotics Innovation Center', 30, 30, 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&auto=format&fit=crop&q=60', 1)
ON DUPLICATE KEY UPDATE id=id;

-- 4. Initial Seed Registrations
-- Amit Sharma (id=1) registered for Hackathon (id=1) - Approved & Attended (to check certificate downloading)
INSERT INTO registrations (student_id, event_id, status, attendance, qr_code_token)
VALUES (1, 1, 'APPROVED', 'PRESENT', 'REG-AMIT-HACK-001')
ON DUPLICATE KEY UPDATE id=id;

-- Priya Patel (id=2) registered for Web Dev Bootcamp (id=3) - Approved but not marked present yet
INSERT INTO registrations (student_id, event_id, status, attendance, qr_code_token)
VALUES (2, 3, 'APPROVED', 'ABSENT', 'REG-PRIYA-BOOT-003')
ON DUPLICATE KEY UPDATE id=id;

-- Rohan Das (id=3) registered for Cultural Festival (id=4) - Pending Approval
INSERT INTO registrations (student_id, event_id, status, attendance, qr_code_token)
VALUES (3, 4, 'PENDING', 'ABSENT', 'REG-ROHAN-CULT-004')
ON DUPLICATE KEY UPDATE id=id;

-- 5. Seed Notifications
INSERT INTO notifications (student_id, message, is_read)
VALUES
(1, 'Welcome to Smart College Event Portal! Complete your profile to stay updated.', 1),
(1, 'Your registration for "Inter-College Hackathon 2026" has been APPROVED! See you at the main auditorium.', 0),
(2, 'Your registration for "Web Development Bootcamp" has been APPROVED! Make sure to bring your laptop.', 0),
(3, 'Your registration for "Rhythm 2026 - Cultural Festival" is pending admin approval.', 0)
ON DUPLICATE KEY UPDATE id=id;
