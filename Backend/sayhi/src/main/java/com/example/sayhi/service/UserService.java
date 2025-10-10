package com.example.sayhi.service;

import com.example.sayhi.entity.User;
import com.example.sayhi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public boolean login(String username, String password) {
        Optional<User> user = userRepository.findByUsername(username);
        return user.isPresent() && user.get().getPassword().equals(password);
    }
    
    public boolean signup(String username, String password) {
        // Check if any user already exists
        if (userRepository.count() > 0) {
            return false; // Only one user allowed
        }
        
        // Check if username already exists
        if (userRepository.existsByUsername(username)) {
            return false;
        }
        
        User newUser = new User(username, password);
        userRepository.save(newUser);
        return true;
    }
    
    public boolean userExists() {
        return userRepository.count() > 0;
    }
}
