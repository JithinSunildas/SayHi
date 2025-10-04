package com.sayhi.model;

import java.util.ArrayList;
import java.util.List;

// Inheritance, Encapsulation, Built-in List
public class User extends BaseEntity {
    private String username;
    private String password;
    private List<FileInfo> files = new ArrayList<>();

    public User() {}
    public User(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public List<FileInfo> getFiles() { return files; }
    public void setFiles(List<FileInfo> files) { this.files = files; }
}