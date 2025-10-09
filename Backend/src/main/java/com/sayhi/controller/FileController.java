package com.sayhi.controller;

import com.sayhi.model.FileInfo;
import com.sayhi.service.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

// REST Controller for files (routing, HTTP requests)
@RestController
@RequestMapping("/files")
public class FileController {

    @Autowired
    private FileService fileService;

    @GetMapping
    public List<FileInfo> getFiles() {
        return fileService.listFiles();
    }

    @GetMapping("/{name}")
    public FileInfo getFile(@PathVariable String name) {
        return fileService.getFileByName(name);
    }

    @PostMapping
    public String uploadFile(@RequestBody FileInfo file) {
        fileService.uploadFile(file);
        return "File uploaded: " + file.getFileName();
    }

    @DeleteMapping("/{name}")
    public String deleteFile(@PathVariable String name) {
        fileService.deleteFile(name);
        return "File deleted: " + name;
    }
}