package com.hitutor.util;

import com.hitutor.entity.User;
import com.hitutor.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UsernameGenerator {
    
    @Autowired
    private UserService userService;
    
    
    public String generateUniqueUsername(String prefix) {
        String username;
        int counter = 0;
        
        do {
            if (counter == 0) {
                username = prefix + System.currentTimeMillis() % 100000;
            } else {
                username = prefix + System.currentTimeMillis() % 100000 + "_" + counter;
            }
            counter++;
        } while (userService.getUserByUsername(username) != null && counter < 100); 
        
        return username;
    }
    
    
    public String generateDefaultUsername() {
        return generateUniqueUsername("用户");
    }
}