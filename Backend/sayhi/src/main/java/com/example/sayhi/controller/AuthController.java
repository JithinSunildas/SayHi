package com.example.sayhi.controller;

import com.example.sayhi.model.User;
import com.example.sayhi.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private UserService userService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody User user) {
        if (userService.signup(user.getUsername(), user.getPassword())) {
            return ResponseEntity.status(201).build();
        }
        return ResponseEntity.badRequest().body("Username already exists");
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        if (userService.login(user.getUsername(), user.getPassword())) {
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }
}