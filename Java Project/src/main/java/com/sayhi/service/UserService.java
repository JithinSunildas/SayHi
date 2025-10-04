package com.sayhi.service;

import com.sayhi.model.User;
import java.util.List;

// Interface for user operations
public interface UserService {
    User addUser(User user);
    User getUserByUsername(String username);
    List<User> getAllUsers();
}