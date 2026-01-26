package com.hitutor.controller;

import com.hitutor.entity.User;
import com.hitutor.service.ComplaintService;
import com.hitutor.service.PointService;
import com.hitutor.service.StudentRequestService;
import com.hitutor.service.TutorProfileService;
import com.hitutor.service.UserService;
import com.hitutor.util.JwtUtil;
import com.hitutor.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private StudentRequestService studentRequestService;

    @Autowired
    private TutorProfileService tutorProfileService;

    @Autowired
    private PointService pointService;

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordUtil passwordUtil;

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> adminRegister(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");
        String username = request.get("username");

        if (email == null || email.trim().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "邮箱不能为空");
            return ResponseEntity.badRequest().body(response);
        }

        if (password == null || password.trim().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "密码不能为空");
            return ResponseEntity.badRequest().body(response);
        }

        User existingUser = userService.getUserByEmail(email);
        if (existingUser != null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "邮箱已被占用");
            return ResponseEntity.status(409).body(response);
        }

        User user = new User();
        user.setId(java.util.UUID.randomUUID().toString());
        user.setEmail(email);
        user.setPassword(passwordUtil.encodePassword(password));
        user.setRole("admin");
        user.setStatus("active");
        
        if (username == null || username.trim().isEmpty()) {
            username = email.split("@")[0];
        }
        user.setUsername(username);

        boolean saved = userService.saveUser(user);
        if (saved) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "管理员注册成功");
            return ResponseEntity.status(201).body(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "注册失败");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/users")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> users = userService.getAllUsers();
        
        for (User user : users) {
            Integer totalPoints = pointService.getTotalPoints(user.getId());
            user.setPoints(totalPoints);
        }
        
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("users", users);
        dataMap.put("total", users.size());
        dataMap.put("page", page);
        dataMap.put("size", size);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取用户列表成功");
        response.put("data", dataMap);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/users/{id}")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getUser(@PathVariable String id) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new HashMap<>();
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(404).body(response);
        }
        response.put("success", true);
        response.put("message", "获取用户信息成功");
        response.put("data", user);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/users/{id}/status")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> updateUserStatus(@PathVariable String id, @RequestBody Map<String, String> requestData) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new HashMap<>();
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(404).body(response);
        }
        
        String status = requestData.get("status");
        if (status != null) {
            user.setStatus(status);
            boolean updated = userService.updateUser(user);
            if (updated) {
                response.put("success", true);
                response.put("message", "更新用户状态成功");
                response.put("data", user);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "更新用户状态失败");
                return ResponseEntity.status(500).body(response);
            }
        }
        
        response.put("success", false);
        response.put("message", "状态不能为空");
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/users/{id}")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable String id) {
        boolean deleted = userService.deleteUser(id);
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("success", true);
            response.put("message", "删除用户成功");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(404).body(response);
        }
    }

    @GetMapping("/stats")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getSystemStats() {
        Map<String, Object> stats = new HashMap<>();
        
        List<User> allUsers = userService.getAllUsers();
        stats.put("totalUsers", allUsers.size());
        
        long activeTutors = allUsers.stream()
                .filter(user -> "tutor".equals(user.getRole()) && "active".equals(user.getStatus()))
                .count();
        long activeStudents = allUsers.stream()
                .filter(user -> "student".equals(user.getRole()) && "active".equals(user.getStatus()))
                .count();
        
        stats.put("activeTutors", activeTutors);
        stats.put("activeStudents", activeStudents);
        
        stats.put("pendingComplaints", complaintService.getPendingComplaintsCount());
        Map<String, Object> studentRequestResult = studentRequestService.getAllStudentRequests(0, 1000);
        Map<String, Object> tutorProfileResult = tutorProfileService.getAllTutorProfiles(0, 1000);
        stats.put("studentRequests", ((java.util.List<?>) studentRequestResult.get("content")).size());
        stats.put("tutorProfiles", ((java.util.List<?>) tutorProfileResult.get("content")).size());

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取系统统计成功");
        response.put("data", stats);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/stats/subject-distribution")
    @PreAuthorize("hasRole('admin')")
    @SuppressWarnings("unchecked")
    public ResponseEntity<Map<String, Object>> getSubjectDistribution() {
        Map<String, Object> result = new HashMap<>();
        
        Map<String, Object> studentRequestResult = studentRequestService.getAllStudentRequests(0, 1000);
        Map<String, Object> tutorProfileResult = tutorProfileService.getAllTutorProfiles(0, 1000);
        
        java.util.List<com.hitutor.entity.StudentRequest> studentRequests = 
            (java.util.List<com.hitutor.entity.StudentRequest>) studentRequestResult.get("content");
        java.util.List<com.hitutor.entity.TutorProfile> tutorProfiles = 
            (java.util.List<com.hitutor.entity.TutorProfile>) tutorProfileResult.get("content");
        
        java.util.Map<String, Integer> subjectCount = new java.util.HashMap<>();
        
        for (com.hitutor.entity.StudentRequest request : studentRequests) {
            String subjectName = request.getSubjectName();
            if (subjectName != null && !subjectName.isEmpty()) {
                subjectCount.put(subjectName, subjectCount.getOrDefault(subjectName, 0) + 1);
            }
        }
        
        for (com.hitutor.entity.TutorProfile profile : tutorProfiles) {
            String subjectName = profile.getSubjectName();
            if (subjectName != null && !subjectName.isEmpty()) {
                subjectCount.put(subjectName, subjectCount.getOrDefault(subjectName, 0) + 1);
            }
        }
        
        java.util.List<java.util.Map<String, Object>> distribution = new java.util.ArrayList<>();
        for (java.util.Map.Entry<String, Integer> entry : subjectCount.entrySet()) {
            java.util.Map<String, Object> item = new java.util.HashMap<>();
            item.put("name", entry.getKey());
            item.put("value", entry.getValue());
            distribution.add(item);
        }
        
        result.put("success", true);
        result.put("message", "获取科目分布成功");
        result.put("data", distribution);
        
        return ResponseEntity.ok(result);
    }
}