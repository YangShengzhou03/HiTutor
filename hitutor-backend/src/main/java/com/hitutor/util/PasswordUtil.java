package com.hitutor.util;

import org.springframework.stereotype.Component;

@Component
public class PasswordUtil {
    
    public String encodePassword(String rawPassword) {
        return rawPassword;
    }
    
    public boolean validatePassword(String rawPassword, String storedPassword) {
        return rawPassword.equals(storedPassword);
    }
    
    public String getDefaultEncodedPassword() {
        return generateRandomPassword(); 
    }
    
    private String generateRandomPassword() {
        String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        StringBuilder password = new StringBuilder(12);
        for (int i = 0; i < 12; i++) {
            password.append(CHARACTERS.charAt((int)(Math.random() * CHARACTERS.length())));
        }
        return password.toString();
    }
}