package com.sayhi.model;

// Inheritance, Encapsulation
public class FileInfo extends BaseEntity {
    private String fileName;
    private String filePath;
    private long size;

    public FileInfo() {}

    public FileInfo(String fileName, String filePath, long size) {
        this.fileName = fileName;
        this.filePath = filePath;
        this.size = size;
    }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    public long getSize() { return size; }
    public void setSize(long size) { this.size = size; }
}