package com.hitutor.controller;

import com.hitutor.dto.UserDTO;
import com.hitutor.entity.User;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import com.hitutor.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordUtil passwordUtil;

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser(@RequestParam(required = false) String userId) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        String targetUserId = userId;
        
        if (targetUserId == null || targetUserId.isEmpty()) {
            org.springframework.security.core.Authentication authentication = 
                SecurityContextHolder.getContext().getAuthentication();
            
            if (authentication == null || !authentication.isAuthenticated()) {
                response.put("success", false);
                response.put("message", "未登录");
                response.put("data", new java.util.HashMap<>());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            targetUserId = authentication.getName();
        }
        
        User user = userService.getUserById(targetUserId);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            response.put("data", new java.util.HashMap<>());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        response.put("success", true);
        response.put("message", "获取用户信息成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUser(@PathVariable String id) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        response.put("success", true);
        response.put("message", "获取用户信息成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }
    
    
    @PatchMapping("/{id}/role")
    public ResponseEntity<Map<String, Object>> updateUserRole(@PathVariable String id, @RequestBody Map<String, Object> userData) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        // 从 SecurityContextHolder 中获取用户 ID，确保使用 token 中的真实用户 ID
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String targetUserId = null;
        
        if (authentication != null && authentication.isAuthenticated() && !"anonymousUser".equals(authentication.getName())) {
            targetUserId = authentication.getName();
        } else {
            // 当 SecurityContext 中没有有效的用户 ID 时，使用路径参数中的用户 ID
            targetUserId = id;
        }
        
        // 使用用户 ID 查询用户
        User user = userService.getUserById(targetUserId);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            response.put("data", null);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        if (userData.containsKey("role") || userData.containsKey("roleId")) {
            String newRole = (String) (userData.containsKey("role") ? 
                userData.get("role") : userData.get("roleId"));
            
            if ("admin".equals(user.getRole())) {
                response.put("success", false);
                response.put("message", "禁止修改管理员角色");
                response.put("data", null);
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            if (!"student".equals(newRole) && !"tutor".equals(newRole)) {
                response.put("success", false);
                response.put("message", "角色类型错误");
                response.put("data", null);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            
            user.setRole(newRole);
        } else {
            response.put("success", false);
            response.put("message", "缺少角色参数");
            response.put("data", null);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        boolean updated = userService.updateUser(user);
        
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            response.put("data", null);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        // 重新查询用户，确保返回最新信息
        User updatedUser = userService.getUserById(targetUserId);
        
        response.put("success", true);
        response.put("message", "角色更新成功");
        response.put("data", DtoConverter.toUserDTO(updatedUser != null ? updatedUser : user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable String id, @RequestBody Map<String, Object> userData) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        User user = userService.getUserById(id);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        if (userData.containsKey("role") || userData.containsKey("roleId")) {
            String newRole = (String) (userData.containsKey("role") ? 
                userData.get("role") : userData.get("roleId"));
            
            user.setRole(newRole);
        }
        
        if (userData.containsKey("status")) {
            user.setStatus((String) userData.get("status"));
        }
        if (userData.containsKey("username")) {
            user.setUsername((String) userData.get("username"));
        }
        if (userData.containsKey("email")) {
            user.setEmail((String) userData.get("email"));
        }
        if (userData.containsKey("phone")) {
            user.setPhone((String) userData.get("phone"));
        }
        
        if (userData.containsKey("avatar")) {
            user.setAvatar((String) userData.get("avatar"));
        }
        if (userData.containsKey("gender")) {
            user.setGender((String) userData.get("gender"));
        }
        if (userData.containsKey("birthDate")) {
            user.setBirthDate(java.time.LocalDate.parse((String) userData.get("birthDate")));
        }
        if (userData.containsKey("teachingExperience")) {
            user.setTeachingExperience((Integer) userData.get("teachingExperience"));
        }
        
        boolean updated = userService.updateUser(user);
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("success", true);
        response.put("message", "更新成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/profile")
    public ResponseEntity<Map<String, Object>> updateProfile(@PathVariable String id, @RequestBody Map<String, Object> data) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        if (data.containsKey("username")) {
            user.setUsername((String) data.get("username"));
        }
        if (data.containsKey("avatar")) {
            user.setAvatar((String) data.get("avatar"));
        }
        if (data.containsKey("phone")) {
            user.setPhone((String) data.get("phone"));
        }
        if (data.containsKey("gender")) {
            user.setGender((String) data.get("gender"));
        }
        if (data.containsKey("birthDate")) {
            user.setBirthDate(java.time.LocalDate.parse((String) data.get("birthDate")));
        }
        if (data.containsKey("teachingExperience")) {
            user.setTeachingExperience((Integer) data.get("teachingExperience"));
        }

        boolean updated = userService.updateUser(user);
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("success", true);
        response.put("message", "更新成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tutors")
    public ResponseEntity<Map<String, Object>> getTutors(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> tutors = userService.getTutors();
        List<UserDTO> tutorDTOs = tutors.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", tutorDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", tutorDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取家教列表成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/tutors/search")
    public ResponseEntity<Map<String, Object>> searchTutors(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> tutors = userService.searchTutors(q, page, size);
        List<UserDTO> tutorDTOs = tutors.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", tutorDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", tutorDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "搜索家教成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/students/search")
    public ResponseEntity<Map<String, Object>> searchStudents(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> students = userService.searchStudents(q, page, size);
        List<UserDTO> studentDTOs = students.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", studentDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", studentDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "搜索学生成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/me/password")
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        org.springframework.security.core.Authentication authentication = 
            SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
        
        String userId = authentication.getName();
        User user = userService.getUserById(userId);
        
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        String oldPassword = request.get("oldPassword");
        String newPassword = request.get("newPassword");
        
        if (oldPassword == null || oldPassword.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "原密码不能为空");
            return ResponseEntity.badRequest().body(response);
        }
        
        if (newPassword == null || newPassword.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "新密码不能为空");
            return ResponseEntity.badRequest().body(response);
        }
        
        if (!passwordUtil.validatePassword(oldPassword, user.getPassword())) {
            response.put("success", false);
            response.put("message", "原密码错误");
            return ResponseEntity.badRequest().body(response);
        }
        
        user.setPassword(passwordUtil.encodePassword(newPassword));
        boolean updated = userService.updateUser(user);
        
        if (updated) {
            response.put("success", true);
            response.put("message", "密码修改成功");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "密码修改失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/{id}/statistics")
    public ResponseEntity<Map<String, Object>> getUserStatistics(@PathVariable String id) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        User user = userService.getUserById(id);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        Map<String, Object> statistics = userService.getUserStatistics(id);
        response.put("success", true);
        response.put("message", "获取用户统计信息成功");
        response.put("data", statistics);
        return ResponseEntity.ok(response);
    }
}