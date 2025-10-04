package com.sayhi.service;

import com.sayhi.model.FileInfo;
import com.sayhi.exception.FileException;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;

// Business logic, Implements Interface (Polymorphism)
@Service
public class FileServiceImpl implements FileService {
    private List<FileInfo> files = new ArrayList<>();

    @Override
    public List<FileInfo> listFiles() {
        return files;
    }

    @Override
    public FileInfo getFileByName(String name) {
        return files.stream()
                .filter(f -> f.getFileName().equals(name))
                .findFirst()
                .orElseThrow(() -> new FileException("File not found: " + name));
    }

    @Override
    public void uploadFile(FileInfo file) {
        files.add(file);
    }

    @Override
    public void deleteFile(String name) {
        files.removeIf(f -> f.getFileName().equals(name));
    }
}