package com.example.sayhi.service;

import com.example.sayhi.model.Photo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class PhotoService {
    @Value("${photo.upload.dir}")
    private String uploadDir;

    public List<Photo> listPhotos() {
        File dir = new File(uploadDir);
        List<Photo> photos = new ArrayList<>();
        if (dir.exists()) {
            for (File file : dir.listFiles()) {
                photos.add(new Photo(file.getName(), "/api/photos/download/" + file.getName()));
            }
        }
        return photos;
    }

    public boolean savePhoto(MultipartFile file) throws IOException {
        File dest = new File(uploadDir, file.getOriginalFilename());
        file.transferTo(dest);
        return true;
    }

    public File getPhoto(String filename) {
        return new File(uploadDir, filename);
    }
}