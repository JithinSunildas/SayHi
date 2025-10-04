package com.sayhi.service;

import com.sayhi.model.FileInfo;
import java.util.List;

// Interface for file operations
public interface FileService {
    List<FileInfo> listFiles();
    FileInfo getFileByName(String name);
    void uploadFile(FileInfo file);
    void deleteFile(String name);
}