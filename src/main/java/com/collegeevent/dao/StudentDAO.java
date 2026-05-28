package com.collegeevent.dao;

import com.collegeevent.model.Student;
import com.collegeevent.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StudentDAO {
    private static final Logger LOGGER = Logger.getLogger(StudentDAO.class.getName());

    /**
     * Registers a new student in the database.
     */
    public boolean registerStudent(Student student) {
        String sql = "INSERT INTO students (email, password, full_name, roll_number, department, phone, is_verified, otp_code, otp_expiry) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, student.getEmail());
            ps.setString(2, student.getPassword());
            ps.setString(3, student.getFullName());
            ps.setString(4, student.getRollNumber());
            ps.setString(5, student.getDepartment());
            ps.setString(6, student.getPhone());
            ps.setBoolean(7, student.isVerified());
            ps.setString(8, student.getOtpCode());
            ps.setTimestamp(9, student.getOtpExpiry());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error registering student with email: " + student.getEmail(), e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Validates a student login.
     */
    public Student validateStudent(String email, String password) {
        String sql = "SELECT * FROM students WHERE email = ? AND password = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                return extractStudentFromResultSet(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error validating student login: " + email, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Updates student profile details.
     */
    public boolean updateStudentProfile(Student student) {
        String sql = "UPDATE students SET full_name = ?, roll_number = ?, department = ?, phone = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, student.getFullName());
            ps.setString(2, student.getRollNumber());
            ps.setString(3, student.getDepartment());
            ps.setString(4, student.getPhone());
            ps.setInt(5, student.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile for student ID: " + student.getId(), e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Gets a student by email.
     */
    public Student getStudentByEmail(String email) {
        String sql = "SELECT * FROM students WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                return extractStudentFromResultSet(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting student by email: " + email, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Gets a student by ID.
     */
    public Student getStudentById(int id) {
        String sql = "SELECT * FROM students WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return extractStudentFromResultSet(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting student by ID: " + id, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * Updates/Generates OTP code for a student.
     */
    public boolean updateOTP(int studentId, String otpCode, Timestamp expiry) {
        String sql = "UPDATE students SET otp_code = ?, otp_expiry = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, otpCode);
            ps.setTimestamp(2, expiry);
            ps.setInt(3, studentId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating OTP for student ID: " + studentId, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Verifies OTP code. If correct and not expired, sets is_verified to 1.
     */
    public boolean verifyOTP(int studentId, String otpCode) {
        String sql = "SELECT otp_expiry FROM students WHERE id = ? AND otp_code = ?";
        String updateSql = "UPDATE students SET is_verified = 1, otp_code = NULL, otp_expiry = NULL WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setString(2, otpCode);
            rs = ps.executeQuery();

            if (rs.next()) {
                Timestamp expiry = rs.getTimestamp("otp_expiry");
                if (expiry != null && expiry.after(new Timestamp(System.currentTimeMillis()))) {
                    // OTP is valid, mark verified
                    PreparedStatement ups = conn.prepareStatement(updateSql);
                    ups.setInt(1, studentId);
                    int updated = ups.executeUpdate();
                    ups.close();
                    return updated > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying OTP for student ID: " + studentId, e);
        } finally {
            DBConnection.close(conn, ps, rs);
        }
        return false;
    }

    /**
     * Resets the password of a student.
     */
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE students SET password = ? WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setString(2, email);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error resetting password for student: " + email, e);
            return false;
        } finally {
            DBConnection.close(conn, ps);
        }
    }

    /**
     * Fetches all registered students.
     */
    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students ORDER BY created_at DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                students.add(extractStudentFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all students", e);
        } finally {
            DBConnection.close(conn, stmt, rs);
        }
        return students;
    }

    private Student extractStudentFromResultSet(ResultSet rs) throws SQLException {
        Student student = new Student();
        student.setId(rs.getInt("id"));
        student.setEmail(rs.getString("email"));
        student.setPassword(rs.getString("password"));
        student.setFullName(rs.getString("full_name"));
        student.setRollNumber(rs.getString("roll_number"));
        student.setDepartment(rs.getString("department"));
        student.setPhone(rs.getString("phone"));
        student.setVerified(rs.getBoolean("is_verified"));
        student.setOtpCode(rs.getString("otp_code"));
        student.setOtpExpiry(rs.getTimestamp("otp_expiry"));
        return student;
    }
}
