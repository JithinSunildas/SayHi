package com.example.sayhi.controller;

import com.example.sayhi.model.User;
import com.example.sayhi.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody User user) {
        Map<String, Object> response = new HashMap<>();
        
        if (user.getUsername() == null || user.getPassword() == null) {
            response.put("success", false);
            response.put("message", "Username and password required");
            return ResponseEntity.badRequest().body(response);
        }
        
        boolean success = userService.login(user.getUsername(), user.getPassword());
        
        if (success) {
            response.put("success", true);
            response.put("message", "Login successful");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Invalid credentials");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }
    
    @PostMapping("/signup")
    public ResponseEntity<Map<String, Object>> signup(@RequestBody User user) {
        Map<String, Object> response = new HashMap<>();
        
        if (user.getUsername() == null || user.getPassword() == null) {
            response.put("success", false);
            response.put("message", "Username and password required");
            return ResponseEntity.badRequest().body(response);
        }
        
        // Check if user already exists
        if (userService.userExists()) {
            response.put("success", false);
            response.put("message", "User already exists. Only one user allowed.");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        }
        
        boolean success = userService.signup(user.getUsername(), user.getPassword());
        
        if (success) {
            response.put("success", true);
            response.put("message", "Signup successful");
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } else {
            response.put("success", false);
            response.put("message", "Signup failed");
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> checkUserExists() {
        Map<String, Object> response = new HashMap<>();
        response.put("userExists", userService.userExists());
        return ResponseEntity.ok(response);
    }
}