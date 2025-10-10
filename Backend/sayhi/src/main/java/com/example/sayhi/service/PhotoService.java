package com.example.sayhi.service;

import com.example.sayhi.entity.Photo;
import com.example.sayhi.repository.PhotoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Service
public class PhotoService {
    
    @Autowired
    private PhotoRepository photoRepository;
    
    @Value("${file.upload-dir}")
    private String uploadDir;
    
    public List<Photo> getAllPhotos() {
        return photoRepository.findAll();
    }
    
    public Photo uploadPhoto(MultipartFile file) throws IOException {
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
        
        // Save file
        Path filePath = uploadPath.resolve(uniqueFilename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        // Save to database
        Photo photo = new Photo(originalFilename, filePath.toString());
        return photoRepository.save(photo);
    }
    
    public Photo getPhotoById(Long id) {
        return photoRepository.findById(id).orElse(null);
    }
    
    public boolean deletePhoto(Long id) {
        if (photoRepository.existsById(id)) {
            Photo photo = photoRepository.findById(id).get();
            try {
                Files.deleteIfExists(Paths.get(photo.getFilePath()));
            } catch (IOException e) {
                e.printStackTrace();
            }
            photoRepository.deleteById(id);
            return true;
        }
        return false;
    }
}