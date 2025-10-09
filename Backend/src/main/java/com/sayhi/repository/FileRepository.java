package com.sayhi.repository;

import com.sayhi.model.FileInfo;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// JDBC CRUD Example for Files (H2 DB)
@Repository
public class FileRepository {
    private final String url = "jdbc:h2:mem:testdb";
    private final String user = "sa";
    private final String pass = "";

    public FileRepository() {
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS files (id INT AUTO_INCREMENT PRIMARY KEY, fileName VARCHAR(255), filePath VARCHAR(255), size BIGINT)");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void saveFile(FileInfo file) {
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement ps = conn.prepareStatement("INSERT INTO files (fileName, filePath, size) VALUES (?, ?, ?)")) {
            ps.setString(1, file.getFileName());
            ps.setString(2, file.getFilePath());
            ps.setLong(3, file.getSize());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<FileInfo> getAllFiles() {
        List<FileInfo> files = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery("SELECT * FROM files");
            while (rs.next()) {
                FileInfo file = new FileInfo();
                file.setId((long) rs.getInt("id"));
                file.setFileName(rs.getString("fileName"));
                file.setFilePath(rs.getString("filePath"));
                file.setSize(rs.getLong("size"));
                files.add(file);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return files;
    }
}