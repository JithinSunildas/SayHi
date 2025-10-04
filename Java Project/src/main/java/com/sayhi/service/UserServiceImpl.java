package com.sayhi.service;

import com.sayhi.model.User;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;

// User Service Implementation
@Service
public class UserServiceImpl implements UserService {
    private List<User> users = new ArrayList<>();

    @Override
    public User addUser(User user) {
        users.add(user);
        return user;
    }

    @Override
    public User getUserByUsername(String username) {
        return users.stream().filter(u -> u.getUsername().equals(username)).findFirst().orElse(null);
    }

    @Override
    public List<User> getAllUsers() {
        return users;
    }
}