package com.hitutor.controller;

import com.hitutor.entity.User;
import com.hitutor.service.UserService;
import com.hitutor.service.PointService;
import com.hitutor.service.VerificationService;
import com.hitutor.util.JwtUtil;
import com.hitutor.util.PasswordUtil;
import com.hitutor.util.UsernameGenerator;
import com.hitutor.util.IpUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordUtil passwordUtil;

    @Autowired
    private UsernameGenerator usernameGenerator;
    
    @Autowired
    private PointService pointService;
    
    @Autowired
    private VerificationService verificationService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");

        User user = userService.getUserByEmail(email);
        if (user != null && passwordUtil.validatePassword(password, user.getPassword())) {
            if (!"active".equals(user.getStatus())) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "账号已被禁用，请联系管理员");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            LocalDate today = LocalDate.now();
            boolean isFirstLoginToday = !pointService.hasLoginPointsToday(user.getId(), today);
            
            if (isFirstLoginToday) {
                pointService.addPoints(user.getId(), 5, "login", "每日登录奖励");
            }
            
            user.setLastLoginTime(LocalDateTime.now());
            userService.updateUser(user);
            
            String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            Map<String, Object> response = new HashMap<>();
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            data.put("isFirstLogin", false); 
            response.put("data", data);
            response.put("success", true);
            response.put("message", "登录成功");
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "邮箱或密码错误");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @PostMapping("/login-password")
    public ResponseEntity<Map<String, Object>> loginByPassword(@RequestBody Map<String, String> request, HttpServletRequest httpRequest) {
        String phone = request.get("phone");
        String password = request.get("password");

        User user = userService.getUserByPhone(phone);
        if (user != null && passwordUtil.validatePassword(password, user.getPassword())) {
            if (!"active".equals(user.getStatus())) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "账号已被禁用，请联系管理员");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            LocalDate today = LocalDate.now();
            boolean isFirstLoginToday = !pointService.hasLoginPointsToday(user.getId(), today);
            
            if (isFirstLoginToday) {
                pointService.addPoints(user.getId(), 5, "login", "每日登录奖励");
            }
            
            user.setLastLoginTime(LocalDateTime.now());
            user.setLastLoginIp(IpUtil.getClientIp(httpRequest));
            userService.updateUser(user);
            
            String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            Map<String, Object> response = new HashMap<>();
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            data.put("isFirstLogin", false); 
            response.put("data", data);
            response.put("success", true);
            response.put("message", "登录成功");
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "手机号或密码错误");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @PostMapping("/login-sms")
    public ResponseEntity<Map<String, Object>> loginBySms(@RequestBody Map<String, String> request, HttpServletRequest httpRequest) {
        
        String phone = request.get("phone");
        String verificationCode = request.get("verificationCode");
        String role = request.get("role");

        if (!verificationService.verifyCode(phone, verificationCode)) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "验证码错误或已过期");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        User user = userService.getUserByPhone(phone);
        if (user != null) {
            if (!"active".equals(user.getStatus())) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "账号已被禁用，请联系管理员");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            LocalDate today = LocalDate.now();
            boolean isFirstLoginToday = !pointService.hasLoginPointsToday(user.getId(), today);
            
            if (isFirstLoginToday) {
                pointService.addPoints(user.getId(), 5, "login", "每日登录奖励");
            }
            
            user.setLastLoginTime(LocalDateTime.now());
            user.setLastLoginIp(IpUtil.getClientIp(httpRequest));
            userService.updateUser(user);
            
            String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            Map<String, Object> response = new HashMap<>();
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            data.put("isFirstLogin", false); 
            response.put("data", data);
            response.put("success", true);
            response.put("message", "登录成功");
            return ResponseEntity.ok(response);
        } else {
            
            User newUser = new User();
            newUser.setId(java.util.UUID.randomUUID().toString()); 
            newUser.setPhone(phone);
            newUser.setPassword(passwordUtil.getDefaultEncodedPassword()); 
            
            
            newUser.setRole(role != null && !role.isEmpty() ? role : "student");
            newUser.setStatus("active"); 
            
            
            String defaultUsername = usernameGenerator.generateDefaultUsername();
            newUser.setUsername(defaultUsername); 
            
            // 设置首次登录时间
            LocalDateTime now = LocalDateTime.now();
            newUser.setLastLoginTime(now);
            newUser.setLastLoginIp(IpUtil.getClientIp(httpRequest));
            
            boolean saved = userService.saveUser(newUser);
            if (saved) {
                // 新用户注册登录，也给5积分
                pointService.addPoints(newUser.getId(), 5, "login", "每日登录奖励");
                
                String token = jwtUtil.generateToken(newUser.getId(), newUser.getUsername(), newUser.getRole());
                Map<String, Object> response = new HashMap<>();
                Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", newUser);
            data.put("isFirstLogin", true); 
            response.put("data", data);
                response.put("success", true);
                response.put("message", "注册并登录成功");
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "用户创建失败");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        }
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<Map<String, Object>> refreshToken(@RequestBody Map<String, String> request) {
        
        String refreshToken = request.get("refreshToken");
        try {
            
            String userId = jwtUtil.getUserIdFromToken(refreshToken);
            String username = jwtUtil.getUsernameFromToken(refreshToken);
            String role = jwtUtil.getRoleFromToken(refreshToken);
            
            
            String newToken = jwtUtil.generateToken(userId, username, role);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "令牌刷新成功");
            response.put("token", newToken);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "无效的刷新令牌");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");
        String email = request.get("email");
        String role = request.get("role");
        String phone = request.get("phone");
        String verificationCode = request.get("verificationCode");

        if (!verificationService.verifyCode(phone, verificationCode)) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "验证码错误或已过期");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        
        User existingUserByEmail = userService.getUserByEmail(email);
        User existingUserByPhone = userService.getUserByPhone(phone);
        if (existingUserByEmail != null || existingUserByPhone != null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "邮箱或手机号已被占用");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        }

        User user = new User();
        user.setId(java.util.UUID.randomUUID().toString()); 
        
        if (username == null || username.trim().isEmpty()) {
            username = usernameGenerator.generateDefaultUsername();
        }
        user.setUsername(username);
        user.setPassword(passwordUtil.encodePassword(password)); 
        user.setEmail(email);
        user.setRole(role != null ? role : "student"); 
        user.setPhone(phone);
        user.setStatus("active"); 

        boolean saved = userService.saveUser(user);
        if (saved) {
            String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            Map<String, Object> response = new HashMap<>();
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            data.put("isFirstLogin", true); 
            response.put("data", data);
            response.put("success", true);
            response.put("message", "注册成功");
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "注册失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> request) {
        
        String phone = request.get("phone");
        verificationService.sendVerificationCode(phone);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "验证码已发送至您的手机，请注意查收");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> request) {
        
        String phone = request.get("phone");
        String verificationCode = request.get("verificationCode");
        String newPassword = request.get("newPassword");

        if (!verificationService.verifyCode(phone, verificationCode)) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "验证码错误或已过期");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        User user = userService.getUserByPhone(phone);
        if (user != null) {
            user.setPassword(passwordUtil.encodePassword(newPassword)); 
            boolean updated = userService.updateUser(user);
            if (updated) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "密码重置成功");
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "密码重置失败");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "找不到对应的用户");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }
    
    @PostMapping("/check-login")
    public ResponseEntity<Map<String, Object>> checkLogin() {
        
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
        
        String userId = authentication.getName();
        User user = userService.getUserById(userId);
        
        if (user == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        // 处理每日登录积分
        LocalDate today = LocalDate.now();
        
        // 检查是否为当日首次登录（通过积分记录表判断）
        boolean isFirstLoginToday = !pointService.hasLoginPointsToday(user.getId(), today);
        
        // 如果是首次登录，加5积分
        if (isFirstLoginToday) {
            pointService.addPoints(user.getId(), 5, "login", "每日登录奖励");
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "登录检查成功");
        response.put("isFirstLoginToday", isFirstLoginToday);
        return ResponseEntity.ok(response);
    }
}