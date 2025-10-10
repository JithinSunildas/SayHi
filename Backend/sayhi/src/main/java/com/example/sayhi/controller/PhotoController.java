package com.example.sayhi.controller;

import com.example.sayhi.entity.Photo;
import com.example.sayhi.service.PhotoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/photos")
@CrossOrigin(origins = "*")
public class PhotoController {
    
    @Autowired
    private PhotoService photoService;
    
    @GetMapping
    public ResponseEntity<List<com.example.sayhi.model.Photo>> getAllPhotos(@RequestParam(required = false) String serverUrl) {
        List<Photo> photos = photoService.getAllPhotos();
        List<com.example.sayhi.model.Photo> photoModels = new ArrayList<>();
        
        for (Photo photo : photos) {
            String baseUrl = serverUrl != null ? serverUrl : "http://localhost:8080";
            String url = baseUrl + "/api/photos/" + photo.getId() + "/download";
            
            com.example.sayhi.model.Photo photoModel = new com.example.sayhi.model.Photo(
                photo.getId(),
                photo.getName(),
                url
            );
            photoModels.add(photoModel);
        }
        
        return ResponseEntity.ok(photoModels);
    }
    
    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadPhoto(@RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Photo photo = photoService.uploadPhoto(file);
            response.put("success", true);
            response.put("message", "Photo uploaded successfully");
            response.put("photoId", photo.getId());
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            response.put("success", false);
            response.put("message", "Failed to upload photo: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    @GetMapping("/{id}/download")
    public ResponseEntity<Resource> downloadPhoto(@PathVariable Long id) {
        Photo photo = photoService.getPhotoById(id);
        
        if (photo == null) {
            return ResponseEntity.notFound().build();
        }
        
        try {
            Path filePath = Paths.get(photo.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                            "attachment; filename=\"" + photo.getName() + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deletePhoto(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        boolean success = photoService.deletePhoto(id);
        
        if (success) {
            response.put("success", true);
            response.put("message", "Photo deleted successfully");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Photo not found");
            return ResponseEntity.notFound().build();
        }
    }
}
